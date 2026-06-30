<?php
header('Content-Type: application/json; charset=utf-8');

$data = json_decode(file_get_contents('php://input'), true);
$userMessage = trim($data['message'] ?? '');

if(empty($userMessage)) {
    echo json_encode(['reply' => 'Lỗi: Không nhận được tin nhắn.']);
    exit;
}

// ==========================================
// 1. KẾT NỐI DATABASE MYSQL VÀ TÌM KIẾM TỪ KHÓA
// ==========================================
$db_host = 'localhost';
$db_user = 'root';
$db_pass = '';
$db_name = 'uth_db';
$contextFromDB = ""; 

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // Tách câu hỏi thành các từ để tìm kiếm
    $words = explode(" ", $userMessage);
    $searchConditions = [];
    $params = [];
    foreach($words as $word) {
        if(mb_strlen($word, 'UTF-8') > 2) { 
            $searchConditions[] = "tu_khoa LIKE ?";
            $params[] = "%$word%";
        }
    }

    if(!empty($searchConditions)) {
        $sql = "SELECT noi_dung, link_dieu_huong FROM faq WHERE " . implode(" OR ", $searchConditions) . " LIMIT 3";
        $stmt = $pdo->prepare($sql);
        $stmt->execute($params);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach($results as $row) {
            $contextFromDB .= "- Thông tin: " . $row['noi_dung'] . " (Link tham khảo: " . $row['link_dieu_huong'] . ")\n";
        }
    }
} catch(PDOException $e) {
    // Nếu lỗi DB thì cứ chạy tiếp không sao
}

// ==========================================
// 2. GỌI AI GEMINI ĐỂ XỬ LÝ CÂU TRẢ LỜI
// ==========================================
// BẠN PHẢI THAY MÃ API KEY CỦA BẠN VÀO DÒNG DƯỚI NÀY NHÉ:
include 'config.php';
$apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=' . $apiKey;

$systemPrompt = "Bạn là trợ lý ảo thân thiện của ĐH Giao thông Vận tải TP.HCM (UTH). 
Quy tắc trả lời:
1. NẾU BÊN DƯỚI CÓ 'TÀI LIỆU TỪ HỆ THỐNG', hãy dựa HOÀN TOÀN vào tài liệu đó để trả lời sinh viên sao cho dễ hiểu nhất. Nếu có Link tham khảo thì hãy đưa cho sinh viên.
2. NẾU KHÔNG CÓ 'TÀI LIỆU TỪ HỆ THỐNG', nghĩa là câu hỏi chưa có trong CSDL, BẮT BUỘC trả lời đúng nguyên văn: 'TICKET_TRIGGER: Xin lỗi, câu hỏi này mình chưa có thông tin. Mình đã tạo 1 Ticket gửi cho Ban quản trị để hỗ trợ bạn nhé.'

TÀI LIỆU TỪ HỆ THỐNG CỦA TRƯỜNG DÀNH CHO CÂU HỎI NÀY:
" . ($contextFromDB != "" ? $contextFromDB : "Không tìm thấy tài liệu.");

$payload = [
    "system_instruction" => ["parts" => [["text" => $systemPrompt]]],
    "contents" => [["role" => "user", "parts" => [["text" => $userMessage]]]],
    "generationConfig" => ["temperature" => 0.1, "maxOutputTokens" => 200]
];

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // Bỏ qua lỗi SSL của XAMPP

$response = curl_exec($ch);
curl_close($ch);

// Kiểm tra lỗi đường truyền của XAMPP
if ($response === false) {
    echo json_encode(['reply' => 'LỖI MẠNG XAMPP: ' . curl_error($ch)]);
    exit;
}

$responseData = json_decode($response, true);

// Kiểm tra lỗi Google trả về (Ví dụ: Sai Key, hết tiền, bị chặn vùng...)
if (isset($responseData['error'])) {
    echo json_encode(['reply' => 'LỖI TỪ GOOGLE: ' . $responseData['error']['message']]);
    exit;
}

// Nếu mượt mà thì in ra câu trả lời
$botReply = $responseData['candidates'][0]['content']['parts'][0]['text'] ?? "Lỗi lạ: Không đọc được dữ liệu JSON.";

// XỬ LÝ TỰ ĐỘNG LƯU TICKET VÀO DATABASE KHI AI BẾ TẮC

if (strpos($botReply, 'TICKET_TRIGGER') !== false) {
    try {
        session_start(); // Lấy phiên đăng nhập để biết ai đang chat
        $student_name = $_SESSION['user'] ?? 'Sinh viên';
        $mssv = $_SESSION['mssv'] ?? '0000000000';
        
        // Tự động chế tiêu đề từ một vài từ đầu của câu hỏi
        $title = "Hỗ trợ về: " . mb_substr($userMessage, 0, 30) . "...";
        
        // Ghi vào Database (Bảng tickets)
        $pdo = new PDO("mysql:host=localhost;dbname=uth_db;charset=utf8mb4", "root", "");
        $sqlInsert = "INSERT INTO tickets (student_name, mssv, title, content, status) VALUES (?, ?, ?, ?, 'pending')";
        $stmtInsert = $pdo->prepare($sqlInsert);
        $stmtInsert->execute([$student_name, $mssv, $title, $userMessage]);
        
    } catch(PDOException $e) {
        // Bỏ qua lỗi nếu có
    }
    
    // Đổi lại câu trả lời cho thân thiện trước khi in ra màn hình
    $botReply = "Xin lỗi, thông tin này chưa có trong dữ liệu của mình. Mình đã tự động tạo 1 phiếu hỗ trợ gửi đến Ban quản trị. Bạn để ý mục Thông báo trên góc phải màn hình nhé!";
}
echo json_encode(['reply' => trim($botReply)]);
?>
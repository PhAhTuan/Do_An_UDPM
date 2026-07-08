<?php
require_once 'config.php';

header('Content-Type: application/json; charset=utf-8');

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data || !isset($data['question']) || !isset($data['answer'])) {
    echo json_encode(['success' => false, 'message' => 'Dữ liệu không hợp lệ.']);
    exit;
}

$question = trim($data['question']);
$answer = trim($data['answer']);
$mssv = isset($data['mssv']) && $data['mssv'] !== '' ? trim($data['mssv']) : 'Khách';
$studentName = isset($data['studentName']) && $data['studentName'] !== '' ? trim($data['studentName']) : 'Khách truy cập';

// Giới hạn độ dài để tránh spam
$question = mb_substr($question, 0, 500, 'UTF-8');
$answer = mb_substr($answer, 0, 1000, 'UTF-8');

// Tạo nội dung ticket
$title = "[Báo lỗi Chatbot] Câu trả lời không chính xác";
$content = "CÂU HỎI CỦA SINH VIÊN:\n" . $question . "\n\nCÂU TRẢ LỜI CỦA CHATBOT:\n" . $answer;

try {
    $pdo = new PDO("mysql:host=$db_host;port=$db_port;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $stmt = $pdo->prepare("INSERT INTO tickets (student_name, mssv, title, content, status) VALUES (?, ?, ?, ?, 'pending')");
    $stmt->execute([$studentName, $mssv, $title, $content]);
    
    echo json_encode(['success' => true, 'message' => 'Báo cáo đã được gửi tới Admin.']);
} catch (PDOException $e) {
    error_log("Lỗi gửi báo cáo chatbot: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Lỗi kết nối CSDL.']);
}
?>

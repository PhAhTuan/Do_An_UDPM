<?php
session_start();
require_once __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

header('Content-Type: application/json; charset=utf-8');

$input = file_get_contents('php://input');
$data = json_decode($input, true);

if (!$data || !isset($data['question']) || !isset($data['answer'])) {
    echo json_encode(['success' => false, 'message' => 'Dữ liệu không hợp lệ.']);
    exit;
}

$question = trim($data['question']);
$answer = trim($data['answer']);
$mssv = isset($data['mssv']) && $data['mssv'] !== '' ? trim($data['mssv']) : ($_SESSION['mssv'] ?? '');
$studentName = isset($data['studentName']) && $data['studentName'] !== '' ? trim($data['studentName']) : ($_SESSION['ho_ten'] ?? 'Khách truy cập');
$messageId = (int)($data['messageId'] ?? 0);

// Giới hạn độ dài để tránh spam
$question = mb_substr($question, 0, 500, 'UTF-8');
$answer = mb_substr($answer, 0, 1000, 'UTF-8');

// Tạo nội dung ticket
$title = "[Báo lỗi Chatbot] Câu trả lời không chính xác";
$content = "CÂU HỎI CỦA SINH VIÊN:\n" . $question . "\n\nCÂU TRẢ LỜI CỦA CHATBOT:\n" . $answer;

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    $student = isset($_SESSION['user_id']) ? appStudentByUserId($pdo, (int)$_SESSION['user_id']) : null;
    if (!$student && $mssv !== '') {
        $student = appStudentByCode($pdo, $mssv);
    }

    if ($messageId > 0) {
        dbExecute($pdo, "
            INSERT INTO chat_feedback (message_id, user_id, rating, reason_code, comment)
            VALUES (?, ?, 'down', 'incorrect', ?)
            ON DUPLICATE KEY UPDATE rating = VALUES(rating), reason_code = VALUES(reason_code), comment = VALUES(comment)
        ", [$messageId, $_SESSION['user_id'] ?? null, 'Báo cáo từ giao diện chatbot']);
    }
    
    appCreateSupportTicket($pdo, $student ?: [
        'ho_ten' => $studentName,
        'mssv' => $mssv,
    ], $title, $content, $_SESSION['chat_session_db_id'] ?? null);
    
    echo json_encode(['success' => true, 'message' => 'Báo cáo đã được gửi tới Admin.']);
} catch (Throwable $e) {
    error_log("Lỗi gửi báo cáo chatbot: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Lỗi kết nối CSDL.']);
}
?>

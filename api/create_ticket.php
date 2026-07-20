<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

// Chỉ sinh viên đã đăng nhập mới tạo được ticket
if (!isset($_SESSION['user_id']) || ($_SESSION['role'] ?? '') !== 'student') {
    echo json_encode(['success' => false, 'error' => 'Bạn cần đăng nhập để tạo ticket hỗ trợ.']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true) ?: [];
$subject     = trim($data['subject'] ?? '');
$description = trim($data['description'] ?? '');

if ($subject === '' || $description === '') {
    echo json_encode(['success' => false, 'error' => 'Thiếu tiêu đề hoặc nội dung ticket.']);
    exit;
}

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    $mssv   = $_SESSION['mssv'] ?? '';
    $hoTen  = $_SESSION['ho_ten'] ?? 'Sinh viên';
    $userId = (int)$_SESSION['user_id'];
    $student = appStudentByUserId($pdo, $userId);
    $studentId = $student ? (int)$student['student_id'] : null;
    $sourceChatSessionId = (int)($_SESSION['chat_session_db_id'] ?? 0);
    if ($sourceChatSessionId > 0) {
        $sourceChatSessionId = (int)dbFetchValue($pdo, "
            SELECT id
            FROM chat_sessions
            WHERE id = ?
              AND (user_id = ? OR user_id IS NULL)
            LIMIT 1
        ", [$sourceChatSessionId, $userId]);
    }
    if ($sourceChatSessionId <= 0) {
        $sourceChatSessionId = null;
    }

    // Sinh ticket_number dạng TK-YYYYMMDD-XXXX
    $ticketNumber = 'TK-' . date('Ymd') . '-' . strtoupper(substr(uniqid(), -4));

    dbExecute($pdo, "
        INSERT INTO tickets
            (ticket_number, student_id, requester_student_code, requester_name, subject, description, status, source_chat_session_id, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, 'open', ?, NOW(), NOW())
    ", [
        $ticketNumber,
        $studentId,
        $student['mssv'] ?? $mssv,
        $student['ho_ten'] ?? $hoTen,
        mb_substr($subject, 0, 255, 'UTF-8'),
        $description,
        $sourceChatSessionId,
    ]);

    $ticketId = (int)$pdo->lastInsertId();

    // Lưu tin nhắn đầu tiên của SV vào ticket_messages
    dbExecute($pdo, "
        INSERT INTO ticket_messages (ticket_id, sender_user_id, sender_role, message, created_at)
        VALUES (?, ?, 'student', ?, NOW())
    ", [$ticketId, $userId, $description]);

    echo json_encode([
        'success'       => true,
        'ticket_id'     => $ticketId,
        'ticket_number' => $ticketNumber,
    ]);
} catch (Exception $e) {
    error_log('create_ticket.php: ' . $e->getMessage());
    echo json_encode(['success' => false, 'error' => 'Lỗi hệ thống, vui lòng thử lại sau.']);
}

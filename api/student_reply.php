<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

if (isset($_POST['ticket_id'])) {
    $ticketId = intval($_POST['ticket_id']);
    $message = trim((string)($_POST['message'] ?? ''));
    if (!isset($_SESSION['mssv']) || !isset($_SESSION['user_id'])) {
        echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
        exit;
    }
    if ($message === '') {
        echo json_encode(['success' => false, 'error' => 'Nội dung phản hồi trống']);
        exit;
    }

    $ticket = dbFetchOne($pdo, "
        SELECT status
        FROM tickets
        WHERE id = ?
          AND requester_student_code = ?
        LIMIT 1
    ", [$ticketId, $_SESSION['mssv'] ?? '']);
    if (!$ticket) {
        echo json_encode(['success' => false, 'error' => 'Bạn không có quyền phản hồi ticket này']);
        exit;
    }
    if (($ticket['status'] ?? '') === 'closed') {
        echo json_encode(['success' => false, 'error' => 'Ticket đã đóng']);
        exit;
    }

    dbExecute($pdo, "INSERT INTO ticket_messages (ticket_id, sender_user_id, sender_role, message) VALUES (?, ?, 'student', ?)", [
        $ticketId,
        $_SESSION['user_id'] ?? null,
        $message,
    ]);
    dbExecute($pdo, "UPDATE tickets SET status = 'in_progress' WHERE id = ? AND requester_student_code = ? AND status <> 'closed'", [
        $ticketId,
        $_SESSION['mssv'] ?? '',
    ]);
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false]);
}

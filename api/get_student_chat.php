<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

if (!isset($_SESSION['mssv'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

$ticket_id = intval($_GET['id'] ?? 0);

$messages = dbFetchAll($pdo, "SELECT sender_role, message, DATE_FORMAT(created_at, '%H:%i %d/%m') as time_str 
                       FROM ticket_messages WHERE ticket_id = ? ORDER BY created_at ASC", [$ticket_id]);

$ticket = dbFetchOne($pdo, "SELECT status FROM tickets WHERE id = ? AND requester_student_code = ?", [$ticket_id, $_SESSION['mssv']]);

echo json_encode(['success' => true, 'messages' => $messages, 'is_closed' => (($ticket['status'] ?? '') === 'closed') ? 1 : 0]);

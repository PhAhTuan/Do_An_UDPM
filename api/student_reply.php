<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

if (isset($_POST['ticket_id'])) {
    $ticketId = intval($_POST['ticket_id']);
    dbExecute($pdo, "INSERT INTO ticket_messages (ticket_id, sender_user_id, sender_role, message) VALUES (?, ?, 'student', ?)", [
        $ticketId,
        $_SESSION['user_id'] ?? null,
        $_POST['message'],
    ]);
    dbExecute($pdo, "UPDATE tickets SET status = 'in_progress' WHERE id = ? AND requester_student_code = ? AND status <> 'closed'", [
        $ticketId,
        $_SESSION['mssv'] ?? '',
    ]);
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false]);
}

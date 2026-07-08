<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

include  __DIR__.'/config.php';
require_once __DIR__.'/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

if (isset($_POST['ticket_id'])) {
    $stmt = $pdo->prepare("INSERT INTO ticket_messages (ticket_id, sender_role, message) VALUES (?, 'student', ?)");
    $stmt->execute([intval($_POST['ticket_id']), $_POST['message']]);
    // Cập nhật lại trạng thái ticket để admin biết có tin mới
    $pdo->prepare("UPDATE tickets SET status = 'pending' WHERE id = ?")->execute([intval($_POST['ticket_id'])]);
    echo json_encode(['success' => true]);
} else {
    echo json_encode(['success' => false]);
}
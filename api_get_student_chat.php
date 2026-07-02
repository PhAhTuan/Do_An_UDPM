<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

// Chỉ cho sinh viên đăng nhập mới được xem
if (!isset($_SESSION['mssv'])) {
    echo json_encode(['success' => false, 'error' => 'Chưa đăng nhập']);
    exit;
}

$pdo = new PDO("mysql:host=localhost;dbname=uth_db;charset=utf8mb4", "root", "");
$ticket_id = $_GET['id'] ?? 0;

$stmt = $pdo->prepare("SELECT sender_role, message, DATE_FORMAT(created_at, '%H:%i %d/%m') as time_str 
                       FROM ticket_messages WHERE ticket_id = ? ORDER BY created_at ASC");
$stmt->execute([$ticket_id]);
$messages = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Kiểm tra xem Ticket có bị đóng chưa
$stmtTicket = $pdo->prepare("SELECT is_closed FROM tickets WHERE id = ?");
$stmtTicket->execute([$ticket_id]);
$ticket = $stmtTicket->fetch(PDO::FETCH_ASSOC);

echo json_encode(['success' => true, 'messages' => $messages, 'is_closed' => $ticket['is_closed']]);
?>
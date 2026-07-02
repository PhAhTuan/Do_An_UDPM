<?php
header('Content-Type: application/json; charset=utf-8');

$db_host = 'localhost';
$db_user = 'root';
$db_pass = '';
$db_name = 'uth_db';

try {
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    
    $ticket_id = $_GET['id'] ?? 0;
    
    // 1. Lấy lịch sử chat trong bảng ticket_messages
    $stmt = $pdo->prepare("SELECT sender_role, message, DATE_FORMAT(created_at, '%H:%i %d/%m') as time_str FROM ticket_messages WHERE ticket_id = ? ORDER BY created_at ASC");
    $stmt->execute([$ticket_id]);
    $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 2. Kiểm tra xem Ticket này đã bị Admin khóa chưa
    $stmtTicket = $pdo->prepare("SELECT is_closed FROM tickets WHERE id = ?");
    $stmtTicket->execute([$ticket_id]);
    $ticket = $stmtTicket->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        'success' => true, 
        'messages' => $messages,
        'is_closed' => $ticket['is_closed'] ?? 0
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
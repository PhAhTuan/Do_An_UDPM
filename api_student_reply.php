<?php
session_start();
$pdo = new PDO("mysql:host=localhost;dbname=uth_db;charset=utf8mb4", "root", "");
if(isset($_POST['ticket_id'])) {
    $stmt = $pdo->prepare("INSERT INTO ticket_messages (ticket_id, sender_role, message) VALUES (?, 'student', ?)");
    $stmt->execute([$_POST['ticket_id'], $_POST['message']]);
    
    // Cập nhật lại trạng thái ticket để admin biết có tin mới
    $pdo->prepare("UPDATE tickets SET status = 'pending' WHERE id = ?")->execute([$_POST['ticket_id']]);
}
?>
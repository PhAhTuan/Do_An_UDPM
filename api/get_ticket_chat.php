<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    $ticket_id = intval($_GET['id'] ?? 0);
    if ($ticket_id <= 0) {
        echo json_encode(['success' => false, 'error' => 'Ticket không hợp lệ.']);
        exit;
    }

    $role = $_SESSION['role'] ?? '';
    $isAdmin = in_array($role, ['admin', 'staff', 'knowledge_reviewer'], true);
    if ($isAdmin) {
        $ticket = dbFetchOne($pdo, "SELECT status FROM tickets WHERE id = ?", [$ticket_id]);
    } else {
        $ticket = dbFetchOne($pdo, "
            SELECT status
            FROM tickets
            WHERE id = ?
              AND requester_student_code = ?
        ", [$ticket_id, $_SESSION['mssv'] ?? '']);
    }

    if (!$ticket) {
        echo json_encode(['success' => false, 'error' => 'Bạn không có quyền xem ticket này.']);
        exit;
    }

    $messages = dbFetchAll($pdo, "SELECT sender_role, message, DATE_FORMAT(created_at, '%H:%i %d/%m') as time_str 
                           FROM ticket_messages WHERE ticket_id = ? ORDER BY created_at ASC", [$ticket_id]);

    echo json_encode([
        'success'   => true,
        'messages'  => $messages,
        'is_closed' => (($ticket['status'] ?? '') === 'closed') ? 1 : 0,
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}

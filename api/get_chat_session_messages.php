<?php

declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../core/faq_helpers.php';

function chatSessionJson(int $status, array $payload): void
{
    http_response_code($status);
    echo json_encode(
        $payload,
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    );
    exit;
}

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        chatSessionJson(405, [
            'success' => false,
            'message' => 'Phương thức không được hỗ trợ.',
        ]);
    }

    $role = (string)($_SESSION['role'] ?? '');
    if (empty($_SESSION['user_id'])) {
        chatSessionJson(401, [
            'success' => false,
            'message' => 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.',
        ]);
    }

    if (!in_array($role, ['admin', 'staff'], true)) {
        chatSessionJson(403, [
            'success' => false,
            'message' => 'Bạn không có quyền xem nội dung phiên chat.',
        ]);
    }

    $sessionId = filter_input(INPUT_GET, 'session_id', FILTER_VALIDATE_INT);
    if (!$sessionId || $sessionId < 1) {
        chatSessionJson(422, [
            'success' => false,
            'message' => 'Mã phiên chat không hợp lệ.',
        ]);
    }

    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    $sessionStmt = $pdo->prepare("
        SELECT
            cs.id,
            cs.session_uuid,
            cs.title,
            cs.channel,
            cs.status,
            cs.language_code,
            cs.context_summary,
            cs.started_at,
            cs.last_activity_at,
            cs.closed_at,
            u.username,
            u.full_name,
            sp.student_code
        FROM chat_sessions cs
        INNER JOIN users u ON u.id = cs.user_id
        INNER JOIN roles r ON r.id = u.role_id AND r.code = 'student'
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        WHERE cs.id = :session_id
        LIMIT 1
    ");
    $sessionStmt->execute(['session_id' => $sessionId]);
    $session = $sessionStmt->fetch(PDO::FETCH_ASSOC);

    if (!$session) {
        chatSessionJson(404, [
            'success' => false,
            'message' => 'Không tìm thấy phiên trò chuyện.',
        ]);
    }

    $messageStmt = $pdo->prepare("
        SELECT
            cm.id,
            cm.parent_message_id,
            cm.sender_type,
            cm.content,
            cm.detected_intent,
            cm.model_name,
            cm.prompt_tokens,
            cm.completion_tokens,
            cm.latency_ms,
            cm.confidence_score,
            cm.answer_status,
            cm.created_at,
            (
                SELECT cf.rating
                FROM chat_feedback cf
                WHERE cf.message_id = cm.id
                ORDER BY cf.created_at DESC, cf.id DESC
                LIMIT 1
            ) AS feedback_rating,
            (
                SELECT cf.reason_code
                FROM chat_feedback cf
                WHERE cf.message_id = cm.id
                ORDER BY cf.created_at DESC, cf.id DESC
                LIMIT 1
            ) AS feedback_reason
        FROM chat_messages cm
        WHERE cm.session_id = :session_id
        ORDER BY cm.created_at ASC, cm.id ASC
    ");
    $messageStmt->execute(['session_id' => $sessionId]);
    $messages = $messageStmt->fetchAll(PDO::FETCH_ASSOC);

    chatSessionJson(200, [
        'success' => true,
        'session' => $session,
        'messages' => $messages,
        'isClosed' => $session['status'] === 'closed' || !empty($session['closed_at']),
    ]);
} catch (Throwable $exception) {
    error_log('get_chat_session_messages.php: ' . $exception->getMessage());
    chatSessionJson(500, [
        'success' => false,
        'message' => 'Không thể tải nội dung phiên trò chuyện.',
    ]);
}

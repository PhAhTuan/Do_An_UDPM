<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'Bạn chưa đăng nhập.']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true) ?: [];
$messageId = (int)($data['messageId'] ?? 0);
$rating = $data['rating'] ?? '';
$reason = $data['reasonCode'] ?? null;
$comment = trim((string)($data['comment'] ?? ''));

if ($messageId <= 0 || !in_array($rating, ['up', 'down'], true)) {
    echo json_encode(['success' => false, 'message' => 'Dữ liệu đánh giá không hợp lệ.']);
    exit;
}

$allowedReasons = ['incorrect','outdated','irrelevant','unclear','unsafe','helpful','other'];
if ($reason !== null && !in_array($reason, $allowedReasons, true)) {
    $reason = 'other';
}

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    dbExecute($pdo, "
        INSERT INTO chat_feedback (message_id, user_id, rating, reason_code, comment)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            rating = VALUES(rating),
            reason_code = VALUES(reason_code),
            comment = VALUES(comment)
    ", [
        $messageId,
        (int)$_SESSION['user_id'],
        $rating,
        $reason ?: ($rating === 'up' ? 'helpful' : 'incorrect'),
        $comment ?: null,
    ]);

    echo json_encode(['success' => true], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    error_log('chat_feedback: '.$e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Không lưu được đánh giá.'], JSON_UNESCAPED_UNICODE);
}

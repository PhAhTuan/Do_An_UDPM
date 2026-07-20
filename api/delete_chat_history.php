<?php
session_start();
header('Content-Type: application/json; charset=utf-8');

require_once __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'error' => 'Phương thức không hợp lệ.'], JSON_UNESCAPED_UNICODE);
    exit;
}

if (!isset($_SESSION['user_id']) || ($_SESSION['role'] ?? '') !== 'student') {
    http_response_code(401);
    echo json_encode(['success' => false, 'error' => 'Bạn cần đăng nhập bằng tài khoản sinh viên.'], JSON_UNESCAPED_UNICODE);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true) ?: [];
$userId = (int)$_SESSION['user_id'];

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    if (!empty($data['deleteAll'])) {
        $deleted = dbExecute($pdo, "DELETE FROM chat_sessions WHERE user_id = ?", [$userId]);
        unset($_SESSION['chat_session_uuid'], $_SESSION['chat_session_db_id'], $_SESSION['chat_session_user_id']);

        echo json_encode([
            'success' => true,
            'deleted' => $deleted,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $sessionUuid = trim((string)($data['sessionUuid'] ?? ''));
    if (!preg_match('/^[0-9a-fA-F-]{36}$/', $sessionUuid)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'error' => 'Phiên chat không hợp lệ.'], JSON_UNESCAPED_UNICODE);
        exit;
    }

    $deleted = dbExecute($pdo, "
        DELETE FROM chat_sessions
        WHERE user_id = ?
          AND session_uuid = ?
    ", [$userId, $sessionUuid]);

    if (($_SESSION['chat_session_uuid'] ?? '') === $sessionUuid) {
        unset($_SESSION['chat_session_uuid'], $_SESSION['chat_session_db_id'], $_SESSION['chat_session_user_id']);
    }

    echo json_encode([
        'success' => true,
        'deleted' => $deleted,
    ], JSON_UNESCAPED_UNICODE);
} catch (Throwable $e) {
    error_log('delete_chat_history.php: '.$e->getMessage());
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => 'Không thể xóa lịch sử lúc này.'], JSON_UNESCAPED_UNICODE);
}

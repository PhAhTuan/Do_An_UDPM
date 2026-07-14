<?php

declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    session_start();
}

header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');

require_once __DIR__ . '/../config.php';
require_once __DIR__ . '/../core/faq_helpers.php';

function chatHistoryJson(int $status, array $payload): void
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
        chatHistoryJson(405, [
            'success' => false,
            'message' => 'Phương thức không được hỗ trợ.',
        ]);
    }

    $role = (string)($_SESSION['role'] ?? '');
    if (empty($_SESSION['user_id'])) {
        chatHistoryJson(401, [
            'success' => false,
            'message' => 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.',
        ]);
    }

    if (!in_array($role, ['admin', 'staff'], true)) {
        chatHistoryJson(403, [
            'success' => false,
            'message' => 'Bạn không có quyền xem lịch sử trò chuyện.',
        ]);
    }

    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    $keyword = trim((string)($_GET['q'] ?? ''));
    $status = trim((string)($_GET['status'] ?? ''));
    $intent = trim((string)($_GET['intent'] ?? ''));
    $fromDate = trim((string)($_GET['from_date'] ?? ''));
    $toDate = trim((string)($_GET['to_date'] ?? ''));

    $page = max(1, (int)($_GET['page'] ?? 1));
    $limit = (int)($_GET['limit'] ?? 20);
    $limit = max(5, min(100, $limit));
    $offset = ($page - 1) * $limit;

    $allowedStatuses = ['active', 'closed', 'archived'];
    if ($status !== '' && !in_array($status, $allowedStatuses, true)) {
        chatHistoryJson(422, [
            'success' => false,
            'message' => 'Trạng thái phiên chat không hợp lệ.',
        ]);
    }

    $where = ["r.code = 'student'"];
    $params = [];

    if ($keyword !== '') {
        $where[] = "(
            u.username LIKE :keyword_username
            OR u.full_name LIKE :keyword_name
            OR sp.student_code LIKE :keyword_student
            OR cs.title LIKE :keyword_title
            OR cs.session_uuid LIKE :keyword_uuid
        )";
        $like = '%' . $keyword . '%';
        $params['keyword_username'] = $like;
        $params['keyword_name'] = $like;
        $params['keyword_student'] = $like;
        $params['keyword_title'] = $like;
        $params['keyword_uuid'] = $like;
    }

    if ($status !== '') {
        $where[] = 'cs.status = :session_status';
        $params['session_status'] = $status;
    }

    if ($fromDate !== '') {
        $from = DateTime::createFromFormat('Y-m-d', $fromDate);
        if (!$from || $from->format('Y-m-d') !== $fromDate) {
            chatHistoryJson(422, [
                'success' => false,
                'message' => 'Ngày bắt đầu không hợp lệ.',
            ]);
        }
        $where[] = 'cs.started_at >= :from_date';
        $params['from_date'] = $fromDate . ' 00:00:00';
    }

    if ($toDate !== '') {
        $to = DateTime::createFromFormat('Y-m-d', $toDate);
        if (!$to || $to->format('Y-m-d') !== $toDate) {
            chatHistoryJson(422, [
                'success' => false,
                'message' => 'Ngày kết thúc không hợp lệ.',
            ]);
        }
        $where[] = 'cs.started_at <= :to_date';
        $params['to_date'] = $toDate . ' 23:59:59';
    }

    if ($intent !== '') {
        if (mb_strlen($intent) > 120) {
            chatHistoryJson(422, [
                'success' => false,
                'message' => 'Intent tìm kiếm quá dài.',
            ]);
        }
        $where[] = "EXISTS (
            SELECT 1
            FROM chat_messages cm_intent
            WHERE cm_intent.session_id = cs.id
              AND cm_intent.detected_intent LIKE :intent
        )";
        $params['intent'] = '%' . $intent . '%';
    }

    $whereSql = implode("\n AND ", $where);

    $countSql = "
        SELECT COUNT(*)
        FROM chat_sessions cs
        INNER JOIN users u ON u.id = cs.user_id
        INNER JOIN roles r ON r.id = u.role_id
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        WHERE {$whereSql}
    ";

    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    $dataSql = "
        SELECT
            cs.id,
            cs.session_uuid,
            cs.title,
            cs.channel,
            cs.status,
            cs.language_code,
            cs.started_at,
            cs.last_activity_at,
            cs.closed_at,
            u.username,
            u.full_name,
            sp.student_code,
            (
                SELECT COUNT(*)
                FROM chat_messages cm_count
                WHERE cm_count.session_id = cs.id
            ) AS message_count,
            (
                SELECT COUNT(*)
                FROM chat_messages cm_user
                WHERE cm_user.session_id = cs.id
                  AND cm_user.sender_type = 'user'
            ) AS user_message_count,
            (
                SELECT COUNT(*)
                FROM chat_messages cm_assistant
                WHERE cm_assistant.session_id = cs.id
                  AND cm_assistant.sender_type = 'assistant'
            ) AS assistant_message_count,
            (
                SELECT cm_last.content
                FROM chat_messages cm_last
                WHERE cm_last.session_id = cs.id
                ORDER BY cm_last.created_at DESC, cm_last.id DESC
                LIMIT 1
            ) AS last_message,
            (
                SELECT cm_intent.detected_intent
                FROM chat_messages cm_intent
                WHERE cm_intent.session_id = cs.id
                  AND cm_intent.detected_intent IS NOT NULL
                  AND cm_intent.detected_intent <> ''
                ORDER BY cm_intent.created_at DESC, cm_intent.id DESC
                LIMIT 1
            ) AS last_intent,
            (
                SELECT COUNT(*)
                FROM chat_feedback cf
                INNER JOIN chat_messages cm_feedback
                    ON cm_feedback.id = cf.message_id
                WHERE cm_feedback.session_id = cs.id
            ) AS feedback_count
        FROM chat_sessions cs
        INNER JOIN users u ON u.id = cs.user_id
        INNER JOIN roles r ON r.id = u.role_id
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        WHERE {$whereSql}
        ORDER BY COALESCE(cs.last_activity_at, cs.started_at) DESC, cs.id DESC
        LIMIT :limit_rows OFFSET :offset_rows
    ";

    $dataStmt = $pdo->prepare($dataSql);
    foreach ($params as $name => $value) {
        $dataStmt->bindValue(':' . $name, $value, PDO::PARAM_STR);
    }
    $dataStmt->bindValue(':limit_rows', $limit, PDO::PARAM_INT);
    $dataStmt->bindValue(':offset_rows', $offset, PDO::PARAM_INT);
    $dataStmt->execute();

    $sessions = $dataStmt->fetchAll(PDO::FETCH_ASSOC);
    $totalPages = max(1, (int)ceil($total / $limit));

    chatHistoryJson(200, [
        'success' => true,
        'sessions' => $sessions,
        'pagination' => [
            'page' => $page,
            'limit' => $limit,
            'total' => $total,
            'totalPages' => $totalPages,
        ],
    ]);
} catch (Throwable $exception) {
    error_log('get_chat_sessions.php: ' . $exception->getMessage());
    chatHistoryJson(500, [
        'success' => false,
        'message' => 'Không thể tải danh sách lịch sử trò chuyện.',
    ]);
}

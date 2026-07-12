<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
if (!isset($_SESSION['role']) || !in_array($_SESSION['role'], ['admin', 'staff', 'knowledge_reviewer'], true)) {
    header('Location: login.php'); exit();
}
// Kết nối Database dùng config tập trung
include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
appEnsureRagViewShape($pdo);

function h($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function adminTicketLabel(string $status): string {
    return match ($status) {
        'open' => 'Mới',
        'in_progress' => 'Đang xử lý',
        'waiting_student' => 'Đã phản hồi',
        'resolved' => 'Đã xử lý',
        'closed' => 'Đã đóng',
        'cancelled' => 'Đã hủy',
        default => $status,
    };
}

function adminAnswerStatusLabel(?string $status): string {
    return match ($status) {
        'ok' => 'Ổn',
        'insufficient_context' => 'Thiếu dữ liệu',
        'clarification_needed' => 'Cần hỏi rõ',
        'blocked' => 'Bị chặn',
        'error' => 'Lỗi',
        default => $status ?: 'Chưa rõ',
    };
}

function adminSenderLabel(string $sender): string {
    return match ($sender) {
        'user' => 'Sinh viên',
        'assistant' => 'Bot',
        'system' => 'Hệ thống',
        'tool' => 'Công cụ',
        default => $sender,
    };
}

function adminStripUiIcons(string $value): string {
    $value = preg_replace('/[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}]/u', '', $value) ?? $value;
    return trim(preg_replace('/[ \t]{2,}/u', ' ', $value) ?? $value);
}

function adminPlainMessage(?string $value): string {
    $text = (string)$value;
    $text = str_ireplace(['<br>', '<br/>', '<br />'], "\n", $text);
    $text = str_replace(['TICKET_OFFER', 'TICKET_CONFIRM:', 'TICKET_TRIGGER:'], '', $text);
    $text = html_entity_decode(strip_tags($text), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $text = adminStripUiIcons($text);
    return trim(preg_replace("/\n{3,}/u", "\n\n", $text) ?? $text);
}

function adminSnippet(?string $value, int $limit = 120): string {
    $text = preg_replace('/\s+/u', ' ', adminPlainMessage($value)) ?? '';
    if (mb_strlen($text, 'UTF-8') <= $limit) {
        return $text;
    }
    return rtrim(mb_substr($text, 0, $limit - 1, 'UTF-8')).'...';
}

// XÁC ĐỊNH TAB ĐANG HOẠT ĐỘNG (Mặc định là dashboard nếu không có tham số)
$currentTab = $_GET['tab'] ?? 'dashboard';
// =========================================================================
// XỬ LÝ LỆNH TỪ GIAO DIỆN ADMIN
// =========================================================================
if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST' && isset($_POST['action'])) {
    $action = $_POST['action'];
    
    if ($action === 'add_source') {
        dbExecute($pdo, "
            INSERT INTO knowledge_sources (
                source_type, title, organization, document_number, source_url,
                issued_date, retrieved_at, is_official, status
            )
            VALUES (?, ?, ?, ?, ?, ?, NOW(), 1, 'active')
        ", [
            $_POST['source_type'] ?? 'official_web',
            trim($_POST['source_title'] ?? ''),
            trim($_POST['organization'] ?? 'UTH') ?: 'UTH',
            trim($_POST['document_number'] ?? '') ?: null,
            trim($_POST['source_url'] ?? '') ?: null,
            appDateOrNull($_POST['issued_date'] ?? null),
        ]);
        header("Location: admin_dashboard.php?tab=faq");
        exit;
    } 
    elseif ($action === 'save_knowledge' || $action === 'verify_knowledge') {
        $articleId = (int)($_POST['article_id'] ?? 0);
        $sourceId = (int)($_POST['source_id'] ?? 0);
        $validFrom = appDateOrNull($_POST['valid_from'] ?? null);
        $validUntil = appDateOrNull($_POST['valid_until'] ?? null);
        $status = $action === 'verify_knowledge' ? 'verified' : ($_POST['verification_status'] ?? 'pending');
        if (!in_array($status, ['draft', 'pending', 'verified', 'rejected', 'expired'], true)) {
            $status = 'pending';
        }

        dbExecute($pdo, "
            UPDATE knowledge_articles
            SET source_id = ?,
                title = ?,
                category = ?,
                intent_code = ?,
                keywords = ?,
                answer_content = ?,
                route_url = ?,
                valid_from = ?,
                valid_until = ?,
                verification_status = ?,
                confidence_level = CASE WHEN ? = 'verified' THEN 'authoritative' ELSE confidence_level END,
                reviewed_by = CASE WHEN ? = 'verified' THEN ? ELSE reviewed_by END,
                reviewed_at = CASE WHEN ? = 'verified' THEN NOW() ELSE reviewed_at END
            WHERE id = ?
        ", [
            $sourceId > 0 ? $sourceId : null,
            trim($_POST['title'] ?? ''),
            trim($_POST['category'] ?? 'Học vụ') ?: 'Học vụ',
            trim($_POST['intent_code'] ?? '') ?: null,
            trim($_POST['keywords'] ?? '') ?: null,
            trim($_POST['answer_content'] ?? ''),
            trim($_POST['route_url'] ?? '') ?: null,
            $validFrom ? $validFrom.' 00:00:00' : null,
            $validUntil ? $validUntil.' 23:59:59' : null,
            $status,
            $status,
            $status,
            (int)$_SESSION['user_id'],
            $status,
            $articleId,
        ]);

        dbExecute($pdo, "
            INSERT INTO knowledge_chunks (article_id, chunk_index, heading, chunk_text, token_count, content_hash)
            VALUES (?, 0, ?, ?, ?, SHA2(?, 256))
            ON DUPLICATE KEY UPDATE
                heading = VALUES(heading),
                chunk_text = VALUES(chunk_text),
                token_count = VALUES(token_count),
                content_hash = VALUES(content_hash),
                updated_at = NOW()
        ", [
            $articleId,
            trim($_POST['title'] ?? ''),
            trim($_POST['answer_content'] ?? ''),
            max(1, str_word_count(appNormalizeText($_POST['answer_content'] ?? ''))),
            trim($_POST['answer_content'] ?? ''),
        ]);

        header("Location: admin_dashboard.php?tab=faq");
        exit;
    }
    elseif ($action === 'add_knowledge') {
        $sourceId = (int)($_POST['source_id'] ?? 0);
        dbExecute($pdo, "
            INSERT INTO knowledge_articles (
                source_id, title, category, intent_code, keywords, answer_content, route_url,
                valid_from, valid_until, verification_status, confidence_level, priority,
                language_code, created_by
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', 'medium', 5, 'vi', ?)
        ", [
            $sourceId > 0 ? $sourceId : null,
            trim($_POST['title'] ?? ''),
            trim($_POST['category'] ?? 'Học vụ') ?: 'Học vụ',
            trim($_POST['intent_code'] ?? '') ?: null,
            trim($_POST['keywords'] ?? '') ?: null,
            trim($_POST['answer_content'] ?? ''),
            trim($_POST['route_url'] ?? '') ?: null,
            appDateOrNull($_POST['valid_from'] ?? null) ? appDateOrNull($_POST['valid_from'] ?? null).' 00:00:00' : null,
            appDateOrNull($_POST['valid_until'] ?? null) ? appDateOrNull($_POST['valid_until'] ?? null).' 23:59:59' : null,
            (int)$_SESSION['user_id'],
        ]);
        $articleId = (int)$pdo->lastInsertId();
        dbExecute($pdo, "
            INSERT INTO knowledge_chunks (article_id, chunk_index, heading, chunk_text, token_count, content_hash)
            VALUES (?, 0, ?, ?, ?, SHA2(?, 256))
        ", [
            $articleId,
            trim($_POST['title'] ?? ''),
            trim($_POST['answer_content'] ?? ''),
            max(1, str_word_count(appNormalizeText($_POST['answer_content'] ?? ''))),
            trim($_POST['answer_content'] ?? ''),
        ]);
        header("Location: admin_dashboard.php?tab=faq");
        exit;
    }
    elseif ($action === 'add_user') {
        $roleId = appRoleId($pdo, 'student');
        $programId = appFindOrCreateProgram(
            $pdo,
            $_POST['nganh'] ?? '',
            $_POST['chuyen_nganh'] ?? '',
            $_POST['bac_dao_tao'] ?? '',
            $_POST['loai_hinh_dao_tao'] ?? ''
        );

        dbExecute($pdo, "
            INSERT INTO users (username, password_hash, full_name, role_id, status, password_changed_at)
            VALUES (?, ?, ?, ?, 'active', NOW())
        ", [
            trim($_POST['mssv'] ?? ''),
            password_hash((string)($_POST['password'] ?? ''), PASSWORD_DEFAULT),
            trim($_POST['ho_ten'] ?? ''),
            $roleId,
        ]);

        $userId = (int)$pdo->lastInsertId();
        dbExecute($pdo, "
            INSERT INTO student_profiles (
                user_id, student_code, program_id, cohort_year, date_of_birth,
                gender, place_of_birth, academic_status
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, 'studying')
        ", [
            $userId,
            trim($_POST['mssv'] ?? ''),
            $programId,
            appExtractYear($_POST['khoa_hoc'] ?? ''),
            appDateOrNull($_POST['ngay_sinh'] ?? null),
            appGenderToDb($_POST['gioi_tinh'] ?? null),
            trim($_POST['noi_sinh'] ?? '') ?: null,
        ]);
        
        header("Location: admin_dashboard.php?tab=users");
        exit;
    }
    elseif ($action === 'edit_user') {
        $student = appStudentByCode($pdo, trim($_POST['mssv'] ?? ''));
        if ($student) {
            $programId = appFindOrCreateProgram(
                $pdo,
                $_POST['nganh'] ?? '',
                $_POST['chuyen_nganh'] ?? '',
                $_POST['bac_dao_tao'] ?? '',
                $_POST['loai_hinh_dao_tao'] ?? ''
            );
            dbExecute($pdo, "UPDATE users SET full_name = ? WHERE id = ?", [
                trim($_POST['ho_ten'] ?? ''),
                (int)$student['user_id'],
            ]);
            if (trim((string)($_POST['password'] ?? '')) !== '') {
                dbExecute($pdo, "UPDATE users SET password_hash = ?, password_changed_at = NOW() WHERE id = ?", [
                    password_hash((string)$_POST['password'], PASSWORD_DEFAULT),
                    (int)$student['user_id'],
                ]);
            }
            dbExecute($pdo, "
                UPDATE student_profiles
                SET program_id = ?,
                    cohort_year = ?,
                    date_of_birth = ?,
                    gender = ?,
                    place_of_birth = ?
                WHERE id = ?
            ", [
                $programId,
                appExtractYear($_POST['khoa_hoc'] ?? ''),
                appDateOrNull($_POST['ngay_sinh'] ?? null),
                appGenderToDb($_POST['gioi_tinh'] ?? null),
                trim($_POST['noi_sinh'] ?? '') ?: null,
                (int)$student['student_id'],
            ]);
        }
        header("Location: admin_dashboard.php?tab=users");
        exit;
    }
    elseif ($action === 'reply_ticket') {
        $ticket_id = (int)$_POST['ticket_id'];
        $reply_content = trim($_POST['admin_reply']);

        if (!empty($reply_content)) {
            dbExecute($pdo, "
                INSERT INTO ticket_messages (ticket_id, sender_user_id, sender_role, message)
                VALUES (?, ?, 'admin', ?)
            ", [$ticket_id, (int)$_SESSION['user_id'], $reply_content]);

            dbExecute($pdo, "UPDATE tickets SET status = 'waiting_student' WHERE id = ? AND status <> 'closed'", [$ticket_id]);
        }
        
        if (isset($_POST['close_ticket']) && $_POST['close_ticket'] == '1') {
            dbExecute($pdo, "UPDATE tickets SET status = 'closed', closed_at = NOW() WHERE id = ?", [$ticket_id]);
        }

        header("Location: admin_dashboard.php?tab=tickets");
        exit;
    }
    elseif ($action === 'close_ticket_only') {
        $ticket_id = (int)$_POST['ticket_id'];
        dbExecute($pdo, "UPDATE tickets SET status = 'closed', closed_at = NOW() WHERE id = ?", [$ticket_id]);
        header("Location: admin_dashboard.php?tab=tickets");
        exit;
    }
}

// =========================================================================
// LẤY DỮ LIỆU TỪ DATABASE ĐỂ HIỂN THỊ RA WEB
// =========================================================================
$totalTickets = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM tickets");
$pendingTickets = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM tickets WHERE status IN ('open', 'in_progress')");
$repliedTickets = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM tickets WHERE status IN ('waiting_student', 'resolved')");
$totalFaq = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM knowledge_articles WHERE verification_status = 'verified' AND deleted_at IS NULL");
$pendingKnowledgeCount = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM knowledge_articles WHERE verification_status = 'pending' AND deleted_at IS NULL");

// Filter ticket theo status
$ticketStatusFilter = $_GET['ticket_status'] ?? 'all';
$ticketSql = "
    SELECT
        id,
        ticket_number,
        requester_name AS student_name,
        requester_student_code AS mssv,
        subject AS title,
        description AS content,
        status,
        created_at,
        closed_at
    FROM tickets
";
$ticketParams = [];
if ($ticketStatusFilter !== 'all') {
    $ticketSql .= " WHERE status = ?";
    $ticketParams[] = $ticketStatusFilter;
}
$ticketSql .= " ORDER BY FIELD(status,'open','in_progress','waiting_student','resolved','closed','cancelled'), created_at DESC LIMIT 100";
$recentTickets = dbFetchAll($pdo, $ticketSql, $ticketParams);
$newTicketCount = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM tickets WHERE status = 'open'");

$knowledgeRows = dbFetchAll($pdo, "
    SELECT
        ka.id, ka.title, ka.category, ka.intent_code, ka.keywords, ka.answer_content,
        ka.route_url, ka.valid_from, ka.valid_until, ka.verification_status,
        ka.source_id, ks.title AS source_title, ks.source_url
    FROM knowledge_articles ka
    LEFT JOIN knowledge_sources ks ON ks.id = ka.source_id
    WHERE ka.deleted_at IS NULL
    ORDER BY FIELD(ka.verification_status, 'pending', 'draft', 'verified', 'rejected', 'expired'), ka.updated_at DESC
    LIMIT 60
");
$knowledgeSources = dbFetchAll($pdo, "
    SELECT id, title, source_type, source_url, document_number
    FROM knowledge_sources
    WHERE status = 'active'
    ORDER BY is_official DESC, updated_at DESC, title ASC
");
$students = appSafeStudentList($pdo);

$logSearch = trim((string)($_GET['log_q'] ?? ''));
$logIssueFilter = (string)($_GET['log_issue'] ?? 'all');
if (!in_array($logIssueFilter, ['all', 'needs_review', 'ok'], true)) {
    $logIssueFilter = 'all';
}

$totalChatSessions = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM chat_sessions");
$totalChatMessages = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM chat_messages");
$needsReviewMessages = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM chat_messages WHERE answer_status <> 'ok'");
$unansweredQuestions = (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM unanswered_questions WHERE status IN ('new', 'reviewing')");

$logWhere = ["1 = 1"];
$logParams = [];
if ($logSearch !== '') {
    $like = '%'.$logSearch.'%';
    $logWhere[] = "(
        cs.title LIKE ?
        OR u.full_name LIKE ?
        OR sp.student_code LIKE ?
        OR EXISTS (
            SELECT 1
            FROM chat_messages cm_search
            WHERE cm_search.session_id = cs.id
              AND cm_search.content LIKE ?
        )
    )";
    array_push($logParams, $like, $like, $like, $like);
}
if ($logIssueFilter === 'needs_review') {
    $logWhere[] = "EXISTS (
        SELECT 1
        FROM chat_messages cm_issue
        WHERE cm_issue.session_id = cs.id
          AND cm_issue.answer_status <> 'ok'
    )";
} elseif ($logIssueFilter === 'ok') {
    $logWhere[] = "NOT EXISTS (
        SELECT 1
        FROM chat_messages cm_issue
        WHERE cm_issue.session_id = cs.id
          AND cm_issue.answer_status <> 'ok'
    )";
}

$chatLogSessions = dbFetchAll($pdo, "
    SELECT
        cs.id,
        cs.session_uuid,
        cs.title,
        cs.status,
        cs.started_at,
        cs.last_activity_at,
        u.full_name,
        sp.student_code,
        COUNT(cm.id) AS message_count,
        SUM(CASE WHEN cm.sender_type = 'user' THEN 1 ELSE 0 END) AS user_message_count,
        SUM(CASE WHEN cm.sender_type = 'assistant' THEN 1 ELSE 0 END) AS bot_message_count,
        SUM(CASE WHEN cm.answer_status <> 'ok' THEN 1 ELSE 0 END) AS issue_count,
        MAX(cm.created_at) AS last_message_at,
        (
            SELECT cmu.content
            FROM chat_messages cmu
            WHERE cmu.session_id = cs.id AND cmu.sender_type = 'user'
            ORDER BY cmu.created_at DESC, cmu.id DESC
            LIMIT 1
        ) AS last_user_message,
        (
            SELECT cma.content
            FROM chat_messages cma
            WHERE cma.session_id = cs.id AND cma.sender_type = 'assistant'
            ORDER BY cma.created_at DESC, cma.id DESC
            LIMIT 1
        ) AS last_bot_message
    FROM chat_sessions cs
    LEFT JOIN users u ON u.id = cs.user_id
    LEFT JOIN student_profiles sp ON sp.user_id = u.id
    LEFT JOIN chat_messages cm ON cm.session_id = cs.id
    WHERE ".implode(' AND ', $logWhere)."
    GROUP BY cs.id, cs.session_uuid, cs.title, cs.status, cs.started_at, cs.last_activity_at, u.full_name, sp.student_code
    ORDER BY COALESCE(MAX(cm.created_at), cs.last_activity_at) DESC, cs.id DESC
    LIMIT 80
", $logParams);

$selectedLogSessionId = (int)($_GET['log_session'] ?? 0);
if ($selectedLogSessionId <= 0 && !empty($chatLogSessions)) {
    $selectedLogSessionId = (int)$chatLogSessions[0]['id'];
}

$selectedChatSession = null;
$selectedChatMessages = [];
$selectedRelatedTickets = [];
if ($selectedLogSessionId > 0) {
    $selectedChatSession = dbFetchOne($pdo, "
        SELECT
            cs.*,
            u.full_name,
            sp.student_code
        FROM chat_sessions cs
        LEFT JOIN users u ON u.id = cs.user_id
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        WHERE cs.id = ?
        LIMIT 1
    ", [$selectedLogSessionId]);

    if ($selectedChatSession) {
        $selectedChatMessages = dbFetchAll($pdo, "
            SELECT
                cm.*,
                DATE_FORMAT(cm.created_at, '%H:%i %d/%m/%Y') AS created_label,
                (
                    SELECT GROUP_CONCAT(CONCAT(cf.rating, IFNULL(CONCAT(':', cf.reason_code), '')) SEPARATOR ', ')
                    FROM chat_feedback cf
                    WHERE cf.message_id = cm.id
                ) AS feedback_summary
            FROM chat_messages cm
            WHERE cm.session_id = ?
            ORDER BY cm.created_at ASC, cm.id ASC
        ", [$selectedLogSessionId]);

        $selectedRelatedTickets = dbFetchAll($pdo, "
            SELECT id, ticket_number, status, created_at
            FROM tickets
            WHERE source_chat_session_id = ?
            ORDER BY created_at DESC
        ", [$selectedLogSessionId]);
    }
}
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UTH Admin Dashboard</title>
    <link rel="stylesheet" href="../css/admin.css">
    <style>.action-form{display:inline-block;margin:0}</style>
</head>
<body>

    <div class="sidebar">
        <div class="logo">UTH ADMIN</div>
        <div class="menu">
            <div class="menu-item <?php echo $currentTab === 'dashboard' ? 'active' : ''; ?>" onclick="switchTab('dashboard', this)">Tổng quan</div>
            <div class="menu-item <?php echo $currentTab === 'tickets' ? 'active' : ''; ?>" onclick="switchTab('tickets', this)">Hỗ trợ Tickets</div>
            <div class="menu-item <?php echo $currentTab === 'faq' ? 'active' : ''; ?>" onclick="switchTab('faq', this)">Kiểm duyệt tri thức</div>
            <div class="menu-item <?php echo $currentTab === 'users' ? 'active' : ''; ?>" onclick="switchTab('users', this)">Quản lý Sinh viên</div>
            <div class="menu-item <?php echo $currentTab === 'logs' ? 'active' : ''; ?>" onclick="switchTab('logs', this)">Lịch sử Chat</div>
            <a href="login.php" class="menu-item logout">Đăng xuất</a>
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <div class="search-bar"><input type="text" placeholder="Tìm kiếm..."></div>
            <div class="admin-profile-container" style="position: relative;">
                <div class="admin-profile" onclick="toggleAdminMenu()">
                    <span><?php echo htmlspecialchars($_SESSION['ho_ten'] ?? 'Admin', ENT_QUOTES, 'UTF-8'); ?></span>
                    <div class="avatar"><?php $n=trim($_SESSION['ho_ten']??'A'); echo htmlspecialchars(mb_strtoupper(mb_substr($n,mb_strpos($n,' ')!==false?mb_strrpos($n,' ')+1:0,1,'UTF-8'),'UTF-8'),ENT_QUOTES,'UTF-8'); ?></div>
                </div>
                <!-- Dropdown menu -->
                <div id="adminMenu" style="display: none; position: absolute; top: 110%; right: 0; background: #fff; border: 1px solid var(--border); border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); width: 180px; z-index: 1000; overflow: hidden;">
                    <a href="javascript:void(0)" onclick="openAdminProfileModal()" style="display: block; padding: 12px 16px; color: var(--text); text-decoration: none; font-size: 14px; border-bottom: 1px solid var(--border); transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">Trang cá nhân</a>
                    <a href="javascript:void(0)" onclick="openAdminSettingsModal()" style="display: block; padding: 12px 16px; color: var(--text); text-decoration: none; font-size: 14px; border-bottom: 1px solid var(--border); transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">Cài đặt</a>
                    <a href="login.php" style="display: block; padding: 12px 16px; color: #d32f2f; text-decoration: none; font-size: 14px; font-weight: 600; transition: background 0.2s;" onmouseover="this.style.background='#fee2e2'" onmouseout="this.style.background='transparent'">Đăng xuất</a>
                </div>
            </div>
        </div>

        <div id="tab-dashboard" class="tab-content <?php echo $currentTab === 'dashboard' ? 'active' : ''; ?>">
            <h2 class="page-title">Tổng quan hệ thống</h2>
            <div class="stats-grid">
                <div class="stat-card"><div class="stat-title">Tổng số Ticket</div><div class="stat-value"><?php echo $totalTickets; ?></div></div>
                <div class="stat-card danger"><div class="stat-title">Ticket chờ xử lý</div><div class="stat-value"><?php echo $pendingTickets; ?></div></div>
                <div class="stat-card success"><div class="stat-title">Ticket đã phản hồi</div><div class="stat-value"><?php echo $repliedTickets; ?></div></div>
                <div class="stat-card"><div class="stat-title">Tri thức đã verified</div><div class="stat-value"><?php echo $totalFaq; ?></div></div>
            </div>
            <div class="table-container">
                <h3 style="margin-bottom: 15px;">Ticket gần đây nhất</h3>
                <table>
                    <thead><tr><th>Mã</th><th>Sinh viên</th><th>Vấn đề</th><th>Trạng thái</th></tr></thead>
                    <tbody>
                        <?php foreach($recentTickets as $t): ?>
                        <tr>
                            <td>#<?php echo (int)$t['id']; ?></td>
                            <td><?php echo h($t['student_name']); ?></td>
                            <td><?php echo h($t['title']); ?></td>
                            <td><span class="badge <?php echo h($t['status']); ?>"><?php echo h(adminTicketLabel($t['status'])); ?></span></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="tab-tickets" class="tab-content <?php echo $currentTab === 'tickets' ? 'active' : ''; ?>">
            <div class="page-title">
                <span>Quản lý Phiếu hỗ trợ (Tickets)
                    <?php if ($newTicketCount > 0): ?>
                    <span class="badge open" style="font-size:12px; padding:3px 10px; vertical-align:middle;"><?php echo $newTicketCount; ?> mới</span>
                    <?php endif; ?>
                </span>
                <!-- Filter theo status -->
                <div style="display:flex; gap:8px; flex-wrap:wrap; align-items:center;">
                    <?php
                    $filterLabels = [
                        'all'            => 'Tất cả',
                        'open'           => 'Mới',
                        'in_progress'    => 'Đang xử lý',
                        'waiting_student'=> 'Đã phản hồi',
                        'resolved'       => 'Đã giải quyết',
                        'closed'         => 'Đã đóng',
                    ];
                    foreach ($filterLabels as $val => $label):
                        $active = $ticketStatusFilter === $val ? 'btn' : 'btn btn-outline';
                    ?>
                    <a href="admin_dashboard.php?tab=tickets&ticket_status=<?php echo $val; ?>" class="<?php echo $active; ?>" style="padding:5px 14px; font-size:13px; text-decoration:none;"><?php echo $label; ?></a>
                    <?php endforeach; ?>
                </div>
            </div>
            <div class="table-container">
                <table>
                    <thead><tr><th>Mã/Ngày</th><th>Sinh viên (MSSV)</th><th>Nội dung câu hỏi</th><th>Trạng thái</th><th>Hành động</th></tr></thead>
                    <tbody>
                        <?php if (empty($recentTickets)): ?>
                        <tr><td colspan="5" style="text-align:center; color:var(--text-muted); padding:30px;">Không có ticket nào.</td></tr>
                        <?php endif; ?>
                        <?php foreach($recentTickets as $t): ?>
                        <tr>
                            <td><b>#<?php echo (int)$t['id']; ?></b><br><span style="color:var(--text-muted); font-size:12px;"><?php echo date('d/m H:i', strtotime($t['created_at'])); ?></span></td>
                            <td><?php echo h($t['student_name']); ?><br><span style="color:var(--text-muted); font-size:12px;"><?php echo h($t['mssv']); ?></span></td>
                            <td style="max-width: 220px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><?php echo h($t['content']); ?></td>
                            <td><span class="badge <?php echo h($t['status']); ?>"><?php echo h(adminTicketLabel($t['status'])); ?></span></td>
                            <td style="white-space:nowrap;">
                                <button class="btn <?php echo in_array($t['status'], ['open', 'in_progress'], true) ? '' : 'btn-outline'; ?>"
                                        data-ticket-id="<?php echo (int)$t['id']; ?>"
                                        data-student-name="<?php echo h($t['student_name']); ?>"
                                        data-content="<?php echo h($t['content']); ?>"
                                        onclick="openReplyModalFromButton(this)">
                                    <?php echo in_array($t['status'], ['open', 'in_progress'], true) ? 'Trả lời' : 'Xem'; ?>
                                </button>
                                <?php if ($t['status'] !== 'closed'): ?>
                                 <form method="POST" action="admin_dashboard.php?tab=tickets" style="display:inline-block; margin:0;">
                                     <input type="hidden" name="action" value="close_ticket_only">
                                     <input type="hidden" name="ticket_id" value="<?php echo (int)$t['id']; ?>">
                                     <button type="submit" class="btn" style="background:#d32f2f; margin-left:4px; padding:5px 10px; font-size:12px;" onclick="return confirm('Đóng ticket này?')">Đóng</button>
                                 </form>
                                 <?php endif; ?>
                             </td>
                         </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="tab-faq" class="tab-content <?php echo $currentTab === 'faq' ? 'active' : ''; ?>">
            <div class="page-title">
                <span>Kiểm duyệt tri thức RAG</span>
                <span class="badge pending"><?php echo (int)$pendingKnowledgeCount; ?> pending</span>
            </div>

            <div class="table-container" style="margin-bottom: 18px;">
                <h3 style="margin-bottom: 15px;">Thêm nguồn chính thức</h3>
                <form method="POST" action="admin_dashboard.php?tab=faq" style="display:grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px;">
                    <input type="hidden" name="action" value="add_source">
                    <select name="source_type" class="faq-input" style="height:44px;">
                        <option value="official_web">Website chính thức</option>
                        <option value="regulation">Quy chế / văn bản</option>
                        <option value="announcement">Thông báo</option>
                        <option value="manual">Sổ tay / hướng dẫn</option>
                    </select>
                    <input type="text" name="source_title" class="faq-input" placeholder="Tên nguồn / văn bản" required>
                    <input type="text" name="organization" class="faq-input" value="UTH" placeholder="Đơn vị ban hành">
                    <input type="text" name="document_number" class="faq-input" placeholder="Số văn bản">
                    <input type="url" name="source_url" class="faq-input" placeholder="URL nguồn">
                    <input type="date" name="issued_date" class="faq-input">
                    <div style="grid-column: 1 / -1; text-align:right;">
                        <button class="btn" type="submit">Thêm nguồn</button>
                    </div>
                </form>
            </div>

            <div class="table-container" style="margin-bottom: 18px;">
                <h3 style="margin-bottom: 15px;">Thêm tri thức mới</h3>
                <form method="POST" action="admin_dashboard.php?tab=faq" style="display:grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">
                    <input type="hidden" name="action" value="add_knowledge">
                    <select name="source_id" class="faq-input" style="height:44px;">
                        <option value="">Chọn nguồn chính thức</option>
                        <?php foreach ($knowledgeSources as $src): ?>
                            <option value="<?php echo (int)$src['id']; ?>"><?php echo h($src['title']); ?></option>
                        <?php endforeach; ?>
                    </select>
                    <input type="text" name="title" class="faq-input" placeholder="Tiêu đề tri thức" required>
                    <input type="text" name="category" class="faq-input" placeholder="Nhóm, ví dụ: Học vụ" required>
                    <input type="text" name="intent_code" class="faq-input" placeholder="Intent, ví dụ: academic_policy">
                    <input type="text" name="keywords" class="faq-input" placeholder="Từ khóa tìm kiếm">
                    <input type="text" name="route_url" class="faq-input" placeholder="Link điều hướng">
                    <input type="date" name="valid_from" class="faq-input">
                    <input type="date" name="valid_until" class="faq-input">
                    <textarea name="answer_content" class="faq-input" style="grid-column: 1 / -1; height: 110px;" placeholder="Nội dung đã đối chiếu nguồn chính thức" required></textarea>
                    <div style="grid-column: 1 / -1; text-align:right;">
                        <button class="btn" type="submit">Thêm vào pending</button>
                    </div>
                </form>
            </div>

            <div class="table-container">
                <h3 style="margin-bottom: 15px;">Danh sách tri thức chờ kiểm duyệt / đã duyệt</h3>
                <table>
                    <thead><tr><th>ID</th><th>Trạng thái</th><th>Nội dung kiểm duyệt</th></tr></thead>
                    <tbody>
                        <?php foreach($knowledgeRows as $row): ?>
                        <tr>
                            <td><b>#<?php echo (int)$row['id']; ?></b></td>
                            <td>
                                <span class="badge <?php echo h($row['verification_status']); ?>"><?php echo h($row['verification_status']); ?></span><br>
                                <span style="color:var(--text-muted); font-size:12px;"><?php echo h($row['source_title'] ?: 'Chưa gắn nguồn'); ?></span>
                            </td>
                            <td>
                                <form method="POST" action="admin_dashboard.php?tab=faq">
                                    <input type="hidden" name="article_id" value="<?php echo (int)$row['id']; ?>">
                                    <div style="display:grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 10px;">
                                        <select name="source_id" class="faq-input" style="height:44px;">
                                            <option value="">Chưa chọn nguồn</option>
                                            <?php foreach ($knowledgeSources as $src): ?>
                                                <option value="<?php echo (int)$src['id']; ?>" <?php echo (int)$row['source_id'] === (int)$src['id'] ? 'selected' : ''; ?>>
                                                    <?php echo h($src['title']); ?>
                                                </option>
                                            <?php endforeach; ?>
                                        </select>
                                        <input type="text" name="title" class="faq-input" value="<?php echo h($row['title']); ?>" required>
                                        <input type="text" name="category" class="faq-input" value="<?php echo h($row['category']); ?>" required>
                                        <input type="text" name="intent_code" class="faq-input" value="<?php echo h($row['intent_code']); ?>" placeholder="intent_code">
                                        <input type="text" name="keywords" class="faq-input" value="<?php echo h($row['keywords']); ?>" placeholder="keywords">
                                        <input type="text" name="route_url" class="faq-input" value="<?php echo h($row['route_url']); ?>" placeholder="route_url">
                                        <input type="date" name="valid_from" class="faq-input" value="<?php echo h($row['valid_from'] ? substr($row['valid_from'], 0, 10) : ''); ?>">
                                        <input type="date" name="valid_until" class="faq-input" value="<?php echo h($row['valid_until'] ? substr($row['valid_until'], 0, 10) : ''); ?>">
                                        <select name="verification_status" class="faq-input" style="height:44px;">
                                            <?php foreach (['draft', 'pending', 'verified', 'rejected', 'expired'] as $status): ?>
                                                <option value="<?php echo h($status); ?>" <?php echo $row['verification_status'] === $status ? 'selected' : ''; ?>><?php echo h($status); ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                        <textarea name="answer_content" class="faq-input" style="grid-column: 1 / -1; height: 120px;" required><?php echo h($row['answer_content']); ?></textarea>
                                    </div>
                                    <div style="text-align:right; margin-top:10px;">
                                        <button class="btn btn-outline" type="submit" name="action" value="save_knowledge">Lưu sửa</button>
                                        <button class="btn" type="submit" name="action" value="verify_knowledge">Duyệt verified</button>
                                    </div>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

       <div id="tab-users" class="tab-content <?php echo $currentTab === 'users' ? 'active' : ''; ?>">
            <div class="page-title">
                <span>Danh sách Tài khoản Sinh viên</span>
                <button class="btn" onclick="document.getElementById('addUserModal').classList.add('active')">+ Cấp tài khoản mới</button>
            </div>
            
            <div class="table-container">
                <table> 
                    <thead>
                        <tr>
                            <th>MSSV (Tài khoản)</th>
                            <th>Họ và tên</th>
                            <th>Ngành / Khóa</th>
                            <th>Trạng thái</th>
                            <th style="text-align: center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach($students as $sv): ?>
                        <tr>
                            <td><b><?php echo h($sv['mssv'] ?: $sv['username']); ?></b></td>
                            <td><?php echo h($sv['ho_ten']); ?></td>
                            <td><?php echo h($sv['nganh']); ?> - <?php echo h($sv['khoa_hoc']); ?></td>
                            <td><span class="badge success"><?php echo h($sv['status'] ?? 'active'); ?></span></td>
                            
                            <td style="text-align: center;">
                                <button class="btn btn-outline" style="margin-right: 5px; padding: 6px 10px;" 
                                        data-info="<?php echo h(json_encode($sv, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)); ?>" 
                                        onclick="viewStudentDetail(this)"> Chi tiết</button>
                                
                                <button class="btn" style="background: #ff9800; color: white; padding: 6px 10px;" 
                                        data-info="<?php echo h(json_encode($sv, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)); ?>" 
                                        onclick="openEditUserModal(this)"> Sửa</button>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="tab-logs" class="tab-content <?php echo $currentTab === 'logs' ? 'active' : ''; ?>">
            <div class="page-title"><span>Lịch sử trò chuyện Sinh viên - Bot</span></div>

            <div class="stats-grid log-stats">
                <div class="stat-card"><div class="stat-title">Phiên chat</div><div class="stat-value"><?php echo $totalChatSessions; ?></div></div>
                <div class="stat-card"><div class="stat-title">Tin nhắn đã lưu</div><div class="stat-value"><?php echo $totalChatMessages; ?></div></div>
                <div class="stat-card danger"><div class="stat-title">Cần xem lại</div><div class="stat-value"><?php echo $needsReviewMessages; ?></div></div>
                <div class="stat-card success"><div class="stat-title">Câu chưa có dữ liệu</div><div class="stat-value"><?php echo $unansweredQuestions; ?></div></div>
            </div>

            <div class="table-container log-filter-panel">
                <form method="GET" action="admin_dashboard.php" class="log-filter-form">
                    <input type="hidden" name="tab" value="logs">
                    <input class="faq-input" type="text" name="log_q" value="<?php echo h($logSearch); ?>" placeholder="Tìm theo tên, MSSV hoặc nội dung chat">
                    <select class="faq-input" name="log_issue">
                        <option value="all" <?php echo $logIssueFilter === 'all' ? 'selected' : ''; ?>>Tất cả trạng thái</option>
                        <option value="needs_review" <?php echo $logIssueFilter === 'needs_review' ? 'selected' : ''; ?>>Có câu cần xem lại</option>
                        <option value="ok" <?php echo $logIssueFilter === 'ok' ? 'selected' : ''; ?>>Chỉ phiên ổn</option>
                    </select>
                    <button class="btn" type="submit">Lọc</button>
                    <a class="btn btn-outline" href="admin_dashboard.php?tab=logs">Xóa lọc</a>
                </form>
            </div>

            <div class="log-layout">
                <div class="table-container log-session-panel">
                    <h3>Phiên gần đây</h3>
                    <div class="log-session-list">
                        <?php if (empty($chatLogSessions)): ?>
                            <div class="log-empty">Chưa có phiên chat phù hợp.</div>
                        <?php endif; ?>
                        <?php foreach ($chatLogSessions as $session): ?>
                            <?php
                                $sessionUrl = 'admin_dashboard.php?'.http_build_query([
                                    'tab' => 'logs',
                                    'log_session' => (int)$session['id'],
                                    'log_q' => $logSearch,
                                    'log_issue' => $logIssueFilter,
                                ]);
                                $lastAt = $session['last_message_at'] ?: $session['last_activity_at'];
                                $studentName = trim((string)($session['full_name'] ?? '')) ?: 'Khách truy cập';
                                $studentCode = trim((string)($session['student_code'] ?? '')) ?: 'Chưa gắn MSSV';
                                $preview = adminSnippet($session['last_user_message'] ?: $session['title'], 110);
                            ?>
                            <a class="log-session-item <?php echo (int)$session['id'] === $selectedLogSessionId ? 'active' : ''; ?>" href="<?php echo h($sessionUrl); ?>">
                                <div class="log-session-top">
                                    <b><?php echo h($studentName); ?></b>
                                    <span><?php echo $lastAt ? h(date('d/m H:i', strtotime($lastAt))) : ''; ?></span>
                                </div>
                                <div class="log-session-meta">
                                    <?php echo h($studentCode); ?> · <?php echo (int)$session['message_count']; ?> tin nhắn
                                </div>
                                <div class="log-session-preview"><?php echo h($preview ?: 'Chưa có câu hỏi.'); ?></div>
                                <?php if ((int)$session['issue_count'] > 0): ?>
                                    <span class="badge insufficient_context"><?php echo (int)$session['issue_count']; ?> cần xem lại</span>
                                <?php endif; ?>
                            </a>
                        <?php endforeach; ?>
                    </div>
                </div>

                <div class="table-container log-transcript-panel">
                    <?php if (!$selectedChatSession): ?>
                        <h3>Nội dung cuộc trò chuyện</h3>
                        <div class="log-empty">Chọn một phiên chat để xem chi tiết.</div>
                    <?php else: ?>
                        <?php
                            $selectedName = trim((string)($selectedChatSession['full_name'] ?? '')) ?: 'Khách truy cập';
                            $selectedCode = trim((string)($selectedChatSession['student_code'] ?? '')) ?: 'Chưa gắn MSSV';
                        ?>
                        <div class="log-transcript-head">
                            <div>
                                <h3><?php echo h($selectedName); ?></h3>
                                <p><?php echo h($selectedCode); ?> · Bắt đầu <?php echo h(date('d/m/Y H:i', strtotime($selectedChatSession['started_at']))); ?></p>
                            </div>
                            <span class="badge <?php echo h($selectedChatSession['status']); ?>"><?php echo h($selectedChatSession['status']); ?></span>
                        </div>

                        <?php if (!empty($selectedRelatedTickets)): ?>
                            <div class="related-ticket-row">
                                <span>Ticket liên quan:</span>
                                <?php foreach ($selectedRelatedTickets as $ticket): ?>
                                    <a href="admin_dashboard.php?tab=tickets" class="badge <?php echo h($ticket['status']); ?>">
                                        <?php echo h($ticket['ticket_number']); ?> · <?php echo h(adminTicketLabel($ticket['status'])); ?>
                                    </a>
                                <?php endforeach; ?>
                            </div>
                        <?php endif; ?>

                        <div class="log-thread">
                            <?php if (empty($selectedChatMessages)): ?>
                                <div class="log-empty">Phiên này chưa có tin nhắn.</div>
                            <?php endif; ?>
                            <?php foreach ($selectedChatMessages as $msg): ?>
                                <?php
                                    $plainContent = adminPlainMessage($msg['content'] ?? '');
                                    $metaParts = [];
                                    if (!empty($msg['detected_intent'])) $metaParts[] = 'Intent: '.$msg['detected_intent'];
                                    if (!empty($msg['model_name'])) $metaParts[] = 'Model: '.$msg['model_name'];
                                    if ($msg['latency_ms'] !== null) $metaParts[] = 'Latency: '.(int)$msg['latency_ms'].'ms';
                                    if ($msg['confidence_score'] !== null) $metaParts[] = 'Tin cậy: '.number_format((float)$msg['confidence_score'], 2);
                                    if (!empty($msg['feedback_summary'])) $metaParts[] = 'Feedback: '.$msg['feedback_summary'];
                                ?>
                                <div class="log-message <?php echo h($msg['sender_type']); ?>">
                                    <div class="log-message-meta">
                                        <b><?php echo h(adminSenderLabel($msg['sender_type'])); ?></b>
                                        <span><?php echo h($msg['created_label']); ?></span>
                                        <?php if ($msg['sender_type'] === 'assistant'): ?>
                                            <span class="badge <?php echo h($msg['answer_status']); ?>"><?php echo h(adminAnswerStatusLabel($msg['answer_status'])); ?></span>
                                        <?php endif; ?>
                                    </div>
                                    <div class="log-message-content"><?php echo nl2br(h($plainContent !== '' ? $plainContent : '(Nội dung trống)')); ?></div>
                                    <?php if (!empty($metaParts)): ?>
                                        <div class="log-message-foot"><?php echo h(implode(' · ', $metaParts)); ?></div>
                                    <?php endif; ?>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
    

<div class="modal-overlay" id="addUserModal">
    <div class="modal-box" style="width: 750px; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
            <h3 style="margin-bottom: 20px;">Cấp tài khoản mới</h3>
            <div class="modal-close-btn" onclick="closeModal('addUserModal')">Đóng</div>
        </div>
        <form method="POST" action="admin_dashboard.php">
            <input type="hidden" name="action" value="add_user">
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0 20px;">
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">MSSV (Dùng để đăng nhập) *</label>
                    <input type="text" name="mssv" class="faq-input" required>
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Mật khẩu ban đầu *</label>
                    <input type="text" name="password" class="faq-input" value="123456" required>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Họ và tên *</label>
                    <input type="text" name="ho_ten" class="faq-input" required>
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngày sinh</label>
                    <input type="date" name="ngay_sinh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Giới tính</label>
                    <select name="gioi_tinh" class="faq-input" style="height: 44px;">
                        <option value="Nam">Nam</option>
                        <option value="Nữ">Nữ</option>
                    </select>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Nơi sinh</label>
                    <input type="text" name="noi_sinh" class="faq-input" placeholder="VD: TP. Hồ Chí Minh">
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngành học</label>
                    <input type="text" name="nganh" class="faq-input" placeholder="VD: Công nghệ thông tin">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Chuyên ngành</label>
                    <input type="text" name="chuyen_nganh" class="faq-input" placeholder="VD: Kỹ thuật phần mềm">
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Khóa học</label>
                    <input type="text" name="khoa_hoc" class="faq-input" placeholder="VD: Khóa 2021">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Bậc đào tạo</label>
                    <select name="bac_dao_tao" class="faq-input" style="height: 44px;">
                        <option value="Đại học">Đại học</option>
                        <option value="Cao đẳng">Cao đẳng</option>
                        <option value="Thạc sĩ">Thạc sĩ</option>
                    </select>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Loại hình đào tạo</label>
                    <select name="loai_hinh_dao_tao" class="faq-input" style="height: 44px;">
                        <option value="Chính quy">Chính quy</option>
                        <option value="Vừa làm vừa học">Vừa làm vừa học</option>
                        <option value="Đào tạo từ xa">Đào tạo từ xa</option>
                    </select>
                </div>
            </div>
            
            <div style="text-align: right; margin-top: 10px; border-top: 1px solid #2c3138; padding-top: 15px;">
                <button type="button" class="btn btn-outline" style="margin-right: 10px;" onclick="closeModal('addUserModal')">Hủy bỏ</button>
                <button type="submit" class="btn">Tạo tài khoản</button>
            </div>
        </form>
    </div>
</div>
<style>
/* ===== ADMIN REPLY TICKET MODAL - REDESIGN ===== */
.rtm-overlay {
    display: none;
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.6);
    backdrop-filter: blur(4px);
    z-index: 2000;
    align-items: center;
    justify-content: center;
    animation: rtmFadeIn .2s ease;
}
.rtm-overlay.active { display: flex; }
@keyframes rtmFadeIn { from { opacity:0 } to { opacity:1 } }

.rtm-box {
    background: #fff;
    border-radius: 16px;
    width: 96%;
    max-width: 660px;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0,0,0,0.25);
    animation: rtmSlideUp .25s cubic-bezier(.34,1.56,.64,1);
}
@keyframes rtmSlideUp {
    from { transform: translateY(24px) scale(.97); opacity:0 }
    to   { transform: translateY(0)   scale(1);   opacity:1 }
}

/* Header */
.rtm-header {
    background: linear-gradient(135deg, #007976 0%, #00b5ad 100%);
    padding: 18px 22px;
    display: flex;
    align-items: center;
    gap: 14px;
    flex-shrink: 0;
    position: relative;
}
.rtm-header-info { flex: 1; min-width: 0; }
.rtm-header-title {
    color: #fff;
    font-size: 16px;
    font-weight: 700;
    margin: 0 0 2px;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.rtm-header-meta {
    color: rgba(255,255,255,0.8);
    font-size: 12px;
    margin: 0;
}
.rtm-close {
    height: 34px;
    padding: 0 12px;
    background: rgba(255,255,255,0.18);
    border: 1.5px solid rgba(255,255,255,0.3);
    border-radius: 8px;
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    line-height: 1;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    transition: background .18s;
    flex-shrink: 0;
}
.rtm-close:hover {
    background: rgba(255,255,255,0.32);
}

/* Thread */
.rtm-thread {
    flex: 1;
    overflow-y: auto;
    padding: 20px 22px;
    background: #f6f8fb;
    display: flex;
    flex-direction: column;
    gap: 12px;
    min-height: 200px;
    max-height: 340px;
}
.rtm-thread::-webkit-scrollbar { width: 5px; }
.rtm-thread::-webkit-scrollbar-track { background: transparent; }
.rtm-thread::-webkit-scrollbar-thumb { background: #ccc; border-radius: 4px; }

.rtm-bubble {
    max-width: 75%;
    padding: 10px 14px;
    border-radius: 12px;
    font-size: 14px;
    line-height: 1.55;
    position: relative;
    word-break: break-word;
}
.rtm-bubble-label {
    font-size: 10.5px;
    font-weight: 700;
    margin-bottom: 4px;
    opacity: .7;
    text-transform: uppercase;
    letter-spacing: .4px;
}
.rtm-bubble-time {
    font-size: 10.5px;
    margin-top: 5px;
    opacity: .5;
    text-align: right;
}
/* SV bubble – trái */
.rtm-bubble.sv {
    background: #fff;
    border: 1px solid #e8ecf0;
    border-bottom-left-radius: 4px;
    align-self: flex-start;
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
    color: #1e2329;
}
.rtm-bubble.sv .rtm-bubble-label { color: #007976; }
/* Admin bubble – phải */
.rtm-bubble.admin {
    background: linear-gradient(135deg, #007976, #009e96);
    color: #fff;
    border-bottom-right-radius: 4px;
    align-self: flex-end;
    box-shadow: 0 2px 8px rgba(0,121,118,.25);
}
.rtm-bubble.admin .rtm-bubble-label { color: rgba(255,255,255,.75); }
.rtm-bubble.admin .rtm-bubble-time { color: rgba(255,255,255,.6); }
/* Banner câu hỏi gốc */
.rtm-origin-banner {
    background: linear-gradient(135deg, #fffbeb, #fff8e1);
    border: 1px solid #fdd835;
    border-left: 4px solid #f9a825;
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 13px;
    color: #5d4037;
}
.rtm-loading-msg {
    text-align: center;
    padding: 30px;
    color: #aaa;
    font-size: 14px;
}

/* Footer */
.rtm-footer {
    padding: 16px 22px;
    background: #fff;
    border-top: 1px solid #edf0f4;
    flex-shrink: 0;
}
.rtm-textarea {
    width: 100%;
    min-height: 80px;
    max-height: 160px;
    border: 1.5px solid #dce0e8;
    border-radius: 10px;
    padding: 12px 14px;
    font-size: 14px;
    font-family: inherit;
    resize: vertical;
    transition: border-color .2s, box-shadow .2s;
    color: #1e2329;
    background: #fafbfc;
    box-sizing: border-box;
}
.rtm-textarea:focus {
    outline: none;
    border-color: #007976;
    box-shadow: 0 0 0 3px rgba(0,121,118,.12);
    background: #fff;
}
.rtm-footer-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 12px;
    gap: 10px;
}
.rtm-close-check-label {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 13px;
    color: #d32f2f;
    cursor: pointer;
    user-select: none;
}
.rtm-close-check-label input[type=checkbox] {
    width: 16px; height: 16px;
    accent-color: #d32f2f;
    cursor: pointer;
}
.rtm-send-btn {
    display: flex; align-items: center; gap: 7px;
    background: linear-gradient(135deg, #007976, #009e96);
    color: #fff;
    border: none;
    padding: 10px 22px;
    border-radius: 10px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: transform .15s, box-shadow .15s;
    box-shadow: 0 2px 8px rgba(0,121,118,.3);
    white-space: nowrap;
}
.rtm-send-btn:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 14px rgba(0,121,118,.4);
}
.rtm-closed-notice {
    display: none;
    text-align: center;
    padding: 14px 20px;
    background: #fff3f3;
    border: 1px solid #ffcdd2;
    border-radius: 8px;
    color: #c62828;
    font-size: 13px;
    font-weight: 500;
}
</style>

<div class="rtm-overlay" id="replyTicketModal">
    <div class="rtm-box">
        <!-- Header -->
        <div class="rtm-header">
            <div class="rtm-header-info">
                <p class="rtm-header-title" id="reply_ticket_id_title">Ticket hỗ trợ</p>
                <p class="rtm-header-meta">Lịch sử trao đổi với: <b id="reply_student_name" style="color:#fff;"></b></p>
            </div>
            <button class="rtm-close" onclick="closeModal('replyTicketModal')" title="Đóng">Đóng</button>
        </div>

        <!-- Thread -->
        <div class="rtm-thread" id="chatHistoryBox">
            <div class="rtm-loading-msg">Đang tải...</div>
        </div>

        <!-- Footer -->
        <div class="rtm-footer">
            <form method="POST" action="admin_dashboard.php" id="replyForm">
                <input type="hidden" name="action" value="reply_ticket">
                <input type="hidden" name="ticket_id" id="reply_ticket_id">

                <div id="replyArea">
                    <textarea name="admin_reply" class="rtm-textarea" placeholder="Nhập phản hồi của bạn cho sinh viên..." required></textarea>
                    <div class="rtm-footer-actions">
                        <label class="rtm-close-check-label">
                            <input type="checkbox" name="close_ticket" value="1">
                            <span>Đóng ticket sau khi gửi</span>
                        </label>
                        <button type="submit" class="rtm-send-btn">Gửi phản hồi</button>
                    </div>
                </div>

                <div id="closedNotice" class="rtm-closed-notice">
                    Ticket này đã được đóng. Không thể gửi thêm phản hồi.
                </div>
            </form>
        </div>
    </div>
</div>

    <script>
        function switchTab(tabId, element) {
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
            document.getElementById('tab-' + tabId).classList.add('active');
            element.classList.add('active');
            
            // Đẩy trạng thái tab lên thanh URL để tránh mất vị trí khi refresh thủ công
            const url = new URL(window.location);
            url.searchParams.set('tab', tabId);
            window.history.pushState({}, '', url);
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
        }

        // Hàm mở khung Chat Ticket & Kéo dữ liệu từ API
    function openReplyModalFromButton(button) {
        openReplyModal(
            parseInt(button.getAttribute('data-ticket-id'), 10),
            button.getAttribute('data-student-name') || '',
            button.getAttribute('data-content') || ''
        );
    }

    function openReplyModal(ticket_id, student_name, original_content) {
        document.getElementById('reply_ticket_id_title').innerText = 'Ticket #' + ticket_id;
        document.getElementById('reply_ticket_id').value = ticket_id;
        document.getElementById('reply_student_name').innerText = student_name;
        let chatBox = document.getElementById('chatHistoryBox');
        chatBox.innerHTML = '<div class="rtm-loading-msg">Đang tải lịch sử trao đổi...</div>';
        document.getElementById('replyTicketModal').classList.add('active');
        fetch('../api/get_ticket_chat.php?id=' + ticket_id)
        .then(res => res.json())
        .then(data => {
            chatBox.innerHTML = '';
            if (original_content) {
                let banner = document.createElement('div');
                banner.className = 'rtm-origin-banner';
                banner.innerHTML = '<div><b style="display:block;margin-bottom:3px;color:#5d4037;">Câu hỏi ban đầu</b>' + escapeAdminHtml(original_content) + '</div>';
                chatBox.appendChild(banner);
            }
            if(data.success && data.messages && data.messages.length > 0) {
                data.messages.forEach(msg => {
                    let isAdmin = msg.sender_role === 'admin';
                    let bubble = document.createElement('div');
                    bubble.className = 'rtm-bubble ' + (isAdmin ? 'admin' : 'sv');
                    let msgText = escapeAdminHtml(msg.message).replace(/\r?\n/g, '<br>');
                    bubble.innerHTML =
                        '<div class="rtm-bubble-label">' + (isAdmin ? 'Admin UTH' : escapeAdminHtml(student_name)) + '</div>' +
                        '<div>' + msgText + '</div>' +
                        '<div class="rtm-bubble-time">' + escapeAdminHtml(msg.time_str || '') + '</div>';
                    chatBox.appendChild(bubble);
                });
            } else if (!original_content) {
                chatBox.innerHTML = '<div class="rtm-loading-msg">Chưa có tin nhắn nào.</div>';
            }
            chatBox.scrollTop = chatBox.scrollHeight;
            let replyArea = document.getElementById('replyArea');
            let closedNotice = document.getElementById('closedNotice');
            if(data.is_closed == 1) {
                replyArea.style.display = 'none';
                closedNotice.style.display = 'block';
            } else {
                replyArea.style.display = 'block';
                closedNotice.style.display = 'none';
            }
        })
        .catch(err => {
            chatBox.innerHTML = '<div class="rtm-loading-msg" style="color:#e53935;">Lỗi tải tin nhắn.</div>';
        });
    }
    function escapeAdminHtml(str) {
        return String(str || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
    }
    </script>

    <div class="modal-overlay" id="studentDetailModal">
        <div class="modal-box">
            <div class="modal-close-btn" onclick="closeModal('studentDetailModal')">Đóng</div>
            <h3 style="margin-bottom: 20px; color: var(--blue);">Thông tin chi tiết</h3>
        
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 15px;">
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">MSSV</div><div id="dt_mssv" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Họ và tên</div><div id="dt_hoten" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Ngày sinh</div><div id="dt_ngaysinh" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Nơi sinh</div><div id="dt_noisinh" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Giới tính</div><div id="dt_gioitinh" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Khóa học</div><div id="dt_khoahoc" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Bậc đào tạo</div><div id="dt_bacdaotao" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item"><div class="info-label" style="color: gray; font-size: 13px;">Loại hình</div><div id="dt_loaihinh" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item" style="grid-column: span 2;"><div class="info-label" style="color: gray; font-size: 13px;">Ngành học</div><div id="dt_nganh" style="font-weight: bold; font-size: 15px;"></div></div>
            <div class="info-item" style="grid-column: span 2;"><div class="info-label" style="color: gray; font-size: 13px;">Chuyên ngành</div><div id="dt_chuyennganh" style="font-weight: bold; font-size: 15px;"></div></div>
        </div>
        
        <div style="text-align: center; margin-top: 25px;">
            <button class="btn" onclick="closeModal('studentDetailModal')">Đóng cửa sổ</button>
        </div>
    </div>
<!-- Admin Profile Modal -->
<div id="adminProfileModal" class="modal-overlay">
  <div class="modal-box" style="max-width: 400px; text-align: center;">
    <div class="modal-close-btn" onclick="closeAdminProfileModal()">Đóng</div>
    <div class="avatar" style="width: 80px; height: 80px; font-size: 32px; margin: 0 auto 20px;">
       <?php $n=trim($_SESSION['ho_ten']??'A'); echo htmlspecialchars(mb_strtoupper(mb_substr($n,mb_strpos($n,' ')!==false?mb_strrpos($n,' ')+1:0,1,'UTF-8'),'UTF-8'),ENT_QUOTES,'UTF-8'); ?>
    </div>
    <h3 style="margin-bottom: 5px; font-size: 20px; color: var(--text);"><?php echo htmlspecialchars($_SESSION['ho_ten'] ?? 'Admin', ENT_QUOTES, 'UTF-8'); ?></h3>
    <p style="color: var(--muted); margin-bottom: 20px;">Vai trò: Quản trị viên hệ thống (Admin)</p>
    <div style="background: var(--bg); padding: 15px; border-radius: 8px; text-align: left;">
      <p style="margin-bottom: 8px; font-size: 14px;"><b>Tài khoản:</b> admin</p>
      <p style="margin-bottom: 8px; font-size: 14px;"><b>Email:</b> admin@ut.edu.vn</p>
      <p style="margin-bottom: 0; font-size: 14px;"><b>Trạng thái:</b> <span class="badge success" style="float: right;">Đang hoạt động</span></p>
    </div>
  </div>
</div>

<!-- Admin Settings Modal -->
<div id="adminSettingsModal" class="modal-overlay">
  <div class="modal-box" style="max-width: 450px;">
    <div class="modal-close-btn" onclick="closeAdminSettingsModal()">Đóng</div>
    <h3 style="margin-bottom: 20px; font-size: 18px; color: var(--text); border-bottom: 1px solid var(--border); padding-bottom: 15px;">Cài đặt hệ thống</h3>
    <div style="margin-bottom: 15px;">
      <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 15px;">
        <input type="checkbox" checked style="width: 18px; height: 18px;"> Bật thông báo qua Email khi có Ticket
      </label>
    </div>
    <div style="margin-bottom: 15px;">
      <label style="display: flex; align-items: center; gap: 10px; cursor: pointer; font-size: 15px;">
        <input type="checkbox" checked style="width: 18px; height: 18px;"> Tự động duyệt câu hỏi FAQ mới
      </label>
    </div>
    <div style="margin-bottom: 25px;">
      <label style="display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px;">Giao diện hiển thị (Sắp ra mắt)</label>
      <select style="width: 100%; padding: 12px; border-radius: 8px; border: 1px solid var(--border); font-family: inherit; font-size: 14px;" disabled>
        <option>Chế độ Sáng (Light mode - Mặc định)</option>
        <option>Chế độ Tối (Dark mode)</option>
      </select>
    </div>
    <button class="btn" style="width: 100%;" onclick="closeAdminSettingsModal(); alert('Đã lưu các thay đổi cài đặt thành công!');">Lưu cấu hình</button>
  </div>
</div>

<script>
    function openAdminProfileModal() { document.getElementById('adminProfileModal').classList.add('active'); document.getElementById('adminMenu').style.display='none'; }
    function closeAdminProfileModal() { document.getElementById('adminProfileModal').classList.remove('active'); }
    function openAdminSettingsModal() { document.getElementById('adminSettingsModal').classList.add('active'); document.getElementById('adminMenu').style.display='none'; }
    function closeAdminSettingsModal() { document.getElementById('adminSettingsModal').classList.remove('active'); }

    // Xử lý Dropdown menu Admin
    function toggleAdminMenu() {
        const menu = document.getElementById('adminMenu');
        menu.style.display = menu.style.display === 'block' ? 'none' : 'block';
    }

    // Đóng dropdown khi click ra ngoài
    document.addEventListener('click', function(e) {
        const container = document.querySelector('.admin-profile-container');
        if (container && !container.contains(e.target)) {
            document.getElementById('adminMenu').style.display = 'none';
        }
    });

    // Hàm bóc tách dữ liệu JSON và đổ lên Modal
    function viewStudentDetail(button) {
        // Lấy dữ liệu từ thuộc tính data-info
        let student = JSON.parse(button.getAttribute('data-info'));
        
        // Gắn vào các the div
        document.getElementById('dt_mssv').innerText = student.mssv || student.username || '---';
        document.getElementById('dt_hoten').innerText = student.ho_ten || '---';
        document.getElementById('dt_ngaysinh').innerText = student.ngay_sinh ? student.ngay_sinh : '---';
        document.getElementById('dt_noisinh').innerText = student.noi_sinh || '---';
        document.getElementById('dt_gioitinh').innerText = student.gioi_tinh || '---';
        document.getElementById('dt_khoahoc').innerText = student.khoa_hoc || '---';
        document.getElementById('dt_bacdaotao').innerText = student.bac_dao_tao || '---';
        document.getElementById('dt_loaihinh').innerText = student.loai_hinh_dao_tao || '---';
        document.getElementById('dt_nganh').innerText = student.nganh || '---';
        document.getElementById('dt_chuyennganh').innerText = student.chuyen_nganh || '---';
        
        // Mở popup
        document.getElementById('studentDetailModal').classList.add('active');
    }
</script>

<div class="modal-overlay" id="editUserModal">
    <div class="modal-box" style="width: 750px; max-height: 90vh; overflow-y: auto;">
        <h3 style="margin-bottom: 20px;">Chỉnh sửa thông tin Sinh viên</h3>
        <div class="modal-close-btn" onclick="closeModal('editUserModal')">Đóng</div>
        <form method="POST" action="admin_dashboard.php">
            <input type="hidden" name="action" value="edit_user">
            <input type="hidden" name="mssv" id="edit_mssv_hidden"> 
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0 20px;">
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">MSSV (Không được sửa)</label>
                    <input type="text" id="edit_mssv_display" class="faq-input" disabled style="background: #2c3138;">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Mật khẩu mới</label>
                    <input type="password" name="password" id="edit_password" class="faq-input" placeholder="Để trống nếu không đổi">
                </div>
                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Họ và tên *</label>
                    <input type="text" name="ho_ten" id="edit_hoten" class="faq-input" required>
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngày sinh</label>
                    <input type="date" name="ngay_sinh" id="edit_ngaysinh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Giới tính</label>
                    <select name="gioi_tinh" id="edit_gioitinh" class="faq-input" style="height: 44px;">
                        <option value="Nam">Nam</option><option value="Nữ">Nữ</option>
                    </select>
                </div>
                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Nơi sinh</label>
                    <input type="text" name="noi_sinh" id="edit_noisinh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngành học</label>
                    <input type="text" name="nganh" id="edit_nganh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Chuyên ngành</label>
                    <input type="text" name="chuyen_nganh" id="edit_chuyennganh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Khóa học</label>
                    <input type="text" name="khoa_hoc" id="edit_khoahoc" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Bậc đào tạo</label>
                    <select name="bac_dao_tao" id="edit_bacdaotao" class="faq-input" style="height: 44px;">
                        <option value="Đại học">Đại học</option><option value="Cao đẳng">Cao đẳng</option><option value="Thạc sĩ">Thạc sĩ</option>
                    </select>
                </div>
                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Loại hình đào tạo</label>
                    <select name="loai_hinh_dao_tao" id="edit_loaihinh" class="faq-input" style="height: 44px;">
                        <option value="Chính quy">Chính quy</option><option value="Vừa làm vừa học">Vừa làm vừa học</option><option value="Đào tạo từ xa">Đào tạo từ xa</option>
                    </select>
                </div>
            </div>
            <div style="text-align: right; margin-top: 10px; border-top: 1px solid #2c3138; padding-top: 15px;">
                <button type="button" class="btn btn-outline" style="margin-right: 10px;" onclick="closeModal('editUserModal')">Hủy bỏ</button>
                <button type="submit" class="btn" style="background: #ff9800;">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Hàm đẩy dữ liệu vào form Sửa
    function openEditUserModal(button) {
        let student = JSON.parse(button.getAttribute('data-info'));   
        document.getElementById('edit_mssv_hidden').value = student.mssv || student.username;
        document.getElementById('edit_mssv_display').value = student.mssv || student.username;
        document.getElementById('edit_password').value = '';
        document.getElementById('edit_hoten').value = student.ho_ten;
        document.getElementById('edit_ngaysinh').value = student.ngay_sinh || '';
        document.getElementById('edit_noisinh').value = student.noi_sinh || '';
        document.getElementById('edit_gioitinh').value = student.gioi_tinh || 'Nam';
        document.getElementById('edit_nganh').value = student.nganh || '';
        document.getElementById('edit_chuyennganh').value = student.chuyen_nganh || '';
        document.getElementById('edit_khoahoc').value = student.khoa_hoc || '';
        document.getElementById('edit_bacdaotao').value = student.bac_dao_tao || 'Đại học';
        document.getElementById('edit_loaihinh').value = student.loai_hinh_dao_tao || 'Chính quy';
        document.getElementById('editUserModal').classList.add('active');
    }
</script>
</body>
</html>

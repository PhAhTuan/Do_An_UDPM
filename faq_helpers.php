<?php

/**
 * Kết nối CSDL MySQL với fallback 127.0.0.1 nếu localhost thất bại.
 */
function connectDatabase(string $db_host, string $db_port, string $db_name, string $db_user, string $db_pass): PDO {
    $dsn = "mysql:host={$db_host};port={$db_port};dbname={$db_name};charset=utf8mb4";
    try {
        $pdo = new PDO($dsn, $db_user, $db_pass);
    } catch (PDOException $e) {
        if ($db_host === 'localhost') {
            $pdo = new PDO(
                "mysql:host=127.0.0.1;port={$db_port};dbname={$db_name};charset=utf8mb4",
                $db_user, $db_pass
            );
        } else {
            throw $e;
        }
    }
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    return $pdo;
}

/**
 * Phát hiện schema thực tế của bảng faq (hỗ trợ nhiều tên cột).
 */
function faqColumnSchema(PDO $pdo): array {
    $columns = $pdo->query("SHOW COLUMNS FROM faq")->fetchAll(PDO::FETCH_COLUMN);

    if (in_array('keywords', $columns, true) && in_array('answer', $columns, true)) {
        return [
            'keyword' => 'keywords',
            'answer'  => 'answer',
            'link'    => in_array('nav_link',     $columns, true) ? 'nav_link'     : null,
            'topic'   => in_array('topic_group',  $columns, true) ? 'topic_group'  : null,
            'stt'     => in_array('stt',           $columns, true),
        ];
    }

    if (in_array('tu_khoa', $columns, true) && in_array('noi_dung', $columns, true)) {
        return [
            'keyword' => 'tu_khoa',
            'answer'  => 'noi_dung',
            'link'    => in_array('link_dieu_huong', $columns, true) ? 'link_dieu_huong' : null,
            'topic'   => in_array('topic_group',     $columns, true) ? 'topic_group'     : null,
            'stt'     => in_array('stt',              $columns, true),
        ];
    }

    throw new RuntimeException('Bảng faq thiếu cột câu hỏi/câu trả lời hợp lệ.');
}

function quoteIdentifier(string $identifier): string {
    return '`' . str_replace('`', '``', $identifier) . '`';
}

function faqSelectSql(array $schema, string $orderBy = 'id DESC'): string {
    $keyword = quoteIdentifier($schema['keyword']) . ' AS tu_khoa';
    $answer  = quoteIdentifier($schema['answer'])  . ' AS noi_dung';
    $link    = $schema['link']  ? quoteIdentifier($schema['link'])  . ' AS link_dieu_huong' : "'' AS link_dieu_huong";
    $topic   = $schema['topic'] ? quoteIdentifier($schema['topic']) . ' AS topic_group'     : "'' AS topic_group";
    return "SELECT id, {$topic}, {$keyword}, {$answer}, {$link} FROM faq ORDER BY {$orderBy}";
}

function faqInsertSql(array $schema): string {
    $columns = [];
    $values  = [];

    if (!empty($schema['stt'])) {
        $columns[] = quoteIdentifier('stt');
        $values[]  = '(SELECT next_stt FROM (SELECT COALESCE(MAX(`stt`), 0) + 1 AS next_stt FROM faq) AS next_faq_stt)';
    }
    if ($schema['topic']) {
        $columns[] = quoteIdentifier($schema['topic']);
        $values[]  = '?';
    }

    $columns[] = quoteIdentifier($schema['keyword']);
    $columns[] = quoteIdentifier($schema['answer']);
    $values[]  = '?';
    $values[]  = '?';

    if ($schema['link']) {
        $columns[] = quoteIdentifier($schema['link']);
        $values[]  = '?';
    }

    return 'INSERT INTO faq (' . implode(', ', $columns) . ') VALUES (' . implode(', ', $values) . ')';
}

function faqUpdateSql(array $schema): string {
    $sets = [];
    if ($schema['topic']) $sets[] = quoteIdentifier($schema['topic']) . ' = ?';
    $sets[] = quoteIdentifier($schema['keyword']) . ' = ?';
    $sets[] = quoteIdentifier($schema['answer'])  . ' = ?';
    if ($schema['link'])  $sets[] = quoteIdentifier($schema['link'])  . ' = ?';
    return 'UPDATE faq SET ' . implode(', ', $sets) . ' WHERE id = ?';
}

function faqFormParams(array $schema, string $topic, string $keyword, string $answer, string $link = ''): array {
    $params = [];
    if ($schema['topic']) $params[] = trim($topic) !== '' ? trim($topic) : 'Chưa phân loại';
    $params[] = $keyword;
    $params[] = $answer;
    if ($schema['link'])  $params[] = $link;
    return $params;
}

function ensureFaqKnowledgeTable(PDO $pdo): void {
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS `faq` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `topic_group` VARCHAR(255) DEFAULT NULL COMMENT 'Nhom chu de',
            `tu_khoa` TEXT NOT NULL COMMENT 'Cau hoi / tu khoa sinh vien hay go',
            `noi_dung` TEXT NOT NULL COMMENT 'Noi dung tra loi chuan xac cua truong',
            `link_dieu_huong` VARCHAR(255) DEFAULT NULL COMMENT 'Link dieu huong den muc lien quan',
            PRIMARY KEY (`id`),
            KEY `idx_topic_group` (`topic_group`),
            FULLTEXT KEY `ft_keywords_answer` (`tu_khoa`, `noi_dung`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
          COMMENT='Kho tri thuc FAQ truong UTH'
    ");
}

function seedFaqKnowledgeFromSqlFile(PDO $pdo, string $sqlPath): int {
    if (!is_file($sqlPath)) {
        throw new RuntimeException('Không tìm thấy file seed FAQ: '.$sqlPath);
    }

    ensureFaqKnowledgeTable($pdo);

    $sql = file_get_contents($sqlPath);
    if ($sql === false || trim($sql) === '') {
        throw new RuntimeException('File seed FAQ rỗng hoặc không đọc được.');
    }

    $start = stripos($sql, 'INSERT INTO `faq`');
    if ($start === false) {
        throw new RuntimeException('File seed FAQ không có câu lệnh INSERT INTO `faq`.');
    }

    $end = stripos($sql, 'DROP TABLE IF EXISTS `tickets`', $start);
    if ($end === false) {
        $end = stripos($sql, 'SET FOREIGN_KEY_CHECKS=1', $start);
    }
    if ($end === false) {
        $end = strlen($sql);
    }

    $insertSql = trim(substr($sql, $start, $end - $start));
    $insertSql = preg_replace('/;\s*$/', '', $insertSql);
    $insertSql .= "
        ON DUPLICATE KEY UPDATE
            `topic_group` = VALUES(`topic_group`),
            `tu_khoa` = VALUES(`tu_khoa`),
            `noi_dung` = VALUES(`noi_dung`),
            `link_dieu_huong` = VALUES(`link_dieu_huong`)
    ";

    $pdo->exec($insertSql);
    return (int)$pdo->query("SELECT COUNT(*) FROM `faq`")->fetchColumn();
}

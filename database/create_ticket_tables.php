<?php
require_once __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

header('Content-Type: text/plain; charset=utf-8');

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    // Tạm tắt kiểm tra khoá ngoại để tránh lỗi 1451 khi có bảng khác
    // đang tham chiếu tới tickets (ví dụ ticket_messages hoặc bảng cũ khác).
    dbExecute($pdo, "SET FOREIGN_KEY_CHECKS = 0");

    // Xoá bảng cũ (nếu tồn tại) để tránh xung đột schema cũ (title/content)
    // với schema mới (subject/description).
    dbExecute($pdo, "DROP TABLE IF EXISTS ticket_messages");
    dbExecute($pdo, "DROP TABLE IF EXISTS tickets");

    dbExecute($pdo, "
        CREATE TABLE tickets (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            ticket_number VARCHAR(30) NOT NULL UNIQUE,
            student_id BIGINT UNSIGNED NULL,
            requester_name VARCHAR(150) NOT NULL,
            requester_student_code VARCHAR(50) NULL,
            category VARCHAR(120) NULL,
            subject VARCHAR(255) NOT NULL,
            description LONGTEXT NOT NULL,
            priority ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
            status ENUM('open','in_progress','waiting_student','resolved','closed','cancelled') NOT NULL DEFAULT 'open',
            assigned_to BIGINT UNSIGNED NULL,
            source_chat_session_id BIGINT UNSIGNED NULL,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            resolved_at DATETIME NULL,
            closed_at DATETIME NULL,
            INDEX idx_ticket_status_priority (status, priority),
            INDEX idx_ticket_student (student_id)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");

    dbExecute($pdo, "
        CREATE TABLE ticket_messages (
            id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
            ticket_id BIGINT UNSIGNED NOT NULL,
            sender_user_id BIGINT UNSIGNED NULL,
            sender_role ENUM('student','admin','system') NOT NULL,
            message LONGTEXT NOT NULL,
            is_internal_note BOOLEAN NOT NULL DEFAULT FALSE,
            created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_ticket_message_time (ticket_id, created_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ");

    // Bật lại kiểm tra khoá ngoại
    dbExecute($pdo, "SET FOREIGN_KEY_CHECKS = 1");

    echo "OK: Đã xoá bảng tickets/ticket_messages cũ (nếu có) và tạo lại đúng schema mới.\n";
} catch (Throwable $e) {
    http_response_code(500);
    echo 'ERROR: '.$e->getMessage()."\n";
}
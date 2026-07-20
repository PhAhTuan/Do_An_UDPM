<?php
include __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';
try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    $faqCount = seedFaqKnowledgeFromSqlFile($pdo, __DIR__.'/faq_knowledge_seed.sql');

    // Create system_notifications
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS system_notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            title VARCHAR(255) NOT NULL,
            content TEXT,
            type ENUM('event', 'news') DEFAULT 'news',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ");
    
    // Check if empty, then insert dummy data
    $stmt = $pdo->query("SELECT COUNT(*) FROM system_notifications");
    if ($stmt->fetchColumn() == 0) {
        $pdo->exec("
            INSERT INTO system_notifications (title, content, type) VALUES
            ('Thông báo nghỉ học ngày Giỗ tổ Hùng Vương', 'Toàn bộ sinh viên được nghỉ học vào ngày mùng 10/3 Âm lịch.', 'news'),
            ('Chương trình hội thảo Kỹ năng mềm', 'Kính mời sinh viên tham gia hội thảo tại HT A vào lúc 8:00 sáng mai.', 'event'),
            ('Thông báo nộp học phí HK2', 'Sinh viên vui lòng hoàn thành học phí trước ngày 30/5.', 'news')
        ");
    }

    // Create class_schedules
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS class_schedules (
            id INT AUTO_INCREMENT PRIMARY KEY,
            mssv VARCHAR(50) NOT NULL,
            subject_name VARCHAR(100) NOT NULL,
            room VARCHAR(50) NOT NULL,
            day_of_week INT NOT NULL, /* 2=Monday, 3=Tuesday... 8=Sunday */
            start_time TIME NOT NULL,
            end_time TIME NOT NULL
        )
    ");
    
    $stmt = $pdo->query("SELECT COUNT(*) FROM class_schedules");
    if ($stmt->fetchColumn() == 0) {
        $mssv = '075205019210'; // Using the user's MSSV from screenshot
        $pdo->exec("
            INSERT INTO class_schedules (mssv, subject_name, room, day_of_week, start_time, end_time) VALUES
            ('$mssv', 'Lập trình thiết bị di động', 'Phòng F101', 2, '07:30:00', '10:00:00'),
            ('$mssv', 'Thương mại điện tử', 'Phòng B202', 2, '13:00:00', '15:30:00'),
            ('$mssv', 'Lập trình mạng', 'Phòng D103', 3, '07:30:00', '10:00:00'),
            ('$mssv', 'Lịch sử Đảng cộng sản Việt Nam', 'HT A', 4, '07:30:00', '11:00:00'),
            ('$mssv', 'Lập trình phân tán', 'Phòng F304', 5, '13:00:00', '15:30:00'),
            ('$mssv', 'Quản trị dự án phần mềm', 'Phòng D201', 6, '07:30:00', '10:00:00')
        ");
    }
    
    echo "Tables and data initialized successfully! FAQ rows: {$faqCount}";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}

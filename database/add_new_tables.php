<?php
include __DIR__.'/../config.php';
try {
    $pdo = new PDO("mysql:host=$db_host;port=$db_port;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $mssv = '075205019210'; // User's MSSV

    // 1. Kết quả học tập (Grades)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS student_grades (
            id INT AUTO_INCREMENT PRIMARY KEY,
            mssv VARCHAR(50) NOT NULL,
            subject_name VARCHAR(150) NOT NULL,
            credits INT NOT NULL DEFAULT 3,
            score_process FLOAT NOT NULL,
            score_final FLOAT NOT NULL,
            score_total FLOAT NOT NULL,
            status VARCHAR(50) NOT NULL DEFAULT 'Đạt',
            term VARCHAR(50) NOT NULL
        )
    ");
    $stmt = $pdo->query("SELECT COUNT(*) FROM student_grades");
    if ($stmt->fetchColumn() == 0) {
        $pdo->exec("
            INSERT INTO student_grades (mssv, subject_name, credits, score_process, score_final, score_total, status, term) VALUES
            ('$mssv', 'Lập trình thiết bị di động', 3, 8.5, 9.0, 8.8, 'Đạt', 'HK1 (2025-2026)'),
            ('$mssv', 'Thương mại điện tử', 3, 7.0, 8.0, 7.5, 'Đạt', 'HK1 (2025-2026)'),
            ('$mssv', 'Lập trình mạng', 3, 9.0, 8.5, 8.7, 'Đạt', 'HK1 (2025-2026)'),
            ('$mssv', 'Lịch sử Đảng cộng sản Việt Nam', 2, 7.5, 6.5, 7.0, 'Đạt', 'HK1 (2025-2026)'),
            ('$mssv', 'Toán rời rạc', 3, 6.0, 3.0, 4.5, 'Học lại', 'HK2 (2024-2025)')
        ");
    }

    // 2. Tra cứu công nợ (Tuition)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS student_tuition (
            id INT AUTO_INCREMENT PRIMARY KEY,
            mssv VARCHAR(50) NOT NULL,
            term VARCHAR(50) NOT NULL,
            total_amount DECIMAL(15, 2) NOT NULL,
            paid_amount DECIMAL(15, 2) NOT NULL,
            debt_amount DECIMAL(15, 2) NOT NULL,
            payment_link VARCHAR(255) DEFAULT 'https://student.uth.edu.vn/payment'
        )
    ");
    $stmt = $pdo->query("SELECT COUNT(*) FROM student_tuition");
    if ($stmt->fetchColumn() == 0) {
        $pdo->exec("
            INSERT INTO student_tuition (mssv, term, total_amount, paid_amount, debt_amount) VALUES
            ('$mssv', 'HK1 (2025-2026)', 8500000, 5000000, 3500000)
        ");
    }

    // 3. Chương trình khung (Curriculum)
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS curriculum_subjects (
            id INT AUTO_INCREMENT PRIMARY KEY,
            major VARCHAR(100) NOT NULL,
            subject_name VARCHAR(150) NOT NULL,
            credits INT NOT NULL DEFAULT 3,
            is_mandatory BOOLEAN DEFAULT TRUE,
            prerequisites TEXT
        )
    ");
    $stmt = $pdo->query("SELECT COUNT(*) FROM curriculum_subjects");
    if ($stmt->fetchColumn() == 0) {
        $pdo->exec("
            INSERT INTO curriculum_subjects (major, subject_name, credits, is_mandatory, prerequisites) VALUES
            ('Công nghệ thông tin', 'Cơ sở dữ liệu', 3, 1, 'Nhập môn lập trình'),
            ('Công nghệ thông tin', 'Lập trình hướng đối tượng', 3, 1, 'Kỹ thuật lập trình'),
            ('Công nghệ thông tin', 'Phân tích thiết kế hệ thống', 3, 1, 'Cơ sở dữ liệu'),
            ('Công nghệ thông tin', 'Lập trình thiết bị di động', 3, 1, 'Lập trình hướng đối tượng, Cơ sở dữ liệu'),
            ('Công nghệ thông tin', 'Kỹ năng giao tiếp', 2, 0, 'Không'),
            ('Công nghệ thông tin', 'Đồ án tốt nghiệp', 6, 1, 'Hoàn thành tối thiểu 100 tín chỉ')
        ");
    }

    echo "Tạo 3 bảng (student_grades, student_tuition, curriculum_subjects) và thêm dữ liệu thành công!\\n";
} catch (Exception $e) {
    echo "Lỗi: " . $e->getMessage() . "\\n";
}

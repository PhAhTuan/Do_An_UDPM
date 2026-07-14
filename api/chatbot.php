<?php
session_start();
ini_set('display_errors', 0);
error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE);
header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('Asia/Ho_Chi_Minh');

require_once __DIR__.'/../config.php';
require_once __DIR__.'/../core/faq_helpers.php';

$startedAt = microtime(true);
$data = json_decode(file_get_contents('php://input'), true) ?: [];
$userMessage = trim((string)($data['message'] ?? ''));

if ($userMessage === '') {
    echo json_encode(['reply' => 'Lỗi: Không nhận được tin nhắn.', 'suggestions' => []], JSON_UNESCAPED_UNICODE);
    exit;
}

function e($value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function moneyVnd($value): string {
    return number_format((float)$value, 0, ',', '.').' VNĐ';
}

function statusLabelVi(?string $status): string {
    return match ($status) {
        'draft' => 'nháp',
        'unpaid' => 'chưa đóng',
        'partially_paid' => 'đã đóng một phần',
        'paid' => 'đã đóng',
        'overdue' => 'quá hạn',
        'cancelled' => 'đã hủy',
        'waived' => 'được miễn',
        'pending' => 'chờ công bố',
        'passed' => 'đạt',
        'failed' => 'không đạt',
        default => $status ?: 'chưa cập nhật',
    };
}

function examTypeLabelVi(?string $type): string {
    return match ($type) {
        'midterm' => 'giữa kỳ',
        'final' => 'cuối kỳ',
        'retake' => 'thi lại',
        'improvement' => 'cải thiện',
        default => $type ?: 'khác',
    };
}

function detectEntities(string $message, ?array $student): array {
    $norm = appNormalizeText($message);
    $entities = [
        'semester_code' => null,
        'academic_year_code' => null,
        'cohort_year' => null,
        'date_scope' => null,
    ];

    if (preg_match('/hoc ky\s*([123])|hk\s*([123])|ky\s*([123])/u', $norm, $m)) {
        $num = $m[1] ?: ($m[2] ?: $m[3]);
        $entities['semester_code'] = 'HK'.$num;
    } elseif (str_contains($norm, 'hoc ky phu') || str_contains($norm, 'he')) {
        if (preg_match('/(20\d{2})/u', $norm, $m)) {
            $entities['semester_code'] = 'HK_HE_'.$m[1];
        } else {
            $entities['semester_code'] = 'SUMMER';
        }
    }

    if (preg_match('/(20\d{2})\s*[- ]\s*(20\d{2})/u', $norm, $m)) {
        $entities['academic_year_code'] = $m[1].'-'.$m[2];
    } elseif (preg_match('/nam hoc\s*(20\d{2})|nam\s*(20\d{2})/u', $norm, $m)) {
        $year = $m[1] ?: $m[2];
        $entities['academic_year_code'] = $year.'-'.((int)$year + 1);
    }

    if (preg_match('/khoa\s*(20\d{2})/u', $norm, $m)) {
        $entities['cohort_year'] = (int)$m[1];
    } elseif (!empty($student['cohort_year'])) {
        $entities['cohort_year'] = (int)$student['cohort_year'];
    }

    if (appContainsAny($norm, ['hôm nay', 'hom nay'])) {
        $entities['date_scope'] = 'today';
    } elseif (appContainsAny($norm, ['ngày mai', 'ngay mai', 'mai'])) {
        $entities['date_scope'] = 'tomorrow';
    } elseif (appContainsAny($norm, ['tuần này', 'tuan nay'])) {
        $entities['date_scope'] = 'week';
    }

    return $entities;
}

function classifyQuestion(string $message): array {
    $norm = appNormalizeText($message);

    if (appContainsAny($norm, ['ho tro truc tuyen', 'can ho tro', 'ticket ho tro', 'tao ticket', 'gui yeu cau ho tro'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_support'];
    }

    if (appContainsAny($norm, ['dao tao truc tuyen', 'hoc truc tuyen', 'e learning', 'elearning'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_online_training'];
    }

    if (appContainsAny($norm, ['dich vu sinh vien', 'thu tuc sinh vien', 'xac nhan sinh vien', 'cap lai the sinh vien'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_student_services'];
    }

    if (appContainsAny($norm, ['chuong trinh khung', 'khung chuong trinh', 'lo trinh hoc'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_curriculum'];
    }

    if (appContainsAny($norm, ['mon hoc dieu kien', 'hoc phan dieu kien', 'mon tien quyet', 'dieu kien tien quyet'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_prerequisites'];
    }

    if (appContainsAny($norm, ['cong thanh toan', 'thanh toan truc tuyen', 'link thanh toan', 'payment'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_payment'];
    }

    if (appContainsAny($norm, ['lich thi', 'phong thi', 'ca thi', 'ngay thi'])) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_exams'];
    }

    if (appContainsAny($norm, ['lich hoc', 'thoi khoa bieu', 'hom nay hoc', 'ngay mai hoc', 'phong hoc', 'ca hoc'])) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_schedule'];
    }

    if (appContainsAny($norm, ['hoc phi', 'cong no', 'hoa don hoc phi', 'hoc phi cua', 'toi no', 'em no', 'da dong hoc phi', 'con no bao nhieu'])) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_tuition'];
    }

    if (
        appContainsAny($norm, ['ket qua hoc tap', 'bang diem', 'gpa', 'diem trung binh'])
        || (str_contains($norm, 'diem') && !appContainsAny($norm, ['diem chuan', 'diem san tuyen sinh', 'diem xet tuyen']))
    ) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_grades'];
    }

    if (appContainsAny($norm, ['thong tin ca nhan', 'ho so sinh vien', 'ma so sinh vien', 'mssv', 'nganh hoc cua', 'khoa hoc cua'])) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_profile'];
    }

    if (appContainsAny($norm, ['thong bao', 'deadline', 'han chot', 'su kien', 'lich dang ky', 'lich nop', 'bao tri'])) {
        return ['class' => 'thong_bao_deadline', 'intent' => 'announcements_deadlines'];
    }

    if (appContainsAny($norm, ['bay gio la may gio', 'may gio roi', 'gio hien tai', 'xem gio', 'hom nay la ngay may', 'thu may hom nay', 'ngay hom nay', 'gio nay'])) {
        return ['class' => 'tien_ich_thoi_gian', 'intent' => 'utility_datetime'];
    }

    if (appContainsAny($norm, ['xin chao', 'chao', 'hello', 'hi', 'cam on', 'ban la ai', 'ke chuyen', 'noi chuyen'])) {
        return ['class' => 'tro_chuyen_thong_thuong', 'intent' => 'small_talk'];
    }

    return ['class' => 'kien_thuc_hoc_vu', 'intent' => 'academic_knowledge'];
}

function keywordOverlapScore(string $question, string $text): float {
    $stopWords = [
        'toi' => true, 'em' => true, 'minh' => true, 'ban' => true, 'cho' => true,
        'hoi' => true, 've' => true, 'la' => true, 'co' => true, 'khong' => true,
        'nhu' => true, 'the' => true, 'nao' => true, 'cai' => true, 'nay' => true,
    ];
    $questionTokens = array_values(array_unique(array_filter(
        explode(' ', appNormalizeText($question)),
        fn($token) => mb_strlen($token, 'UTF-8') >= 2 && empty($stopWords[$token])
    )));
    if (!$questionTokens) {
        return 0.0;
    }

    $haystack = ' '.appNormalizeText($text).' ';
    $matches = 0;
    foreach ($questionTokens as $token) {
        if (mb_strpos($haystack, ' '.$token.' ', 0, 'UTF-8') !== false) {
            $matches++;
        }
    }

    return min(1.0, $matches / max(4, (int)ceil(count($questionTokens) * 0.7)));
}

function requireStudentForPersonal(?array $student): ?string {
    if ($student) {
        return null;
    }
    return 'Bạn cần đăng nhập bằng tài khoản sinh viên để mình tra cứu dữ liệu cá nhân như điểm, lịch học, lịch thi hoặc học phí.';
}

function buildProfileReply(array $student): string {
    $lines = [
        '<strong>Thông tin sinh viên</strong>',
        '- Họ tên: '.e($student['ho_ten'] ?? ''),
        '- MSSV: '.e($student['mssv'] ?? ''),
        '- Ngành: '.e($student['nganh'] ?: 'chưa cập nhật'),
        '- Chuyên ngành: '.e($student['chuyen_nganh'] ?: 'chưa cập nhật'),
        '- Khóa học: '.e($student['khoa_hoc'] ?: 'chưa cập nhật'),
        '- Lớp: '.e($student['class_code'] ?: 'chưa cập nhật'),
        '- Trạng thái học tập: '.e($student['academic_status'] ?? 'chưa cập nhật'),
    ];
    return implode('<br>', $lines);
}

function buildGradesReply(PDO $pdo, array $student): ?string {
    $rows = dbFetchAll($pdo, "
        SELECT
            ay.code AS academic_year,
            sem.name AS semester,
            s.code AS subject_code,
            s.name AS subject_name,
            cs.section_code,
            g.attendance_score,
            g.process_score,
            g.midterm_score,
            g.final_exam_score,
            g.final_score_10,
            g.grade_4,
            g.letter_grade,
            g.result,
            g.published_at
        FROM enrollments e
        JOIN course_sections cs ON cs.id = e.course_section_id
        JOIN subjects s ON s.id = cs.subject_id
        JOIN semesters sem ON sem.id = cs.semester_id
        JOIN academic_years ay ON ay.id = sem.academic_year_id
        LEFT JOIN grades g ON g.enrollment_id = e.id
        WHERE e.student_id = ?
        ORDER BY sem.start_date DESC, s.name ASC
        LIMIT 30
    ", [(int)$student['student_id']]);

    if (!$rows) {
        return null;
    }

    $lines = ['<strong>Kết quả học tập hiện có</strong>'];
    foreach ($rows as $row) {
        $score = $row['final_score_10'] !== null ? $row['final_score_10'].'/10' : 'chưa công bố';
        $letter = $row['letter_grade'] ? ' - điểm chữ '.$row['letter_grade'] : '';
        $lines[] = '- '.e($row['subject_name']).' ('.e($row['subject_code']).', '.e($row['semester']).'): '.$score.$letter;
    }
    $lines[] = 'Lưu ý: đây là dữ liệu đang có trong database portal, không thay thế bảng điểm chính thức của Phòng Đào tạo.';
    return implode('<br>', $lines);
}

function buildScheduleReply(PDO $pdo, array $student, array $entities): ?string {
    $params = [(int)$student['student_id']];
    $whereDate = '';
    if ($entities['date_scope'] === 'today') {
        $whereDate = ' AND css.day_of_week = ?';
        $params[] = (int)date('N');
    } elseif ($entities['date_scope'] === 'tomorrow') {
        $whereDate = ' AND css.day_of_week = ?';
        $params[] = (int)date('N', strtotime('+1 day'));
    }

    $rows = dbFetchAll($pdo, "
        SELECT
            s.name AS subject_name,
            s.code AS subject_code,
            cs.section_code,
            cs.lecturer_name,
            css.day_of_week,
            css.start_time,
            css.end_time,
            css.room,
            css.campus,
            css.online_meeting_url
        FROM enrollments e
        JOIN course_sections cs ON cs.id = e.course_section_id
        JOIN subjects s ON s.id = cs.subject_id
        JOIN class_schedule_sessions css ON css.course_section_id = cs.id
        WHERE e.student_id = ?
          AND e.enrollment_status IN ('registered', 'studying')
          {$whereDate}
        ORDER BY css.day_of_week ASC, css.start_time ASC
        LIMIT 40
    ", $params);

    if (!$rows) {
        return null;
    }

    $dayLabels = [1 => 'Thứ 2', 2 => 'Thứ 3', 3 => 'Thứ 4', 4 => 'Thứ 5', 5 => 'Thứ 6', 6 => 'Thứ 7', 7 => 'Chủ nhật'];
    $title = $entities['date_scope'] === 'today' ? 'Lịch học hôm nay' : ($entities['date_scope'] === 'tomorrow' ? 'Lịch học ngày mai' : 'Lịch học hiện có');
    $lines = ['<strong>'.e($title).'</strong>'];
    foreach ($rows as $row) {
        $lines[] = '- '.($dayLabels[(int)$row['day_of_week']] ?? 'Ngày học').' '
            .substr((string)$row['start_time'], 0, 5).'-'.substr((string)$row['end_time'], 0, 5)
            .': '.e($row['subject_name']).' ('.e($row['section_code']).'), phòng '.e($row['room'] ?: 'chưa cập nhật');
    }
    return implode('<br>', $lines);
}

function buildExamsReply(PDO $pdo, array $student): ?string {
    $rows = dbFetchAll($pdo, "
        SELECT
            s.name AS subject_name,
            s.code AS subject_code,
            cs.section_code,
            es.exam_type,
            es.exam_date,
            es.start_time,
            es.duration_minutes,
            es.room,
            es.campus,
            es.seat_number,
            es.notes
        FROM enrollments e
        JOIN course_sections cs ON cs.id = e.course_section_id
        JOIN subjects s ON s.id = cs.subject_id
        JOIN exam_schedules es ON es.course_section_id = cs.id
        WHERE e.student_id = ?
          AND e.enrollment_status IN ('registered', 'studying', 'completed')
        ORDER BY es.exam_date ASC, es.start_time ASC
        LIMIT 30
    ", [(int)$student['student_id']]);

    if (!$rows) {
        return null;
    }

    $lines = ['<strong>Lịch thi hiện có</strong>'];
    foreach ($rows as $row) {
        $lines[] = '- '.date('d/m/Y', strtotime($row['exam_date'])).' '
            .substr((string)$row['start_time'], 0, 5)
            .': '.e($row['subject_name']).' ('.e(examTypeLabelVi($row['exam_type'] ?? null)).'), phòng '.e($row['room'] ?: 'chưa cập nhật')
            .($row['seat_number'] ? ', SBD/Ghế: '.e($row['seat_number']) : '');
    }
    return implode('<br>', $lines);
}

function buildTuitionReply(PDO $pdo, array $student): ?string {
    $rows = dbFetchAll($pdo, "
        SELECT
            ti.invoice_number,
            ti.description,
            ti.subtotal,
            ti.discount_amount,
            ti.paid_amount,
            ti.outstanding_amount,
            ti.due_date,
            ti.status,
            ti.currency,
            sem.name AS semester,
            ay.code AS academic_year
        FROM tuition_invoices ti
        JOIN semesters sem ON sem.id = ti.semester_id
        JOIN academic_years ay ON ay.id = sem.academic_year_id
        WHERE ti.student_id = ?
        ORDER BY ti.issued_at DESC
        LIMIT 10
    ", [(int)$student['student_id']]);

    if (!$rows) {
        return null;
    }

    $lines = ['<strong>Thông tin học phí / công nợ</strong>'];
    foreach ($rows as $row) {
        $due = $row['due_date'] ? date('d/m/Y', strtotime($row['due_date'])) : 'chưa cập nhật';
        $termLabel = (string)$row['semester'];
        if (!str_contains($termLabel, (string)$row['academic_year'])) {
            $termLabel .= ' '.(string)$row['academic_year'];
        }
        $lines[] = '- '.e($termLabel).' ('.e($row['invoice_number']).'): phải thu '
            .moneyVnd($row['subtotal']).', đã đóng '.moneyVnd($row['paid_amount'])
            .', còn lại '.moneyVnd($row['outstanding_amount']).', hạn '.$due
            .', trạng thái '.e(statusLabelVi($row['status'] ?? null)).'.';
    }
    return implode('<br>', $lines);
}

function buildPortalNavigationReply(PDO $pdo, ?array $student, string $intent): array {
    if ($intent === 'nav_support') {
        return [
            '<strong>Hỗ trợ trực tuyến</strong><br>Mình có thể giúp bạn đi đúng hướng ngay từ đây. Bạn chỉ cần mô tả vấn đề cần hỗ trợ vào khung chat, còn nếu nội dung cần cán bộ xử lý hoặc hệ thống chưa có dữ liệu thì mình sẽ hướng dẫn tạo ticket để bộ phận phụ trách phản hồi.',
            ['Tạo ticket hỗ trợ', 'Hỏi lịch học', 'Hỏi học phí']
        ];
    }

    if ($intent === 'nav_online_training') {
        return [
            '<strong>Đào tạo trực tuyến</strong><br>Phần học trực tuyến của UTH nằm trong Portal, nơi bạn có thể xem tài liệu, bài giảng và thông báo lớp học. Nếu bạn đang gặp lỗi đăng nhập hoặc không thấy lớp học, cứ nói rõ lỗi cho mình, mình sẽ giúp bạn xử lý tiếp hoặc tạo ticket hỗ trợ.',
            ['Không thấy lớp học', 'Lỗi đăng nhập', 'Tạo ticket hỗ trợ']
        ];
    }

    if ($intent === 'nav_student_services') {
        return [
            '<strong>Dịch vụ sinh viên</strong><br>Mình có thể hỗ trợ bạn tra nhanh các thủ tục như xác nhận sinh viên, cấp lại thẻ, vay vốn, miễn giảm học phí, điểm rèn luyện hay các yêu cầu hành chính khác. Bạn cứ nói rõ thủ tục cần tra cứu, mình sẽ tìm đúng phần liên quan cho bạn.',
            ['Cấp lại thẻ sinh viên', 'Xin giấy xác nhận', 'Điểm rèn luyện']
        ];
    }

    if ($intent === 'nav_curriculum') {
        $program = trim((string)($student['nganh'] ?? ''));
        $specialization = trim((string)($student['chuyen_nganh'] ?? ''));
        $credits = (int)($student['total_credits'] ?? 0);
        $lines = ['<strong>Chương trình khung</strong>'];
        $lines[] = '- Ngành: '.e($program !== '' ? $program : 'chưa cập nhật');
        if ($specialization !== '') {
            $lines[] = '- Chuyên ngành: '.e($specialization);
        }
        if ($credits > 0) {
            $lines[] = '- Tổng tín chỉ chương trình: '.$credits;
        }
        $lines[] = 'Nếu bạn muốn, mình có thể giúp bạn bám vào từng học kỳ hoặc nhóm môn cụ thể để tra cứu sâu hơn.';
        return [implode('<br>', $lines), ['Lớp học phần hiện tại', 'Môn học điều kiện', 'Kết quả học tập']];
    }

    if ($intent === 'nav_prerequisites') {
        $rows = dbFetchAll($pdo, "
            SELECT
                s.code AS subject_code,
                s.name AS subject_name,
                ps.code AS prerequisite_code,
                ps.name AS prerequisite_name,
                sp.requirement_type,
                sp.minimum_letter_grade
            FROM subject_prerequisites sp
            JOIN subjects s ON s.id = sp.subject_id
            JOIN subjects ps ON ps.id = sp.prerequisite_subject_id
            ORDER BY s.name ASC, ps.name ASC
            LIMIT 20
        ");
        if (!$rows) {
            return [
                '<strong>Môn học điều kiện</strong><br>Hiện mình chưa thấy danh sách môn tiên quyết/môn điều kiện trong database. Nếu bạn gửi tên môn học cụ thể, mình có thể ghi nhận để hỗ trợ tiếp hoặc tạo ticket cập nhật dữ liệu khi cần.',
                ['Tạo ticket hỗ trợ', 'Hỏi chương trình khung', 'Hỏi đăng ký học phần']
            ];
        }
        $lines = ['<strong>Môn học điều kiện</strong>'];
        foreach ($rows as $row) {
            $minGrade = $row['minimum_letter_grade'] ? ' tối thiểu '.$row['minimum_letter_grade'] : '';
            $lines[] = '- '.e($row['subject_name']).' cần '.e($row['prerequisite_name']).$minGrade.'.';
        }
        return [implode('<br>', $lines), ['Hỏi đăng ký học phần', 'Hỏi chương trình khung']];
    }

    if ($intent === 'nav_payment') {
        $reply = '<strong>Cổng thanh toán trực tuyến</strong><br>Bạn có thể thanh toán học phí tại <a href="https://payment.ut.edu.vn" target="_blank" rel="noopener">payment.ut.edu.vn</a> hoặc trong mục Cổng thanh toán trên Portal. Nếu bạn muốn biết số tiền còn nợ, mình sẽ tra cứu trực tiếp hóa đơn của sinh viên đang đăng nhập để trả lời chính xác hơn.';
        return [$reply, ['Tôi còn nợ học phí không?', 'Hạn đóng học phí', 'Tạo ticket hỗ trợ']];
    }

    return [
        'Mình đã nhận được yêu cầu. Bạn nói rõ hơn mục cần tra cứu để mình hỗ trợ chính xác nhé.',
        ['Hỏi lịch học', 'Hỏi học phí', 'Tạo ticket hỗ trợ']
    ];
}

function buildAnnouncementReply(PDO $pdo, string $question): ?string {
    $items = [];
    $deadlines = dbFetchAll($pdo, "
        SELECT title, description, due_at, deadline_type, source_url,
               MATCH(title, description) AGAINST (? IN NATURAL LANGUAGE MODE) AS score
        FROM academic_deadlines
        WHERE status = 'published'
          AND (
              MATCH(title, description) AGAINST (? IN NATURAL LANGUAGE MODE)
              OR due_at BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 60 DAY)
          )
        ORDER BY score DESC, due_at ASC
        LIMIT 5
    ", [$question, $question]);

    foreach ($deadlines as $row) {
        $items[] = '- Deadline '.date('d/m/Y H:i', strtotime($row['due_at'])).': '.e($row['title'])
            .($row['description'] ? ' - '.e(mb_substr($row['description'], 0, 180, 'UTF-8')) : '');
    }

    $announcements = dbFetchAll($pdo, "
        SELECT title, summary, published_at, source_url,
               MATCH(title, summary, content) AGAINST (? IN NATURAL LANGUAGE MODE) AS score
        FROM announcements
        WHERE status = 'published'
          AND (expires_at IS NULL OR expires_at >= NOW())
          AND MATCH(title, summary, content) AGAINST (? IN NATURAL LANGUAGE MODE)
        ORDER BY score DESC, COALESCE(published_at, created_at) DESC
        LIMIT 5
    ", [$question, $question]);

    foreach ($announcements as $row) {
        $items[] = '- Thông báo '.($row['published_at'] ? date('d/m/Y', strtotime($row['published_at'])) : '').': '.e($row['title'])
            .($row['summary'] ? ' - '.e(mb_substr($row['summary'], 0, 180, 'UTF-8')) : '');
    }

    if (!$items) {
        return null;
    }

    return '<strong>Thông báo / deadline liên quan</strong><br>Mình đã lọc ra các mục có khả năng liên quan nhất, bạn xem nhanh bên dưới nhé:<br><br>'.implode('<br><br>', $items).'<br><br>Nếu bạn muốn, mình có thể rút gọn lại chỉ còn mục sát nhất với câu hỏi của bạn.';
}

function buildUtilityReply(string $intent): array {
    $now = new DateTimeImmutable('now', new DateTimeZone('Asia/Ho_Chi_Minh'));
    $timeLabel = $now->format('H:i');
    $dateLabel = $now->format('d/m/Y');
    $dayLabel = match ((int)$now->format('N')) {
        1 => 'Thứ 2',
        2 => 'Thứ 3',
        3 => 'Thứ 4',
        4 => 'Thứ 5',
        5 => 'Thứ 6',
        6 => 'Thứ 7',
        7 => 'Chủ nhật',
    };

    if ($intent === 'utility_datetime') {
        return [
            '<strong>Thời gian hiện tại</strong><br>Hôm nay là '.e($dayLabel).', ngày '.e($dateLabel).', và bây giờ là '.e($timeLabel).'. Nếu bạn muốn, mình cũng có thể nhắc thêm lịch học hoặc lịch thi gần nhất.',
            ['Lịch học hôm nay', 'Lịch thi của tôi', 'Học phí của tôi']
        ];
    }

    return ['Mình có thể giúp bạn xem giờ hiện tại, ngày hôm nay hoặc chuyển sang tra cứu lịch học, học phí và điểm nếu bạn muốn.', ['Xem giờ hiện tại', 'Lịch học hôm nay', 'Học phí của tôi']];
}

function callGemini(string $apiKey, string $userMsg, string $systemPrompt): string {
    $apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key='.rawurlencode($apiKey);
    $payload = [
        'systemInstruction' => ['role' => 'user', 'parts' => [['text' => $systemPrompt]]],
        'contents' => [
            ['role' => 'user', 'parts' => [['text' => $userMsg]]],
        ],
        'generationConfig' => [
            'temperature' => 0.25,
            'maxOutputTokens' => 900,
        ],
    ];

    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES),
        CURLOPT_TIMEOUT => 20,
    ]);
    $res = curl_exec($ch);
    if ($res === false) {
        throw new RuntimeException('Gemini network error: '.curl_error($ch));
    }
    curl_close($ch);

    $decoded = json_decode($res, true);
    if (isset($decoded['error'])) {
        throw new RuntimeException($decoded['error']['message'] ?? 'Gemini API error');
    }
    return trim($decoded['candidates'][0]['content']['parts'][0]['text'] ?? '');
}

function retrieveRagChunks(PDO $pdo, string $question, string $intent, array $entities, ?array $student, int $userMessageId): array {
    appEnsureRagViewShape($pdo);
    $limit = min(5, max(1, (int)appSystemSetting($pdo, 'rag.max_context_chunks', 5)));
    $minFinalScore = (float)appSystemSetting($pdo, 'rag.min_final_score', 0.58);

    $sql = "
        SELECT
            v.id AS article_id,
            v.title,
            v.category,
            v.intent_code,
            v.keywords,
            v.route_url,
            v.priority,
            v.confidence_level,
            v.source_title,
            v.source_url,
            v.semester_code,
            v.academic_year_code,
            v.cohort_from,
            v.cohort_to,
            kc.id AS chunk_id,
            kc.heading,
            kc.chunk_text,
            MATCH(v.title, v.keywords, v.answer_content) AGAINST (? IN NATURAL LANGUAGE MODE) AS article_score,
            MATCH(kc.heading, kc.chunk_text) AGAINST (? IN NATURAL LANGUAGE MODE) AS chunk_score
        FROM v_active_verified_knowledge v
        JOIN knowledge_chunks kc ON kc.article_id = v.id
        WHERE (
            MATCH(v.title, v.keywords, v.answer_content) AGAINST (? IN NATURAL LANGUAGE MODE)
            OR MATCH(kc.heading, kc.chunk_text) AGAINST (? IN NATURAL LANGUAGE MODE)
        )
          AND (v.intent_code IS NULL OR v.intent_code = ?)
    ";
    $params = [$question, $question, $question, $question, $intent];

    if (!empty($entities['semester_code'])) {
        if ($entities['semester_code'] === 'SUMMER') {
            $sql .= " AND (v.semester_code IS NULL OR v.semester_code = 'SUMMER' OR v.semester_code LIKE ? OR v.semester_code = 'HK3')";
            $params[] = '%HE%';
        } else {
            $sql .= " AND (v.semester_code IS NULL OR v.semester_code = ?)";
            $params[] = $entities['semester_code'];
        }
    }
    if (!empty($entities['academic_year_code'])) {
        $sql .= " AND (v.academic_year_code IS NULL OR v.academic_year_code = ?)";
        $params[] = $entities['academic_year_code'];
    }
    if (!empty($entities['cohort_year'])) {
        $sql .= " AND (v.cohort_from IS NULL OR v.cohort_from <= ?) AND (v.cohort_to IS NULL OR v.cohort_to >= ?)";
        $params[] = (int)$entities['cohort_year'];
        $params[] = (int)$entities['cohort_year'];
    }
    if (!empty($student['program_id'])) {
        $sql .= " AND (v.program_id IS NULL OR v.program_id = ?)";
        $params[] = (int)$student['program_id'];
    }

    $sql .= " ORDER BY (article_score + chunk_score) DESC, v.priority ASC LIMIT {$limit}";
    $rows = dbFetchAll($pdo, $sql, $params);

    $selected = [];
    foreach ($rows as $index => $row) {
        $articleScore = max(0.0, (float)$row['article_score']);
        $chunkScore = max(0.0, (float)$row['chunk_score']);
        $overlapScore = keywordOverlapScore($question, implode(' ', [
            $row['title'] ?? '',
            $row['category'] ?? '',
            $row['intent_code'] ?? '',
            $row['keywords'] ?? '',
            $row['heading'] ?? '',
            $row['chunk_text'] ?? '',
        ]));
        $keywordScore = max($overlapScore, min(1.0, ($articleScore + $chunkScore) / 2.0));
        $metadataScore = 0.0;
        if (($row['intent_code'] ?? null) === $intent) $metadataScore += 0.08;
        if (!empty($entities['semester_code']) && empty($row['semester_code'])) $metadataScore += 0.02;
        if (!empty($entities['academic_year_code']) && empty($row['academic_year_code'])) $metadataScore += 0.02;
        if (!empty($entities['cohort_year']) && empty($row['cohort_from']) && empty($row['cohort_to'])) $metadataScore += 0.02;
        $freshnessScore = 0.03;
        $priorityBoost = max(0, 6 - (int)$row['priority']) * 0.01;
        $finalScore = min(1.0, ($keywordScore * 0.85) + $metadataScore + $freshnessScore + $priorityBoost);
        $isSelected = $finalScore >= $minFinalScore;

        dbExecute($pdo, "
            INSERT INTO rag_retrieval_logs (
                user_message_id, article_id, chunk_id, rank_position, keyword_score,
                semantic_score, metadata_score, freshness_score, final_score,
                selected_for_context, rejection_reason
            )
            VALUES (?, ?, ?, ?, ?, NULL, ?, ?, ?, ?, ?)
        ", [
            $userMessageId,
            (int)$row['article_id'],
            (int)$row['chunk_id'],
            $index + 1,
            $keywordScore,
            $metadataScore,
            $freshnessScore,
            $finalScore,
            $isSelected ? 1 : 0,
            $isSelected ? null : 'below_min_final_score',
        ]);

        if ($isSelected) {
            $row['final_score'] = $finalScore;
            $selected[] = $row;
        }
    }

    return [$selected, $rows, $minFinalScore];
}

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    appEnsureRagViewShape($pdo);

    $student = isset($_SESSION['user_id']) ? appStudentByUserId($pdo, (int)$_SESSION['user_id']) : null;
    if (!$student && !empty($data['mssv'])) {
        $student = appStudentByCode($pdo, trim((string)$data['mssv']));
    }

    $classification = classifyQuestion($userMessage);
    $entities = detectEntities($userMessage, $student);
    $chatSession = appEnsureChatSession(
        $pdo,
        $data['sessionUuid'] ?? ($_SESSION['chat_session_uuid'] ?? null),
        $_SESSION['user_id'] ?? null,
        mb_substr($userMessage, 0, 80, 'UTF-8')
    );
    $_SESSION['chat_session_uuid'] = $chatSession['session_uuid'];
    $_SESSION['chat_session_db_id'] = (int)$chatSession['id'];

    $userMessageId = appLogChatMessage(
        $pdo,
        (int)$chatSession['id'],
        null,
        'user',
        $userMessage,
        $classification['intent'],
        $entities
    );

    $finish = function (
        string $reply,
        array $suggestions = [],
        string $answerStatus = 'ok',
        ?float $confidence = null,
        ?string $modelName = null
    ) use ($pdo, $chatSession, $userMessageId, $classification, $entities, $startedAt) {
        $assistantId = appLogChatMessage(
            $pdo,
            (int)$chatSession['id'],
            $userMessageId,
            'assistant',
            $reply,
            $classification['intent'],
            $entities,
            $modelName,
            $confidence,
            $answerStatus,
            (int)round((microtime(true) - $startedAt) * 1000)
        );

        echo json_encode([
            'reply' => $reply,
            'suggestions' => $suggestions,
            'sessionUuid' => $chatSession['session_uuid'],
            'messageId' => $assistantId,
            'intent' => $classification['intent'],
            'intentClass' => $classification['class'],
            'answerStatus' => $answerStatus,
        ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    };

    $fallbackMessage = (string)appSystemSetting(
        $pdo,
        'chatbot.fallback_message',
        'Mình chưa tìm thấy thông tin đủ chính xác trong hệ thống. Bạn có thể cung cấp thêm học kỳ, năm học hoặc tạo ticket hỗ trợ.'
    );

    if ($classification['class'] === 'portal_navigation') {
        [$reply, $suggestions] = buildPortalNavigationReply($pdo, $student, $classification['intent']);
        $finish($reply, $suggestions, 'ok', 1.0, 'database-navigation');
    }

    if ($classification['class'] === 'du_lieu_ca_nhan_sinh_vien') {
        $loginMessage = requireStudentForPersonal($student);
        if ($loginMessage) {
            appLogUnanswered($pdo, $userMessageId, $userMessage, $classification['intent']);
            $finish($loginMessage, ['Đăng nhập Portal', 'Liên hệ phòng Công tác sinh viên'], 'blocked', 0.0);
        }

        $reply = match ($classification['intent']) {
            'personal_grades' => buildGradesReply($pdo, $student),
            'personal_schedule' => buildScheduleReply($pdo, $student, $entities),
            'personal_exams' => buildExamsReply($pdo, $student),
            'personal_tuition' => buildTuitionReply($pdo, $student),
            default => buildProfileReply($student),
        };

        if (!$reply) {
            appLogUnanswered($pdo, $userMessageId, $userMessage, $classification['intent']);
            $finish($fallbackMessage, ['Tạo ticket hỗ trợ', 'Hỏi phòng Đào tạo'], 'insufficient_context', 0.0);
        }

        $finish($reply, ['Xem lịch học', 'Xem học phí', 'Xem lịch thi'], 'ok', 1.0, 'database');
    }

    if ($classification['class'] === 'thong_bao_deadline') {
        $reply = buildAnnouncementReply($pdo, $userMessage);
        if (!$reply) {
            appLogUnanswered($pdo, $userMessageId, $userMessage, $classification['intent']);
            $finish($fallbackMessage, ['Hỏi deadline học phí', 'Hỏi lịch đăng ký học phần'], 'insufficient_context', 0.0);
        }
        $finish($reply, ['Deadline gần nhất', 'Thông báo học phí', 'Thông báo lịch thi'], 'ok', 0.92, 'database');
    }

    if ($classification['class'] === 'tien_ich_thoi_gian') {
        [$reply, $suggestions] = buildUtilityReply($classification['intent']);
        $finish($reply, $suggestions, 'ok', 1.0, 'utility-time');
    }

    if ($classification['class'] === 'tro_chuyen_thong_thuong') {
        $reply = 'Chào bạn, mình là ChatBot UTH. Mình có thể giúp bạn xem lịch học, lịch thi, học phí, điểm, thông báo và cả những câu hỏi đơn giản như giờ hiện tại hoặc hôm nay là ngày nào.';
        $modelName = 'deterministic';
        if (trim((string)$apiKey) !== '') {
            try {
                $reply = callGemini($apiKey, $userMessage, "Bạn là ChatBot UTH. Trả lời thân thiện, tự nhiên, ngắn gọn bằng tiếng Việt. Hãy giống một trợ lý sinh viên thực tế: nói rõ ý chính trước, sau đó mới bổ sung chi tiết nếu cần. Không bịa thông tin học vụ, không hỏi hoặc nhắc dữ liệu nhạy cảm.");
                $modelName = 'gemini-2.5-flash-lite';
            } catch (Throwable $e) {
                error_log('Gemini small talk: '.$e->getMessage());
            }
        }
        $finish(nl2br(e($reply)), ['Xem điểm của tôi', 'Lịch học hôm nay', 'Tôi còn nợ học phí không?'], 'ok', 0.8, $modelName);
    }

    [$selectedChunks, $retrievedRows, $threshold] = retrieveRagChunks($pdo, $userMessage, $classification['intent'], $entities, $student, $userMessageId);
    if (!$selectedChunks) {
        appLogUnanswered($pdo, $userMessageId, $userMessage, $classification['intent']);
        $reply = '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.';
        $finish($reply, ['Hỏi lịch học', 'Hỏi học phí', 'Hỏi giờ hiện tại'], 'insufficient_context', 0.0);
    }

    $contextParts = [];
    foreach ($selectedChunks as $i => $row) {
        $contextParts[] = "Nguồn ".($i + 1).": ".$row['title']."\n"
            ."Độ tin cậy: ".$row['confidence_level']."; điểm truy xuất: ".number_format((float)$row['final_score'], 3)."\n"
            ."Nội dung: ".$row['chunk_text']."\n"
            ."URL: ".($row['route_url'] ?: ($row['source_url'] ?? ''));
    }
    $context = implode("\n\n", $contextParts);

    if (trim((string)$apiKey) === '') {
        $reply = '<strong>Mình đã tìm thấy thông tin phù hợp</strong><br>Mình tóm tắt ngắn gọn từ dữ liệu nội bộ đã kiểm duyệt như sau:<br><br>'.implode('<br><br>', array_map(
            fn($row) => '<strong>'.e($row['title']).'</strong><br>'.nl2br(e($row['chunk_text']))
                .($row['route_url'] ? '<br><a href="'.e($row['route_url']).'" target="_blank" rel="noopener">Xem chi tiết</a>' : ''),
            $selectedChunks
        )).'<br><br>Nếu bạn muốn, mình có thể giải thích lại theo cách ngắn hơn hoặc dễ hiểu hơn.';
        $finish($reply, ['Hỏi rõ học kỳ', 'Hỏi năm học', 'Tạo ticket hỗ trợ'], 'ok', (float)$selectedChunks[0]['final_score'], 'database-rag');
    }

    try {
        $systemPrompt = "Bạn là ChatBot UTH, một trợ lý sinh viên thực tế, thân thiện và chủ động. "
            ."Giữ đúng dữ liệu trong CONTEXT, nhưng phải diễn đạt lại tự nhiên như đang trò chuyện với sinh viên thật, không chép máy móc. "
            ."Dùng giọng văn gần gũi, xưng hô 'mình/bạn', trả lời ngắn gọn trước rồi mới bổ sung chi tiết nếu cần. "
            ."Nếu CONTEXT chưa đủ, hãy nói rõ là chưa có đủ thông tin và gợi ý người dùng cung cấp thêm học kỳ, năm học, mã lớp hoặc từ khóa liên quan. "
            ."Không tự đoán về điểm, lịch học, lịch thi, học phí cá nhân. Không yêu cầu hoặc lặp lại CCCD, địa chỉ, password hash, hay toàn bộ hồ sơ sinh viên. "
            ."Nếu người dùng chào hỏi hoặc cảm ơn, hãy đáp lại tự nhiên, thân thiện, không máy móc. "
            ."Ưu tiên một câu trả lời mạch lạc; chỉ dùng gạch đầu dòng khi thực sự cần liệt kê dữ liệu.\n\nCONTEXT:\n".$context;
        $answer = callGemini($apiKey, $userMessage, $systemPrompt);
        if ($answer === '') {
            throw new RuntimeException('Gemini returned empty answer');
        }
        $finish(nl2br(e($answer)), ['Hỏi thêm học kỳ', 'Hỏi quy chế liên quan', 'Tạo ticket hỗ trợ'], 'ok', (float)$selectedChunks[0]['final_score'], 'gemini-2.5-flash-lite');
    } catch (Throwable $e) {
        error_log('Gemini RAG: '.$e->getMessage());
        $reply = '<strong>Thông tin đã kiểm duyệt</strong><br>'.implode('<br><br>', array_map(
            fn($row) => e($row['chunk_text']).($row['route_url'] ? '<br><a href="'.e($row['route_url']).'">Xem chi tiết</a>' : ''),
            $selectedChunks
        ));
        $finish($reply, ['Hỏi rõ học kỳ', 'Hỏi năm học', 'Tạo ticket hỗ trợ'], 'ok', (float)$selectedChunks[0]['final_score'], 'database-rag');
    }
} catch (Throwable $e) {
    error_log('chatbot.php: '.$e->getMessage());
    echo json_encode([
        'reply' => 'Hệ thống chatbot đang gặp lỗi xử lý. Bạn thử lại sau vài giây nhé.',
        'suggestions' => ['Thử lại', 'Tạo ticket hỗ trợ'],
        'answerStatus' => 'error',
    ], JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
}

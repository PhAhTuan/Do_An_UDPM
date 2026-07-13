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
        'exempted' => 'được miễn',
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

    if (appContainsAny($norm, [
        'tao ticket', 'gui ticket', 'ticket ho tro', 'gui yeu cau ho tro',
        'nho admin', 'viet ticket', 'tao phieu', 'gui phieu ho tro',
        'can admin xu ly', 'lien he admin', 'can gap admin',
        'gui yeu cau', 'dat cau hoi cho admin',
    ])) {
        return ['class' => 'create_ticket', 'intent' => 'create_ticket'];
    }

    if (appContainsAny($norm, [
        'ngu', 'bot ngu', 'tra loi sai', 'sai roi', 'khong dung', 'khong phai',
        'hoi khong hieu', 'khong hieu y', 'noi linh tinh', 'tra loi lung tung',
    ])) {
        return ['class' => 'chatbot_feedback', 'intent' => 'chatbot_feedback'];
    }

    if (appContainsAny($norm, ['ho tro truc tuyen', 'can ho tro', 'ticket ho tro'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_support'];
    }

    if (appContainsAny($norm, ['dao tao truc tuyen', 'hoc truc tuyen', 'e learning', 'elearning'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_online_training'];
    }

    if (appContainsAny($norm, ['dich vu sinh vien', 'thu tuc sinh vien', 'xac nhan sinh vien', 'cap lai the sinh vien'])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_student_services'];
    }

    if (appContainsAny($norm, [
        'cac nganh dao tao', 'nganh dao tao', 'truong co nganh gi',
        'co nhung nganh nao', 'danh sach nganh', 'nganh hoc o truong',
    ])) {
        return ['class' => 'portal_navigation', 'intent' => 'nav_programs'];
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

    if (
        appContainsAny($norm, ['lich hoc', 'thoi khoa bieu', 'hom nay hoc', 'ngay mai hoc', 'phong hoc', 'ca hoc'])
        || (
            appContainsAny($norm, ['hom nay', 'ngay mai', 'tuan nay'])
            && appContainsAny($norm, ['hoc', 'mon', 'lop', 'phong'])
        )
    ) {
        return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => 'personal_schedule'];
    }

    $hasTuitionWord = appContainsAny($norm, ['hoc phi', 'cong no', 'hoa don', 'dong tien', 'tien hoc', 'tien']);
    $isGeneralTuitionQuestion = appContainsAny($norm, [
        'nam hoc', 'nam 202', 'khoa 20', 'tin chi', 'mot tin', '1 tin',
        'dai tra', 'tien tien', 'chat luong cao', 'muc thu', 'bao nhieu mot tin',
        'tre han', 'tre tien hoc', 'tre hoc phi', 'nop tre', 'phat hoc phi',
        'gia han hoc phi', 'xin no hoc phi',
    ]) || preg_match('/\b20\d{2}\b/u', $norm);
    $isPersonalTuitionQuestion = appContainsAny($norm, [
        'xem hoc phi', 'hoc phi cua toi', 'hoc phi cua minh', 'hoc phi cua em',
        'toi con no', 'minh con no', 'em con no', 'con no bao nhieu',
        'da dong hoc phi', 'dong hoc phi chua', 'hoa don hoc phi', 'cong no cua toi',
    ]);
    if ($isPersonalTuitionQuestion || ($hasTuitionWord && !$isGeneralTuitionQuestion)) {
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

    if (appContainsAny($norm, ['xin chao', 'chao', 'hello', 'hi', 'cam on', 'ban la ai', 'ke chuyen', 'noi chuyen'])) {
        return ['class' => 'tro_chuyen_thong_thuong', 'intent' => 'small_talk'];
    }

    return ['class' => 'kien_thuc_hoc_vu', 'intent' => 'academic_knowledge'];
}

function refineClassificationWithSession(PDO $pdo, int $sessionId, string $message, array $classification): array {
    if (($classification['class'] ?? '') !== 'kien_thuc_hoc_vu') {
        return $classification;
    }

    $norm = appNormalizeText($message);
    if ($norm === '' || mb_strlen($norm, 'UTF-8') < 2) {
        return $classification;
    }

    $looksLikeFollowUp = appContainsAny($norm, [
        'vay con', 'con mon', 'mon do', 'mon nay', 'cai do', 'cai nay',
        'diem nay', 'diem do', 'ngay mai thi sao', 'hom nay thi sao',
        'phong nao', 'may gio', 'bao nhieu', 'con no', 'da dong chua',
    ]);
    if (!$looksLikeFollowUp) {
        return $classification;
    }

    $lastIntent = dbFetchValue($pdo, "
        SELECT detected_intent
        FROM chat_messages
        WHERE session_id = ?
          AND sender_type = 'user'
          AND detected_intent IN ('personal_grades', 'personal_schedule', 'personal_tuition', 'personal_exams')
        ORDER BY id DESC
        LIMIT 1
    ", [$sessionId]);

    if (!$lastIntent) {
        return $classification;
    }

    if (
        $lastIntent === 'personal_grades'
        && !appContainsAny($norm, ['diem', 'mon', 'cai nay', 'cai do', 'vay con', 'cai thien', 'hoc lai', 'rot'])
    ) {
        return $classification;
    }
    if (
        $lastIntent === 'personal_schedule'
        && !appContainsAny($norm, ['lich', 'hoc', 'ngay mai', 'hom nay', 'phong', 'may gio', 'tuan nay'])
    ) {
        return $classification;
    }
    if (
        $lastIntent === 'personal_tuition'
        && !appContainsAny($norm, ['hoc phi', 'tien', 'no', 'dong', 'hoa don', 'bao nhieu'])
    ) {
        return $classification;
    }
    if (
        $lastIntent === 'personal_exams'
        && !appContainsAny($norm, ['thi', 'lich', 'phong', 'ca', 'ngay mai', 'hom nay'])
    ) {
        return $classification;
    }

    return ['class' => 'du_lieu_ca_nhan_sinh_vien', 'intent' => (string)$lastIntent];
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

function chatTextForGemini(string $content): string {
    $content = preg_replace('/<br\s*\/?>/i', "\n", $content) ?? $content;
    $content = strip_tags($content);
    $content = html_entity_decode($content, ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $content = str_replace(['TICKET_OFFER', 'TICKET_CONFIRM:'], '', $content);
    $content = preg_replace('/[ \t]+/u', ' ', $content) ?? $content;
    $content = preg_replace("/\n{3,}/u", "\n\n", $content) ?? $content;
    return trim($content);
}

function buildGeminiHistory(PDO $pdo, int $sessionId, int $beforeMessageId, int $limit = 4): array {
    $limit = max(0, min(10, $limit));
    if ($limit === 0) {
        return [];
    }

    $recentMessages = dbFetchAll($pdo, "
        SELECT sender_type, content
        FROM chat_messages
        WHERE session_id = ?
          AND id < ?
          AND sender_type IN ('user', 'assistant')
        ORDER BY id DESC
        LIMIT {$limit}
    ", [$sessionId, $beforeMessageId]);

    $history = [];
    foreach (array_reverse($recentMessages) as $msg) {
        $content = chatTextForGemini((string)($msg['content'] ?? ''));
        if ($content === '') {
            continue;
        }
        $history[] = [
            'role' => ($msg['sender_type'] === 'user') ? 'user' : 'model',
            'content' => mb_substr($content, 0, 1800, 'UTF-8'),
        ];
    }
    return $history;
}

function exactQuestionPhraseScore(string $question, string $phrases): float {
    $questionNorm = appNormalizeText($question);
    if ($questionNorm === '') {
        return 0.0;
    }

    $score = 0.0;
    foreach (preg_split('/[,;\r\n]+/u', $phrases) ?: [] as $phrase) {
        $rawPhrase = trim((string)$phrase);
        $phraseNorm = appNormalizeText((string)$phrase);
        if ($phraseNorm === '' || mb_strlen($phraseNorm, 'UTF-8') < 3) {
            continue;
        }

        $isShortAbbreviation = !str_contains($rawPhrase, ' ')
            && mb_strlen(appStripAccents($rawPhrase), 'UTF-8') <= 5;
        $maxPhraseScore = $isShortAbbreviation ? 0.65 : 0.9;

        if ($phraseNorm === $questionNorm) {
            return $isShortAbbreviation ? 0.85 : 1.0;
        }

        $phraseTokens = substr_count($phraseNorm, ' ') + 1;
        if (
            str_contains(' '.$questionNorm.' ', ' '.$phraseNorm.' ')
            || ($phraseTokens >= 3 && str_contains(' '.$phraseNorm.' ', ' '.$questionNorm.' '))
        ) {
            $score = max($score, $phraseTokens >= 3 ? $maxPhraseScore : min($maxPhraseScore, 0.72));
        }
    }
    return $score;
}

function faqIntentMismatchPenalty(string $question, string $faqText): float {
    $questionNorm = ' '.appNormalizeText($question).' ';
    $faqNorm = ' '.appNormalizeText($faqText).' ';
    $penalty = 0.0;

    foreach ([
        'rut', 'huy', 'hoan tien', 'cai thien', 'hoc lai', 'nang diem',
        'tien quyet', 'mon hoc truoc', 'dieu kien', 'phuc khao',
        'bao hiem', 'thu vien',
    ] as $term) {
        $termNorm = ' '.appNormalizeText($term).' ';
        if (str_contains($faqNorm, $termNorm) && !str_contains($questionNorm, $termNorm)) {
            $penalty += 0.035;
        }
    }

    return min(0.18, $penalty);
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

function studentGradeRows(PDO $pdo, array $student, int $limit = 40): array {
    return dbFetchAll($pdo, "
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
        LIMIT {$limit}
    ", [(int)$student['student_id']]);
}

function gradeSubjectMatches(array $rows, string $question): array {
    $norm = appNormalizeText($question);
    if ($norm === '') {
        return [];
    }

    $matches = [];
    foreach ($rows as $row) {
        $score = 0.0;
        foreach ([$row['subject_code'] ?? '', $row['section_code'] ?? ''] as $code) {
            $codeNorm = appNormalizeText((string)$code);
            if ($codeNorm !== '' && str_contains(' '.$norm.' ', ' '.$codeNorm.' ')) {
                $score = max($score, 1.0);
            }
        }

        $subjectNorm = appNormalizeText((string)($row['subject_name'] ?? ''));
        if ($subjectNorm !== '') {
            if (str_contains(' '.$norm.' ', ' '.$subjectNorm.' ')) {
                $score = max($score, 1.0);
            } else {
                $tokens = array_values(array_filter(
                    explode(' ', $subjectNorm),
                    fn($token) => mb_strlen($token, 'UTF-8') >= 3 && !in_array($token, ['hoc', 'phan', 'mon', 'lap', 'trinh'], true)
                ));
                $hit = 0;
                foreach ($tokens as $token) {
                    if (str_contains(' '.$norm.' ', ' '.$token.' ')) {
                        $hit++;
                    }
                }
                if ($hit >= 2 || ($hit >= 1 && count($tokens) <= 2)) {
                    $score = max($score, min(0.95, $hit / max(1, count($tokens))));
                }
            }
        }

        if ($score >= 0.45) {
            $row['_match_score'] = $score;
            $matches[] = $row;
        }
    }

    usort($matches, fn($a, $b) => ($b['_match_score'] <=> $a['_match_score']));
    return $matches;
}

function recentGradeSubjectQuestion(PDO $pdo, int $sessionId, int $beforeMessageId): string {
    $rows = dbFetchAll($pdo, "
        SELECT content
        FROM chat_messages
        WHERE session_id = ?
          AND id < ?
          AND sender_type = 'user'
          AND detected_intent = 'personal_grades'
        ORDER BY id DESC
        LIMIT 4
    ", [$sessionId, $beforeMessageId]);

    return implode("\n", array_column($rows, 'content'));
}

function isGradeImprovementQuestion(string $question): bool {
    $norm = appNormalizeText($question);
    return appContainsAny($norm, [
        'cai thien', 'hoc cai thien', 'nang diem', 'hoc lai de cai thien',
        'diem nay cai thien', 'co cai thien duoc khong',
    ]);
}

function isAllGradeQuestion(string $question): bool {
    $norm = appNormalizeText($question);
    return appContainsAny($norm, [
        'tung mon', 'cac mon', 'tat ca mon', 'bang diem', 'ket qua hoc tap',
        'diem cua minh', 'diem cua toi', 'hoc ky vua roi',
    ]);
}

function gradeScoreText(array $row): string {
    $score = $row['final_score_10'] !== null ? $row['final_score_10'].'/10' : 'chưa công bố';
    $letter = $row['letter_grade'] ? ' - điểm chữ '.$row['letter_grade'] : '';
    return $score.$letter;
}

function buildGradeImprovementReply(array $rows, array $matchedRows): string {
    $policy = 'Theo dữ liệu quy định hiện có, sinh viên có điểm trung bình môn ở mức D, D+, C, C+ có thể đăng ký học cải thiện ở học kỳ tiếp theo; điểm lần học sau sẽ thay thế điểm lần học trước.';
    $targetRows = $matchedRows ?: $rows;
    $eligibleLetters = ['D', 'D+', 'C', 'C+'];
    $lines = ['<strong>Khả năng học cải thiện</strong>', $policy];

    if (!$targetRows) {
        $lines[] = '- Database hiện chưa có điểm để đối chiếu.';
        return implode('<br>', $lines);
    }

    $shown = 0;
    foreach ($targetRows as $row) {
        $name = e($row['subject_name']).' ('.e($row['subject_code']).')';
        $letter = trim((string)($row['letter_grade'] ?? ''));
        if ($row['final_score_10'] === null && $letter === '') {
            $lines[] = '- '.$name.': điểm chưa công bố nên chưa kết luận được có học cải thiện hay không.';
        } elseif (in_array($letter, $eligibleLetters, true)) {
            $lines[] = '- '.$name.': '.e(gradeScoreText($row)).' - thuộc nhóm có thể đăng ký học cải thiện.';
        } elseif ($letter === 'F' || ($row['result'] ?? '') === 'failed') {
            $lines[] = '- '.$name.': '.e(gradeScoreText($row)).' - đây là rớt môn/học lại, không phải trường hợp học cải thiện điểm đã đạt.';
        } else {
            $lines[] = '- '.$name.': '.e(gradeScoreText($row)).' - chưa nằm trong nhóm D, D+, C, C+ theo quy định học cải thiện đang có trong hệ thống.';
        }
        $shown++;
        if (!$matchedRows && $shown >= 8) {
            break;
        }
    }

    return implode('<br>', $lines);
}

function buildGradesReply(PDO $pdo, array $student, string $question = '', ?int $sessionId = null, ?int $beforeMessageId = null): ?string {
    $rows = studentGradeRows($pdo, $student);

    if (!$rows) {
        return null;
    }

    $matchedRows = gradeSubjectMatches($rows, $question);
    if (!$matchedRows && $sessionId && $beforeMessageId && !isAllGradeQuestion($question)) {
        $matchedRows = gradeSubjectMatches($rows, recentGradeSubjectQuestion($pdo, $sessionId, $beforeMessageId));
    }

    if (isGradeImprovementQuestion($question)) {
        return buildGradeImprovementReply($rows, $matchedRows);
    }

    $displayRows = $matchedRows ?: $rows;
    $lines = [$matchedRows ? '<strong>Điểm môn được hỏi</strong>' : '<strong>Kết quả học tập hiện có</strong>'];
    foreach ($displayRows as $row) {
        $lines[] = '- '.e($row['subject_name']).' ('.e($row['subject_code']).', '.e($row['semester']).'): '.e(gradeScoreText($row));
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
          AND (css.valid_from IS NULL OR css.valid_from <= CURDATE())
          AND (css.valid_until IS NULL OR css.valid_until >= CURDATE())
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

function buildStudentPromptContext(PDO $pdo, ?array $student, string $intent, array $entities): string {
    if (!$student) {
        return '';
    }

    $lines = [
        '# DỮ LIỆU CÁ NHÂN SINH VIÊN',
        '- Họ tên: '.($student['ho_ten'] ?: 'chưa cập nhật'),
        '- MSSV: '.($student['mssv'] ?: 'chưa cập nhật'),
        '- Lớp: '.($student['class_code'] ?: 'chưa cập nhật'),
        '- Ngành: '.($student['nganh'] ?: 'chưa cập nhật'),
        '- Chuyên ngành: '.($student['chuyen_nganh'] ?: 'chưa cập nhật'),
        '- Khóa: '.($student['khoa_hoc'] ?: 'chưa cập nhật'),
        '- Trạng thái học tập: '.($student['academic_status'] ?: 'chưa cập nhật'),
    ];

    $studentId = (int)($student['student_id'] ?? 0);
    if ($studentId <= 0) {
        return implode("\n", $lines);
    }

    if ($intent === 'personal_tuition') {
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
                sem.name AS semester,
                ay.code AS academic_year
            FROM tuition_invoices ti
            JOIN semesters sem ON sem.id = ti.semester_id
            JOIN academic_years ay ON ay.id = sem.academic_year_id
            WHERE ti.student_id = ?
            ORDER BY ti.issued_at DESC
            LIMIT 10
        ", [$studentId]);

        $totalOutstanding = 0.0;
        foreach ($rows as $row) {
            $totalOutstanding += (float)$row['outstanding_amount'];
        }
        $lines[] = '';
        $lines[] = '## Học phí / công nợ';
        $lines[] = '- Tổng số tiền còn nợ trong database: '.moneyVnd($totalOutstanding);
        if (!$rows) {
            $lines[] = '- Chưa có hóa đơn học phí nào trong database.';
        }
        foreach ($rows as $row) {
            $due = $row['due_date'] ? date('d/m/Y', strtotime($row['due_date'])) : 'chưa cập nhật';
            $termLabel = trim((string)$row['semester'].' '.(string)$row['academic_year']);
            $lines[] = '- '.$termLabel.'; mã hóa đơn '.$row['invoice_number']
                .'; phải thu '.moneyVnd($row['subtotal'])
                .'; đã đóng '.moneyVnd($row['paid_amount'])
                .'; còn nợ '.moneyVnd($row['outstanding_amount'])
                .'; hạn '.$due
                .'; trạng thái '.statusLabelVi($row['status'] ?? null).'.';
        }
    }

    if ($intent === 'personal_schedule') {
        $params = [$studentId];
        $whereDate = '';
        $scopeLabel = 'trong tuần';
        if ($entities['date_scope'] === 'today') {
            $whereDate = ' AND css.day_of_week = ?';
            $params[] = (int)date('N');
            $scopeLabel = 'hôm nay';
        } elseif ($entities['date_scope'] === 'tomorrow') {
            $whereDate = ' AND css.day_of_week = ?';
            $params[] = (int)date('N', strtotime('+1 day'));
            $scopeLabel = 'ngày mai';
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
              AND (css.valid_from IS NULL OR css.valid_from <= CURDATE())
              AND (css.valid_until IS NULL OR css.valid_until >= CURDATE())
              {$whereDate}
            ORDER BY css.day_of_week ASC, css.start_time ASC
            LIMIT 40
        ", $params);

        $dayLabels = [1 => 'Thứ 2', 2 => 'Thứ 3', 3 => 'Thứ 4', 4 => 'Thứ 5', 5 => 'Thứ 6', 6 => 'Thứ 7', 7 => 'Chủ nhật'];
        $lines[] = '';
        $lines[] = '## Lịch học '.$scopeLabel;
        if (!$rows) {
            $lines[] = '- Chưa có lịch học phù hợp trong database.';
        }
        foreach ($rows as $row) {
            $lines[] = '- '.($dayLabels[(int)$row['day_of_week']] ?? 'Ngày học').' '
                .substr((string)$row['start_time'], 0, 5).'-'.substr((string)$row['end_time'], 0, 5)
                .'; '.$row['subject_name'].' ('.$row['subject_code'].'; lớp '.$row['section_code'].')'
                .'; phòng '.($row['room'] ?: 'chưa cập nhật')
                .'; cơ sở '.($row['campus'] ?: 'chưa cập nhật')
                .($row['lecturer_name'] ? '; giảng viên '.$row['lecturer_name'] : '').'.';
        }
    }

    if ($intent === 'personal_grades') {
        $rows = dbFetchAll($pdo, "
            SELECT
                ay.code AS academic_year,
                sem.name AS semester,
                s.code AS subject_code,
                s.name AS subject_name,
                cs.section_code,
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
            LIMIT 20
        ", [$studentId]);

        $lines[] = '';
        $lines[] = '## Kết quả học tập';
        if (!$rows) {
            $lines[] = '- Chưa có điểm trong database.';
        }
        foreach ($rows as $row) {
            $score10 = $row['final_score_10'] !== null ? $row['final_score_10'].'/10' : 'chưa công bố';
            $grade4 = $row['grade_4'] !== null ? '; hệ 4: '.$row['grade_4'] : '';
            $letter = $row['letter_grade'] ? '; điểm chữ '.$row['letter_grade'] : '';
            $lines[] = '- '.$row['subject_name'].' ('.$row['subject_code'].'; '.$row['semester'].' '.$row['academic_year'].'): '
                .$score10.$grade4.$letter.'; kết quả '.statusLabelVi($row['result'] ?? null).'.';
        }
    }

    if ($intent === 'personal_exams') {
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
            LIMIT 20
        ", [$studentId]);

        $lines[] = '';
        $lines[] = '## Lịch thi';
        if (!$rows) {
            $lines[] = '- Chưa có lịch thi trong database.';
        }
        foreach ($rows as $row) {
            $lines[] = '- '.date('d/m/Y', strtotime($row['exam_date'])).' '
                .substr((string)$row['start_time'], 0, 5)
                .'; '.$row['subject_name'].' ('.$row['subject_code'].'; '.examTypeLabelVi($row['exam_type'] ?? null).')'
                .'; thời lượng '.(int)$row['duration_minutes'].' phút'
                .'; phòng '.($row['room'] ?: 'chưa cập nhật')
                .($row['seat_number'] ? '; SBD/Ghế '.$row['seat_number'] : '').'.';
        }
    }

    return implode("\n", $lines);
}

function buildPortalNavigationReply(PDO $pdo, ?array $student, string $intent): array {
    if ($intent === 'nav_support') {
        return [
            '<strong>Hỗ trợ trực tuyến</strong><br>Bạn có thể nhập trực tiếp vấn đề cần hỗ trợ vào khung chat. Nếu câu hỏi cần cán bộ xử lý hoặc thiếu dữ liệu trong hệ thống, mình sẽ hướng dẫn tạo ticket hỗ trợ để bộ phận phụ trách phản hồi.',
            ['Tạo ticket hỗ trợ', 'Hỏi lịch học', 'Hỏi học phí']
        ];
    }

    if ($intent === 'nav_online_training') {
        return [
            '<strong>Đào tạo trực tuyến</strong><br>Bạn có thể truy cập khu vực học trực tuyến của UTH từ Portal để xem tài liệu, bài giảng và thông báo lớp học. Nếu bạn bị lỗi đăng nhập hoặc không thấy lớp học, hãy gửi mô tả lỗi để mình tạo ticket hỗ trợ.',
            ['Không thấy lớp học', 'Lỗi đăng nhập', 'Tạo ticket hỗ trợ']
        ];
    }

    if ($intent === 'nav_student_services') {
        return [
            '<strong>Dịch vụ sinh viên</strong><br>Mục này hỗ trợ các thủ tục như xác nhận sinh viên, cấp lại thẻ sinh viên, vay vốn, miễn giảm học phí, điểm rèn luyện, tư vấn sinh viên và các yêu cầu hành chính khác. Bạn có thể nói rõ thủ tục cần tra cứu để mình tìm đúng thông tin.',
            ['Cấp lại thẻ sinh viên', 'Xin giấy xác nhận', 'Điểm rèn luyện']
        ];
    }

    if ($intent === 'nav_programs') {
        $rows = dbFetchAll($pdo, "
            SELECT name, specialization, degree_level, education_type, total_credits
            FROM programs
            WHERE status = 'active'
            ORDER BY name ASC, specialization ASC, education_type ASC
            LIMIT 40
        ");

        if (!$rows) {
            return [
                '<strong>Ngành đào tạo</strong><br>Database hiện chưa có danh sách ngành đào tạo. Bạn có thể xem thông tin tuyển sinh/chương trình đào tạo trên cổng thông tin UTH hoặc tạo ticket để admin cập nhật dữ liệu.',
                ['Hỏi chương trình khung', 'Hỏi điểm chuẩn', 'Tạo ticket hỗ trợ']
            ];
        }

        $lines = ['<strong>Ngành đào tạo đang có trong hệ thống</strong>'];
        $seen = [];
        foreach ($rows as $row) {
            $name = trim((string)$row['name']);
            $detailParts = array_filter([
                trim((string)($row['specialization'] ?? '')),
                trim((string)($row['education_type'] ?? '')),
                appDegreeLabel($row['degree_level'] ?? null),
                !empty($row['total_credits']) ? ((int)$row['total_credits']).' tín chỉ' : '',
            ]);
            $line = '- '.$name.($detailParts ? ' - '.implode(', ', array_unique($detailParts)) : '');
            if (isset($seen[$line])) {
                continue;
            }
            $seen[$line] = true;
            $lines[] = e($line);
        }
        $lines[] = 'Lưu ý: đây là dữ liệu ngành đang có trong database portal, có thể chưa phải danh sách tuyển sinh đầy đủ mới nhất.';
        return [implode('<br>', $lines), ['Hỏi điểm chuẩn', 'Hỏi chương trình khung', 'Hỏi ngành CNTT']];
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
        $lines[] = 'Bạn có thể hỏi tiếp tên học kỳ hoặc nhóm môn cụ thể để mình tra cứu sâu hơn khi dữ liệu chương trình khung được cập nhật đầy đủ.';
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
                '<strong>Môn học điều kiện</strong><br>Database hiện chưa có danh sách môn tiên quyết/môn điều kiện. Bạn có thể gửi tên môn học cụ thể để mình ghi nhận và tạo ticket cập nhật dữ liệu nếu cần.',
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
        $reply = '<strong>Cổng thanh toán trực tuyến</strong><br>Bạn có thể thanh toán học phí tại <a href="https://payment.ut.edu.vn" target="_blank" rel="noopener">payment.ut.edu.vn</a> hoặc mục Cổng thanh toán trên Portal. Nếu bạn hỏi số tiền còn nợ, mình sẽ tra cứu trực tiếp hóa đơn trong database của sinh viên đang đăng nhập.';
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

    return $items ? '<strong>Thông báo / deadline liên quan</strong><br>'.implode('<br>', $items) : null;
}

function buildUthSystemPrompt(string $context): string {
    return <<<PROMPT
Bạn là ChatBot UTH, trợ lý ảo thân thiện của trường Đại học Giao thông Vận tải TP.HCM.
Nhiệm vụ của bạn là giải đáp thắc mắc cho sinh viên dựa trên NGỮ CẢNH (CONTEXT) được cung cấp.

# QUY TẮC BẮT BUỘC (TUYỆT ĐỐI TUÂN THỦ):
1. CHỈ SỬ DỤNG thông tin từ phần CONTEXT bên dưới để trả lời. Không sử dụng kiến thức bên ngoài, không tự bịa ra quy chế.
2. Nếu câu hỏi nằm ngoài phạm vi CONTEXT, hãy trả lời MỘT CÂU duy nhất: "Dạ, hiện tại em chưa tìm thấy thông tin chính xác về vấn đề này trong hệ thống. Anh/chị vui lòng liên hệ Phòng Đào tạo (support.ut.edu.vn) hoặc tạo ticket hỗ trợ nhé."
3. KHÔNG tự đoán hoặc tính toán điểm số, lịch thi, học phí nếu không có trong dữ liệu cá nhân.
4. Nếu CONTEXT có mục "DỮ LIỆU CÁ NHÂN SINH VIÊN", chỉ dùng đúng các dòng trong mục đó để trả lời thông tin riêng của sinh viên đang đăng nhập.
5. Trả lời ngắn gọn, súc tích, chia gạch đầu dòng cho dễ đọc. Xưng hô "mình" - "bạn" hoặc "em" - "anh/chị".
6. KHÔNG dùng emoji (biểu tượng cảm xúc) trong câu trả lời.

# CONTEXT:
{$context}
PROMPT;
}

function callGemini(string $apiKey, string $userMsg, string $systemPrompt, array $history = []): string {
    $apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key='.rawurlencode($apiKey);
    $contents = [];
    foreach ($history as $msg) {
        $role = ($msg['role'] ?? '') === 'model' ? 'model' : 'user';
        $content = trim((string)($msg['content'] ?? ''));
        if ($content === '') {
            continue;
        }
        $contents[] = [
            'role' => $role,
            'parts' => [['text' => $content]],
        ];
    }
    $contents[] = ['role' => 'user', 'parts' => [['text' => $userMsg]]];

    $payload = [
        'systemInstruction' => ['role' => 'user', 'parts' => [['text' => $systemPrompt]]],
        'contents' => $contents,
        'generationConfig' => [
            'temperature' => 0.1,
            'maxOutputTokens' => 800,
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

function retrieveFaqContextRows(PDO $pdo, string $question, int $userMessageId, int $limit, float $baseThreshold): array {
    try {
        ensureFaqKnowledgeTable($pdo);
        $schema = faqColumnSchema($pdo);
    } catch (Throwable $e) {
        error_log('FAQ retrieval schema: '.$e->getMessage());
        return [];
    }

    $faqThreshold = min(
        $baseThreshold,
        (float)appSystemSetting($pdo, 'rag.faq_min_final_score', 0.48)
    );
    $orderBy = $schema['priority'] ? 'priority DESC, id DESC' : 'id DESC';
    $rows = dbFetchAll($pdo, faqSelectSql($schema, $orderBy));

    $candidates = [];
    foreach ($rows as $row) {
        $primaryText = trim(implode(' ', [
            $row['topic_group'] ?? '',
            $row['tu_khoa'] ?? '',
        ]));
        $variationText = (string)($row['variations'] ?? '');
        $keywordText = trim($primaryText.' '.$variationText);
        $answerText = (string)($row['noi_dung'] ?? '');
        $exactScore = exactQuestionPhraseScore($question, ($row['tu_khoa'] ?? '')."\n".($row['variations'] ?? ''));
        $primaryScore = keywordOverlapScore($question, $primaryText);
        $variationScore = keywordOverlapScore($question, $variationText);
        $keywordScore = max($primaryScore, $variationScore * 0.78);
        $answerScore = keywordOverlapScore($question, $answerText);
        $rowSearchText = $primaryText.' '.$variationText.' '.$answerText;
        $mismatchPenalty = faqIntentMismatchPenalty($question, $primaryText.' '.$variationText);
        if (
            appContainsAny(appNormalizeText($question), ['hoc phi', 'tien hoc', 'cong no', 'dong tien'])
            && !appContainsAny(appNormalizeText($rowSearchText), ['hoc phi', 'tien hoc', 'cong no', 'dong tien', 'thanh toan'])
        ) {
            $mismatchPenalty += 0.45;
        }
        $priorityBoost = min(0.08, max(0, (int)($row['priority'] ?? 0)) * 0.01);
        $numberBonus = 0.0;
        if (preg_match_all('/\b(?:20\d{2}|\d{3,}(?:[.,]\d{3})*)\b/u', appNormalizeText($question), $numberMatches)) {
            $rowNorm = appNormalizeText($primaryText.' '.$variationText.' '.$answerText);
            $allNumbersMatch = true;
            foreach (array_unique($numberMatches[0]) as $numberToken) {
                if (!str_contains(' '.$rowNorm.' ', ' '.$numberToken.' ')) {
                    $allNumbersMatch = false;
                    break;
                }
            }
            if ($allNumbersMatch) {
                $numberBonus = 0.25;
            }
        }
        $finalScore = max(0.0, min(1.0, max(
            $exactScore,
            ($primaryScore * 0.74) + ($variationScore * 0.16) + ($answerScore * 0.10)
        ) + $priorityBoost + $numberBonus - $mismatchPenalty));

        if ($finalScore < $faqThreshold) {
            continue;
        }

        $candidates[] = [
            'article_id' => null,
            'chunk_id' => null,
            'title' => $row['tu_khoa'] ?: ($row['topic_group'] ?: 'FAQ UTH'),
            'category' => $row['topic_group'] ?: 'FAQ',
            'intent_code' => 'faq_knowledge',
            'keywords' => $keywordText,
            'route_url' => $row['link_dieu_huong'] ?? '',
            'priority' => (int)($row['priority'] ?? 0),
            'confidence_level' => 'high',
            'source_title' => 'FAQ UTH',
            'source_url' => '',
            'semester_code' => null,
            'academic_year_code' => null,
            'cohort_from' => null,
            'cohort_to' => null,
            'heading' => $row['tu_khoa'] ?: ($row['topic_group'] ?: 'FAQ UTH'),
            'chunk_text' => $answerText,
            'article_score' => $keywordScore,
            'chunk_score' => $answerScore,
            'metadata_score' => $exactScore,
            'final_score' => $finalScore,
            'retrieval_source' => 'faq',
        ];
    }

    usort($candidates, fn($a, $b) => $b['final_score'] <=> $a['final_score']);
    if ($candidates) {
        $topScore = (float)$candidates[0]['final_score'];
        $scoreWindow = $topScore >= 0.85 ? 0.025 : 0.12;
        $floorScore = max($faqThreshold, $topScore - $scoreWindow);
        $candidates = array_values(array_filter(
            $candidates,
            fn($row) => (float)$row['final_score'] >= $floorScore
        ));
    }
    $candidates = array_slice($candidates, 0, max(1, $limit));

    foreach ($candidates as $index => $row) {
        dbExecute($pdo, "
            INSERT INTO rag_retrieval_logs (
                user_message_id, article_id, chunk_id, rank_position, keyword_score,
                semantic_score, metadata_score, freshness_score, final_score,
                selected_for_context, rejection_reason
            )
            VALUES (?, NULL, NULL, ?, ?, NULL, ?, ?, ?, 1, NULL)
        ", [
            $userMessageId,
            100 + $index + 1,
            (float)$row['article_score'],
            (float)$row['metadata_score'],
            0.02,
            (float)$row['final_score'],
        ]);
    }

    return $candidates;
}

function retrieveRagChunks(PDO $pdo, string $question, string $intent, array $entities, ?array $student, int $userMessageId): array {
    appEnsureRagViewShape($pdo);
    $limit = min(5, max(1, (int)appSystemSetting($pdo, 'rag.max_context_chunks', 5)));
    $minFinalScore = (float)appSystemSetting($pdo, 'rag.min_final_score', 0.62);

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

    $faqRows = retrieveFaqContextRows($pdo, $question, $userMessageId, $limit, $minFinalScore);
    if ($faqRows) {
        if ((float)$faqRows[0]['final_score'] >= 0.9) {
            $selected = $faqRows;
        } else {
            $selected = array_merge($selected, $faqRows);
        }
        usort($selected, function ($a, $b) {
            $scoreCompare = $b['final_score'] <=> $a['final_score'];
            if ($scoreCompare !== 0) {
                return $scoreCompare;
            }
            return (($b['retrieval_source'] ?? '') === 'faq' ? 1 : 0) <=> (($a['retrieval_source'] ?? '') === 'faq' ? 1 : 0);
        });

        $deduped = [];
        $seenTexts = [];
        foreach ($selected as $row) {
            $textKey = appNormalizeText((string)($row['chunk_text'] ?? ''));
            if ($textKey !== '' && isset($seenTexts[$textKey])) {
                continue;
            }
            if ($textKey !== '') {
                $seenTexts[$textKey] = true;
            }
            $deduped[] = $row;
            if (count($deduped) >= $limit) {
                break;
            }
        }
        $selected = $deduped;
    }

    return [$selected, array_merge($rows, $faqRows ?? []), $minFinalScore];
}

try {
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    appEnsureRagViewShape($pdo);

    $student = isset($_SESSION['user_id']) ? appStudentByUserId($pdo, (int)$_SESSION['user_id']) : null;
    $sessionMssv = trim((string)($_SESSION['mssv'] ?? ''));
    $requestMssv = trim((string)($data['mssv'] ?? ''));
    if (!$student && $sessionMssv !== '') {
        $student = appStudentByCode($pdo, $sessionMssv);
    }
    if (!$student && $requestMssv !== '') {
        $student = appStudentByCode($pdo, $requestMssv);
    }

    $classification = classifyQuestion($userMessage);
    $entities = detectEntities($userMessage, $student);
    $currentUserId = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : null;
    $chatSessionUserId = isset($_SESSION['chat_session_user_id']) ? (int)$_SESSION['chat_session_user_id'] : null;
    if ($currentUserId !== $chatSessionUserId) {
        unset($_SESSION['chat_session_uuid'], $_SESSION['chat_session_db_id']);
        $_SESSION['chat_session_user_id'] = $currentUserId;
    }
    $requestSessionUuid = trim((string)($data['sessionUuid'] ?? ''));
    if ($requestSessionUuid === '') {
        $requestSessionUuid = $_SESSION['chat_session_uuid'] ?? null;
    }
    $chatSession = appEnsureChatSession(
        $pdo,
        $requestSessionUuid,
        $currentUserId,
        mb_substr($userMessage, 0, 80, 'UTF-8')
    );
    $_SESSION['chat_session_uuid'] = $chatSession['session_uuid'];
    $_SESSION['chat_session_db_id'] = (int)$chatSession['id'];
    $_SESSION['chat_session_user_id'] = $currentUserId;

    $classification = refineClassificationWithSession($pdo, (int)$chatSession['id'], $userMessage, $classification);
    $entities = detectEntities($userMessage, $student);

    $userMessageId = appLogChatMessage(
        $pdo,
        (int)$chatSession['id'],
        null,
        'user',
        $userMessage,
        $classification['intent'],
        $entities
    );
    $geminiHistory = buildGeminiHistory($pdo, (int)$chatSession['id'], $userMessageId, 4);
    $personalContext = buildStudentPromptContext($pdo, $student, $classification['intent'], $entities);

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

    // Xử lý intent tạo ticket trực tiếp
    if ($classification['class'] === 'create_ticket') {
        if (!$student) {
            $finish(
                'Bạn cần đăng nhập bằng tài khoản sinh viên để tạo ticket hỗ trợ.',
                ['Đăng nhập Portal'],
                'blocked',
                0.0
            );
        }
        $finish(
            'TICKET_CONFIRM:' . $userMessage,
            [],
            'ok',
            1.0,
            'deterministic'
        );
    }

    if ($classification['class'] === 'chatbot_feedback') {
        $finish(
            'Mình xin lỗi, câu trước có thể chưa đúng ý bạn. Bạn gửi lại câu hỏi cụ thể hơn hoặc nói rõ phần nào sai, mình sẽ tra lại theo dữ liệu sinh viên và kho FAQ đang có. Nếu vấn đề cần admin xử lý, mình có thể giúp tạo ticket hỗ trợ.',
            ['Gửi lại câu hỏi', 'Xem điểm của tôi', 'Tạo ticket hỗ trợ'],
            'clarification_needed',
            0.4,
            'deterministic-feedback'
        );
    }

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
            'personal_grades' => buildGradesReply($pdo, $student, $userMessage, (int)$chatSession['id'], $userMessageId),
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

    if ($classification['class'] === 'tro_chuyen_thong_thuong') {
        $reply = 'Chào bạn, mình là ChatBot UTH. Mình có thể hỗ trợ tra cứu điểm, lịch học, lịch thi, học phí và giải đáp kiến thức học vụ đã được kiểm duyệt.';
        $finish(nl2br(e($reply)), ['Xem điểm của tôi', 'Lịch học hôm nay', 'Tôi còn nợ học phí không?'], 'ok', 0.8, 'deterministic-small-talk');
    }

    [$selectedChunks, $retrievedRows, $threshold] = retrieveRagChunks($pdo, $userMessage, $classification['intent'], $entities, $student, $userMessageId);
    if (!$selectedChunks) {
        appLogUnanswered($pdo, $userMessageId, $userMessage, $classification['intent']);
        // Trả về TICKET_OFFER để JS hiển thị nút mời tạo ticket
        $finish(
            $fallbackMessage . ' TICKET_OFFER',
            ['Tạo ticket hỗ trợ', 'Cung cấp thêm học kỳ', 'Cung cấp năm học'],
            'insufficient_context',
            0.0
        );
    }

    $contextParts = [];
    foreach ($selectedChunks as $i => $row) {
        $contextParts[] = "Nguồn ".($i + 1).": ".$row['title']."\n"
            ."Độ tin cậy: ".$row['confidence_level']."; điểm truy xuất: ".number_format((float)$row['final_score'], 3)."\n"
            ."Nội dung: ".$row['chunk_text']."\n"
            ."URL: ".($row['route_url'] ?: ($row['source_url'] ?? ''));
    }
    $knowledgeContext = "# TRI THỨC ĐÃ KIỂM DUYỆT\n".implode("\n\n", $contextParts);
    $context = trim($personalContext !== '' ? $personalContext."\n\n".$knowledgeContext : $knowledgeContext);

    if (trim((string)$apiKey) === '') {
        $reply = '<strong>Thông tin đã kiểm duyệt</strong><br>'.implode('<br><br>', array_map(
            fn($row) => e($row['chunk_text']).($row['route_url'] ? '<br><a href="'.e($row['route_url']).'">Xem chi tiết</a>' : ''),
            $selectedChunks
        ));
        $finish($reply, ['Hỏi rõ học kỳ', 'Hỏi năm học', 'Tạo ticket hỗ trợ'], 'ok', (float)$selectedChunks[0]['final_score'], 'database-rag');
    }

    try {
        $systemPrompt = buildUthSystemPrompt($context);
        $answer = callGemini($apiKey, $userMessage, $systemPrompt, $geminiHistory);
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

<?php
ini_set('display_errors', 0);
error_reporting(E_ALL & ~E_DEPRECATED & ~E_NOTICE);
header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('Asia/Ho_Chi_Minh');

// ============================================================
// 1. ĐỌC DỮ LIỆU TỪ REQUEST
// ============================================================
$data              = json_decode(file_get_contents('php://input'), true);
$userMessage       = trim($data['message']                    ?? '');
$chatHistory       = is_array($data['history']   ?? null)     ? $data['history']           : [];
$studentName       = trim($data['studentName']                ?? '');
$studentFirstName  = trim($data['studentFirstName']           ?? $studentName);
$mssv              = trim($data['mssv']                       ?? '');
$todayDate         = trim($data['todayDate']                  ?? date('Y-m-d'));
$todayLabel        = trim($data['todayLabel']                 ?? date('d/m/Y'));
$todaySchedule     = is_array($data['todaySchedule']  ?? null)? $data['todaySchedule']     : [];
$todayDeadlines    = is_array($data['todayDeadlines'] ?? null)? $data['todayDeadlines']    : [];
$tomorrowLabel     = trim($data['tomorrowLabel']              ?? '');
$tomorrowSchedule  = is_array($data['tomorrowSchedule']?? null)?$data['tomorrowSchedule']  : [];
$tomorrowDeadlines = is_array($data['tomorrowDeadlines']??null)?$data['tomorrowDeadlines'] : [];

if ($userMessage === '') {
    echo json_encode(['reply' => 'Lỗi: Không nhận được tin nhắn.', 'suggestions' => []], JSON_UNESCAPED_UNICODE);
    exit;
}

// ============================================================
// 2. TEXT HELPERS
// ============================================================
function stripAccents(string $s): string {
    static $m = [
        'à'=>'a','á'=>'a','ạ'=>'a','ả'=>'a','ã'=>'a','â'=>'a','ầ'=>'a','ấ'=>'a','ậ'=>'a','ẩ'=>'a','ẫ'=>'a',
        'ă'=>'a','ằ'=>'a','ắ'=>'a','ặ'=>'a','ẳ'=>'a','ẵ'=>'a',
        'è'=>'e','é'=>'e','ẹ'=>'e','ẻ'=>'e','ẽ'=>'e','ê'=>'e','ề'=>'e','ế'=>'e','ệ'=>'e','ể'=>'e','ễ'=>'e',
        'ì'=>'i','í'=>'i','ị'=>'i','ỉ'=>'i','ĩ'=>'i',
        'ò'=>'o','ó'=>'o','ọ'=>'o','ỏ'=>'o','õ'=>'o','ô'=>'o','ồ'=>'o','ố'=>'o','ộ'=>'o','ổ'=>'o','ỗ'=>'o',
        'ơ'=>'o','ờ'=>'o','ớ'=>'o','ợ'=>'o','ở'=>'o','ỡ'=>'o',
        'ù'=>'u','ú'=>'u','ụ'=>'u','ủ'=>'u','ũ'=>'u','ư'=>'u','ừ'=>'u','ứ'=>'u','ự'=>'u','ử'=>'u','ữ'=>'u',
        'ỳ'=>'y','ý'=>'y','ỵ'=>'y','ỷ'=>'y','ỹ'=>'y','đ'=>'d',
        'À'=>'A','Á'=>'A','Ạ'=>'A','Ả'=>'A','Ã'=>'A','Â'=>'A','Ầ'=>'A','Ấ'=>'A','Ậ'=>'A','Ẩ'=>'A','Ẫ'=>'A',
        'Ă'=>'A','Ằ'=>'A','Ắ'=>'A','Ặ'=>'A','Ẳ'=>'A','Ẵ'=>'A',
        'È'=>'E','É'=>'E','Ẹ'=>'E','Ẻ'=>'E','Ẽ'=>'E','Ê'=>'E','Ề'=>'E','Ế'=>'E','Ệ'=>'E','Ể'=>'E','Ễ'=>'E',
        'Ì'=>'I','Í'=>'I','Ị'=>'I','Ỉ'=>'I','Ĩ'=>'I',
        'Ò'=>'O','Ó'=>'O','Ọ'=>'O','Ỏ'=>'O','Õ'=>'O','Ô'=>'O','Ồ'=>'O','Ố'=>'O','Ộ'=>'O','Ổ'=>'O','Ỗ'=>'O',
        'Ơ'=>'O','Ờ'=>'O','Ớ'=>'O','Ợ'=>'O','Ở'=>'O','Ỡ'=>'O',
        'Ù'=>'U','Ú'=>'U','Ụ'=>'U','Ủ'=>'U','Ũ'=>'U','Ư'=>'U','Ừ'=>'U','Ứ'=>'U','Ự'=>'U','Ử'=>'U','Ữ'=>'U',
        'Ỳ'=>'Y','Ý'=>'Y','Ỵ'=>'Y','Ỷ'=>'Y','Ỹ'=>'Y','Đ'=>'D',
    ];
    return strtr($s, $m);
}

function normalizeText(string $t): string {
    $t = mb_strtolower(stripAccents($t), 'UTF-8');
    $t = preg_replace('/[^a-z0-9]+/u', ' ', $t);
    return trim(preg_replace('/\s+/u', ' ', $t));
}

function stopwords(): array {
    static $sw = null;
    if ($sw === null) {
        // FIX: Bỏ 'phong' ra khỏi stopwords vì 'phòng học' là từ khóa quan trọng
        $sw = array_flip([
            'toi','minh','em','anh','chi','ban','thay','co','a',
            'sinh','vien','truong','uth','bot','ad','xin','cho','hoi','muon',
            'can','giup','nho','la','gi','ai','o','dau','the','nao','bao',
            'nhieu','lam','sao','khong','duoc','bi','phai','ve','voi','va',
            'hoac','nhung','cua','vao','khi','sau','truoc','tai','nay','kia',
            'do','nhe','nha','dang','thi','may','nam','cac','tat','ca','moi','nhat',
        ]);
    }
    return $sw;
}

function significantTokens(string $text): array {
    $norm = normalizeText($text);
    if ($norm === '') return [];
    // Giữ lại mã phòng học quan trọng (f, d, b1…)
    $imp = array_flip(['f','d','b1','a0','a00','a01','d01','d07']);
    $sw  = stopwords();
    $out = [];
    foreach (explode(' ', $norm) as $tok) {
        if ($tok === '') continue;
        $l = mb_strlen($tok, 'UTF-8');
        if (isset($imp[$tok]) || ($l >= 2 && !isset($sw[$tok]))) $out[] = $tok;
    }
    return array_values(array_unique($out));
}

function ngramsFromMessage(string $text): array {
    $norm  = normalizeText($text);
    if ($norm === '') return [];
    $words = array_values(array_filter(
        explode(' ', $norm),
        fn($w) => mb_strlen($w, 'UTF-8') >= 2 || in_array($w, ['f','d'], true)
    ));
    $phrases = [];
    $cnt = count($words);
    for ($sz = 2; $sz <= 5; $sz++)
        for ($i = 0; $i <= $cnt - $sz; $i++) {
            $ph = implode(' ', array_slice($words, $i, $sz));
            if (mb_strlen($ph, 'UTF-8') >= 5) $phrases[] = $ph;
        }
    usort($phrases, fn($a,$b) => mb_strlen($b,'UTF-8') <=> mb_strlen($a,'UTF-8'));
    return array_values(array_unique($phrases));
}

function containsPhrase(string $hay, string $needle): bool {
    return $needle !== '' && mb_strpos(' '.$hay.' ', ' '.$needle.' ', 0, 'UTF-8') !== false;
}

function isCampusAddressIntent(string $norm): bool {
    foreach (['dia chi truong','dia diem truong','truong uth o dau','uth o dau','truong o dau','truong nam o dau','co so chinh o dau','dia chi uth','dia chi co so'] as $kw) {
        if (mb_strpos($norm, $kw, 0, 'UTF-8') !== false) return true;
    }
    return false;
}

function faqTopicGroups(string $norm): array {
    $defs = [
        'tuition' => [
            'hoc phi','cong no','dong hoc phi','dong tien hoc','nop hoc phi',
            'thanh toan hoc phi','tien hoc','gia han hoc phi','mien giam hoc phi',
            'tin chi bao nhieu','mot tin chi'
        ],
        'admission' => [
            'diem chuan','diem san','trung tuyen','xet tuyen','tuyen sinh',
            'nguyen vong','hoc ba','to hop mon','khoi thi','chi tieu','nhap hoc'
        ],
        'grades' => [
            'xem diem','coi diem','tra cuu diem','diem mon','diem thi','diem f',
            'cach tinh diem','thang diem','gpa','hoc lai','cai thien diem','canh bao hoc vu'
        ],
        'schedule' => ['lich hoc','thoi khoa bieu','phong hoc','lich thi','ca hoc','gio hoc'],
        'profile' => ['thong tin ca nhan','ho so sinh vien','mssv','ma so sinh vien'],
    ];

    $groups = [];
    foreach ($defs as $group => $phrases) {
        if (hasAnyPhrase($norm, $phrases)) $groups[] = $group;
    }
    return $groups;
}

function topicGroupOverlapCount(array $a, array $b): int {
    return count(array_intersect($a, $b));
}

// ============================================================
// 3. RAG — SCORING + RETRIEVAL (Đã tối ưu ngưỡng)
// ============================================================
function scoreFaqRow(string $msg, array $row): int {
    $qn  = normalizeText($msg);
    $kn  = normalizeText($row['tu_khoa']     ?? '');
    $an  = normalizeText($row['noi_dung']    ?? '');
    $tn  = normalizeText($row['topic_group'] ?? '');
    $qtk = significantTokens($msg);
    if (empty($qtk) && count(ngramsFromMessage($msg)) === 0) return 0;

    if (isCampusAddressIntent($qn)) {
        $isAddressRow =
            mb_strpos($kn, 'dia chi truong', 0, 'UTF-8') !== false ||
            mb_strpos($kn, 'truong nam', 0, 'UTF-8') !== false ||
            (mb_strpos($tn, 'thong tin chung', 0, 'UTF-8') !== false && mb_strpos($an, 'vo oanh', 0, 'UTF-8') !== false);
        return $isAddressRow ? 1000 : 0;
    }

    if (mb_strpos($qn, 'phuc khao', 0, 'UTF-8') !== false) {
        $asksExamScore = hasAnyPhrase($qn, ['diem thi','bai thi','thi ket thuc','cham phuc khao']);
        $asksProcessScore = hasAnyPhrase($qn, ['diem qua trinh','diem thanh phan','giua ky','chuyen can']);
        if ($asksExamScore) {
            return (mb_strpos($tn.' '.$kn, 'phuc khao diem thi', 0, 'UTF-8') !== false) ? 950 : 0;
        }
        if ($asksProcessScore) {
            return (mb_strpos($tn.' '.$kn.' '.$an, 'qua trinh', 0, 'UTF-8') !== false) ? 950 : 0;
        }
    }

    $queryGroups = faqTopicGroups($qn);
    $rowGroups   = faqTopicGroups($tn.' '.$kn);
    $topicOverlap = topicGroupOverlapCount($queryGroups, $rowGroups);
    if (!empty($queryGroups) && !empty($rowGroups) && $topicOverlap === 0) return 0;

    $kt = array_flip(explode(' ', $kn));
    $at = array_flip(explode(' ', $an));
    $tt = array_flip(explode(' ', $tn));
    $sc = 0; $src = 0; $km = 0;

    if ($topicOverlap > 0) {
        $bonus = 18 * $topicOverlap;
        $sc += $bonus;
        $src += $bonus;
    }

    // Câu hỏi chứa nguyên chuỗi keyword
    if (mb_strlen($qn,'UTF-8') >= 8 && containsPhrase($kn, $qn)) { $sc += 50; $src += 50; }

    // N-gram matching
    foreach (ngramsFromMessage($msg) as $ph) {
        $wc = substr_count($ph, ' ') + 1;
        if (containsPhrase($kn, $ph)) { $p = 14+($wc*5); $sc += $p; $src += $p; }
        if (containsPhrase($tn, $ph)) { $p = 5+$wc;      $sc += $p; $src += $p; }
        if (containsPhrase($an, $ph))   $sc += 5+($wc*2);
    }

    // Token matching
    foreach ($qtk as $tok) {
        $tl = mb_strlen($tok,'UTF-8'); $b = $tl >= 4 ? 8 : 4;
        if (isset($kt[$tok])) { $sc += $b;       $src += $b; $km++; }
        if (isset($tt[$tok])) { $sc += 3;        $src += 3; }
        if (isset($at[$tok]))   $sc += max(1, $b-4);
        if ($tl >= 4 && mb_strpos($kn,$tok,0,'UTF-8') !== false) { $sc += 3; $src += 3; }
        if ($tl >= 4 && mb_strpos($an,$tok,0,'UTF-8') !== false)   $sc += 1;
    }

    // Bonus khi khớp nhiều token
    if ($km > 0) {
        $bon = $km * 3;
        if ($km === count($qtk)) $bon += 10; // Tất cả token đều khớp keyword
        $sc  += $bon;
        $src += $bon;
    }

    // FIX: Nâng ngưỡng loại bỏ từ 8 → 12 để lọc chặt hơn
    if ($src < 12) return 0;
    return $sc;
}

function buildContextualQuery(string $msg, array $history): string {
    if (empty($history)) return $msg;
    $len  = mb_strlen(trim($msg), 'UTF-8');
    $norm = normalizeText($msg);
    $vagues = ['vay','con','the','sao','con nua','them gi','gi nua','khi nao','bao gio','nhu the nao'];
    $isVague = ($len < 20);
    if (!$isVague) {
        foreach ($vagues as $v)
            if ($norm === $v || str_starts_with($norm, $v.' ')) { $isVague = true; break; }
    }
    if ($isVague) {
        $parts = [];
        foreach (array_slice($history, -6) as $t)
            if (($t['role'] ?? '') === 'user') $parts[] = trim($t['text'] ?? '');
        if (!empty($parts)) return implode(' ', $parts).' '.$msg;
    }
    return $msg;
}

function findRelevantFaqs(PDO $pdo, array $schema, string $msg): array {
    $rows   = $pdo->query(faqSelectSql($schema, 'id ASC'))->fetchAll();
    $scored = [];
    foreach ($rows as $row) {
        $s = scoreFaqRow($msg, $row);
        if ($s > 0) { $row['score'] = $s; $scored[] = $row; }
    }
    usort($scored, fn($a,$b) => $b['score'] <=> $a['score']);
    if (empty($scored)) return [];

    // FIX: Nâng ngưỡng threshold từ max(12, 0.65) → max(18, 0.70)
    $top = $scored[0]['score'];
    $min = max(18, (int) ceil($top * 0.70));
    // FIX: Trả về top 2 thay vì top 3 để context gọn, ít nhiễu
    return array_slice(
        array_values(array_filter($scored, fn($r) => $r['score'] >= $min)),
        0, 2
    );
}

// ============================================================
// 4. HELPERS: FORMAT & TICKET
// ============================================================
function formatFaqReply(array $row, string $studentName = 'bạn', string $question = ''): string {
    $topic = trim((string)($row['topic_group'] ?? 'Dịch vụ sinh viên'));
    $name  = trim($studentName) !== '' ? $studentName : 'bạn';
    $ans   = htmlspecialchars($row['noi_dung'] ?? '', ENT_QUOTES, 'UTF-8');
    $ans   = preg_replace('/\*\*(.*?)\*\*/u', '<strong>$1</strong>', $ans);
    $ans   = nl2br($ans);

    $reply = "Chào ".htmlspecialchars($name, ENT_QUOTES, 'UTF-8').", mình tìm thấy thông tin phù hợp trong kho tri thức UTH.";
    if ($question !== '') {
        $reply .= "<br><strong>Câu hỏi của bạn:</strong> ".htmlspecialchars($question, ENT_QUOTES, 'UTF-8');
    }
    $reply .= "<br><strong>Chủ đề:</strong> ".htmlspecialchars($topic, ENT_QUOTES, 'UTF-8');
    $reply .= "<br><br><strong>Thông tin chính:</strong><br>".$ans;

    $link = trim($row['link_dieu_huong'] ?? '');
    if ($link !== '') {
        $sl   = htmlspecialchars($link, ENT_QUOTES, 'UTF-8');
        $reply .= "<br><br><strong>Trang/mục liên quan:</strong> <a href=\"$sl\" target=\"_blank\">$sl</a>";
    }

    $reply .= "<br><br><strong>Lưu ý thêm:</strong><br>"
        ."- Nếu nội dung liên quan đến thông tin cá nhân như lịch học, điểm, học phí hoặc hồ sơ sinh viên, mình sẽ ưu tiên tra cứu theo MSSV đang đăng nhập.<br>"
        ."- Nếu bạn muốn biết chi tiết thủ tục, thời hạn, nơi nộp hồ sơ hoặc người phụ trách, hãy hỏi tiếp bằng một câu cụ thể hơn để mình lọc đúng dữ liệu.";

    return $reply;
}

function faqSuggestions(array $row): array {
    $topic = normalizeText(($row['topic_group'] ?? '').' '.($row['tu_khoa'] ?? ''));
    if (hasAnyPhrase($topic, ['diem chuan','diem san','tuyen sinh','xet tuyen','nguyen vong','nhap hoc'])) {
        return ['Phương thức tuyển sinh năm 2026?','Điểm chuẩn tất cả các ngành năm 2025?','Hồ sơ nhập học cần gì?'];
    }
    if (hasAnyPhrase($topic, ['hoc phi','cong no','thanh toan','bao hiem'])) {
        return ['Tôi còn nợ bao nhiêu tiền học phí?','Xin gia hạn học phí thế nào?','Có thông báo học phí mới không?'];
    }
    if (hasAnyPhrase($topic, ['diem','hoc vu','phuc khao','canh bao'])) {
        return ['Cho tôi xem điểm của tôi','Phúc khảo điểm thi thế nào?','Cảnh báo học vụ là gì?'];
    }
    if (hasAnyPhrase($topic, ['dang ky','hoc phan','chuong trinh','mon dieu kien'])) {
        return ['Cho tôi xem chương trình khung','Môn tiên quyết là gì?','Đăng ký học phần như thế nào?'];
    }
    if (hasAnyPhrase($topic, ['thong bao','su kien','doan hoi','hoc bong'])) {
        return ['Có thông báo mới nào không?','Điều kiện nhận học bổng là gì?','Hoạt động được cộng điểm rèn luyện không?'];
    }
    return ['Cho tôi xem lịch học tuần này','Có thông báo mới nào không?','Tôi cần hỗ trợ trực tuyến'];
}

/**
 * FIX: Bổ sung danh sách social keywords để không tạo ticket nhầm
 * cho câu hỏi xã giao, chào hỏi, tâm sự.
 */
function isSocialMessage(string $cleanMsg): bool {
    $socialPhrases = [
        'co khoe khong','khoe khong','ban co khoe','ban khoe','tot khong','ban tot',
        'ban the nao','the nao roi','sao roi','hom nay the nao','ban dang lam gi',
        'bao bao oi','bao bao','ban co vui','ban vui khong','buon qua','vui qua',
        'met qua','chan qua','yeu roi','cuoi roi','yeu ban','thich ban',
        'ban rat gioi','gioi that','tuyet voi','hay qua','dep qua',
        'co gi moi','co gi hay','ke cho nghe','binh thuong','binh an',
        'chuc ngu ngon','ngu ngon','good night','good morning','buoi sang',
        'buoi toi','buoi chieu','an gi chua','an gi roi','com chua','com roi',
        'di choi','di dau','di hoc','sap thi roi','thi xong','thi tot',
        'toi muon noi','toi muon tam su','tam su','toi can ban ben',
    ];
    foreach ($socialPhrases as $ph)
        if (str_contains($cleanMsg, $ph)) return true;
    return false;
}

function shouldCreateTicket(string $msg, string $cleanMsg): bool {
    // Không tạo ticket cho câu xã giao
    if (isSocialMessage($cleanMsg)) return false;
    // Chỉ tạo ticket khi câu hỏi đủ dài và có từ khóa đáng kể
    return mb_strlen($msg, 'UTF-8') >= 15 && count(significantTokens($msg)) >= 2;
}

function createSupportTicket(?PDO $pdo, string $msg, string $studentName = 'Sinh viên', string $studentMssv = '0000000000'): bool {
    if (!$pdo instanceof PDO) return false;
    try {
        if (session_status() === PHP_SESSION_NONE) session_start();
        $name  = $_SESSION['ho_ten'] ?? ($_SESSION['user'] ?? $studentName);
        $mssv  = $_SESSION['mssv']   ?? $studentMssv;
        if (trim($name) === '') $name = 'Sinh viên';
        if (trim($mssv) === '') $mssv = '0000000000';
        $title = 'Hỗ trợ về: '.mb_substr($msg, 0, 40, 'UTF-8').'...';
        // Tránh tạo ticket trùng trong 24h
        $ck = $pdo->prepare("SELECT id FROM tickets WHERE mssv=? AND content=? AND status='pending' AND created_at>=(NOW()-INTERVAL 1 DAY) LIMIT 1");
        $ck->execute([$mssv, $msg]);
        if ($ck->fetchColumn()) return true;
        $pdo->prepare("INSERT INTO tickets(student_name,mssv,title,content,status) VALUES(?,?,?,?,'pending')")
            ->execute([$name, $mssv, $title, $msg]);
        return true;
    } catch (Throwable $e) {
        error_log('Ticket: '.$e->getMessage());
        return false;
    }
}

// ============================================================
// 5. INTENT + FORMAT HELPERS
// ============================================================
function h(?string $value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function hasAnyPhrase(string $norm, array $phrases): bool {
    foreach ($phrases as $kw) {
        if ($kw !== '' && mb_strpos($norm, $kw, 0, 'UTF-8') !== false) return true;
    }
    return false;
}

function isScheduleIntent(string $norm): string|false {
    if (hasAnyPhrase($norm, ['hom nay','ngay hom nay','nay co hoc','nay hoc gi','lich hom nay','hoc hom nay','co gi hom nay','deadline hom nay','bai tap hom nay'])) return 'today';
    if (hasAnyPhrase($norm, ['ngay mai','mai co hoc','mai hoc gi','lich ngay mai','hoc ngay mai','co gi ngay mai','deadline mai','bai tap mai','mon hoc mai','buoi mai','co lich mai','ngay mai co','mai co lich','mai co deadline'])) return 'tomorrow';
    if (hasAnyPhrase($norm, ['deadline','bai tap','han nop','nop bai','sap toi'])) return 'deadline';
    if (hasAnyPhrase($norm, ['thoi khoa bieu','tkb','lich hoc','co lich hoc','lich tuan','tuan nay','ca tuan','ca hoc','phong hoc','gio hoc','buoi hoc','mon hoc nao'])) return 'week';
    return false;
}

function isNotificationIntent(string $norm): bool {
    return hasAnyPhrase($norm, ['thong bao','tin tuc','su kien','lich nghi','nghi hoc','bao tri','hoi thao','phan hoi ho tro','admin tra loi','ticket','yeu cau ho tro']);
}

function isGradeIntent(string $norm): bool {
    if (hasAnyPhrase($norm, [
        'diem chuan','diem san','diem ren luyen','phuc khao','cach tinh diem',
        'quy che diem','thang diem','bao nhieu diem thi','xet tuyen','tuyen sinh'
    ])) {
        return false;
    }

    return hasAnyPhrase($norm, [
        'xem diem','coi diem','tra cuu diem','diem mon','diem thi mon',
        'xem diem cua toi','coi diem cua toi','tra cuu diem cua toi',
        'diem cua toi','diem em','diem minh','ket qua hoc tap cua toi',
        'bang diem cua toi','diem thi cua toi','diem mon cua toi',
        'diem tong ket cua toi','gpa cua toi','toi co hoc lai','toi bi rot mon'
    ]);
}

function isTuitionIntent(string $norm): bool {
    return hasAnyPhrase($norm, [
        'cong no','no hoc phi','no bao nhieu','toi con no','minh con no',
        'hoc phi cua toi','con no','da dong bao nhieu','toi da dong',
        'xem hoc phi cua toi','tra cuu hoc phi','tra cuu cong no'
    ]);
}

function isProfileIntent(string $norm): bool {
    return hasAnyPhrase($norm, ['thong tin ca nhan','ho so sinh vien','thong tin sinh vien','mssv','ma so sinh vien','nganh hoc','chuyen nganh','khoa hoc','ngay sinh','noi sinh']);
}

function isCurriculumIntent(string $norm): bool {
    return hasAnyPhrase($norm, [
        'xem chuong trinh khung','cho toi xem chuong trinh khung',
        'chuong trinh khung cua toi','danh sach mon trong chuong trinh',
        'cac mon trong chuong trinh','mon bat buoc cua toi','mon tu chon cua toi'
    ]);
}

function tableExists(PDO $pdo, string $table): bool {
    try {
        $stmt = $pdo->prepare('SHOW TABLES LIKE ?');
        $stmt->execute([$table]);
        return (bool)$stmt->fetchColumn();
    } catch (Throwable $e) {
        return false;
    }
}

function uthDayIndexFromDate(string $date): int {
    $ts = strtotime($date) ?: time();
    return ((int)date('N', $ts)) + 1; // 2=Monday ... 8=Sunday
}

function dayLabelFromIndex($day): string {
    $day = is_numeric($day) ? (int)$day : 0;
    if ($day === 8) return 'Chủ nhật';
    if ($day >= 2 && $day <= 7) return 'Thứ '.$day;
    return 'Không rõ thứ';
}

function formatDateLabel(string $date): string {
    $ts = strtotime($date) ?: time();
    return date('d/m/Y', $ts);
}

function formatTimeValue(?string $time): string {
    $time = trim((string)$time);
    if ($time === '') return '';
    $ts = strtotime($time);
    return $ts ? date('H:i', $ts) : $time;
}

function formatRoomLabel(string $room): string {
    $room = trim($room);
    if ($room === '') return '';
    $norm = normalizeText($room);
    if (str_starts_with($norm, 'phong ') || str_starts_with($norm, 'ht ') || str_contains($norm, 'hoi truong')) {
        return $room;
    }
    return 'Phòng '.$room;
}

function formatCurrencyVnd($amount): string {
    return number_format((float)$amount, 0, ',', '.').' VNĐ';
}

function normalizeScheduleRows(array $rows): array {
    $out = [];
    foreach ($rows as $row) {
        if (!is_array($row)) continue;
        $subject = trim((string)($row['subject_name'] ?? $row['mon_hoc'] ?? $row['ten_mon'] ?? $row['title'] ?? ''));
        $room    = trim((string)($row['room'] ?? $row['phong_hoc'] ?? $row['phong'] ?? ''));
        $start   = trim((string)($row['start_time'] ?? $row['gio_bat_dau'] ?? $row['start'] ?? ''));
        $end     = trim((string)($row['end_time'] ?? $row['gio_ket_thuc'] ?? $row['end'] ?? ''));
        $day     = $row['day_of_week'] ?? $row['thu'] ?? null;
        $out[] = [
            'subject'     => $subject !== '' ? $subject : 'Môn học chưa rõ',
            'room'        => $room,
            'start_time'  => $start,
            'end_time'    => $end,
            'day_of_week' => is_numeric($day) ? (int)$day : null,
        ];
    }
    usort($out, function ($a, $b) {
        return [($a['day_of_week'] ?? 99), $a['start_time']] <=> [($b['day_of_week'] ?? 99), $b['start_time']];
    });
    return $out;
}

function formatScheduleRows(array $rows, bool $includeDay = true): string {
    $rows = normalizeScheduleRows($rows);
    if (empty($rows)) return 'Không có lịch học trong dữ liệu hiện tại.';

    $lines = [];
    foreach ($rows as $s) {
        $time = trim(formatTimeValue($s['start_time']).' - '.formatTimeValue($s['end_time']), ' -');
        $parts = [];
        if ($includeDay) $parts[] = dayLabelFromIndex($s['day_of_week']);
        $parts[] = $s['subject'];
        if ($time !== '') $parts[] = $time;
        if ($s['room'] !== '') $parts[] = formatRoomLabel($s['room']);
        $lines[] = '- '.implode(' | ', $parts);
    }
    return implode("\n", $lines);
}

function formatDeadlineRows(array $rows): string {
    if (empty($rows)) return 'Không có deadline nào trong dữ liệu hiện tại.';
    $lines = [];
    foreach ($rows as $d) {
        if (!is_array($d)) continue;
        $subject  = trim((string)($d['subject_name'] ?? $d['mon_hoc'] ?? ''));
        $name     = trim((string)($d['ten_bai'] ?? $d['title'] ?? $d['name'] ?? 'Bài tập'));
        $deadline = trim((string)($d['deadline'] ?? $d['due_at'] ?? $d['han_nop'] ?? ''));
        $when     = $deadline !== '' ? date('H:i d/m/Y', strtotime($deadline)) : 'chưa rõ hạn';
        $prefix   = $subject !== '' ? '['.$subject.'] ' : '';
        $lines[]  = '- '.$prefix.$name.' | Hạn: '.$when;
    }
    return empty($lines) ? 'Không có deadline nào trong dữ liệu hiện tại.' : implode("\n", $lines);
}

function formatScheduleContext(array $sched, array $dl): array {
    return [
        'scheduleText' => formatScheduleRows($sched, false),
        'deadlineText' => formatDeadlineRows($dl),
    ];
}

function buildScheduleReply(string $name, string $label, array $schedule, array $deadlines = []): array {
    $hasSchedule = !empty(normalizeScheduleRows($schedule));
    $hasDeadline = !empty($deadlines);
    $safeName = h($name);
    $safeLabel = h($label);

    if (!$hasSchedule && !$hasDeadline) {
        return [
            'reply' => "Chào {$safeName}, mình đã kiểm tra theo MSSV của bạn.<br><br><strong>{$safeLabel}</strong> hiện chưa có lịch học hoặc deadline nào trong hệ thống. Bạn có thể dùng thời gian này để ôn bài, chuẩn bị bài tập hoặc theo dõi thêm thông báo mới trên Portal.",
            'suggestions' => ['Cho tôi xem lịch học tuần này','Có thông báo mới nào không?','Xem kết quả học tập của tôi'],
        ];
    }

    $reply = "Chào {$safeName}, mình đã kiểm tra theo MSSV của bạn.<br><br><strong>{$safeLabel}</strong>";
    if ($hasSchedule) {
        $reply .= "<br><strong>Lịch học:</strong><br>".nl2br(h(formatScheduleRows($schedule, false)));
    } else {
        $reply .= "<br>Không có lịch học trong ngày này.";
    }
    if ($hasDeadline) {
        $reply .= "<br><br><strong>Deadline:</strong><br>".nl2br(h(formatDeadlineRows($deadlines)));
    }
    $reply .= "<br><br>Bạn nên đến trước giờ học khoảng 10-15 phút và kiểm tra lại thông báo nếu có thay đổi phòng học.";

    return [
        'reply' => $reply,
        'suggestions' => ['Cho tôi xem lịch học tuần này','Có thông báo mới nào không?','Tôi còn nợ học phí không?'],
    ];
}

function buildWeekScheduleReply(string $name, array $schedule): array {
    $safeName = h($name);
    if (empty(normalizeScheduleRows($schedule))) {
        return [
            'reply' => "Chào {$safeName}, hiện hệ thống chưa có thời khóa biểu tuần cho MSSV của bạn. Nếu bạn vừa được thêm lớp học phần, hãy thử tải lại trang hoặc liên hệ quản trị để cập nhật dữ liệu.",
            'suggestions' => ['Có thông báo mới nào không?','Xem thông tin sinh viên của tôi','Tôi cần hỗ trợ trực tuyến'],
        ];
    }
    return [
        'reply' => "Chào {$safeName}, đây là thời khóa biểu hiện có của bạn:<br><br><strong>Lịch học trong tuần:</strong><br>".nl2br(h(formatScheduleRows($schedule, true)))."<br><br>Mình đã sắp xếp theo thứ và giờ bắt đầu để bạn dễ theo dõi.",
        'suggestions' => ['Ngày mai mình có lịch học gì?','Hôm nay mình học gì?','Có thông báo nghỉ học không?'],
    ];
}

function buildNotificationReply(string $name, array $systemNotifications, array $ticketNotifications = []): array {
    $safeName = h($name);
    $lines = [];

    foreach (array_slice($systemNotifications, 0, 5) as $n) {
        if (!is_array($n)) continue;
        $date = !empty($n['created_at']) ? date('d/m/Y H:i', strtotime($n['created_at'])) : 'chưa rõ thời gian';
        $type = ($n['type'] ?? '') === 'event' ? 'Sự kiện' : 'Thông báo';
        $lines[] = '- ['.$type.'] '.($n['title'] ?? 'Thông báo').' | '.$date."\n  ".trim((string)($n['content'] ?? ''));
    }

    foreach (array_slice($ticketNotifications, 0, 3) as $t) {
        if (!is_array($t)) continue;
        $date = !empty($t['created_at']) ? date('d/m/Y H:i', strtotime($t['created_at'])) : 'chưa rõ thời gian';
        $lines[] = '- [Phản hồi hỗ trợ] '.($t['title'] ?? 'Yêu cầu hỗ trợ').' | '.$date."\n  ".trim((string)($t['admin_reply'] ?? ''));
    }

    if (empty($lines)) {
        return [
            'reply' => "Chào {$safeName}, hiện chưa có thông báo mới hoặc phản hồi hỗ trợ mới dành cho bạn. Bạn vẫn nên theo dõi khu vực thông báo trên Portal trước các mốc đăng ký học phần, học phí và lịch thi.",
            'suggestions' => ['Cho tôi xem lịch học tuần này','Tôi còn nợ học phí không?','Xem kết quả học tập của tôi'],
        ];
    }

    return [
        'reply' => "Chào {$safeName}, mình tìm thấy các thông báo mới nhất như sau:<br><br>".nl2br(h(implode("\n", $lines)))."<br><br>Nếu thông báo có mốc thời gian, bạn nên xử lý trước hạn để tránh ảnh hưởng đến đăng ký học phần, thi cử hoặc học phí.",
        'suggestions' => ['Có thông báo nghỉ học không?','Ngày mai mình có lịch học gì?','Tôi cần hỗ trợ trực tuyến'],
    ];
}

function buildGradesReply(string $name, array $grades): array {
    $safeName = h($name);
    if (empty($grades)) {
        return [
            'reply' => "Chào {$safeName}, hiện hệ thống chưa có dữ liệu điểm cho MSSV của bạn. Nếu bạn vừa hoàn tất môn học, điểm có thể chưa được giảng viên hoặc phòng đào tạo cập nhật lên Portal.",
            'suggestions' => ['Cách tính điểm môn học thế nào?','Cho tôi xem chương trình khung','Tôi cần hỗ trợ về điểm'],
        ];
    }

    $lines = [];
    $totalCredits = 0;
    $weightedTotal = 0.0;
    $failed = [];

    foreach ($grades as $g) {
        if (!is_array($g)) continue;
        $credits = (int)($g['credits'] ?? 0);
        $score = (float)($g['score_total'] ?? 0);
        if ($credits > 0) {
            $totalCredits += $credits;
            $weightedTotal += $credits * $score;
        }
        $status = trim((string)($g['status'] ?? ''));
        if ($status !== '' && normalizeText($status) !== 'dat') $failed[] = $g['subject_name'] ?? 'Môn chưa rõ';
        $lines[] = '- '.($g['subject_name'] ?? 'Môn chưa rõ').' ('.($g['credits'] ?? '?').' tín chỉ, '.($g['term'] ?? 'chưa rõ học kỳ').'): Quá trình '.($g['score_process'] ?? '?').', thi '.($g['score_final'] ?? '?').', tổng '.($g['score_total'] ?? '?').' - '.($status !== '' ? $status : 'chưa rõ trạng thái');
    }

    $avg = $totalCredits > 0 ? round($weightedTotal / $totalCredits, 2) : null;
    $summary = $avg !== null ? "<br><br><strong>Trung bình theo tín chỉ trong dữ liệu hiện có:</strong> ".h((string)$avg)."/10" : '';
    if (!empty($failed)) {
        $summary .= "<br><strong>Môn cần chú ý:</strong> ".h(implode(', ', $failed)).".";
    }

    return [
        'reply' => "Chào {$safeName}, đây là kết quả học tập hiện có của bạn:<br><br>".nl2br(h(implode("\n", $lines))).$summary."<br><br>Lưu ý: điểm trung bình ở trên chỉ tính trên các môn đang có trong bảng dữ liệu chatbot, không thay thế bảng điểm chính thức của Phòng Đào tạo.",
        'suggestions' => ['Cách tính điểm chữ như thế nào?','Tôi có môn nào phải học lại không?','Cho tôi xem học phí'],
    ];
}

function genericGradeQueryTokens(string $norm): array {
    return array_flip([
        'xem','coi','tra','cuu','diem','mon','hoc','thi','cua','toi','minh','em',
        'ket','qua','bang','tong','tong ket','gpa','cho','hoi','giup','voi','nhe'
    ]);
}

function gradeSubjectScore(string $questionNorm, array $grade): int {
    $subjectNorm = normalizeText($grade['subject_name'] ?? '');
    if ($subjectNorm === '') return 0;
    if (containsPhrase($questionNorm, $subjectNorm)) return 1000;

    $generic = genericGradeQueryTokens($questionNorm);
    $queryTokens = [];
    foreach (explode(' ', $questionNorm) as $tok) {
        if ($tok !== '' && !isset($generic[$tok]) && mb_strlen($tok, 'UTF-8') >= 2) $queryTokens[$tok] = true;
    }
    if (empty($queryTokens)) return 0;

    $subjectTokens = [];
    foreach (explode(' ', $subjectNorm) as $tok) {
        if ($tok !== '' && mb_strlen($tok, 'UTF-8') >= 2) $subjectTokens[$tok] = true;
    }

    $matched = 0;
    foreach ($queryTokens as $tok => $_) {
        if (isset($subjectTokens[$tok]) || mb_strpos($subjectNorm, $tok, 0, 'UTF-8') !== false) $matched++;
    }

    if ($matched === 0) return 0;
    $subjectCount = max(1, count($subjectTokens));
    return ($matched * 100) + ($matched === $subjectCount ? 80 : 0);
}

function findGradeMatches(string $question, array $grades): array {
    $norm = normalizeText($question);
    $matches = [];
    foreach ($grades as $g) {
        $score = gradeSubjectScore($norm, $g);
        if ($score > 0) {
            $g['_match_score'] = $score;
            $matches[] = $g;
        }
    }
    usort($matches, fn($a, $b) => ($b['_match_score'] ?? 0) <=> ($a['_match_score'] ?? 0));
    return $matches;
}

function buildSubjectGradeReply(string $name, string $question, array $grades): ?array {
    $matches = findGradeMatches($question, $grades);
    if (empty($matches)) return null;

    $topScore = (int)($matches[0]['_match_score'] ?? 0);
    $sameTop = array_values(array_filter($matches, fn($g) => (int)($g['_match_score'] ?? 0) === $topScore));

    if ($topScore < 200 || count($sameTop) > 1) {
        $names = array_map(fn($g) => $g['subject_name'] ?? 'Môn chưa rõ', array_slice($matches, 0, 5));
        return [
            'reply' => "Chào ".h($name).", mình thấy bạn đang hỏi điểm theo môn nhưng tên môn chưa đủ rõ. Trong dữ liệu của bạn có các môn gần khớp:<br><br>".nl2br(h('- '.implode("\n- ", $names)))."<br><br>Bạn hãy nhập rõ hơn, ví dụ: <strong>xem điểm Lập trình mạng</strong>.",
            'suggestions' => array_map(fn($g) => 'Xem điểm '.($g['subject_name'] ?? 'môn này'), array_slice($matches, 0, 3)),
        ];
    }

    $g = $matches[0];
    $status = trim((string)($g['status'] ?? 'chưa rõ trạng thái'));
    $reply = "Chào ".h($name).", mình đã tra điểm môn <strong>".h($g['subject_name'] ?? 'Môn chưa rõ')."</strong> theo MSSV của bạn:<br><br>"
        ."- <strong>Học kỳ:</strong> ".h($g['term'] ?? 'chưa rõ')."<br>"
        ."- <strong>Số tín chỉ:</strong> ".h((string)($g['credits'] ?? '?'))."<br>"
        ."- <strong>Điểm quá trình:</strong> ".h((string)($g['score_process'] ?? '?'))."<br>"
        ."- <strong>Điểm thi:</strong> ".h((string)($g['score_final'] ?? '?'))."<br>"
        ."- <strong>Điểm tổng kết:</strong> ".h((string)($g['score_total'] ?? '?'))."<br>"
        ."- <strong>Trạng thái:</strong> ".h($status)."<br><br>";

    if (normalizeText($status) === 'dat') {
        $reply .= "Kết luận: môn này đang được ghi nhận là <strong>Đạt</strong>. Bạn vẫn nên đối chiếu với bảng điểm chính thức trên Portal nếu cần nộp hồ sơ hoặc xét học vụ.";
    } else {
        $reply .= "Kết luận: môn này cần chú ý vì trạng thái hiện tại là <strong>".h($status)."</strong>. Bạn nên kiểm tra thông báo học lại/cải thiện hoặc hỏi cố vấn học tập nếu cần.";
    }

    return [
        'reply' => $reply,
        'suggestions' => ['Cho tôi xem toàn bộ điểm','Cách tính điểm chữ như thế nào?','Tôi có môn nào phải học lại không?'],
    ];
}

function buildTuitionReply(string $name, ?array $tuition): array {
    $safeName = h($name);
    if (!$tuition) {
        return [
            'reply' => "Chào {$safeName}, hiện hệ thống chưa có dữ liệu công nợ/học phí cho MSSV của bạn. Bạn có thể kiểm tra lại ở mục Cổng thanh toán hoặc liên hệ phòng tài chính nếu cần đối soát.",
            'suggestions' => ['Cho tôi xin link cổng thanh toán học phí','Có thông báo học phí mới không?','Tôi cần hỗ trợ trực tuyến'],
        ];
    }

    $debt = (float)($tuition['debt_amount'] ?? 0);
    $reply = "Chào {$safeName}, mình tra được thông tin học phí gần nhất của bạn:<br><br>"
        ."<strong>Học kỳ:</strong> ".h($tuition['term'] ?? 'chưa rõ')."<br>"
        ."<strong>Tổng phải đóng:</strong> ".h(formatCurrencyVnd($tuition['total_amount'] ?? 0))."<br>"
        ."<strong>Đã đóng:</strong> ".h(formatCurrencyVnd($tuition['paid_amount'] ?? 0))."<br>"
        ."<strong>Còn nợ:</strong> ".h(formatCurrencyVnd($debt))."<br>";

    if ($debt > 0 && !empty($tuition['payment_link'])) {
        $link = h($tuition['payment_link']);
        $reply .= "<br>Bạn còn công nợ, nên thanh toán sớm qua link: <a href=\"{$link}\" target=\"_blank\">{$link}</a>.";
    } elseif ($debt <= 0) {
        $reply .= "<br>Hiện không ghi nhận công nợ trong dữ liệu gần nhất.";
    }

    return [
        'reply' => $reply,
        'suggestions' => ['Có thông báo học phí mới không?','Cho tôi xem kết quả học tập','Lịch học tuần này của tôi'],
    ];
}

function buildProfileReply(string $name, array $profile, string $mssv): array {
    $safeName = h($name);
    if (empty($profile) && $mssv === '') {
        return [
            'reply' => "Mình chưa nhận được MSSV nên chưa thể tra cứu hồ sơ cá nhân. Bạn hãy đăng nhập bằng tài khoản sinh viên hoặc cung cấp MSSV để mình đối chiếu dữ liệu.",
            'suggestions' => ['Tôi cần hỗ trợ đăng nhập','Dịch vụ sinh viên hỗ trợ gì?','Liên hệ phòng CTSV ở đâu?'],
        ];
    }

    $lines = [
        '- Họ tên: '.($profile['ho_ten'] ?? $name),
        '- MSSV: '.($profile['username'] ?? $mssv),
        '- Ngày sinh: '.($profile['ngay_sinh'] ?? 'chưa cập nhật'),
        '- Nơi sinh: '.($profile['noi_sinh'] ?? 'chưa cập nhật'),
        '- Ngành: '.($profile['nganh'] ?? 'chưa cập nhật'),
        '- Chuyên ngành: '.($profile['chuyen_nganh'] ?? 'chưa cập nhật'),
        '- Khóa học: '.($profile['khoa_hoc'] ?? 'chưa cập nhật'),
        '- Bậc đào tạo: '.($profile['bac_dao_tao'] ?? 'chưa cập nhật'),
        '- Loại hình đào tạo: '.($profile['loai_hinh_dao_tao'] ?? 'chưa cập nhật'),
    ];

    return [
        'reply' => "Chào {$safeName}, đây là thông tin sinh viên mình đang có trong hệ thống:<br><br>".nl2br(h(implode("\n", $lines)))."<br><br>Nếu thông tin nào chưa đúng, bạn nên liên hệ quản trị/Phòng Công tác sinh viên để cập nhật hồ sơ.",
        'suggestions' => ['Cho tôi xem lịch học tuần này','Tôi còn nợ học phí không?','Xem kết quả học tập của tôi'],
    ];
}

function buildCurriculumReply(string $name, array $curriculum): array {
    $safeName = h($name);
    if (empty($curriculum)) {
        return [
            'reply' => "Chào {$safeName}, hiện hệ thống chưa có dữ liệu chương trình khung phù hợp với ngành của bạn. Bạn có thể hỏi về quy định đăng ký học phần hoặc liên hệ cố vấn học tập để được kiểm tra lộ trình.",
            'suggestions' => ['Đăng ký học phần như thế nào?','Môn tiên quyết là gì?','Tôi cần hỗ trợ trực tuyến'],
        ];
    }

    $lines = [];
    foreach (array_slice($curriculum, 0, 12) as $c) {
        if (!is_array($c)) continue;
        $type = !empty($c['is_mandatory']) ? 'Bắt buộc' : 'Tự chọn';
        $pre  = trim((string)($c['prerequisites'] ?? ''));
        $lines[] = '- '.($c['subject_name'] ?? 'Môn chưa rõ').' ('.($c['credits'] ?? '?').' tín chỉ, '.$type.'). Tiên quyết: '.($pre !== '' ? $pre : 'không ghi nhận');
    }

    return [
        'reply' => "Chào {$safeName}, mình tìm thấy các môn trong chương trình khung liên quan đến ngành của bạn:<br><br>".nl2br(h(implode("\n", $lines)))."<br><br>Khi đăng ký học phần, bạn nên kiểm tra môn tiên quyết và số tín chỉ tối đa trước khi chốt lịch.",
        'suggestions' => ['Môn tiên quyết là gì?','Cho tôi xem lịch học tuần này','Tôi có môn nào phải học lại không?'],
    ];
}

function renderAiAnswer(string $text): string {
    $text = trim($text);
    if ($text === '') return '';
    $safe = h($text);
    $safe = preg_replace('/\*\*(.*?)\*\*/u', '<strong>$1</strong>', $safe);
    return nl2br($safe);
}


// ============================================================
// 6. DB FETCH (RAG + dữ liệu cá nhân theo MSSV)
// ============================================================
$studentContextText   = "";
$pdo                  = null;
$results              = [];
$studentProfile       = [];
$grades               = [];
$tuition              = null;
$curr                 = [];
$allSchedule          = [];
$systemNotifications  = is_array($data['systemNotifications'] ?? null) ? $data['systemNotifications'] : [];
$ticketNotifications  = [];

$todayIndex = uthDayIndexFromDate($todayDate);
$tomorrowDate = date('Y-m-d', strtotime($todayDate.' +1 day'));
$tomorrowIndex = uthDayIndexFromDate($tomorrowDate);
if ($tomorrowLabel === '') $tomorrowLabel = formatDateLabel($tomorrowDate);

try {
    include_once __DIR__.'/config.php';
    require_once __DIR__.'/faq_helpers.php';
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

    // 6.1. FAQ RAG: lấy tri thức chung theo câu hỏi + lịch sử hội thoại.
    if (tableExists($pdo, 'faq')) {
        $faqSchema = faqColumnSchema($pdo);
        $searchQ   = buildContextualQuery($userMessage, $chatHistory);
        $results   = findRelevantFaqs($pdo, $faqSchema, $searchQ);
    }

    if ($mssv !== '') {
        // 6.2. Hồ sơ sinh viên.
        if (tableExists($pdo, 'users')) {
            $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ? AND role = 'student' LIMIT 1");
            $stmt->execute([$mssv]);
            $studentProfile = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];
            if (!empty($studentProfile['ho_ten'])) {
                $studentName = $studentProfile['ho_ten'];
                if ($studentFirstName === '' || $studentFirstName === $mssv || normalizeText($studentFirstName) === normalizeText($studentName)) {
                    $parts = preg_split('/\s+/u', trim($studentName));
                    $studentFirstName = $parts ? end($parts) : $studentName;
                }
            }
        }

        // 6.3. Lịch học: ưu tiên DB để không phụ thuộc payload frontend cũ.
        if (tableExists($pdo, 'class_schedules')) {
            $stmt = $pdo->prepare("SELECT * FROM class_schedules WHERE mssv = ? ORDER BY day_of_week ASC, start_time ASC");
            $stmt->execute([$mssv]);
            $allSchedule = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $dbToday = [];
            $dbTomorrow = [];
            foreach ($allSchedule as $class) {
                $dow = (int)($class['day_of_week'] ?? 0);
                if ($dow === $todayIndex) $dbToday[] = $class;
                if ($dow === $tomorrowIndex) $dbTomorrow[] = $class;
            }
            if (!empty($dbToday) || empty($todaySchedule)) $todaySchedule = $dbToday;
            if (!empty($dbTomorrow) || empty($tomorrowSchedule)) $tomorrowSchedule = $dbTomorrow;
        } else {
            $allSchedule = array_merge($todaySchedule, $tomorrowSchedule);
        }

        // 6.4. Điểm số.
        if (tableExists($pdo, 'student_grades')) {
            $stmt = $pdo->prepare("SELECT * FROM student_grades WHERE mssv = ? ORDER BY term DESC, subject_name ASC");
            $stmt->execute([$mssv]);
            $grades = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }

        // 6.5. Công nợ / học phí.
        if (tableExists($pdo, 'student_tuition')) {
            $stmt = $pdo->prepare("SELECT * FROM student_tuition WHERE mssv = ? ORDER BY id DESC LIMIT 1");
            $stmt->execute([$mssv]);
            $tuition = $stmt->fetch(PDO::FETCH_ASSOC) ?: null;
        }

        // 6.6. Chương trình khung theo ngành nếu có.
        if (tableExists($pdo, 'curriculum_subjects')) {
            $major = trim((string)($studentProfile['nganh'] ?? ''));
            if ($major !== '') {
                $stmt = $pdo->prepare("SELECT * FROM curriculum_subjects WHERE major = ? ORDER BY id ASC LIMIT 30");
                $stmt->execute([$major]);
                $curr = $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
            if (empty($curr)) {
                $stmt = $pdo->query("SELECT * FROM curriculum_subjects ORDER BY id ASC LIMIT 30");
                $curr = $stmt->fetchAll(PDO::FETCH_ASSOC);
            }
        }

        // 6.7. Phản hồi hỗ trợ cá nhân.
        if (tableExists($pdo, 'tickets')) {
            $stmt = $pdo->prepare("SELECT * FROM tickets WHERE mssv = ? AND status = 'replied' ORDER BY created_at DESC LIMIT 5");
            $stmt->execute([$mssv]);
            $ticketNotifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
        }
    }

    // 6.8. Thông báo hệ thống chung.
    if (tableExists($pdo, 'system_notifications')) {
        $stmt = $pdo->query("SELECT * FROM system_notifications ORDER BY created_at DESC LIMIT 10");
        $systemNotifications = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
} catch (Throwable $e) {
    error_log('DB Context Fetch Error: '.$e->getMessage());
}

$contextSections = [];
if (!empty($studentProfile)) {
    $contextSections[] = "[HỒ SƠ SINH VIÊN]\n"
        ."- Họ tên: ".($studentProfile['ho_ten'] ?? $studentName)."\n"
        ."- MSSV: ".($studentProfile['username'] ?? $mssv)."\n"
        ."- Ngày sinh: ".($studentProfile['ngay_sinh'] ?? 'chưa cập nhật')."\n"
        ."- Ngành: ".($studentProfile['nganh'] ?? 'chưa cập nhật')."\n"
        ."- Chuyên ngành: ".($studentProfile['chuyen_nganh'] ?? 'chưa cập nhật')."\n"
        ."- Khóa học: ".($studentProfile['khoa_hoc'] ?? 'chưa cập nhật')."\n"
        ."- Hệ đào tạo: ".($studentProfile['loai_hinh_dao_tao'] ?? 'chưa cập nhật');
}

$contextSections[] = "[LỊCH HỌC HÔM NAY - ".formatDateLabel($todayDate)."]\n".formatScheduleRows($todaySchedule, false);
$contextSections[] = "[LỊCH HỌC NGÀY MAI - ".$tomorrowLabel."]\n".formatScheduleRows($tomorrowSchedule, false);
if (!empty($allSchedule)) $contextSections[] = "[THỜI KHÓA BIỂU TUẦN]\n".formatScheduleRows($allSchedule, true);

if (!empty($grades)) {
    $lines = [];
    foreach ($grades as $g) {
        $lines[] = "- Môn {$g['subject_name']} ({$g['credits']}TC, {$g['term']}): Quá trình {$g['score_process']}, Thi {$g['score_final']}, Tổng {$g['score_total']} - {$g['status']}";
    }
    $contextSections[] = "[KẾT QUẢ HỌC TẬP]\n".implode("\n", $lines);
}

if ($tuition) {
    $contextSections[] = "[CÔNG NỢ & HỌC PHÍ]\n"
        ."- Học kỳ: {$tuition['term']}\n"
        ."- Tổng phải đóng: ".formatCurrencyVnd($tuition['total_amount'])."\n"
        ."- Đã đóng: ".formatCurrencyVnd($tuition['paid_amount'])."\n"
        ."- Còn nợ: ".formatCurrencyVnd($tuition['debt_amount'])."\n"
        ."- Link thanh toán: ".($tuition['payment_link'] ?? '');
}

if (!empty($curr)) {
    $lines = [];
    foreach (array_slice($curr, 0, 15) as $c) {
        $mand = !empty($c['is_mandatory']) ? 'Bắt buộc' : 'Tự chọn';
        $lines[] = "- Môn {$c['subject_name']} ({$c['credits']}TC, {$mand}). Tiên quyết: {$c['prerequisites']}";
    }
    $contextSections[] = "[CHƯƠNG TRÌNH KHUNG]\n".implode("\n", $lines);
}

if (!empty($systemNotifications)) {
    $lines = [];
    foreach (array_slice($systemNotifications, 0, 5) as $n) {
        $lines[] = "- ".($n['title'] ?? 'Thông báo').": ".trim((string)($n['content'] ?? ''));
    }
    $contextSections[] = "[THÔNG BÁO HỆ THỐNG]\n".implode("\n", $lines);
}

if (!empty($ticketNotifications)) {
    $lines = [];
    foreach ($ticketNotifications as $t) {
        $lines[] = "- ".($t['title'] ?? 'Phản hồi hỗ trợ').": ".trim((string)($t['admin_reply'] ?? ''));
    }
    $contextSections[] = "[PHẢN HỒI HỖ TRỢ CÁ NHÂN]\n".implode("\n", $lines);
}

if (!empty($results)) {
    $lines = [];
    foreach ($results as $row) {
        $lines[] = "- Chủ đề: {$row['topic_group']}. Trả lời: {$row['noi_dung']}";
    }
    $contextSections[] = "[THÔNG TIN DỊCH VỤ SINH VIÊN - RAG FAQ]\n".implode("\n", $lines);
}

$studentContextText = trim(implode("\n\n", $contextSections));
$hasContext = ($studentContextText !== '');

// ============================================================
// 7. GEMINI — HỆ THỐNG GIAO TIẾP (SYSTEM PROMPT MỚI)
// ============================================================
function callGemini(string $apiKey, string $userMsg, string $context, array $history, array $ctx): string {
    $apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key='.$apiKey;

    $name = $ctx['firstName']        ?? 'bạn';
    $full = $ctx['fullName']         ?? '';
    $mssv = $ctx['mssv']             ?? '';
    $today= $ctx['todayLabel']       ?? '';
    $tmr  = $ctx['tomorrowLabel']    ?? '';
    $tSch = $ctx['todayScheduleText']   ?? 'Không có dữ liệu.';
    $tDdl = $ctx['todayDeadlineText']   ?? 'Không có dữ liệu.';
    $sch  = $ctx['scheduleText']        ?? 'Không có dữ liệu.';
    $ddl  = $ctx['deadlineText']        ?? 'Không có dữ liệu.';

    if (empty($mssv)) {
        $mssvText = "Sinh viên CHƯA cung cấp MSSV.";
    } else {
        $mssvText = "MSSV của sinh viên: {$mssv}";
    }

    $systemPrompt = <<<PROMPT
Bạn là Agent AI - Trợ lý ảo hỗ trợ sinh viên của trường Đại học Giao thông Vận tải TP.HCM (UTH). Tên của bạn là "ChatBot UTH" hoặc "Trợ lý sinh viên UTH".
Nhiệm vụ của bạn là hỗ trợ tra cứu hồ sơ sinh viên, lịch học, thông báo, điểm, học phí và dịch vụ sinh viên DỰA TRÊN DUY NHẤT dữ liệu được cung cấp. KHÔNG TỰ BỊA ĐẶT THÔNG TIN.

THÔNG TIN HIỆN TẠI:
- Tên sinh viên: {$full} (gọi thân mật: {$name})
- {$mssvText}
- Hôm nay: {$today}. Lịch học: {$tSch}. Deadline: {$tDdl}
- Ngày mai: {$tmr}. Lịch học: {$sch}. Deadline: {$ddl}

NGỮ CẢNH TỪ CƠ SỞ DỮ LIỆU:
{$context}

QUY TẮC XỬ LÝ (BẮT BUỘC TUÂN THỦ):
1. Luôn xưng là "Trợ lý sinh viên UTH" hoặc "ChatBot UTH". Xưng hô thân thiện, lịch sự nhưng gần gũi với sinh viên.
2. NẾU CÓ DỮ LIỆU MSSV: Ưu tiên trả lời trực tiếp câu hỏi bằng NGỮ CẢNH TỪ CƠ SỞ DỮ LIỆU.
3. NẾU KHÔNG CÓ DỮ LIỆU MSSV: Bắt buộc yêu cầu sinh viên cung cấp Mã số sinh viên (MSSV) để tra cứu cá nhân.
4. Trả lời đầy đủ hơn một câu ngắn: mở đầu bằng kết luận, sau đó liệt kê 3-6 ý chính, cuối cùng thêm lưu ý/hành động tiếp theo nếu phù hợp.
5. HƯỚNG DẪN ĐÁP ỨNG TỪNG CHỨC NĂNG:
   - CHỨC NĂNG 1 (Lịch học): Liệt kê rõ ràng theo Thứ, Tên môn, Thời gian, Phòng học bằng danh sách (bullet points).
   - CHỨC NĂNG 2 (Kết quả học tập): Liệt kê danh sách môn kèm điểm số. Tính điểm trung bình nếu sinh viên yêu cầu.
   - CHỨC NĂNG 3 (Công nợ & Học phí): Báo rõ "Tổng phải đóng", "Đã đóng", "Còn nợ". Nếu còn nợ, cung cấp link thanh toán.
   - CHỨC NĂNG 4 (Chương trình khung & Đăng ký môn): Trích xuất các môn và chỉ rõ môn tiên quyết.
   - CHỨC NĂNG 5 (FAQ Dịch vụ sinh viên): Lấy câu trả lời mẫu từ dữ liệu FAQ để hướng dẫn các bước.
   - CHỨC NĂNG 6 (Thông báo): Tóm tắt thông báo/sự kiện mới, nêu thời gian nếu có, và nhắc sinh viên việc cần làm.
6. Sử dụng danh sách (bullet points) để thông tin dễ đọc, dễ nhìn trên màn hình chat. Không dùng bảng Markdown.

ĐỊNH DẠNG OUTPUT (JSON thuần, KHÔNG Markdown code block):
{"answer": "nội dung trả lời", "suggestions": ["Gợi ý 1?", "Gợi ý 2?", "Gợi ý 3?"]}
PROMPT;

    $contents = [];
    foreach (array_slice($history, -10) as $t) {
        $role = ($t['role'] ?? '') === 'user' ? 'user' : 'model';
        $txt  = trim($t['text'] ?? '');
        if ($txt !== '') $contents[] = ['role' => $role, 'parts' => [['text' => $txt]]];
    }
    $contents[] = ['role' => 'user', 'parts' => [['text' => $userMsg]]];

    $payload = [
        'systemInstruction' => ['role' => 'user', 'parts' => [['text' => $systemPrompt]]],
        'contents'          => $contents,
        'generationConfig'  => ['temperature' => 0.15, 'maxOutputTokens' => 1800],
    ];

    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_POSTFIELDS     => json_encode($payload, JSON_UNESCAPED_UNICODE),
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_TIMEOUT        => 25,
    ]);
    $res = curl_exec($ch);
    if ($res === false) throw new RuntimeException('Gemini network error: '.curl_error($ch));
    curl_close($ch);

    $d = json_decode($res, true);
    if (isset($d['error'])) throw new RuntimeException($d['error']['message'] ?? 'Gemini API error');

    return trim($d['candidates'][0]['content']['parts'][0]['text'] ?? '');
}

function parseGeminiJson(string $raw, string $fallback = ''): array {
    $raw = trim($raw);
    if ($raw === '') return ['answer' => $fallback, 'suggestions' => []];

    if (preg_match('/```(?:json)?\s*([\s\S]*?)```/i', $raw, $m)) $raw = trim($m[1]);

    if (preg_match('/\{[\s\S]*\}/u', $raw, $m)) {
        $dec = json_decode($m[0], true);
        if (is_array($dec) && isset($dec['answer']) && trim($dec['answer']) !== '') {
            return [
                'answer'      => trim($dec['answer']),
                'suggestions' => array_values(array_filter(
                    array_map('trim', (array)($dec['suggestions'] ?? [])),
                    fn($s) => $s !== ''
                )),
            ];
        }
    }

    if ($raw !== '') return ['answer' => $raw, 'suggestions' => []];

    return ['answer' => $fallback, 'suggestions' => []];
}

function jsonExit(string $reply, array $sugg = []): void {
    echo json_encode(['reply' => trim($reply), 'suggestions' => $sugg], JSON_UNESCAPED_UNICODE);
    exit;
}

$firstName    = $studentFirstName ?: ($studentName ?: 'bạn');
$cleanMsg     = normalizeText($userMessage);
$hasGeminiKey = isset($apiKey) && trim($apiKey) !== '' && $apiKey !== 'YOUR_GEMINI_API_KEY';

// ============================================================
// 8. SHORT-CIRCUIT: Chào hỏi
// ============================================================
$greetings  = ['xin chao','chao ban','chao','hi','hello','halo','chao bot','alo','chao em','chao thay','chao co','hey'];
$thanks     = ['cam on','thank you','thanks','thank','tks','cam on ban','da cam on','ok cam on','camon'];
$identities = ['ban la ai','ten la gi','ai day','bot la ai','ten cua ban la gi','gioi thieu','may la ai','con bot nay ten gi','bao bao la ai'];

if (in_array($cleanMsg, $greetings, true))
    jsonExit("Xin chào ".h($firstName)."! Mình là Trợ lý sinh viên UTH. Mình có thể tra cứu theo MSSV của bạn: lịch học, thông báo, điểm, học phí, chương trình khung và các dịch vụ sinh viên.", ['Cho xem lịch học tuần này','Có thông báo mới nào không?','Xem điểm tổng kết']);
if (in_array($cleanMsg, $thanks, true))
    jsonExit("Không có gì ".h($firstName)." ơi! Rất vui được hỗ trợ bạn. Chúc bạn học tập tốt.", ['Còn câu hỏi nào khác không?','Xem lịch học ngày mai?']);
if (in_array($cleanMsg, $identities, true))
    jsonExit("Mình là ChatBot UTH — Trợ lý sinh viên UTH. Bạn muốn mình tra cứu thông tin gì nào?", ['Học phí học kỳ này?','Điểm thi môn học?','Quy chế thi cử?']);

// ============================================================
// 9. GEMINI — XỬ LÝ CHÍNH
// ============================================================
$fmtToday    = formatScheduleContext($todaySchedule, $todayDeadlines);
$fmtTomorrow = formatScheduleContext($tomorrowSchedule, $tomorrowDeadlines);
$studentCtx  = [
    'fullName'          => $studentName,
    'firstName'         => $firstName,
    'mssv'              => $mssv,
    'todayLabel'        => $todayLabel,
    'tomorrowLabel'     => $tomorrowLabel,
    'todayScheduleText' => $fmtToday['scheduleText'],
    'todayDeadlineText' => $fmtToday['deadlineText'],
    'scheduleText'      => $fmtTomorrow['scheduleText'],
    'deadlineText'      => $fmtTomorrow['deadlineText'],
];

$botReply   = '';
$botSuggest = [];

if ($hasGeminiKey) {
    try {
        $raw = callGemini($apiKey, $userMessage, $studentContextText, $chatHistory, $studentCtx);
        if ($raw !== '') {
            $fallbackText = !empty($results) ? formatFaqReply($results[0], $firstName, $userMessage) : '';
            $p            = parseGeminiJson($raw, $fallbackText);
            $botReply     = renderAiAnswer($p['answer']);
            $botSuggest   = array_slice($p['suggestions'], 0, 4);
        }
    } catch (Throwable $e) {
        error_log('Gemini main: '.$e->getMessage());
    }
}

// Fallback khi Gemini lỗi/chưa cấu hình: ưu tiên dữ liệu cá nhân, sau đó mới dùng FAQ RAG.
if ($botReply === '') {
    $scheduleIntent = isScheduleIntent($cleanMsg);

    if (isNotificationIntent($cleanMsg)) {
        $direct = buildNotificationReply($firstName, $systemNotifications, $ticketNotifications);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if ($scheduleIntent === 'today') {
        $direct = buildScheduleReply($firstName, 'Hôm nay ('.$todayLabel.')', $todaySchedule, $todayDeadlines);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if ($scheduleIntent === 'tomorrow') {
        $direct = buildScheduleReply($firstName, 'Ngày mai ('.$tomorrowLabel.')', $tomorrowSchedule, $tomorrowDeadlines);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if ($scheduleIntent === 'week') {
        $direct = buildWeekScheduleReply($firstName, $allSchedule ?: array_merge($todaySchedule, $tomorrowSchedule));
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if ($scheduleIntent === 'deadline') {
        $deadlineText = trim(formatDeadlineRows(array_merge($todayDeadlines, $tomorrowDeadlines)));
        $reply = "Chào ".h($firstName).", hiện dữ liệu deadline mình nhận được là:<br><br>".nl2br(h($deadlineText))."<br><br>Nếu lớp của bạn có bài tập trên hệ thống khác, bạn nên kiểm tra thêm LMS hoặc thông báo từ giảng viên.";
        jsonExit($reply, ['Hôm nay mình học gì?','Ngày mai mình có lịch học gì?','Có thông báo mới nào không?']);
    }

    if (isGradeIntent($cleanMsg)) {
        $subjectGrade = buildSubjectGradeReply($firstName, $userMessage, $grades);
        if ($subjectGrade !== null) {
            jsonExit($subjectGrade['reply'], $subjectGrade['suggestions']);
        }
        $direct = buildGradesReply($firstName, $grades);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if (isTuitionIntent($cleanMsg)) {
        $direct = buildTuitionReply($firstName, $tuition);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if (isProfileIntent($cleanMsg)) {
        $direct = buildProfileReply($firstName, $studentProfile, $mssv);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if (isCurriculumIntent($cleanMsg)) {
        $direct = buildCurriculumReply($firstName, $curr);
        jsonExit($direct['reply'], $direct['suggestions']);
    }

    if (!empty($results)) {
        $botReply = formatFaqReply($results[0], $firstName, $userMessage);
        $botSuggest = faqSuggestions($results[0]);
    } else {
        if (shouldCreateTicket($userMessage, $cleanMsg)) {
            createSupportTicket($pdo, $userMessage, $studentName, $mssv);
            jsonExit("Xin lỗi ".h($firstName).", mình chưa tìm thấy dữ liệu đủ chắc chắn để trả lời câu này. Mình đã chuyển phiếu hỗ trợ đến Ban quản trị để kiểm tra thêm.", ['Cho tôi xem lịch học tuần này','Có thông báo mới nào không?']);
        }
        jsonExit("Mình chưa có dữ liệu chắc chắn cho câu này, ".h($firstName)." ơi. Bạn có thể hỏi cụ thể hơn về lịch học, thông báo, điểm, học phí hoặc dịch vụ sinh viên để mình tra cứu đúng nguồn.", ['Cho tôi xem lịch học tuần này','Có thông báo mới nào không?','Tôi còn nợ học phí không?']);
    }
}

jsonExit($botReply, $botSuggest);

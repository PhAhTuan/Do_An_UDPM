// ============================================================
// 6. DB FETCH (Điểm, Học phí, Chương trình khung, FAQ)
// ============================================================
$studentContextText = "";
$pdo = null;
try {
    include_once __DIR__.'/config.php';
    require_once __DIR__.'/faq_helpers.php';
    $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    
    // 6.1. FAQ RAG
    $faqSchema = faqColumnSchema($pdo);
    $searchQ   = buildContextualQuery($userMessage, $chatHistory);
    $results   = findRelevantFaqs($pdo, $faqSchema, $searchQ);
    if (!empty($results)) {
        $studentContextText .= "\\n[THÔNG TIN DỊCH VỤ SINH VIÊN (FAQ)]\\n";
        foreach ($results as $row) {
            $studentContextText .= "- Chủ đề: {$row['topic_group']}. Trả lời: {$row['noi_dung']}\\n";
        }
    }

    if (!empty($mssv)) {
        // 6.2. Điểm số (Kết quả học tập)
        $stmt = $pdo->prepare("SELECT * FROM student_grades WHERE mssv = ?");
        $stmt->execute([$mssv]);
        $grades = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!empty($grades)) {
            $studentContextText .= "\\n[KẾT QUẢ HỌC TẬP]\\n";
            foreach ($grades as $g) {
                $studentContextText .= "- Môn {$g['subject_name']} ({$g['credits']}TC): Quá trình: {$g['score_process']}, Thi: {$g['score_final']}, Tổng: {$g['score_total']} -> {$g['status']}\\n";
            }
        }

        // 6.3. Công nợ (Tuition)
        $stmt = $pdo->prepare("SELECT * FROM student_tuition WHERE mssv = ? ORDER BY id DESC LIMIT 1");
        $stmt->execute([$mssv]);
        $tuition = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($tuition) {
            $studentContextText .= "\\n[CÔNG NỢ & HỌC PHÍ]\\n";
            $studentContextText .= "- Học kỳ: {$tuition['term']}\\n";
            $studentContextText .= "- Tổng phải đóng: ".number_format($tuition['total_amount'])." VNĐ\\n";
            $studentContextText .= "- Đã đóng: ".number_format($tuition['paid_amount'])." VNĐ\\n";
            $studentContextText .= "- Còn nợ: ".number_format($tuition['debt_amount'])." VNĐ\\n";
            $studentContextText .= "- Link thanh toán: {$tuition['payment_link']}\\n";
        }

        // 6.4. Chương trình khung (Lấy mẫu các môn CNTT)
        // Trong thực tế sẽ map với Ngành của Sinh viên, ở đây lấy cứng mẫu
        $stmt = $pdo->prepare("SELECT * FROM curriculum_subjects LIMIT 20");
        $stmt->execute();
        $curr = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if (!empty($curr)) {
            $studentContextText .= "\\n[CHƯƠNG TRÌNH KHUNG]\\n";
            foreach ($curr as $c) {
                $mand = $c['is_mandatory'] ? 'Bắt buộc' : 'Tự chọn';
                $studentContextText .= "- Môn {$c['subject_name']} ({$c['credits']}TC, {$mand}). Tiên quyết: {$c['prerequisites']}\\n";
            }
        }
    }
} catch (Throwable $e) {
    error_log('DB Context Fetch Error: '.$e->getMessage());
}

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
    $sch  = $ctx['scheduleText']        ?? 'Không có dữ liệu.';

    if (empty($mssv)) {
        $mssvText = "Sinh viên CHƯA cung cấp MSSV.";
    } else {
        $mssvText = "MSSV của sinh viên: {$mssv}";
    }

    $systemPrompt = <<<PROMPT
Bạn là Agent AI - Trợ lý ảo hỗ trợ sinh viên của trường Đại học Giao thông Vận tải TP.HCM (UTH). Tên của bạn là "Bảo Bảo" hoặc "Trợ lý sinh viên UTH".
Nhiệm vụ của bạn là hỗ trợ tra cứu thông tin học vụ, lịch học, học phí và các dịch vụ sinh viên DỰA TRÊN DUY NHẤT dữ liệu được cung cấp. KHÔNG TỰ BỊA ĐẶT THÔNG TIN.

THÔNG TIN HIỆN TẠI:
- Tên sinh viên: {$full} (gọi thân mật: {$name})
- {$mssvText}
- Hôm nay: {$today}. Lịch học: {$tSch}
- Ngày mai: {$tmr}. Lịch học: {$sch}

NGỮ CẢNH TỪ CƠ SỞ DỮ LIỆU:
{$context}

QUY TẮC XỬ LÝ (BẮT BUỘC TUÂN THỦ):
1. Luôn xưng là "Trợ lý sinh viên UTH" hoặc "Bảo Bảo". Xưng hô thân thiện, lịch sự nhưng gần gũi với sinh viên.
2. NẾU CÓ DỮ LIỆU MSSV: Ưu tiên trả lời trực tiếp câu hỏi bằng NGỮ CẢNH TỪ CƠ SỞ DỮ LIỆU.
3. NẾU KHÔNG CÓ DỮ LIỆU MSSV: Bắt buộc yêu cầu sinh viên cung cấp Mã số sinh viên (MSSV) để tra cứu cá nhân.
4. HƯỚNG DẪN ĐÁP ỨNG TỪNG CHỨC NĂNG:
   - CHỨC NĂNG 1 (Lịch học): Liệt kê rõ ràng theo Thứ, Tên môn, Thời gian, Phòng học bằng danh sách (bullet points).
   - CHỨC NĂNG 2 (Kết quả học tập): Liệt kê danh sách môn kèm điểm số. Tính điểm trung bình nếu sinh viên yêu cầu.
   - CHỨC NĂNG 3 (Công nợ & Học phí): Báo rõ "Tổng phải đóng", "Đã đóng", "Còn nợ". Nếu còn nợ, cung cấp link thanh toán.
   - CHỨC NĂNG 4 (Chương trình khung & Đăng ký môn): Trích xuất các môn và chỉ rõ môn tiên quyết.
   - CHỨC NĂNG 5 (FAQ Dịch vụ sinh viên): Lấy câu trả lời mẫu từ dữ liệu FAQ để hướng dẫn các bước.
5. Sử dụng danh sách (bullet points) để thông tin dễ đọc, dễ nhìn trên màn hình chat.

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
        'generationConfig'  => ['temperature' => 0.1, 'maxOutputTokens' => 800],
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
    jsonExit("Xin chào {$firstName}! 👋 Mình là Trợ lý sinh viên UTH. Hôm nay bạn cần hỗ trợ về điểm số, công nợ hay lịch học nào?", ['Cho xem lịch học tuần này','Tra cứu công nợ','Xem điểm tổng kết']);
if (in_array($cleanMsg, $thanks, true))
    jsonExit("Không có gì {$firstName} ơi! 😊 Rất vui được hỗ trợ bạn. Chúc học tập tốt!", ['Còn câu hỏi nào khác không?','Xem lịch học ngày mai?']);
if (in_array($cleanMsg, $identities, true))
    jsonExit("Mình là Bảo Bảo — Trợ lý sinh viên UTH. Bạn muốn mình tra cứu thông tin gì nào?", ['Học phí học kỳ này?','Điểm thi môn học?','Quy chế thi cử?']);

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
            $fallbackText = $hasContext ? formatFaqReply($results[0]) : '';
            $p            = parseGeminiJson($raw, $fallbackText);
            $botReply     = $p['answer'];
            $botSuggest   = $p['suggestions'];
        }
    } catch (Throwable $e) {
        error_log('Gemini main: '.$e->getMessage());
    }
}

// Fallback khi Gemini lỗi
if ($botReply === '') {
    if ($hasContext && !empty($results)) {
        $botReply = formatFaqReply($results[0]);
    } else {
        createSupportTicket($pdo, $userMessage);
        jsonExit("Xin lỗi {$firstName}, hệ thống không tìm thấy dữ liệu. Mình đã chuyển phiếu hỗ trợ đến Ban quản trị! 📩", []);
    }
}

jsonExit($botReply, $botSuggest);

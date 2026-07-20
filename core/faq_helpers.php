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

function dbFetchAll(PDO $pdo, string $sql, array $params = []): array {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

function dbFetchOne(PDO $pdo, string $sql, array $params = []): ?array {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row === false ? null : $row;
}

function dbFetchValue(PDO $pdo, string $sql, array $params = []) {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetchColumn();
}

function dbExecute(PDO $pdo, string $sql, array $params = []): int {
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->rowCount();
}

function appStripAccents(string $s): string {
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

/**
 * Từ điển viết tắt / từ lóng phổ biến của sinh viên đại học Việt Nam.
 * Key phải viết thường, KHÔNG dấu-hoặc-có-dấu tùy trường hợp thực tế các bạn hay gõ.
 * Value là cụm từ đầy đủ, có dấu, để sau đó pipeline chuẩn hóa (bỏ dấu, hạ chữ thường)
 * tiếp tục xử lý như bình thường.
 *
 * Lưu ý: việc khớp từ được thực hiện theo TỪ NGUYÊN VẸN (word boundary bằng khoảng trắng),
 * nên các từ ngắn như 'k', 'vs', 'tc' chỉ được thay khi đứng riêng lẻ, không thay
 * khi là một phần của từ/chuỗi khác (vd "10k" sẽ không bị đụng vào vì không có khoảng trắng
 * tách "10" và "k").
 */
function appSlangDictionary(): array {
    return [
        // Học phí / học vụ
        'hp'        => 'học phí',
        'hphi'      => 'học phí',
        'dkhp'      => 'đăng ký học phần',
        'đkhp'      => 'đăng ký học phần',
        'dkmh'      => 'đăng ký môn học',
        'đkmh'      => 'đăng ký môn học',
        'tkb'       => 'thời khóa biểu',
        'tc'        => 'tín chỉ',
        'gk'        => 'giữa kỳ',
        'ck'        => 'cuối kỳ',
        'mssv'      => 'mã số sinh viên',
        // Đơn vị / phòng ban
        'ktx'       => 'ký túc xá',
        'pdt'       => 'phòng đào tạo',
        'pđt'       => 'phòng đào tạo',
        'ptckt'     => 'phòng tài chính kế toán',
        'ctsv'      => 'công tác sinh viên',
        'gvcn'      => 'giáo viên chủ nhiệm',
        'gvhd'      => 'giáo viên hướng dẫn',
        'cvht'      => 'cố vấn học tập',
        // Nghiên cứu / khóa luận / thực tập
        'nckh'      => 'nghiên cứu khoa học',
        'tttn'      => 'thực tập tốt nghiệp',
        'datn'      => 'đồ án tốt nghiệp',
        'đatn'      => 'đồ án tốt nghiệp',
        'dacn'      => 'đồ án chuyên ngành',
        'đacn'      => 'đồ án chuyên ngành',
        // Giấy tờ / thủ tục khác
        'bhyt'      => 'bảo hiểm y tế',
        'ttsv'      => 'thẻ sinh viên',
        'gdqp'      => 'giáo dục quốc phòng',
        // Kết quả học tập (cụm từ, không chỉ 1 từ)
        'rớt môn'   => 'thi trượt môn học',
        'rot mon'   => 'thi trượt môn học',
        'cải thiện' => 'học cải thiện điểm số',
        'cai thien' => 'học cải thiện điểm số',
        'no mon'    => 'nợ môn học',
        'nợ môn'    => 'nợ môn học',
        // Viết tắt chat chung (rất phổ biến khi sinh viên nhắn tin)
        'sv'        => 'sinh viên',
        'gv'        => 'giảng viên',
        'dh'        => 'đại học',
        'đh'        => 'đại học',
        'ntn'       => 'như thế nào',
        'vs'        => 'với',
        'k'         => 'không',
        'ko'        => 'không',
        'đc'        => 'được',
        'dc'        => 'được',
    ];
}

/**
 * Dịch nhanh từ viết tắt/từ lóng sinh viên sang từ gốc trước khi chuẩn hóa chuỗi,
 * để AI/RAG hiểu đúng ý ngay cả khi sinh viên gõ tắt.
 */
function appExpandSlang(string $value): string {
    $padded = ' ' . $value . ' ';
    foreach (appSlangDictionary() as $abbr => $full) {
        $padded = str_replace(' ' . $abbr . ' ', ' ' . $full . ' ', $padded);
    }
    return trim($padded);
}

function appNormalizeText(string $value): string {
    $value = appExpandSlang(mb_strtolower($value, 'UTF-8'));
    $value = mb_strtolower(appStripAccents($value), 'UTF-8');
    $value = preg_replace('/[^a-z0-9]+/u', ' ', $value);
    return trim(preg_replace('/\s+/u', ' ', $value));
}

function appContainsAny(string $normalized, array $phrases): bool {
    $haystack = ' '.$normalized.' ';
    foreach ($phrases as $phrase) {
        $needle = appNormalizeText($phrase);
        if ($needle !== '' && mb_strpos($haystack, ' '.$needle.' ', 0, 'UTF-8') !== false) {
            return true;
        }
    }
    return false;
}

function appDateOrNull(?string $value): ?string {
    $value = trim((string)$value);
    return $value === '' ? null : $value;
}

function appExtractYear(?string $value): ?int {
    if (preg_match('/(20\d{2})/', (string)$value, $m)) {
        return (int)$m[1];
    }
    return null;
}

function appGenderToDb(?string $value): ?string {
    $norm = appNormalizeText((string)$value);
    if ($norm === 'nam' || $norm === 'male') return 'male';
    if ($norm === 'nu' || $norm === 'female') return 'female';
    if ($norm === 'khac' || $norm === 'other') return 'other';
    return null;
}

function appGenderLabel(?string $value): string {
    return match ($value) {
        'male' => 'Nam',
        'female' => 'Nữ',
        'other' => 'Khác',
        default => '',
    };
}

function appDegreeToDb(?string $value): string {
    $norm = appNormalizeText((string)$value);
    if (str_contains($norm, 'cao dang')) return 'college';
    if (str_contains($norm, 'thac')) return 'master';
    if (str_contains($norm, 'tien si') || str_contains($norm, 'doctor')) return 'doctorate';
    if (str_contains($norm, 'ky su')) return 'engineer';
    return 'bachelor';
}

function appDegreeLabel(?string $value): string {
    return match ($value) {
        'college' => 'Cao đẳng',
        'engineer' => 'Kỹ sư',
        'master' => 'Thạc sĩ',
        'doctorate' => 'Tiến sĩ',
        default => 'Đại học',
    };
}

function appUuidV4(): string {
    $data = random_bytes(16);
    $data[6] = chr((ord($data[6]) & 0x0f) | 0x40);
    $data[8] = chr((ord($data[8]) & 0x3f) | 0x80);
    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

function appSystemSetting(PDO $pdo, string $key, $default = null) {
    $json = dbFetchValue($pdo, 'SELECT setting_value FROM system_settings WHERE setting_key = ? LIMIT 1', [$key]);
    if ($json === false || $json === null) {
        return $default;
    }
    $data = json_decode((string)$json, true);
    if (!is_array($data)) {
        return $default;
    }
    if (array_key_exists('value', $data)) {
        return $data['value'];
    }
    if (array_key_exists('vi', $data)) {
        return $data['vi'];
    }
    return $data ?: $default;
}

function appRoleId(PDO $pdo, string $code): int {
    $id = dbFetchValue($pdo, 'SELECT id FROM roles WHERE code = ? LIMIT 1', [$code]);
    if (!$id) {
        throw new RuntimeException('Không tìm thấy role: '.$code);
    }
    return (int)$id;
}

function appFindUserForLogin(PDO $pdo, string $username): ?array {
    return dbFetchOne($pdo, "
        SELECT
            u.id, u.username, u.password_hash, u.full_name, u.avatar_url, u.status,
            r.code AS role_code,
            sp.id AS student_id,
            sp.student_code
        FROM users u
        JOIN roles r ON r.id = u.role_id
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        WHERE u.username = ? AND u.deleted_at IS NULL
        LIMIT 1
    ", [$username]);
}

function appProgramCode(string $name, string $specialization, string $degree, string $educationType): string {
    $base = appNormalizeText($name.' '.$specialization.' '.$degree.' '.$educationType);
    return 'PG'.strtoupper(substr(sha1($base !== '' ? $base : 'uth-program'), 0, 10));
}

function appFindOrCreateProgram(PDO $pdo, string $name, string $specialization = '', string $degreeLabel = '', string $educationType = ''): ?int {
    $name = trim($name);
    if ($name === '') {
        return null;
    }

    $degree = appDegreeToDb($degreeLabel);
    $existing = dbFetchOne($pdo, "
        SELECT id
        FROM programs
        WHERE name = ?
          AND COALESCE(specialization, '') = ?
          AND degree_level = ?
          AND COALESCE(education_type, '') = ?
        LIMIT 1
    ", [$name, trim($specialization), $degree, trim($educationType)]);

    if ($existing) {
        return (int)$existing['id'];
    }

    $code = appProgramCode($name, $specialization, $degree, $educationType);
    dbExecute($pdo, "
        INSERT INTO programs (code, name, degree_level, education_type, specialization, status)
        VALUES (?, ?, ?, ?, ?, 'active')
    ", [$code, $name, $degree, trim($educationType) ?: null, trim($specialization) ?: null]);

    return (int)$pdo->lastInsertId();
}

function appDecorateStudentRow(array $row): array {
    $row['mssv'] = $row['student_code'] ?? $row['username'] ?? '';
    $row['gioi_tinh'] = appGenderLabel($row['gender'] ?? null);
    $row['bac_dao_tao'] = appDegreeLabel($row['degree_level'] ?? null);
    $row['khoa_hoc'] = !empty($row['cohort_year']) ? 'Khóa '.$row['cohort_year'] : '';
    $row['ngay_sinh'] = $row['date_of_birth'] ?? '';
    $row['noi_sinh'] = $row['place_of_birth'] ?? '';
    $row['nganh'] = $row['program_name'] ?? '';
    $row['chuyen_nganh'] = $row['specialization'] ?? '';
    $row['loai_hinh_dao_tao'] = $row['education_type'] ?? '';
    $row['ho_ten'] = $row['full_name'] ?? '';
    $row['avatar'] = $row['avatar_url'] ?? '';
    return $row;
}

function appStudentByUserId(PDO $pdo, int $userId): ?array {
    $row = dbFetchOne($pdo, "
        SELECT
            u.id AS user_id, u.username, u.full_name, u.avatar_url, u.status,
            sp.id AS student_id, sp.student_code, sp.cohort_year, sp.class_code,
            sp.date_of_birth, sp.gender, sp.place_of_birth, sp.academic_status,
            p.id AS program_id, p.code AS program_code, p.name AS program_name,
            p.degree_level, p.education_type, p.specialization, p.total_credits,
            f.name AS faculty_name
        FROM users u
        JOIN student_profiles sp ON sp.user_id = u.id
        LEFT JOIN programs p ON p.id = sp.program_id
        LEFT JOIN faculties f ON f.id = p.faculty_id
        WHERE u.id = ? AND u.deleted_at IS NULL
        LIMIT 1
    ", [$userId]);

    return $row ? appDecorateStudentRow($row) : null;
}

function appStudentByCode(PDO $pdo, string $studentCode): ?array {
    $row = dbFetchOne($pdo, "
        SELECT
            u.id AS user_id, u.username, u.full_name, u.avatar_url, u.status,
            sp.id AS student_id, sp.student_code, sp.cohort_year, sp.class_code,
            sp.date_of_birth, sp.gender, sp.place_of_birth, sp.academic_status,
            p.id AS program_id, p.code AS program_code, p.name AS program_name,
            p.degree_level, p.education_type, p.specialization, p.total_credits,
            f.name AS faculty_name
        FROM student_profiles sp
        JOIN users u ON u.id = sp.user_id
        LEFT JOIN programs p ON p.id = sp.program_id
        LEFT JOIN faculties f ON f.id = p.faculty_id
        WHERE sp.student_code = ? AND u.deleted_at IS NULL
        LIMIT 1
    ", [$studentCode]);

    return $row ? appDecorateStudentRow($row) : null;
}

function appSafeStudentList(PDO $pdo): array {
    $rows = dbFetchAll($pdo, "
        SELECT
            u.id AS user_id, u.username, u.full_name, u.avatar_url, u.status, u.created_at,
            sp.id AS student_id, sp.student_code, sp.cohort_year, sp.class_code,
            sp.date_of_birth, sp.gender, sp.place_of_birth, sp.academic_status,
            p.id AS program_id, p.name AS program_name, p.degree_level, p.education_type, p.specialization, p.total_credits
        FROM users u
        JOIN roles r ON r.id = u.role_id AND r.code = 'student'
        LEFT JOIN student_profiles sp ON sp.user_id = u.id
        LEFT JOIN programs p ON p.id = sp.program_id
        WHERE u.deleted_at IS NULL
        ORDER BY u.created_at DESC
    ");

    return array_map('appDecorateStudentRow', $rows);
}

function appEnsureChatSession(PDO $pdo, ?string $sessionUuid, ?int $userId, string $title = 'Trò chuyện UTH'): array {
    if ($userId !== null) {
        $userExists = dbFetchValue($pdo, 'SELECT id FROM users WHERE id = ?', [$userId]);
        if (!$userExists) {
            $userId = null;
        }
    }

    if ($sessionUuid && preg_match('/^[0-9a-fA-F-]{36}$/', $sessionUuid)) {
        $existing = dbFetchOne($pdo, 'SELECT * FROM chat_sessions WHERE session_uuid = ? LIMIT 1', [$sessionUuid]);
        if ($existing) {
            $existingUserId = $existing['user_id'] !== null ? (int)$existing['user_id'] : null;
            if ($userId !== null && $existingUserId !== null && $existingUserId !== $userId) {
                $existing = null;
            } elseif ($userId === null && $existingUserId !== null) {
                $existing = null;
            } else {
                if ($userId !== null && $existingUserId === null) {
                    dbExecute($pdo, 'UPDATE chat_sessions SET user_id = ? WHERE id = ?', [$userId, (int)$existing['id']]);
                    $existing['user_id'] = $userId;
                }
                dbExecute($pdo, 'UPDATE chat_sessions SET last_activity_at = NOW() WHERE id = ?', [(int)$existing['id']]);
                return $existing;
            }
        }
    }

    $uuid = appUuidV4();
    dbExecute($pdo, "
        INSERT INTO chat_sessions (session_uuid, user_id, title, channel, status)
        VALUES (?, ?, ?, 'web', 'active')
    ", [$uuid, $userId, mb_substr($title, 0, 255, 'UTF-8')]);

    return dbFetchOne($pdo, 'SELECT * FROM chat_sessions WHERE id = ? LIMIT 1', [(int)$pdo->lastInsertId()]);
}

function appLogChatMessage(
    PDO $pdo,
    int $sessionId,
    ?int $parentMessageId,
    string $senderType,
    string $content,
    ?string $intent = null,
    ?array $entities = null,
    ?string $modelName = null,
    ?float $confidence = null,
    string $answerStatus = 'ok',
    ?int $latencyMs = null
): int {
    dbExecute($pdo, "
        INSERT INTO chat_messages (
            session_id, parent_message_id, sender_type, content, normalized_content,
            detected_intent, extracted_entities, model_name, latency_ms,
            confidence_score, answer_status
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ", [
        $sessionId,
        $parentMessageId,
        $senderType,
        $content,
        appNormalizeText($content),
        $intent,
        $entities ? json_encode($entities, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) : null,
        $modelName,
        $latencyMs,
        $confidence,
        $answerStatus,
    ]);

    return (int)$pdo->lastInsertId();
}

function appLogUnanswered(PDO $pdo, ?int $userMessageId, string $question, ?string $intent): void {
    $normalized = appNormalizeText($question);
    if ($normalized === '') {
        return;
    }

    $existing = dbFetchOne($pdo, "
        SELECT id
        FROM unanswered_questions
        WHERE normalized_question = ?
          AND COALESCE(detected_intent, '') = COALESCE(?, '')
          AND status IN ('new', 'reviewing')
        LIMIT 1
    ", [$normalized, $intent]);

    if ($existing) {
        dbExecute($pdo, "
            UPDATE unanswered_questions
            SET occurrence_count = occurrence_count + 1,
                user_message_id = COALESCE(?, user_message_id),
                last_seen_at = NOW()
            WHERE id = ?
        ", [$userMessageId, (int)$existing['id']]);
        return;
    }

    dbExecute($pdo, "
        INSERT INTO unanswered_questions (user_message_id, normalized_question, detected_intent)
        VALUES (?, ?, ?)
    ", [$userMessageId, $normalized, $intent]);
}

function appTicketNumber(): string {
    return 'TK'.date('YmdHis').random_int(100, 999);
}

function appCreateSupportTicket(PDO $pdo, ?array $student, string $subject, string $description, ?int $chatSessionId = null): int {
    $studentId = isset($student['student_id']) ? (int)$student['student_id'] : null;
    $name = trim((string)($student['ho_ten'] ?? $student['full_name'] ?? 'Khách truy cập'));
    $code = trim((string)($student['mssv'] ?? $student['student_code'] ?? ''));

    dbExecute($pdo, "
        INSERT INTO tickets (
            ticket_number, student_id, requester_name, requester_student_code,
            category, subject, description, priority, status, source_chat_session_id
        )
        VALUES (?, ?, ?, ?, 'chatbot', ?, ?, 'normal', 'open', ?)
    ", [appTicketNumber(), $studentId, $name ?: 'Khách truy cập', $code ?: null, $subject, $description, $chatSessionId]);

    return (int)$pdo->lastInsertId();
}

function appEnsureRagViewShape(PDO $pdo): void {
    static $done = false;
    if ($done) {
        return;
    }

    dbExecute($pdo, "
        CREATE OR REPLACE VIEW v_active_verified_knowledge AS
        SELECT
            ka.id,
            ka.title,
            ka.category,
            ka.subcategory,
            ka.intent_code,
            ka.keywords,
            ka.answer_content,
            ka.route_url,
            ka.audience,
            ka.faculty_id,
            ka.program_id,
            ka.cohort_from,
            ka.cohort_to,
            ka.semester_code,
            ka.academic_year_code,
            ka.valid_from,
            ka.valid_until,
            ka.priority,
            ka.confidence_level,
            ks.title AS source_title,
            ks.source_url,
            ks.document_number,
            ks.issued_date
        FROM knowledge_articles ka
        LEFT JOIN knowledge_sources ks ON ks.id = ka.source_id
        WHERE ka.verification_status = 'verified'
          AND ka.deleted_at IS NULL
          AND (ka.valid_from IS NULL OR ka.valid_from <= NOW())
          AND (ka.valid_until IS NULL OR ka.valid_until >= NOW())
          AND (ks.id IS NULL OR ks.status = 'active')
    ");

    $done = true;
}

/**
 * Phát hiện schema thực tế của bảng faq (hỗ trợ nhiều tên cột).
 * Phiên bản nâng cấp: nhận diện thêm cột variations và priority.
 */
function faqColumnSchema(PDO $pdo): array {
    $rows = dbFetchAll($pdo, "SHOW COLUMNS FROM faq");
    $columns = array_column($rows, 'Field');

    if (in_array('keywords', $columns, true) && in_array('answer', $columns, true)) {
        return [
            'keyword'    => 'keywords',
            'answer'     => 'answer',
            'link'       => in_array('nav_link',     $columns, true) ? 'nav_link'     : null,
            'topic'      => in_array('topic_group',  $columns, true) ? 'topic_group'  : null,
            'stt'        => in_array('stt',           $columns, true),
            'variations' => in_array('variations',    $columns, true) ? 'variations'   : null,
            'priority'   => in_array('priority',      $columns, true) ? 'priority'     : null,
        ];
    }

    if (in_array('tu_khoa', $columns, true) && in_array('noi_dung', $columns, true)) {
        return [
            'keyword'    => 'tu_khoa',
            'answer'     => 'noi_dung',
            'link'       => in_array('link_dieu_huong', $columns, true) ? 'link_dieu_huong' : null,
            'topic'      => in_array('topic_group',     $columns, true) ? 'topic_group'     : null,
            'stt'        => in_array('stt',              $columns, true),
            'variations' => in_array('variations',       $columns, true) ? 'variations'      : null,
            'priority'   => in_array('priority',         $columns, true) ? 'priority'        : null,
        ];
    }

    throw new RuntimeException('Bảng faq thiếu cột câu hỏi/câu trả lời hợp lệ.');
}

function quoteIdentifier(string $identifier): string {
    return '`' . str_replace('`', '``', $identifier) . '`';
}

function faqSelectSql(array $schema, string $orderBy = 'priority DESC, id DESC'): string {
    $keyword    = quoteIdentifier($schema['keyword']) . ' AS tu_khoa';
    $answer     = quoteIdentifier($schema['answer'])  . ' AS noi_dung';
    $link       = $schema['link']       ? quoteIdentifier($schema['link'])       . ' AS link_dieu_huong' : "'' AS link_dieu_huong";
    $topic      = $schema['topic']      ? quoteIdentifier($schema['topic'])      . ' AS topic_group'     : "'' AS topic_group";
    $variations = $schema['variations'] ? quoteIdentifier($schema['variations']) . ' AS variations'      : "'' AS variations";
    $priority   = $schema['priority']   ? quoteIdentifier($schema['priority'])   . ' AS priority'        : "0 AS priority";

    // Nếu bảng chưa có cột priority (schema cũ) thì không thể ORDER BY priority thật,
    // fallback về id DESC để tránh lỗi SQL "Unknown column".
    if (!$schema['priority'] && stripos($orderBy, 'priority') !== false) {
        $orderBy = 'id DESC';
    }

    return "SELECT id, {$topic}, {$keyword}, {$answer}, {$link}, {$variations}, {$priority} FROM faq ORDER BY {$orderBy}";
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

    if ($schema['variations']) {
        $columns[] = quoteIdentifier($schema['variations']);
        $values[]  = '?';
    }

    if ($schema['priority']) {
        $columns[] = quoteIdentifier($schema['priority']);
        $values[]  = '?';
    }

    return 'INSERT INTO faq (' . implode(', ', $columns) . ') VALUES (' . implode(', ', $values) . ')';
}

function faqUpdateSql(array $schema): string {
    $sets = [];
    if ($schema['topic'])      $sets[] = quoteIdentifier($schema['topic'])      . ' = ?';
    $sets[] = quoteIdentifier($schema['keyword']) . ' = ?';
    $sets[] = quoteIdentifier($schema['answer'])  . ' = ?';
    if ($schema['link'])       $sets[] = quoteIdentifier($schema['link'])       . ' = ?';
    if ($schema['variations']) $sets[] = quoteIdentifier($schema['variations']) . ' = ?';
    if ($schema['priority'])   $sets[] = quoteIdentifier($schema['priority'])   . ' = ?';
    return 'UPDATE faq SET ' . implode(', ', $sets) . ' WHERE id = ?';
}

/**
 * @param string $variations Các cách hỏi khác nhau cho cùng 1 câu trả lời, mỗi cách hỏi 1 dòng.
 * @param int    $priority   Trọng số ưu tiên, số càng lớn càng được ưu tiên hiển thị/tìm kiếm trước.
 */
function faqFormParams(
    array $schema,
    string $topic,
    string $keyword,
    string $answer,
    string $link = '',
    string $variations = '',
    int $priority = 0
): array {
    $params = [];
    if ($schema['topic']) $params[] = trim($topic) !== '' ? trim($topic) : 'Chưa phân loại';
    $params[] = $keyword;
    $params[] = $answer;
    if ($schema['link'])       $params[] = $link;
    if ($schema['variations']) $params[] = trim($variations) !== '' ? trim($variations) : null;
    if ($schema['priority'])   $params[] = $priority;
    return $params;
}

function ensureFaqKnowledgeTable(PDO $pdo): void {
    dbExecute($pdo, "
        CREATE TABLE IF NOT EXISTS `faq` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `topic_group` VARCHAR(255) DEFAULT NULL COMMENT 'Nhom chu de',
            `tu_khoa` TEXT NOT NULL COMMENT 'Cau hoi / tu khoa sinh vien hay go',
            `noi_dung` TEXT NOT NULL COMMENT 'Noi dung tra loi chuan xac cua truong',
            `variations` TEXT DEFAULT NULL COMMENT 'Cac cach hoi khac nhau cho cung 1 noi dung',
            `priority` INT NOT NULL DEFAULT 0 COMMENT 'Trong so uu tien tim kiem, cang cao cang uu tien',
            `link_dieu_huong` VARCHAR(255) DEFAULT NULL COMMENT 'Link dieu huong den muc lien quan',
            PRIMARY KEY (`id`),
            KEY `idx_topic_group` (`topic_group`),
            KEY `idx_priority` (`priority`),
            FULLTEXT KEY `ft_keywords_answer` (`tu_khoa`, `noi_dung`, `variations`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
          COMMENT='Kho tri thuc FAQ truong UTH'
    ");

    // Nếu bảng `faq` đã tồn tại từ trước (được tạo trước khi có variations/priority),
    // CREATE TABLE IF NOT EXISTS ở trên sẽ KHÔNG tự thêm cột mới vào bảng cũ.
    // Vì vậy cần kiểm tra và ALTER TABLE bổ sung để đảm bảo logic hoạt động đúng
    // trên cả các cài đặt cũ lẫn mới.
    $columns = array_column(dbFetchAll($pdo, "SHOW COLUMNS FROM `faq`"), 'Field');
    $keywordColumn = in_array('tu_khoa', $columns, true)
        ? 'tu_khoa'
        : (in_array('keywords', $columns, true) ? 'keywords' : null);
    $answerColumn = in_array('noi_dung', $columns, true)
        ? 'noi_dung'
        : (in_array('answer', $columns, true) ? 'answer' : null);

    if (!$keywordColumn || !$answerColumn) {
        throw new RuntimeException('Bảng faq thiếu cột từ khóa/nội dung hợp lệ.');
    }

    if (!in_array('variations', $columns, true)) {
        dbExecute($pdo, "
            ALTER TABLE `faq`
            ADD COLUMN `variations` TEXT DEFAULT NULL COMMENT 'Cac cach hoi khac nhau cho cung 1 noi dung' AFTER ".quoteIdentifier($answerColumn)."
        ");
        $columns[] = 'variations';
    }

    if (!in_array('priority', $columns, true)) {
        dbExecute($pdo, "
            ALTER TABLE `faq`
            ADD COLUMN `priority` INT NOT NULL DEFAULT 0 COMMENT 'Trong so uu tien tim kiem, cang cao cang uu tien' AFTER `variations`
        ");
    }

    // Đảm bảo FULLTEXT KEY đã bao gồm cột `variations` (áp dụng cho bảng cũ vừa được ALTER ở trên).
    $expectedFulltextColumns = [$keywordColumn, $answerColumn, 'variations'];
    $indexRows = dbFetchAll($pdo, "SHOW INDEX FROM `faq` WHERE Key_name = 'ft_keywords_answer'");
    usort($indexRows, fn($a, $b) => (int)$a['Seq_in_index'] <=> (int)$b['Seq_in_index']);
    $indexes = array_column($indexRows, 'Column_name');
    if (!$indexes) {
        dbExecute($pdo, "ALTER TABLE `faq` ADD FULLTEXT KEY `ft_keywords_answer` ("
            .implode(', ', array_map('quoteIdentifier', $expectedFulltextColumns)).")");
    } elseif ($indexes !== $expectedFulltextColumns) {
        dbExecute($pdo, "ALTER TABLE `faq` DROP INDEX `ft_keywords_answer`");
        dbExecute($pdo, "ALTER TABLE `faq` ADD FULLTEXT KEY `ft_keywords_answer` ("
            .implode(', ', array_map('quoteIdentifier', $expectedFulltextColumns)).")");
    }

    if (!in_array('idx_priority', array_column(dbFetchAll($pdo, "SHOW INDEX FROM `faq` WHERE Key_name = 'idx_priority'"), 'Key_name'), true)) {
        dbExecute($pdo, "ALTER TABLE `faq` ADD KEY `idx_priority` (`priority`)");
    }
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
    $insertColumns = [];
    if (preg_match('/INSERT\s+INTO\s+`faq`\s*\((.*?)\)\s*VALUES/is', $insertSql, $matches)) {
        preg_match_all('/`([^`]+)`/', $matches[1], $columnMatches);
        $insertColumns = $columnMatches[1] ?? [];
    }
    $updateAssignments = [];
    foreach (['topic_group', 'tu_khoa', 'noi_dung', 'variations', 'link_dieu_huong', 'priority'] as $column) {
        if (in_array($column, $insertColumns, true)) {
            $quoted = quoteIdentifier($column);
            $updateAssignments[] = "{$quoted} = VALUES({$quoted})";
        }
    }
    if ($updateAssignments) {
        $insertSql .= "\n        ON DUPLICATE KEY UPDATE\n            ".implode(",\n            ", $updateAssignments);
    }

    dbExecute($pdo, $insertSql);
    return (int)dbFetchValue($pdo, "SELECT COUNT(*) FROM `faq`");
}

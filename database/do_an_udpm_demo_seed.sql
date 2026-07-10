-- ============================================================================
-- UTH CHATBOT PORTAL - DEMO DATA SEED
-- Target database: do_an_udpm
-- Safe to run more than once. Existing passwords are preserved unless they are
-- empty/dummy values.
-- ============================================================================

SET NAMES utf8mb4;
SET time_zone = '+07:00';
USE `do_an_udpm`;

-- Roles and settings ---------------------------------------------------------
INSERT INTO roles (code, name, description) VALUES
('student', 'Sinh viên', 'Người dùng sinh viên'),
('admin', 'Quản trị viên', 'Quản trị toàn hệ thống'),
('staff', 'Nhân viên', 'Nhân viên phòng ban hỗ trợ'),
('knowledge_reviewer', 'Kiểm duyệt kiến thức', 'Xác minh nguồn và nội dung RAG')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    description = VALUES(description);

INSERT INTO system_settings (setting_key, setting_value, description, is_public) VALUES
('rag.min_final_score', JSON_OBJECT('value', 0.62), 'Ngưỡng tối thiểu để dùng context RAG', FALSE),
('rag.max_context_chunks', JSON_OBJECT('value', 5), 'Số chunk tối đa gửi tới Gemini', FALSE),
('rag.require_verified', JSON_OBJECT('value', true), 'Chỉ dùng kiến thức đã kiểm duyệt', FALSE),
('chatbot.fallback_message', JSON_OBJECT('vi', 'Mình chưa tìm thấy thông tin đủ chính xác trong hệ thống. Bạn có thể cung cấp thêm học kỳ, năm học hoặc tạo ticket hỗ trợ.'), 'Câu trả lời khi thiếu context', TRUE)
ON DUPLICATE KEY UPDATE
    setting_value = VALUES(setting_value),
    description = VALUES(description),
    is_public = VALUES(is_public);

-- Organization and student profile -----------------------------------------
INSERT INTO faculties (code, name, office_location, email, phone, status) VALUES
('FIT', 'Khoa Công nghệ thông tin', 'Khu nhà C - Cơ sở chính', 'fit@ut.edu.vn', '028 3899 2862', 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    office_location = VALUES(office_location),
    email = VALUES(email),
    phone = VALUES(phone),
    status = VALUES(status);

SET @faculty_id = (SELECT id FROM faculties WHERE code = 'FIT' LIMIT 1);

INSERT INTO programs (
    faculty_id, code, name, degree_level, education_type, specialization,
    total_credits, standard_duration_semesters, status
) VALUES (
    @faculty_id, 'CNTT-CLC-2023', 'Công nghệ thông tin', 'bachelor',
    'Chất lượng cao', 'Công nghệ thông tin', 120, 8, 'active'
)
ON DUPLICATE KEY UPDATE
    faculty_id = VALUES(faculty_id),
    name = VALUES(name),
    degree_level = VALUES(degree_level),
    education_type = VALUES(education_type),
    specialization = VALUES(specialization),
    total_credits = VALUES(total_credits),
    standard_duration_semesters = VALUES(standard_duration_semesters),
    status = VALUES(status);

SET @program_id = (SELECT id FROM programs WHERE code = 'CNTT-CLC-2023' LIMIT 1);
SET @admin_role_id = (SELECT id FROM roles WHERE code = 'admin' LIMIT 1);
SET @student_role_id = (SELECT id FROM roles WHERE code = 'student' LIMIT 1);

-- Default fresh-import credentials:
--   admin / admin123
--   075205019210 / sv123
INSERT INTO users (username, email, password_hash, role_id, full_name, status, created_at, updated_at)
VALUES (
    'admin',
    'admin@ut.edu.vn',
    '$2y$12$3M7KKuHVwqedzfDCECxT0e1SkMFE7YW3JVH4Ylr5x5zMfCiiP1d0K',
    @admin_role_id,
    'Ban Quản trị UTH',
    'active',
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    role_id = VALUES(role_id),
    full_name = VALUES(full_name),
    status = VALUES(status),
    password_hash = IF(users.password_hash IN ('', 'password_hash_dummy'), VALUES(password_hash), users.password_hash),
    updated_at = NOW();

INSERT INTO users (username, email, password_hash, role_id, full_name, status, created_at, updated_at)
VALUES (
    '075205019210',
    '075205019210@student.ut.edu.vn',
    '$2y$12$piGoVROmAihFzRzx3BQ9.uKIgo.bIGfYmrYdPYTYWrV5a0GN/EZSu',
    @student_role_id,
    'Phạm Anh Tuấn',
    'active',
    NOW(),
    NOW()
)
ON DUPLICATE KEY UPDATE
    role_id = VALUES(role_id),
    full_name = VALUES(full_name),
    status = VALUES(status),
    password_hash = IF(users.password_hash IN ('', 'password_hash_dummy'), VALUES(password_hash), users.password_hash),
    updated_at = NOW();

SET @student_user_id = (SELECT id FROM users WHERE username = '075205019210' LIMIT 1);

INSERT INTO student_profiles (
    user_id, student_code, program_id, cohort_year, class_code, date_of_birth,
    gender, place_of_birth, enrollment_date, expected_graduation_date,
    academic_status, advisor_name, created_at, updated_at
) VALUES (
    @student_user_id, '075205019210', @program_id, 2023, 'CNTT2023',
    '2005-06-07', 'male', 'Đồng Tháp', '2023-09-05',
    '2027-08-31', 'studying', 'ThS. Nguyễn Minh Khoa', NOW(), NOW()
)
ON DUPLICATE KEY UPDATE
    program_id = VALUES(program_id),
    cohort_year = VALUES(cohort_year),
    class_code = VALUES(class_code),
    date_of_birth = VALUES(date_of_birth),
    gender = VALUES(gender),
    place_of_birth = VALUES(place_of_birth),
    enrollment_date = VALUES(enrollment_date),
    expected_graduation_date = VALUES(expected_graduation_date),
    academic_status = VALUES(academic_status),
    advisor_name = VALUES(advisor_name),
    updated_at = NOW();

SET @student_id = (SELECT id FROM student_profiles WHERE student_code = '075205019210' LIMIT 1);

-- Academic year, semester, subjects -----------------------------------------
INSERT INTO academic_years (code, start_date, end_date, is_current) VALUES
('2025-2026', '2025-08-01', '2026-07-31', TRUE)
ON DUPLICATE KEY UPDATE
    start_date = VALUES(start_date),
    end_date = VALUES(end_date),
    is_current = VALUES(is_current);

SET @academic_year_id = (SELECT id FROM academic_years WHERE code = '2025-2026' LIMIT 1);

INSERT INTO semesters (
    academic_year_id, code, name, semester_number, start_date, end_date,
    registration_start, registration_end, tuition_due_date, is_current
) VALUES (
    @academic_year_id, 'HK_HE_2026', 'Học kỳ hè năm học 2025-2026',
    3, '2026-06-01', '2026-07-31', '2026-06-01 08:00:00',
    '2026-06-15 17:00:00', '2026-07-20 17:00:00', TRUE
)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    semester_number = VALUES(semester_number),
    start_date = VALUES(start_date),
    end_date = VALUES(end_date),
    registration_start = VALUES(registration_start),
    registration_end = VALUES(registration_end),
    tuition_due_date = VALUES(tuition_due_date),
    is_current = VALUES(is_current);

SET @semester_id = (
    SELECT id
    FROM semesters
    WHERE academic_year_id = @academic_year_id AND code = 'HK_HE_2026'
    LIMIT 1
);

INSERT INTO subjects (code, name, credits, theory_periods, practice_periods, faculty_id, description, status) VALUES
('MOB101', 'Lập trình thiết bị di động', 3, 30, 30, @faculty_id, 'Xây dựng ứng dụng di động cơ bản và tích hợp API.', 'active'),
('ECOM201', 'Thương mại điện tử', 3, 30, 15, @faculty_id, 'Nền tảng thương mại điện tử và vận hành kênh bán hàng số.', 'active'),
('NET301', 'Lập trình mạng', 3, 30, 30, @faculty_id, 'Socket, giao thức mạng và ứng dụng client-server.', 'active'),
('POL101', 'Lịch sử Đảng Cộng sản Việt Nam', 2, 30, 0, @faculty_id, 'Kiến thức nền tảng về lịch sử Đảng Cộng sản Việt Nam.', 'active'),
('DST401', 'Lập trình phân tán', 3, 30, 30, @faculty_id, 'Kiến trúc phân tán, RPC, message queue và dịch vụ web.', 'active'),
('PM401', 'Quản trị dự án phần mềm', 3, 30, 15, @faculty_id, 'Lập kế hoạch, quản lý rủi ro và theo dõi tiến độ dự án phần mềm.', 'active')
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    credits = VALUES(credits),
    theory_periods = VALUES(theory_periods),
    practice_periods = VALUES(practice_periods),
    faculty_id = VALUES(faculty_id),
    description = VALUES(description),
    status = VALUES(status);

-- Course sections and weekly schedule ---------------------------------------
INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'MOB101-01', 'ThS. Nguyễn Văn A', 45, 36, 'offline', 'open'
FROM subjects WHERE code = 'MOB101'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), status = VALUES(status);

INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'ECOM201-01', 'ThS. Trần Thị B', 45, 34, 'hybrid', 'open'
FROM subjects WHERE code = 'ECOM201'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), delivery_mode = VALUES(delivery_mode), status = VALUES(status);

INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'NET301-01', 'ThS. Lê Văn C', 45, 38, 'offline', 'open'
FROM subjects WHERE code = 'NET301'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), status = VALUES(status);

INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'POL101-01', 'TS. Phạm Thị D', 80, 72, 'offline', 'open'
FROM subjects WHERE code = 'POL101'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), status = VALUES(status);

INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'DST401-01', 'ThS. Hoàng Minh E', 40, 31, 'offline', 'open'
FROM subjects WHERE code = 'DST401'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), status = VALUES(status);

INSERT INTO course_sections (semester_id, subject_id, section_code, lecturer_name, capacity, registered_count, delivery_mode, status)
SELECT @semester_id, id, 'PM401-01', 'ThS. Võ Thanh F', 50, 41, 'online', 'open'
FROM subjects WHERE code = 'PM401'
ON DUPLICATE KEY UPDATE subject_id = VALUES(subject_id), lecturer_name = VALUES(lecturer_name), registered_count = VALUES(registered_count), delivery_mode = VALUES(delivery_mode), status = VALUES(status);

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 1, '07:30:00', '10:00:00', 'Phòng F101', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'MOB101-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 1 AND css.start_time = '07:30:00'
  );

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 1, '13:00:00', '15:30:00', 'Phòng B202', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'ECOM201-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 1 AND css.start_time = '13:00:00'
  );

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 2, '07:30:00', '10:00:00', 'Phòng D103', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'NET301-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 2 AND css.start_time = '07:30:00'
  );

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 3, '07:30:00', '11:00:00', 'Hội trường A', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'POL101-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 3 AND css.start_time = '07:30:00'
  );

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 4, '13:00:00', '15:30:00', 'Phòng F304', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'DST401-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 4 AND css.start_time = '13:00:00'
  );

INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus, valid_from, valid_until)
SELECT cs.id, 5, '07:30:00', '10:00:00', 'Phòng D201', 'Cơ sở chính', '2026-06-01', '2026-07-31'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'PM401-01'
  AND NOT EXISTS (
      SELECT 1 FROM class_schedule_sessions css
      WHERE css.course_section_id = cs.id AND css.day_of_week = 5 AND css.start_time = '07:30:00'
  );

INSERT INTO enrollments (student_id, course_section_id, enrollment_status, registered_at)
SELECT @student_id, cs.id, 'studying', '2026-06-01 09:00:00'
FROM course_sections cs
WHERE cs.semester_id = @semester_id
  AND cs.section_code IN ('MOB101-01', 'ECOM201-01', 'NET301-01', 'POL101-01', 'DST401-01', 'PM401-01')
ON DUPLICATE KEY UPDATE
    enrollment_status = VALUES(enrollment_status);

-- Grades, exams, tuition -----------------------------------------------------
INSERT INTO grades (enrollment_id, attendance_score, process_score, midterm_score, final_exam_score, final_score_10, grade_4, letter_grade, result, published_at)
SELECT e.id, 9.0, 8.5, 8.0, 8.2, 8.3, 3.50, 'B+', 'passed', '2026-07-08 09:00:00'
FROM enrollments e JOIN course_sections cs ON cs.id = e.course_section_id
WHERE e.student_id = @student_id AND cs.section_code = 'MOB101-01'
ON DUPLICATE KEY UPDATE final_score_10 = VALUES(final_score_10), grade_4 = VALUES(grade_4), letter_grade = VALUES(letter_grade), result = VALUES(result), published_at = VALUES(published_at);

INSERT INTO grades (enrollment_id, attendance_score, process_score, midterm_score, final_exam_score, final_score_10, grade_4, letter_grade, result, published_at)
SELECT e.id, 8.5, 8.0, 7.5, 7.8, 7.9, 3.00, 'B', 'passed', '2026-07-08 09:00:00'
FROM enrollments e JOIN course_sections cs ON cs.id = e.course_section_id
WHERE e.student_id = @student_id AND cs.section_code = 'ECOM201-01'
ON DUPLICATE KEY UPDATE final_score_10 = VALUES(final_score_10), grade_4 = VALUES(grade_4), letter_grade = VALUES(letter_grade), result = VALUES(result), published_at = VALUES(published_at);

INSERT INTO grades (enrollment_id, attendance_score, process_score, midterm_score, final_exam_score, final_score_10, grade_4, letter_grade, result, published_at)
SELECT e.id, 8.0, 7.5, 7.0, NULL, NULL, NULL, NULL, 'pending', NULL
FROM enrollments e JOIN course_sections cs ON cs.id = e.course_section_id
WHERE e.student_id = @student_id AND cs.section_code = 'NET301-01'
ON DUPLICATE KEY UPDATE attendance_score = VALUES(attendance_score), process_score = VALUES(process_score), midterm_score = VALUES(midterm_score), result = VALUES(result), published_at = VALUES(published_at);

INSERT INTO exam_schedules (course_section_id, exam_type, exam_date, start_time, duration_minutes, room, campus, seat_number, notes, published_at)
SELECT cs.id, 'final', '2026-07-24', '07:30:00', 90, 'Phòng C305', 'Cơ sở chính', 'A12', 'Mang theo thẻ sinh viên khi dự thi.', '2026-07-08 08:00:00'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'MOB101-01'
  AND NOT EXISTS (
      SELECT 1 FROM exam_schedules es
      WHERE es.course_section_id = cs.id AND es.exam_type = 'final' AND es.exam_date = '2026-07-24'
  );

INSERT INTO exam_schedules (course_section_id, exam_type, exam_date, start_time, duration_minutes, room, campus, seat_number, notes, published_at)
SELECT cs.id, 'final', '2026-07-28', '13:30:00', 90, 'Phòng D204', 'Cơ sở chính', 'B08', 'Có mặt trước giờ thi 15 phút.', '2026-07-08 08:00:00'
FROM course_sections cs
WHERE cs.semester_id = @semester_id AND cs.section_code = 'NET301-01'
  AND NOT EXISTS (
      SELECT 1 FROM exam_schedules es
      WHERE es.course_section_id = cs.id AND es.exam_type = 'final' AND es.exam_date = '2026-07-28'
  );

INSERT INTO tuition_invoices (
    student_id, semester_id, invoice_number, description, subtotal,
    discount_amount, paid_amount, due_date, status, issued_at
) VALUES (
    @student_id, @semester_id, 'HP-075205019210-HE2026',
    'Học phí học kỳ hè năm học 2025-2026', 17640000,
    0, 8000000, '2026-07-20 17:00:00', 'partially_paid', '2026-06-20 08:30:00'
)
ON DUPLICATE KEY UPDATE
    description = VALUES(description),
    subtotal = VALUES(subtotal),
    discount_amount = VALUES(discount_amount),
    paid_amount = VALUES(paid_amount),
    due_date = VALUES(due_date),
    status = VALUES(status);

SET @invoice_id = (SELECT id FROM tuition_invoices WHERE invoice_number = 'HP-075205019210-HE2026' LIMIT 1);

DELETE FROM tuition_invoice_items WHERE invoice_id = @invoice_id;

INSERT INTO tuition_invoice_items (invoice_id, item_type, description, quantity, unit_price) VALUES
(@invoice_id, 'tuition_credit', '18 tín chỉ chương trình chất lượng cao', 18, 980000),
(@invoice_id, 'service', 'Phí dịch vụ sinh viên học kỳ hè', 1, 0);

-- Announcements and deadlines ------------------------------------------------
INSERT INTO announcements (title, slug, summary, content, announcement_type, source_url, published_by, published_at, expires_at, status) VALUES
('Thông báo điều chỉnh đăng ký học phần học kỳ hè 2025-2026', 'thong-bao-dieu-chinh-dkhp-he-2026', 'Sinh viên được điều chỉnh đăng ký học phần học kỳ hè đến 17:00 ngày 12/07/2026.', 'Sinh viên đăng nhập Portal để kiểm tra lớp học phần, học phí tạm tính và thực hiện điều chỉnh trong thời gian quy định.', 'academic', 'https://portal.ut.edu.vn/thong-bao/dieu-chinh-dkhp-he-2026', (SELECT id FROM users WHERE username = 'admin' LIMIT 1), '2026-07-01 08:00:00', '2026-07-31 23:59:59', 'published'),
('Sự kiện Ngày hội việc làm UTH 2026', 'su-kien-ngay-hoi-viec-lam-uth-2026', 'Ngày hội việc làm diễn ra tại cơ sở chính, sinh viên đăng ký tham dự trên Portal.', 'Chương trình có các doanh nghiệp trong lĩnh vực công nghệ, logistics và giao thông vận tải tham gia tuyển dụng thực tập sinh.', 'event', 'https://portal.ut.edu.vn/su-kien/ngay-hoi-viec-lam-2026', (SELECT id FROM users WHERE username = 'admin' LIMIT 1), '2026-07-05 09:00:00', '2026-07-16 23:59:59', 'published'),
('Thông báo công bố lịch thi học kỳ hè 2025-2026', 'thong-bao-lich-thi-he-2026', 'Lịch thi dự kiến đã được cập nhật, sinh viên kiểm tra phòng thi và ca thi trong Portal.', 'Sinh viên phản hồi trùng lịch thi hoặc sai thông tin lớp học phần qua mục hỗ trợ trực tuyến trước ngày 18/07/2026.', 'exam', 'https://portal.ut.edu.vn/thong-bao/lich-thi-he-2026', (SELECT id FROM users WHERE username = 'admin' LIMIT 1), '2026-07-08 10:00:00', '2026-07-31 23:59:59', 'published'),
('Thông báo bảo trì Portal sinh viên', 'bao-tri-portal-sinh-vien-07-2026', 'Portal tạm ngưng một số chức năng thanh toán trong khung giờ bảo trì.', 'Hệ thống thanh toán và xác nhận học phí tạm ngưng từ 22:00 ngày 18/07/2026 đến 02:00 ngày 19/07/2026.', 'other', 'https://portal.ut.edu.vn/thong-bao/bao-tri-07-2026', (SELECT id FROM users WHERE username = 'admin' LIMIT 1), '2026-07-10 07:30:00', '2026-07-20 23:59:59', 'published')
ON DUPLICATE KEY UPDATE
    summary = VALUES(summary),
    content = VALUES(content),
    announcement_type = VALUES(announcement_type),
    source_url = VALUES(source_url),
    published_at = VALUES(published_at),
    expires_at = VALUES(expires_at),
    status = VALUES(status);

INSERT INTO academic_deadlines (semester_id, title, deadline_type, description, starts_at, due_at, audience_type, audience_value, source_url, status)
SELECT @semester_id, 'Hạn cuối điều chỉnh đăng ký học phần học kỳ hè', 'course_registration', 'Sinh viên hoàn tất điều chỉnh lớp học phần trên Portal trước thời hạn.', '2026-07-01 08:00:00', '2026-07-12 17:00:00', 'all', NULL, 'https://portal.ut.edu.vn/dang-ky-hoc-phan', 'published'
WHERE NOT EXISTS (
    SELECT 1 FROM academic_deadlines
    WHERE title = 'Hạn cuối điều chỉnh đăng ký học phần học kỳ hè'
      AND due_at = '2026-07-12 17:00:00'
);

INSERT INTO academic_deadlines (semester_id, title, deadline_type, description, starts_at, due_at, audience_type, audience_value, source_url, status)
SELECT @semester_id, 'Hạn đóng học phí học kỳ hè 2025-2026', 'tuition', 'Sinh viên thanh toán phần học phí còn lại để không bị khóa lịch thi.', '2026-06-20 08:00:00', '2026-07-20 17:00:00', 'student', '075205019210', 'https://payment.ut.edu.vn', 'published'
WHERE NOT EXISTS (
    SELECT 1 FROM academic_deadlines
    WHERE title = 'Hạn đóng học phí học kỳ hè 2025-2026'
      AND due_at = '2026-07-20 17:00:00'
      AND audience_value = '075205019210'
);

INSERT INTO academic_deadlines (semester_id, title, deadline_type, description, starts_at, due_at, audience_type, audience_value, source_url, status)
SELECT @semester_id, 'Hạn phản hồi trùng lịch thi học kỳ hè', 'exam', 'Sinh viên gửi phản hồi nếu phát hiện trùng ca thi hoặc sai thông tin phòng thi.', '2026-07-08 08:00:00', '2026-07-18 17:00:00', 'all', NULL, 'https://support.ut.edu.vn', 'published'
WHERE NOT EXISTS (
    SELECT 1 FROM academic_deadlines
    WHERE title = 'Hạn phản hồi trùng lịch thi học kỳ hè'
      AND due_at = '2026-07-18 17:00:00'
);

-- A small verified RAG seed so academic knowledge queries have safe context. ---
INSERT INTO knowledge_sources (
    source_type, title, organization, source_url, retrieved_at, is_official, status
)
SELECT 'official_web', 'Portal UTH - dữ liệu mẫu đã kiểm duyệt', 'UTH', 'https://portal.ut.edu.vn', NOW(), TRUE, 'active'
WHERE NOT EXISTS (
    SELECT 1 FROM knowledge_sources
    WHERE title = 'Portal UTH - dữ liệu mẫu đã kiểm duyệt'
);

SET @official_source_id = (
    SELECT id
    FROM knowledge_sources
    WHERE title = 'Portal UTH - dữ liệu mẫu đã kiểm duyệt'
    LIMIT 1
);
SET @admin_user_id = (SELECT id FROM users WHERE username = 'admin' LIMIT 1);

INSERT INTO knowledge_articles (
    source_id, title, category, subcategory, intent_code, keywords, answer_content,
    route_url, audience, program_id, cohort_from, cohort_to, semester_code,
    academic_year_code, valid_from, valid_until, verification_status,
    confidence_level, priority, created_by, reviewed_by, reviewed_at
)
SELECT
    @official_source_id,
    'Quy định điều chỉnh đăng ký học phần học kỳ hè 2025-2026',
    'Đăng ký học phần',
    'Học kỳ hè',
    'academic_knowledge',
    'đăng ký học phần, điều chỉnh học phần, học kỳ hè, rút môn, thêm môn',
    'Sinh viên điều chỉnh đăng ký học phần học kỳ hè 2025-2026 trực tiếp trên Portal trong thời gian trường công bố. Sau hạn điều chỉnh, sinh viên cần gửi yêu cầu hỗ trợ để được Phòng Đào tạo xem xét theo quy định.',
    '/dang-ky-hoc-phan',
    'student',
    @program_id,
    2023,
    2023,
    'HK_HE_2026',
    '2025-2026',
    '2026-07-01 00:00:00',
    '2026-07-31 23:59:59',
    'verified',
    'authoritative',
    1,
    @admin_user_id,
    @admin_user_id,
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM knowledge_articles
    WHERE title = 'Quy định điều chỉnh đăng ký học phần học kỳ hè 2025-2026'
      AND deleted_at IS NULL
);

SET @article_dkhp_id = (
    SELECT id
    FROM knowledge_articles
    WHERE title = 'Quy định điều chỉnh đăng ký học phần học kỳ hè 2025-2026'
      AND deleted_at IS NULL
    LIMIT 1
);

INSERT INTO knowledge_chunks (article_id, chunk_index, heading, chunk_text, token_count, content_hash)
VALUES (
    @article_dkhp_id,
    0,
    'Điều chỉnh đăng ký học phần học kỳ hè 2025-2026',
    'Sinh viên điều chỉnh đăng ký học phần học kỳ hè 2025-2026 trực tiếp trên Portal trong thời gian trường công bố. Sau hạn điều chỉnh, sinh viên cần gửi yêu cầu hỗ trợ để được Phòng Đào tạo xem xét theo quy định.',
    48,
    SHA2('dkhp-he-2026', 256)
)
ON DUPLICATE KEY UPDATE
    heading = VALUES(heading),
    chunk_text = VALUES(chunk_text),
    token_count = VALUES(token_count),
    content_hash = VALUES(content_hash);

INSERT INTO knowledge_articles (
    source_id, title, category, subcategory, intent_code, keywords, answer_content,
    route_url, audience, valid_from, valid_until, verification_status,
    confidence_level, priority, created_by, reviewed_by, reviewed_at
)
SELECT
    @official_source_id,
    'Hướng dẫn tra cứu công nợ học phí trên Portal',
    'Học phí',
    'Tra cứu công nợ',
    'academic_knowledge',
    'học phí, công nợ, thanh toán học phí, cổng thanh toán',
    'Sinh viên tra cứu công nợ và thanh toán học phí tại Cổng thanh toán hoặc mục học phí trên Portal. Các câu hỏi về số tiền còn nợ của từng sinh viên phải được tra cứu từ dữ liệu hóa đơn trong database.',
    '/cong-thanh-toan',
    'student',
    '2026-07-01 00:00:00',
    NULL,
    'verified',
    'authoritative',
    1,
    @admin_user_id,
    @admin_user_id,
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM knowledge_articles
    WHERE title = 'Hướng dẫn tra cứu công nợ học phí trên Portal'
      AND deleted_at IS NULL
);

SET @article_tuition_id = (
    SELECT id
    FROM knowledge_articles
    WHERE title = 'Hướng dẫn tra cứu công nợ học phí trên Portal'
      AND deleted_at IS NULL
    LIMIT 1
);

INSERT INTO knowledge_chunks (article_id, chunk_index, heading, chunk_text, token_count, content_hash)
VALUES (
    @article_tuition_id,
    0,
    'Tra cứu công nợ học phí',
    'Sinh viên tra cứu công nợ và thanh toán học phí tại Cổng thanh toán hoặc mục học phí trên Portal. Các câu hỏi về số tiền còn nợ của từng sinh viên phải được tra cứu từ dữ liệu hóa đơn trong database.',
    45,
    SHA2('hoc-phi-cong-no-portal', 256)
)
ON DUPLICATE KEY UPDATE
    heading = VALUES(heading),
    chunk_text = VALUES(chunk_text),
    token_count = VALUES(token_count),
    content_hash = VALUES(content_hash);

-- Check if user already inserted
DELETE FROM users WHERE username = '075205019210';
INSERT INTO users (username, email, password_hash, role_id, full_name, status, created_at, updated_at)
VALUES ('075205019210', '075205019210@student.ut.edu.vn', 'password_hash_dummy', 3, 'Phạm Anh Tuấn', 'active', NOW(), NOW());

SET @user_id = LAST_INSERT_ID();

INSERT INTO student_profiles (user_id, student_code, cohort_year, class_code, date_of_birth, gender, place_of_birth, academic_status, created_at, updated_at)
VALUES (@user_id, '075205019210', 2023, 'CNTT2023', '2005-06-07', 'male', 'Đồng Tháp', 'studying', NOW(), NOW());

SET @student_id = LAST_INSERT_ID();

INSERT INTO subjects (code, name, credits) VALUES 
('LTTBDD', 'Lập trình thiết bị di động', 3),
('TMDT', 'Thương mại điện tử', 3),
('LTM', 'Lập trình mạng', 3),
('LSDCSVN', 'Lịch sử Đảng cộng sản Việt Nam', 2)
ON DUPLICATE KEY UPDATE id=id;

INSERT INTO academic_years (code, start_date, end_date) VALUES ('2025-2026', '2025-08-01', '2026-07-31') ON DUPLICATE KEY UPDATE id=id;
SET @ay_id = (SELECT id FROM academic_years WHERE code = '2025-2026' LIMIT 1);

INSERT INTO semesters (academic_year_id, code, name, start_date, end_date) VALUES (@ay_id, 'HK3', 'Học kỳ hè', '2026-06-01', '2026-07-31') ON DUPLICATE KEY UPDATE id=id;
SET @sem_id = (SELECT id FROM semesters WHERE code = 'HK3' LIMIT 1);

-- Sections
INSERT INTO course_sections (subject_id, semester_id, section_code, lecturer_name) VALUES 
((SELECT id FROM subjects WHERE code = 'LTTBDD' LIMIT 1), @sem_id, 'LTTBDD_01', 'GV Nguyễn Văn A'),
((SELECT id FROM subjects WHERE code = 'TMDT' LIMIT 1), @sem_id, 'TMDT_01', 'GV Trần Thị B'),
((SELECT id FROM subjects WHERE code = 'LTM' LIMIT 1), @sem_id, 'LTM_01', 'GV Lê Văn C'),
((SELECT id FROM subjects WHERE code = 'LSDCSVN' LIMIT 1), @sem_id, 'LSDCSVN_01', 'GV Phạm Thị D');

-- Sessions
INSERT INTO class_schedule_sessions (course_section_id, day_of_week, start_time, end_time, room, campus) VALUES 
((SELECT id FROM course_sections WHERE section_code = 'LTTBDD_01' LIMIT 1), 2, '07:30:00', '10:00:00', 'Phòng F101', 'Cơ sở 1'),
((SELECT id FROM course_sections WHERE section_code = 'TMDT_01' LIMIT 1), 2, '13:00:00', '15:30:00', 'Phòng B202', 'Cơ sở 1'),
((SELECT id FROM course_sections WHERE section_code = 'LTM_01' LIMIT 1), 3, '07:30:00', '10:00:00', 'Phòng D103', 'Cơ sở 1'),
((SELECT id FROM course_sections WHERE section_code = 'LSDCSVN_01' LIMIT 1), 4, '07:30:00', '11:00:00', 'HT A', 'Cơ sở 1');

-- Enrollments
INSERT INTO enrollments (student_id, course_section_id, enrollment_status) VALUES 
(@student_id, (SELECT id FROM course_sections WHERE section_code = 'LTTBDD_01' LIMIT 1), 'studying'),
(@student_id, (SELECT id FROM course_sections WHERE section_code = 'TMDT_01' LIMIT 1), 'studying'),
(@student_id, (SELECT id FROM course_sections WHERE section_code = 'LTM_01' LIMIT 1), 'studying'),
(@student_id, (SELECT id FROM course_sections WHERE section_code = 'LSDCSVN_01' LIMIT 1), 'studying');


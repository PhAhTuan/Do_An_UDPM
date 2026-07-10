USE do_an_udpm;

-- Delete if exists
DELETE FROM users WHERE username IN ('admin', '075205019210');

-- Insert admin (admin123)
INSERT INTO users (username, email, password_hash, role_id, full_name, status, created_at, updated_at)
VALUES ('admin', 'admin@ut.edu.vn', '$2y$12$3M7KKuHVwqedzfDCECxT0e1SkMFE7YW3JVH4Ylr5x5zMfCiiP1d0K', 2, 'Ban Quản Trị UTH', 'active', NOW(), NOW());

-- Insert student (sv123)
INSERT INTO users (username, email, password_hash, role_id, full_name, status, created_at, updated_at)
VALUES ('075205019210', '075205019210@student.ut.edu.vn', '$2y$12$piGoVROmAihFzRzx3BQ9.uKIgo.bIGfYmrYdPYTYWrV5a0GN/EZSu', 1, 'Phạm Anh Tuấn', 'active', NOW(), NOW());

SET @student_user_id = LAST_INSERT_ID();

-- Insert student profile
INSERT INTO student_profiles (user_id, student_code, cohort_year, class_code, date_of_birth, gender, place_of_birth, academic_status, created_at, updated_at)
VALUES (@student_user_id, '075205019210', 2023, 'CNTT2023', '2005-06-07', 'male', 'Đồng Tháp', 'studying', NOW(), NOW());

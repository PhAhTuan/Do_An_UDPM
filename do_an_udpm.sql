-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th8 01, 2026 lúc 01:56 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `do_an_udpm`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `academic_deadlines`
--

CREATE TABLE `academic_deadlines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `deadline_type` enum('course_registration','tuition','withdrawal','exam','appeal','certificate','graduation','other') NOT NULL,
  `description` text DEFAULT NULL,
  `starts_at` datetime DEFAULT NULL,
  `due_at` datetime NOT NULL,
  `audience_type` enum('all','faculty','program','cohort','student') NOT NULL DEFAULT 'all',
  `audience_value` varchar(100) DEFAULT NULL,
  `source_url` varchar(1000) DEFAULT NULL,
  `status` enum('draft','published','cancelled','completed') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `academic_deadlines`
--

INSERT INTO `academic_deadlines` (`id`, `semester_id`, `title`, `deadline_type`, `description`, `starts_at`, `due_at`, `audience_type`, `audience_value`, `source_url`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Hạn cuối điều chỉnh đăng ký học phần học kỳ hè', 'course_registration', 'Sinh viên hoàn tất điều chỉnh lớp học phần trên Portal trước thời hạn.', '2026-07-01 08:00:00', '2026-07-12 17:00:00', 'all', NULL, 'https://portal.ut.edu.vn/dang-ky-hoc-phan', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(2, 1, 'Hạn đóng học phí học kỳ hè 2025-2026', 'tuition', 'Sinh viên thanh toán phần học phí còn lại để không bị khóa lịch thi.', '2026-06-20 08:00:00', '2026-07-20 17:00:00', 'student', '075205019210', 'https://payment.ut.edu.vn', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(3, 1, 'Hạn phản hồi trùng lịch thi học kỳ hè', 'exam', 'Sinh viên gửi phản hồi nếu phát hiện trùng ca thi hoặc sai thông tin phòng thi.', '2026-07-08 08:00:00', '2026-07-18 17:00:00', 'all', NULL, 'https://support.ut.edu.vn', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `academic_years`
--

CREATE TABLE `academic_years` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT 0
) ;

--
-- Đang đổ dữ liệu cho bảng `academic_years`
--

INSERT INTO `academic_years` (`id`, `code`, `start_date`, `end_date`, `is_current`) VALUES
(1, '2025-2026', '2025-08-01', '2026-07-31', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `announcements`
--

CREATE TABLE `announcements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `content` longtext NOT NULL,
  `announcement_type` enum('news','event','academic','tuition','exam','emergency','other') NOT NULL DEFAULT 'news',
  `source_url` varchar(1000) DEFAULT NULL,
  `published_by` bigint(20) UNSIGNED DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `status` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `slug`, `summary`, `content`, `announcement_type`, `source_url`, `published_by`, `published_at`, `expires_at`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Thông báo điều chỉnh đăng ký học phần học kỳ hè 2025-2026', 'thong-bao-dieu-chinh-dkhp-he-2026', 'Sinh viên được điều chỉnh đăng ký học phần học kỳ hè đến 17:00 ngày 12/07/2026.', 'Sinh viên đăng nhập Portal để kiểm tra lớp học phần, học phí tạm tính và thực hiện điều chỉnh trong thời gian quy định.', 'academic', 'https://portal.ut.edu.vn/thong-bao/dieu-chinh-dkhp-he-2026', 1, '2026-07-01 08:00:00', '2026-07-31 23:59:59', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(2, 'Sự kiện Ngày hội việc làm UTH 2026', 'su-kien-ngay-hoi-viec-lam-uth-2026', 'Ngày hội việc làm diễn ra tại cơ sở chính, sinh viên đăng ký tham dự trên Portal.', 'Chương trình có các doanh nghiệp trong lĩnh vực công nghệ, logistics và giao thông vận tải tham gia tuyển dụng thực tập sinh.', 'event', 'https://portal.ut.edu.vn/su-kien/ngay-hoi-viec-lam-2026', 1, '2026-07-05 09:00:00', '2026-07-16 23:59:59', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(3, 'Thông báo công bố lịch thi học kỳ hè 2025-2026', 'thong-bao-lich-thi-he-2026', 'Lịch thi dự kiến đã được cập nhật, sinh viên kiểm tra phòng thi và ca thi trong Portal.', 'Sinh viên phản hồi trùng lịch thi hoặc sai thông tin lớp học phần qua mục hỗ trợ trực tuyến trước ngày 18/07/2026.', 'exam', 'https://portal.ut.edu.vn/thong-bao/lich-thi-he-2026', 1, '2026-07-08 10:00:00', '2026-07-31 23:59:59', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(4, 'Thông báo bảo trì Portal sinh viên', 'bao-tri-portal-sinh-vien-07-2026', 'Portal tạm ngưng một số chức năng thanh toán trong khung giờ bảo trì.', 'Hệ thống thanh toán và xác nhận học phí tạm ngưng từ 22:00 ngày 18/07/2026 đến 02:00 ngày 19/07/2026.', 'other', 'https://portal.ut.edu.vn/thong-bao/bao-tri-07-2026', 1, '2026-07-10 07:30:00', '2026-07-20 23:59:59', 'published', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `announcement_audiences`
--

CREATE TABLE `announcement_audiences` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `announcement_id` bigint(20) UNSIGNED NOT NULL,
  `audience_type` enum('all','role','faculty','program','cohort','student') NOT NULL DEFAULT 'all',
  `audience_value` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `api_usage_logs`
--

CREATE TABLE `api_usage_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `provider` varchar(80) NOT NULL,
  `model_name` varchar(120) DEFAULT NULL,
  `endpoint` varchar(255) DEFAULT NULL,
  `request_id` varchar(255) DEFAULT NULL,
  `input_tokens` int(10) UNSIGNED DEFAULT NULL,
  `output_tokens` int(10) UNSIGNED DEFAULT NULL,
  `estimated_cost` decimal(14,8) DEFAULT NULL,
  `status_code` smallint(5) UNSIGNED DEFAULT NULL,
  `latency_ms` int(10) UNSIGNED DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` varchar(120) NOT NULL,
  `entity_type` varchar(120) DEFAULT NULL,
  `entity_id` varchar(120) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(1000) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_feedback`
--

CREATE TABLE `chat_feedback` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rating` enum('up','down') NOT NULL,
  `reason_code` enum('incorrect','outdated','irrelevant','unclear','unsafe','helpful','other') DEFAULT NULL,
  `comment` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chat_feedback`
--

INSERT INTO `chat_feedback` (`id`, `message_id`, `user_id`, `rating`, `reason_code`, `comment`, `created_at`) VALUES
(1, 52, 2, 'down', 'incorrect', 'Báo cáo từ giao diện chatbot', '2026-07-22 22:56:43');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `parent_message_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sender_type` enum('user','assistant','system','tool') NOT NULL,
  `content` longtext NOT NULL,
  `normalized_content` longtext DEFAULT NULL,
  `detected_intent` varchar(120) DEFAULT NULL,
  `extracted_entities` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`extracted_entities`)),
  `model_name` varchar(120) DEFAULT NULL,
  `prompt_tokens` int(10) UNSIGNED DEFAULT NULL,
  `completion_tokens` int(10) UNSIGNED DEFAULT NULL,
  `latency_ms` int(10) UNSIGNED DEFAULT NULL,
  `confidence_score` decimal(8,6) DEFAULT NULL,
  `answer_status` enum('ok','insufficient_context','clarification_needed','blocked','error') NOT NULL DEFAULT 'ok',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `session_id`, `parent_message_id`, `sender_type`, `content`, `normalized_content`, `detected_intent`, `extracted_entities`, `model_name`, `prompt_tokens`, `completion_tokens`, `latency_ms`, `confidence_score`, `answer_status`, `created_at`) VALUES
(1, 1, NULL, 'user', 'Ngày mai mình có lịch học gì?', 'ngay mai minh co lich hoc gi', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":\"tomorrow\"}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-11 16:56:53'),
(2, 1, 1, 'assistant', 'Mình chưa tìm thấy thông tin đủ chính xác trong hệ thống. Bạn có thể cung cấp thêm học kỳ, năm học hoặc tạo ticket hỗ trợ.', 'minh chua tim thay thong tin du chinh xac trong he thong ban co the cung cap them hoc ky nam hoc hoac tao ticket ho tro', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":\"tomorrow\"}', NULL, NULL, NULL, 32, 0.000000, 'insufficient_context', '2026-07-11 16:56:53'),
(3, 1, NULL, 'user', 'Tạo ticket hỗ trợ', 'tao ticket ho tro', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-11 16:56:56'),
(4, 1, 3, 'assistant', '<strong>Hỗ trợ trực tuyến</strong><br>Bạn có thể nhập trực tiếp vấn đề cần hỗ trợ vào khung chat. Nếu câu hỏi cần cán bộ xử lý hoặc thiếu dữ liệu trong hệ thống, mình sẽ hướng dẫn tạo ticket hỗ trợ để bộ phận phụ trách phản hồi.', 'strong ho tro truc tuyen strong br ban co the nhap truc tiep van de can ho tro vao khung chat neu cau hoi can can bo xu ly hoac thieu du lieu trong he thong minh se huong dan tao ticket ho tro de bo phan phu trach phan hoi', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', 'database-navigation', NULL, NULL, 25, 1.000000, 'ok', '2026-07-11 16:56:56'),
(5, 1, NULL, 'user', 'Tạo ticket hỗ trợ', 'tao ticket ho tro', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-11 16:57:13'),
(6, 1, 5, 'assistant', '<strong>Hỗ trợ trực tuyến</strong><br>Bạn có thể nhập trực tiếp vấn đề cần hỗ trợ vào khung chat. Nếu câu hỏi cần cán bộ xử lý hoặc thiếu dữ liệu trong hệ thống, mình sẽ hướng dẫn tạo ticket hỗ trợ để bộ phận phụ trách phản hồi.', 'strong ho tro truc tuyen strong br ban co the nhap truc tiep van de can ho tro vao khung chat neu cau hoi can can bo xu ly hoac thieu du lieu trong he thong minh se huong dan tao ticket ho tro de bo phan phu trach phan hoi', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', 'database-navigation', NULL, NULL, 44, 1.000000, 'ok', '2026-07-11 16:57:13'),
(7, 1, NULL, 'user', 'tôi muốn múc admin', 'toi muon muc admin', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-11 16:57:21'),
(8, 1, 7, 'assistant', 'Xin lỗi, tôi không hiểu rõ ý bạn muốn hỏi &quot;múc admin&quot; là gì. Bạn có thể vui lòng diễn đạt lại câu hỏi của mình không?', 'xin loi toi khong hieu ro y ban muon hoi quot muc admin quot la gi ban co the vui long dien dat lai cau hoi cua minh khong', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1374, 0.868627, 'ok', '2026-07-11 16:57:22'),
(9, 1, NULL, 'user', 'Tạo ticket hỗ trợ', 'tao ticket ho tro', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-11 16:57:25'),
(10, 1, 9, 'assistant', '<strong>Hỗ trợ trực tuyến</strong><br>Bạn có thể nhập trực tiếp vấn đề cần hỗ trợ vào khung chat. Nếu câu hỏi cần cán bộ xử lý hoặc thiếu dữ liệu trong hệ thống, mình sẽ hướng dẫn tạo ticket hỗ trợ để bộ phận phụ trách phản hồi.', 'strong ho tro truc tuyen strong br ban co the nhap truc tiep van de can ho tro vao khung chat neu cau hoi can can bo xu ly hoac thieu du lieu trong he thong minh se huong dan tao ticket ho tro de bo phan phu trach phan hoi', 'nav_support', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":2023,\"date_scope\":null}', 'database-navigation', NULL, NULL, 25, 1.000000, 'ok', '2026-07-11 16:57:25'),
(11, 2, NULL, 'user', 'Tôi muốn đào tạo trực tuyến', 'toi muon dao tao truc tuyen', 'nav_online_training', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:08'),
(12, 2, 11, 'assistant', '<strong>Đào tạo trực tuyến</strong><br>Phần học trực tuyến của UTH nằm trong Portal, nơi bạn có thể xem tài liệu, bài giảng và thông báo lớp học. Nếu bạn đang gặp lỗi đăng nhập hoặc không thấy lớp học, cứ nói rõ lỗi cho mình, mình sẽ giúp bạn xử lý tiếp hoặc tạo ticket hỗ trợ.', 'strong dao tao truc tuyen strong br phan hoc truc tuyen cua uth nam trong portal noi ban co the xem tai lieu bai giang va thong bao lop hoc neu ban dang gap loi dang nhap hoac khong thay lop hoc cu noi ro loi cho minh minh se giup ban xu ly tiep hoac tao ticket ho tro', 'nav_online_training', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database-navigation', NULL, NULL, 24, 1.000000, 'ok', '2026-07-20 19:28:08'),
(13, 2, NULL, 'user', 'hello', 'hello', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:14'),
(14, 2, 13, 'assistant', 'Chào bạn, mình là ChatBot UTH đây! Có gì mình giúp được bạn không?', 'chao ban minh la chatbot uth day co gi minh giup duoc ban khong', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1648, 0.800000, 'ok', '2026-07-20 19:28:15'),
(15, 2, NULL, 'user', 'Lịch học hôm nay', 'lich hoc hom nay', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:19'),
(16, 2, 15, 'assistant', '<strong>Lịch học hôm nay</strong><br>- Thứ 2 07:30-10:00: Lập trình thiết bị di động (MOB101-01), phòng Phòng F101<br>- Thứ 2 13:00-15:30: Thương mại điện tử (ECOM201-01), phòng Phòng B202', 'strong lich hoc hom nay strong br thu 2 07 30 10 00 lap trinh thiet bi di dong mob101 01 phong phong f101 br thu 2 13 00 15 30 thuong mai dien tu ecom201 01 phong phong b202', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', 'database', NULL, NULL, 35, 1.000000, 'ok', '2026-07-20 19:28:19'),
(17, 2, NULL, 'user', 'Xem học phí', 'xem hoc phi', 'personal_tuition', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:21'),
(18, 2, 17, 'assistant', '<strong>Thông tin học phí / công nợ</strong><br>- Học kỳ hè năm học 2025-2026 (HP-075205019210-HE2026): phải thu 17.640.000 VNĐ, đã đóng 8.000.000 VNĐ, còn lại 9.640.000 VNĐ, hạn 20/07/2026, trạng thái đã đóng một phần.', 'strong thong tin hoc phi cong no strong br hoc ky he nam hoc 2025 2026 hp 075205019210 he2026 phai thu 17 640 000 vnd da dong 8 000 000 vnd con lai 9 640 000 vnd han 20 07 2026 trang thai da dong mot phan', 'personal_tuition', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 33, 1.000000, 'ok', '2026-07-20 19:28:21'),
(19, 2, NULL, 'user', 'Xem lịch thi', 'xem lich thi', 'personal_exams', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:23'),
(20, 2, 19, 'assistant', '<strong>Lịch thi hiện có</strong><br>- 24/07/2026 07:30: Lập trình thiết bị di động (cuối kỳ), phòng Phòng C305, SBD/Ghế: A12<br>- 28/07/2026 13:30: Lập trình mạng (cuối kỳ), phòng Phòng D204, SBD/Ghế: B08', 'strong lich thi hien co strong br 24 07 2026 07 30 lap trinh thiet bi di dong cuoi ky phong phong c305 sbd ghe a12 br 28 07 2026 13 30 lap trinh mang cuoi ky phong phong d204 sbd ghe b08', 'personal_exams', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 28, 1.000000, 'ok', '2026-07-20 19:28:23'),
(21, 2, NULL, 'user', 'sắp tới có sự kiện gì k', 'sap toi co su kien gi khong', 'announcements_deadlines', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:33'),
(22, 2, 21, 'assistant', '<strong>Thông báo / deadline liên quan</strong><br>Mình đã lọc ra các mục có khả năng liên quan nhất, bạn xem nhanh bên dưới nhé:<br><br>- Thông báo 08/07/2026: Thông báo công bố lịch thi học kỳ hè 2025-2026 - Lịch thi dự kiến đã được cập nhật, sinh viên kiểm tra phòng thi và ca thi trong Portal.<br><br>Nếu bạn muốn, mình có thể rút gọn lại chỉ còn mục sát nhất với câu hỏi của bạn.', 'strong thong bao deadline lien quan strong br minh da loc ra cac muc co kha nang lien quan nhat ban xem nhanh ben duoi nhe br br thong bao 08 07 2026 thong bao cong bo lich thi hoc ky he 2025 2026 lich thi du kien da duoc cap nhat sinh vien kiem tra phong thi va ca thi trong portal br br neu ban muon minh co the rut gon lai chi con muc sat nhat voi cau hoi cua ban', 'announcements_deadlines', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 54, 0.920000, 'ok', '2026-07-20 19:28:33'),
(23, 2, NULL, 'user', 'hôm nay ngày nhiêu', 'hom nay ngay nhieu', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:28:47'),
(24, 2, 23, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', NULL, NULL, NULL, 375, 0.000000, 'insufficient_context', '2026-07-20 19:28:47'),
(25, 2, NULL, 'user', 'trường mình ai dạy môn lập trình máy tính', 'truong minh ai day mon lap trinh may tinh', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:29:07'),
(26, 2, 25, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 122, 0.000000, 'insufficient_context', '2026-07-20 19:29:07'),
(27, 2, NULL, 'user', 'thi lại phải làm sao', 'thi lai phai lam sao', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:29:27'),
(28, 2, 27, 'assistant', 'Chào bạn, mình là ChatBot UTH đây!<br />\n<br />\nVề việc thi lại, bạn có thể làm đơn xin chuyển ca thi hoặc đăng ký thi ghép vào đợt thi của lớp khác nếu bị trùng lịch thi hoặc có lý do bất khả kháng. Bạn cần mang minh chứng đến Phòng Đào tạo trước ngày thi ít nhất 3 ngày để xử lý nhé.<br />\n<br />\nBạn có muốn hỏi thêm về bảo lưu kết quả hay quy định số lần cảnh báo học vụ không?', 'chao ban minh la chatbot uth day br br ve viec thi lai ban co the lam don xin chuyen ca thi hoac dang ky thi ghep vao dot thi cua lop khac neu bi trung lich thi hoac co ly do bat kha khang ban can mang minh chung den phong dao tao truoc ngay thi it nhat 3 ngay de xu ly nhe br br ban co muon hoi them ve bao luu ket qua hay quy dinh so lan canh bao hoc vu khong', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 2007, 0.815000, 'ok', '2026-07-20 19:29:29'),
(29, 2, NULL, 'user', 'có', 'co', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-20 19:29:38'),
(30, 2, 29, 'assistant', 'Chào bạn, mình là ChatBot UTH đây. Bạn cần mình hỗ trợ thông tin gì nè? 😊', 'chao ban minh la chatbot uth day ban can minh ho tro thong tin gi ne', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1779, 0.900000, 'ok', '2026-07-20 19:29:40'),
(31, 3, NULL, 'user', 'hello', 'hello', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:00:57'),
(32, 3, 31, 'assistant', 'Chào bạn, tôi có thể giúp gì cho bạn?', 'chao ban toi co the giup gi cho ban', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1235, 0.800000, 'ok', '2026-07-21 04:00:58'),
(33, 3, NULL, 'user', 'Lịch học hôm nay', 'lich hoc hom nay', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:00'),
(34, 3, 33, 'assistant', '<strong>Lịch học hôm nay</strong><br>- Thứ 3 07:30-10:00: Lập trình mạng (NET301-01), phòng Phòng D103', 'strong lich hoc hom nay strong br thu 3 07 30 10 00 lap trinh mang net301 01 phong phong d103', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":\"today\"}', 'database', NULL, NULL, 40, 1.000000, 'ok', '2026-07-21 04:01:00'),
(35, 3, NULL, 'user', 'Xem học phí', 'xem hoc phi', 'personal_tuition', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:02'),
(36, 3, 35, 'assistant', '<strong>Thông tin học phí / công nợ</strong><br>- Học kỳ hè năm học 2025-2026 (HP-075205019210-HE2026): phải thu 17.640.000 VNĐ, đã đóng 8.000.000 VNĐ, còn lại 9.640.000 VNĐ, hạn 20/07/2026, trạng thái đã đóng một phần.', 'strong thong tin hoc phi cong no strong br hoc ky he nam hoc 2025 2026 hp 075205019210 he2026 phai thu 17 640 000 vnd da dong 8 000 000 vnd con lai 9 640 000 vnd han 20 07 2026 trang thai da dong mot phan', 'personal_tuition', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 31, 1.000000, 'ok', '2026-07-21 04:01:02'),
(37, 3, NULL, 'user', 'Xem lịch học', 'xem lich hoc', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:03'),
(38, 3, 37, 'assistant', '<strong>Lịch học hiện có</strong><br>- Thứ 2 07:30-10:00: Lập trình thiết bị di động (MOB101-01), phòng Phòng F101<br>- Thứ 2 13:00-15:30: Thương mại điện tử (ECOM201-01), phòng Phòng B202<br>- Thứ 3 07:30-10:00: Lập trình mạng (NET301-01), phòng Phòng D103<br>- Thứ 4 07:30-11:00: Lịch sử Đảng Cộng sản Việt Nam (POL101-01), phòng Hội trường A<br>- Thứ 5 13:00-15:30: Lập trình phân tán (DST401-01), phòng Phòng F304<br>- Thứ 6 07:30-10:00: Quản trị dự án phần mềm (PM401-01), phòng Phòng D201', 'strong lich hoc hien co strong br thu 2 07 30 10 00 lap trinh thiet bi di dong mob101 01 phong phong f101 br thu 2 13 00 15 30 thuong mai dien tu ecom201 01 phong phong b202 br thu 3 07 30 10 00 lap trinh mang net301 01 phong phong d103 br thu 4 07 30 11 00 lich su dang cong san viet nam pol101 01 phong hoi truong a br thu 5 13 00 15 30 lap trinh phan tan dst401 01 phong phong f304 br thu 6 07 30 10 00 quan tri du an phan mem pm401 01 phong phong d201', 'personal_schedule', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 10, 1.000000, 'ok', '2026-07-21 04:01:03'),
(39, 3, NULL, 'user', 'tôi muốn hủy học phần', 'toi muon huy hoc phan', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:10'),
(40, 3, 39, 'assistant', 'Chào bạn, mình có thể giúp bạn hủy học phần nha.<br />\n<br />\nBạn muốn hủy học phần nào vậy? Mình cần biết thêm thông tin về học phần bạn muốn hủy để hỗ trợ bạn tốt hơn.', 'chao ban minh co the giup ban huy hoc phan nha br br ban muon huy hoc phan nao vay minh can biet them thong tin ve hoc phan ban muon huy de ho tro ban tot hon', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1435, 1.000000, 'ok', '2026-07-21 04:01:11'),
(41, 3, NULL, 'user', 'tôi muốn hủy môn lập trình mạng', 'toi muon huy mon lap trinh mang', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:22'),
(42, 3, 41, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 82, 0.000000, 'insufficient_context', '2026-07-21 04:01:22'),
(43, 3, NULL, 'user', 'tôi muốn bạn hủy học phần', 'toi muon ban huy hoc phan', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:35'),
(44, 3, 43, 'assistant', 'Chào bạn, mình hiểu là bạn muốn hủy học phần &quot;Lập trình mạng (NET301-01)&quot; nha.<br />\n<br />\nTheo quy định, bạn có thể nộp đơn online để xin rút bớt học phần đã đăng ký trong vòng 2 tuần đầu của học kỳ chính (hoặc 1 tuần đối với học kỳ hè). Học phần rút thành công sẽ ghi nhận điểm W trên bảng điểm, không tính vào điểm trung bình tích lũy, nhưng bạn sẽ không được hoàn lại học phí.<br />\n<br />\nBạn có muốn mình hỗ trợ thêm thông tin về cách thức nộp đơn online không?', 'chao ban minh hieu la ban muon huy hoc phan quot lap trinh mang net301 01 quot nha br br theo quy dinh ban co the nop don online de xin rut bot hoc phan da dang ky trong vong 2 tuan dau cua hoc ky chinh hoac 1 tuan doi voi hoc ky he hoc phan rut thanh cong se ghi nhan diem w tren bang diem khong tinh vao diem trung binh tich luy nhung ban se khong duoc hoan lai hoc phi br br ban co muon minh ho tro them thong tin ve cach thuc nop don online khong', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1668, 1.000000, 'ok', '2026-07-21 04:01:37'),
(45, 3, NULL, 'user', 'có tôi muốn', 'co toi muon', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:01:50'),
(46, 3, 45, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 84, 0.000000, 'insufficient_context', '2026-07-21 04:01:50'),
(47, 3, NULL, 'user', 'tôi muốn hủy', 'toi muon huy', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:02:01'),
(48, 3, 47, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 89, 0.000000, 'insufficient_context', '2026-07-21 04:02:01'),
(49, 3, NULL, 'user', 'Tôi muốn đăng ký học phần', 'toi muon dang ky hoc phan', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-21 04:02:20'),
(50, 3, 49, 'assistant', 'Chào bạn, mình có thể giúp bạn đăng ký học phần nha.<br />\n<br />\nBạn muốn đăng ký học phần cho học kỳ nào vậy? Mình cần biết thêm thông tin về học kỳ bạn muốn đăng ký để hỗ trợ bạn tốt hơn.', 'chao ban minh co the giup ban dang ky hoc phan nha br br ban muon dang ky hoc phan cho hoc ky nao vay minh can biet them thong tin ve hoc ky ban muon dang ky de ho tro ban tot hon', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1647, 1.000000, 'ok', '2026-07-21 04:02:21'),
(51, 3, NULL, 'user', 'nono', 'nono', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-22 22:56:35'),
(52, 3, 51, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 124, 0.000000, 'insufficient_context', '2026-07-22 22:56:35'),
(53, 3, NULL, 'user', 'tạo ticket', 'tao ticket', 'create_ticket', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-22 22:56:50'),
(54, 3, 53, 'assistant', 'TICKET_CONFIRM:tạo ticket', 'ticket confirm tao ticket', 'create_ticket', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'deterministic', NULL, NULL, 26, 1.000000, 'ok', '2026-07-22 22:56:50'),
(55, 3, NULL, 'user', 'trường hutech có gần uth không', 'truong hutech co gan uth khong', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-23 13:52:53'),
(56, 3, 55, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 116, 0.000000, 'insufficient_context', '2026-07-23 13:52:53'),
(57, 3, NULL, 'user', 'tạo ticket vấn đề vị trí trường học', 'tao ticket van de vi tri truong hoc', 'create_ticket', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-07-23 13:53:35'),
(58, 3, 57, 'assistant', 'TICKET_CONFIRM:tạo ticket vấn đề vị trí trường học', 'ticket confirm tao ticket van de vi tri truong hoc', 'create_ticket', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'deterministic', NULL, NULL, 13, 1.000000, 'ok', '2026-07-23 13:53:35'),
(59, 3, NULL, 'user', 'hello', 'hello', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:14:06'),
(60, 3, 59, 'assistant', 'Chào bạn, tôi có thể giúp gì cho bạn?', 'chao ban toi co the giup gi cho ban', 'small_talk', '{\"semester_code\":\"SUMMER\",\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1660, 0.800000, 'ok', '2026-08-01 18:14:08'),
(61, 3, NULL, 'user', 'Xem điểm của tôi', 'xem diem cua toi', 'personal_grades', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:14:11'),
(62, 3, 61, 'assistant', '<strong>Kết quả học tập hiện có</strong><br>- Lập trình mạng (NET301, Học kỳ hè năm học 2025-2026): chưa công bố<br>- Lập trình phân tán (DST401, Học kỳ hè năm học 2025-2026): chưa công bố<br>- Lập trình thiết bị di động (MOB101, Học kỳ hè năm học 2025-2026): 8.30/10 - điểm chữ B+<br>- Lịch sử Đảng Cộng sản Việt Nam (POL101, Học kỳ hè năm học 2025-2026): chưa công bố<br>- Quản trị dự án phần mềm (PM401, Học kỳ hè năm học 2025-2026): chưa công bố<br>- Thương mại điện tử (ECOM201, Học kỳ hè năm học 2025-2026): 7.90/10 - điểm chữ B<br>Lưu ý: đây là dữ liệu đang có trong database portal, không thay thế bảng điểm chính thức của Phòng Đào tạo.', 'strong ket qua hoc tap hien co strong br lap trinh mang net301 hoc ky he nam hoc 2025 2026 chua cong bo br lap trinh phan tan dst401 hoc ky he nam hoc 2025 2026 chua cong bo br lap trinh thiet bi di dong mob101 hoc ky he nam hoc 2025 2026 8 30 10 diem chu b br lich su dang cong san viet nam pol101 hoc ky he nam hoc 2025 2026 chua cong bo br quan tri du an phan mem pm401 hoc ky he nam hoc 2025 2026 chua cong bo br thuong mai dien tu ecom201 hoc ky he nam hoc 2025 2026 7 90 10 diem chu b br luu y day la du lieu dang co trong database portal khong thay the bang diem chinh thuc cua phong dao tao', 'personal_grades', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'database', NULL, NULL, 23, 1.000000, 'ok', '2026-08-01 18:14:11'),
(63, 3, NULL, 'user', 'tôi muốn vị trí trương mình', 'toi muon vi tri truong minh', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:14:28'),
(64, 3, 63, 'assistant', 'Chào bạn, mình có thể giúp bạn tìm hiểu về vị trí trường UTH nha.<br />\n<br />\nBạn muốn hỏi về vị trí của trường UTH so với trường Hutech hay vị trí cụ thể của trường UTH ở đâu?', 'chao ban minh co the giup ban tim hieu ve vi tri truong uth nha br br ban muon hoi ve vi tri cua truong uth so voi truong hutech hay vi tri cu the cua truong uth o dau', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 1611, 0.890000, 'ok', '2026-08-01 18:14:29'),
(65, 3, NULL, 'user', 'UTH á', 'uth a', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:14:41'),
(66, 3, 65, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 94, 0.000000, 'insufficient_context', '2026-08-01 18:14:41'),
(67, 3, NULL, 'user', 'vị trí trường UTH', 'vi tri truong uth', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:14:50'),
(68, 3, 67, 'assistant', '<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'strong minh chua chac ban dang muon hoi gi strong br de minh ho tro dung hon ban co the noi ro mot trong cac huong sau lich hoc lich thi hoc phi diem thong bao hoac nhap lai cau hoi theo cach ngan hon mot chut', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, 95, 0.000000, 'insufficient_context', '2026-08-01 18:14:50'),
(69, 3, NULL, 'user', 'bị rớt môn', 'bi thi truot mon hoc', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', NULL, NULL, NULL, NULL, NULL, 'ok', '2026-08-01 18:15:01'),
(70, 3, 69, 'assistant', 'Chào bạn, mình hiểu là bạn đang lo lắng về việc bị rớt môn đúng không?<br />\n<br />\nTheo quy chế khen thưởng của UTH, nếu bạn bị rớt môn (nhận điểm F) hoặc đăng ký thi lại/học lại bất kỳ môn nào trong học kỳ đó thì sẽ không được xét học bổng khuyến khích học tập, dù điểm GPA của bạn có cao đi chăng nữa.<br />\n<br />\nBạn có muốn mình cung cấp thêm thông tin về các loại học bổng khác không, ví dụ như học bổng doanh nghiệp hay học bổng liên kết chẳng hạn?', 'chao ban minh hieu la ban dang lo lang ve viec bi thi truot mon hoc dung khong br br theo quy che khen thuong cua uth neu ban bi thi truot mon hoc nhan diem f hoac dang ky thi lai hoc lai bat ky mon nao trong hoc ky do thi se khong duoc xet hoc bong khuyen khich hoc tap du diem gpa cua ban co cao di chang nua br br ban co muon minh cung cap them thong tin ve cac loai hoc bong khac khong vi du nhu hoc bong doanh nghiep hay hoc bong lien ket chang han', 'academic_knowledge', '{\"semester_code\":null,\"academic_year_code\":null,\"cohort_year\":null,\"date_scope\":null}', 'gemini-2.5-flash-lite', NULL, NULL, 2233, 0.840000, 'ok', '2026-08-01 18:15:03');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chat_sessions`
--

CREATE TABLE `chat_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `session_uuid` char(36) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `channel` enum('web','mobile','admin','api') NOT NULL DEFAULT 'web',
  `status` enum('active','closed','archived') NOT NULL DEFAULT 'active',
  `language_code` varchar(10) NOT NULL DEFAULT 'vi',
  `context_summary` text DEFAULT NULL,
  `started_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_activity_at` datetime NOT NULL DEFAULT current_timestamp(),
  `closed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `chat_sessions`
--

INSERT INTO `chat_sessions` (`id`, `session_uuid`, `user_id`, `title`, `channel`, `status`, `language_code`, `context_summary`, `started_at`, `last_activity_at`, `closed_at`) VALUES
(1, 'df02fbcb-82c6-4ec0-a02d-29f94834de7e', 2, 'Ngày mai mình có lịch học gì?', 'web', 'active', 'vi', NULL, '2026-07-11 16:56:53', '2026-07-11 16:57:25', NULL),
(2, '540a7c44-6b71-4fbd-aace-775f024ced3f', NULL, 'Tôi muốn đào tạo trực tuyến', 'web', 'active', 'vi', NULL, '2026-07-20 19:28:08', '2026-07-20 19:29:38', NULL),
(3, '31996739-b86b-4e37-b14e-73cf1c0fedac', 2, 'hello', 'web', 'active', 'vi', NULL, '2026-07-21 04:00:57', '2026-08-01 18:15:01', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `class_schedules`
-- (See below for the actual view)
--
CREATE TABLE `class_schedules` (
`id` bigint(20) unsigned
,`mssv` varchar(50)
,`subject_name` varchar(255)
,`room` varchar(100)
,`day_of_week` tinyint(3) unsigned
,`start_time` time
,`end_time` time
);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `class_schedule_sessions`
--

CREATE TABLE `class_schedule_sessions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_section_id` bigint(20) UNSIGNED NOT NULL,
  `day_of_week` tinyint(3) UNSIGNED NOT NULL COMMENT '1=Monday ... 7=Sunday',
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room` varchar(100) DEFAULT NULL,
  `campus` varchar(255) DEFAULT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `online_meeting_url` varchar(500) DEFAULT NULL
) ;

--
-- Đang đổ dữ liệu cho bảng `class_schedule_sessions`
--

INSERT INTO `class_schedule_sessions` (`id`, `course_section_id`, `day_of_week`, `start_time`, `end_time`, `room`, `campus`, `valid_from`, `valid_until`, `online_meeting_url`) VALUES
(1, 1, 1, '07:30:00', '10:00:00', 'Phòng F101', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL),
(2, 2, 1, '13:00:00', '15:30:00', 'Phòng B202', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL),
(3, 3, 2, '07:30:00', '10:00:00', 'Phòng D103', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL),
(4, 4, 3, '07:30:00', '11:00:00', 'Hội trường A', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL),
(5, 5, 4, '13:00:00', '15:30:00', 'Phòng F304', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL),
(6, 6, 5, '07:30:00', '10:00:00', 'Phòng D201', 'Cơ sở chính', '2026-06-01', '2026-07-31', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `course_sections`
--

CREATE TABLE `course_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `section_code` varchar(50) NOT NULL,
  `lecturer_name` varchar(150) DEFAULT NULL,
  `capacity` smallint(5) UNSIGNED DEFAULT NULL,
  `registered_count` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `delivery_mode` enum('offline','online','hybrid') NOT NULL DEFAULT 'offline',
  `status` enum('planned','open','closed','cancelled','completed') NOT NULL DEFAULT 'open',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `course_sections`
--

INSERT INTO `course_sections` (`id`, `semester_id`, `subject_id`, `section_code`, `lecturer_name`, `capacity`, `registered_count`, `delivery_mode`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'MOB101-01', 'ThS. Nguyễn Văn A', 45, 36, 'offline', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(2, 1, 2, 'ECOM201-01', 'ThS. Trần Thị B', 45, 34, 'hybrid', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(3, 1, 3, 'NET301-01', 'ThS. Lê Văn C', 45, 38, 'offline', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(4, 1, 4, 'POL101-01', 'TS. Phạm Thị D', 80, 72, 'offline', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(5, 1, 5, 'DST401-01', 'ThS. Hoàng Minh E', 40, 31, 'offline', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(6, 1, 6, 'PM401-01', 'ThS. Võ Thanh F', 50, 41, 'online', 'open', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `enrollments`
--

CREATE TABLE `enrollments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `course_section_id` bigint(20) UNSIGNED NOT NULL,
  `enrollment_status` enum('registered','studying','withdrawn','completed','failed','cancelled') NOT NULL DEFAULT 'registered',
  `registered_at` datetime NOT NULL DEFAULT current_timestamp(),
  `withdrawn_at` datetime DEFAULT NULL,
  `final_result` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `enrollments`
--

INSERT INTO `enrollments` (`id`, `student_id`, `course_section_id`, `enrollment_status`, `registered_at`, `withdrawn_at`, `final_result`) VALUES
(1, 1, 5, 'studying', '2026-06-01 09:00:00', NULL, NULL),
(2, 1, 2, 'studying', '2026-06-01 09:00:00', NULL, NULL),
(3, 1, 1, 'studying', '2026-06-01 09:00:00', NULL, NULL),
(4, 1, 3, 'studying', '2026-06-01 09:00:00', NULL, NULL),
(5, 1, 6, 'studying', '2026-06-01 09:00:00', NULL, NULL),
(6, 1, 4, 'studying', '2026-06-01 09:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `exam_schedules`
--

CREATE TABLE `exam_schedules` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `course_section_id` bigint(20) UNSIGNED NOT NULL,
  `exam_type` enum('midterm','final','retake','improvement','other') NOT NULL DEFAULT 'final',
  `exam_date` date NOT NULL,
  `start_time` time NOT NULL,
  `duration_minutes` smallint(5) UNSIGNED NOT NULL,
  `room` varchar(100) DEFAULT NULL,
  `campus` varchar(255) DEFAULT NULL,
  `seat_number` varchar(30) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `published_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `exam_schedules`
--

INSERT INTO `exam_schedules` (`id`, `course_section_id`, `exam_type`, `exam_date`, `start_time`, `duration_minutes`, `room`, `campus`, `seat_number`, `notes`, `published_at`) VALUES
(1, 1, 'final', '2026-07-24', '07:30:00', 90, 'Phòng C305', 'Cơ sở chính', 'A12', 'Mang theo thẻ sinh viên khi dự thi.', '2026-07-08 08:00:00'),
(2, 3, 'final', '2026-07-28', '13:30:00', 90, 'Phòng D204', 'Cơ sở chính', 'B08', 'Có mặt trước giờ thi 15 phút.', '2026-07-08 08:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `faculties`
--

CREATE TABLE `faculties` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(255) NOT NULL,
  `office_location` varchar(255) DEFAULT NULL,
  `email` varchar(190) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `faculties`
--

INSERT INTO `faculties` (`id`, `code`, `name`, `office_location`, `email`, `phone`, `status`, `created_at`, `updated_at`) VALUES
(1, 'FIT', 'Khoa Công nghệ thông tin', 'Khu nhà C - Cơ sở chính', 'fit@ut.edu.vn', '028 3899 2862', 'active', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `faq`
--

CREATE TABLE `faq` (
  `id` int(10) UNSIGNED NOT NULL,
  `topic_group` varchar(255) DEFAULT NULL COMMENT 'Nhom chu de',
  `tu_khoa` text NOT NULL COMMENT 'Cau hoi / tu khoa sinh vien hay go',
  `noi_dung` text NOT NULL COMMENT 'Noi dung tra loi chuan xac cua truong',
  `variations` text DEFAULT NULL COMMENT 'Cac cach hoi khac nhau cho cung 1 noi dung',
  `priority` int(11) NOT NULL DEFAULT 0 COMMENT 'Trong so uu tien tim kiem, cang cao cang uu tien',
  `link_dieu_huong` varchar(255) DEFAULT NULL COMMENT 'Link dieu huong den muc lien quan'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Kho tri thuc FAQ truong UTH';

--
-- Đang đổ dữ liệu cho bảng `faq`
--

INSERT INTO `faq` (`id`, `topic_group`, `tu_khoa`, `noi_dung`, `variations`, `priority`, `link_dieu_huong`) VALUES
(1, 'Thông tin chung', 'Địa chỉ trường ở đâu? UTH có mấy cơ sở? Trường nằm ở chỗ nào?', 'Trường Đại học Giao thông Vận tải TP.HCM (UTH) có cơ sở chính tại Số 2, Đường Võ Oanh, Phường 25, Quận Bình Thạnh, TP.HCM. Ngoài ra, trường còn có các cơ sở đào tạo khác tại Quận 12 (TP.HCM), TP. Thủ Đức và TP. Vũng Tàu. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về bãi giữ xe của trường, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(2, 'Chương trình Đào tạo', 'Trường có những ngành gì? Ngành CNTT học hệ nào? Đào tạo chất lượng cao là sao?', 'UTH là trường công lập đào tạo đa ngành hàng đầu về Giao thông vận tải, Logistics, Công nghệ thông tin, Khoa học dữ liệu, Điện tử viễn thông, Kinh tế vận tải và Kỹ thuật công trình. Hệ đào tạo gồm 2 loại hình: Hệ Đại trà và Hệ Chất lượng cao. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian nhận bằng tốt nghiệp và về xin hoãn đi thực tập tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/chuong-trinh-khung'),
(3, 'Cách Tính Điểm', 'Cách tính điểm môn học thế nào? Điểm F là gì? Quy chế thang điểm chữ?', 'UTH áp dụng đào tạo theo hệ thống tín chỉ. Điểm tổng kết môn gồm: Điểm quá trình và Điểm thi kết thúc học phần. Điểm tính theo thang điểm 10 rồi quy đổi sang thang điểm chữ (A, B, C, D, F) tương ứng với thang điểm 4. Điểm F là rớt môn và bắt buộc phải đóng tiền đăng ký học lại. Ngoài ra, nếu bạn còn thắc mắc về xét giảm điểm rèn luyện hoặc về phúc khảo điểm thi, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/ket-qua-hoc-tap'),
(4, 'Học Cải Thiện', 'Điểm thấp có được học lại không? Làm sao để nâng điểm tích lũy?', 'Sinh viên đạt điểm trung bình môn ở mức D, D+, C, C+ muốn nâng cao điểm trung bình tích lũy (GPA) được phép đăng ký học cải thiện vào các học kỳ tiếp theo. Khi học cải thiện, điểm của lần học sau sẽ thay thế hoàn toàn cho điểm của lần học trước. Bên cạnh đó, nếu bạn cũng quan tâm về xét giảm điểm rèn luyện, hay về quy trình chấm điểm rèn luyện, cứ hỏi mình thêm nha.', NULL, 0, '/ket-qua-hoc-tap'),
(5, 'Cảnh Báo Học Vụ', 'Điều kiện xét nâng lớp? Khi nào bị cảnh báo học vụ? Bị buộc thôi học khi nào?', 'Sinh viên sẽ bị cảnh báo học vụ nếu điểm trung bình tích lũy học kỳ đạt dưới 0.8 (đối với học kỳ đầu tiên) hoặc dưới 1.0 (đối với các học kỳ tiếp theo), hoặc số tín chỉ bị nợ vượt quá quy định. Bị cảnh báo học vụ 2 lần liên tiếp sẽ thuộc diện xem xét buộc thôi học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xét giảm điểm rèn luyện và về điểm rèn luyện f — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(6, 'Đăng Ký Môn Học', 'Khi nào đăng ký học phần? Một kỳ được đăng ký tối đa bao nhiêu tín chỉ? Hủy môn học ở đâu?', 'Sinh viên thực hiện đăng ký học phần (DKMH) trực tuyến tại trang Portal UTH theo khung thời gian thông báo của Phòng Đào tạo. Sinh viên hệ đại trà được đăng ký tối đa 24 tín chỉ và tối thiểu 14 tín chỉ trong một học kỳ chính. Ngoài ra, nếu bạn còn thắc mắc về quy định số lần cảnh báo học vụ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dang-ky-hoc-phan'),
(7, 'Môn Điều Kiện', 'Môn tiên quyết là gì? Môn học trước là gì? Khác nhau thế nào?', 'Môn tiên quyết là môn sinh viên bắt buộc phải học và thi đạt (điểm chữ từ D trở lên) mới được đăng ký môn tiếp theo. Môn học trước là môn sinh viên chỉ cần hoàn thành khóa học (kể cả thi rớt điểm F) là đã đủ điều kiện đăng ký môn sau. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình chấm điểm rèn luyện, hay về bảo lưu kết quả, cứ hỏi mình thêm nha.', NULL, 0, '/dang-ky-mon-hoc-dieu-kien'),
(8, 'Quy Chế Thi Cử', 'Xem lịch thi ở đâu? Vào phòng thi cần mang gì? Hoãn thi làm sao?', 'Lịch thi học kỳ được công bố trên Portal trước kỳ thi 2 tuần. Khi vào phòng thi, sinh viên bắt buộc phải xuất trình Thẻ sinh viên chính thức hoặc giấy tờ tùy thân có ảnh (CCCD). Sinh viên vắng thi không có lý do chính đáng sẽ nhận điểm 0. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về bảo lưu kết quả và về rút học phần, hủy môn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/lich-hoc-trong-tuan'),
(9, 'Học Phí Trường', 'Học phí năm 2025 các ngành UTH? Học phí 2025 từng ngành? Học phí các ngành bao nhiêu? Học phí một tín chỉ bao nhiêu tiền? Học phí chương trình chuẩn 2025? Học phí chương trình tiên tiến 2025? Học phí đại trà 2025? Đóng tiền học ở đâu?', 'Học phí UTH được tính theo số tín chỉ đăng ký mỗi học kỳ và loại chương trình, không phải một mức cố định riêng cho từng ngành. Với khóa 2025 trong dữ liệu hiện có: chương trình chuẩn (đại trà) 400.000đ/tín chỉ; chương trình tiên tiến (trước đây gọi là Chất lượng cao) 980.000đ/tín chỉ. Với tân sinh viên khóa 2026: chương trình chuẩn 515.000đ/tín chỉ; chương trình tiên tiến 1.120.000đ/tín chỉ; chương trình hoàn toàn bằng tiếng Anh 1.500.000đ/tín chỉ. Tổng học phí mỗi học kỳ = đơn giá tín chỉ x số tín chỉ đăng ký, nên các ngành khác nhau có thể khác tổng tiền vì khác chương trình đào tạo hoặc số tín chỉ học trong kỳ. Trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học của mỗi khóa. Sinh viên nộp học phí trực tuyến qua Cổng thanh toán của trường (payment.ut.edu.vn) và nên tra cứu số tiền chính xác trên Portal cá nhân. Ngoài ra, nếu bạn còn thắc mắc về học phí chương trình tiên tiến hoặc về gia hạn học phí, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/cong-thanh-toan'),
(10, 'Gia Hạn Học Phí', 'Không có tiền đóng học phí làm sao? Xin nợ học phí ở đâu?', 'Sinh viên có hoàn cảnh khó khăn không thể hoàn thành học phí đúng hạn phải làm Đơn xin gia hạn học phí trực tuyến gửi Phòng Công tác sinh viên trước thời hạn quy định để không bị khóa tài khoản đăng ký môn học và bị cấm thi. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', NULL, 0, '/tra-cuu-cong-no'),
(11, 'Hoạt Động Đoàn Hội', 'Lịch hiến máu tình nguyện? Tham gia hoạt động được cộng bao nhiêu điểm rèn luyện?', 'Ngày hội hiến máu tình nguyện trường UTH được tổ chức định kỳ hàng năm tại Sảnh lớn khu giảng đường A. Sinh viên tham gia hiến máu nhân đạo sẽ được cấp giấy chứng nhận, hỗ trợ chi phí và được cộng 5 điểm rèn luyện (ĐRL) vào mục hoạt động cộng đồng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về ngày hội sáng tạo và về học bổng doanh nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(12, 'Các Câu Lạc Bộ', 'Trường có CLB guitar không? Đội tình nguyện hoạt động thế nào?', 'UTH hiện có hơn 20 Câu lạc bộ (CLB) sinh viên đang hoạt động thuộc các khối: Học thuật (CLB Tin học, CLB Logistics), Nghệ thuật (CLB Guitar, CLB Bước Nhảy), Thể thao (CLB Bóng đá, Bóng chuyền) và Tình nguyện (Đội Công tác xã hội, CLB Tiếp sức đến trường). Ngoài ra, nếu bạn còn thắc mắc về hoạt động đoàn hội hoặc về đăng ký tham gia hiến máu đợt hè, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(13, 'Học Bổng Khuyến Khích', 'Điều kiện nhận học bổng trường? Điểm rèn luyện bao nhiêu thì được học bổng?', 'Học bổng khuyến khích học tập UTH được xét sau mỗi học kỳ dựa trên 2 tiêu chí song song: Điểm trung bình học tập đạt loại Khá trở lên (từ 2.5/4.0) và Điểm rèn luyện đạt loại Tốt trở lên (từ 80 điểm/100), đồng thời không bị kỷ luật và không nợ môn. Bên cạnh đó, nếu bạn cũng quan tâm về chiến sĩ tình nguyện, hay về giải chạy sinh viên, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(14, 'Chuẩn Đầu Ra Ngoại Ngữ', 'Chuẩn tiếng Anh xét tốt nghiệp? Nộp bằng TOEIC ở đâu? Điều kiện miễn học Anh văn?', 'Sinh viên đại học chính quy UTH phải đạt chuẩn đầu ra tiếng Anh theo quy định (thường là TOEIC 450 trở lên hoặc B1 VSTEP tùy theo ngành học). Chứng chỉ phải còn giá trị hiệu lực và nộp về Trung tâm Ngoại ngữ trường để làm thủ tục hậu kiểm xét tốt nghiệp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về đăng ký thi lại chuẩn đầu ra — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(15, 'Chuẩn Tin Học', 'Chuẩn tin học đầu ra là gì? Chứng chỉ MOS hay IC3?', 'Sinh viên UTH bắt buộc phải hoàn thành chuẩn đầu ra Tin học bằng việc đạt chứng chỉ Tin học đại chúng đại học hoặc các chứng chỉ quốc tế được công nhận tương đương như MOS (đạt 3 kỹ năng Word, Excel, Powerpoint) hoặc IC3. Ngoài ra, nếu bạn còn thắc mắc về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH hoặc về chuẩn tin học quốc tế nâng cao, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(16, 'Điều Kiện Tốt Nghiệp', 'Làm sao để được ra trường? Điều kiện xét tốt nghiệp UTH? Nợ môn có được xét tốt nghiệp?', 'Điều kiện xét công nhận tốt nghiệp UTH: Tích lũy đủ số tín chỉ của chương trình khung; Điểm trung bình tích lũy (GPA) toàn khóa đạt từ 2.0/4.0 trở lên; Đạt chuẩn đầu ra Ngoại ngữ và Tin học; Đạt chứng chỉ Giáo dục quốc phòng và Giáo dục thể chất; Không trong thời gian bị kỷ luật. Bên cạnh đó, nếu bạn cũng quan tâm về chuyển cơ sở học tập, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', NULL, 0, '/chuong-trinh-khung'),
(17, 'Mất Thẻ Sinh Viên', 'Làm lại thẻ sinh viên ở đâu? Mất thẻ sinh viên đóng phạt bao nhiêu?', 'Khi bị mất thẻ, sinh viên đến Phòng Công tác sinh viên (Cơ sở chính, khu nhà A) để làm thủ tục xin cấp lại thẻ sinh viên mới. Lệ phí cấp lại thẻ theo quy định là 50.000đ. Trong thời gian chờ cấp thẻ mới, sinh viên được cấp giấy xác nhận tạm thời để ra vào trường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về quy định mượn học cụ, thiết bị tại phòng thí nghiệm — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(18, 'Ký Túc Xá Trường', 'Đăng ký ở KTX ở đâu? Chi phí Ký túc xá UTH? Đối tượng ưu tiên ở KTX?', 'UTH hỗ trợ chỗ ở tại Ký túc xá trường cho sinh viên (ưu tiên sinh viên diện chính sách, vùng sâu vùng xa, hoàn cảnh khó khăn). Sinh viên làm Đơn đăng ký nội trú trực tuyến trên Portal hoặc nộp hồ sơ trực tiếp tại Ban quản lý Ký túc xá trong thời gian quy định đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về liên hệ ban quản lý ký túc xá hoặc về ký túc xá quận 12, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(19, 'Mượn Sách Thư Viện', 'Thư viện trường ở đâu? Cách mượn sách về nhà? Trả sách trễ hạn bị phạt thế nào?', 'Thư viện UTH đặt tại khu vực cơ sở chính. Sinh viên sử dụng Thẻ sinh viên để vào thư viện đọc sách hoặc làm thủ tục mượn tài liệu về nhà. Thời gian mượn tối đa là 2 tuần/cuốn. Nếu trả sách trễ hạn, sinh viên sẽ bị phạt tiền theo quy định của thư viện. Bên cạnh đó, nếu bạn cũng quan tâm về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, hay về bảng điểm tiếng anh, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(20, 'Bảo Hiểm Y Tế', 'Đóng tiền bảo hiểm y tế ở đâu? Hạn chót nộp BHYT? Gia hạn bảo hiểm sinh viên?', 'Bảo hiểm y tế (BHYT) là hình thức bắt buộc đối với tất cả sinh viên. Nhà trường tổ chức thu tiền và gia hạn BHYT định kỳ vào đầu năm học thông qua Cổng thanh toán trực tuyến. Sinh viên có thẻ BHYT diện hộ nghèo, thân nhân quân nhân phải nộp bản photo minh chứng để được miễn giảm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đóng lệ phí thi lại và về phí phạt nợ học phí quá hạn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/cong-thanh-toan'),
(21, 'Sinh Viên 5 Tốt', 'Tiêu chí đạt Sinh viên 5 Tốt? Quyền lợi khi đạt Sinh viên 5 Tốt UTH?', 'Danh hiệu Sinh viên 5 Tốt được xét duyệt hàng năm dựa trên 5 tiêu chí: Học tập tốt (GPA >= 3.2 hoặc 2.8 tùy hệ), Đạo đức tốt (ĐRL >= 80), Thể lực tốt (đạt danh hiệu khỏe), Tình nguyện tốt (tham gia chiến dịch lớn), và Hội nhập tốt (đạt giải thưởng khoa học hoặc kỹ năng ngoại ngữ tốt). Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về khen thưởng sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(22, 'Nghiên Cứu Khoa Học', 'Đăng ký nghiên cứu khoa học ở đâu? Quyền lợi khi làm NCKH sinh viên?', 'Phong trào Nghiên cứu khoa học (NCKH) sinh viên UTH được phát động vào đầu học kỳ 1. Sinh viên đăng ký đề tài theo nhóm (dưới sự hướng dẫn của giảng viên) thông qua Phòng Quản lý khoa học. Đề tài nghiệm thu đạt loại Khá trở lên sẽ được cộng điểm rèn luyện và thưởng tiền mặt. Bên cạnh đó, nếu bạn cũng quan tâm về đại hội đoàn, hay về giải bóng đá UTH, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(23, 'Rút Học Phần, Hủy Môn', 'Cách rút môn học? Hạn chót hủy học phần đã đăng ký? Rút môn có được hoàn tiền không?', 'Trong 2 tuần đầu của học kỳ chính (hoặc 1 tuần đối với học kỳ hè), sinh viên được phép nộp đơn online để xin rút bớt học phần đã đăng ký. Học phần xin rút thành công sẽ ghi nhận điểm chữ W trên bảng điểm, không tính vào điểm trung bình tích lũy nhưng sinh viên không được hoàn lại học phí. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy chế thi cử và về quy trình chấm điểm rèn luyện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dang-ky-hoc-phan'),
(24, 'Phòng Công Tác Sinh Viên', 'Liên hệ phòng CTSV ở đâu? Xin giấy xác nhận sinh viên vay vốn ở đâu?', 'Phòng Công tác sinh viên (CTSV) chịu trách nhiệm giải quyết các thủ tục: Cấp giấy xác nhận sinh viên để vay vốn ngân hàng, tạm hoãn nghĩa vụ quân sự, đánh giá điểm rèn luyện, giải quyết chế độ chính sách, miễn giảm học phí. Văn phòng đặt tại tầng trệt nhà A cơ sở chính. Ngoài ra, nếu bạn còn thắc mắc về minh chứng ĐRL hoặc về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(25, 'Phòng Đào Tạo', 'Số điện thoại Phòng Đào tạo? Hỏi về lịch học, lịch thi, xét tốt nghiệp ở đâu?', 'Phòng Đào tạo UTH là nơi giải quyết các vấn đề chuyên môn về: Khung lịch học, lịch thi, giải quyết đơn phúc khảo điểm thi, cấp bảng điểm chính thức, xử lý hồ sơ chuyển ngành, ngừng học tạm thời, bảo lưu kết quả, và xét công nhận tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về các tuyến xe buýt, hay về đại hội đoàn, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(26, 'Ký Túc Xá Quận 12', 'KTX Quận 12 ở đâu? Đăng ký ký túc xá cơ sở 2? Chi phí phòng KTX Quận 12?', 'Cơ sở 2 của UTH tại Quận 12 có khu Ký túc xá khang trang dành riêng cho sinh viên học tập tại đây. Chi phí nội trú dao động từ 150.000đ - 250.000đ/tháng/sinh viên tùy loại phòng. Sinh viên nộp đơn đăng ký trực tiếp tại Ban quản lý KTX Cơ sở 2. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về ký túc xá trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(27, 'Học Bổng Doanh Nghiệp', 'Học bổng tài trợ? Điều kiện nhận học bổng ngoài ngân sách? Học bổng vượt khó?', 'Ngoài học bổng khuyến khích của trường, sinh viên UTH còn có cơ hội nhận Học bổng tài trợ từ các tập đoàn, doanh nghiệp lớn đối tác (như các tổng công ty xây dựng, cảng biển, công ty công nghệ). Tiêu chí xét tuyển thường ưu tiên sinh viên nghèo vượt khó học giỏi hoặc có thành tích xuất sắc. Ngoài ra, nếu bạn còn thắc mắc về giải chạy sinh viên hoặc về học bổng liên kết, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(28, 'Các Tuyến Xe Buýt', 'Xe buýt nào đi qua trường UTH? Đi xe bus đến Võ Oanh? Xe bus qua cơ sở Bình Thạnh?', 'Cơ sở chính Võ Oanh (Bình Thạnh) có rất nhiều tuyến xe buýt đi qua như tuyến số 08, 14, 19, 43, 44, 93 (dừng tại trạm Điện Biên Phủ hoặc Nguyễn Văn Thương rồi đi bộ vào). Sinh viên được hưởng giá vé ưu đãi khi xuất trình Thẻ sinh viên UTH. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về thời gian giữ xe tối đa tại trường, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(29, 'Thủ Tục Chuyển Ngành', 'Làm sao để đổi ngành học? Điều kiện chuyển ngành UTH? Đang học có được đổi ngành khác?', 'Sinh viên được xem xét chuyển ngành nếu: Không thuộc diện bị buộc thôi học; Điểm xét tuyển đầu vào không thấp hơn điểm trúng tuyển của ngành muốn chuyển sang; Có đơn xin chuyển ngành và được sự đồng ý của cả hai Khoa chủ quản. Thủ tục làm tại Phòng Đào tạo vào cuối năm học thứ nhất. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký môn học và về cảnh báo học vụ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(30, 'Bảo Lưu Kết Quả', 'Xin tạm dừng học? Cách làm đơn bảo lưu học tập? Nghỉ học tạm thời được bao lâu?', 'Sinh viên được xin nghỉ học tạm thời và bảo lưu kết quả học tập vì lý do cá nhân (như sức khỏe, hoàn cảnh gia đình hoặc thực hiện nghĩa vụ quân sự). Thời gian tạm dừng học không quá 2 học kỳ chính và phải làm đơn nộp về Phòng Đào tạo trước khi học kỳ mới bắt đầu. Ngoài ra, nếu bạn còn thắc mắc về đăng ký môn học hoặc về quy định số lần cảnh báo học vụ, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(31, 'Phúc Khảo Điểm Thi', 'Chấm phúc khảo ở đâu? Lệ phí phúc khảo bài thi? Thời hạn nộp đơn chấm phúc khảo?', 'Nếu thấy điểm thi kết thúc học phần không chính xác, sinh viên có quyền làm Đơn xin phúc khảo bài thi nộp về Phòng Đào tạo hoặc văn phòng Khoa trong vòng 5 ngày làm việc kể từ ngày công bố điểm. Lệ phí phúc khảo theo quy định hiện hành của trường. Bên cạnh đó, nếu bạn cũng quan tâm về quy định số lần cảnh báo học vụ, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', NULL, 0, '/ket-qua-hoc-tap'),
(32, 'Đồng Phục & Trang Phục', 'Quy định đồng phục UTH? Mặc áo gì đi học? Có bắt buộc mặc áo trường không?', 'Sinh viên khi đến trường UTH phải ăn mặc lịch sự, gọn gàng, không mặc quần đùi, áo ba lỗ, dép lê vào lớp. Nhà trường khuyến khích sinh viên mặc Áo thun đồng phục UTH hoặc áo sơ mi trắng vào các ngày lễ, các buổi sinh hoạt chung và các ngày cố định theo quy định của Khoa. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký cấp lại tài khoản email sinh viên và về phòng đào tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(33, 'Kỷ Luật Học Đường', 'Quy chế kỷ luật sinh viên? Đi thi gian lận bị phạt thế nào? Quay cóp bài thi bị xử lý sao?', 'Sinh viên vi phạm quy chế thi cử (như mang tài liệu, điện thoại vào phòng thi, quay cóp) sẽ bị xử lý kỷ luật nghiêm khắc từ Đình chỉ thi môn đó, Nhận điểm 0, Cảnh cáo trước toàn trường, cho đến đình chỉ học tập có thời hạn hoặc buộc thôi học nếu tái phạm nhiều lần. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(34, 'Văn Phòng Khoa CNTT', 'Liên hệ khoa CNTT ở đâu? Số điện thoại khoa Công nghệ thông tin UTH?', 'Văn phòng Khoa Công nghệ thông tin UTH chịu trách nhiệm quản lý chuyên môn ngành CNTT và Khoa học dữ liệu. Văn phòng khoa hỗ trợ sinh viên các vấn đề về: Đăng ký đồ án tốt nghiệp, thực tập doanh nghiệp, cố vấn học tập. Địa chỉ liên hệ đặt tại Khu nhà C, Cơ sở chính. Bên cạnh đó, nếu bạn cũng quan tâm về đồng phục & trang phục, hay về đại hội đoàn, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(35, 'Văn Phòng Khoa Viện', 'Liên hệ Viện Logistics ở đâu? Văn phòng Khoa Kinh tế vận tải nằm ở đâu?', 'Các văn phòng Khoa chuyên ngành (như Viện Logistics và Quản lý chuỗi cung ứng, Khoa Kinh tế vận tải, Khoa Công trình giao thông, Khoa Điện - Điện tử viễn thông) đều có văn phòng trực ban tại các khu nhà chức năng cơ sở chính để hỗ trợ giải quyết lịch học chuyên ngành cho sinh viên. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian giữ xe tối đa tại trường và về bãi giữ xe của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-truong'),
(36, 'Giáo Dục Quốc Phòng', 'Học quân sự ở đâu? Lịch học giáo dục quốc phòng? Đi học quân sự cần chuẩn bị gì?', 'Sinh viên UTH tham gia học môn Giáo dục quốc phòng - An ninh tập trung tại Trung tâm Giáo dục Quốc phòng theo lịch phân bổ của trường. Sinh viên được rèn luyện trong môi trường quân đội nội trú, phải tuân thủ nghiêm ngặt giờ giấc, tác phong quân kỷ và mặc quân phục. Ngoài ra, nếu bạn còn thắc mắc về giáo dục thể chất hoặc về thủ tục xin miễn học thể dục, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(37, 'Giáo Dục Thể Chất', 'Học thể dục ở đâu? Các môn thể dục UTH? Đăng ký học môn thể thao nào?', 'Môn Giáo dục thể chất (Thể dục) tại UTH rất đa dạng, sinh viên được tự chọn đăng ký các môn thể thao yêu thích trên Portal như: Bóng đá, Bóng chuyền, Bóng rổ, Cầu lông, Cờ vua hoặc Võ thuật. Sinh viên phải thi đạt môn này mới đủ điều kiện xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về cấp lại giấy chứng nhận quốc phòng, hay về thủ tục xin miễn học thể dục, cứ hỏi mình thêm nha.', NULL, 0, '/dang-ky-hoc-phan'),
(38, 'Cấp Lại Bảng Điểm', 'Xin cấp bảng điểm học tập ở đâu? Lệ phí in bảng điểm chính thức?', 'Sinh viên cần bảng điểm chính thức (có mộc đỏ của trường) để xin việc làm hoặc nộp hồ sơ học bổng phải làm Đơn xin cấp bảng điểm tại máy tự động hoặc nộp trực tiếp tại Phòng Đào tạo. Lệ phí in bảng điểm được tính theo số lượng bản sao quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(39, 'Phạt Tiền Thư Viện', 'Làm mất sách thư viện đền tiền thế nào? Quên trả sách thư viện bị phạt bao nhiêu?', 'Sinh viên mượn tài liệu thư viện UTH nếu làm mất hoặc hư hỏng phải mua đền cuốn sách mới tương đương hoặc đền tiền gấp nhiều lần giá trị cuốn sách theo quy chế. Trả sách trễ hạn sẽ bị phạt số tiền tính theo từng ngày trễ hạn và bị tạm khóa thẻ thư viện. Ngoài ra, nếu bạn còn thắc mắc về mượn sách thư viện hoặc về mất thẻ sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(40, 'Nguyện Vọng Bổ Sung', 'Trường có xét tuyển bổ sung không? Điều kiện xét tuyển đợt 2 UTH?', 'Trong trường hợp các ngành học chưa tuyển đủ chỉ tiêu đợt 1, Hội đồng tuyển sinh UTH sẽ thông báo nhận hồ sơ Xét tuyển nguyện vọng bổ sung (Đợt 2) trên trang tuyển sinh chính thức của trường. Thí sinh nộp hồ sơ theo phương thức xét điểm thi tốt nghiệp THPT hoặc học bạ. Bên cạnh đó, nếu bạn cũng quan tâm về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(41, 'Bảng Điểm Tiếng Anh', 'Xin bảng điểm bằng tiếng Anh ở đâu? Lệ phí dịch thuật bảng điểm UTH? Cấp bảng điểm song ngữ?', 'Sinh viên có nhu cầu cấp bảng điểm bằng tiếng Anh (hoặc song ngữ) để làm hồ sơ du học, săn học bổng quốc tế hoặc nộp cho doanh nghiệp nước ngoài thì làm đơn đăng ký tại Phòng Đào tạo. Thời gian xử lý và cấp phát từ 3 đến 5 ngày làm việc kèm theo lệ phí in ấn quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời hạn sử dụng của thẻ thư viện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(42, 'Phúc Khảo Đồ Án', 'Đồ án tốt nghiệp có được phúc khảo không? Chấm lại điểm khóa luận tốt nghiệp?', 'Theo quy chế học vụ UTH, điểm bảo vệ Đồ án tốt nghiệp hoặc Khóa luận tốt nghiệp sẽ KHÔNG được chấm phúc khảo. Điểm số cuối cùng do Hội đồng chấm tốt nghiệp quyết định ngay tại buổi bảo vệ công khai. Sinh viên chỉ được quyền khiếu nại nếu có sai sót trong quá trình cộng điểm hoặc nhập điểm vào hệ thống. Ngoài ra, nếu bạn còn thắc mắc về quy chế thi cử hoặc về xét giảm điểm rèn luyện, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/ket-qua-hoc-tap'),
(43, 'Khóa Tài Khoản Portal', 'Tại sao tài khoản Portal bị khóa? Lỗi không đăng nhập được trang sinh viên?', 'Tài khoản Portal của sinh viên UTH thường bị khóa vì các lý do sau: Nợ học phí quá hạn quy định; Chưa hoàn thành các khảo sát bắt buộc của trường; Hoặc nhập sai mật khẩu quá 5 lần liên tiếp. Sinh viên cần liên hệ Phòng Đào tạo hoặc Phòng Công tác sinh viên để kiểm tra lý do và mở khóa. Bên cạnh đó, nếu bạn cũng quan tâm về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, hay về hủy tư cách đoàn viên, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-ca-nhan'),
(44, 'Bãi Giữ Xe Của Trường', 'Bãi xe trường ở đâu? Giá vé gửi xe máy UTH? Gửi xe qua đêm tại trường được không?', 'UTH có bãi giữ xe dành cho sinh viên tại tất cả các cơ sở. Giá vé gửi xe máy áp dụng theo đúng quy định nhà nước. Sinh viên tuyệt đối không được gửi xe qua đêm tại trường trừ các trường hợp đặc biệt được Đoàn trường hoặc Ban quản lý cơ sở cấp phép trước bằng văn bản. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về quy định sử dụng mạng wifi nội bộ của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-truong'),
(45, 'Miễn Giảm Anh Em Ruột', 'Anh em ruột cùng học UTH có được giảm học phí? Chính sách giảm học phí gia đình?', 'Nhà trường áp dụng chính sách hỗ trợ học phí cho gia đình có từ 2 anh/chị/em ruột trở lên đang cùng theo học hệ chính quy tại UTH. Mức giảm thường là 10% đến 20% học phí cho người em. Sinh viên cần nộp Giấy khai sinh bản sao và Đơn đề nghị về Phòng Công tác sinh viên đầu học kỳ. Ngoài ra, nếu bạn còn thắc mắc về gia hạn học phí hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/cong-thanh-toan'),
(46, 'Đổi Lịch Thi Học Kỳ', 'Làm sao để xin đổi ca thi? Bị trùng lịch thi phải làm thế nào? Trùng giờ thi xử lý sao?', 'Trường hợp sinh viên bị trùng lịch thi 2 môn trong cùng 1 ca hoặc có lý do bất khả kháng (tai nạn, nằm viện), sinh viên phải mang minh chứng đến Phòng Đào tạo trước ngày thi ít nhất 3 ngày để làm đơn xin chuyển ca thi hoặc đăng ký thi ghép vào đợt thi của lớp khác. Bên cạnh đó, nếu bạn cũng quan tâm về bảo lưu kết quả, hay về quy định số lần cảnh báo học vụ, cứ hỏi mình thêm nha.', NULL, 0, '/lich-hoc-trong-tuan'),
(47, 'Quên Mật Khẩu Portal', 'Làm sao lấy lại mật khẩu Portal? Quên pass trang sinh viên UTH?', 'Nếu quên mật khẩu đăng nhập hệ thống Portal, sinh viên bấm vào nút \"Quên mật khẩu\" trên giao diện đăng nhập để nhận mã khôi phục qua Email sinh viên (@ut.edu.vn). Nếu không làm được, sinh viên mang Thẻ sinh viên đến trực tiếp Phòng Đào tạo để được cấp lại mật khẩu mới. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về đăng ký cấp lại tài khoản email sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(48, 'Phòng Y Tế Trường', 'Trạm y tế trường nằm ở đâu? Khám sức khỏe sinh viên đầu năm ở đâu?', 'Phòng Y tế UTH nằm tại khu vực tầng trệt cơ sở chính. Đây là nơi tiếp nhận, sơ cứu và cấp phát thuốc cơ bản miễn phí cho sinh viên khi gặp các vấn đề về sức khỏe trong quá trình học tập tại trường. Đồng thời là nơi tổ chức khám sức khỏe định kỳ bắt buộc cho tân sinh viên. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-truong'),
(49, 'Học Bổng Liên Kết', 'Học bổng du học UTH? Chương trình trao đổi sinh viên quốc tế?', 'UTH liên kết với nhiều trường Đại học lớn tại Hàn Quốc, Nhật Bản, Hà Lan, Anh Quốc để triển khai các chương trình trao đổi sinh viên và học bổng du học hệ 2+2 hoặc 3+1. Sinh viên có học lực Giỏi và đạt chuẩn tiếng Anh (IELTS/TOEFL) cao sẽ được xét duyệt hồ sơ tham gia. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng khuyến khích, hay về hoạt động đoàn hội, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(50, 'Sinh Hoạt Công Dân', 'Tuần sinh hoạt công dân học khi nào? Không học sinh hoạt công dân có bị sao không?', 'Tuần sinh hoạt công dân - học sinh sinh viên được tổ chức bắt buộc vào đầu mỗi năm học. Sinh viên phải tham gia đầy đủ và làm bài kiểm tra thu hoạch đạt yêu cầu. Vắng mặt không lý do sẽ bị trừ điểm rèn luyện nghiêm khắc và xét kỷ luật tùy mức độ. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về học bổng khuyến khích — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(51, 'Chuyển Cơ Sở Học Tập', 'Sinh viên có được đổi cơ sở học không? Đang học Quận 12 chuyển qua Bình Thạnh?', 'Việc phân bổ cơ sở học tập (Bình Thạnh hoặc Quận 12) phụ thuộc hoàn toàn vào chuyên ngành và kế hoạch đào tạo của từng Khoa/Viện. Sinh viên KHÔNG được tự ý xin chuyển cơ sở học tập cá nhân trừ khi có sự điều chỉnh quy hoạch lớp học từ phía Ban giám hiệu nhà trường. Ngoài ra, nếu bạn còn thắc mắc về chương trình đào tạo hoặc về xin hoãn đi thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/chuong-trinh-khung'),
(52, 'Mượn Phòng Học', 'Làm sao để mượn phòng học làm hoạt động? Thủ tục mượn hội trường UTH?', 'Các Ban cán sự lớp hoặc Câu lạc bộ muốn mượn phòng học, giảng đường hoặc Hội trường để tổ chức sinh hoạt, họp hành, tập văn nghệ phải làm Đơn xin mượn phòng (có xác nhận của Bí thư Đoàn trường hoặc Trưởng Khoa) nộp về Phòng Quản trị thiết bị trước ít nhất 2 ngày. Bên cạnh đó, nếu bạn cũng quan tâm về thời hạn sử dụng của thẻ thư viện, hay về khóa tài khoản Portal, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(53, 'Hỗ Trợ Khởi Nghiệp', 'Cuộc thi khởi nghiệp sinh viên UTH? Quỹ hỗ trợ ý tưởng sáng tạo?', 'Nhà trường thường xuyên tổ chức các cuộc thi Ý tưởng khởi nghiệp sáng tạo sinh viên UTH. Các dự án tiềm năng và đạt giải cao sẽ được Câu lạc bộ Khởi nghiệp của trường hỗ trợ không gian làm việc, kết nối với các quỹ đầu tư và cố vấn chuyên môn để phát triển thành dự án thực tế. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh viên 5 tốt và về khen thưởng sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(54, 'Giấy Chứng Nhận Tạm Thời', 'Xin giấy chứng nhận sinh viên tạm thời ở đâu? Thời gian cấp giấy xác nhận là bao lâu?', 'Để phục vụ các nhu cầu cấp bách (như làm hồ sơ xin việc, chứng minh thông tin khi chưa có thẻ nhựa), sinh viên đăng ký xin cấp Giấy chứng nhận sinh viên tạm thời tại văn phòng Phòng Công tác sinh viên. Giấy xác nhận này có mộc đỏ và giá trị pháp lý ngắn hạn. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về quên mật khẩu Portal, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(55, 'Văn Phòng Đoàn Thanh Niên', 'Văn phòng Đoàn trường UTH ở đâu? Đăng ký sổ Đoàn, nộp sổ Đoàn ở đâu?', 'Văn phòng Đoàn Thanh niên - Hội Sinh viên UTH đặt tại cơ sở chính Võ Oanh. Đây là nơi quản lý toàn bộ hồ sơ đoàn viên, tiếp nhận sổ Đoàn của sinh viên đầu năm học, xét duyệt các danh hiệu thi đua, cộng điểm rèn luyện và tổ chức các chiến dịch lớn như Mùa hè xanh, Tiếp sức mùa thi. Bên cạnh đó, nếu bạn cũng quan tâm về sinh hoạt công dân, hay về mượn thiết bị âm thanh, sự kiện, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(56, 'Khảo Sát Ý Kiến Sinh Viên', 'Khảo sát môn học làm ở đâu? Không làm khảo sát giảng viên có bị sao không?', 'Cuối mỗi học kỳ, UTH bắt buộc sinh viên phải tham gia Khảo sát ý kiến về hoạt động giảng dạy của giảng viên trực tuyến trên trang Portal. Sinh viên cố tình không hoàn thành khảo sát đúng hạn sẽ bị tạm khóa chức năng xem điểm thi học kỳ và khóa lịch đăng ký môn học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về hoạt động đoàn hội và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(57, 'Đóng Lệ Phí Thi Lại', 'Thi lại có tốn tiền không? Lệ phí thi lại đóng ở đâu?', 'Đối với các môn học bị điểm F, sinh viên áp dụng quy chế học chế tín chỉ của UTH là phải đăng ký học lại và đóng tiền học phí tính theo số tín chỉ môn đó giống như học mới, trường KHÔNG tổ chức kỳ thi lại độc lập thu phí riêng như hệ niên chế cũ. Ngoài ra, nếu bạn còn thắc mắc về lệ phí xét tuyển hồ sơ đầu vào hoặc về miễn giảm anh em ruột, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/cong-thanh-toan'),
(58, 'Thực Tập Tốt Nghiệp', 'Lịch đi thực tập của sinh viên năm cuối? Xin giấy giới thiệu thực tập ở đâu?', 'Sinh viên năm cuối đủ điều kiện sẽ tham gia học phần Thực tập tốt nghiệp. Sinh viên đến văn phòng Khoa/Viện chủ quản để nhận Giấy giới thiệu thực tập nộp cho doanh nghiệp. Sau khi kết thúc, phải nộp lại Báo cáo thực tập có nhận xét và mộc tròn của công ty. Bên cạnh đó, nếu bạn cũng quan tâm về quy định tham quan kiến tập thực tế tại doanh nghiệp, hay về thời gian nhận bằng tốt nghiệp, cứ hỏi mình thêm nha.', NULL, 0, '/chuong-trinh-khung'),
(59, 'Đồ Án Tốt Nghiệp', 'Điều kiện được làm đồ án ra trường? Điểm GPA bao nhiêu thì được làm khóa luận tốt nghiệp?', 'Điều kiện để sinh viên UTH được giao đề tài làm Đồ án/Khóa luận tốt nghiệp: Tính đến học kỳ xét, sinh viên không bị cảnh báo học vụ; Tích lũy tối thiểu 80% đến 90% số tín chỉ toàn khóa; Điểm trung bình GPA đạt mức quy định riêng của từng Khoa/Viện chuyên ngành. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đồ án tốt nghiệp đạt điểm f xử lý sao và về quy trình làm thủ tục nhập học trực tiếp tại trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/chuong-trinh-khung'),
(60, 'Khen Thưởng Sinh Viên', 'Sinh viên xuất sắc được thưởng gì? Tiêu chuẩn xét khen thưởng danh hiệu học tập?', 'Kết thúc mỗi năm học, nhà trường tiến hành xét khen thưởng cho sinh viên đạt danh hiệu Sinh viên Xuất sắc (GPA >= 3.6/4.0) và Sinh viên Giỏi (GPA >= 3.2/4.0) kèm theo điểm rèn luyện loại Tốt trở lên. Sinh viên được tặng giấy khen của Hiệu trưởng và nhận tiền thưởng tương ứng. Ngoài ra, nếu bạn còn thắc mắc về đăng ký tham gia câu lạc bộ hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(61, 'Mùa Hè Xanh UTH', 'Đăng ký Mùa hè xanh ở đâu? Tiêu chí tuyển chiến sĩ MHX? Đi MHX được bao nhiêu ĐRL?', 'Chiến dịch tình nguyện Mùa Hè Xanh UTH do Đoàn trường tổ chức vào tháng 7 hằng năm. Sinh viên đăng ký qua form chính thức của Đoàn Khoa/Viện. Tiêu chí tuyển chọn dựa trên sức khỏe, đạo đức tốt và tích cực tham gia phong trào. Hoàn thành chiến dịch được cộng tối đa 15-20 điểm rèn luyện. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(62, 'Tiếp Sức Mùa Thi', 'Đăng ký Tiếp sức mùa thi UTH? Lịch chạy chương trình TSMT?', 'Chương trình Tiếp sức mùa thi diễn ra vào tháng 6 hằng năm nhằm hỗ trợ thí sinh thi THPT Quốc tế. Sinh viên UTH đăng ký tham gia thông qua Hội Sinh viên trường. Chiến sĩ TSMT sẽ trực tại các điểm trường thi để phân luồng giao thông, hỗ trợ nước uống và chỉ đường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng đoàn thanh niên và về các câu lạc bộ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(63, 'Xuân Tình Nguyện', 'Lịch chạy Xuân tình nguyện UTH? Đăng ký đi XTN ở đâu? Chi phí đóng góp XTN?', 'Chiến dịch Xuân Tình Nguyện UTH diễn ra vào dịp cận Tết Nguyên Đán. Các đội hình sẽ thực hiện hoạt động gói bánh chưng, tặng quà cho trẻ em cơ nhỡ, người già neo đơn và dọn dẹp nghĩa trang liệt sĩ. Sinh viên đăng ký qua Fanpage Đoàn - Hội của Khoa/Viện. Ngoài ra, nếu bạn còn thắc mắc về sinh viên 5 tốt hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(64, 'Giải Chạy Sinh Viên', 'Giải chạy bộ UTH? Đăng ký chạy marathon trường ở đâu? Minh chứng hoàn thành giải chạy?', 'UTH thường xuyên tổ chức hoặc liên kết các giải chạy bộ (Marathon trực tuyến/trực tiếp qua app Strava). Sinh viên hoàn thành cự ly quy định (thường là 21km hoặc 42km tích lũy) sẽ đạt tiêu chí \"Thể lực tốt\" phục vụ xét danh hiệu Sinh viên 5 Tốt và được cộng ĐRL. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về đăng ký tham gia hiến máu đợt hè, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(65, 'Ngày Hội Sáng Tạo', 'Cuộc thi ý tưởng sáng tạo UTH? Sáng tạo trẻ sinh viên giao thông?', 'Ngày hội Sáng tạo trẻ UTH là sân chơi khoa học công nghệ, trưng bày các mô hình, phần mềm độc đáo do sinh viên tự nghiên cứu (robot, mô hình cầu đường, app quản lý vận tải). Đề tài đạt giải cao sẽ được hỗ trợ kinh phí tham gia các cuộc thi cấp Thành phố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chiến sĩ tình nguyện và về hủy tư cách đoàn viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(66, 'Chiến Sĩ Tình Nguyện', 'Danh hiệu Chiến sĩ tình nguyện xuất sắc? Làm sao để được tặng bằng khen MHX?', 'Kết thúc mỗi chiến dịch tình nguyện (MHX, XTN, TSMT), Ban chỉ huy chiến dịch sẽ tổ chức họp xét để tuyên dương các cá nhân có đóng góp xuất sắc. Chiến sĩ đạt danh hiệu sẽ được tặng Giấy khen của Hiệu trưởng hoặc Ủy ban Hội Sinh viên Thành phố. Ngoài ra, nếu bạn còn thắc mắc về tiếp sức mùa thi hoặc về đăng ký tham gia câu lạc bộ, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(67, 'Đại Hội Đoàn - Hội', 'Lịch tổ chức Đại hội Đại biểu? Đi bầu cử Đoàn Thanh niên ở đâu?', 'Đại hội Đại biểu Đoàn TNCS Hồ Chí Minh và Đại hội Hội Sinh viên Việt Nam trường UTH được tổ chức định kỳ để bầu ra Ban chấp hành mới. Sinh viên là Đại biểu chính thức sẽ tham gia họp và bỏ phiếu tại Hội trường lớn cơ sở chính Võ Oanh. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng liên kết, hay về văn phòng khoa CNTT, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(68, 'Cắm Trại Truyền Thống', 'Hội trại truyền thống UTH học kỳ nào? Địa điểm cắm trại trường? Chi phí hội trại?', 'Hội trại truyền thống UTH thường được tổ chức nhân dịp kỷ niệm ngày thành lập Đoàn 26/03 hoặc ngày truyền thống trường. Địa điểm tổ chức có thể tại sân trường cơ sở Quận 12 hoặc các khu du lịch dã ngoại. Hội trại gồm các hoạt động dựng trại, trò chơi lớn và đêm lửa trại. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về các câu lạc bộ và về chiến sĩ đỏ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(69, 'Giải Bóng Đá UTH', 'Giải bóng đá nam/nữ trường UTH? Đăng ký đá banh giải trường ở đâu?', 'Giải bóng đá truyền thống sinh viên UTH tổ chức hằng năm tại sân bóng cỏ nhân tạo. Các đội bóng tham gia tranh tài theo đơn vị lớp hoặc Liên quân Khoa/Viện. Lịch thi đấu và thể lệ được Ban thể thao thuộc Hội sinh viên trường công bố công khai đầu học kỳ 2. Ngoài ra, nếu bạn còn thắc mắc về hoạt động \"hiến máu tình nguyện\" lần 2 trong năm hoặc về tham gia hiến máu có được nghỉ học, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dang-ky-hoc-phan'),
(70, 'Văn Nghệ Tiếng Hát', 'Cuộc thi tiếng hát sinh viên UTH? Cuộc thi văn nghệ UTH Got Talent?', 'Cuộc thi văn nghệ truyền thống (Tiếng hát sinh viên UTH) là nơi tìm kiếm các tài năng âm nhạc, nhạc cụ, nhảy hiện đại, múa dân gian. Sinh viên đăng ký tiết mục đơn ca, song ca hoặc tốp ca trực tiếp với Đội văn nghệ xung kích của trường để tham gia vòng sơ loại. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách học bổng tuyển sinh, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(71, 'Chiến Sĩ Đỏ - Hiến Máu', 'Đội tình nguyện hiến máu UTH? Câu lạc bộ Hành Trình Đỏ UTH?', 'Câu lạc bộ Hành Trình Đỏ / Đội Tình nguyện Hiến máu UTH là đơn vị nòng cốt phối hợp với Trung tâm hiến máu nhân đạo TP.HCM để tổ chức các đợt hiến máu tại trường. Thành viên đội sẽ hỗ trợ điều phối, hướng dẫn sinh viên điền form và chăm sóc sinh viên sau hiến máu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-truong'),
(72, 'Minh Chứng ĐRL', 'Nộp minh chứng hoạt động ở đâu? Quên nộp minh chứng có được cộng điểm rèn luyện?', 'Khi tham gia các hoạt động bên ngoài trường (Hiến máu, Tình nguyện hè, Giải chạy), sinh viên phải giữ lại Giấy chứng nhận bản cứng hoặc chụp màn hình kết quả. Sau đó, đăng nhập hệ thống Portal nộp minh chứng đúng thời hạn quy định để Lớp trưởng xét cộng ĐRL. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về cấp lại bảng điểm, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(73, 'Điểm Rèn Luyện F', 'Điểm rèn luyện dưới 50 bị phạt thế nào? ĐRL loại Yếu có được tốt nghiệp không?', 'Sinh viên có điểm rèn luyện xếp loại Yếu (dưới 50 điểm) hoặc Kém (dưới 35 điểm) trong một năm học sẽ bị đưa vào danh sách kỷ luật cảnh cáo. Nếu bị xếp loại yếu, kém 2 học kỳ liên tiếp sẽ bị đình chỉ học tập 1 học kỳ; nếu bị lần thứ 3 sẽ bị buộc thôi học. Bên cạnh đó, nếu bạn cũng quan tâm về quy chế thi cử, hay về đăng ký môn học, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-ca-nhan'),
(74, 'Ngày Hội Việc Làm', 'UTH Job Fair tổ chức khi nào? Sinh viên năm nhất có được tham gia ngày hội việc làm?', 'Ngày hội việc làm UTH Job Fair diễn ra định kỳ hằng năm tại sân trường cơ sở chính. Hoạt động này thu hút hàng chục doanh nghiệp lớn đến phỏng vấn tuyển dụng trực tiếp, nhận hồ sơ thực tập. Tất cả sinh viên các năm đều được tham gia tự do để tìm kiếm cơ hội. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách học bổng tuyển sinh và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(75, 'Hội Thảo Kỹ Năng', 'Lớp học kỹ năng mềm UTH? Đăng ký chuyên đề kỹ năng ở đâu? Có tính ĐRL không?', 'Phòng Công tác sinh viên phối hợp với các chuyên gia tổ chức các buổi Hội thảo kỹ năng mềm (Kỹ năng viết CV, kỹ năng giao tiếp, quản lý thời gian). Sinh viên quét mã QR điểm danh tại hội trường sẽ được tự động cộng 2-3 điểm rèn luyện vào hệ thống Portal. Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về văn phòng đoàn thanh niên, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(76, 'Học phí chương trình tiên tiến (trước đây gọi là Chất lượng cao - CLC)', 'Học phí hệ chất lượng cao là bao nhiêu? Tại sao học phí CLC lại cao hơn đại trà? Tổng tiền học phí CLC một năm?', 'UTH hiện gọi chương trình Chất lượng cao trước đây là \"Chương trình tiên tiến\". Mức học phí chương trình tiên tiến áp dụng cho tân sinh viên khóa 2026 là 1.120.000đ/tín chỉ (khóa 2025 áp dụng mức 980.000đ/tín chỉ). Với chương trình đào tạo chuẩn hóa 120 tín chỉ toàn khóa, tổng học phí chương trình tiên tiến trọn khóa (học đúng tiến độ, chưa gồm các khoản phí khác) theo mức khóa 2026 vào khoảng 134 triệu đồng. Mức phí chương trình tiên tiến cao hơn chương trình chuẩn do quy mô lớp nhỏ, tăng cường thời lượng tiếng Anh chuyên ngành, cơ sở vật chất hiện đại và có các học phần trải nghiệm/kiến tập tại doanh nghiệp. Mỗi khóa nhập học có mức học phí niêm yết riêng và trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về chính sách hỗ trợ bảo hiểm tai nạn, cứ hỏi mình thêm nha.', NULL, 0, '/cong-thanh-toan'),
(77, 'Quy trình chấm Điểm rèn luyện (ĐRL) hằng kỳ', 'Cách chấm điểm rèn luyện như thế nào? Quy trình họp xét ĐRL của lớp? Khi nào bắt đầu tự đánh giá ĐRL?', 'Quy trình chấm Điểm rèn luyện hằng kỳ tại UTH được thực hiện qua 3 bước bắt buộc: - Sinh viên đăng nhập hệ thống Portal tự đánh giá điểm cá nhân theo các mục quy định. - Tập thể lớp tổ chức họp dưới sự chủ trì của Ban cán sự lớp để thông qua và chấm điểm cho từng sinh viên. - Cố vấn học tập (Giảng viên chủ nhiệm) phê duyệt và gửi danh sách chính thức về Phòng Công tác sinh viên để lưu hệ thống. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về cảnh báo học vụ và về thủ tục phúc khảo điểm quá trình — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(78, 'Thẻ bảo hiểm y tế điện tử (VssID)', 'Xem thẻ bảo hiểm y tế ở đâu? Cách đăng ký tài khoản VssID sinh viên? Mất thẻ bảo hiểm y tế giấy phải làm sao?', 'Nhà trường không cấp thẻ Bảo hiểm y tế (BHYT) bằng giấy vật lý cho sinh viên nữa. Sau khi đóng lệ phí gia hạn BHYT thành công trên cổng thanh toán của trường, sinh viên tải ứng dụng VssID (Bảo hiểm xã hội số) trên điện thoại và đăng ký tài khoản bằng mã số bảo hiểm của mình để sử dụng thẻ BHYT điện tử khi đi khám chữa bệnh tại các bệnh viện. Ngoài ra, nếu bạn còn thắc mắc về chính sách hỗ trợ bảo hiểm tai nạn hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(79, 'Chuẩn tin học quốc tế nâng cao', 'Chứng chỉ tin học IC3 hay MOS tốt hơn? Quy đổi điểm tin học đầu ra như thế nào?', 'UTH công nhận cả hai chứng chỉ quốc tế là MOS và IC3 để xét đạt chuẩn đầu ra Tin học. Đối với chứng chỉ MOS, sinh viên phải đạt từ 3 kỹ năng độc lập trở lên (gồm Word, Excel và Powerpoint). Đối với chứng chỉ IC3, sinh viên phải thi đạt cả 3 phần (Living Online, Key Applications, và Computing Fundamentals). Sinh viên mang chứng chỉ gốc đến Phòng Đào tạo để làm thủ tục hậu kiểm công nhận quy đổi. Bên cạnh đó, nếu bạn cũng quan tâm về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH, hay về đăng ký thi lại chuẩn đầu ra, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(80, 'Quy định sử dụng mạng Wifi nội bộ của trường', 'Cách kết nối wifi trường UTH? Mật khẩu wifi sinh viên là gì? Tại sao không vào được wifi trường?', 'Nhà trường cấp hệ thống mạng Wifi miễn phí tại tất cả các khu vực giảng đường, thư viện và sân trường cho sinh viên. Để kết nối, sinh viên chọn mạng Wifi dành riêng cho người học, sau đó đăng nhập bằng Mã số sinh viên (Username) và Mật khẩu Portal cá nhân của mình. Hệ thống sẽ tự động chặn các truy cập vào trang web độc hại hoặc tải tài liệu lậu dung lượng quá lớn làm nghẽn băng thông. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng khoa viện và về liên hệ ban quản lý ký túc xá — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-tin-truong'),
(81, 'Đăng ký tham gia Câu lạc bộ (CLB) đầu năm học', 'Làm sao để vào câu lạc bộ của trường? Ngày hội các câu lạc bộ tổ chức khi nào? Tuyển thành viên CLB UTH?', 'Vào khoảng tháng 9 và tháng 10 hằng năm (đầu học kỳ 1), Hội Sinh viên trường UTH tổ chức Ngày hội các Câu lạc bộ (CLB Festival) tại sân trường cơ sở chính. Tại đây, tất cả các CLB (Học thuật, Nghệ thuật, Thể thao, Tình nguyện) sẽ đặt gian hàng giới thiệu và phát đơn tuyển thành viên mới trực tiếp hoặc trực tuyến qua các trang Fanpage chính thức của mình. Ngoài ra, nếu bạn còn thắc mắc về văn phòng đoàn thanh niên hoặc về sinh viên 5 tốt, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(82, 'Đăng ký cấp lại tài khoản Email sinh viên (@ut.edu.vn)', 'Làm sao để đổi mật khẩu email sinh viên? Bị mất email của trường xử lý thế nào?', 'Email sinh viên định dạng [MSSV]@ut.edu.vn được nhà trường cấp miễn phí cho toàn bộ người học để liên lạc và nhận các thông báo quan trọng. Nếu bị khóa tài khoản hoặc quên mật khẩu email, sinh viên mang Thẻ sinh viên đến trực tiếp văn phòng Trung tâm Dữ liệu và Công nghệ thông tin của trường tại khu nhà chức năng cơ sở chính để được hỗ trợ reset cấp lại mật khẩu ngay trong ngày. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về quên mật khẩu Portal, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-ca-nhan'),
(83, 'Hoạt động \"Hiến máu tình nguyện\" lần 2 trong năm', 'Một năm trường tổ chức hiến máu mấy lần? Lịch hiến máu đợt 2 của trường?', 'Nhằm đáp ứng nhu cầu cung cấp máu cứu người, Đoàn trường và Hội sinh viên UTH phối hợp tổ chức hoạt động hiến máu nhân đạo định kỳ 2 lần trong một năm học (thường rơi vào Học kỳ 1 và Học kỳ 2). Lịch chi tiết của từng đợt sẽ được đăng tải sớm trên trang Portal trước 1 tuần để sinh viên đăng ký tham gia và nhận quyền lợi cộng điểm rèn luyện. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(84, 'Chế độ miễn giảm học phí cho con em diện chính sách', 'Con thương binh có được giảm học phí không? Thủ tục xin miễn học phí diện hộ nghèo? Nộp hồ sơ giảm học phí ở đâu?', 'Sinh viên thuộc diện con thương binh, bệnh binh, người có công với cách mạng, sinh viên dân tộc thiểu số vùng đặc biệt khó khăn, hoặc sinh viên thuộc hộ nghèo/hộ cận nghèo sẽ được hưởng chính sách miễn hoặc giảm học phí theo đúng quy định của Nhà nước. Sinh viên cần chuẩn bị Sổ hộ nghèo, Giấy chứng nhận diện chính sách bản công chứng nộp về Phòng Công tác sinh viên để xét duyệt đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/cong-thanh-toan'),
(85, 'Quy định mượn học cụ, thiết bị tại phòng thí nghiệm', 'Làm sao để mượn đồ phòng thí nghiệm làm đồ án? Quy định mượn thiết bị đo đạc?', 'Sinh viên các ngành kỹ thuật (như Công trình, Điện - Điện tử, CNTT) cần mượn thiết bị, học cụ tại các phòng thí nghiệm, xưởng thực hành để làm đồ án hoặc bài tập lớn phải có Giấy đề xuất mượn thiết bị do Giảng viên hướng dẫn ký duyệt. Sinh viên nộp giấy này cho Cán bộ quản lý phòng thí nghiệm, xuất trình Thẻ sinh viên để ký sổ mượn và có trách nhiệm bảo quản, hoàn trả nguyên vẹn đúng thời hạn. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về liên hệ ban quản lý ký túc xá, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(86, 'Tiếp nhận hồ sơ Đăng ký xét tuyển Học bạ đợt tiếp theo', 'Khi nào trường nhận hồ sơ học bạ đợt 2? Cách nộp học bạ online vào trường UTH?', 'Hội đồng tuyển sinh UTH tổ chức xét tuyển học bạ THPT thành nhiều đợt trong năm. Thí sinh đăng ký nộp hồ sơ trực tuyến thông qua trang Tuyển sinh chính thức của trường, điền đầy đủ điểm số các môn thuộc tổ hợp xét tuyển và tải ảnh chụp học bạ lên hệ thống. Sau khi có kết quả trúng tuyển tạm thời, thí sinh phải nộp hồ sơ bản giấy về trường để đối chiếu xác thực thông tin. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về nguyện vọng bổ sung — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(87, 'Thủ tục xin tạm hoãn thi học kỳ', 'Bị ốm đột xuất không đi thi được làm sao? Cách xin hoãn thi học kỳ? Đơn xin hoãn thi nộp ở đâu?', 'Nếu gặp lý do bất khả kháng như tai nạn hoặc bệnh tật phải nằm viện điều trị ngay vào ngày thi kết thúc học phần, sinh viên phải làm Đơn xin hoãn thi kèm theo Giấy ra viện hoặc Giấy xác nhận có mộc tròn của bệnh viện nộp về Phòng Đào tạo trong vòng tối đa 3 ngày làm việc kể từ ngày thi của môn đó. Môn học xin hoãn thi thành công sẽ được chuyển điểm sang đợt thi bổ sung hoặc thi ghép cùng khóa sau mà không bị tính điểm 0. Ngoài ra, nếu bạn còn thắc mắc về cách tính điểm hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/lich-hoc-trong-tuan');
INSERT INTO `faq` (`id`, `topic_group`, `tu_khoa`, `noi_dung`, `variations`, `priority`, `link_dieu_huong`) VALUES
(88, 'Quy chế quản lý thông tin và tài sản số của sinh viên', 'Có được chia sẻ tài khoản Portal cho người khác không? Quy định bảo mật thông tin sinh viên UTH?', 'Theo quy định an ninh thông tin của UTH, tài khoản Portal và mật khẩu cá nhân là tài sản số độc quyền của cá nhân sinh viên đó. Sinh viên tuyệt đối không được chia sẻ tài khoản này cho bất kỳ ai khác. Mọi hành vi tự ý chia sẻ tài khoản dẫn đến việc sai lệch dữ liệu đăng ký môn học, kết quả học tập hoặc phát tán thông tin sai sự thật trên hệ thống sẽ bị xử lý kỷ luật nghiêm khắc từ mức cảnh cáo đến đình chỉ học tập. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về khảo sát ý kiến sinh viên, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-ca-nhan'),
(89, 'Quy định tham quan kiến tập thực tế tại doanh nghiệp', 'Sinh viên năm mấy được đi kiến tập? Đi kiến tập doanh nghiệp có bắt buộc không?', 'Hoạt động tham quan kiến tập thực tế tại doanh nghiệp, nhà máy, cảng biển là một học phần bắt buộc hoặc hoạt động bổ trợ bổ ích được các Khoa/Viện tổ chức cho sinh viên (thường dành cho sinh viên năm 2 hoặc năm 3). Hoạt động này giúp sinh viên tiếp cận môi trường làm việc thực tế. Sinh viên tham gia phải tuân thủ nghiêm ngặt giờ giấc điều phối của giảng viên trưởng đoàn và mặc đồng phục trường lịch sự. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thủ tục chuyển ngành và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/chuong-trinh-khung'),
(90, 'Tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường', 'Trường có phòng tư vấn tâm lý không? Bị stress áp lực học tập thì liên hệ ai hỗ trợ?', 'Nhằm hỗ trợ giải tỏa các áp lực về học tập, cuộc sống hoặc các vấn đề tâm lý cá nhân, UTH có Trung tâm Tư vấn tâm lý sinh viên trực thuộc Phòng Công tác sinh viên. Tại đây, các chuyên gia tâm lý sẽ lắng nghe, chia sẻ và tư vấn định hướng hoàn toàn miễn phí và bảo mật tuyệt đối thông tin cho sinh viên. Sinh viên có thể đặt lịch hẹn tư vấn trực tuyến qua trang hỗ trợ hoặc đến gặp trực tiếp tại văn phòng nhà A. Ngoài ra, nếu bạn còn thắc mắc về cấp lại bảng điểm hoặc về đăng ký cấp lại tài khoản email sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(106, 'Rút hồ sơ thôi học', 'rut ho so, thoi hoc, xoa ten, khong hoc nua, xin thoi hoc, nghi hoc luon', 'Sinh viên muốn xin thôi học và rút hồ sơ gốc (Học bạ, Bằng tốt nghiệp THPT) phải làm đơn theo mẫu của trường, xin ý kiến xác nhận không nợ sách Thư viện, không nợ học phí, sau đó nộp về Phòng Đào tạo để ra quyết định xóa tên và trả lại hồ sơ. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(107, 'Đăng ký thi lại chuẩn đầu ra', 'thi lai anh van, thi lai tin hoc, nop don thi lai cdr, dang ky thi tieng anh', 'Trung tâm Ngoại ngữ và Trung tâm Tin học UTH tổ chức các đợt thi đánh giá chuẩn đầu ra định kỳ hằng tháng. Sinh viên theo dõi lịch thông báo, đăng ký và đóng lệ phí dự thi trực tuyến trên trang của Trung tâm trước ngày thi ít nhất 10 ngày. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(108, 'Xét giảm điểm rèn luyện', 'tru diem ren luyen, khieu nai drl, mo cong drl, cham lai drl, kieu nai drl', 'Nếu phát hiện điểm rèn luyện hiển thị trên Portal bị sai sót hoặc bị trừ điểm không rõ lý do, sinh viên làm đơn khiếu nại gửi Ban cán sự lớp và Cố vấn học tập trong thời gian 5 ngày kể từ khi công bố kết quả dự kiến để được kiểm tra, điều chỉnh. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xin tạm hoãn thi học kỳ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(109, 'Quy trình vay vốn ngân hàng', 'vay von ngan hang, giay xac nhan vay von, ngan hang chinh sach, don xin vay von', 'Sinh viên thuộc diện đối tượng được vay vốn tín dụng học tập mang hộ khẩu và minh chứng đối tượng đến Phòng Công tác sinh viên để xin cấp \"Giấy xác nhận là sinh viên của trường\". Sau đó mang giấy này về địa phương để làm thủ tục giải ngân tại Ngân hàng Chính sách Xã hội. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về gia hạn học phí, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(110, 'Chính sách Học bổng tuyển sinh', 'hoc bong tuyen sinh, thu khoa, kien quoc, hoc bong dau vao, khuyen khich dau vao', 'UTH cấp học bổng toàn phần hoặc bán phần (miễn 50% - 100% học phí năm đầu) cho các tân sinh viên đạt danh hiệu Thủ khoa trường, Thủ khoa ngành, hoặc các thí sinh đạt điểm cao xuất sắc trong kỳ thi tốt nghiệp THPT và kỳ thi Đánh giá năng lực. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký tham gia hiến máu đợt hè và về ngày hội sáng tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(111, 'Thời gian giữ xe tối đa tại trường', 'gui xe qua dem, mat xe, quen lay xe, giu xe may, bai xe mo cua den may gio', 'Bãi giữ xe trường UTH mở cửa từ 6h00 đến 22h00 hằng ngày. Sinh viên không được để xe lại bãi qua đêm. Trường hợp xe bị hư hỏng bắt buộc phải để lại, sinh viên phải báo cáo và đăng ký thông tin với Đội bảo vệ trực ban của trường để được quản lý. Ngoài ra, nếu bạn còn thắc mắc về quy định sử dụng mạng wifi nội bộ của trường hoặc về liên hệ ban quản lý ký túc xá, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-truong'),
(112, 'Thủ tục phúc khảo điểm quá trình', 'phuc khao diem thanh phan, xem lai diem giua ky, diem qua trinh bi sai, sửa điểm', 'Điểm quá trình (điểm chuyên cần, bài tập, giữa kỳ) do Giảng viên bộ môn quản lý và công bố trên lớp. Nếu có thắc mắc, sinh viên phải phản hồi trực tiếp với Giảng viên trước khi môn học kết thúc. Khi điểm đã nộp về trường, giảng viên mới không thể tự ý chỉnh sửa. Bên cạnh đó, nếu bạn cũng quan tâm về học cải thiện, hay về đổi lịch thi học kỳ, cứ hỏi mình thêm nha.', NULL, 0, '/ket-qua-hoc-tap'),
(113, 'Tham gia hiến máu có được nghỉ học', 'hien mau co duoc nghi, xin nghi hoc hien mau, hoãn hoc hien mau', 'Sinh viên tham gia ngày hội hiến máu tình nguyện tổ chức tại trường sẽ được hỗ trợ cấp Giấy chứng nhận hiến máu. Giấy này được dùng làm minh chứng hợp lệ để xin phép nghỉ học có lý do đối với các tiết học diễn ra trong ngày hiến máu đó. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về khảo sát ý kiến sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/lich-hoc-trong-tuan'),
(114, 'Đổi thẻ nhựa sang thẻ sinh viên', 'doi the nhua, lam the sinh vien moi, chip the sinh vien, tich hop the ngan hang', 'Hiện nay UTH triển khai cấp thẻ sinh viên tích hợp thẻ ngân hàng thông minh. Sinh viên năm nhất nhận thẻ theo lịch phân phối của phòng CTSV. Sinh viên khóa cũ có nhu cầu đổi phôi thẻ lỗi sang thẻ đa năng mới đăng ký và đóng phí tại văn phòng phòng CTSV. Ngoài ra, nếu bạn còn thắc mắc về khóa tài khoản Portal hoặc về phạt tiền thư viện, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(115, 'Hủy tư cách đoàn viên', 'xoa ten doan, rut so doan, khong sinh hoat doan, dong doan phi', 'Đoàn viên không tham gia sinh hoạt Đoàn hoặc không đóng đoàn phí liên tục trong 3 tháng mà không có lý do chính đáng sẽ bị xem xét xóa tên khỏi danh sách Đoàn viên và thông báo về Chi đoàn lớp sinh hoạt để trừ điểm rèn luyện theo quy chế. Bên cạnh đó, nếu bạn cũng quan tâm về nghiên cứu khoa học, hay về đồng phục & trang phục, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-ca-nhan'),
(116, 'Chính sách hỗ trợ bảo hiểm tai nạn', 'bao hiem tai nan, bhtn, bi tai nan duoc den bao nhieu, ho tro nam vien', 'Ngoài BHYT bắt buộc, nhà trường có liên kết đơn vị bảo hiểm để sinh viên đăng ký tự nguyện Bảo hiểm tai nạn. Khi xảy ra sự cố chấn thương, nằm viện, sinh viên mang Giấy ra viện và hóa đơn chi phí đến Phòng Công tác sinh viên để làm thủ tục nhận tiền bảo hiểm bồi thường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về lệ phí xét tuyển hồ sơ đầu vào — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(117, 'Mượn thiết bị âm thanh, sự kiện', 'muon loa keo, loa mic, thiet bi su kien, loa mic clb, thiet bi doan hoi', 'Các Câu lạc bộ, Chi đoàn lớp cần mượn loa kéo, micro, thiết bị âm thanh hoặc backdrop để tổ chức hoạt động phong trào phải làm đơn đăng ký thông qua Văn phòng Đoàn trường hoặc Phòng Quản trị thiết bị trước ngày diễn ra sự kiện ít nhất 3 ngày. Ngoài ra, nếu bạn còn thắc mắc về mất thẻ sinh viên hoặc về khóa tài khoản Portal, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(118, 'Cấp lại giấy chứng nhận quốc phòng', 'mat bang quan su, mat giay quoc phong, cap lai chung chi gdqp, xin bang diem gdqp', 'Chứng chỉ Giáo dục Quốc phòng - An ninh do Trung tâm GDQP cấp gốc 1 lần duy nhất. Nếu bị mất, sinh viên không được cấp lại bằng gốc mà phải làm đơn xin cấp Giấy xác nhận hoàn thành môn học hoặc bản sao bảng điểm trực tiếp tại Trung tâm quản lý để nộp xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về giáo dục quốc phòng, hay về giáo dục thể chất, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(119, 'Đăng ký tham gia hiến máu đợt hè', 'hien mau mua he, hien mau hk he, lich hien mau thang 6 thang 7', 'Hoạt động hiến máu tình nguyện đợt hè thường được phối hợp tổ chức vào khoảng tháng 6 hoặc tháng 7 nhằm bổ sung nguồn máu dự trữ khan hiếm. Sinh viên học kỳ hè hoặc sinh viên ở lại thành phố đăng ký trực tuyến qua Fanpage Hội Sinh viên trường UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh hoạt công dân và về văn nghệ tiếng hát — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(120, 'Quy định số lần cảnh báo học vụ', 'bi canh bao may lan thi bi duoi, gioi han canh bao, canh bao hoc vu muc do 2', 'Theo quy chế học vụ UTH, sinh viên bị cảnh báo học vụ 2 lần liên tiếp sẽ bị buộc thôi học. Nếu bị cảnh báo rải rác không liên tiếp, sinh viên vẫn được tiếp tục học nhưng phải chủ động gặp Cố vấn học tập để làm cam kết lộ trình cải thiện điểm số. Ngoài ra, nếu bạn còn thắc mắc về điểm rèn luyện f hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-ca-nhan'),
(121, 'Thời hạn sử dụng của thẻ thư viện', 'gia han the thu vien, the thu vien het han, khoa the thu vien', 'Thẻ thư viện UTH (tích hợp trên Thẻ sinh viên) có giá trị sử dụng xuyên suốt toàn bộ khóa học chính quy của sinh viên tại trường. Tài khoản thư viện sẽ tự động bị khóa sau khi sinh viên nhận quyết định tốt nghiệp hoặc quyết định thôi học, ngừng học. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về cấp lại bảng điểm, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(122, 'Thủ tục xin miễn học thể dục', 'mien hoc the duc, khong hoc the duc bi khuyet tat, don mien giao duc the chat, gay chan, chan thuong, tai nan, dau om', 'Sinh viên có khuyết tật, dị tật hoặc mắc các bệnh lý mãn tính không thể tham gia vận động mạnh phải làm đơn xin miễn/giảm học phần Giáo dục thể chất kèm theo Bệnh án, Giấy chứng nhận thương tật của bệnh viện cấp Quận trở lên nộp về Bộ môn GDTC để xét duyệt chuyển đổi môn học phù hợp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giáo dục quốc phòng và về cấp lại giấy chứng nhận quốc phòng — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dang-ky-hoc-phan'),
(123, 'Thời gian nhận bằng tốt nghiệp', 'khi nao nhan bang goc, lay bang tot nghiep o dau, phat bang tot nghiep', 'Bằng tốt nghiệp chính thức được cấp phát cho sinh viên trong vòng 30 ngày kể từ ngày ký Quyết định công nhận tốt nghiệp. Sinh viên nhận bằng trực tiếp tại lễ tốt nghiệp hoặc đến văn phòng Phòng Đào tạo để ký sổ nhận bằng gốc (mang theo CCCD). Ngoài ra, nếu bạn còn thắc mắc về điều kiện tốt nghiệp hoặc về thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(124, 'Phí phạt nợ học phí quá hạn', 'nop tre hoc phi, nop phat hoc phi, tre han dong tien hoc bi phat bao nhieu', 'UTH không áp dụng hình thức phạt tiền mặt khi sinh viên nộp học phí trễ hạn. Tuy nhiên, sinh viên không hoàn thành học phí đúng thời gian quy định sẽ bị hệ thống tự động khóa tài khoản Portal, hủy danh sách đăng ký học phần và cấm tham gia kỳ thi học kỳ. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình vay vốn ngân hàng, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', NULL, 0, '/cong-thanh-toan'),
(125, 'Xin hoãn đi thực tập tốt nghiệp', 'hoan thuc tap, don xin hoan thuc tap nam cuoi, doi lich di thuc tap', 'Sinh viên năm cuối vì lý do sức khỏe hoặc chưa tích lũy đủ các môn học điều kiện bắt buộc muốn xin hoãn học phần Thực tập tốt nghiệp phải làm đơn xin hoãn nộp về Văn phòng Khoa/Viện chủ quản trước khi danh sách phân công đơn vị thực tập được công bố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chương trình đào tạo và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/chuong-trinh-khung'),
(126, 'Chính sách hỗ trợ sinh viên nghèo', 'tro cap kho khan, ho tro sinh vien ngheo đột xuất, tro cap xa hoi', 'Sinh viên gặp tai nạn, thiên tai, hỏa hoạn hoặc gia đình gặp biến cố lớn đột xuất dẫn đến hoàn cảnh đặc biệt khó khăn làm đơn xin hỗ trợ gửi Phòng Công tác sinh viên. Nhà trường sẽ xem xét trích Quỹ hỗ trợ sinh viên để cấp kinh phí trợ cấp đột xuất. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chế độ miễn giảm học phí cho con em diện chính sách, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(127, 'Đồ án tốt nghiệp đạt điểm F xử lý sao', 'rot do an tot nghiep, lam lai khoa luan, rot khoa luan ra truong', 'Sinh viên bảo vệ Đồ án hoặc Khóa luận tốt nghiệp nhận điểm F (không đạt) sẽ không được tốt nghiệp đúng hạn. Sinh viên bắt buộc phải đăng ký làm lại đề tài mới hoặc đăng ký lại học phần đồ án vào kỳ xét duyệt tiếp theo của năm học sau và đóng phí theo quy định. Bên cạnh đó, nếu bạn cũng quan tâm về thời gian nhận bằng tốt nghiệp, hay về chương trình đào tạo, cứ hỏi mình thêm nha.', NULL, 0, '/chuong-trinh-khung'),
(128, 'Quy chế xét học bổng khi nợ môn', 'no mon co duoc hoc bong, rot mon co duoc xet hoc bong, thi lai co duoc hoc bong', 'Theo quy chế khen thưởng của UTH, sinh viên chỉ cần nợ 1 môn học (nhận điểm F) hoặc đăng ký thi lại/học lại bất kỳ môn nào trong học kỳ đó thì sẽ lập tức bị tước quyền tham gia xét duyệt Học bổng khuyến khích học tập, bất kể điểm GPA tổng của bạn cao bao nhiêu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học bổng doanh nghiệp và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(129, 'Liên hệ Ban quản lý ký túc xá', 'so dien thoai ban quan ly ktx, gap ai de phan anh ktx, ban quan ly noi tru', 'Để phản ánh các vấn đề về điện nước, an ninh phòng ở hoặc nộp chi phí nội trú Ký túc xá, sinh viên đến trực tiếp văn phòng Ban quản lý nội trú Ký túc xá đặt tại khu vực cổng vào của khu nội trú cơ sở đó để được cán bộ trực ban giải quyết. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-truong'),
(131, 'Phương thức tuyển sinh năm 2026 của UTH', 'phương thức tuyển sinh 2026, phuong thuc tuyen sinh 2026, uth xet tuyen cach nao, xet hoc ba 2026, diem thi thpt 2026', 'Năm 2026, UTH tuyển sinh đại học chính quy theo 2 phương thức: (1) Xét tuyển thẳng theo quy định của Bộ GD&ĐT và theo Đề án riêng của UTH (thí sinh đạt giải HSG cấp Tỉnh/Thành trở lên; có chứng chỉ tiếng Anh quốc tế từ IELTS 6.0, TOEFL iBT 60, TOEIC 600 hoặc Bậc 4/6 trở lên; học sinh trường chuyên/trọng điểm; đạt học lực Giỏi nhiều học kỳ; thuộc nhóm ngành ưu tiên nhà nước như đường sắt tốc độ cao, CNTT, trí tuệ nhân tạo; hoặc có thư giới thiệu từ doanh nghiệp đối tác của UTH); (2) Xét tuyển kết hợp - phương thức chủ đạo, chiếm phần lớn chỉ tiêu, tính điểm theo công thức riêng của trường (UTH120), kết hợp điểm thi Đánh giá năng lực (nếu có), điểm học bạ cả năm lớp 12, điểm thi tốt nghiệp THPT năm 2026 và điểm ưu tiên/điểm khuyến khích theo quy định. Từ năm 2025, UTH không còn xét tuyển riêng lẻ theo điểm thi THPT hay điểm học bạ như các năm trước đó; các loại điểm này chỉ là thành phần trong công thức xét tuyển kết hợp chung. Chương trình đào tạo được thiết kế 120 tín chỉ, thời gian học tối thiểu 3 năm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian công bố kết quả trúng tuyển chính thức và về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/thong-bao-su-kien'),
(132, 'Các tổ hợp môn xét tuyển phổ biến tại UTH', 'tổ hợp môn xét tuyển, to hop mon xet tuyen, khoi thi vao uth, khoi a00 a01 d01 d07, uth xet khoi nao', 'Trong công thức xét tuyển kết hợp của UTH, điểm xét tuyển được tính từ 3 môn theo tổ hợp đăng ký (các tổ hợp phổ biến nhiều năm qua gồm A00: Toán - Lý - Hóa; A01: Toán - Lý - Anh; D01: Toán - Văn - Anh; D07: Toán - Hóa - Anh), sau đó tổng hợp cùng điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực (nếu có) theo công thức và trọng số riêng của từng năm tuyển sinh. Công nghệ thông tin và Logistics - Quản lý chuỗi cung ứng tiếp tục là các nhóm ngành có chỉ tiêu lớn và mức độ cạnh tranh cao nhất trường. Vì tổ hợp và công thức tính điểm cụ thể có thể thay đổi theo từng ngành và từng năm, thí sinh nên tra cứu Đề án tuyển sinh chính thức hằng năm tại tuyensinh.ut.edu.vn để có thông tin chính xác nhất. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xác nhận nhập học trực tuyến hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/chuong-trinh-khung'),
(133, 'Điểm chuẩn ngành Công nghệ thông tin (CNTT) năm 2025', 'điểm chuẩn cntt 2025, diem chuan cong nghe thong tin 2025, nganh cntt uth bao nhieu diem, diem trung tuyen cntt', 'Năm 2025, UTH xét tuyển theo phương thức Xét tuyển kết hợp với thang điểm riêng của trường (không phải thang 30 quen thuộc, mà dao động 668-999 điểm tùy ngành). Điểm chuẩn trúng tuyển các chuyên ngành thuộc nhóm Công nghệ thông tin, công bố ngày 22/8/2025, như sau: CNTT (chuyên ngành CNTT, chương trình tiên tiến): 800 điểm; CNTT chuyên ngành Khoa học dữ liệu và AI (chương trình tiên tiến): 800 điểm; CNTT chương trình hoàn toàn bằng tiếng Anh: 800 điểm; CNTT chuyên ngành Truyền thông số và Đổi mới sáng tạo: 720 điểm; CNTT chuyên ngành Smart Logistics: 720 điểm; CNTT chuyên ngành Công nghệ ô tô số: 800 điểm. Lưu ý: mức điểm này tính theo công thức riêng của UTH (kết hợp điểm học bạ, điểm thi THPT, điểm Đánh giá năng lực và điểm ưu tiên) nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, cứ hỏi mình thêm nha.', NULL, 0, '/chuong-trinh-khung'),
(134, 'Điểm chuẩn ngành Logistics và Quản lý chuỗi cung ứng năm 2025', 'điểm chuẩn logistics 2025, diem chuan logistics 2025, nganh logistics lay bao nhieu diem, diem xet tuyen logistics', 'Logistics và Quản lý chuỗi cung ứng tiếp tục là một trong những ngành có điểm chuẩn cao nhất UTH. Theo điểm chuẩn chính thức công bố ngày 22/8/2025 (phương thức Xét tuyển kết hợp, thang điểm riêng của trường, KHÔNG phải thang 30): Logistics và Quản lý chuỗi cung ứng - chương trình tiên tiến: 963 điểm (chỉ xếp sau ngành Khoa học dữ liệu - chương trình tiên tiến với 999 điểm, cao nhất toàn trường); Logistics và Quản lý chuỗi cung ứng - chương trình hoàn toàn bằng tiếng Anh: 720 điểm. Đây tiếp tục là ngành có mức độ cạnh tranh rất cao tại UTH trong nhiều năm liền. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về rút hồ sơ thôi học và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/chuong-trinh-khung'),
(135, 'Điểm chuẩn tổng hợp tất cả các ngành năm 2025', 'điểm chuẩn 2025, diem chuan 2025, điểm chuẩn tất cả các ngành uth, diem chuan tat ca cac nganh, điểm chuẩn uth 2025 mới nhất, điểm chuẩn năm 2025 bao nhiêu, xet tuyen ket hop 2025, diem chuan hoc ba 2025', 'UTH công bố điểm chuẩn chính thức hệ đại học chính quy năm 2025 vào ngày 22/8/2025, theo phương thức Xét tuyển kết hợp (thang điểm riêng của trường, KHÔNG phải thang 30 truyền thống), dao động từ 668 đến 999 điểm tùy ngành/chuyên ngành. Một số mức điểm chuẩn tiêu biểu: Khoa học dữ liệu (chương trình tiên tiến) 999 điểm - cao nhất toàn trường; Logistics và Quản lý chuỗi cung ứng (chương trình tiên tiến) 963 điểm; Kỹ thuật điện (chuyên ngành Điện công nghiệp, Hệ thống điện giao thông, Năng lượng tái tạo) 936 điểm; Công nghệ kỹ thuật điều khiển và tự động hóa (chương trình tiên tiến) 931 điểm. Nhóm ngành phổ biến ở mức 720-800 điểm gồm: Công nghệ thông tin, Ngôn ngữ Anh, Luật, Quản trị kinh doanh, Hệ thống thông tin quản lý, Kỹ thuật cơ khí, Kỹ thuật ô tô, Kinh tế xây dựng, Khai thác vận tải, Kinh tế vận tải (đa số thuộc chương trình tiên tiến). Nhóm có điểm sàn thấp nhất (668 điểm) gồm các chương trình chuẩn (không phải tiên tiến) như Kỹ thuật tàu thủy, Kỹ thuật xây dựng công trình thủy, Khoa học hàng hải và các ngành liên quan đường sắt tốc độ cao. Lưu ý quan trọng: mức điểm 2025 tính theo công thức riêng của UTH (kết hợp điểm học bạ lớp 12, điểm thi THPT, điểm thi Đánh giá năng lực và điểm ưu tiên), nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Trường có hơn 50 ngành/chuyên ngành/chương trình đào tạo khác nhau, mỗi ngành có mức điểm riêng; thí sinh nên tra cứu bảng điểm chuẩn đầy đủ theo từng mã ngành tại tuyensinh.ut.edu.vn hoặc liên hệ Phòng Đào tạo để được tư vấn chính xác. Ngoài ra, nếu bạn còn thắc mắc về phương thức tuyển sinh năm 2026 của UTH hoặc về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(136, 'Chỉ tiêu tuyển sinh dự kiến năm 2026', 'chỉ tiêu tuyển sinh 2026, chi tieu tuyen sinh 2026, uth tuyen bao nhieu sinh vien, chi tieu nganh cntt 2026', 'UTH công bố Đề án tuyển sinh đại học chính quy năm 2026 vào ngày 16/6/2026, với hơn 50 ngành/chuyên ngành đào tạo, mở rộng thêm nhiều chuyên ngành mới gắn với công nghệ số như: Khoa học dữ liệu - Blockchain và AI, Smart Logistics, Công nghệ ô tô số, Kinh tế số và Trí tuệ nhân tạo, Truyền thông số và Đổi mới sáng tạo, Logistics xanh và phát triển bền vững, Quản lý và công nghệ UAV... Chỉ tiêu cụ thể được phân bổ chi tiết theo từng mã ngành trong Đề án tuyển sinh chính thức chứ không phải một con số tổng cố định, và có thể thay đổi theo từng năm. Thí sinh nên tra cứu chỉ tiêu cụ thể theo từng mã ngành tại Đề án tuyển sinh 2026 chính thức đăng trên tuyensinh.ut.edu.vn thay vì dựa vào số liệu ước tính. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành công nghệ thông tin, hay về thủ tục xác nhận nhập học trực tuyến, cứ hỏi mình thêm nha.', NULL, 0, '/thong-tin-truong'),
(137, 'Cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH', 'quy đổi điểm ielts, quy doi diem ielts tuyen sinh, ielts 5.5 duoc may diem, cong diem ielts vao uth', 'UTH không áp dụng một bảng quy đổi điểm IELTS sang thang điểm xét tuyển cố định. Chứng chỉ tiếng Anh quốc tế được UTH sử dụng theo 2 cách: (1) Trong xét tuyển đầu vào: thí sinh có chứng chỉ IELTS từ 6.0 trở lên (hoặc TOEFL iBT từ 60, TOEFL ITP từ 530, TOEIC từ 600, Bậc 4 theo Khung năng lực ngoại ngữ 6 bậc dùng cho Việt Nam trở lên, còn hiệu lực) có thể dùng làm một trong các tiêu chí để đăng ký diện Xét tuyển thẳng theo Đề án riêng của UTH; (2) Sau khi nhập học: sinh viên nộp chứng chỉ IELTS hoặc chứng chỉ ngoại ngữ tương đương để trường xét miễn các cấp độ học phần tiếng Anh tương ứng với năng lực (miễn đến cấp độ nào thì được miễn học phí cấp độ đó), nộp hồ sơ trực tuyến qua support.ut.edu.vn (mục Phòng Đào tạo/Chuẩn đào tạo ngoại ngữ UTH). Vì điều kiện cụ thể có thể điều chỉnh theo từng năm, sinh viên nên tra cứu Đề án tuyển sinh hoặc thông báo chính thức mới nhất của UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(138, 'Điểm sàn nhận hồ sơ xét tuyển (Ngưỡng đảm bảo chất lượng)', 'điểm sàn uth, diem san nhan ho so, bao nhieu diem thi duoc nop don, diem san 2025 2026', 'Từ năm 2025, UTH chuyển sang phương thức Xét tuyển kết hợp làm phương thức tuyển sinh chủ đạo (tính điểm theo công thức riêng của trường, kết hợp điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực), nên khái niệm \"điểm sàn\" theo thang 30 truyền thống không còn áp dụng thống nhất cho toàn trường như các năm trước 2025. Điều kiện đầu vào tối thiểu của phương thức xét tuyển kết hợp hiện nay là thí sinh phải có điểm thi môn Toán trong kỳ thi tốt nghiệp THPT từ 5.0 trở lên (một số ngành yêu cầu cao hơn, ví dụ ngành Toán ứng dụng yêu cầu từ 6.0), cùng với ngưỡng đảm bảo chất lượng cụ thể theo từng ngành được quy định riêng trong Đề án tuyển sinh của từng năm. Thí sinh cần tra cứu Đề án tuyển sinh chính thức mới nhất tại tuyensinh.ut.edu.vn để biết điều kiện đăng ký xét tuyển áp dụng cho ngành mình quan tâm. Ngoài ra, nếu bạn còn thắc mắc về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT hoặc về lệ phí xét tuyển hồ sơ đầu vào, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(139, 'Đăng ký nguyện vọng vào UTH trên hệ thống của Bộ GD&ĐT', 'đăng ký nguyện vọng, dang ky nguyen vong, ma truong uth la gi, xep nguyen vong vao uth', 'Để xét tuyển vào UTH bằng điểm thi THPT, thí sinh phải đăng ký nguyện vọng trên hệ thống chung của Bộ GD&ĐT theo đúng lịch quy định. Thí sinh cần nhập chính xác Mã trường của UTH là GTS và chọn đúng mã ngành, mã tổ hợp môn mong muốn. Nên xếp ngành yêu thích nhất ở Nguyện vọng 1. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025, hay về lệ phí xét tuyển hồ sơ đầu vào, cứ hỏi mình thêm nha.', NULL, 0, '/thong-bao-su-kien'),
(140, 'Lệ phí xét tuyển hồ sơ đầu vào', 'lệ phí xét tuyển, le phi xet tuyen, nop tien xet hoc ba bao nhieu, dong tien nguyen vong', 'Lệ phí xét tuyển đối với phương thức xét học bạ nộp trực tiếp về trường UTH áp dụng theo quy định hành chính thu chi. Đối với phương thức xét điểm thi THPT, thí sinh đóng lệ phí trực tuyến trực tiếp trên hệ thống cổng thông tin của Bộ GD&ĐT khi tiến hành xác nhận số lượng nguyện vọng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học phí trường và về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/cong-thanh-toan'),
(141, 'Thời gian công bố kết quả trúng tuyển chính thức', 'khi nào biết kết quả trúng tuyển, khi nao biet ket qua trung tuyen, lich cong bo diem chuan uth', 'Thời gian công bố điểm chuẩn và danh sách trúng tuyển chính thức của UTH tuân thủ nghiêm ngặt theo lộ trình chung của Bộ GD&ĐT (thường vào khoảng tháng 8 hằng năm). Kết quả xét tuyển sớm bằng học bạ thường được trường thông báo trước đó vào tháng 6 hoặc tháng 7. Ngoài ra, nếu bạn còn thắc mắc về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-bao-su-kien'),
(142, 'Thủ tục xác nhận nhập học trực tuyến', 'xác nhận nhập học, xac nhan nhap hoc online, huong dan nhap hoc uth, khong xac nhan nhap hoc bi gi', 'Sau khi có thông báo trúng tuyển chính thức, thí sinh bắt buộc phải thực hiện bước Xác nhận nhập học trực tuyến trên hệ thống của Bộ GD&ĐT trước thời hạn quy định. Thí sinh cố tình không xác nhận nhập học đúng hạn sẽ bị hệ thống tự động hủy kết quả trúng tuyển vào trường. Bên cạnh đó, nếu bạn cũng quan tâm về các tổ hợp môn xét tuyển phổ biến tại UTH, hay về phương thức tuyển sinh năm 2026 của UTH, cứ hỏi mình thêm nha.', NULL, 0, '/dich-vu-sinh-vien'),
(143, 'Hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học', 'hồ sơ nhập học cần gì, ho so nhap hoc can gi, mang theo gi khi nhap hoc uth, giay to nhap hoc', 'Hồ sơ nhập học bản giấy nộp tại trường bao gồm: Giấy báo trúng tuyển bản gốc; Học bạ THPT (bản sao công chứng); Giấy chứng nhận tốt nghiệp tạm thời hoặc Bằng tốt nghiệp THPT; Bản sao CCCD; Giấy khai sinh; và các giấy tờ minh chứng đối tượng ưu tiên chính sách (nếu có). Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy trình làm thủ tục nhập học trực tiếp tại trường và về rút hồ sơ thôi học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', NULL, 0, '/dich-vu-sinh-vien'),
(144, 'Quy trình làm thủ tục nhập học trực tiếp tại trường', 'quy trình nhập học trực tiếp, quy trinh nhap hoc truc tiep, den truong nhap hoc o dau, huong dan tan sinh vien', 'Khi đến nhập học trực tiếp tại cơ sở chính của UTH, tân sinh viên thực hiện theo quy trình luồng: - Tra cứu số thứ tự và phòng làm thủ tục tại sảnh hướng dẫn. - Nộp hồ sơ bản giấy tại bàn tiếp nhận của Khoa/Viện. - Đóng học phí và các khoản bảo hiểm bắt buộc tại bàn tài chính. - Nhận lịch học Tuần sinh hoạt công dân và chụp ảnh làm Thẻ sinh viên. Ngoài ra, nếu bạn còn thắc mắc về thời gian nhận bằng tốt nghiệp hoặc về điều kiện tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', NULL, 0, '/thong-tin-truong'),
(145, 'Chính sách rút hồ sơ hoàn học phí đối với tân sinh viên', 'rút học phí nhập học, rut hoc phi nhap hoc, nhap hoc roi xin rut lai tien, thoi hoc rut lai hoc phi', 'Tân sinh viên đã làm thủ tục nhập học nhưng vì lý do cá nhân muốn xin rút hồ sơ không theo học nữa sẽ được xem xét hoàn trả học phí tùy theo thời điểm nộp đơn. Nếu nộp đơn rút trước ngày khai giảng chính thức, sinh viên được hoàn lại một phần học phí theo quy định đóng rút bồi hoàn của nhà trường; sau ngày khai giảng sẽ không được hoàn phí. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách hỗ trợ sinh viên nghèo, hay về quy trình vay vốn ngân hàng, cứ hỏi mình thêm nha.', NULL, 0, '/cong-thanh-toan');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `grades`
--

CREATE TABLE `grades` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_score` decimal(5,2) DEFAULT NULL,
  `process_score` decimal(5,2) DEFAULT NULL,
  `midterm_score` decimal(5,2) DEFAULT NULL,
  `final_exam_score` decimal(5,2) DEFAULT NULL,
  `final_score_10` decimal(5,2) DEFAULT NULL,
  `grade_4` decimal(4,2) DEFAULT NULL,
  `letter_grade` varchar(5) DEFAULT NULL,
  `result` enum('pending','passed','failed','exempted') NOT NULL DEFAULT 'pending',
  `published_at` datetime DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ;

--
-- Đang đổ dữ liệu cho bảng `grades`
--

INSERT INTO `grades` (`id`, `enrollment_id`, `attendance_score`, `process_score`, `midterm_score`, `final_exam_score`, `final_score_10`, `grade_4`, `letter_grade`, `result`, `published_at`, `updated_at`) VALUES
(1, 3, 9.00, 8.50, 8.00, 8.20, 8.30, 3.50, 'B+', 'passed', '2026-07-08 09:00:00', '2026-07-11 16:34:11'),
(2, 2, 8.50, 8.00, 7.50, 7.80, 7.90, 3.00, 'B', 'passed', '2026-07-08 09:00:00', '2026-07-11 16:34:11'),
(3, 4, 8.00, 7.50, 7.00, NULL, NULL, NULL, NULL, 'pending', NULL, '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `knowledge_articles`
--

CREATE TABLE `knowledge_articles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(500) NOT NULL,
  `category` varchar(120) NOT NULL,
  `subcategory` varchar(120) DEFAULT NULL,
  `intent_code` varchar(120) DEFAULT NULL,
  `keywords` text DEFAULT NULL,
  `answer_content` longtext NOT NULL,
  `route_url` varchar(1000) DEFAULT NULL,
  `audience` enum('all','prospective_student','student','lecturer','staff','parent') NOT NULL DEFAULT 'all',
  `faculty_id` bigint(20) UNSIGNED DEFAULT NULL,
  `program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `cohort_from` smallint(5) UNSIGNED DEFAULT NULL,
  `cohort_to` smallint(5) UNSIGNED DEFAULT NULL,
  `semester_code` varchar(30) DEFAULT NULL,
  `academic_year_code` varchar(20) DEFAULT NULL,
  `valid_from` datetime DEFAULT NULL,
  `valid_until` datetime DEFAULT NULL,
  `verification_status` enum('draft','pending','verified','rejected','expired') NOT NULL DEFAULT 'draft',
  `confidence_level` enum('low','medium','high','authoritative') NOT NULL DEFAULT 'low',
  `priority` tinyint(3) UNSIGNED NOT NULL DEFAULT 5,
  `version` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `language_code` varchar(10) NOT NULL DEFAULT 'vi',
  `created_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `knowledge_articles`
--

INSERT INTO `knowledge_articles` (`id`, `source_id`, `title`, `category`, `subcategory`, `intent_code`, `keywords`, `answer_content`, `route_url`, `audience`, `faculty_id`, `program_id`, `cohort_from`, `cohort_to`, `semester_code`, `academic_year_code`, `valid_from`, `valid_until`, `verification_status`, `confidence_level`, `priority`, `version`, `language_code`, `created_by`, `reviewed_by`, `reviewed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'FAQ #1 - Thông tin chung', 'Thông tin chung', NULL, NULL, 'Địa chỉ trường ở đâu? UTH có mấy cơ sở? Trường nằm ở chỗ nào?', 'Trường Đại học Giao thông Vận tải TP.HCM (UTH) có cơ sở chính tại Số 2, Đường Võ Oanh, Phường 25, Quận Bình Thạnh, TP.HCM. Ngoài ra, trường còn có các cơ sở đào tạo khác tại Quận 12 (TP.HCM), TP. Thủ Đức và TP. Vũng Tàu. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về bãi giữ xe của trường, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(2, 1, 'FAQ #2 - Chương trình Đào tạo', 'Chương trình Đào tạo', NULL, NULL, 'Trường có những ngành gì? Ngành CNTT học hệ nào? Đào tạo chất lượng cao là sao?', 'UTH là trường công lập đào tạo đa ngành hàng đầu về Giao thông vận tải, Logistics, Công nghệ thông tin, Khoa học dữ liệu, Điện tử viễn thông, Kinh tế vận tải và Kỹ thuật công trình. Hệ đào tạo gồm 2 loại hình: Hệ Đại trà và Hệ Chất lượng cao. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian nhận bằng tốt nghiệp và về xin hoãn đi thực tập tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(3, 1, 'FAQ #3 - Cách Tính Điểm', 'Cách Tính Điểm', NULL, NULL, 'Cách tính điểm môn học thế nào? Điểm F là gì? Quy chế thang điểm chữ?', 'UTH áp dụng đào tạo theo hệ thống tín chỉ. Điểm tổng kết môn gồm: Điểm quá trình và Điểm thi kết thúc học phần. Điểm tính theo thang điểm 10 rồi quy đổi sang thang điểm chữ (A, B, C, D, F) tương ứng với thang điểm 4. Điểm F là rớt môn và bắt buộc phải đóng tiền đăng ký học lại. Ngoài ra, nếu bạn còn thắc mắc về xét giảm điểm rèn luyện hoặc về phúc khảo điểm thi, mình có thể hỗ trợ giải đáp thêm nhé.', '/ket-qua-hoc-tap', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(4, 1, 'FAQ #4 - Học Cải Thiện', 'Học Cải Thiện', NULL, NULL, 'Điểm thấp có được học lại không? Làm sao để nâng điểm tích lũy?', 'Sinh viên đạt điểm trung bình môn ở mức D, D+, C, C+ muốn nâng cao điểm trung bình tích lũy (GPA) được phép đăng ký học cải thiện vào các học kỳ tiếp theo. Khi học cải thiện, điểm của lần học sau sẽ thay thế hoàn toàn cho điểm của lần học trước. Bên cạnh đó, nếu bạn cũng quan tâm về xét giảm điểm rèn luyện, hay về quy trình chấm điểm rèn luyện, cứ hỏi mình thêm nha.', '/ket-qua-hoc-tap', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(5, 1, 'FAQ #5 - Cảnh Báo Học Vụ', 'Cảnh Báo Học Vụ', NULL, NULL, 'Điều kiện xét nâng lớp? Khi nào bị cảnh báo học vụ? Bị buộc thôi học khi nào?', 'Sinh viên sẽ bị cảnh báo học vụ nếu điểm trung bình tích lũy học kỳ đạt dưới 0.8 (đối với học kỳ đầu tiên) hoặc dưới 1.0 (đối với các học kỳ tiếp theo), hoặc số tín chỉ bị nợ vượt quá quy định. Bị cảnh báo học vụ 2 lần liên tiếp sẽ thuộc diện xem xét buộc thôi học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xét giảm điểm rèn luyện và về điểm rèn luyện f — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(6, 1, 'FAQ #6 - Đăng Ký Môn Học', 'Đăng Ký Môn Học', NULL, NULL, 'Khi nào đăng ký học phần? Một kỳ được đăng ký tối đa bao nhiêu tín chỉ? Hủy môn học ở đâu?', 'Sinh viên thực hiện đăng ký học phần (DKMH) trực tuyến tại trang Portal UTH theo khung thời gian thông báo của Phòng Đào tạo. Sinh viên hệ đại trà được đăng ký tối đa 24 tín chỉ và tối thiểu 14 tín chỉ trong một học kỳ chính. Ngoài ra, nếu bạn còn thắc mắc về quy định số lần cảnh báo học vụ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', '/dang-ky-hoc-phan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(7, 1, 'FAQ #7 - Môn Điều Kiện', 'Môn Điều Kiện', NULL, NULL, 'Môn tiên quyết là gì? Môn học trước là gì? Khác nhau thế nào?', 'Môn tiên quyết là môn sinh viên bắt buộc phải học và thi đạt (điểm chữ từ D trở lên) mới được đăng ký môn tiếp theo. Môn học trước là môn sinh viên chỉ cần hoàn thành khóa học (kể cả thi rớt điểm F) là đã đủ điều kiện đăng ký môn sau. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình chấm điểm rèn luyện, hay về bảo lưu kết quả, cứ hỏi mình thêm nha.', '/dang-ky-mon-hoc-dieu-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(8, 1, 'FAQ #8 - Quy Chế Thi Cử', 'Quy Chế Thi Cử', NULL, NULL, 'Xem lịch thi ở đâu? Vào phòng thi cần mang gì? Hoãn thi làm sao?', 'Lịch thi học kỳ được công bố trên Portal trước kỳ thi 2 tuần. Khi vào phòng thi, sinh viên bắt buộc phải xuất trình Thẻ sinh viên chính thức hoặc giấy tờ tùy thân có ảnh (CCCD). Sinh viên vắng thi không có lý do chính đáng sẽ nhận điểm 0. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về bảo lưu kết quả và về rút học phần, hủy môn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/lich-hoc-trong-tuan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(9, 1, 'FAQ #9 - Học Phí Trường', 'Học Phí Trường', NULL, NULL, 'Học phí một tín chỉ bao nhiêu tiền? Đóng tiền học ở đâu?', 'Học phí UTH được tính theo số tín chỉ đăng ký mỗi học kỳ, phân theo 3 loại chương trình: Chương trình chuẩn (đại trà), Chương trình tiên tiến (trước đây gọi là Chất lượng cao) và Chương trình học hoàn toàn bằng tiếng Anh. Mức thu áp dụng cho tân sinh viên khóa tuyển sinh năm 2026: Chương trình chuẩn 515.000đ/tín chỉ; Chương trình tiên tiến 1.120.000đ/tín chỉ; Chương trình hoàn toàn bằng tiếng Anh 1.500.000đ/tín chỉ. Sinh viên các khóa nhập học từ năm 2025 trở về trước áp dụng mức học phí đã công bố riêng cho khóa đó (thường thấp hơn khóa mới, ví dụ khóa 2025: chương trình chuẩn 400.000đ/tín chỉ, tiên tiến 980.000đ/tín chỉ). Trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học của mỗi khóa. Sinh viên nộp học phí trực tuyến qua Cổng thanh toán của trường (payment.ut.edu.vn) và nên tra cứu mức thu chính xác áp dụng cho khóa của mình trên Portal cá nhân. Ngoài ra, nếu bạn còn thắc mắc về học phí chương trình tiên tiến hoặc về chính sách hỗ trợ bảo hiểm tai nạn, mình có thể hỗ trợ giải đáp thêm nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(10, 1, 'FAQ #10 - Gia Hạn Học Phí', 'Gia Hạn Học Phí', NULL, NULL, 'Không có tiền đóng học phí làm sao? Xin nợ học phí ở đâu?', 'Sinh viên có hoàn cảnh khó khăn không thể hoàn thành học phí đúng hạn phải làm Đơn xin gia hạn học phí trực tuyến gửi Phòng Công tác sinh viên trước thời hạn quy định để không bị khóa tài khoản đăng ký môn học và bị cấm thi. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', '/tra-cuu-cong-no', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(11, 1, 'FAQ #11 - Hoạt Động Đoàn Hội', 'Hoạt Động Đoàn Hội', NULL, NULL, 'Lịch hiến máu tình nguyện? Tham gia hoạt động được cộng bao nhiêu điểm rèn luyện?', 'Ngày hội hiến máu tình nguyện trường UTH được tổ chức định kỳ hàng năm tại Sảnh lớn khu giảng đường A. Sinh viên tham gia hiến máu nhân đạo sẽ được cấp giấy chứng nhận, hỗ trợ chi phí và được cộng 5 điểm rèn luyện (ĐRL) vào mục hoạt động cộng đồng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về ngày hội sáng tạo và về học bổng doanh nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(12, 1, 'FAQ #12 - Các Câu Lạc Bộ', 'Các Câu Lạc Bộ', NULL, NULL, 'Trường có CLB guitar không? Đội tình nguyện hoạt động thế nào?', 'UTH hiện có hơn 20 Câu lạc bộ (CLB) sinh viên đang hoạt động thuộc các khối: Học thuật (CLB Tin học, CLB Logistics), Nghệ thuật (CLB Guitar, CLB Bước Nhảy), Thể thao (CLB Bóng đá, Bóng chuyền) và Tình nguyện (Đội Công tác xã hội, CLB Tiếp sức đến trường). Ngoài ra, nếu bạn còn thắc mắc về hoạt động đoàn hội hoặc về đăng ký tham gia hiến máu đợt hè, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(13, 1, 'FAQ #13 - Học Bổng Khuyến Khích', 'Học Bổng Khuyến Khích', NULL, NULL, 'Điều kiện nhận học bổng trường? Điểm rèn luyện bao nhiêu thì được học bổng?', 'Học bổng khuyến khích học tập UTH được xét sau mỗi học kỳ dựa trên 2 tiêu chí song song: Điểm trung bình học tập đạt loại Khá trở lên (từ 2.5/4.0) và Điểm rèn luyện đạt loại Tốt trở lên (từ 80 điểm/100), đồng thời không bị kỷ luật và không nợ môn. Bên cạnh đó, nếu bạn cũng quan tâm về chiến sĩ tình nguyện, hay về giải chạy sinh viên, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(14, 1, 'FAQ #14 - Chuẩn Đầu Ra Ngoại Ngữ', 'Chuẩn Đầu Ra Ngoại Ngữ', NULL, NULL, 'Chuẩn tiếng Anh xét tốt nghiệp? Nộp bằng TOEIC ở đâu? Điều kiện miễn học Anh văn?', 'Sinh viên đại học chính quy UTH phải đạt chuẩn đầu ra tiếng Anh theo quy định (thường là TOEIC 450 trở lên hoặc B1 VSTEP tùy theo ngành học). Chứng chỉ phải còn giá trị hiệu lực và nộp về Trung tâm Ngoại ngữ trường để làm thủ tục hậu kiểm xét tốt nghiệp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về đăng ký thi lại chuẩn đầu ra — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(15, 1, 'FAQ #15 - Chuẩn Tin Học', 'Chuẩn Tin Học', NULL, NULL, 'Chuẩn tin học đầu ra là gì? Chứng chỉ MOS hay IC3?', 'Sinh viên UTH bắt buộc phải hoàn thành chuẩn đầu ra Tin học bằng việc đạt chứng chỉ Tin học đại chúng đại học hoặc các chứng chỉ quốc tế được công nhận tương đương như MOS (đạt 3 kỹ năng Word, Excel, Powerpoint) hoặc IC3. Ngoài ra, nếu bạn còn thắc mắc về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH hoặc về chuẩn tin học quốc tế nâng cao, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(16, 1, 'FAQ #16 - Điều Kiện Tốt Nghiệp', 'Điều Kiện Tốt Nghiệp', NULL, NULL, 'Làm sao để được ra trường? Điều kiện xét tốt nghiệp UTH? Nợ môn có được xét tốt nghiệp?', 'Điều kiện xét công nhận tốt nghiệp UTH: Tích lũy đủ số tín chỉ của chương trình khung; Điểm trung bình tích lũy (GPA) toàn khóa đạt từ 2.0/4.0 trở lên; Đạt chuẩn đầu ra Ngoại ngữ và Tin học; Đạt chứng chỉ Giáo dục quốc phòng và Giáo dục thể chất; Không trong thời gian bị kỷ luật. Bên cạnh đó, nếu bạn cũng quan tâm về chuyển cơ sở học tập, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(17, 1, 'FAQ #17 - Mất Thẻ Sinh Viên', 'Mất Thẻ Sinh Viên', NULL, NULL, 'Làm lại thẻ sinh viên ở đâu? Mất thẻ sinh viên đóng phạt bao nhiêu?', 'Khi bị mất thẻ, sinh viên đến Phòng Công tác sinh viên (Cơ sở chính, khu nhà A) để làm thủ tục xin cấp lại thẻ sinh viên mới. Lệ phí cấp lại thẻ theo quy định là 50.000đ. Trong thời gian chờ cấp thẻ mới, sinh viên được cấp giấy xác nhận tạm thời để ra vào trường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về quy định mượn học cụ, thiết bị tại phòng thí nghiệm — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(18, 1, 'FAQ #18 - Ký Túc Xá Trường', 'Ký Túc Xá Trường', NULL, NULL, 'Đăng ký ở KTX ở đâu? Chi phí Ký túc xá UTH? Đối tượng ưu tiên ở KTX?', 'UTH hỗ trợ chỗ ở tại Ký túc xá trường cho sinh viên (ưu tiên sinh viên diện chính sách, vùng sâu vùng xa, hoàn cảnh khó khăn). Sinh viên làm Đơn đăng ký nội trú trực tuyến trên Portal hoặc nộp hồ sơ trực tiếp tại Ban quản lý Ký túc xá trong thời gian quy định đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về liên hệ ban quản lý ký túc xá hoặc về ký túc xá quận 12, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(19, 1, 'FAQ #19 - Mượn Sách Thư Viện', 'Mượn Sách Thư Viện', NULL, NULL, 'Thư viện trường ở đâu? Cách mượn sách về nhà? Trả sách trễ hạn bị phạt thế nào?', 'Thư viện UTH đặt tại khu vực cơ sở chính. Sinh viên sử dụng Thẻ sinh viên để vào thư viện đọc sách hoặc làm thủ tục mượn tài liệu về nhà. Thời gian mượn tối đa là 2 tuần/cuốn. Nếu trả sách trễ hạn, sinh viên sẽ bị phạt tiền theo quy định của thư viện. Bên cạnh đó, nếu bạn cũng quan tâm về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, hay về bảng điểm tiếng anh, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(20, 1, 'FAQ #20 - Bảo Hiểm Y Tế', 'Bảo Hiểm Y Tế', NULL, NULL, 'Đóng tiền bảo hiểm y tế ở đâu? Hạn chót nộp BHYT? Gia hạn bảo hiểm sinh viên?', 'Bảo hiểm y tế (BHYT) là hình thức bắt buộc đối với tất cả sinh viên. Nhà trường tổ chức thu tiền và gia hạn BHYT định kỳ vào đầu năm học thông qua Cổng thanh toán trực tuyến. Sinh viên có thẻ BHYT diện hộ nghèo, thân nhân quân nhân phải nộp bản photo minh chứng để được miễn giảm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đóng lệ phí thi lại và về phí phạt nợ học phí quá hạn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(21, 1, 'FAQ #21 - Sinh Viên 5 Tốt', 'Sinh Viên 5 Tốt', NULL, NULL, 'Tiêu chí đạt Sinh viên 5 Tốt? Quyền lợi khi đạt Sinh viên 5 Tốt UTH?', 'Danh hiệu Sinh viên 5 Tốt được xét duyệt hàng năm dựa trên 5 tiêu chí: Học tập tốt (GPA >= 3.2 hoặc 2.8 tùy hệ), Đạo đức tốt (ĐRL >= 80), Thể lực tốt (đạt danh hiệu khỏe), Tình nguyện tốt (tham gia chiến dịch lớn), và Hội nhập tốt (đạt giải thưởng khoa học hoặc kỹ năng ngoại ngữ tốt). Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về khen thưởng sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(22, 1, 'FAQ #22 - Nghiên Cứu Khoa Học', 'Nghiên Cứu Khoa Học', NULL, NULL, 'Đăng ký nghiên cứu khoa học ở đâu? Quyền lợi khi làm NCKH sinh viên?', 'Phong trào Nghiên cứu khoa học (NCKH) sinh viên UTH được phát động vào đầu học kỳ 1. Sinh viên đăng ký đề tài theo nhóm (dưới sự hướng dẫn của giảng viên) thông qua Phòng Quản lý khoa học. Đề tài nghiệm thu đạt loại Khá trở lên sẽ được cộng điểm rèn luyện và thưởng tiền mặt. Bên cạnh đó, nếu bạn cũng quan tâm về đại hội đoàn, hay về giải bóng đá UTH, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(23, 1, 'FAQ #23 - Rút Học Phần, Hủy Môn', 'Rút Học Phần, Hủy Môn', NULL, NULL, 'Cách rút môn học? Hạn chót hủy học phần đã đăng ký? Rút môn có được hoàn tiền không?', 'Trong 2 tuần đầu của học kỳ chính (hoặc 1 tuần đối với học kỳ hè), sinh viên được phép nộp đơn online để xin rút bớt học phần đã đăng ký. Học phần xin rút thành công sẽ ghi nhận điểm chữ W trên bảng điểm, không tính vào điểm trung bình tích lũy nhưng sinh viên không được hoàn lại học phí. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy chế thi cử và về quy trình chấm điểm rèn luyện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dang-ky-hoc-phan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(24, 1, 'FAQ #24 - Phòng Công Tác Sinh Viên', 'Phòng Công Tác Sinh Viên', NULL, NULL, 'Liên hệ phòng CTSV ở đâu? Xin giấy xác nhận sinh viên vay vốn ở đâu?', 'Phòng Công tác sinh viên (CTSV) chịu trách nhiệm giải quyết các thủ tục: Cấp giấy xác nhận sinh viên để vay vốn ngân hàng, tạm hoãn nghĩa vụ quân sự, đánh giá điểm rèn luyện, giải quyết chế độ chính sách, miễn giảm học phí. Văn phòng đặt tại tầng trệt nhà A cơ sở chính. Ngoài ra, nếu bạn còn thắc mắc về minh chứng ĐRL hoặc về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(25, 1, 'FAQ #25 - Phòng Đào Tạo', 'Phòng Đào Tạo', NULL, NULL, 'Số điện thoại Phòng Đào tạo? Hỏi về lịch học, lịch thi, xét tốt nghiệp ở đâu?', 'Phòng Đào tạo UTH là nơi giải quyết các vấn đề chuyên môn về: Khung lịch học, lịch thi, giải quyết đơn phúc khảo điểm thi, cấp bảng điểm chính thức, xử lý hồ sơ chuyển ngành, ngừng học tạm thời, bảo lưu kết quả, và xét công nhận tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về các tuyến xe buýt, hay về đại hội đoàn, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(26, 1, 'FAQ #26 - Ký Túc Xá Quận 12', 'Ký Túc Xá Quận 12', NULL, NULL, 'KTX Quận 12 ở đâu? Đăng ký ký túc xá cơ sở 2? Chi phí phòng KTX Quận 12?', 'Cơ sở 2 của UTH tại Quận 12 có khu Ký túc xá khang trang dành riêng cho sinh viên học tập tại đây. Chi phí nội trú dao động từ 150.000đ - 250.000đ/tháng/sinh viên tùy loại phòng. Sinh viên nộp đơn đăng ký trực tiếp tại Ban quản lý KTX Cơ sở 2. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về ký túc xá trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(27, 1, 'FAQ #27 - Học Bổng Doanh Nghiệp', 'Học Bổng Doanh Nghiệp', NULL, NULL, 'Học bổng tài trợ? Điều kiện nhận học bổng ngoài ngân sách? Học bổng vượt khó?', 'Ngoài học bổng khuyến khích của trường, sinh viên UTH còn có cơ hội nhận Học bổng tài trợ từ các tập đoàn, doanh nghiệp lớn đối tác (như các tổng công ty xây dựng, cảng biển, công ty công nghệ). Tiêu chí xét tuyển thường ưu tiên sinh viên nghèo vượt khó học giỏi hoặc có thành tích xuất sắc. Ngoài ra, nếu bạn còn thắc mắc về giải chạy sinh viên hoặc về học bổng liên kết, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(28, 1, 'FAQ #28 - Các Tuyến Xe Buýt', 'Các Tuyến Xe Buýt', NULL, NULL, 'Xe buýt nào đi qua trường UTH? Đi xe bus đến Võ Oanh? Xe bus qua cơ sở Bình Thạnh?', 'Cơ sở chính Võ Oanh (Bình Thạnh) có rất nhiều tuyến xe buýt đi qua như tuyến số 08, 14, 19, 43, 44, 93 (dừng tại trạm Điện Biên Phủ hoặc Nguyễn Văn Thương rồi đi bộ vào). Sinh viên được hưởng giá vé ưu đãi khi xuất trình Thẻ sinh viên UTH. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về thời gian giữ xe tối đa tại trường, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(29, 1, 'FAQ #29 - Thủ Tục Chuyển Ngành', 'Thủ Tục Chuyển Ngành', NULL, NULL, 'Làm sao để đổi ngành học? Điều kiện chuyển ngành UTH? Đang học có được đổi ngành khác?', 'Sinh viên được xem xét chuyển ngành nếu: Không thuộc diện bị buộc thôi học; Điểm xét tuyển đầu vào không thấp hơn điểm trúng tuyển của ngành muốn chuyển sang; Có đơn xin chuyển ngành và được sự đồng ý của cả hai Khoa chủ quản. Thủ tục làm tại Phòng Đào tạo vào cuối năm học thứ nhất. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký môn học và về cảnh báo học vụ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(30, 1, 'FAQ #30 - Bảo Lưu Kết Quả', 'Bảo Lưu Kết Quả', NULL, NULL, 'Xin tạm dừng học? Cách làm đơn bảo lưu học tập? Nghỉ học tạm thời được bao lâu?', 'Sinh viên được xin nghỉ học tạm thời và bảo lưu kết quả học tập vì lý do cá nhân (như sức khỏe, hoàn cảnh gia đình hoặc thực hiện nghĩa vụ quân sự). Thời gian tạm dừng học không quá 2 học kỳ chính và phải làm đơn nộp về Phòng Đào tạo trước khi học kỳ mới bắt đầu. Ngoài ra, nếu bạn còn thắc mắc về đăng ký môn học hoặc về quy định số lần cảnh báo học vụ, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(31, 1, 'FAQ #31 - Phúc Khảo Điểm Thi', 'Phúc Khảo Điểm Thi', NULL, NULL, 'Chấm phúc khảo ở đâu? Lệ phí phúc khảo bài thi? Thời hạn nộp đơn chấm phúc khảo?', 'Nếu thấy điểm thi kết thúc học phần không chính xác, sinh viên có quyền làm Đơn xin phúc khảo bài thi nộp về Phòng Đào tạo hoặc văn phòng Khoa trong vòng 5 ngày làm việc kể từ ngày công bố điểm. Lệ phí phúc khảo theo quy định hiện hành của trường. Bên cạnh đó, nếu bạn cũng quan tâm về quy định số lần cảnh báo học vụ, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', '/ket-qua-hoc-tap', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(32, 1, 'FAQ #32 - Đồng Phục & Trang Phục', 'Đồng Phục & Trang Phục', NULL, NULL, 'Quy định đồng phục UTH? Mặc áo gì đi học? Có bắt buộc mặc áo trường không?', 'Sinh viên khi đến trường UTH phải ăn mặc lịch sự, gọn gàng, không mặc quần đùi, áo ba lỗ, dép lê vào lớp. Nhà trường khuyến khích sinh viên mặc Áo thun đồng phục UTH hoặc áo sơ mi trắng vào các ngày lễ, các buổi sinh hoạt chung và các ngày cố định theo quy định của Khoa. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký cấp lại tài khoản email sinh viên và về phòng đào tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(33, 1, 'FAQ #33 - Kỷ Luật Học Đường', 'Kỷ Luật Học Đường', NULL, NULL, 'Quy chế kỷ luật sinh viên? Đi thi gian lận bị phạt thế nào? Quay cóp bài thi bị xử lý sao?', 'Sinh viên vi phạm quy chế thi cử (như mang tài liệu, điện thoại vào phòng thi, quay cóp) sẽ bị xử lý kỷ luật nghiêm khắc từ Đình chỉ thi môn đó, Nhận điểm 0, Cảnh cáo trước toàn trường, cho đến đình chỉ học tập có thời hạn hoặc buộc thôi học nếu tái phạm nhiều lần. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(34, 1, 'FAQ #34 - Văn Phòng Khoa CNTT', 'Văn Phòng Khoa CNTT', NULL, NULL, 'Liên hệ khoa CNTT ở đâu? Số điện thoại khoa Công nghệ thông tin UTH?', 'Văn phòng Khoa Công nghệ thông tin UTH chịu trách nhiệm quản lý chuyên môn ngành CNTT và Khoa học dữ liệu. Văn phòng khoa hỗ trợ sinh viên các vấn đề về: Đăng ký đồ án tốt nghiệp, thực tập doanh nghiệp, cố vấn học tập. Địa chỉ liên hệ đặt tại Khu nhà C, Cơ sở chính. Bên cạnh đó, nếu bạn cũng quan tâm về đồng phục & trang phục, hay về đại hội đoàn, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(35, 1, 'FAQ #35 - Văn Phòng Khoa Viện', 'Văn Phòng Khoa Viện', NULL, NULL, 'Liên hệ Viện Logistics ở đâu? Văn phòng Khoa Kinh tế vận tải nằm ở đâu?', 'Các văn phòng Khoa chuyên ngành (như Viện Logistics và Quản lý chuỗi cung ứng, Khoa Kinh tế vận tải, Khoa Công trình giao thông, Khoa Điện - Điện tử viễn thông) đều có văn phòng trực ban tại các khu nhà chức năng cơ sở chính để hỗ trợ giải quyết lịch học chuyên ngành cho sinh viên. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian giữ xe tối đa tại trường và về bãi giữ xe của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(36, 1, 'FAQ #36 - Giáo Dục Quốc Phòng', 'Giáo Dục Quốc Phòng', NULL, NULL, 'Học quân sự ở đâu? Lịch học giáo dục quốc phòng? Đi học quân sự cần chuẩn bị gì?', 'Sinh viên UTH tham gia học môn Giáo dục quốc phòng - An ninh tập trung tại Trung tâm Giáo dục Quốc phòng theo lịch phân bổ của trường. Sinh viên được rèn luyện trong môi trường quân đội nội trú, phải tuân thủ nghiêm ngặt giờ giấc, tác phong quân kỷ và mặc quân phục. Ngoài ra, nếu bạn còn thắc mắc về giáo dục thể chất hoặc về thủ tục xin miễn học thể dục, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(37, 1, 'FAQ #37 - Giáo Dục Thể Chất', 'Giáo Dục Thể Chất', NULL, NULL, 'Học thể dục ở đâu? Các môn thể dục UTH? Đăng ký học môn thể thao nào?', 'Môn Giáo dục thể chất (Thể dục) tại UTH rất đa dạng, sinh viên được tự chọn đăng ký các môn thể thao yêu thích trên Portal như: Bóng đá, Bóng chuyền, Bóng rổ, Cầu lông, Cờ vua hoặc Võ thuật. Sinh viên phải thi đạt môn này mới đủ điều kiện xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về cấp lại giấy chứng nhận quốc phòng, hay về thủ tục xin miễn học thể dục, cứ hỏi mình thêm nha.', '/dang-ky-hoc-phan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(38, 1, 'FAQ #38 - Cấp Lại Bảng Điểm', 'Cấp Lại Bảng Điểm', NULL, NULL, 'Xin cấp bảng điểm học tập ở đâu? Lệ phí in bảng điểm chính thức?', 'Sinh viên cần bảng điểm chính thức (có mộc đỏ của trường) để xin việc làm hoặc nộp hồ sơ học bổng phải làm Đơn xin cấp bảng điểm tại máy tự động hoặc nộp trực tiếp tại Phòng Đào tạo. Lệ phí in bảng điểm được tính theo số lượng bản sao quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(39, 1, 'FAQ #39 - Phạt Tiền Thư Viện', 'Phạt Tiền Thư Viện', NULL, NULL, 'Làm mất sách thư viện đền tiền thế nào? Quên trả sách thư viện bị phạt bao nhiêu?', 'Sinh viên mượn tài liệu thư viện UTH nếu làm mất hoặc hư hỏng phải mua đền cuốn sách mới tương đương hoặc đền tiền gấp nhiều lần giá trị cuốn sách theo quy chế. Trả sách trễ hạn sẽ bị phạt số tiền tính theo từng ngày trễ hạn và bị tạm khóa thẻ thư viện. Ngoài ra, nếu bạn còn thắc mắc về mượn sách thư viện hoặc về mất thẻ sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(40, 1, 'FAQ #40 - Nguyện Vọng Bổ Sung', 'Nguyện Vọng Bổ Sung', NULL, NULL, 'Trường có xét tuyển bổ sung không? Điều kiện xét tuyển đợt 2 UTH?', 'Trong trường hợp các ngành học chưa tuyển đủ chỉ tiêu đợt 1, Hội đồng tuyển sinh UTH sẽ thông báo nhận hồ sơ Xét tuyển nguyện vọng bổ sung (Đợt 2) trên trang tuyển sinh chính thức của trường. Thí sinh nộp hồ sơ theo phương thức xét điểm thi tốt nghiệp THPT hoặc học bạ. Bên cạnh đó, nếu bạn cũng quan tâm về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(41, 1, 'FAQ #41 - Bảng Điểm Tiếng Anh', 'Bảng Điểm Tiếng Anh', NULL, NULL, 'Xin bảng điểm bằng tiếng Anh ở đâu? Lệ phí dịch thuật bảng điểm UTH? Cấp bảng điểm song ngữ?', 'Sinh viên có nhu cầu cấp bảng điểm bằng tiếng Anh (hoặc song ngữ) để làm hồ sơ du học, săn học bổng quốc tế hoặc nộp cho doanh nghiệp nước ngoài thì làm đơn đăng ký tại Phòng Đào tạo. Thời gian xử lý và cấp phát từ 3 đến 5 ngày làm việc kèm theo lệ phí in ấn quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời hạn sử dụng của thẻ thư viện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(42, 1, 'FAQ #42 - Phúc Khảo Đồ Án', 'Phúc Khảo Đồ Án', NULL, NULL, 'Đồ án tốt nghiệp có được phúc khảo không? Chấm lại điểm khóa luận tốt nghiệp?', 'Theo quy chế học vụ UTH, điểm bảo vệ Đồ án tốt nghiệp hoặc Khóa luận tốt nghiệp sẽ KHÔNG được chấm phúc khảo. Điểm số cuối cùng do Hội đồng chấm tốt nghiệp quyết định ngay tại buổi bảo vệ công khai. Sinh viên chỉ được quyền khiếu nại nếu có sai sót trong quá trình cộng điểm hoặc nhập điểm vào hệ thống. Ngoài ra, nếu bạn còn thắc mắc về quy chế thi cử hoặc về xét giảm điểm rèn luyện, mình có thể hỗ trợ giải đáp thêm nhé.', '/ket-qua-hoc-tap', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(43, 1, 'FAQ #43 - Khóa Tài Khoản Portal', 'Khóa Tài Khoản Portal', NULL, NULL, 'Tại sao tài khoản Portal bị khóa? Lỗi không đăng nhập được trang sinh viên?', 'Tài khoản Portal của sinh viên UTH thường bị khóa vì các lý do sau: Nợ học phí quá hạn quy định; Chưa hoàn thành các khảo sát bắt buộc của trường; Hoặc nhập sai mật khẩu quá 5 lần liên tiếp. Sinh viên cần liên hệ Phòng Đào tạo hoặc Phòng Công tác sinh viên để kiểm tra lý do và mở khóa. Bên cạnh đó, nếu bạn cũng quan tâm về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, hay về hủy tư cách đoàn viên, cứ hỏi mình thêm nha.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(44, 1, 'FAQ #44 - Bãi Giữ Xe Của Trường', 'Bãi Giữ Xe Của Trường', NULL, NULL, 'Bãi xe trường ở đâu? Giá vé gửi xe máy UTH? Gửi xe qua đêm tại trường được không?', 'UTH có bãi giữ xe dành cho sinh viên tại tất cả các cơ sở. Giá vé gửi xe máy áp dụng theo đúng quy định nhà nước. Sinh viên tuyệt đối không được gửi xe qua đêm tại trường trừ các trường hợp đặc biệt được Đoàn trường hoặc Ban quản lý cơ sở cấp phép trước bằng văn bản. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về quy định sử dụng mạng wifi nội bộ của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(45, 1, 'FAQ #45 - Miễn Giảm Anh Em Ruột', 'Miễn Giảm Anh Em Ruột', NULL, NULL, 'Anh em ruột cùng học UTH có được giảm học phí? Chính sách giảm học phí gia đình?', 'Nhà trường áp dụng chính sách hỗ trợ học phí cho gia đình có từ 2 anh/chị/em ruột trở lên đang cùng theo học hệ chính quy tại UTH. Mức giảm thường là 10% đến 20% học phí cho người em. Sinh viên cần nộp Giấy khai sinh bản sao và Đơn đề nghị về Phòng Công tác sinh viên đầu học kỳ. Ngoài ra, nếu bạn còn thắc mắc về gia hạn học phí hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(46, 1, 'FAQ #46 - Đổi Lịch Thi Học Kỳ', 'Đổi Lịch Thi Học Kỳ', NULL, NULL, 'Làm sao để xin đổi ca thi? Bị trùng lịch thi phải làm thế nào? Trùng giờ thi xử lý sao?', 'Trường hợp sinh viên bị trùng lịch thi 2 môn trong cùng 1 ca hoặc có lý do bất khả kháng (tai nạn, nằm viện), sinh viên phải mang minh chứng đến Phòng Đào tạo trước ngày thi ít nhất 3 ngày để làm đơn xin chuyển ca thi hoặc đăng ký thi ghép vào đợt thi của lớp khác. Bên cạnh đó, nếu bạn cũng quan tâm về bảo lưu kết quả, hay về quy định số lần cảnh báo học vụ, cứ hỏi mình thêm nha.', '/lich-hoc-trong-tuan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(47, 1, 'FAQ #47 - Quên Mật Khẩu Portal', 'Quên Mật Khẩu Portal', NULL, NULL, 'Làm sao lấy lại mật khẩu Portal? Quên pass trang sinh viên UTH?', 'Nếu quên mật khẩu đăng nhập hệ thống Portal, sinh viên bấm vào nút \"Quên mật khẩu\" trên giao diện đăng nhập để nhận mã khôi phục qua Email sinh viên (@ut.edu.vn). Nếu không làm được, sinh viên mang Thẻ sinh viên đến trực tiếp Phòng Đào tạo để được cấp lại mật khẩu mới. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về đăng ký cấp lại tài khoản email sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(48, 1, 'FAQ #48 - Phòng Y Tế Trường', 'Phòng Y Tế Trường', NULL, NULL, 'Trạm y tế trường nằm ở đâu? Khám sức khỏe sinh viên đầu năm ở đâu?', 'Phòng Y tế UTH nằm tại khu vực tầng trệt cơ sở chính. Đây là nơi tiếp nhận, sơ cứu và cấp phát thuốc cơ bản miễn phí cho sinh viên khi gặp các vấn đề về sức khỏe trong quá trình học tập tại trường. Đồng thời là nơi tổ chức khám sức khỏe định kỳ bắt buộc cho tân sinh viên. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(49, 1, 'FAQ #49 - Học Bổng Liên Kết', 'Học Bổng Liên Kết', NULL, NULL, 'Học bổng du học UTH? Chương trình trao đổi sinh viên quốc tế?', 'UTH liên kết với nhiều trường Đại học lớn tại Hàn Quốc, Nhật Bản, Hà Lan, Anh Quốc để triển khai các chương trình trao đổi sinh viên và học bổng du học hệ 2+2 hoặc 3+1. Sinh viên có học lực Giỏi và đạt chuẩn tiếng Anh (IELTS/TOEFL) cao sẽ được xét duyệt hồ sơ tham gia. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng khuyến khích, hay về hoạt động đoàn hội, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(50, 1, 'FAQ #50 - Sinh Hoạt Công Dân', 'Sinh Hoạt Công Dân', NULL, NULL, 'Tuần sinh hoạt công dân học khi nào? Không học sinh hoạt công dân có bị sao không?', 'Tuần sinh hoạt công dân - học sinh sinh viên được tổ chức bắt buộc vào đầu mỗi năm học. Sinh viên phải tham gia đầy đủ và làm bài kiểm tra thu hoạch đạt yêu cầu. Vắng mặt không lý do sẽ bị trừ điểm rèn luyện nghiêm khắc và xét kỷ luật tùy mức độ. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về học bổng khuyến khích — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(51, 1, 'FAQ #51 - Chuyển Cơ Sở Học Tập', 'Chuyển Cơ Sở Học Tập', NULL, NULL, 'Sinh viên có được đổi cơ sở học không? Đang học Quận 12 chuyển qua Bình Thạnh?', 'Việc phân bổ cơ sở học tập (Bình Thạnh hoặc Quận 12) phụ thuộc hoàn toàn vào chuyên ngành và kế hoạch đào tạo của từng Khoa/Viện. Sinh viên KHÔNG được tự ý xin chuyển cơ sở học tập cá nhân trừ khi có sự điều chỉnh quy hoạch lớp học từ phía Ban giám hiệu nhà trường. Ngoài ra, nếu bạn còn thắc mắc về chương trình đào tạo hoặc về xin hoãn đi thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(52, 1, 'FAQ #52 - Mượn Phòng Học', 'Mượn Phòng Học', NULL, NULL, 'Làm sao để mượn phòng học làm hoạt động? Thủ tục mượn hội trường UTH?', 'Các Ban cán sự lớp hoặc Câu lạc bộ muốn mượn phòng học, giảng đường hoặc Hội trường để tổ chức sinh hoạt, họp hành, tập văn nghệ phải làm Đơn xin mượn phòng (có xác nhận của Bí thư Đoàn trường hoặc Trưởng Khoa) nộp về Phòng Quản trị thiết bị trước ít nhất 2 ngày. Bên cạnh đó, nếu bạn cũng quan tâm về thời hạn sử dụng của thẻ thư viện, hay về khóa tài khoản Portal, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(53, 1, 'FAQ #53 - Hỗ Trợ Khởi Nghiệp', 'Hỗ Trợ Khởi Nghiệp', NULL, NULL, 'Cuộc thi khởi nghiệp sinh viên UTH? Quỹ hỗ trợ ý tưởng sáng tạo?', 'Nhà trường thường xuyên tổ chức các cuộc thi Ý tưởng khởi nghiệp sáng tạo sinh viên UTH. Các dự án tiềm năng và đạt giải cao sẽ được Câu lạc bộ Khởi nghiệp của trường hỗ trợ không gian làm việc, kết nối với các quỹ đầu tư và cố vấn chuyên môn để phát triển thành dự án thực tế. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh viên 5 tốt và về khen thưởng sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(54, 1, 'FAQ #54 - Giấy Chứng Nhận Tạm Thời', 'Giấy Chứng Nhận Tạm Thời', NULL, NULL, 'Xin giấy chứng nhận sinh viên tạm thời ở đâu? Thời gian cấp giấy xác nhận là bao lâu?', 'Để phục vụ các nhu cầu cấp bách (như làm hồ sơ xin việc, chứng minh thông tin khi chưa có thẻ nhựa), sinh viên đăng ký xin cấp Giấy chứng nhận sinh viên tạm thời tại văn phòng Phòng Công tác sinh viên. Giấy xác nhận này có mộc đỏ và giá trị pháp lý ngắn hạn. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về quên mật khẩu Portal, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(55, 1, 'FAQ #55 - Văn Phòng Đoàn Thanh Niên', 'Văn Phòng Đoàn Thanh Niên', NULL, NULL, 'Văn phòng Đoàn trường UTH ở đâu? Đăng ký sổ Đoàn, nộp sổ Đoàn ở đâu?', 'Văn phòng Đoàn Thanh niên - Hội Sinh viên UTH đặt tại cơ sở chính Võ Oanh. Đây là nơi quản lý toàn bộ hồ sơ đoàn viên, tiếp nhận sổ Đoàn của sinh viên đầu năm học, xét duyệt các danh hiệu thi đua, cộng điểm rèn luyện và tổ chức các chiến dịch lớn như Mùa hè xanh, Tiếp sức mùa thi. Bên cạnh đó, nếu bạn cũng quan tâm về sinh hoạt công dân, hay về mượn thiết bị âm thanh, sự kiện, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(56, 1, 'FAQ #56 - Khảo Sát Ý Kiến Sinh Viên', 'Khảo Sát Ý Kiến Sinh Viên', NULL, NULL, 'Khảo sát môn học làm ở đâu? Không làm khảo sát giảng viên có bị sao không?', 'Cuối mỗi học kỳ, UTH bắt buộc sinh viên phải tham gia Khảo sát ý kiến về hoạt động giảng dạy của giảng viên trực tuyến trên trang Portal. Sinh viên cố tình không hoàn thành khảo sát đúng hạn sẽ bị tạm khóa chức năng xem điểm thi học kỳ và khóa lịch đăng ký môn học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về hoạt động đoàn hội và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(57, 1, 'FAQ #57 - Đóng Lệ Phí Thi Lại', 'Đóng Lệ Phí Thi Lại', NULL, NULL, 'Thi lại có tốn tiền không? Lệ phí thi lại đóng ở đâu?', 'Đối với các môn học bị điểm F, sinh viên áp dụng quy chế học chế tín chỉ của UTH là phải đăng ký học lại và đóng tiền học phí tính theo số tín chỉ môn đó giống như học mới, trường KHÔNG tổ chức kỳ thi lại độc lập thu phí riêng như hệ niên chế cũ. Ngoài ra, nếu bạn còn thắc mắc về lệ phí xét tuyển hồ sơ đầu vào hoặc về miễn giảm anh em ruột, mình có thể hỗ trợ giải đáp thêm nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(58, 1, 'FAQ #58 - Thực Tập Tốt Nghiệp', 'Thực Tập Tốt Nghiệp', NULL, NULL, 'Lịch đi thực tập của sinh viên năm cuối? Xin giấy giới thiệu thực tập ở đâu?', 'Sinh viên năm cuối đủ điều kiện sẽ tham gia học phần Thực tập tốt nghiệp. Sinh viên đến văn phòng Khoa/Viện chủ quản để nhận Giấy giới thiệu thực tập nộp cho doanh nghiệp. Sau khi kết thúc, phải nộp lại Báo cáo thực tập có nhận xét và mộc tròn của công ty. Bên cạnh đó, nếu bạn cũng quan tâm về quy định tham quan kiến tập thực tế tại doanh nghiệp, hay về thời gian nhận bằng tốt nghiệp, cứ hỏi mình thêm nha.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(59, 1, 'FAQ #59 - Đồ Án Tốt Nghiệp', 'Đồ Án Tốt Nghiệp', NULL, NULL, 'Điều kiện được làm đồ án ra trường? Điểm GPA bao nhiêu thì được làm khóa luận tốt nghiệp?', 'Điều kiện để sinh viên UTH được giao đề tài làm Đồ án/Khóa luận tốt nghiệp: Tính đến học kỳ xét, sinh viên không bị cảnh báo học vụ; Tích lũy tối thiểu 80% đến 90% số tín chỉ toàn khóa; Điểm trung bình GPA đạt mức quy định riêng của từng Khoa/Viện chuyên ngành. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đồ án tốt nghiệp đạt điểm f xử lý sao và về quy trình làm thủ tục nhập học trực tiếp tại trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(60, 1, 'FAQ #60 - Khen Thưởng Sinh Viên', 'Khen Thưởng Sinh Viên', NULL, NULL, 'Sinh viên xuất sắc được thưởng gì? Tiêu chuẩn xét khen thưởng danh hiệu học tập?', 'Kết thúc mỗi năm học, nhà trường tiến hành xét khen thưởng cho sinh viên đạt danh hiệu Sinh viên Xuất sắc (GPA >= 3.6/4.0) và Sinh viên Giỏi (GPA >= 3.2/4.0) kèm theo điểm rèn luyện loại Tốt trở lên. Sinh viên được tặng giấy khen của Hiệu trưởng và nhận tiền thưởng tương ứng. Ngoài ra, nếu bạn còn thắc mắc về đăng ký tham gia câu lạc bộ hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'verified', 'authoritative', 5, 1, 'vi', NULL, 1, '2026-07-23 13:35:11', '2026-07-11 16:34:11', '2026-07-23 13:35:11', NULL),
(61, 1, 'FAQ #61 - Mùa Hè Xanh UTH', 'Mùa Hè Xanh UTH', NULL, NULL, 'Đăng ký Mùa hè xanh ở đâu? Tiêu chí tuyển chiến sĩ MHX? Đi MHX được bao nhiêu ĐRL?', 'Chiến dịch tình nguyện Mùa Hè Xanh UTH do Đoàn trường tổ chức vào tháng 7 hằng năm. Sinh viên đăng ký qua form chính thức của Đoàn Khoa/Viện. Tiêu chí tuyển chọn dựa trên sức khỏe, đạo đức tốt và tích cực tham gia phong trào. Hoàn thành chiến dịch được cộng tối đa 15-20 điểm rèn luyện. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'verified', 'authoritative', 5, 1, 'vi', NULL, 1, '2026-07-23 13:35:21', '2026-07-11 16:34:11', '2026-07-23 13:35:21', NULL),
(62, 1, 'FAQ #62 - Tiếp Sức Mùa Thi', 'Tiếp Sức Mùa Thi', NULL, NULL, 'Đăng ký Tiếp sức mùa thi UTH? Lịch chạy chương trình TSMT?', 'Chương trình Tiếp sức mùa thi diễn ra vào tháng 6 hằng năm nhằm hỗ trợ thí sinh thi THPT Quốc tế. Sinh viên UTH đăng ký tham gia thông qua Hội Sinh viên trường. Chiến sĩ TSMT sẽ trực tại các điểm trường thi để phân luồng giao thông, hỗ trợ nước uống và chỉ đường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng đoàn thanh niên và về các câu lạc bộ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(63, 1, 'FAQ #63 - Xuân Tình Nguyện', 'Xuân Tình Nguyện', NULL, NULL, 'Lịch chạy Xuân tình nguyện UTH? Đăng ký đi XTN ở đâu? Chi phí đóng góp XTN?', 'Chiến dịch Xuân Tình Nguyện UTH diễn ra vào dịp cận Tết Nguyên Đán. Các đội hình sẽ thực hiện hoạt động gói bánh chưng, tặng quà cho trẻ em cơ nhỡ, người già neo đơn và dọn dẹp nghĩa trang liệt sĩ. Sinh viên đăng ký qua Fanpage Đoàn - Hội của Khoa/Viện. Ngoài ra, nếu bạn còn thắc mắc về sinh viên 5 tốt hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(64, 1, 'FAQ #64 - Giải Chạy Sinh Viên', 'Giải Chạy Sinh Viên', NULL, NULL, 'Giải chạy bộ UTH? Đăng ký chạy marathon trường ở đâu? Minh chứng hoàn thành giải chạy?', 'UTH thường xuyên tổ chức hoặc liên kết các giải chạy bộ (Marathon trực tuyến/trực tiếp qua app Strava). Sinh viên hoàn thành cự ly quy định (thường là 21km hoặc 42km tích lũy) sẽ đạt tiêu chí \"Thể lực tốt\" phục vụ xét danh hiệu Sinh viên 5 Tốt và được cộng ĐRL. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về đăng ký tham gia hiến máu đợt hè, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(65, 1, 'FAQ #65 - Ngày Hội Sáng Tạo', 'Ngày Hội Sáng Tạo', NULL, NULL, 'Cuộc thi ý tưởng sáng tạo UTH? Sáng tạo trẻ sinh viên giao thông?', 'Ngày hội Sáng tạo trẻ UTH là sân chơi khoa học công nghệ, trưng bày các mô hình, phần mềm độc đáo do sinh viên tự nghiên cứu (robot, mô hình cầu đường, app quản lý vận tải). Đề tài đạt giải cao sẽ được hỗ trợ kinh phí tham gia các cuộc thi cấp Thành phố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chiến sĩ tình nguyện và về hủy tư cách đoàn viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(66, 1, 'FAQ #66 - Chiến Sĩ Tình Nguyện', 'Chiến Sĩ Tình Nguyện', NULL, NULL, 'Danh hiệu Chiến sĩ tình nguyện xuất sắc? Làm sao để được tặng bằng khen MHX?', 'Kết thúc mỗi chiến dịch tình nguyện (MHX, XTN, TSMT), Ban chỉ huy chiến dịch sẽ tổ chức họp xét để tuyên dương các cá nhân có đóng góp xuất sắc. Chiến sĩ đạt danh hiệu sẽ được tặng Giấy khen của Hiệu trưởng hoặc Ủy ban Hội Sinh viên Thành phố. Ngoài ra, nếu bạn còn thắc mắc về tiếp sức mùa thi hoặc về đăng ký tham gia câu lạc bộ, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(67, 1, 'FAQ #67 - Đại Hội Đoàn - Hội', 'Đại Hội Đoàn - Hội', NULL, NULL, 'Lịch tổ chức Đại hội Đại biểu? Đi bầu cử Đoàn Thanh niên ở đâu?', 'Đại hội Đại biểu Đoàn TNCS Hồ Chí Minh và Đại hội Hội Sinh viên Việt Nam trường UTH được tổ chức định kỳ để bầu ra Ban chấp hành mới. Sinh viên là Đại biểu chính thức sẽ tham gia họp và bỏ phiếu tại Hội trường lớn cơ sở chính Võ Oanh. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng liên kết, hay về văn phòng khoa CNTT, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL);
INSERT INTO `knowledge_articles` (`id`, `source_id`, `title`, `category`, `subcategory`, `intent_code`, `keywords`, `answer_content`, `route_url`, `audience`, `faculty_id`, `program_id`, `cohort_from`, `cohort_to`, `semester_code`, `academic_year_code`, `valid_from`, `valid_until`, `verification_status`, `confidence_level`, `priority`, `version`, `language_code`, `created_by`, `reviewed_by`, `reviewed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(68, 1, 'FAQ #68 - Cắm Trại Truyền Thống', 'Cắm Trại Truyền Thống', NULL, NULL, 'Hội trại truyền thống UTH học kỳ nào? Địa điểm cắm trại trường? Chi phí hội trại?', 'Hội trại truyền thống UTH thường được tổ chức nhân dịp kỷ niệm ngày thành lập Đoàn 26/03 hoặc ngày truyền thống trường. Địa điểm tổ chức có thể tại sân trường cơ sở Quận 12 hoặc các khu du lịch dã ngoại. Hội trại gồm các hoạt động dựng trại, trò chơi lớn và đêm lửa trại. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về các câu lạc bộ và về chiến sĩ đỏ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(69, 1, 'FAQ #69 - Giải Bóng Đá UTH', 'Giải Bóng Đá UTH', NULL, NULL, 'Giải bóng đá nam/nữ trường UTH? Đăng ký đá banh giải trường ở đâu?', 'Giải bóng đá truyền thống sinh viên UTH tổ chức hằng năm tại sân bóng cỏ nhân tạo. Các đội bóng tham gia tranh tài theo đơn vị lớp hoặc Liên quân Khoa/Viện. Lịch thi đấu và thể lệ được Ban thể thao thuộc Hội sinh viên trường công bố công khai đầu học kỳ 2. Ngoài ra, nếu bạn còn thắc mắc về hoạt động \"hiến máu tình nguyện\" lần 2 trong năm hoặc về tham gia hiến máu có được nghỉ học, mình có thể hỗ trợ giải đáp thêm nhé.', '/dang-ky-hoc-phan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(70, 1, 'FAQ #70 - Văn Nghệ Tiếng Hát', 'Văn Nghệ Tiếng Hát', NULL, NULL, 'Cuộc thi tiếng hát sinh viên UTH? Cuộc thi văn nghệ UTH Got Talent?', 'Cuộc thi văn nghệ truyền thống (Tiếng hát sinh viên UTH) là nơi tìm kiếm các tài năng âm nhạc, nhạc cụ, nhảy hiện đại, múa dân gian. Sinh viên đăng ký tiết mục đơn ca, song ca hoặc tốp ca trực tiếp với Đội văn nghệ xung kích của trường để tham gia vòng sơ loại. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách học bổng tuyển sinh, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(71, 1, 'FAQ #71 - Chiến Sĩ Đỏ - Hiến Máu', 'Chiến Sĩ Đỏ - Hiến Máu', NULL, NULL, 'Đội tình nguyện hiến máu UTH? Câu lạc bộ Hành Trình Đỏ UTH?', 'Câu lạc bộ Hành Trình Đỏ / Đội Tình nguyện Hiến máu UTH là đơn vị nòng cốt phối hợp với Trung tâm hiến máu nhân đạo TP.HCM để tổ chức các đợt hiến máu tại trường. Thành viên đội sẽ hỗ trợ điều phối, hướng dẫn sinh viên điền form và chăm sóc sinh viên sau hiến máu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(72, 1, 'FAQ #72 - Minh Chứng ĐRL', 'Minh Chứng ĐRL', NULL, NULL, 'Nộp minh chứng hoạt động ở đâu? Quên nộp minh chứng có được cộng điểm rèn luyện?', 'Khi tham gia các hoạt động bên ngoài trường (Hiến máu, Tình nguyện hè, Giải chạy), sinh viên phải giữ lại Giấy chứng nhận bản cứng hoặc chụp màn hình kết quả. Sau đó, đăng nhập hệ thống Portal nộp minh chứng đúng thời hạn quy định để Lớp trưởng xét cộng ĐRL. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về cấp lại bảng điểm, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(73, 1, 'FAQ #73 - Điểm Rèn Luyện F', 'Điểm Rèn Luyện F', NULL, NULL, 'Điểm rèn luyện dưới 50 bị phạt thế nào? ĐRL loại Yếu có được tốt nghiệp không?', 'Sinh viên có điểm rèn luyện xếp loại Yếu (dưới 50 điểm) hoặc Kém (dưới 35 điểm) trong một năm học sẽ bị đưa vào danh sách kỷ luật cảnh cáo. Nếu bị xếp loại yếu, kém 2 học kỳ liên tiếp sẽ bị đình chỉ học tập 1 học kỳ; nếu bị lần thứ 3 sẽ bị buộc thôi học. Bên cạnh đó, nếu bạn cũng quan tâm về quy chế thi cử, hay về đăng ký môn học, cứ hỏi mình thêm nha.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(74, 1, 'FAQ #74 - Ngày Hội Việc Làm', 'Ngày Hội Việc Làm', NULL, NULL, 'UTH Job Fair tổ chức khi nào? Sinh viên năm nhất có được tham gia ngày hội việc làm?', 'Ngày hội việc làm UTH Job Fair diễn ra định kỳ hằng năm tại sân trường cơ sở chính. Hoạt động này thu hút hàng chục doanh nghiệp lớn đến phỏng vấn tuyển dụng trực tiếp, nhận hồ sơ thực tập. Tất cả sinh viên các năm đều được tham gia tự do để tìm kiếm cơ hội. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách học bổng tuyển sinh và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(75, 1, 'FAQ #75 - Hội Thảo Kỹ Năng', 'Hội Thảo Kỹ Năng', NULL, NULL, 'Lớp học kỹ năng mềm UTH? Đăng ký chuyên đề kỹ năng ở đâu? Có tính ĐRL không?', 'Phòng Công tác sinh viên phối hợp với các chuyên gia tổ chức các buổi Hội thảo kỹ năng mềm (Kỹ năng viết CV, kỹ năng giao tiếp, quản lý thời gian). Sinh viên quét mã QR điểm danh tại hội trường sẽ được tự động cộng 2-3 điểm rèn luyện vào hệ thống Portal. Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về văn phòng đoàn thanh niên, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(76, 1, 'FAQ #76 - Học phí chương trình tiên tiến (trước đây gọi là Chất lượng cao - CLC)', 'Học phí chương trình tiên tiến (trước đây gọi là Chất lượng cao - CLC)', NULL, NULL, 'Học phí hệ chất lượng cao là bao nhiêu? Tại sao học phí CLC lại cao hơn đại trà? Tổng tiền học phí CLC một năm?', 'UTH hiện gọi chương trình Chất lượng cao trước đây là \"Chương trình tiên tiến\". Mức học phí chương trình tiên tiến áp dụng cho tân sinh viên khóa 2026 là 1.120.000đ/tín chỉ (khóa 2025 áp dụng mức 980.000đ/tín chỉ). Với chương trình đào tạo chuẩn hóa 120 tín chỉ toàn khóa, tổng học phí chương trình tiên tiến trọn khóa (học đúng tiến độ, chưa gồm các khoản phí khác) theo mức khóa 2026 vào khoảng 134 triệu đồng. Mức phí chương trình tiên tiến cao hơn chương trình chuẩn do quy mô lớp nhỏ, tăng cường thời lượng tiếng Anh chuyên ngành, cơ sở vật chất hiện đại và có các học phần trải nghiệm/kiến tập tại doanh nghiệp. Mỗi khóa nhập học có mức học phí niêm yết riêng và trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về chính sách hỗ trợ bảo hiểm tai nạn, cứ hỏi mình thêm nha.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(77, 1, 'FAQ #77 - Quy trình chấm Điểm rèn luyện (ĐRL) hằng kỳ', 'Quy trình chấm Điểm rèn luyện (ĐRL) hằng kỳ', NULL, NULL, 'Cách chấm điểm rèn luyện như thế nào? Quy trình họp xét ĐRL của lớp? Khi nào bắt đầu tự đánh giá ĐRL?', 'Quy trình chấm Điểm rèn luyện hằng kỳ tại UTH được thực hiện qua 3 bước bắt buộc: - Sinh viên đăng nhập hệ thống Portal tự đánh giá điểm cá nhân theo các mục quy định. - Tập thể lớp tổ chức họp dưới sự chủ trì của Ban cán sự lớp để thông qua và chấm điểm cho từng sinh viên. - Cố vấn học tập (Giảng viên chủ nhiệm) phê duyệt và gửi danh sách chính thức về Phòng Công tác sinh viên để lưu hệ thống. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về cảnh báo học vụ và về thủ tục phúc khảo điểm quá trình — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(78, 1, 'FAQ #78 - Thẻ bảo hiểm y tế điện tử (VssID)', 'Thẻ bảo hiểm y tế điện tử (VssID)', NULL, NULL, 'Xem thẻ bảo hiểm y tế ở đâu? Cách đăng ký tài khoản VssID sinh viên? Mất thẻ bảo hiểm y tế giấy phải làm sao?', 'Nhà trường không cấp thẻ Bảo hiểm y tế (BHYT) bằng giấy vật lý cho sinh viên nữa. Sau khi đóng lệ phí gia hạn BHYT thành công trên cổng thanh toán của trường, sinh viên tải ứng dụng VssID (Bảo hiểm xã hội số) trên điện thoại và đăng ký tài khoản bằng mã số bảo hiểm của mình để sử dụng thẻ BHYT điện tử khi đi khám chữa bệnh tại các bệnh viện. Ngoài ra, nếu bạn còn thắc mắc về chính sách hỗ trợ bảo hiểm tai nạn hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(79, 1, 'FAQ #79 - Chuẩn tin học quốc tế nâng cao', 'Chuẩn tin học quốc tế nâng cao', NULL, NULL, 'Chứng chỉ tin học IC3 hay MOS tốt hơn? Quy đổi điểm tin học đầu ra như thế nào?', 'UTH công nhận cả hai chứng chỉ quốc tế là MOS và IC3 để xét đạt chuẩn đầu ra Tin học. Đối với chứng chỉ MOS, sinh viên phải đạt từ 3 kỹ năng độc lập trở lên (gồm Word, Excel và Powerpoint). Đối với chứng chỉ IC3, sinh viên phải thi đạt cả 3 phần (Living Online, Key Applications, và Computing Fundamentals). Sinh viên mang chứng chỉ gốc đến Phòng Đào tạo để làm thủ tục hậu kiểm công nhận quy đổi. Bên cạnh đó, nếu bạn cũng quan tâm về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH, hay về đăng ký thi lại chuẩn đầu ra, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(80, 1, 'FAQ #80 - Quy định sử dụng mạng Wifi nội bộ của trường', 'Quy định sử dụng mạng Wifi nội bộ của trường', NULL, NULL, 'Cách kết nối wifi trường UTH? Mật khẩu wifi sinh viên là gì? Tại sao không vào được wifi trường?', 'Nhà trường cấp hệ thống mạng Wifi miễn phí tại tất cả các khu vực giảng đường, thư viện và sân trường cho sinh viên. Để kết nối, sinh viên chọn mạng Wifi dành riêng cho người học, sau đó đăng nhập bằng Mã số sinh viên (Username) và Mật khẩu Portal cá nhân của mình. Hệ thống sẽ tự động chặn các truy cập vào trang web độc hại hoặc tải tài liệu lậu dung lượng quá lớn làm nghẽn băng thông. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng khoa viện và về liên hệ ban quản lý ký túc xá — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(81, 1, 'FAQ #81 - Đăng ký tham gia Câu lạc bộ (CLB) đầu năm học', 'Đăng ký tham gia Câu lạc bộ (CLB) đầu năm học', NULL, NULL, 'Làm sao để vào câu lạc bộ của trường? Ngày hội các câu lạc bộ tổ chức khi nào? Tuyển thành viên CLB UTH?', 'Vào khoảng tháng 9 và tháng 10 hằng năm (đầu học kỳ 1), Hội Sinh viên trường UTH tổ chức Ngày hội các Câu lạc bộ (CLB Festival) tại sân trường cơ sở chính. Tại đây, tất cả các CLB (Học thuật, Nghệ thuật, Thể thao, Tình nguyện) sẽ đặt gian hàng giới thiệu và phát đơn tuyển thành viên mới trực tiếp hoặc trực tuyến qua các trang Fanpage chính thức của mình. Ngoài ra, nếu bạn còn thắc mắc về văn phòng đoàn thanh niên hoặc về sinh viên 5 tốt, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(82, 1, 'FAQ #82 - Đăng ký cấp lại tài khoản Email sinh viên (@ut.edu.vn)', 'Đăng ký cấp lại tài khoản Email sinh viên (@ut.edu.vn)', NULL, NULL, 'Làm sao để đổi mật khẩu email sinh viên? Bị mất email của trường xử lý thế nào?', 'Email sinh viên định dạng [MSSV]@ut.edu.vn được nhà trường cấp miễn phí cho toàn bộ người học để liên lạc và nhận các thông báo quan trọng. Nếu bị khóa tài khoản hoặc quên mật khẩu email, sinh viên mang Thẻ sinh viên đến trực tiếp văn phòng Trung tâm Dữ liệu và Công nghệ thông tin của trường tại khu nhà chức năng cơ sở chính để được hỗ trợ reset cấp lại mật khẩu ngay trong ngày. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về quên mật khẩu Portal, cứ hỏi mình thêm nha.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(83, 1, 'FAQ #83 - Hoạt động \"Hiến máu tình nguyện\" lần 2 trong năm', 'Hoạt động \"Hiến máu tình nguyện\" lần 2 trong năm', NULL, NULL, 'Một năm trường tổ chức hiến máu mấy lần? Lịch hiến máu đợt 2 của trường?', 'Nhằm đáp ứng nhu cầu cung cấp máu cứu người, Đoàn trường và Hội sinh viên UTH phối hợp tổ chức hoạt động hiến máu nhân đạo định kỳ 2 lần trong một năm học (thường rơi vào Học kỳ 1 và Học kỳ 2). Lịch chi tiết của từng đợt sẽ được đăng tải sớm trên trang Portal trước 1 tuần để sinh viên đăng ký tham gia và nhận quyền lợi cộng điểm rèn luyện. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(84, 1, 'FAQ #84 - Chế độ miễn giảm học phí cho con em diện chính sách', 'Chế độ miễn giảm học phí cho con em diện chính sách', NULL, NULL, 'Con thương binh có được giảm học phí không? Thủ tục xin miễn học phí diện hộ nghèo? Nộp hồ sơ giảm học phí ở đâu?', 'Sinh viên thuộc diện con thương binh, bệnh binh, người có công với cách mạng, sinh viên dân tộc thiểu số vùng đặc biệt khó khăn, hoặc sinh viên thuộc hộ nghèo/hộ cận nghèo sẽ được hưởng chính sách miễn hoặc giảm học phí theo đúng quy định của Nhà nước. Sinh viên cần chuẩn bị Sổ hộ nghèo, Giấy chứng nhận diện chính sách bản công chứng nộp về Phòng Công tác sinh viên để xét duyệt đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(85, 1, 'FAQ #85 - Quy định mượn học cụ, thiết bị tại phòng thí nghiệm', 'Quy định mượn học cụ, thiết bị tại phòng thí nghiệm', NULL, NULL, 'Làm sao để mượn đồ phòng thí nghiệm làm đồ án? Quy định mượn thiết bị đo đạc?', 'Sinh viên các ngành kỹ thuật (như Công trình, Điện - Điện tử, CNTT) cần mượn thiết bị, học cụ tại các phòng thí nghiệm, xưởng thực hành để làm đồ án hoặc bài tập lớn phải có Giấy đề xuất mượn thiết bị do Giảng viên hướng dẫn ký duyệt. Sinh viên nộp giấy này cho Cán bộ quản lý phòng thí nghiệm, xuất trình Thẻ sinh viên để ký sổ mượn và có trách nhiệm bảo quản, hoàn trả nguyên vẹn đúng thời hạn. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về liên hệ ban quản lý ký túc xá, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(86, 1, 'FAQ #86 - Tiếp nhận hồ sơ Đăng ký xét tuyển Học bạ đợt tiếp theo', 'Tiếp nhận hồ sơ Đăng ký xét tuyển Học bạ đợt tiếp theo', NULL, NULL, 'Khi nào trường nhận hồ sơ học bạ đợt 2? Cách nộp học bạ online vào trường UTH?', 'Hội đồng tuyển sinh UTH tổ chức xét tuyển học bạ THPT thành nhiều đợt trong năm. Thí sinh đăng ký nộp hồ sơ trực tuyến thông qua trang Tuyển sinh chính thức của trường, điền đầy đủ điểm số các môn thuộc tổ hợp xét tuyển và tải ảnh chụp học bạ lên hệ thống. Sau khi có kết quả trúng tuyển tạm thời, thí sinh phải nộp hồ sơ bản giấy về trường để đối chiếu xác thực thông tin. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về nguyện vọng bổ sung — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(87, 1, 'FAQ #87 - Thủ tục xin tạm hoãn thi học kỳ', 'Thủ tục xin tạm hoãn thi học kỳ', NULL, NULL, 'Bị ốm đột xuất không đi thi được làm sao? Cách xin hoãn thi học kỳ? Đơn xin hoãn thi nộp ở đâu?', 'Nếu gặp lý do bất khả kháng như tai nạn hoặc bệnh tật phải nằm viện điều trị ngay vào ngày thi kết thúc học phần, sinh viên phải làm Đơn xin hoãn thi kèm theo Giấy ra viện hoặc Giấy xác nhận có mộc tròn của bệnh viện nộp về Phòng Đào tạo trong vòng tối đa 3 ngày làm việc kể từ ngày thi của môn đó. Môn học xin hoãn thi thành công sẽ được chuyển điểm sang đợt thi bổ sung hoặc thi ghép cùng khóa sau mà không bị tính điểm 0. Ngoài ra, nếu bạn còn thắc mắc về cách tính điểm hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', '/lich-hoc-trong-tuan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(88, 1, 'FAQ #88 - Quy chế quản lý thông tin và tài sản số của sinh viên', 'Quy chế quản lý thông tin và tài sản số của sinh viên', NULL, NULL, 'Có được chia sẻ tài khoản Portal cho người khác không? Quy định bảo mật thông tin sinh viên UTH?', 'Theo quy định an ninh thông tin của UTH, tài khoản Portal và mật khẩu cá nhân là tài sản số độc quyền của cá nhân sinh viên đó. Sinh viên tuyệt đối không được chia sẻ tài khoản này cho bất kỳ ai khác. Mọi hành vi tự ý chia sẻ tài khoản dẫn đến việc sai lệch dữ liệu đăng ký môn học, kết quả học tập hoặc phát tán thông tin sai sự thật trên hệ thống sẽ bị xử lý kỷ luật nghiêm khắc từ mức cảnh cáo đến đình chỉ học tập. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về khảo sát ý kiến sinh viên, cứ hỏi mình thêm nha.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(89, 1, 'FAQ #89 - Quy định tham quan kiến tập thực tế tại doanh nghiệp', 'Quy định tham quan kiến tập thực tế tại doanh nghiệp', NULL, NULL, 'Sinh viên năm mấy được đi kiến tập? Đi kiến tập doanh nghiệp có bắt buộc không?', 'Hoạt động tham quan kiến tập thực tế tại doanh nghiệp, nhà máy, cảng biển là một học phần bắt buộc hoặc hoạt động bổ trợ bổ ích được các Khoa/Viện tổ chức cho sinh viên (thường dành cho sinh viên năm 2 hoặc năm 3). Hoạt động này giúp sinh viên tiếp cận môi trường làm việc thực tế. Sinh viên tham gia phải tuân thủ nghiêm ngặt giờ giấc điều phối của giảng viên trưởng đoàn và mặc đồng phục trường lịch sự. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thủ tục chuyển ngành và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(90, 1, 'FAQ #90 - Tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường', 'Tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường', NULL, NULL, 'Trường có phòng tư vấn tâm lý không? Bị stress áp lực học tập thì liên hệ ai hỗ trợ?', 'Nhằm hỗ trợ giải tỏa các áp lực về học tập, cuộc sống hoặc các vấn đề tâm lý cá nhân, UTH có Trung tâm Tư vấn tâm lý sinh viên trực thuộc Phòng Công tác sinh viên. Tại đây, các chuyên gia tâm lý sẽ lắng nghe, chia sẻ và tư vấn định hướng hoàn toàn miễn phí và bảo mật tuyệt đối thông tin cho sinh viên. Sinh viên có thể đặt lịch hẹn tư vấn trực tuyến qua trang hỗ trợ hoặc đến gặp trực tiếp tại văn phòng nhà A. Ngoài ra, nếu bạn còn thắc mắc về cấp lại bảng điểm hoặc về đăng ký cấp lại tài khoản email sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(91, 1, 'FAQ #106 - Rút hồ sơ thôi học', 'Rút hồ sơ thôi học', NULL, NULL, 'rut ho so, thoi hoc, xoa ten, khong hoc nua, xin thoi hoc, nghi hoc luon', 'Sinh viên muốn xin thôi học và rút hồ sơ gốc (Học bạ, Bằng tốt nghiệp THPT) phải làm đơn theo mẫu của trường, xin ý kiến xác nhận không nợ sách Thư viện, không nợ học phí, sau đó nộp về Phòng Đào tạo để ra quyết định xóa tên và trả lại hồ sơ. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(92, 1, 'FAQ #107 - Đăng ký thi lại chuẩn đầu ra', 'Đăng ký thi lại chuẩn đầu ra', NULL, NULL, 'thi lai anh van, thi lai tin hoc, nop don thi lai cdr, dang ky thi tieng anh', 'Trung tâm Ngoại ngữ và Trung tâm Tin học UTH tổ chức các đợt thi đánh giá chuẩn đầu ra định kỳ hằng tháng. Sinh viên theo dõi lịch thông báo, đăng ký và đóng lệ phí dự thi trực tuyến trên trang của Trung tâm trước ngày thi ít nhất 10 ngày. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(93, 1, 'FAQ #108 - Xét giảm điểm rèn luyện', 'Xét giảm điểm rèn luyện', NULL, NULL, 'tru diem ren luyen, khieu nai drl, mo cong drl, cham lai drl, kieu nai drl', 'Nếu phát hiện điểm rèn luyện hiển thị trên Portal bị sai sót hoặc bị trừ điểm không rõ lý do, sinh viên làm đơn khiếu nại gửi Ban cán sự lớp và Cố vấn học tập trong thời gian 5 ngày kể từ khi công bố kết quả dự kiến để được kiểm tra, điều chỉnh. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xin tạm hoãn thi học kỳ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(94, 1, 'FAQ #109 - Quy trình vay vốn ngân hàng', 'Quy trình vay vốn ngân hàng', NULL, NULL, 'vay von ngan hang, giay xac nhan vay von, ngan hang chinh sach, don xin vay von', 'Sinh viên thuộc diện đối tượng được vay vốn tín dụng học tập mang hộ khẩu và minh chứng đối tượng đến Phòng Công tác sinh viên để xin cấp \"Giấy xác nhận là sinh viên của trường\". Sau đó mang giấy này về địa phương để làm thủ tục giải ngân tại Ngân hàng Chính sách Xã hội. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về gia hạn học phí, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(95, 1, 'FAQ #110 - Chính sách Học bổng tuyển sinh', 'Chính sách Học bổng tuyển sinh', NULL, NULL, 'hoc bong tuyen sinh, thu khoa, kien quoc, hoc bong dau vao, khuyen khich dau vao', 'UTH cấp học bổng toàn phần hoặc bán phần (miễn 50% - 100% học phí năm đầu) cho các tân sinh viên đạt danh hiệu Thủ khoa trường, Thủ khoa ngành, hoặc các thí sinh đạt điểm cao xuất sắc trong kỳ thi tốt nghiệp THPT và kỳ thi Đánh giá năng lực. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký tham gia hiến máu đợt hè và về ngày hội sáng tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(96, 1, 'FAQ #111 - Thời gian giữ xe tối đa tại trường', 'Thời gian giữ xe tối đa tại trường', NULL, NULL, 'gui xe qua dem, mat xe, quen lay xe, giu xe may, bai xe mo cua den may gio', 'Bãi giữ xe trường UTH mở cửa từ 6h00 đến 22h00 hằng ngày. Sinh viên không được để xe lại bãi qua đêm. Trường hợp xe bị hư hỏng bắt buộc phải để lại, sinh viên phải báo cáo và đăng ký thông tin với Đội bảo vệ trực ban của trường để được quản lý. Ngoài ra, nếu bạn còn thắc mắc về quy định sử dụng mạng wifi nội bộ của trường hoặc về liên hệ ban quản lý ký túc xá, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(97, 1, 'FAQ #112 - Thủ tục phúc khảo điểm quá trình', 'Thủ tục phúc khảo điểm quá trình', NULL, NULL, 'phuc khao diem thanh phan, xem lai diem giua ky, diem qua trinh bi sai, sửa điểm', 'Điểm quá trình (điểm chuyên cần, bài tập, giữa kỳ) do Giảng viên bộ môn quản lý và công bố trên lớp. Nếu có thắc mắc, sinh viên phải phản hồi trực tiếp với Giảng viên trước khi môn học kết thúc. Khi điểm đã nộp về trường, giảng viên mới không thể tự ý chỉnh sửa. Bên cạnh đó, nếu bạn cũng quan tâm về học cải thiện, hay về đổi lịch thi học kỳ, cứ hỏi mình thêm nha.', '/ket-qua-hoc-tap', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(98, 1, 'FAQ #113 - Tham gia hiến máu có được nghỉ học', 'Tham gia hiến máu có được nghỉ học', NULL, NULL, 'hien mau co duoc nghi, xin nghi hoc hien mau, hoãn hoc hien mau', 'Sinh viên tham gia ngày hội hiến máu tình nguyện tổ chức tại trường sẽ được hỗ trợ cấp Giấy chứng nhận hiến máu. Giấy này được dùng làm minh chứng hợp lệ để xin phép nghỉ học có lý do đối với các tiết học diễn ra trong ngày hiến máu đó. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về khảo sát ý kiến sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/lich-hoc-trong-tuan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(99, 1, 'FAQ #114 - Đổi thẻ nhựa sang thẻ sinh viên', 'Đổi thẻ nhựa sang thẻ sinh viên', NULL, NULL, 'doi the nhua, lam the sinh vien moi, chip the sinh vien, tich hop the ngan hang', 'Hiện nay UTH triển khai cấp thẻ sinh viên tích hợp thẻ ngân hàng thông minh. Sinh viên năm nhất nhận thẻ theo lịch phân phối của phòng CTSV. Sinh viên khóa cũ có nhu cầu đổi phôi thẻ lỗi sang thẻ đa năng mới đăng ký và đóng phí tại văn phòng phòng CTSV. Ngoài ra, nếu bạn còn thắc mắc về khóa tài khoản Portal hoặc về phạt tiền thư viện, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(100, 1, 'FAQ #115 - Hủy tư cách đoàn viên', 'Hủy tư cách đoàn viên', NULL, NULL, 'xoa ten doan, rut so doan, khong sinh hoat doan, dong doan phi', 'Đoàn viên không tham gia sinh hoạt Đoàn hoặc không đóng đoàn phí liên tục trong 3 tháng mà không có lý do chính đáng sẽ bị xem xét xóa tên khỏi danh sách Đoàn viên và thông báo về Chi đoàn lớp sinh hoạt để trừ điểm rèn luyện theo quy chế. Bên cạnh đó, nếu bạn cũng quan tâm về nghiên cứu khoa học, hay về đồng phục & trang phục, cứ hỏi mình thêm nha.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(101, 1, 'FAQ #116 - Chính sách hỗ trợ bảo hiểm tai nạn', 'Chính sách hỗ trợ bảo hiểm tai nạn', NULL, NULL, 'bao hiem tai nan, bhtn, bi tai nan duoc den bao nhieu, ho tro nam vien', 'Ngoài BHYT bắt buộc, nhà trường có liên kết đơn vị bảo hiểm để sinh viên đăng ký tự nguyện Bảo hiểm tai nạn. Khi xảy ra sự cố chấn thương, nằm viện, sinh viên mang Giấy ra viện và hóa đơn chi phí đến Phòng Công tác sinh viên để làm thủ tục nhận tiền bảo hiểm bồi thường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về lệ phí xét tuyển hồ sơ đầu vào — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(102, 1, 'FAQ #117 - Mượn thiết bị âm thanh, sự kiện', 'Mượn thiết bị âm thanh, sự kiện', NULL, NULL, 'muon loa keo, loa mic, thiet bi su kien, loa mic clb, thiet bi doan hoi', 'Các Câu lạc bộ, Chi đoàn lớp cần mượn loa kéo, micro, thiết bị âm thanh hoặc backdrop để tổ chức hoạt động phong trào phải làm đơn đăng ký thông qua Văn phòng Đoàn trường hoặc Phòng Quản trị thiết bị trước ngày diễn ra sự kiện ít nhất 3 ngày. Ngoài ra, nếu bạn còn thắc mắc về mất thẻ sinh viên hoặc về khóa tài khoản Portal, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(103, 1, 'FAQ #118 - Cấp lại giấy chứng nhận quốc phòng', 'Cấp lại giấy chứng nhận quốc phòng', NULL, NULL, 'mat bang quan su, mat giay quoc phong, cap lai chung chi gdqp, xin bang diem gdqp', 'Chứng chỉ Giáo dục Quốc phòng - An ninh do Trung tâm GDQP cấp gốc 1 lần duy nhất. Nếu bị mất, sinh viên không được cấp lại bằng gốc mà phải làm đơn xin cấp Giấy xác nhận hoàn thành môn học hoặc bản sao bảng điểm trực tiếp tại Trung tâm quản lý để nộp xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về giáo dục quốc phòng, hay về giáo dục thể chất, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(104, 1, 'FAQ #119 - Đăng ký tham gia hiến máu đợt hè', 'Đăng ký tham gia hiến máu đợt hè', NULL, NULL, 'hien mau mua he, hien mau hk he, lich hien mau thang 6 thang 7', 'Hoạt động hiến máu tình nguyện đợt hè thường được phối hợp tổ chức vào khoảng tháng 6 hoặc tháng 7 nhằm bổ sung nguồn máu dự trữ khan hiếm. Sinh viên học kỳ hè hoặc sinh viên ở lại thành phố đăng ký trực tuyến qua Fanpage Hội Sinh viên trường UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh hoạt công dân và về văn nghệ tiếng hát — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(105, 1, 'FAQ #120 - Quy định số lần cảnh báo học vụ', 'Quy định số lần cảnh báo học vụ', NULL, NULL, 'bi canh bao may lan thi bi duoi, gioi han canh bao, canh bao hoc vu muc do 2', 'Theo quy chế học vụ UTH, sinh viên bị cảnh báo học vụ 2 lần liên tiếp sẽ bị buộc thôi học. Nếu bị cảnh báo rải rác không liên tiếp, sinh viên vẫn được tiếp tục học nhưng phải chủ động gặp Cố vấn học tập để làm cam kết lộ trình cải thiện điểm số. Ngoài ra, nếu bạn còn thắc mắc về điểm rèn luyện f hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-ca-nhan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(106, 1, 'FAQ #121 - Thời hạn sử dụng của thẻ thư viện', 'Thời hạn sử dụng của thẻ thư viện', NULL, NULL, 'gia han the thu vien, the thu vien het han, khoa the thu vien', 'Thẻ thư viện UTH (tích hợp trên Thẻ sinh viên) có giá trị sử dụng xuyên suốt toàn bộ khóa học chính quy của sinh viên tại trường. Tài khoản thư viện sẽ tự động bị khóa sau khi sinh viên nhận quyết định tốt nghiệp hoặc quyết định thôi học, ngừng học. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về cấp lại bảng điểm, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(107, 1, 'FAQ #122 - Thủ tục xin miễn học thể dục', 'Thủ tục xin miễn học thể dục', NULL, NULL, 'mien hoc the duc, khong hoc the duc bi khuyet tat, don mien giao duc the chat, gay chan, chan thuong, tai nan, dau om', 'Sinh viên có khuyết tật, dị tật hoặc mắc các bệnh lý mãn tính không thể tham gia vận động mạnh phải làm đơn xin miễn/giảm học phần Giáo dục thể chất kèm theo Bệnh án, Giấy chứng nhận thương tật của bệnh viện cấp Quận trở lên nộp về Bộ môn GDTC để xét duyệt chuyển đổi môn học phù hợp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giáo dục quốc phòng và về cấp lại giấy chứng nhận quốc phòng — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dang-ky-hoc-phan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(108, 1, 'FAQ #123 - Thời gian nhận bằng tốt nghiệp', 'Thời gian nhận bằng tốt nghiệp', NULL, NULL, 'khi nao nhan bang goc, lay bang tot nghiep o dau, phat bang tot nghiep', 'Bằng tốt nghiệp chính thức được cấp phát cho sinh viên trong vòng 30 ngày kể từ ngày ký Quyết định công nhận tốt nghiệp. Sinh viên nhận bằng trực tiếp tại lễ tốt nghiệp hoặc đến văn phòng Phòng Đào tạo để ký sổ nhận bằng gốc (mang theo CCCD). Ngoài ra, nếu bạn còn thắc mắc về điều kiện tốt nghiệp hoặc về thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(109, 1, 'FAQ #124 - Phí phạt nợ học phí quá hạn', 'Phí phạt nợ học phí quá hạn', NULL, NULL, 'nop tre hoc phi, nop phat hoc phi, tre han dong tien hoc bi phat bao nhieu', 'UTH không áp dụng hình thức phạt tiền mặt khi sinh viên nộp học phí trễ hạn. Tuy nhiên, sinh viên không hoàn thành học phí đúng thời gian quy định sẽ bị hệ thống tự động khóa tài khoản Portal, hủy danh sách đăng ký học phần và cấm tham gia kỳ thi học kỳ. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình vay vốn ngân hàng, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(110, 1, 'FAQ #125 - Xin hoãn đi thực tập tốt nghiệp', 'Xin hoãn đi thực tập tốt nghiệp', NULL, NULL, 'hoan thuc tap, don xin hoan thuc tap nam cuoi, doi lich di thuc tap', 'Sinh viên năm cuối vì lý do sức khỏe hoặc chưa tích lũy đủ các môn học điều kiện bắt buộc muốn xin hoãn học phần Thực tập tốt nghiệp phải làm đơn xin hoãn nộp về Văn phòng Khoa/Viện chủ quản trước khi danh sách phân công đơn vị thực tập được công bố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chương trình đào tạo và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(111, 1, 'FAQ #126 - Chính sách hỗ trợ sinh viên nghèo', 'Chính sách hỗ trợ sinh viên nghèo', NULL, NULL, 'tro cap kho khan, ho tro sinh vien ngheo đột xuất, tro cap xa hoi', 'Sinh viên gặp tai nạn, thiên tai, hỏa hoạn hoặc gia đình gặp biến cố lớn đột xuất dẫn đến hoàn cảnh đặc biệt khó khăn làm đơn xin hỗ trợ gửi Phòng Công tác sinh viên. Nhà trường sẽ xem xét trích Quỹ hỗ trợ sinh viên để cấp kinh phí trợ cấp đột xuất. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chế độ miễn giảm học phí cho con em diện chính sách, mình có thể hỗ trợ giải đáp thêm nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(112, 1, 'FAQ #127 - Đồ án tốt nghiệp đạt điểm F xử lý sao', 'Đồ án tốt nghiệp đạt điểm F xử lý sao', NULL, NULL, 'rot do an tot nghiep, lam lai khoa luan, rot khoa luan ra truong', 'Sinh viên bảo vệ Đồ án hoặc Khóa luận tốt nghiệp nhận điểm F (không đạt) sẽ không được tốt nghiệp đúng hạn. Sinh viên bắt buộc phải đăng ký làm lại đề tài mới hoặc đăng ký lại học phần đồ án vào kỳ xét duyệt tiếp theo của năm học sau và đóng phí theo quy định. Bên cạnh đó, nếu bạn cũng quan tâm về thời gian nhận bằng tốt nghiệp, hay về chương trình đào tạo, cứ hỏi mình thêm nha.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(113, 1, 'FAQ #128 - Quy chế xét học bổng khi nợ môn', 'Quy chế xét học bổng khi nợ môn', NULL, NULL, 'no mon co duoc hoc bong, rot mon co duoc xet hoc bong, thi lai co duoc hoc bong', 'Theo quy chế khen thưởng của UTH, sinh viên chỉ cần nợ 1 môn học (nhận điểm F) hoặc đăng ký thi lại/học lại bất kỳ môn nào trong học kỳ đó thì sẽ lập tức bị tước quyền tham gia xét duyệt Học bổng khuyến khích học tập, bất kể điểm GPA tổng của bạn cao bao nhiêu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học bổng doanh nghiệp và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(114, 1, 'FAQ #129 - Liên hệ Ban quản lý ký túc xá', 'Liên hệ Ban quản lý ký túc xá', NULL, NULL, 'so dien thoai ban quan ly ktx, gap ai de phan anh ktx, ban quan ly noi tru', 'Để phản ánh các vấn đề về điện nước, an ninh phòng ở hoặc nộp chi phí nội trú Ký túc xá, sinh viên đến trực tiếp văn phòng Ban quản lý nội trú Ký túc xá đặt tại khu vực cổng vào của khu nội trú cơ sở đó để được cán bộ trực ban giải quyết. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(115, 1, 'FAQ #131 - Phương thức tuyển sinh năm 2026 của UTH', 'Phương thức tuyển sinh năm 2026 của UTH', NULL, NULL, 'phương thức tuyển sinh 2026, phuong thuc tuyen sinh 2026, uth xet tuyen cach nao, xet hoc ba 2026, diem thi thpt 2026', 'Năm 2026, UTH tuyển sinh đại học chính quy theo 2 phương thức: (1) Xét tuyển thẳng theo quy định của Bộ GD&ĐT và theo Đề án riêng của UTH (thí sinh đạt giải HSG cấp Tỉnh/Thành trở lên; có chứng chỉ tiếng Anh quốc tế từ IELTS 6.0, TOEFL iBT 60, TOEIC 600 hoặc Bậc 4/6 trở lên; học sinh trường chuyên/trọng điểm; đạt học lực Giỏi nhiều học kỳ; thuộc nhóm ngành ưu tiên nhà nước như đường sắt tốc độ cao, CNTT, trí tuệ nhân tạo; hoặc có thư giới thiệu từ doanh nghiệp đối tác của UTH); (2) Xét tuyển kết hợp - phương thức chủ đạo, chiếm phần lớn chỉ tiêu, tính điểm theo công thức riêng của trường (UTH120), kết hợp điểm thi Đánh giá năng lực (nếu có), điểm học bạ cả năm lớp 12, điểm thi tốt nghiệp THPT năm 2026 và điểm ưu tiên/điểm khuyến khích theo quy định. Từ năm 2025, UTH không còn xét tuyển riêng lẻ theo điểm thi THPT hay điểm học bạ như các năm trước đó; các loại điểm này chỉ là thành phần trong công thức xét tuyển kết hợp chung. Chương trình đào tạo được thiết kế 120 tín chỉ, thời gian học tối thiểu 3 năm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian công bố kết quả trúng tuyển chính thức và về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(116, 1, 'FAQ #132 - Các tổ hợp môn xét tuyển phổ biến tại UTH', 'Các tổ hợp môn xét tuyển phổ biến tại UTH', NULL, NULL, 'tổ hợp môn xét tuyển, to hop mon xet tuyen, khoi thi vao uth, khoi a00 a01 d01 d07, uth xet khoi nao', 'Trong công thức xét tuyển kết hợp của UTH, điểm xét tuyển được tính từ 3 môn theo tổ hợp đăng ký (các tổ hợp phổ biến nhiều năm qua gồm A00: Toán - Lý - Hóa; A01: Toán - Lý - Anh; D01: Toán - Văn - Anh; D07: Toán - Hóa - Anh), sau đó tổng hợp cùng điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực (nếu có) theo công thức và trọng số riêng của từng năm tuyển sinh. Công nghệ thông tin và Logistics - Quản lý chuỗi cung ứng tiếp tục là các nhóm ngành có chỉ tiêu lớn và mức độ cạnh tranh cao nhất trường. Vì tổ hợp và công thức tính điểm cụ thể có thể thay đổi theo từng ngành và từng năm, thí sinh nên tra cứu Đề án tuyển sinh chính thức hằng năm tại tuyensinh.ut.edu.vn để có thông tin chính xác nhất. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xác nhận nhập học trực tuyến hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(117, 1, 'FAQ #133 - Điểm chuẩn ngành Công nghệ thông tin (CNTT) năm 2025', 'Điểm chuẩn ngành Công nghệ thông tin (CNTT) năm 2025', NULL, NULL, 'điểm chuẩn cntt 2025, diem chuan cong nghe thong tin 2025, nganh cntt uth bao nhieu diem, diem trung tuyen cntt', 'Năm 2025, UTH xét tuyển theo phương thức Xét tuyển kết hợp với thang điểm riêng của trường (không phải thang 30 quen thuộc, mà dao động 668-999 điểm tùy ngành). Điểm chuẩn trúng tuyển các chuyên ngành thuộc nhóm Công nghệ thông tin, công bố ngày 22/8/2025, như sau: CNTT (chuyên ngành CNTT, chương trình tiên tiến): 800 điểm; CNTT chuyên ngành Khoa học dữ liệu và AI (chương trình tiên tiến): 800 điểm; CNTT chương trình hoàn toàn bằng tiếng Anh: 800 điểm; CNTT chuyên ngành Truyền thông số và Đổi mới sáng tạo: 720 điểm; CNTT chuyên ngành Smart Logistics: 720 điểm; CNTT chuyên ngành Công nghệ ô tô số: 800 điểm. Lưu ý: mức điểm này tính theo công thức riêng của UTH (kết hợp điểm học bạ, điểm thi THPT, điểm Đánh giá năng lực và điểm ưu tiên) nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, cứ hỏi mình thêm nha.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(118, 1, 'FAQ #134 - Điểm chuẩn ngành Logistics và Quản lý chuỗi cung ứng năm 2025', 'Điểm chuẩn ngành Logistics và Quản lý chuỗi cung ứng năm 2025', NULL, NULL, 'điểm chuẩn logistics 2025, diem chuan logistics 2025, nganh logistics lay bao nhieu diem, diem xet tuyen logistics', 'Logistics và Quản lý chuỗi cung ứng tiếp tục là một trong những ngành có điểm chuẩn cao nhất UTH. Theo điểm chuẩn chính thức công bố ngày 22/8/2025 (phương thức Xét tuyển kết hợp, thang điểm riêng của trường, KHÔNG phải thang 30): Logistics và Quản lý chuỗi cung ứng - chương trình tiên tiến: 963 điểm (chỉ xếp sau ngành Khoa học dữ liệu - chương trình tiên tiến với 999 điểm, cao nhất toàn trường); Logistics và Quản lý chuỗi cung ứng - chương trình hoàn toàn bằng tiếng Anh: 720 điểm. Đây tiếp tục là ngành có mức độ cạnh tranh rất cao tại UTH trong nhiều năm liền. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về rút hồ sơ thôi học và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/chuong-trinh-khung', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(119, 1, 'FAQ #135 - Điểm chuẩn tổng hợp tất cả các ngành năm 2025', 'Điểm chuẩn tổng hợp tất cả các ngành năm 2025', NULL, NULL, 'điểm chuẩn 2025, diem chuan 2025, điểm chuẩn tất cả các ngành uth, diem chuan tat ca cac nganh, điểm chuẩn uth 2025 mới nhất, điểm chuẩn năm 2025 bao nhiêu, xet tuyen ket hop 2025, diem chuan hoc ba 2025', 'UTH công bố điểm chuẩn chính thức hệ đại học chính quy năm 2025 vào ngày 22/8/2025, theo phương thức Xét tuyển kết hợp (thang điểm riêng của trường, KHÔNG phải thang 30 truyền thống), dao động từ 668 đến 999 điểm tùy ngành/chuyên ngành. Một số mức điểm chuẩn tiêu biểu: Khoa học dữ liệu (chương trình tiên tiến) 999 điểm - cao nhất toàn trường; Logistics và Quản lý chuỗi cung ứng (chương trình tiên tiến) 963 điểm; Kỹ thuật điện (chuyên ngành Điện công nghiệp, Hệ thống điện giao thông, Năng lượng tái tạo) 936 điểm; Công nghệ kỹ thuật điều khiển và tự động hóa (chương trình tiên tiến) 931 điểm. Nhóm ngành phổ biến ở mức 720-800 điểm gồm: Công nghệ thông tin, Ngôn ngữ Anh, Luật, Quản trị kinh doanh, Hệ thống thông tin quản lý, Kỹ thuật cơ khí, Kỹ thuật ô tô, Kinh tế xây dựng, Khai thác vận tải, Kinh tế vận tải (đa số thuộc chương trình tiên tiến). Nhóm có điểm sàn thấp nhất (668 điểm) gồm các chương trình chuẩn (không phải tiên tiến) như Kỹ thuật tàu thủy, Kỹ thuật xây dựng công trình thủy, Khoa học hàng hải và các ngành liên quan đường sắt tốc độ cao. Lưu ý quan trọng: mức điểm 2025 tính theo công thức riêng của UTH (kết hợp điểm học bạ lớp 12, điểm thi THPT, điểm thi Đánh giá năng lực và điểm ưu tiên), nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Trường có hơn 50 ngành/chuyên ngành/chương trình đào tạo khác nhau, mỗi ngành có mức điểm riêng; thí sinh nên tra cứu bảng điểm chuẩn đầy đủ theo từng mã ngành tại tuyensinh.ut.edu.vn hoặc liên hệ Phòng Đào tạo để được tư vấn chính xác. Ngoài ra, nếu bạn còn thắc mắc về phương thức tuyển sinh năm 2026 của UTH hoặc về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(120, 1, 'FAQ #136 - Chỉ tiêu tuyển sinh dự kiến năm 2026', 'Chỉ tiêu tuyển sinh dự kiến năm 2026', NULL, NULL, 'chỉ tiêu tuyển sinh 2026, chi tieu tuyen sinh 2026, uth tuyen bao nhieu sinh vien, chi tieu nganh cntt 2026', 'UTH công bố Đề án tuyển sinh đại học chính quy năm 2026 vào ngày 16/6/2026, với hơn 50 ngành/chuyên ngành đào tạo, mở rộng thêm nhiều chuyên ngành mới gắn với công nghệ số như: Khoa học dữ liệu - Blockchain và AI, Smart Logistics, Công nghệ ô tô số, Kinh tế số và Trí tuệ nhân tạo, Truyền thông số và Đổi mới sáng tạo, Logistics xanh và phát triển bền vững, Quản lý và công nghệ UAV... Chỉ tiêu cụ thể được phân bổ chi tiết theo từng mã ngành trong Đề án tuyển sinh chính thức chứ không phải một con số tổng cố định, và có thể thay đổi theo từng năm. Thí sinh nên tra cứu chỉ tiêu cụ thể theo từng mã ngành tại Đề án tuyển sinh 2026 chính thức đăng trên tuyensinh.ut.edu.vn thay vì dựa vào số liệu ước tính. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành công nghệ thông tin, hay về thủ tục xác nhận nhập học trực tuyến, cứ hỏi mình thêm nha.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(121, 1, 'FAQ #137 - Cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH', 'Cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH', NULL, NULL, 'quy đổi điểm ielts, quy doi diem ielts tuyen sinh, ielts 5.5 duoc may diem, cong diem ielts vao uth', 'UTH không áp dụng một bảng quy đổi điểm IELTS sang thang điểm xét tuyển cố định. Chứng chỉ tiếng Anh quốc tế được UTH sử dụng theo 2 cách: (1) Trong xét tuyển đầu vào: thí sinh có chứng chỉ IELTS từ 6.0 trở lên (hoặc TOEFL iBT từ 60, TOEFL ITP từ 530, TOEIC từ 600, Bậc 4 theo Khung năng lực ngoại ngữ 6 bậc dùng cho Việt Nam trở lên, còn hiệu lực) có thể dùng làm một trong các tiêu chí để đăng ký diện Xét tuyển thẳng theo Đề án riêng của UTH; (2) Sau khi nhập học: sinh viên nộp chứng chỉ IELTS hoặc chứng chỉ ngoại ngữ tương đương để trường xét miễn các cấp độ học phần tiếng Anh tương ứng với năng lực (miễn đến cấp độ nào thì được miễn học phí cấp độ đó), nộp hồ sơ trực tuyến qua support.ut.edu.vn (mục Phòng Đào tạo/Chuẩn đào tạo ngoại ngữ UTH). Vì điều kiện cụ thể có thể điều chỉnh theo từng năm, sinh viên nên tra cứu Đề án tuyển sinh hoặc thông báo chính thức mới nhất của UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL);
INSERT INTO `knowledge_articles` (`id`, `source_id`, `title`, `category`, `subcategory`, `intent_code`, `keywords`, `answer_content`, `route_url`, `audience`, `faculty_id`, `program_id`, `cohort_from`, `cohort_to`, `semester_code`, `academic_year_code`, `valid_from`, `valid_until`, `verification_status`, `confidence_level`, `priority`, `version`, `language_code`, `created_by`, `reviewed_by`, `reviewed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(122, 1, 'FAQ #138 - Điểm sàn nhận hồ sơ xét tuyển (Ngưỡng đảm bảo chất lượng)', 'Điểm sàn nhận hồ sơ xét tuyển (Ngưỡng đảm bảo chất lượng)', NULL, NULL, 'điểm sàn uth, diem san nhan ho so, bao nhieu diem thi duoc nop don, diem san 2025 2026', 'Từ năm 2025, UTH chuyển sang phương thức Xét tuyển kết hợp làm phương thức tuyển sinh chủ đạo (tính điểm theo công thức riêng của trường, kết hợp điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực), nên khái niệm \"điểm sàn\" theo thang 30 truyền thống không còn áp dụng thống nhất cho toàn trường như các năm trước 2025. Điều kiện đầu vào tối thiểu của phương thức xét tuyển kết hợp hiện nay là thí sinh phải có điểm thi môn Toán trong kỳ thi tốt nghiệp THPT từ 5.0 trở lên (một số ngành yêu cầu cao hơn, ví dụ ngành Toán ứng dụng yêu cầu từ 6.0), cùng với ngưỡng đảm bảo chất lượng cụ thể theo từng ngành được quy định riêng trong Đề án tuyển sinh của từng năm. Thí sinh cần tra cứu Đề án tuyển sinh chính thức mới nhất tại tuyensinh.ut.edu.vn để biết điều kiện đăng ký xét tuyển áp dụng cho ngành mình quan tâm. Ngoài ra, nếu bạn còn thắc mắc về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT hoặc về lệ phí xét tuyển hồ sơ đầu vào, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(123, 1, 'FAQ #139 - Đăng ký nguyện vọng vào UTH trên hệ thống của Bộ GD&ĐT', 'Đăng ký nguyện vọng vào UTH trên hệ thống của Bộ GD&ĐT', NULL, NULL, 'đăng ký nguyện vọng, dang ky nguyen vong, ma truong uth la gi, xep nguyen vong vao uth', 'Để xét tuyển vào UTH bằng điểm thi THPT, thí sinh phải đăng ký nguyện vọng trên hệ thống chung của Bộ GD&ĐT theo đúng lịch quy định. Thí sinh cần nhập chính xác Mã trường của UTH là GTS và chọn đúng mã ngành, mã tổ hợp môn mong muốn. Nên xếp ngành yêu thích nhất ở Nguyện vọng 1. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025, hay về lệ phí xét tuyển hồ sơ đầu vào, cứ hỏi mình thêm nha.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(124, 1, 'FAQ #140 - Lệ phí xét tuyển hồ sơ đầu vào', 'Lệ phí xét tuyển hồ sơ đầu vào', NULL, NULL, 'lệ phí xét tuyển, le phi xet tuyen, nop tien xet hoc ba bao nhieu, dong tien nguyen vong', 'Lệ phí xét tuyển đối với phương thức xét học bạ nộp trực tiếp về trường UTH áp dụng theo quy định hành chính thu chi. Đối với phương thức xét điểm thi THPT, thí sinh đóng lệ phí trực tuyến trực tiếp trên hệ thống cổng thông tin của Bộ GD&ĐT khi tiến hành xác nhận số lượng nguyện vọng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học phí trường và về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(125, 1, 'FAQ #141 - Thời gian công bố kết quả trúng tuyển chính thức', 'Thời gian công bố kết quả trúng tuyển chính thức', NULL, NULL, 'khi nào biết kết quả trúng tuyển, khi nao biet ket qua trung tuyen, lich cong bo diem chuan uth', 'Thời gian công bố điểm chuẩn và danh sách trúng tuyển chính thức của UTH tuân thủ nghiêm ngặt theo lộ trình chung của Bộ GD&ĐT (thường vào khoảng tháng 8 hằng năm). Kết quả xét tuyển sớm bằng học bạ thường được trường thông báo trước đó vào tháng 6 hoặc tháng 7. Ngoài ra, nếu bạn còn thắc mắc về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-bao-su-kien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(126, 1, 'FAQ #142 - Thủ tục xác nhận nhập học trực tuyến', 'Thủ tục xác nhận nhập học trực tuyến', NULL, NULL, 'xác nhận nhập học, xac nhan nhap hoc online, huong dan nhap hoc uth, khong xac nhan nhap hoc bi gi', 'Sau khi có thông báo trúng tuyển chính thức, thí sinh bắt buộc phải thực hiện bước Xác nhận nhập học trực tuyến trên hệ thống của Bộ GD&ĐT trước thời hạn quy định. Thí sinh cố tình không xác nhận nhập học đúng hạn sẽ bị hệ thống tự động hủy kết quả trúng tuyển vào trường. Bên cạnh đó, nếu bạn cũng quan tâm về các tổ hợp môn xét tuyển phổ biến tại UTH, hay về phương thức tuyển sinh năm 2026 của UTH, cứ hỏi mình thêm nha.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(127, 1, 'FAQ #143 - Hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học', 'Hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học', NULL, NULL, 'hồ sơ nhập học cần gì, ho so nhap hoc can gi, mang theo gi khi nhap hoc uth, giay to nhap hoc', 'Hồ sơ nhập học bản giấy nộp tại trường bao gồm: Giấy báo trúng tuyển bản gốc; Học bạ THPT (bản sao công chứng); Giấy chứng nhận tốt nghiệp tạm thời hoặc Bằng tốt nghiệp THPT; Bản sao CCCD; Giấy khai sinh; và các giấy tờ minh chứng đối tượng ưu tiên chính sách (nếu có). Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy trình làm thủ tục nhập học trực tiếp tại trường và về rút hồ sơ thôi học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', '/dich-vu-sinh-vien', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(128, 1, 'FAQ #144 - Quy trình làm thủ tục nhập học trực tiếp tại trường', 'Quy trình làm thủ tục nhập học trực tiếp tại trường', NULL, NULL, 'quy trình nhập học trực tiếp, quy trinh nhap hoc truc tiep, den truong nhap hoc o dau, huong dan tan sinh vien', 'Khi đến nhập học trực tiếp tại cơ sở chính của UTH, tân sinh viên thực hiện theo quy trình luồng: - Tra cứu số thứ tự và phòng làm thủ tục tại sảnh hướng dẫn. - Nộp hồ sơ bản giấy tại bàn tiếp nhận của Khoa/Viện. - Đóng học phí và các khoản bảo hiểm bắt buộc tại bàn tài chính. - Nhận lịch học Tuần sinh hoạt công dân và chụp ảnh làm Thẻ sinh viên. Ngoài ra, nếu bạn còn thắc mắc về thời gian nhận bằng tốt nghiệp hoặc về điều kiện tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', '/thong-tin-truong', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(129, 1, 'FAQ #145 - Chính sách rút hồ sơ hoàn học phí đối với tân sinh viên', 'Chính sách rút hồ sơ hoàn học phí đối với tân sinh viên', NULL, NULL, 'rút học phí nhập học, rut hoc phi nhap hoc, nhap hoc roi xin rut lai tien, thoi hoc rut lai hoc phi', 'Tân sinh viên đã làm thủ tục nhập học nhưng vì lý do cá nhân muốn xin rút hồ sơ không theo học nữa sẽ được xem xét hoàn trả học phí tùy theo thời điểm nộp đơn. Nếu nộp đơn rút trước ngày khai giảng chính thức, sinh viên được hoàn lại một phần học phí theo quy định đóng rút bồi hoàn của nhà trường; sau ngày khai giảng sẽ không được hoàn phí. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách hỗ trợ sinh viên nghèo, hay về quy trình vay vốn ngân hàng, cứ hỏi mình thêm nha.', '/cong-thanh-toan', 'all', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'pending', 'low', 5, 1, 'vi', NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(256, 2, 'Quy định điều chỉnh đăng ký học phần học kỳ hè 2025-2026', 'Đăng ký học phần', 'Học kỳ hè', 'academic_knowledge', 'đăng ký học phần, điều chỉnh học phần, học kỳ hè, rút môn, thêm môn', 'Sinh viên điều chỉnh đăng ký học phần học kỳ hè 2025-2026 trực tiếp trên Portal trong thời gian trường công bố. Sau hạn điều chỉnh, sinh viên cần gửi yêu cầu hỗ trợ để được Phòng Đào tạo xem xét theo quy định.', '/dang-ky-hoc-phan', 'student', NULL, 1, 2023, 2023, 'HK_HE_2026', '2025-2026', '2026-07-01 00:00:00', '2026-07-31 23:59:59', 'verified', 'authoritative', 1, 1, 'vi', 1, 1, '2026-07-11 16:34:11', '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL),
(257, 2, 'Hướng dẫn tra cứu công nợ học phí trên Portal', 'Học phí', 'Tra cứu công nợ', 'academic_knowledge', 'học phí, công nợ, thanh toán học phí, cổng thanh toán', 'Sinh viên tra cứu công nợ và thanh toán học phí tại Cổng thanh toán hoặc mục học phí trên Portal. Các câu hỏi về số tiền còn nợ của từng sinh viên phải được tra cứu từ dữ liệu hóa đơn trong database.', '/cong-thanh-toan', 'student', NULL, NULL, NULL, NULL, NULL, NULL, '2026-07-01 00:00:00', NULL, 'verified', 'authoritative', 1, 1, 'vi', 1, 1, '2026-07-11 16:34:11', '2026-07-11 16:34:11', '2026-07-11 16:34:11', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `knowledge_chunks`
--

CREATE TABLE `knowledge_chunks` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `article_id` bigint(20) UNSIGNED NOT NULL,
  `chunk_index` int(10) UNSIGNED NOT NULL,
  `heading` varchar(500) DEFAULT NULL,
  `chunk_text` longtext NOT NULL,
  `token_count` int(10) UNSIGNED DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `embedding_model` varchar(120) DEFAULT NULL,
  `embedding_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Portable fallback; use a vector DB for large-scale semantic retrieval' CHECK (json_valid(`embedding_json`)),
  `content_hash` char(64) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `knowledge_chunks`
--

INSERT INTO `knowledge_chunks` (`id`, `article_id`, `chunk_index`, `heading`, `chunk_text`, `token_count`, `metadata`, `embedding_model`, `embedding_json`, `content_hash`, `created_at`, `updated_at`) VALUES
(1, 1, 0, 'FAQ #1 - Thông tin chung', 'Trường Đại học Giao thông Vận tải TP.HCM (UTH) có cơ sở chính tại Số 2, Đường Võ Oanh, Phường 25, Quận Bình Thạnh, TP.HCM. Ngoài ra, trường còn có các cơ sở đào tạo khác tại Quận 12 (TP.HCM), TP. Thủ Đức và TP. Vũng Tàu. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về bãi giữ xe của trường, cứ hỏi mình thêm nha.', 82, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(2, 2, 0, 'FAQ #2 - Chương trình Đào tạo', 'UTH là trường công lập đào tạo đa ngành hàng đầu về Giao thông vận tải, Logistics, Công nghệ thông tin, Khoa học dữ liệu, Điện tử viễn thông, Kinh tế vận tải và Kỹ thuật công trình. Hệ đào tạo gồm 2 loại hình: Hệ Đại trà và Hệ Chất lượng cao. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian nhận bằng tốt nghiệp và về xin hoãn đi thực tập tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 102, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(3, 3, 0, 'FAQ #3 - Cách Tính Điểm', 'UTH áp dụng đào tạo theo hệ thống tín chỉ. Điểm tổng kết môn gồm: Điểm quá trình và Điểm thi kết thúc học phần. Điểm tính theo thang điểm 10 rồi quy đổi sang thang điểm chữ (A, B, C, D, F) tương ứng với thang điểm 4. Điểm F là rớt môn và bắt buộc phải đóng tiền đăng ký học lại. Ngoài ra, nếu bạn còn thắc mắc về xét giảm điểm rèn luyện hoặc về phúc khảo điểm thi, mình có thể hỗ trợ giải đáp thêm nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(4, 4, 0, 'FAQ #4 - Học Cải Thiện', 'Sinh viên đạt điểm trung bình môn ở mức D, D+, C, C+ muốn nâng cao điểm trung bình tích lũy (GPA) được phép đăng ký học cải thiện vào các học kỳ tiếp theo. Khi học cải thiện, điểm của lần học sau sẽ thay thế hoàn toàn cho điểm của lần học trước. Bên cạnh đó, nếu bạn cũng quan tâm về xét giảm điểm rèn luyện, hay về quy trình chấm điểm rèn luyện, cứ hỏi mình thêm nha.', 92, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(5, 5, 0, 'FAQ #5 - Cảnh Báo Học Vụ', 'Sinh viên sẽ bị cảnh báo học vụ nếu điểm trung bình tích lũy học kỳ đạt dưới 0.8 (đối với học kỳ đầu tiên) hoặc dưới 1.0 (đối với các học kỳ tiếp theo), hoặc số tín chỉ bị nợ vượt quá quy định. Bị cảnh báo học vụ 2 lần liên tiếp sẽ thuộc diện xem xét buộc thôi học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xét giảm điểm rèn luyện và về điểm rèn luyện f — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 102, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(6, 6, 0, 'FAQ #6 - Đăng Ký Môn Học', 'Sinh viên thực hiện đăng ký học phần (DKMH) trực tuyến tại trang Portal UTH theo khung thời gian thông báo của Phòng Đào tạo. Sinh viên hệ đại trà được đăng ký tối đa 24 tín chỉ và tối thiểu 14 tín chỉ trong một học kỳ chính. Ngoài ra, nếu bạn còn thắc mắc về quy định số lần cảnh báo học vụ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', 89, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(7, 7, 0, 'FAQ #7 - Môn Điều Kiện', 'Môn tiên quyết là môn sinh viên bắt buộc phải học và thi đạt (điểm chữ từ D trở lên) mới được đăng ký môn tiếp theo. Môn học trước là môn sinh viên chỉ cần hoàn thành khóa học (kể cả thi rớt điểm F) là đã đủ điều kiện đăng ký môn sau. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình chấm điểm rèn luyện, hay về bảo lưu kết quả, cứ hỏi mình thêm nha.', 88, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(8, 8, 0, 'FAQ #8 - Quy Chế Thi Cử', 'Lịch thi học kỳ được công bố trên Portal trước kỳ thi 2 tuần. Khi vào phòng thi, sinh viên bắt buộc phải xuất trình Thẻ sinh viên chính thức hoặc giấy tờ tùy thân có ảnh (CCCD). Sinh viên vắng thi không có lý do chính đáng sẽ nhận điểm 0. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về bảo lưu kết quả và về rút học phần, hủy môn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 94, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(9, 9, 0, 'FAQ #9 - Học Phí Trường', 'Học phí UTH được tính theo số tín chỉ đăng ký mỗi học kỳ, phân theo 3 loại chương trình: Chương trình chuẩn (đại trà), Chương trình tiên tiến (trước đây gọi là Chất lượng cao) và Chương trình học hoàn toàn bằng tiếng Anh. Mức thu áp dụng cho tân sinh viên khóa tuyển sinh năm 2026: Chương trình chuẩn 515.000đ/tín chỉ; Chương trình tiên tiến 1.120.000đ/tín chỉ; Chương trình hoàn toàn bằng tiếng Anh 1.500.000đ/tín chỉ. Sinh viên các khóa nhập học từ năm 2025 trở về trước áp dụng mức học phí đã công bố riêng cho khóa đó (thường thấp hơn khóa mới, ví dụ khóa 2025: chương trình chuẩn 400.000đ/tín chỉ, tiên tiến 980.000đ/tín chỉ). Trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học của mỗi khóa. Sinh viên nộp học phí trực tuyến qua Cổng thanh toán của trường (payment.ut.edu.vn) và nên tra cứu mức thu chính xác áp dụng cho khóa của mình trên Portal cá nhân. Ngoài ra, nếu bạn còn thắc mắc về học phí chương trình tiên tiến hoặc về chính sách hỗ trợ bảo hiểm tai nạn, mình có thể hỗ trợ giải đáp thêm nhé.', 257, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(10, 10, 0, 'FAQ #10 - Gia Hạn Học Phí', 'Sinh viên có hoàn cảnh khó khăn không thể hoàn thành học phí đúng hạn phải làm Đơn xin gia hạn học phí trực tuyến gửi Phòng Công tác sinh viên trước thời hạn quy định để không bị khóa tài khoản đăng ký môn học và bị cấm thi. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', 91, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(11, 11, 0, 'FAQ #11 - Hoạt Động Đoàn Hội', 'Ngày hội hiến máu tình nguyện trường UTH được tổ chức định kỳ hàng năm tại Sảnh lớn khu giảng đường A. Sinh viên tham gia hiến máu nhân đạo sẽ được cấp giấy chứng nhận, hỗ trợ chi phí và được cộng 5 điểm rèn luyện (ĐRL) vào mục hoạt động cộng đồng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về ngày hội sáng tạo và về học bổng doanh nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(12, 12, 0, 'FAQ #12 - Các Câu Lạc Bộ', 'UTH hiện có hơn 20 Câu lạc bộ (CLB) sinh viên đang hoạt động thuộc các khối: Học thuật (CLB Tin học, CLB Logistics), Nghệ thuật (CLB Guitar, CLB Bước Nhảy), Thể thao (CLB Bóng đá, Bóng chuyền) và Tình nguyện (Đội Công tác xã hội, CLB Tiếp sức đến trường). Ngoài ra, nếu bạn còn thắc mắc về hoạt động đoàn hội hoặc về đăng ký tham gia hiến máu đợt hè, mình có thể hỗ trợ giải đáp thêm nhé.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(13, 13, 0, 'FAQ #13 - Học Bổng Khuyến Khích', 'Học bổng khuyến khích học tập UTH được xét sau mỗi học kỳ dựa trên 2 tiêu chí song song: Điểm trung bình học tập đạt loại Khá trở lên (từ 2.5/4.0) và Điểm rèn luyện đạt loại Tốt trở lên (từ 80 điểm/100), đồng thời không bị kỷ luật và không nợ môn. Bên cạnh đó, nếu bạn cũng quan tâm về chiến sĩ tình nguyện, hay về giải chạy sinh viên, cứ hỏi mình thêm nha.', 90, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(14, 14, 0, 'FAQ #14 - Chuẩn Đầu Ra Ngoại Ngữ', 'Sinh viên đại học chính quy UTH phải đạt chuẩn đầu ra tiếng Anh theo quy định (thường là TOEIC 450 trở lên hoặc B1 VSTEP tùy theo ngành học). Chứng chỉ phải còn giá trị hiệu lực và nộp về Trung tâm Ngoại ngữ trường để làm thủ tục hậu kiểm xét tốt nghiệp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về đăng ký thi lại chuẩn đầu ra — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 104, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(15, 15, 0, 'FAQ #15 - Chuẩn Tin Học', 'Sinh viên UTH bắt buộc phải hoàn thành chuẩn đầu ra Tin học bằng việc đạt chứng chỉ Tin học đại chúng đại học hoặc các chứng chỉ quốc tế được công nhận tương đương như MOS (đạt 3 kỹ năng Word, Excel, Powerpoint) hoặc IC3. Ngoài ra, nếu bạn còn thắc mắc về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH hoặc về chuẩn tin học quốc tế nâng cao, mình có thể hỗ trợ giải đáp thêm nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(16, 16, 0, 'FAQ #16 - Điều Kiện Tốt Nghiệp', 'Điều kiện xét công nhận tốt nghiệp UTH: Tích lũy đủ số tín chỉ của chương trình khung; Điểm trung bình tích lũy (GPA) toàn khóa đạt từ 2.0/4.0 trở lên; Đạt chuẩn đầu ra Ngoại ngữ và Tin học; Đạt chứng chỉ Giáo dục quốc phòng và Giáo dục thể chất; Không trong thời gian bị kỷ luật. Bên cạnh đó, nếu bạn cũng quan tâm về chuyển cơ sở học tập, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(17, 17, 0, 'FAQ #17 - Mất Thẻ Sinh Viên', 'Khi bị mất thẻ, sinh viên đến Phòng Công tác sinh viên (Cơ sở chính, khu nhà A) để làm thủ tục xin cấp lại thẻ sinh viên mới. Lệ phí cấp lại thẻ theo quy định là 50.000đ. Trong thời gian chờ cấp thẻ mới, sinh viên được cấp giấy xác nhận tạm thời để ra vào trường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về quy định mượn học cụ, thiết bị tại phòng thí nghiệm — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 110, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(18, 18, 0, 'FAQ #18 - Ký Túc Xá Trường', 'UTH hỗ trợ chỗ ở tại Ký túc xá trường cho sinh viên (ưu tiên sinh viên diện chính sách, vùng sâu vùng xa, hoàn cảnh khó khăn). Sinh viên làm Đơn đăng ký nội trú trực tuyến trên Portal hoặc nộp hồ sơ trực tiếp tại Ban quản lý Ký túc xá trong thời gian quy định đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về liên hệ ban quản lý ký túc xá hoặc về ký túc xá quận 12, mình có thể hỗ trợ giải đáp thêm nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(19, 19, 0, 'FAQ #19 - Mượn Sách Thư Viện', 'Thư viện UTH đặt tại khu vực cơ sở chính. Sinh viên sử dụng Thẻ sinh viên để vào thư viện đọc sách hoặc làm thủ tục mượn tài liệu về nhà. Thời gian mượn tối đa là 2 tuần/cuốn. Nếu trả sách trễ hạn, sinh viên sẽ bị phạt tiền theo quy định của thư viện. Bên cạnh đó, nếu bạn cũng quan tâm về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, hay về bảng điểm tiếng anh, cứ hỏi mình thêm nha.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(20, 20, 0, 'FAQ #20 - Bảo Hiểm Y Tế', 'Bảo hiểm y tế (BHYT) là hình thức bắt buộc đối với tất cả sinh viên. Nhà trường tổ chức thu tiền và gia hạn BHYT định kỳ vào đầu năm học thông qua Cổng thanh toán trực tuyến. Sinh viên có thẻ BHYT diện hộ nghèo, thân nhân quân nhân phải nộp bản photo minh chứng để được miễn giảm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đóng lệ phí thi lại và về phí phạt nợ học phí quá hạn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 107, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(21, 21, 0, 'FAQ #21 - Sinh Viên 5 Tốt', 'Danh hiệu Sinh viên 5 Tốt được xét duyệt hàng năm dựa trên 5 tiêu chí: Học tập tốt (GPA >= 3.2 hoặc 2.8 tùy hệ), Đạo đức tốt (ĐRL >= 80), Thể lực tốt (đạt danh hiệu khỏe), Tình nguyện tốt (tham gia chiến dịch lớn), và Hội nhập tốt (đạt giải thưởng khoa học hoặc kỹ năng ngoại ngữ tốt). Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về khen thưởng sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', 102, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(22, 22, 0, 'FAQ #22 - Nghiên Cứu Khoa Học', 'Phong trào Nghiên cứu khoa học (NCKH) sinh viên UTH được phát động vào đầu học kỳ 1. Sinh viên đăng ký đề tài theo nhóm (dưới sự hướng dẫn của giảng viên) thông qua Phòng Quản lý khoa học. Đề tài nghiệm thu đạt loại Khá trở lên sẽ được cộng điểm rèn luyện và thưởng tiền mặt. Bên cạnh đó, nếu bạn cũng quan tâm về đại hội đoàn, hay về giải bóng đá UTH, cứ hỏi mình thêm nha.', 94, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(23, 23, 0, 'FAQ #23 - Rút Học Phần, Hủy Môn', 'Trong 2 tuần đầu của học kỳ chính (hoặc 1 tuần đối với học kỳ hè), sinh viên được phép nộp đơn online để xin rút bớt học phần đã đăng ký. Học phần xin rút thành công sẽ ghi nhận điểm chữ W trên bảng điểm, không tính vào điểm trung bình tích lũy nhưng sinh viên không được hoàn lại học phí. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy chế thi cử và về quy trình chấm điểm rèn luyện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 109, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(24, 24, 0, 'FAQ #24 - Phòng Công Tác Sinh Viên', 'Phòng Công tác sinh viên (CTSV) chịu trách nhiệm giải quyết các thủ tục: Cấp giấy xác nhận sinh viên để vay vốn ngân hàng, tạm hoãn nghĩa vụ quân sự, đánh giá điểm rèn luyện, giải quyết chế độ chính sách, miễn giảm học phí. Văn phòng đặt tại tầng trệt nhà A cơ sở chính. Ngoài ra, nếu bạn còn thắc mắc về minh chứng ĐRL hoặc về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, mình có thể hỗ trợ giải đáp thêm nhé.', 106, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(25, 25, 0, 'FAQ #25 - Phòng Đào Tạo', 'Phòng Đào tạo UTH là nơi giải quyết các vấn đề chuyên môn về: Khung lịch học, lịch thi, giải quyết đơn phúc khảo điểm thi, cấp bảng điểm chính thức, xử lý hồ sơ chuyển ngành, ngừng học tạm thời, bảo lưu kết quả, và xét công nhận tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về các tuyến xe buýt, hay về đại hội đoàn, cứ hỏi mình thêm nha.', 85, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(26, 26, 0, 'FAQ #26 - Ký Túc Xá Quận 12', 'Cơ sở 2 của UTH tại Quận 12 có khu Ký túc xá khang trang dành riêng cho sinh viên học tập tại đây. Chi phí nội trú dao động từ 150.000đ - 250.000đ/tháng/sinh viên tùy loại phòng. Sinh viên nộp đơn đăng ký trực tiếp tại Ban quản lý KTX Cơ sở 2. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về ký túc xá trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(27, 27, 0, 'FAQ #27 - Học Bổng Doanh Nghiệp', 'Ngoài học bổng khuyến khích của trường, sinh viên UTH còn có cơ hội nhận Học bổng tài trợ từ các tập đoàn, doanh nghiệp lớn đối tác (như các tổng công ty xây dựng, cảng biển, công ty công nghệ). Tiêu chí xét tuyển thường ưu tiên sinh viên nghèo vượt khó học giỏi hoặc có thành tích xuất sắc. Ngoài ra, nếu bạn còn thắc mắc về giải chạy sinh viên hoặc về học bổng liên kết, mình có thể hỗ trợ giải đáp thêm nhé.', 103, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(28, 28, 0, 'FAQ #28 - Các Tuyến Xe Buýt', 'Cơ sở chính Võ Oanh (Bình Thạnh) có rất nhiều tuyến xe buýt đi qua như tuyến số 08, 14, 19, 43, 44, 93 (dừng tại trạm Điện Biên Phủ hoặc Nguyễn Văn Thương rồi đi bộ vào). Sinh viên được hưởng giá vé ưu đãi khi xuất trình Thẻ sinh viên UTH. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về thời gian giữ xe tối đa tại trường, cứ hỏi mình thêm nha.', 90, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(29, 29, 0, 'FAQ #29 - Thủ Tục Chuyển Ngành', 'Sinh viên được xem xét chuyển ngành nếu: Không thuộc diện bị buộc thôi học; Điểm xét tuyển đầu vào không thấp hơn điểm trúng tuyển của ngành muốn chuyển sang; Có đơn xin chuyển ngành và được sự đồng ý của cả hai Khoa chủ quản. Thủ tục làm tại Phòng Đào tạo vào cuối năm học thứ nhất. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký môn học và về cảnh báo học vụ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 104, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(30, 30, 0, 'FAQ #30 - Bảo Lưu Kết Quả', 'Sinh viên được xin nghỉ học tạm thời và bảo lưu kết quả học tập vì lý do cá nhân (như sức khỏe, hoàn cảnh gia đình hoặc thực hiện nghĩa vụ quân sự). Thời gian tạm dừng học không quá 2 học kỳ chính và phải làm đơn nộp về Phòng Đào tạo trước khi học kỳ mới bắt đầu. Ngoài ra, nếu bạn còn thắc mắc về đăng ký môn học hoặc về quy định số lần cảnh báo học vụ, mình có thể hỗ trợ giải đáp thêm nhé.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(31, 31, 0, 'FAQ #31 - Phúc Khảo Điểm Thi', 'Nếu thấy điểm thi kết thúc học phần không chính xác, sinh viên có quyền làm Đơn xin phúc khảo bài thi nộp về Phòng Đào tạo hoặc văn phòng Khoa trong vòng 5 ngày làm việc kể từ ngày công bố điểm. Lệ phí phúc khảo theo quy định hiện hành của trường. Bên cạnh đó, nếu bạn cũng quan tâm về quy định số lần cảnh báo học vụ, hay về thủ tục chuyển ngành, cứ hỏi mình thêm nha.', 93, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(32, 32, 0, 'FAQ #32 - Đồng Phục & Trang Phục', 'Sinh viên khi đến trường UTH phải ăn mặc lịch sự, gọn gàng, không mặc quần đùi, áo ba lỗ, dép lê vào lớp. Nhà trường khuyến khích sinh viên mặc Áo thun đồng phục UTH hoặc áo sơ mi trắng vào các ngày lễ, các buổi sinh hoạt chung và các ngày cố định theo quy định của Khoa. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký cấp lại tài khoản email sinh viên và về phòng đào tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 107, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(33, 33, 0, 'FAQ #33 - Kỷ Luật Học Đường', 'Sinh viên vi phạm quy chế thi cử (như mang tài liệu, điện thoại vào phòng thi, quay cóp) sẽ bị xử lý kỷ luật nghiêm khắc từ Đình chỉ thi môn đó, Nhận điểm 0, Cảnh cáo trước toàn trường, cho đến đình chỉ học tập có thời hạn hoặc buộc thôi học nếu tái phạm nhiều lần. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', 104, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(34, 34, 0, 'FAQ #34 - Văn Phòng Khoa CNTT', 'Văn phòng Khoa Công nghệ thông tin UTH chịu trách nhiệm quản lý chuyên môn ngành CNTT và Khoa học dữ liệu. Văn phòng khoa hỗ trợ sinh viên các vấn đề về: Đăng ký đồ án tốt nghiệp, thực tập doanh nghiệp, cố vấn học tập. Địa chỉ liên hệ đặt tại Khu nhà C, Cơ sở chính. Bên cạnh đó, nếu bạn cũng quan tâm về đồng phục & trang phục, hay về đại hội đoàn, cứ hỏi mình thêm nha.', 93, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(35, 35, 0, 'FAQ #35 - Văn Phòng Khoa Viện', 'Các văn phòng Khoa chuyên ngành (như Viện Logistics và Quản lý chuỗi cung ứng, Khoa Kinh tế vận tải, Khoa Công trình giao thông, Khoa Điện - Điện tử viễn thông) đều có văn phòng trực ban tại các khu nhà chức năng cơ sở chính để hỗ trợ giải quyết lịch học chuyên ngành cho sinh viên. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian giữ xe tối đa tại trường và về bãi giữ xe của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 110, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(36, 36, 0, 'FAQ #36 - Giáo Dục Quốc Phòng', 'Sinh viên UTH tham gia học môn Giáo dục quốc phòng - An ninh tập trung tại Trung tâm Giáo dục Quốc phòng theo lịch phân bổ của trường. Sinh viên được rèn luyện trong môi trường quân đội nội trú, phải tuân thủ nghiêm ngặt giờ giấc, tác phong quân kỷ và mặc quân phục. Ngoài ra, nếu bạn còn thắc mắc về giáo dục thể chất hoặc về thủ tục xin miễn học thể dục, mình có thể hỗ trợ giải đáp thêm nhé.', 99, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(37, 37, 0, 'FAQ #37 - Giáo Dục Thể Chất', 'Môn Giáo dục thể chất (Thể dục) tại UTH rất đa dạng, sinh viên được tự chọn đăng ký các môn thể thao yêu thích trên Portal như: Bóng đá, Bóng chuyền, Bóng rổ, Cầu lông, Cờ vua hoặc Võ thuật. Sinh viên phải thi đạt môn này mới đủ điều kiện xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về cấp lại giấy chứng nhận quốc phòng, hay về thủ tục xin miễn học thể dục, cứ hỏi mình thêm nha.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(38, 38, 0, 'FAQ #38 - Cấp Lại Bảng Điểm', 'Sinh viên cần bảng điểm chính thức (có mộc đỏ của trường) để xin việc làm hoặc nộp hồ sơ học bổng phải làm Đơn xin cấp bảng điểm tại máy tự động hoặc nộp trực tiếp tại Phòng Đào tạo. Lệ phí in bảng điểm được tính theo số lượng bản sao quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(39, 39, 0, 'FAQ #39 - Phạt Tiền Thư Viện', 'Sinh viên mượn tài liệu thư viện UTH nếu làm mất hoặc hư hỏng phải mua đền cuốn sách mới tương đương hoặc đền tiền gấp nhiều lần giá trị cuốn sách theo quy chế. Trả sách trễ hạn sẽ bị phạt số tiền tính theo từng ngày trễ hạn và bị tạm khóa thẻ thư viện. Ngoài ra, nếu bạn còn thắc mắc về mượn sách thư viện hoặc về mất thẻ sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', 93, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(40, 40, 0, 'FAQ #40 - Nguyện Vọng Bổ Sung', 'Trong trường hợp các ngành học chưa tuyển đủ chỉ tiêu đợt 1, Hội đồng tuyển sinh UTH sẽ thông báo nhận hồ sơ Xét tuyển nguyện vọng bổ sung (Đợt 2) trên trang tuyển sinh chính thức của trường. Thí sinh nộp hồ sơ theo phương thức xét điểm thi tốt nghiệp THPT hoặc học bạ. Bên cạnh đó, nếu bạn cũng quan tâm về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', 112, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(41, 41, 0, 'FAQ #41 - Bảng Điểm Tiếng Anh', 'Sinh viên có nhu cầu cấp bảng điểm bằng tiếng Anh (hoặc song ngữ) để làm hồ sơ du học, săn học bổng quốc tế hoặc nộp cho doanh nghiệp nước ngoài thì làm đơn đăng ký tại Phòng Đào tạo. Thời gian xử lý và cấp phát từ 3 đến 5 ngày làm việc kèm theo lệ phí in ấn quy định. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời hạn sử dụng của thẻ thư viện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 109, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(42, 42, 0, 'FAQ #42 - Phúc Khảo Đồ Án', 'Theo quy chế học vụ UTH, điểm bảo vệ Đồ án tốt nghiệp hoặc Khóa luận tốt nghiệp sẽ KHÔNG được chấm phúc khảo. Điểm số cuối cùng do Hội đồng chấm tốt nghiệp quyết định ngay tại buổi bảo vệ công khai. Sinh viên chỉ được quyền khiếu nại nếu có sai sót trong quá trình cộng điểm hoặc nhập điểm vào hệ thống. Ngoài ra, nếu bạn còn thắc mắc về quy chế thi cử hoặc về xét giảm điểm rèn luyện, mình có thể hỗ trợ giải đáp thêm nhé.', 106, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(43, 43, 0, 'FAQ #43 - Khóa Tài Khoản Portal', 'Tài khoản Portal của sinh viên UTH thường bị khóa vì các lý do sau: Nợ học phí quá hạn quy định; Chưa hoàn thành các khảo sát bắt buộc của trường; Hoặc nhập sai mật khẩu quá 5 lần liên tiếp. Sinh viên cần liên hệ Phòng Đào tạo hoặc Phòng Công tác sinh viên để kiểm tra lý do và mở khóa. Bên cạnh đó, nếu bạn cũng quan tâm về tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường, hay về hủy tư cách đoàn viên, cứ hỏi mình thêm nha.', 108, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(44, 44, 0, 'FAQ #44 - Bãi Giữ Xe Của Trường', 'UTH có bãi giữ xe dành cho sinh viên tại tất cả các cơ sở. Giá vé gửi xe máy áp dụng theo đúng quy định nhà nước. Sinh viên tuyệt đối không được gửi xe qua đêm tại trường trừ các trường hợp đặc biệt được Đoàn trường hoặc Ban quản lý cơ sở cấp phép trước bằng văn bản. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về liên hệ ban quản lý ký túc xá và về quy định sử dụng mạng wifi nội bộ của trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 111, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(45, 45, 0, 'FAQ #45 - Miễn Giảm Anh Em Ruột', 'Nhà trường áp dụng chính sách hỗ trợ học phí cho gia đình có từ 2 anh/chị/em ruột trở lên đang cùng theo học hệ chính quy tại UTH. Mức giảm thường là 10% đến 20% học phí cho người em. Sinh viên cần nộp Giấy khai sinh bản sao và Đơn đề nghị về Phòng Công tác sinh viên đầu học kỳ. Ngoài ra, nếu bạn còn thắc mắc về gia hạn học phí hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(46, 46, 0, 'FAQ #46 - Đổi Lịch Thi Học Kỳ', 'Trường hợp sinh viên bị trùng lịch thi 2 môn trong cùng 1 ca hoặc có lý do bất khả kháng (tai nạn, nằm viện), sinh viên phải mang minh chứng đến Phòng Đào tạo trước ngày thi ít nhất 3 ngày để làm đơn xin chuyển ca thi hoặc đăng ký thi ghép vào đợt thi của lớp khác. Bên cạnh đó, nếu bạn cũng quan tâm về bảo lưu kết quả, hay về quy định số lần cảnh báo học vụ, cứ hỏi mình thêm nha.', 96, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(47, 47, 0, 'FAQ #47 - Quên Mật Khẩu Portal', 'Nếu quên mật khẩu đăng nhập hệ thống Portal, sinh viên bấm vào nút \"Quên mật khẩu\" trên giao diện đăng nhập để nhận mã khôi phục qua Email sinh viên (@ut.edu.vn). Nếu không làm được, sinh viên mang Thẻ sinh viên đến trực tiếp Phòng Đào tạo để được cấp lại mật khẩu mới. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về khóa tài khoản Portal và về đăng ký cấp lại tài khoản email sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 109, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(48, 48, 0, 'FAQ #48 - Phòng Y Tế Trường', 'Phòng Y tế UTH nằm tại khu vực tầng trệt cơ sở chính. Đây là nơi tiếp nhận, sơ cứu và cấp phát thuốc cơ bản miễn phí cho sinh viên khi gặp các vấn đề về sức khỏe trong quá trình học tập tại trường. Đồng thời là nơi tổ chức khám sức khỏe định kỳ bắt buộc cho tân sinh viên. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định sử dụng mạng wifi nội bộ của trường, mình có thể hỗ trợ giải đáp thêm nhé.', 106, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(49, 49, 0, 'FAQ #49 - Học Bổng Liên Kết', 'UTH liên kết với nhiều trường Đại học lớn tại Hàn Quốc, Nhật Bản, Hà Lan, Anh Quốc để triển khai các chương trình trao đổi sinh viên và học bổng du học hệ 2+2 hoặc 3+1. Sinh viên có học lực Giỏi và đạt chuẩn tiếng Anh (IELTS/TOEFL) cao sẽ được xét duyệt hồ sơ tham gia. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng khuyến khích, hay về hoạt động đoàn hội, cứ hỏi mình thêm nha.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(50, 50, 0, 'FAQ #50 - Sinh Hoạt Công Dân', 'Tuần sinh hoạt công dân - học sinh sinh viên được tổ chức bắt buộc vào đầu mỗi năm học. Sinh viên phải tham gia đầy đủ và làm bài kiểm tra thu hoạch đạt yêu cầu. Vắng mặt không lý do sẽ bị trừ điểm rèn luyện nghiêm khắc và xét kỷ luật tùy mức độ. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về học bổng khuyến khích — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(51, 51, 0, 'FAQ #51 - Chuyển Cơ Sở Học Tập', 'Việc phân bổ cơ sở học tập (Bình Thạnh hoặc Quận 12) phụ thuộc hoàn toàn vào chuyên ngành và kế hoạch đào tạo của từng Khoa/Viện. Sinh viên KHÔNG được tự ý xin chuyển cơ sở học tập cá nhân trừ khi có sự điều chỉnh quy hoạch lớp học từ phía Ban giám hiệu nhà trường. Ngoài ra, nếu bạn còn thắc mắc về chương trình đào tạo hoặc về xin hoãn đi thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(52, 52, 0, 'FAQ #52 - Mượn Phòng Học', 'Các Ban cán sự lớp hoặc Câu lạc bộ muốn mượn phòng học, giảng đường hoặc Hội trường để tổ chức sinh hoạt, họp hành, tập văn nghệ phải làm Đơn xin mượn phòng (có xác nhận của Bí thư Đoàn trường hoặc Trưởng Khoa) nộp về Phòng Quản trị thiết bị trước ít nhất 2 ngày. Bên cạnh đó, nếu bạn cũng quan tâm về thời hạn sử dụng của thẻ thư viện, hay về khóa tài khoản Portal, cứ hỏi mình thêm nha.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(53, 53, 0, 'FAQ #53 - Hỗ Trợ Khởi Nghiệp', 'Nhà trường thường xuyên tổ chức các cuộc thi Ý tưởng khởi nghiệp sáng tạo sinh viên UTH. Các dự án tiềm năng và đạt giải cao sẽ được Câu lạc bộ Khởi nghiệp của trường hỗ trợ không gian làm việc, kết nối với các quỹ đầu tư và cố vấn chuyên môn để phát triển thành dự án thực tế. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh viên 5 tốt và về khen thưởng sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 104, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(54, 54, 0, 'FAQ #54 - Giấy Chứng Nhận Tạm Thời', 'Để phục vụ các nhu cầu cấp bách (như làm hồ sơ xin việc, chứng minh thông tin khi chưa có thẻ nhựa), sinh viên đăng ký xin cấp Giấy chứng nhận sinh viên tạm thời tại văn phòng Phòng Công tác sinh viên. Giấy xác nhận này có mộc đỏ và giá trị pháp lý ngắn hạn. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về quên mật khẩu Portal, mình có thể hỗ trợ giải đáp thêm nhé.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(55, 55, 0, 'FAQ #55 - Văn Phòng Đoàn Thanh Niên', 'Văn phòng Đoàn Thanh niên - Hội Sinh viên UTH đặt tại cơ sở chính Võ Oanh. Đây là nơi quản lý toàn bộ hồ sơ đoàn viên, tiếp nhận sổ Đoàn của sinh viên đầu năm học, xét duyệt các danh hiệu thi đua, cộng điểm rèn luyện và tổ chức các chiến dịch lớn như Mùa hè xanh, Tiếp sức mùa thi. Bên cạnh đó, nếu bạn cũng quan tâm về sinh hoạt công dân, hay về mượn thiết bị âm thanh, sự kiện, cứ hỏi mình thêm nha.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(56, 56, 0, 'FAQ #56 - Khảo Sát Ý Kiến Sinh Viên', 'Cuối mỗi học kỳ, UTH bắt buộc sinh viên phải tham gia Khảo sát ý kiến về hoạt động giảng dạy của giảng viên trực tuyến trên trang Portal. Sinh viên cố tình không hoàn thành khảo sát đúng hạn sẽ bị tạm khóa chức năng xem điểm thi học kỳ và khóa lịch đăng ký môn học. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về hoạt động đoàn hội và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(57, 57, 0, 'FAQ #57 - Đóng Lệ Phí Thi Lại', 'Đối với các môn học bị điểm F, sinh viên áp dụng quy chế học chế tín chỉ của UTH là phải đăng ký học lại và đóng tiền học phí tính theo số tín chỉ môn đó giống như học mới, trường KHÔNG tổ chức kỳ thi lại độc lập thu phí riêng như hệ niên chế cũ. Ngoài ra, nếu bạn còn thắc mắc về lệ phí xét tuyển hồ sơ đầu vào hoặc về miễn giảm anh em ruột, mình có thể hỗ trợ giải đáp thêm nhé.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(58, 58, 0, 'FAQ #58 - Thực Tập Tốt Nghiệp', 'Sinh viên năm cuối đủ điều kiện sẽ tham gia học phần Thực tập tốt nghiệp. Sinh viên đến văn phòng Khoa/Viện chủ quản để nhận Giấy giới thiệu thực tập nộp cho doanh nghiệp. Sau khi kết thúc, phải nộp lại Báo cáo thực tập có nhận xét và mộc tròn của công ty. Bên cạnh đó, nếu bạn cũng quan tâm về quy định tham quan kiến tập thực tế tại doanh nghiệp, hay về thời gian nhận bằng tốt nghiệp, cứ hỏi mình thêm nha.', 103, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(59, 59, 0, 'FAQ #59 - Đồ Án Tốt Nghiệp', 'Điều kiện để sinh viên UTH được giao đề tài làm Đồ án/Khóa luận tốt nghiệp: Tính đến học kỳ xét, sinh viên không bị cảnh báo học vụ; Tích lũy tối thiểu 80% đến 90% số tín chỉ toàn khóa; Điểm trung bình GPA đạt mức quy định riêng của từng Khoa/Viện chuyên ngành. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đồ án tốt nghiệp đạt điểm f xử lý sao và về quy trình làm thủ tục nhập học trực tiếp tại trường — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 113, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(60, 60, 0, 'FAQ #60 - Khen Thưởng Sinh Viên', 'Kết thúc mỗi năm học, nhà trường tiến hành xét khen thưởng cho sinh viên đạt danh hiệu Sinh viên Xuất sắc (GPA >= 3.6/4.0) và Sinh viên Giỏi (GPA >= 3.2/4.0) kèm theo điểm rèn luyện loại Tốt trở lên. Sinh viên được tặng giấy khen của Hiệu trưởng và nhận tiền thưởng tương ứng. Ngoài ra, nếu bạn còn thắc mắc về đăng ký tham gia câu lạc bộ hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', 85, NULL, NULL, NULL, '32c4c48e43cd8454dccf113de925ac35169409c39ca63ce43bfb8cb1f1e3cd63', '2026-07-11 16:34:11', '2026-07-23 13:35:11'),
(61, 61, 0, 'FAQ #61 - Mùa Hè Xanh UTH', 'Chiến dịch tình nguyện Mùa Hè Xanh UTH do Đoàn trường tổ chức vào tháng 7 hằng năm. Sinh viên đăng ký qua form chính thức của Đoàn Khoa/Viện. Tiêu chí tuyển chọn dựa trên sức khỏe, đạo đức tốt và tích cực tham gia phong trào. Hoàn thành chiến dịch được cộng tối đa 15-20 điểm rèn luyện. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', 82, NULL, NULL, NULL, '5a29e04861dbb42e4cf94a910eb848b007d16799647ef454c79d453eec288e8c', '2026-07-11 16:34:11', '2026-07-23 13:35:21'),
(62, 62, 0, 'FAQ #62 - Tiếp Sức Mùa Thi', 'Chương trình Tiếp sức mùa thi diễn ra vào tháng 6 hằng năm nhằm hỗ trợ thí sinh thi THPT Quốc tế. Sinh viên UTH đăng ký tham gia thông qua Hội Sinh viên trường. Chiến sĩ TSMT sẽ trực tại các điểm trường thi để phân luồng giao thông, hỗ trợ nước uống và chỉ đường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng đoàn thanh niên và về các câu lạc bộ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(63, 63, 0, 'FAQ #63 - Xuân Tình Nguyện', 'Chiến dịch Xuân Tình Nguyện UTH diễn ra vào dịp cận Tết Nguyên Đán. Các đội hình sẽ thực hiện hoạt động gói bánh chưng, tặng quà cho trẻ em cơ nhỡ, người già neo đơn và dọn dẹp nghĩa trang liệt sĩ. Sinh viên đăng ký qua Fanpage Đoàn - Hội của Khoa/Viện. Ngoài ra, nếu bạn còn thắc mắc về sinh viên 5 tốt hoặc về mượn thiết bị âm thanh, sự kiện, mình có thể hỗ trợ giải đáp thêm nhé.', 96, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(64, 64, 0, 'FAQ #64 - Giải Chạy Sinh Viên', 'UTH thường xuyên tổ chức hoặc liên kết các giải chạy bộ (Marathon trực tuyến/trực tiếp qua app Strava). Sinh viên hoàn thành cự ly quy định (thường là 21km hoặc 42km tích lũy) sẽ đạt tiêu chí \"Thể lực tốt\" phục vụ xét danh hiệu Sinh viên 5 Tốt và được cộng ĐRL. Bên cạnh đó, nếu bạn cũng quan tâm về khen thưởng sinh viên, hay về đăng ký tham gia hiến máu đợt hè, cứ hỏi mình thêm nha.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(65, 65, 0, 'FAQ #65 - Ngày Hội Sáng Tạo', 'Ngày hội Sáng tạo trẻ UTH là sân chơi khoa học công nghệ, trưng bày các mô hình, phần mềm độc đáo do sinh viên tự nghiên cứu (robot, mô hình cầu đường, app quản lý vận tải). Đề tài đạt giải cao sẽ được hỗ trợ kinh phí tham gia các cuộc thi cấp Thành phố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chiến sĩ tình nguyện và về hủy tư cách đoàn viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(66, 66, 0, 'FAQ #66 - Chiến Sĩ Tình Nguyện', 'Kết thúc mỗi chiến dịch tình nguyện (MHX, XTN, TSMT), Ban chỉ huy chiến dịch sẽ tổ chức họp xét để tuyên dương các cá nhân có đóng góp xuất sắc. Chiến sĩ đạt danh hiệu sẽ được tặng Giấy khen của Hiệu trưởng hoặc Ủy ban Hội Sinh viên Thành phố. Ngoài ra, nếu bạn còn thắc mắc về tiếp sức mùa thi hoặc về đăng ký tham gia câu lạc bộ, mình có thể hỗ trợ giải đáp thêm nhé.', 93, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(67, 67, 0, 'FAQ #67 - Đại Hội Đoàn - Hội', 'Đại hội Đại biểu Đoàn TNCS Hồ Chí Minh và Đại hội Hội Sinh viên Việt Nam trường UTH được tổ chức định kỳ để bầu ra Ban chấp hành mới. Sinh viên là Đại biểu chính thức sẽ tham gia họp và bỏ phiếu tại Hội trường lớn cơ sở chính Võ Oanh. Bên cạnh đó, nếu bạn cũng quan tâm về học bổng liên kết, hay về văn phòng khoa CNTT, cứ hỏi mình thêm nha.', 86, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(68, 68, 0, 'FAQ #68 - Cắm Trại Truyền Thống', 'Hội trại truyền thống UTH thường được tổ chức nhân dịp kỷ niệm ngày thành lập Đoàn 26/03 hoặc ngày truyền thống trường. Địa điểm tổ chức có thể tại sân trường cơ sở Quận 12 hoặc các khu du lịch dã ngoại. Hội trại gồm các hoạt động dựng trại, trò chơi lớn và đêm lửa trại. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về các câu lạc bộ và về chiến sĩ đỏ — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(69, 69, 0, 'FAQ #69 - Giải Bóng Đá UTH', 'Giải bóng đá truyền thống sinh viên UTH tổ chức hằng năm tại sân bóng cỏ nhân tạo. Các đội bóng tham gia tranh tài theo đơn vị lớp hoặc Liên quân Khoa/Viện. Lịch thi đấu và thể lệ được Ban thể thao thuộc Hội sinh viên trường công bố công khai đầu học kỳ 2. Ngoài ra, nếu bạn còn thắc mắc về hoạt động \"hiến máu tình nguyện\" lần 2 trong năm hoặc về tham gia hiến máu có được nghỉ học, mình có thể hỗ trợ giải đáp thêm nhé.', 106, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(70, 70, 0, 'FAQ #70 - Văn Nghệ Tiếng Hát', 'Cuộc thi văn nghệ truyền thống (Tiếng hát sinh viên UTH) là nơi tìm kiếm các tài năng âm nhạc, nhạc cụ, nhảy hiện đại, múa dân gian. Sinh viên đăng ký tiết mục đơn ca, song ca hoặc tốp ca trực tiếp với Đội văn nghệ xung kích của trường để tham gia vòng sơ loại. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách học bổng tuyển sinh, hay về hội thảo kỹ năng, cứ hỏi mình thêm nha.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(71, 71, 0, 'FAQ #71 - Chiến Sĩ Đỏ - Hiến Máu', 'Câu lạc bộ Hành Trình Đỏ / Đội Tình nguyện Hiến máu UTH là đơn vị nòng cốt phối hợp với Trung tâm hiến máu nhân đạo TP.HCM để tổ chức các đợt hiến máu tại trường. Thành viên đội sẽ hỗ trợ điều phối, hướng dẫn sinh viên điền form và chăm sóc sinh viên sau hiến máu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giải chạy sinh viên và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(72, 72, 0, 'FAQ #72 - Minh Chứng ĐRL', 'Khi tham gia các hoạt động bên ngoài trường (Hiến máu, Tình nguyện hè, Giải chạy), sinh viên phải giữ lại Giấy chứng nhận bản cứng hoặc chụp màn hình kết quả. Sau đó, đăng nhập hệ thống Portal nộp minh chứng đúng thời hạn quy định để Lớp trưởng xét cộng ĐRL. Ngoài ra, nếu bạn còn thắc mắc về bảng điểm tiếng anh hoặc về cấp lại bảng điểm, mình có thể hỗ trợ giải đáp thêm nhé.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(73, 73, 0, 'FAQ #73 - Điểm Rèn Luyện F', 'Sinh viên có điểm rèn luyện xếp loại Yếu (dưới 50 điểm) hoặc Kém (dưới 35 điểm) trong một năm học sẽ bị đưa vào danh sách kỷ luật cảnh cáo. Nếu bị xếp loại yếu, kém 2 học kỳ liên tiếp sẽ bị đình chỉ học tập 1 học kỳ; nếu bị lần thứ 3 sẽ bị buộc thôi học. Bên cạnh đó, nếu bạn cũng quan tâm về quy chế thi cử, hay về đăng ký môn học, cứ hỏi mình thêm nha.', 89, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(74, 74, 0, 'FAQ #74 - Ngày Hội Việc Làm', 'Ngày hội việc làm UTH Job Fair diễn ra định kỳ hằng năm tại sân trường cơ sở chính. Hoạt động này thu hút hàng chục doanh nghiệp lớn đến phỏng vấn tuyển dụng trực tiếp, nhận hồ sơ thực tập. Tất cả sinh viên các năm đều được tham gia tự do để tìm kiếm cơ hội. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách học bổng tuyển sinh và về đại hội đoàn — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(75, 75, 0, 'FAQ #75 - Hội Thảo Kỹ Năng', 'Phòng Công tác sinh viên phối hợp với các chuyên gia tổ chức các buổi Hội thảo kỹ năng mềm (Kỹ năng viết CV, kỹ năng giao tiếp, quản lý thời gian). Sinh viên quét mã QR điểm danh tại hội trường sẽ được tự động cộng 2-3 điểm rèn luyện vào hệ thống Portal. Ngoài ra, nếu bạn còn thắc mắc về ngày hội việc làm hoặc về văn phòng đoàn thanh niên, mình có thể hỗ trợ giải đáp thêm nhé.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(76, 76, 0, 'FAQ #76 - Học phí chương trình tiên tiến (trước đây gọi là Chất lượng cao - CLC)', 'UTH hiện gọi chương trình Chất lượng cao trước đây là \"Chương trình tiên tiến\". Mức học phí chương trình tiên tiến áp dụng cho tân sinh viên khóa 2026 là 1.120.000đ/tín chỉ (khóa 2025 áp dụng mức 980.000đ/tín chỉ). Với chương trình đào tạo chuẩn hóa 120 tín chỉ toàn khóa, tổng học phí chương trình tiên tiến trọn khóa (học đúng tiến độ, chưa gồm các khoản phí khác) theo mức khóa 2026 vào khoảng 134 triệu đồng. Mức phí chương trình tiên tiến cao hơn chương trình chuẩn do quy mô lớp nhỏ, tăng cường thời lượng tiếng Anh chuyên ngành, cơ sở vật chất hiện đại và có các học phần trải nghiệm/kiến tập tại doanh nghiệp. Mỗi khóa nhập học có mức học phí niêm yết riêng và trường cam kết không tăng học phí trong 3 năm đầu tính từ năm nhập học. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về chính sách hỗ trợ bảo hiểm tai nạn, cứ hỏi mình thêm nha.', 217, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(77, 77, 0, 'FAQ #77 - Quy trình chấm Điểm rèn luyện (ĐRL) hằng kỳ', 'Quy trình chấm Điểm rèn luyện hằng kỳ tại UTH được thực hiện qua 3 bước bắt buộc: - Sinh viên đăng nhập hệ thống Portal tự đánh giá điểm cá nhân theo các mục quy định. - Tập thể lớp tổ chức họp dưới sự chủ trì của Ban cán sự lớp để thông qua và chấm điểm cho từng sinh viên. - Cố vấn học tập (Giảng viên chủ nhiệm) phê duyệt và gửi danh sách chính thức về Phòng Công tác sinh viên để lưu hệ thống. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về cảnh báo học vụ và về thủ tục phúc khảo điểm quá trình — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 137, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(78, 78, 0, 'FAQ #78 - Thẻ bảo hiểm y tế điện tử (VssID)', 'Nhà trường không cấp thẻ Bảo hiểm y tế (BHYT) bằng giấy vật lý cho sinh viên nữa. Sau khi đóng lệ phí gia hạn BHYT thành công trên cổng thanh toán của trường, sinh viên tải ứng dụng VssID (Bảo hiểm xã hội số) trên điện thoại và đăng ký tài khoản bằng mã số bảo hiểm của mình để sử dụng thẻ BHYT điện tử khi đi khám chữa bệnh tại các bệnh viện. Ngoài ra, nếu bạn còn thắc mắc về chính sách hỗ trợ bảo hiểm tai nạn hoặc về bảo hiểm y tế, mình có thể hỗ trợ giải đáp thêm nhé.', 119, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(79, 79, 0, 'FAQ #79 - Chuẩn tin học quốc tế nâng cao', 'UTH công nhận cả hai chứng chỉ quốc tế là MOS và IC3 để xét đạt chuẩn đầu ra Tin học. Đối với chứng chỉ MOS, sinh viên phải đạt từ 3 kỹ năng độc lập trở lên (gồm Word, Excel và Powerpoint). Đối với chứng chỉ IC3, sinh viên phải thi đạt cả 3 phần (Living Online, Key Applications, và Computing Fundamentals). Sinh viên mang chứng chỉ gốc đến Phòng Đào tạo để làm thủ tục hậu kiểm công nhận quy đổi. Bên cạnh đó, nếu bạn cũng quan tâm về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH, hay về đăng ký thi lại chuẩn đầu ra, cứ hỏi mình thêm nha.', 140, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(80, 80, 0, 'FAQ #80 - Quy định sử dụng mạng Wifi nội bộ của trường', 'Nhà trường cấp hệ thống mạng Wifi miễn phí tại tất cả các khu vực giảng đường, thư viện và sân trường cho sinh viên. Để kết nối, sinh viên chọn mạng Wifi dành riêng cho người học, sau đó đăng nhập bằng Mã số sinh viên (Username) và Mật khẩu Portal cá nhân của mình. Hệ thống sẽ tự động chặn các truy cập vào trang web độc hại hoặc tải tài liệu lậu dung lượng quá lớn làm nghẽn băng thông. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về văn phòng khoa viện và về liên hệ ban quản lý ký túc xá — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 135, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(81, 81, 0, 'FAQ #81 - Đăng ký tham gia Câu lạc bộ (CLB) đầu năm học', 'Vào khoảng tháng 9 và tháng 10 hằng năm (đầu học kỳ 1), Hội Sinh viên trường UTH tổ chức Ngày hội các Câu lạc bộ (CLB Festival) tại sân trường cơ sở chính. Tại đây, tất cả các CLB (Học thuật, Nghệ thuật, Thể thao, Tình nguyện) sẽ đặt gian hàng giới thiệu và phát đơn tuyển thành viên mới trực tiếp hoặc trực tuyến qua các trang Fanpage chính thức của mình. Ngoài ra, nếu bạn còn thắc mắc về văn phòng đoàn thanh niên hoặc về sinh viên 5 tốt, mình có thể hỗ trợ giải đáp thêm nhé.', 120, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(82, 82, 0, 'FAQ #82 - Đăng ký cấp lại tài khoản Email sinh viên (@ut.edu.vn)', 'Email sinh viên định dạng [MSSV]@ut.edu.vn được nhà trường cấp miễn phí cho toàn bộ người học để liên lạc và nhận các thông báo quan trọng. Nếu bị khóa tài khoản hoặc quên mật khẩu email, sinh viên mang Thẻ sinh viên đến trực tiếp văn phòng Trung tâm Dữ liệu và Công nghệ thông tin của trường tại khu nhà chức năng cơ sở chính để được hỗ trợ reset cấp lại mật khẩu ngay trong ngày. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về quên mật khẩu Portal, cứ hỏi mình thêm nha.', 122, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(83, 83, 0, 'FAQ #83 - Hoạt động \"Hiến máu tình nguyện\" lần 2 trong năm', 'Nhằm đáp ứng nhu cầu cung cấp máu cứu người, Đoàn trường và Hội sinh viên UTH phối hợp tổ chức hoạt động hiến máu nhân đạo định kỳ 2 lần trong một năm học (thường rơi vào Học kỳ 1 và Học kỳ 2). Lịch chi tiết của từng đợt sẽ được đăng tải sớm trên trang Portal trước 1 tuần để sinh viên đăng ký tham gia và nhận quyền lợi cộng điểm rèn luyện. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về mượn thiết bị âm thanh, sự kiện — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 123, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(84, 84, 0, 'FAQ #84 - Chế độ miễn giảm học phí cho con em diện chính sách', 'Sinh viên thuộc diện con thương binh, bệnh binh, người có công với cách mạng, sinh viên dân tộc thiểu số vùng đặc biệt khó khăn, hoặc sinh viên thuộc hộ nghèo/hộ cận nghèo sẽ được hưởng chính sách miễn hoặc giảm học phí theo đúng quy định của Nhà nước. Sinh viên cần chuẩn bị Sổ hộ nghèo, Giấy chứng nhận diện chính sách bản công chứng nộp về Phòng Công tác sinh viên để xét duyệt đầu năm học. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', 138, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(85, 85, 0, 'FAQ #85 - Quy định mượn học cụ, thiết bị tại phòng thí nghiệm', 'Sinh viên các ngành kỹ thuật (như Công trình, Điện - Điện tử, CNTT) cần mượn thiết bị, học cụ tại các phòng thí nghiệm, xưởng thực hành để làm đồ án hoặc bài tập lớn phải có Giấy đề xuất mượn thiết bị do Giảng viên hướng dẫn ký duyệt. Sinh viên nộp giấy này cho Cán bộ quản lý phòng thí nghiệm, xuất trình Thẻ sinh viên để ký sổ mượn và có trách nhiệm bảo quản, hoàn trả nguyên vẹn đúng thời hạn. Bên cạnh đó, nếu bạn cũng quan tâm về mượn phòng học, hay về liên hệ ban quản lý ký túc xá, cứ hỏi mình thêm nha.', 128, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(86, 86, 0, 'FAQ #86 - Tiếp nhận hồ sơ Đăng ký xét tuyển Học bạ đợt tiếp theo', 'Hội đồng tuyển sinh UTH tổ chức xét tuyển học bạ THPT thành nhiều đợt trong năm. Thí sinh đăng ký nộp hồ sơ trực tuyến thông qua trang Tuyển sinh chính thức của trường, điền đầy đủ điểm số các môn thuộc tổ hợp xét tuyển và tải ảnh chụp học bạ lên hệ thống. Sau khi có kết quả trúng tuyển tạm thời, thí sinh phải nộp hồ sơ bản giấy về trường để đối chiếu xác thực thông tin. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về nguyện vọng bổ sung — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 138, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(87, 87, 0, 'FAQ #87 - Thủ tục xin tạm hoãn thi học kỳ', 'Nếu gặp lý do bất khả kháng như tai nạn hoặc bệnh tật phải nằm viện điều trị ngay vào ngày thi kết thúc học phần, sinh viên phải làm Đơn xin hoãn thi kèm theo Giấy ra viện hoặc Giấy xác nhận có mộc tròn của bệnh viện nộp về Phòng Đào tạo trong vòng tối đa 3 ngày làm việc kể từ ngày thi của môn đó. Môn học xin hoãn thi thành công sẽ được chuyển điểm sang đợt thi bổ sung hoặc thi ghép cùng khóa sau mà không bị tính điểm 0. Ngoài ra, nếu bạn còn thắc mắc về cách tính điểm hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', 134, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(88, 88, 0, 'FAQ #88 - Quy chế quản lý thông tin và tài sản số của sinh viên', 'Theo quy định an ninh thông tin của UTH, tài khoản Portal và mật khẩu cá nhân là tài sản số độc quyền của cá nhân sinh viên đó. Sinh viên tuyệt đối không được chia sẻ tài khoản này cho bất kỳ ai khác. Mọi hành vi tự ý chia sẻ tài khoản dẫn đến việc sai lệch dữ liệu đăng ký môn học, kết quả học tập hoặc phát tán thông tin sai sự thật trên hệ thống sẽ bị xử lý kỷ luật nghiêm khắc từ mức cảnh cáo đến đình chỉ học tập. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về khảo sát ý kiến sinh viên, cứ hỏi mình thêm nha.', 133, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(89, 89, 0, 'FAQ #89 - Quy định tham quan kiến tập thực tế tại doanh nghiệp', 'Hoạt động tham quan kiến tập thực tế tại doanh nghiệp, nhà máy, cảng biển là một học phần bắt buộc hoặc hoạt động bổ trợ bổ ích được các Khoa/Viện tổ chức cho sinh viên (thường dành cho sinh viên năm 2 hoặc năm 3). Hoạt động này giúp sinh viên tiếp cận môi trường làm việc thực tế. Sinh viên tham gia phải tuân thủ nghiêm ngặt giờ giấc điều phối của giảng viên trưởng đoàn và mặc đồng phục trường lịch sự. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thủ tục chuyển ngành và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 140, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11');
INSERT INTO `knowledge_chunks` (`id`, `article_id`, `chunk_index`, `heading`, `chunk_text`, `token_count`, `metadata`, `embedding_model`, `embedding_json`, `content_hash`, `created_at`, `updated_at`) VALUES
(90, 90, 0, 'FAQ #90 - Tư vấn tâm lý và hỗ trợ sinh viên gặp áp lực học đường', 'Nhằm hỗ trợ giải tỏa các áp lực về học tập, cuộc sống hoặc các vấn đề tâm lý cá nhân, UTH có Trung tâm Tư vấn tâm lý sinh viên trực thuộc Phòng Công tác sinh viên. Tại đây, các chuyên gia tâm lý sẽ lắng nghe, chia sẻ và tư vấn định hướng hoàn toàn miễn phí và bảo mật tuyệt đối thông tin cho sinh viên. Sinh viên có thể đặt lịch hẹn tư vấn trực tuyến qua trang hỗ trợ hoặc đến gặp trực tiếp tại văn phòng nhà A. Ngoài ra, nếu bạn còn thắc mắc về cấp lại bảng điểm hoặc về đăng ký cấp lại tài khoản email sinh viên, mình có thể hỗ trợ giải đáp thêm nhé.', 138, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(91, 91, 0, 'FAQ #106 - Rút hồ sơ thôi học', 'Sinh viên muốn xin thôi học và rút hồ sơ gốc (Học bạ, Bằng tốt nghiệp THPT) phải làm đơn theo mẫu của trường, xin ý kiến xác nhận không nợ sách Thư viện, không nợ học phí, sau đó nộp về Phòng Đào tạo để ra quyết định xóa tên và trả lại hồ sơ. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, cứ hỏi mình thêm nha.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(92, 92, 0, 'FAQ #107 - Đăng ký thi lại chuẩn đầu ra', 'Trung tâm Ngoại ngữ và Trung tâm Tin học UTH tổ chức các đợt thi đánh giá chuẩn đầu ra định kỳ hằng tháng. Sinh viên theo dõi lịch thông báo, đăng ký và đóng lệ phí dự thi trực tuyến trên trang của Trung tâm trước ngày thi ít nhất 10 ngày. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chuẩn tin học quốc tế nâng cao và về cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 109, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(93, 93, 0, 'FAQ #108 - Xét giảm điểm rèn luyện', 'Nếu phát hiện điểm rèn luyện hiển thị trên Portal bị sai sót hoặc bị trừ điểm không rõ lý do, sinh viên làm đơn khiếu nại gửi Ban cán sự lớp và Cố vấn học tập trong thời gian 5 ngày kể từ khi công bố kết quả dự kiến để được kiểm tra, điều chỉnh. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xin tạm hoãn thi học kỳ hoặc về cách tính điểm, mình có thể hỗ trợ giải đáp thêm nhé.', 94, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(94, 94, 0, 'FAQ #109 - Quy trình vay vốn ngân hàng', 'Sinh viên thuộc diện đối tượng được vay vốn tín dụng học tập mang hộ khẩu và minh chứng đối tượng đến Phòng Công tác sinh viên để xin cấp \"Giấy xác nhận là sinh viên của trường\". Sau đó mang giấy này về địa phương để làm thủ tục giải ngân tại Ngân hàng Chính sách Xã hội. Bên cạnh đó, nếu bạn cũng quan tâm về miễn giảm anh em ruột, hay về gia hạn học phí, cứ hỏi mình thêm nha.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(95, 95, 0, 'FAQ #110 - Chính sách Học bổng tuyển sinh', 'UTH cấp học bổng toàn phần hoặc bán phần (miễn 50% - 100% học phí năm đầu) cho các tân sinh viên đạt danh hiệu Thủ khoa trường, Thủ khoa ngành, hoặc các thí sinh đạt điểm cao xuất sắc trong kỳ thi tốt nghiệp THPT và kỳ thi Đánh giá năng lực. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về đăng ký tham gia hiến máu đợt hè và về ngày hội sáng tạo — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 98, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(96, 96, 0, 'FAQ #111 - Thời gian giữ xe tối đa tại trường', 'Bãi giữ xe trường UTH mở cửa từ 6h00 đến 22h00 hằng ngày. Sinh viên không được để xe lại bãi qua đêm. Trường hợp xe bị hư hỏng bắt buộc phải để lại, sinh viên phải báo cáo và đăng ký thông tin với Đội bảo vệ trực ban của trường để được quản lý. Ngoài ra, nếu bạn còn thắc mắc về quy định sử dụng mạng wifi nội bộ của trường hoặc về liên hệ ban quản lý ký túc xá, mình có thể hỗ trợ giải đáp thêm nhé.', 100, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(97, 97, 0, 'FAQ #112 - Thủ tục phúc khảo điểm quá trình', 'Điểm quá trình (điểm chuyên cần, bài tập, giữa kỳ) do Giảng viên bộ môn quản lý và công bố trên lớp. Nếu có thắc mắc, sinh viên phải phản hồi trực tiếp với Giảng viên trước khi môn học kết thúc. Khi điểm đã nộp về trường, giảng viên mới không thể tự ý chỉnh sửa. Bên cạnh đó, nếu bạn cũng quan tâm về học cải thiện, hay về đổi lịch thi học kỳ, cứ hỏi mình thêm nha.', 92, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(98, 98, 0, 'FAQ #113 - Tham gia hiến máu có được nghỉ học', 'Sinh viên tham gia ngày hội hiến máu tình nguyện tổ chức tại trường sẽ được hỗ trợ cấp Giấy chứng nhận hiến máu. Giấy này được dùng làm minh chứng hợp lệ để xin phép nghỉ học có lý do đối với các tiết học diễn ra trong ngày hiến máu đó. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về xuân tình nguyện và về khảo sát ý kiến sinh viên — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 95, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(99, 99, 0, 'FAQ #114 - Đổi thẻ nhựa sang thẻ sinh viên', 'Hiện nay UTH triển khai cấp thẻ sinh viên tích hợp thẻ ngân hàng thông minh. Sinh viên năm nhất nhận thẻ theo lịch phân phối của phòng CTSV. Sinh viên khóa cũ có nhu cầu đổi phôi thẻ lỗi sang thẻ đa năng mới đăng ký và đóng phí tại văn phòng phòng CTSV. Ngoài ra, nếu bạn còn thắc mắc về khóa tài khoản Portal hoặc về phạt tiền thư viện, mình có thể hỗ trợ giải đáp thêm nhé.', 94, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(100, 100, 0, 'FAQ #115 - Hủy tư cách đoàn viên', 'Đoàn viên không tham gia sinh hoạt Đoàn hoặc không đóng đoàn phí liên tục trong 3 tháng mà không có lý do chính đáng sẽ bị xem xét xóa tên khỏi danh sách Đoàn viên và thông báo về Chi đoàn lớp sinh hoạt để trừ điểm rèn luyện theo quy chế. Bên cạnh đó, nếu bạn cũng quan tâm về nghiên cứu khoa học, hay về đồng phục & trang phục, cứ hỏi mình thêm nha.', 88, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(101, 101, 0, 'FAQ #116 - Chính sách hỗ trợ bảo hiểm tai nạn', 'Ngoài BHYT bắt buộc, nhà trường có liên kết đơn vị bảo hiểm để sinh viên đăng ký tự nguyện Bảo hiểm tai nạn. Khi xảy ra sự cố chấn thương, nằm viện, sinh viên mang Giấy ra viện và hóa đơn chi phí đến Phòng Công tác sinh viên để làm thủ tục nhận tiền bảo hiểm bồi thường. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chính sách rút hồ sơ hoàn học phí đối với tân sinh viên và về lệ phí xét tuyển hồ sơ đầu vào — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 115, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(102, 102, 0, 'FAQ #117 - Mượn thiết bị âm thanh, sự kiện', 'Các Câu lạc bộ, Chi đoàn lớp cần mượn loa kéo, micro, thiết bị âm thanh hoặc backdrop để tổ chức hoạt động phong trào phải làm đơn đăng ký thông qua Văn phòng Đoàn trường hoặc Phòng Quản trị thiết bị trước ngày diễn ra sự kiện ít nhất 3 ngày. Ngoài ra, nếu bạn còn thắc mắc về mất thẻ sinh viên hoặc về khóa tài khoản Portal, mình có thể hỗ trợ giải đáp thêm nhé.', 91, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(103, 103, 0, 'FAQ #118 - Cấp lại giấy chứng nhận quốc phòng', 'Chứng chỉ Giáo dục Quốc phòng - An ninh do Trung tâm GDQP cấp gốc 1 lần duy nhất. Nếu bị mất, sinh viên không được cấp lại bằng gốc mà phải làm đơn xin cấp Giấy xác nhận hoàn thành môn học hoặc bản sao bảng điểm trực tiếp tại Trung tâm quản lý để nộp xét tốt nghiệp. Bên cạnh đó, nếu bạn cũng quan tâm về giáo dục quốc phòng, hay về giáo dục thể chất, cứ hỏi mình thêm nha.', 94, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(104, 104, 0, 'FAQ #119 - Đăng ký tham gia hiến máu đợt hè', 'Hoạt động hiến máu tình nguyện đợt hè thường được phối hợp tổ chức vào khoảng tháng 6 hoặc tháng 7 nhằm bổ sung nguồn máu dự trữ khan hiếm. Sinh viên học kỳ hè hoặc sinh viên ở lại thành phố đăng ký trực tuyến qua Fanpage Hội Sinh viên trường UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về sinh hoạt công dân và về văn nghệ tiếng hát — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 97, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(105, 105, 0, 'FAQ #120 - Quy định số lần cảnh báo học vụ', 'Theo quy chế học vụ UTH, sinh viên bị cảnh báo học vụ 2 lần liên tiếp sẽ bị buộc thôi học. Nếu bị cảnh báo rải rác không liên tiếp, sinh viên vẫn được tiếp tục học nhưng phải chủ động gặp Cố vấn học tập để làm cam kết lộ trình cải thiện điểm số. Ngoài ra, nếu bạn còn thắc mắc về điểm rèn luyện f hoặc về bảo lưu kết quả, mình có thể hỗ trợ giải đáp thêm nhé.', 90, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(106, 106, 0, 'FAQ #121 - Thời hạn sử dụng của thẻ thư viện', 'Thẻ thư viện UTH (tích hợp trên Thẻ sinh viên) có giá trị sử dụng xuyên suốt toàn bộ khóa học chính quy của sinh viên tại trường. Tài khoản thư viện sẽ tự động bị khóa sau khi sinh viên nhận quyết định tốt nghiệp hoặc quyết định thôi học, ngừng học. Bên cạnh đó, nếu bạn cũng quan tâm về phạt tiền thư viện, hay về cấp lại bảng điểm, cứ hỏi mình thêm nha.', 89, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(107, 107, 0, 'FAQ #122 - Thủ tục xin miễn học thể dục', 'Sinh viên có khuyết tật, dị tật hoặc mắc các bệnh lý mãn tính không thể tham gia vận động mạnh phải làm đơn xin miễn/giảm học phần Giáo dục thể chất kèm theo Bệnh án, Giấy chứng nhận thương tật của bệnh viện cấp Quận trở lên nộp về Bộ môn GDTC để xét duyệt chuyển đổi môn học phù hợp. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về giáo dục quốc phòng và về cấp lại giấy chứng nhận quốc phòng — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 110, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(108, 108, 0, 'FAQ #123 - Thời gian nhận bằng tốt nghiệp', 'Bằng tốt nghiệp chính thức được cấp phát cho sinh viên trong vòng 30 ngày kể từ ngày ký Quyết định công nhận tốt nghiệp. Sinh viên nhận bằng trực tiếp tại lễ tốt nghiệp hoặc đến văn phòng Phòng Đào tạo để ký sổ nhận bằng gốc (mang theo CCCD). Ngoài ra, nếu bạn còn thắc mắc về điều kiện tốt nghiệp hoặc về thực tập tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', 91, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(109, 109, 0, 'FAQ #124 - Phí phạt nợ học phí quá hạn', 'UTH không áp dụng hình thức phạt tiền mặt khi sinh viên nộp học phí trễ hạn. Tuy nhiên, sinh viên không hoàn thành học phí đúng thời gian quy định sẽ bị hệ thống tự động khóa tài khoản Portal, hủy danh sách đăng ký học phần và cấm tham gia kỳ thi học kỳ. Bên cạnh đó, nếu bạn cũng quan tâm về quy trình vay vốn ngân hàng, hay về bảo hiểm y tế, cứ hỏi mình thêm nha.', 92, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(110, 110, 0, 'FAQ #125 - Xin hoãn đi thực tập tốt nghiệp', 'Sinh viên năm cuối vì lý do sức khỏe hoặc chưa tích lũy đủ các môn học điều kiện bắt buộc muốn xin hoãn học phần Thực tập tốt nghiệp phải làm đơn xin hoãn nộp về Văn phòng Khoa/Viện chủ quản trước khi danh sách phân công đơn vị thực tập được công bố. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về chương trình đào tạo và về thời gian nhận bằng tốt nghiệp — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(111, 111, 0, 'FAQ #126 - Chính sách hỗ trợ sinh viên nghèo', 'Sinh viên gặp tai nạn, thiên tai, hỏa hoạn hoặc gia đình gặp biến cố lớn đột xuất dẫn đến hoàn cảnh đặc biệt khó khăn làm đơn xin hỗ trợ gửi Phòng Công tác sinh viên. Nhà trường sẽ xem xét trích Quỹ hỗ trợ sinh viên để cấp kinh phí trợ cấp đột xuất. Ngoài ra, nếu bạn còn thắc mắc về đóng lệ phí thi lại hoặc về chế độ miễn giảm học phí cho con em diện chính sách, mình có thể hỗ trợ giải đáp thêm nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(112, 112, 0, 'FAQ #127 - Đồ án tốt nghiệp đạt điểm F xử lý sao', 'Sinh viên bảo vệ Đồ án hoặc Khóa luận tốt nghiệp nhận điểm F (không đạt) sẽ không được tốt nghiệp đúng hạn. Sinh viên bắt buộc phải đăng ký làm lại đề tài mới hoặc đăng ký lại học phần đồ án vào kỳ xét duyệt tiếp theo của năm học sau và đóng phí theo quy định. Bên cạnh đó, nếu bạn cũng quan tâm về thời gian nhận bằng tốt nghiệp, hay về chương trình đào tạo, cứ hỏi mình thêm nha.', 96, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(113, 113, 0, 'FAQ #128 - Quy chế xét học bổng khi nợ môn', 'Theo quy chế khen thưởng của UTH, sinh viên chỉ cần nợ 1 môn học (nhận điểm F) hoặc đăng ký thi lại/học lại bất kỳ môn nào trong học kỳ đó thì sẽ lập tức bị tước quyền tham gia xét duyệt Học bổng khuyến khích học tập, bất kể điểm GPA tổng của bạn cao bao nhiêu. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học bổng doanh nghiệp và về học bổng liên kết — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 101, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(114, 114, 0, 'FAQ #129 - Liên hệ Ban quản lý ký túc xá', 'Để phản ánh các vấn đề về điện nước, an ninh phòng ở hoặc nộp chi phí nội trú Ký túc xá, sinh viên đến trực tiếp văn phòng Ban quản lý nội trú Ký túc xá đặt tại khu vực cổng vào của khu nội trú cơ sở đó để được cán bộ trực ban giải quyết. Ngoài ra, nếu bạn còn thắc mắc về đồng phục & trang phục hoặc về quy định mượn học cụ, thiết bị tại phòng thí nghiệm, mình có thể hỗ trợ giải đáp thêm nhé.', 99, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(115, 115, 0, 'FAQ #131 - Phương thức tuyển sinh năm 2026 của UTH', 'Năm 2026, UTH tuyển sinh đại học chính quy theo 2 phương thức: (1) Xét tuyển thẳng theo quy định của Bộ GD&ĐT và theo Đề án riêng của UTH (thí sinh đạt giải HSG cấp Tỉnh/Thành trở lên; có chứng chỉ tiếng Anh quốc tế từ IELTS 6.0, TOEFL iBT 60, TOEIC 600 hoặc Bậc 4/6 trở lên; học sinh trường chuyên/trọng điểm; đạt học lực Giỏi nhiều học kỳ; thuộc nhóm ngành ưu tiên nhà nước như đường sắt tốc độ cao, CNTT, trí tuệ nhân tạo; hoặc có thư giới thiệu từ doanh nghiệp đối tác của UTH); (2) Xét tuyển kết hợp - phương thức chủ đạo, chiếm phần lớn chỉ tiêu, tính điểm theo công thức riêng của trường (UTH120), kết hợp điểm thi Đánh giá năng lực (nếu có), điểm học bạ cả năm lớp 12, điểm thi tốt nghiệp THPT năm 2026 và điểm ưu tiên/điểm khuyến khích theo quy định. Từ năm 2025, UTH không còn xét tuyển riêng lẻ theo điểm thi THPT hay điểm học bạ như các năm trước đó; các loại điểm này chỉ là thành phần trong công thức xét tuyển kết hợp chung. Chương trình đào tạo được thiết kế 120 tín chỉ, thời gian học tối thiểu 3 năm. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về thời gian công bố kết quả trúng tuyển chính thức và về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 306, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(116, 116, 0, 'FAQ #132 - Các tổ hợp môn xét tuyển phổ biến tại UTH', 'Trong công thức xét tuyển kết hợp của UTH, điểm xét tuyển được tính từ 3 môn theo tổ hợp đăng ký (các tổ hợp phổ biến nhiều năm qua gồm A00: Toán - Lý - Hóa; A01: Toán - Lý - Anh; D01: Toán - Văn - Anh; D07: Toán - Hóa - Anh), sau đó tổng hợp cùng điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực (nếu có) theo công thức và trọng số riêng của từng năm tuyển sinh. Công nghệ thông tin và Logistics - Quản lý chuỗi cung ứng tiếp tục là các nhóm ngành có chỉ tiêu lớn và mức độ cạnh tranh cao nhất trường. Vì tổ hợp và công thức tính điểm cụ thể có thể thay đổi theo từng ngành và từng năm, thí sinh nên tra cứu Đề án tuyển sinh chính thức hằng năm tại tuyensinh.ut.edu.vn để có thông tin chính xác nhất. Ngoài ra, nếu bạn còn thắc mắc về thủ tục xác nhận nhập học trực tuyến hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', 223, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(117, 117, 0, 'FAQ #133 - Điểm chuẩn ngành Công nghệ thông tin (CNTT) năm 2025', 'Năm 2025, UTH xét tuyển theo phương thức Xét tuyển kết hợp với thang điểm riêng của trường (không phải thang 30 quen thuộc, mà dao động 668-999 điểm tùy ngành). Điểm chuẩn trúng tuyển các chuyên ngành thuộc nhóm Công nghệ thông tin, công bố ngày 22/8/2025, như sau: CNTT (chuyên ngành CNTT, chương trình tiên tiến): 800 điểm; CNTT chuyên ngành Khoa học dữ liệu và AI (chương trình tiên tiến): 800 điểm; CNTT chương trình hoàn toàn bằng tiếng Anh: 800 điểm; CNTT chuyên ngành Truyền thông số và Đổi mới sáng tạo: 720 điểm; CNTT chuyên ngành Smart Logistics: 720 điểm; CNTT chuyên ngành Công nghệ ô tô số: 800 điểm. Lưu ý: mức điểm này tính theo công thức riêng của UTH (kết hợp điểm học bạ, điểm thi THPT, điểm Đánh giá năng lực và điểm ưu tiên) nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Bên cạnh đó, nếu bạn cũng quan tâm về chỉ tiêu tuyển sinh dự kiến năm 2026, hay về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, cứ hỏi mình thêm nha.', 255, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(118, 118, 0, 'FAQ #134 - Điểm chuẩn ngành Logistics và Quản lý chuỗi cung ứng năm 2025', 'Logistics và Quản lý chuỗi cung ứng tiếp tục là một trong những ngành có điểm chuẩn cao nhất UTH. Theo điểm chuẩn chính thức công bố ngày 22/8/2025 (phương thức Xét tuyển kết hợp, thang điểm riêng của trường, KHÔNG phải thang 30): Logistics và Quản lý chuỗi cung ứng - chương trình tiên tiến: 963 điểm (chỉ xếp sau ngành Khoa học dữ liệu - chương trình tiên tiến với 999 điểm, cao nhất toàn trường); Logistics và Quản lý chuỗi cung ứng - chương trình hoàn toàn bằng tiếng Anh: 720 điểm. Đây tiếp tục là ngành có mức độ cạnh tranh rất cao tại UTH trong nhiều năm liền. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về rút hồ sơ thôi học và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 179, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(119, 119, 0, 'FAQ #135 - Điểm chuẩn tổng hợp tất cả các ngành năm 2025', 'UTH công bố điểm chuẩn chính thức hệ đại học chính quy năm 2025 vào ngày 22/8/2025, theo phương thức Xét tuyển kết hợp (thang điểm riêng của trường, KHÔNG phải thang 30 truyền thống), dao động từ 668 đến 999 điểm tùy ngành/chuyên ngành. Một số mức điểm chuẩn tiêu biểu: Khoa học dữ liệu (chương trình tiên tiến) 999 điểm - cao nhất toàn trường; Logistics và Quản lý chuỗi cung ứng (chương trình tiên tiến) 963 điểm; Kỹ thuật điện (chuyên ngành Điện công nghiệp, Hệ thống điện giao thông, Năng lượng tái tạo) 936 điểm; Công nghệ kỹ thuật điều khiển và tự động hóa (chương trình tiên tiến) 931 điểm. Nhóm ngành phổ biến ở mức 720-800 điểm gồm: Công nghệ thông tin, Ngôn ngữ Anh, Luật, Quản trị kinh doanh, Hệ thống thông tin quản lý, Kỹ thuật cơ khí, Kỹ thuật ô tô, Kinh tế xây dựng, Khai thác vận tải, Kinh tế vận tải (đa số thuộc chương trình tiên tiến). Nhóm có điểm sàn thấp nhất (668 điểm) gồm các chương trình chuẩn (không phải tiên tiến) như Kỹ thuật tàu thủy, Kỹ thuật xây dựng công trình thủy, Khoa học hàng hải và các ngành liên quan đường sắt tốc độ cao. Lưu ý quan trọng: mức điểm 2025 tính theo công thức riêng của UTH (kết hợp điểm học bạ lớp 12, điểm thi THPT, điểm thi Đánh giá năng lực và điểm ưu tiên), nên KHÔNG thể so sánh trực tiếp với điểm chuẩn thang 30 của các trường xét điểm thi THPT truyền thống. Trường có hơn 50 ngành/chuyên ngành/chương trình đào tạo khác nhau, mỗi ngành có mức điểm riêng; thí sinh nên tra cứu bảng điểm chuẩn đầy đủ theo từng mã ngành tại tuyensinh.ut.edu.vn hoặc liên hệ Phòng Đào tạo để được tư vấn chính xác. Ngoài ra, nếu bạn còn thắc mắc về phương thức tuyển sinh năm 2026 của UTH hoặc về tiếp nhận hồ sơ đăng ký xét tuyển học bạ đợt tiếp theo, mình có thể hỗ trợ giải đáp thêm nhé.', 434, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(120, 120, 0, 'FAQ #136 - Chỉ tiêu tuyển sinh dự kiến năm 2026', 'UTH công bố Đề án tuyển sinh đại học chính quy năm 2026 vào ngày 16/6/2026, với hơn 50 ngành/chuyên ngành đào tạo, mở rộng thêm nhiều chuyên ngành mới gắn với công nghệ số như: Khoa học dữ liệu - Blockchain và AI, Smart Logistics, Công nghệ ô tô số, Kinh tế số và Trí tuệ nhân tạo, Truyền thông số và Đổi mới sáng tạo, Logistics xanh và phát triển bền vững, Quản lý và công nghệ UAV... Chỉ tiêu cụ thể được phân bổ chi tiết theo từng mã ngành trong Đề án tuyển sinh chính thức chứ không phải một con số tổng cố định, và có thể thay đổi theo từng năm. Thí sinh nên tra cứu chỉ tiêu cụ thể theo từng mã ngành tại Đề án tuyển sinh 2026 chính thức đăng trên tuyensinh.ut.edu.vn thay vì dựa vào số liệu ước tính. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành công nghệ thông tin, hay về thủ tục xác nhận nhập học trực tuyến, cứ hỏi mình thêm nha.', 213, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(121, 121, 0, 'FAQ #137 - Cách sử dụng chứng chỉ IELTS trong tuyển sinh và học tập tại UTH', 'UTH không áp dụng một bảng quy đổi điểm IELTS sang thang điểm xét tuyển cố định. Chứng chỉ tiếng Anh quốc tế được UTH sử dụng theo 2 cách: (1) Trong xét tuyển đầu vào: thí sinh có chứng chỉ IELTS từ 6.0 trở lên (hoặc TOEFL iBT từ 60, TOEFL ITP từ 530, TOEIC từ 600, Bậc 4 theo Khung năng lực ngoại ngữ 6 bậc dùng cho Việt Nam trở lên, còn hiệu lực) có thể dùng làm một trong các tiêu chí để đăng ký diện Xét tuyển thẳng theo Đề án riêng của UTH; (2) Sau khi nhập học: sinh viên nộp chứng chỉ IELTS hoặc chứng chỉ ngoại ngữ tương đương để trường xét miễn các cấp độ học phần tiếng Anh tương ứng với năng lực (miễn đến cấp độ nào thì được miễn học phí cấp độ đó), nộp hồ sơ trực tuyến qua support.ut.edu.vn (mục Phòng Đào tạo/Chuẩn đào tạo ngoại ngữ UTH). Vì điều kiện cụ thể có thể điều chỉnh theo từng năm, sinh viên nên tra cứu Đề án tuyển sinh hoặc thông báo chính thức mới nhất của UTH. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 và về điểm sàn nhận hồ sơ xét tuyển — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 271, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(122, 122, 0, 'FAQ #138 - Điểm sàn nhận hồ sơ xét tuyển (Ngưỡng đảm bảo chất lượng)', 'Từ năm 2025, UTH chuyển sang phương thức Xét tuyển kết hợp làm phương thức tuyển sinh chủ đạo (tính điểm theo công thức riêng của trường, kết hợp điểm học bạ, điểm thi THPT và điểm thi Đánh giá năng lực), nên khái niệm \"điểm sàn\" theo thang 30 truyền thống không còn áp dụng thống nhất cho toàn trường như các năm trước 2025. Điều kiện đầu vào tối thiểu của phương thức xét tuyển kết hợp hiện nay là thí sinh phải có điểm thi môn Toán trong kỳ thi tốt nghiệp THPT từ 5.0 trở lên (một số ngành yêu cầu cao hơn, ví dụ ngành Toán ứng dụng yêu cầu từ 6.0), cùng với ngưỡng đảm bảo chất lượng cụ thể theo từng ngành được quy định riêng trong Đề án tuyển sinh của từng năm. Thí sinh cần tra cứu Đề án tuyển sinh chính thức mới nhất tại tuyensinh.ut.edu.vn để biết điều kiện đăng ký xét tuyển áp dụng cho ngành mình quan tâm. Ngoài ra, nếu bạn còn thắc mắc về đăng ký nguyện vọng vào UTH trên hệ thống của bộ GD&ĐT hoặc về lệ phí xét tuyển hồ sơ đầu vào, mình có thể hỗ trợ giải đáp thêm nhé.', 247, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(123, 123, 0, 'FAQ #139 - Đăng ký nguyện vọng vào UTH trên hệ thống của Bộ GD&ĐT', 'Để xét tuyển vào UTH bằng điểm thi THPT, thí sinh phải đăng ký nguyện vọng trên hệ thống chung của Bộ GD&ĐT theo đúng lịch quy định. Thí sinh cần nhập chính xác Mã trường của UTH là GTS và chọn đúng mã ngành, mã tổ hợp môn mong muốn. Nên xếp ngành yêu thích nhất ở Nguyện vọng 1. Bên cạnh đó, nếu bạn cũng quan tâm về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025, hay về lệ phí xét tuyển hồ sơ đầu vào, cứ hỏi mình thêm nha.', 111, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(124, 124, 0, 'FAQ #140 - Lệ phí xét tuyển hồ sơ đầu vào', 'Lệ phí xét tuyển đối với phương thức xét học bạ nộp trực tiếp về trường UTH áp dụng theo quy định hành chính thu chi. Đối với phương thức xét điểm thi THPT, thí sinh đóng lệ phí trực tuyến trực tiếp trên hệ thống cổng thông tin của Bộ GD&ĐT khi tiến hành xác nhận số lượng nguyện vọng. Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về học phí trường và về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 116, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(125, 125, 0, 'FAQ #141 - Thời gian công bố kết quả trúng tuyển chính thức', 'Thời gian công bố điểm chuẩn và danh sách trúng tuyển chính thức của UTH tuân thủ nghiêm ngặt theo lộ trình chung của Bộ GD&ĐT (thường vào khoảng tháng 8 hằng năm). Kết quả xét tuyển sớm bằng học bạ thường được trường thông báo trước đó vào tháng 6 hoặc tháng 7. Ngoài ra, nếu bạn còn thắc mắc về điểm chuẩn ngành logistics và quản lý chuỗi cung ứng năm 2025 hoặc về hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học, mình có thể hỗ trợ giải đáp thêm nhé.', 118, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(126, 126, 0, 'FAQ #142 - Thủ tục xác nhận nhập học trực tuyến', 'Sau khi có thông báo trúng tuyển chính thức, thí sinh bắt buộc phải thực hiện bước Xác nhận nhập học trực tuyến trên hệ thống của Bộ GD&ĐT trước thời hạn quy định. Thí sinh cố tình không xác nhận nhập học đúng hạn sẽ bị hệ thống tự động hủy kết quả trúng tuyển vào trường. Bên cạnh đó, nếu bạn cũng quan tâm về các tổ hợp môn xét tuyển phổ biến tại UTH, hay về phương thức tuyển sinh năm 2026 của UTH, cứ hỏi mình thêm nha.', 106, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(127, 127, 0, 'FAQ #143 - Hồ sơ bản giấy cần chuẩn bị khi đến trường làm thủ tục nhập học', 'Hồ sơ nhập học bản giấy nộp tại trường bao gồm: Giấy báo trúng tuyển bản gốc; Học bạ THPT (bản sao công chứng); Giấy chứng nhận tốt nghiệp tạm thời hoặc Bằng tốt nghiệp THPT; Bản sao CCCD; Giấy khai sinh; và các giấy tờ minh chứng đối tượng ưu tiên chính sách (nếu có). Nhân tiện, các bạn sinh viên cũng hay hỏi thêm về quy trình làm thủ tục nhập học trực tiếp tại trường và về rút hồ sơ thôi học — nếu cần, bạn cứ đặt câu hỏi cho mình nhé.', 110, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(128, 128, 0, 'FAQ #144 - Quy trình làm thủ tục nhập học trực tiếp tại trường', 'Khi đến nhập học trực tiếp tại cơ sở chính của UTH, tân sinh viên thực hiện theo quy trình luồng: - Tra cứu số thứ tự và phòng làm thủ tục tại sảnh hướng dẫn. - Nộp hồ sơ bản giấy tại bàn tiếp nhận của Khoa/Viện. - Đóng học phí và các khoản bảo hiểm bắt buộc tại bàn tài chính. - Nhận lịch học Tuần sinh hoạt công dân và chụp ảnh làm Thẻ sinh viên. Ngoài ra, nếu bạn còn thắc mắc về thời gian nhận bằng tốt nghiệp hoặc về điều kiện tốt nghiệp, mình có thể hỗ trợ giải đáp thêm nhé.', 121, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(129, 129, 0, 'FAQ #145 - Chính sách rút hồ sơ hoàn học phí đối với tân sinh viên', 'Tân sinh viên đã làm thủ tục nhập học nhưng vì lý do cá nhân muốn xin rút hồ sơ không theo học nữa sẽ được xem xét hoàn trả học phí tùy theo thời điểm nộp đơn. Nếu nộp đơn rút trước ngày khai giảng chính thức, sinh viên được hoàn lại một phần học phí theo quy định đóng rút bồi hoàn của nhà trường; sau ngày khai giảng sẽ không được hoàn phí. Bên cạnh đó, nếu bạn cũng quan tâm về chính sách hỗ trợ sinh viên nghèo, hay về quy trình vay vốn ngân hàng, cứ hỏi mình thêm nha.', 119, NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(256, 256, 0, 'Điều chỉnh đăng ký học phần học kỳ hè 2025-2026', 'Sinh viên điều chỉnh đăng ký học phần học kỳ hè 2025-2026 trực tiếp trên Portal trong thời gian trường công bố. Sau hạn điều chỉnh, sinh viên cần gửi yêu cầu hỗ trợ để được Phòng Đào tạo xem xét theo quy định.', 48, NULL, NULL, NULL, 'b4d715df642a781b0ffd4fee59b74739e1caf2fae323169272dfa639bb0a705c', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(257, 257, 0, 'Tra cứu công nợ học phí', 'Sinh viên tra cứu công nợ và thanh toán học phí tại Cổng thanh toán hoặc mục học phí trên Portal. Các câu hỏi về số tiền còn nợ của từng sinh viên phải được tra cứu từ dữ liệu hóa đơn trong database.', 45, NULL, NULL, NULL, '3e69d26739ff9c85c27da8eebb7064940ea20e9a46a0a7a03a6b77755f2d080d', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `knowledge_question_examples`
--

CREATE TABLE `knowledge_question_examples` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `article_id` bigint(20) UNSIGNED NOT NULL,
  `example_question` varchar(1000) NOT NULL,
  `normalized_question` varchar(1000) DEFAULT NULL,
  `language_code` varchar(10) NOT NULL DEFAULT 'vi',
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `knowledge_question_examples`
--

INSERT INTO `knowledge_question_examples` (`id`, `article_id`, `example_question`, `normalized_question`, `language_code`, `created_at`) VALUES
(1, 1, 'Địa chỉ trường ở đâu? UTH có mấy cơ sở? Trường nằm ở chỗ nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(2, 2, 'Trường có những ngành gì? Ngành CNTT học hệ nào? Đào tạo chất lượng cao là sao?', NULL, 'vi', '2026-07-11 16:34:11'),
(3, 3, 'Cách tính điểm môn học thế nào? Điểm F là gì? Quy chế thang điểm chữ?', NULL, 'vi', '2026-07-11 16:34:11'),
(4, 4, 'Điểm thấp có được học lại không? Làm sao để nâng điểm tích lũy?', NULL, 'vi', '2026-07-11 16:34:11'),
(5, 5, 'Điều kiện xét nâng lớp? Khi nào bị cảnh báo học vụ? Bị buộc thôi học khi nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(6, 6, 'Khi nào đăng ký học phần? Một kỳ được đăng ký tối đa bao nhiêu tín chỉ? Hủy môn học ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(7, 7, 'Môn tiên quyết là gì? Môn học trước là gì? Khác nhau thế nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(8, 8, 'Xem lịch thi ở đâu? Vào phòng thi cần mang gì? Hoãn thi làm sao?', NULL, 'vi', '2026-07-11 16:34:11'),
(9, 9, 'Học phí một tín chỉ bao nhiêu tiền? Đóng tiền học ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(10, 10, 'Không có tiền đóng học phí làm sao? Xin nợ học phí ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(11, 11, 'Lịch hiến máu tình nguyện? Tham gia hoạt động được cộng bao nhiêu điểm rèn luyện?', NULL, 'vi', '2026-07-11 16:34:11'),
(12, 12, 'Trường có CLB guitar không? Đội tình nguyện hoạt động thế nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(13, 13, 'Điều kiện nhận học bổng trường? Điểm rèn luyện bao nhiêu thì được học bổng?', NULL, 'vi', '2026-07-11 16:34:11'),
(14, 14, 'Chuẩn tiếng Anh xét tốt nghiệp? Nộp bằng TOEIC ở đâu? Điều kiện miễn học Anh văn?', NULL, 'vi', '2026-07-11 16:34:11'),
(15, 15, 'Chuẩn tin học đầu ra là gì? Chứng chỉ MOS hay IC3?', NULL, 'vi', '2026-07-11 16:34:11'),
(16, 16, 'Làm sao để được ra trường? Điều kiện xét tốt nghiệp UTH? Nợ môn có được xét tốt nghiệp?', NULL, 'vi', '2026-07-11 16:34:11'),
(17, 17, 'Làm lại thẻ sinh viên ở đâu? Mất thẻ sinh viên đóng phạt bao nhiêu?', NULL, 'vi', '2026-07-11 16:34:11'),
(18, 18, 'Đăng ký ở KTX ở đâu? Chi phí Ký túc xá UTH? Đối tượng ưu tiên ở KTX?', NULL, 'vi', '2026-07-11 16:34:11'),
(19, 19, 'Thư viện trường ở đâu? Cách mượn sách về nhà? Trả sách trễ hạn bị phạt thế nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(20, 20, 'Đóng tiền bảo hiểm y tế ở đâu? Hạn chót nộp BHYT? Gia hạn bảo hiểm sinh viên?', NULL, 'vi', '2026-07-11 16:34:11'),
(21, 21, 'Tiêu chí đạt Sinh viên 5 Tốt? Quyền lợi khi đạt Sinh viên 5 Tốt UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(22, 22, 'Đăng ký nghiên cứu khoa học ở đâu? Quyền lợi khi làm NCKH sinh viên?', NULL, 'vi', '2026-07-11 16:34:11'),
(23, 23, 'Cách rút môn học? Hạn chót hủy học phần đã đăng ký? Rút môn có được hoàn tiền không?', NULL, 'vi', '2026-07-11 16:34:11'),
(24, 24, 'Liên hệ phòng CTSV ở đâu? Xin giấy xác nhận sinh viên vay vốn ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(25, 25, 'Số điện thoại Phòng Đào tạo? Hỏi về lịch học, lịch thi, xét tốt nghiệp ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(26, 26, 'KTX Quận 12 ở đâu? Đăng ký ký túc xá cơ sở 2? Chi phí phòng KTX Quận 12?', NULL, 'vi', '2026-07-11 16:34:11'),
(27, 27, 'Học bổng tài trợ? Điều kiện nhận học bổng ngoài ngân sách? Học bổng vượt khó?', NULL, 'vi', '2026-07-11 16:34:11'),
(28, 28, 'Xe buýt nào đi qua trường UTH? Đi xe bus đến Võ Oanh? Xe bus qua cơ sở Bình Thạnh?', NULL, 'vi', '2026-07-11 16:34:11'),
(29, 29, 'Làm sao để đổi ngành học? Điều kiện chuyển ngành UTH? Đang học có được đổi ngành khác?', NULL, 'vi', '2026-07-11 16:34:11'),
(30, 30, 'Xin tạm dừng học? Cách làm đơn bảo lưu học tập? Nghỉ học tạm thời được bao lâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(31, 31, 'Chấm phúc khảo ở đâu? Lệ phí phúc khảo bài thi? Thời hạn nộp đơn chấm phúc khảo?', NULL, 'vi', '2026-07-11 16:34:11'),
(32, 32, 'Quy định đồng phục UTH? Mặc áo gì đi học? Có bắt buộc mặc áo trường không?', NULL, 'vi', '2026-07-11 16:34:11'),
(33, 33, 'Quy chế kỷ luật sinh viên? Đi thi gian lận bị phạt thế nào? Quay cóp bài thi bị xử lý sao?', NULL, 'vi', '2026-07-11 16:34:11'),
(34, 34, 'Liên hệ khoa CNTT ở đâu? Số điện thoại khoa Công nghệ thông tin UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(35, 35, 'Liên hệ Viện Logistics ở đâu? Văn phòng Khoa Kinh tế vận tải nằm ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(36, 36, 'Học quân sự ở đâu? Lịch học giáo dục quốc phòng? Đi học quân sự cần chuẩn bị gì?', NULL, 'vi', '2026-07-11 16:34:11'),
(37, 37, 'Học thể dục ở đâu? Các môn thể dục UTH? Đăng ký học môn thể thao nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(38, 38, 'Xin cấp bảng điểm học tập ở đâu? Lệ phí in bảng điểm chính thức?', NULL, 'vi', '2026-07-11 16:34:11'),
(39, 39, 'Làm mất sách thư viện đền tiền thế nào? Quên trả sách thư viện bị phạt bao nhiêu?', NULL, 'vi', '2026-07-11 16:34:11'),
(40, 40, 'Trường có xét tuyển bổ sung không? Điều kiện xét tuyển đợt 2 UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(41, 41, 'Xin bảng điểm bằng tiếng Anh ở đâu? Lệ phí dịch thuật bảng điểm UTH? Cấp bảng điểm song ngữ?', NULL, 'vi', '2026-07-11 16:34:11'),
(42, 42, 'Đồ án tốt nghiệp có được phúc khảo không? Chấm lại điểm khóa luận tốt nghiệp?', NULL, 'vi', '2026-07-11 16:34:11'),
(43, 43, 'Tại sao tài khoản Portal bị khóa? Lỗi không đăng nhập được trang sinh viên?', NULL, 'vi', '2026-07-11 16:34:11'),
(44, 44, 'Bãi xe trường ở đâu? Giá vé gửi xe máy UTH? Gửi xe qua đêm tại trường được không?', NULL, 'vi', '2026-07-11 16:34:11'),
(45, 45, 'Anh em ruột cùng học UTH có được giảm học phí? Chính sách giảm học phí gia đình?', NULL, 'vi', '2026-07-11 16:34:11'),
(46, 46, 'Làm sao để xin đổi ca thi? Bị trùng lịch thi phải làm thế nào? Trùng giờ thi xử lý sao?', NULL, 'vi', '2026-07-11 16:34:11'),
(47, 47, 'Làm sao lấy lại mật khẩu Portal? Quên pass trang sinh viên UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(48, 48, 'Trạm y tế trường nằm ở đâu? Khám sức khỏe sinh viên đầu năm ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(49, 49, 'Học bổng du học UTH? Chương trình trao đổi sinh viên quốc tế?', NULL, 'vi', '2026-07-11 16:34:11'),
(50, 50, 'Tuần sinh hoạt công dân học khi nào? Không học sinh hoạt công dân có bị sao không?', NULL, 'vi', '2026-07-11 16:34:11'),
(51, 51, 'Sinh viên có được đổi cơ sở học không? Đang học Quận 12 chuyển qua Bình Thạnh?', NULL, 'vi', '2026-07-11 16:34:11'),
(52, 52, 'Làm sao để mượn phòng học làm hoạt động? Thủ tục mượn hội trường UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(53, 53, 'Cuộc thi khởi nghiệp sinh viên UTH? Quỹ hỗ trợ ý tưởng sáng tạo?', NULL, 'vi', '2026-07-11 16:34:11'),
(54, 54, 'Xin giấy chứng nhận sinh viên tạm thời ở đâu? Thời gian cấp giấy xác nhận là bao lâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(55, 55, 'Văn phòng Đoàn trường UTH ở đâu? Đăng ký sổ Đoàn, nộp sổ Đoàn ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(56, 56, 'Khảo sát môn học làm ở đâu? Không làm khảo sát giảng viên có bị sao không?', NULL, 'vi', '2026-07-11 16:34:11'),
(57, 57, 'Thi lại có tốn tiền không? Lệ phí thi lại đóng ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(58, 58, 'Lịch đi thực tập của sinh viên năm cuối? Xin giấy giới thiệu thực tập ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(59, 59, 'Điều kiện được làm đồ án ra trường? Điểm GPA bao nhiêu thì được làm khóa luận tốt nghiệp?', NULL, 'vi', '2026-07-11 16:34:11'),
(60, 60, 'Sinh viên xuất sắc được thưởng gì? Tiêu chuẩn xét khen thưởng danh hiệu học tập?', NULL, 'vi', '2026-07-11 16:34:11'),
(61, 61, 'Đăng ký Mùa hè xanh ở đâu? Tiêu chí tuyển chiến sĩ MHX? Đi MHX được bao nhiêu ĐRL?', NULL, 'vi', '2026-07-11 16:34:11'),
(62, 62, 'Đăng ký Tiếp sức mùa thi UTH? Lịch chạy chương trình TSMT?', NULL, 'vi', '2026-07-11 16:34:11'),
(63, 63, 'Lịch chạy Xuân tình nguyện UTH? Đăng ký đi XTN ở đâu? Chi phí đóng góp XTN?', NULL, 'vi', '2026-07-11 16:34:11'),
(64, 64, 'Giải chạy bộ UTH? Đăng ký chạy marathon trường ở đâu? Minh chứng hoàn thành giải chạy?', NULL, 'vi', '2026-07-11 16:34:11'),
(65, 65, 'Cuộc thi ý tưởng sáng tạo UTH? Sáng tạo trẻ sinh viên giao thông?', NULL, 'vi', '2026-07-11 16:34:11'),
(66, 66, 'Danh hiệu Chiến sĩ tình nguyện xuất sắc? Làm sao để được tặng bằng khen MHX?', NULL, 'vi', '2026-07-11 16:34:11'),
(67, 67, 'Lịch tổ chức Đại hội Đại biểu? Đi bầu cử Đoàn Thanh niên ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(68, 68, 'Hội trại truyền thống UTH học kỳ nào? Địa điểm cắm trại trường? Chi phí hội trại?', NULL, 'vi', '2026-07-11 16:34:11'),
(69, 69, 'Giải bóng đá nam/nữ trường UTH? Đăng ký đá banh giải trường ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(70, 70, 'Cuộc thi tiếng hát sinh viên UTH? Cuộc thi văn nghệ UTH Got Talent?', NULL, 'vi', '2026-07-11 16:34:11'),
(71, 71, 'Đội tình nguyện hiến máu UTH? Câu lạc bộ Hành Trình Đỏ UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(72, 72, 'Nộp minh chứng hoạt động ở đâu? Quên nộp minh chứng có được cộng điểm rèn luyện?', NULL, 'vi', '2026-07-11 16:34:11'),
(73, 73, 'Điểm rèn luyện dưới 50 bị phạt thế nào? ĐRL loại Yếu có được tốt nghiệp không?', NULL, 'vi', '2026-07-11 16:34:11'),
(74, 74, 'UTH Job Fair tổ chức khi nào? Sinh viên năm nhất có được tham gia ngày hội việc làm?', NULL, 'vi', '2026-07-11 16:34:11'),
(75, 75, 'Lớp học kỹ năng mềm UTH? Đăng ký chuyên đề kỹ năng ở đâu? Có tính ĐRL không?', NULL, 'vi', '2026-07-11 16:34:11'),
(76, 76, 'Học phí hệ chất lượng cao là bao nhiêu? Tại sao học phí CLC lại cao hơn đại trà? Tổng tiền học phí CLC một năm?', NULL, 'vi', '2026-07-11 16:34:11'),
(77, 77, 'Cách chấm điểm rèn luyện như thế nào? Quy trình họp xét ĐRL của lớp? Khi nào bắt đầu tự đánh giá ĐRL?', NULL, 'vi', '2026-07-11 16:34:11'),
(78, 78, 'Xem thẻ bảo hiểm y tế ở đâu? Cách đăng ký tài khoản VssID sinh viên? Mất thẻ bảo hiểm y tế giấy phải làm sao?', NULL, 'vi', '2026-07-11 16:34:11'),
(79, 79, 'Chứng chỉ tin học IC3 hay MOS tốt hơn? Quy đổi điểm tin học đầu ra như thế nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(80, 80, 'Cách kết nối wifi trường UTH? Mật khẩu wifi sinh viên là gì? Tại sao không vào được wifi trường?', NULL, 'vi', '2026-07-11 16:34:11'),
(81, 81, 'Làm sao để vào câu lạc bộ của trường? Ngày hội các câu lạc bộ tổ chức khi nào? Tuyển thành viên CLB UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(82, 82, 'Làm sao để đổi mật khẩu email sinh viên? Bị mất email của trường xử lý thế nào?', NULL, 'vi', '2026-07-11 16:34:11'),
(83, 83, 'Một năm trường tổ chức hiến máu mấy lần? Lịch hiến máu đợt 2 của trường?', NULL, 'vi', '2026-07-11 16:34:11'),
(84, 84, 'Con thương binh có được giảm học phí không? Thủ tục xin miễn học phí diện hộ nghèo? Nộp hồ sơ giảm học phí ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(85, 85, 'Làm sao để mượn đồ phòng thí nghiệm làm đồ án? Quy định mượn thiết bị đo đạc?', NULL, 'vi', '2026-07-11 16:34:11'),
(86, 86, 'Khi nào trường nhận hồ sơ học bạ đợt 2? Cách nộp học bạ online vào trường UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(87, 87, 'Bị ốm đột xuất không đi thi được làm sao? Cách xin hoãn thi học kỳ? Đơn xin hoãn thi nộp ở đâu?', NULL, 'vi', '2026-07-11 16:34:11'),
(88, 88, 'Có được chia sẻ tài khoản Portal cho người khác không? Quy định bảo mật thông tin sinh viên UTH?', NULL, 'vi', '2026-07-11 16:34:11'),
(89, 89, 'Sinh viên năm mấy được đi kiến tập? Đi kiến tập doanh nghiệp có bắt buộc không?', NULL, 'vi', '2026-07-11 16:34:11'),
(90, 90, 'Trường có phòng tư vấn tâm lý không? Bị stress áp lực học tập thì liên hệ ai hỗ trợ?', NULL, 'vi', '2026-07-11 16:34:11'),
(91, 91, 'rut ho so, thoi hoc, xoa ten, khong hoc nua, xin thoi hoc, nghi hoc luon', NULL, 'vi', '2026-07-11 16:34:11'),
(92, 92, 'thi lai anh van, thi lai tin hoc, nop don thi lai cdr, dang ky thi tieng anh', NULL, 'vi', '2026-07-11 16:34:11'),
(93, 93, 'tru diem ren luyen, khieu nai drl, mo cong drl, cham lai drl, kieu nai drl', NULL, 'vi', '2026-07-11 16:34:11'),
(94, 94, 'vay von ngan hang, giay xac nhan vay von, ngan hang chinh sach, don xin vay von', NULL, 'vi', '2026-07-11 16:34:11'),
(95, 95, 'hoc bong tuyen sinh, thu khoa, kien quoc, hoc bong dau vao, khuyen khich dau vao', NULL, 'vi', '2026-07-11 16:34:11'),
(96, 96, 'gui xe qua dem, mat xe, quen lay xe, giu xe may, bai xe mo cua den may gio', NULL, 'vi', '2026-07-11 16:34:11'),
(97, 97, 'phuc khao diem thanh phan, xem lai diem giua ky, diem qua trinh bi sai, sửa điểm', NULL, 'vi', '2026-07-11 16:34:11'),
(98, 98, 'hien mau co duoc nghi, xin nghi hoc hien mau, hoãn hoc hien mau', NULL, 'vi', '2026-07-11 16:34:11'),
(99, 99, 'doi the nhua, lam the sinh vien moi, chip the sinh vien, tich hop the ngan hang', NULL, 'vi', '2026-07-11 16:34:11'),
(100, 100, 'xoa ten doan, rut so doan, khong sinh hoat doan, dong doan phi', NULL, 'vi', '2026-07-11 16:34:11'),
(101, 101, 'bao hiem tai nan, bhtn, bi tai nan duoc den bao nhieu, ho tro nam vien', NULL, 'vi', '2026-07-11 16:34:11'),
(102, 102, 'muon loa keo, loa mic, thiet bi su kien, loa mic clb, thiet bi doan hoi', NULL, 'vi', '2026-07-11 16:34:11'),
(103, 103, 'mat bang quan su, mat giay quoc phong, cap lai chung chi gdqp, xin bang diem gdqp', NULL, 'vi', '2026-07-11 16:34:11'),
(104, 104, 'hien mau mua he, hien mau hk he, lich hien mau thang 6 thang 7', NULL, 'vi', '2026-07-11 16:34:11'),
(105, 105, 'bi canh bao may lan thi bi duoi, gioi han canh bao, canh bao hoc vu muc do 2', NULL, 'vi', '2026-07-11 16:34:11'),
(106, 106, 'gia han the thu vien, the thu vien het han, khoa the thu vien', NULL, 'vi', '2026-07-11 16:34:11'),
(107, 107, 'mien hoc the duc, khong hoc the duc bi khuyet tat, don mien giao duc the chat, gay chan, chan thuong, tai nan, dau om', NULL, 'vi', '2026-07-11 16:34:11'),
(108, 108, 'khi nao nhan bang goc, lay bang tot nghiep o dau, phat bang tot nghiep', NULL, 'vi', '2026-07-11 16:34:11'),
(109, 109, 'nop tre hoc phi, nop phat hoc phi, tre han dong tien hoc bi phat bao nhieu', NULL, 'vi', '2026-07-11 16:34:11'),
(110, 110, 'hoan thuc tap, don xin hoan thuc tap nam cuoi, doi lich di thuc tap', NULL, 'vi', '2026-07-11 16:34:11'),
(111, 111, 'tro cap kho khan, ho tro sinh vien ngheo đột xuất, tro cap xa hoi', NULL, 'vi', '2026-07-11 16:34:11'),
(112, 112, 'rot do an tot nghiep, lam lai khoa luan, rot khoa luan ra truong', NULL, 'vi', '2026-07-11 16:34:11'),
(113, 113, 'no mon co duoc hoc bong, rot mon co duoc xet hoc bong, thi lai co duoc hoc bong', NULL, 'vi', '2026-07-11 16:34:11'),
(114, 114, 'so dien thoai ban quan ly ktx, gap ai de phan anh ktx, ban quan ly noi tru', NULL, 'vi', '2026-07-11 16:34:11'),
(115, 115, 'phương thức tuyển sinh 2026, phuong thuc tuyen sinh 2026, uth xet tuyen cach nao, xet hoc ba 2026, diem thi thpt 2026', NULL, 'vi', '2026-07-11 16:34:11'),
(116, 116, 'tổ hợp môn xét tuyển, to hop mon xet tuyen, khoi thi vao uth, khoi a00 a01 d01 d07, uth xet khoi nao', NULL, 'vi', '2026-07-11 16:34:11'),
(117, 117, 'điểm chuẩn cntt 2025, diem chuan cong nghe thong tin 2025, nganh cntt uth bao nhieu diem, diem trung tuyen cntt', NULL, 'vi', '2026-07-11 16:34:11'),
(118, 118, 'điểm chuẩn logistics 2025, diem chuan logistics 2025, nganh logistics lay bao nhieu diem, diem xet tuyen logistics', NULL, 'vi', '2026-07-11 16:34:11'),
(119, 119, 'điểm chuẩn 2025, diem chuan 2025, điểm chuẩn tất cả các ngành uth, diem chuan tat ca cac nganh, điểm chuẩn uth 2025 mới nhất, điểm chuẩn năm 2025 bao nhiêu, xet tuyen ket hop 2025, diem chuan hoc ba 2025', NULL, 'vi', '2026-07-11 16:34:11'),
(120, 120, 'chỉ tiêu tuyển sinh 2026, chi tieu tuyen sinh 2026, uth tuyen bao nhieu sinh vien, chi tieu nganh cntt 2026', NULL, 'vi', '2026-07-11 16:34:11'),
(121, 121, 'quy đổi điểm ielts, quy doi diem ielts tuyen sinh, ielts 5.5 duoc may diem, cong diem ielts vao uth', NULL, 'vi', '2026-07-11 16:34:11'),
(122, 122, 'điểm sàn uth, diem san nhan ho so, bao nhieu diem thi duoc nop don, diem san 2025 2026', NULL, 'vi', '2026-07-11 16:34:11'),
(123, 123, 'đăng ký nguyện vọng, dang ky nguyen vong, ma truong uth la gi, xep nguyen vong vao uth', NULL, 'vi', '2026-07-11 16:34:11'),
(124, 124, 'lệ phí xét tuyển, le phi xet tuyen, nop tien xet hoc ba bao nhieu, dong tien nguyen vong', NULL, 'vi', '2026-07-11 16:34:11'),
(125, 125, 'khi nào biết kết quả trúng tuyển, khi nao biet ket qua trung tuyen, lich cong bo diem chuan uth', NULL, 'vi', '2026-07-11 16:34:11'),
(126, 126, 'xác nhận nhập học, xac nhan nhap hoc online, huong dan nhap hoc uth, khong xac nhan nhap hoc bi gi', NULL, 'vi', '2026-07-11 16:34:11'),
(127, 127, 'hồ sơ nhập học cần gì, ho so nhap hoc can gi, mang theo gi khi nhap hoc uth, giay to nhap hoc', NULL, 'vi', '2026-07-11 16:34:11'),
(128, 128, 'quy trình nhập học trực tiếp, quy trinh nhap hoc truc tiep, den truong nhap hoc o dau, huong dan tan sinh vien', NULL, 'vi', '2026-07-11 16:34:11'),
(129, 129, 'rút học phí nhập học, rut hoc phi nhap hoc, nhap hoc roi xin rut lai tien, thoi hoc rut lai hoc phi', NULL, 'vi', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `knowledge_sources`
--

CREATE TABLE `knowledge_sources` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `source_type` enum('official_web','regulation','announcement','faq','manual','uploaded_document','database','other') NOT NULL,
  `title` varchar(500) NOT NULL,
  `organization` varchar(255) DEFAULT 'UTH',
  `document_number` varchar(100) DEFAULT NULL,
  `source_url` varchar(1000) DEFAULT NULL,
  `file_path` varchar(1000) DEFAULT NULL,
  `mime_type` varchar(150) DEFAULT NULL,
  `checksum_sha256` char(64) DEFAULT NULL,
  `issued_date` date DEFAULT NULL,
  `retrieved_at` datetime DEFAULT NULL,
  `is_official` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','inactive','superseded','deleted') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `knowledge_sources`
--

INSERT INTO `knowledge_sources` (`id`, `source_type`, `title`, `organization`, `document_number`, `source_url`, `file_path`, `mime_type`, `checksum_sha256`, `issued_date`, `retrieved_at`, `is_official`, `status`, `created_at`, `updated_at`) VALUES
(1, 'faq', 'Legacy enriched FAQ import 2026-07-10', 'UTH Chatbot project', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'active', '2026-07-11 16:34:11', '2026-07-11 16:34:11'),
(2, 'official_web', 'Portal UTH - dữ liệu mẫu đã kiểm duyệt', 'UTH', NULL, 'https://portal.ut.edu.vn', NULL, NULL, NULL, NULL, '2026-07-11 16:34:11', 1, 'active', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `programs`
--

CREATE TABLE `programs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `faculty_id` bigint(20) UNSIGNED DEFAULT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `degree_level` enum('college','bachelor','engineer','master','doctorate','other') NOT NULL DEFAULT 'bachelor',
  `education_type` varchar(100) DEFAULT NULL,
  `specialization` varchar(255) DEFAULT NULL,
  `total_credits` smallint(5) UNSIGNED DEFAULT NULL,
  `standard_duration_semesters` tinyint(3) UNSIGNED DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `programs`
--

INSERT INTO `programs` (`id`, `faculty_id`, `code`, `name`, `degree_level`, `education_type`, `specialization`, `total_credits`, `standard_duration_semesters`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'CNTT-CLC-2023', 'Công nghệ thông tin', 'bachelor', 'Chất lượng cao', 'Công nghệ thông tin', 120, 8, 'active', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `rag_retrieval_logs`
--

CREATE TABLE `rag_retrieval_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_message_id` bigint(20) UNSIGNED NOT NULL,
  `article_id` bigint(20) UNSIGNED DEFAULT NULL,
  `chunk_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rank_position` smallint(5) UNSIGNED DEFAULT NULL,
  `keyword_score` decimal(10,6) DEFAULT NULL,
  `semantic_score` decimal(10,6) DEFAULT NULL,
  `metadata_score` decimal(10,6) DEFAULT NULL,
  `freshness_score` decimal(10,6) DEFAULT NULL,
  `final_score` decimal(10,6) DEFAULT NULL,
  `selected_for_context` tinyint(1) NOT NULL DEFAULT 0,
  `rejection_reason` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `rag_retrieval_logs`
--

INSERT INTO `rag_retrieval_logs` (`id`, `user_message_id`, `article_id`, `chunk_id`, `rank_position`, `keyword_score`, `semantic_score`, `metadata_score`, `freshness_score`, `final_score`, `selected_for_context`, `rejection_reason`, `created_at`) VALUES
(1, 7, 257, 257, 1, 0.810150, NULL, 0.100000, 0.030000, 0.868627, 1, NULL, '2026-07-11 16:57:21'),
(2, 25, 256, 256, 1, 0.380106, NULL, 0.080000, 0.030000, 0.483090, 0, 'below_min_final_score', '2026-07-20 19:29:07'),
(3, 27, 257, 257, 1, 0.250000, NULL, 0.080000, 0.030000, 0.372500, 0, 'below_min_final_score', '2026-07-20 19:29:27'),
(4, 27, NULL, NULL, 101, 1.000000, NULL, 0.000000, 0.020000, 0.815000, 1, NULL, '2026-07-20 19:29:27'),
(5, 29, NULL, NULL, 101, 0.000000, NULL, 0.900000, 0.020000, 0.900000, 1, NULL, '2026-07-20 19:29:39'),
(6, 29, NULL, NULL, 102, 0.000000, NULL, 0.900000, 0.020000, 0.900000, 1, NULL, '2026-07-20 19:29:39'),
(7, 29, NULL, NULL, 103, 0.000000, NULL, 0.900000, 0.020000, 0.900000, 1, NULL, '2026-07-20 19:29:39'),
(8, 29, NULL, NULL, 104, 0.000000, NULL, 0.900000, 0.020000, 0.900000, 1, NULL, '2026-07-20 19:29:39'),
(9, 29, NULL, NULL, 105, 0.000000, NULL, 0.900000, 0.020000, 0.900000, 1, NULL, '2026-07-20 19:29:39'),
(10, 39, 256, 256, 1, 1.000000, NULL, 0.080000, 0.030000, 1.000000, 1, NULL, '2026-07-21 04:01:10'),
(11, 39, 257, 257, 2, 0.250000, NULL, 0.080000, 0.030000, 0.372500, 0, 'below_min_final_score', '2026-07-21 04:01:10'),
(12, 39, NULL, NULL, 101, 0.750000, NULL, 0.000000, 0.020000, 0.605000, 1, NULL, '2026-07-21 04:01:10'),
(13, 39, NULL, NULL, 102, 0.750000, NULL, 0.000000, 0.020000, 0.535000, 1, NULL, '2026-07-21 04:01:10'),
(14, 41, 256, 256, 1, 0.335369, NULL, 0.080000, 0.030000, 0.445064, 0, 'below_min_final_score', '2026-07-21 04:01:22'),
(15, 43, 256, 256, 1, 1.000000, NULL, 0.080000, 0.030000, 1.000000, 1, NULL, '2026-07-21 04:01:35'),
(16, 43, 257, 257, 2, 0.250000, NULL, 0.080000, 0.030000, 0.372500, 0, 'below_min_final_score', '2026-07-21 04:01:35'),
(17, 43, NULL, NULL, 101, 0.750000, NULL, 0.000000, 0.020000, 0.605000, 1, NULL, '2026-07-21 04:01:35'),
(18, 43, NULL, NULL, 102, 0.750000, NULL, 0.000000, 0.020000, 0.535000, 1, NULL, '2026-07-21 04:01:35'),
(19, 49, 256, 256, 1, 1.000000, NULL, 0.080000, 0.030000, 1.000000, 1, NULL, '2026-07-21 04:02:20'),
(20, 49, 257, 257, 2, 0.250000, NULL, 0.080000, 0.030000, 0.372500, 0, 'below_min_final_score', '2026-07-21 04:02:20'),
(21, 49, NULL, NULL, 101, 1.000000, NULL, 0.000000, 0.020000, 0.805000, 1, NULL, '2026-07-21 04:02:20'),
(22, 49, NULL, NULL, 102, 1.000000, NULL, 0.000000, 0.020000, 0.735000, 1, NULL, '2026-07-21 04:02:20'),
(23, 55, 61, 61, 1, 0.500000, NULL, 0.000000, 0.030000, 0.465000, 0, 'below_min_final_score', '2026-07-23 13:52:53'),
(24, 55, 60, 60, 2, 0.250000, NULL, 0.000000, 0.030000, 0.252500, 0, 'below_min_final_score', '2026-07-23 13:52:53'),
(25, 55, 256, 256, 3, 0.250000, NULL, 0.080000, 0.030000, 0.372500, 0, 'below_min_final_score', '2026-07-23 13:52:53'),
(26, 63, 61, 61, 1, 1.000000, NULL, 0.000000, 0.030000, 0.890000, 1, NULL, '2026-08-01 18:14:28'),
(27, 63, 60, 60, 2, 0.679554, NULL, 0.000000, 0.030000, 0.617621, 0, 'below_min_final_score', '2026-08-01 18:14:28'),
(28, 65, 61, 61, 1, 0.250000, NULL, 0.000000, 0.030000, 0.252500, 0, 'below_min_final_score', '2026-08-01 18:14:41'),
(29, 67, 61, 61, 1, 0.500000, NULL, 0.000000, 0.030000, 0.465000, 0, 'below_min_final_score', '2026-08-01 18:14:50'),
(30, 67, 60, 60, 2, 0.250000, NULL, 0.000000, 0.030000, 0.252500, 0, 'below_min_final_score', '2026-08-01 18:14:50'),
(31, 69, NULL, NULL, 101, 1.000000, NULL, 0.000000, 0.020000, 0.840000, 1, NULL, '2026-08-01 18:15:01');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `roles`
--

CREATE TABLE `roles` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `roles`
--

INSERT INTO `roles` (`id`, `code`, `name`, `description`) VALUES
(1, 'student', 'Sinh viên', 'Người dùng sinh viên'),
(2, 'admin', 'Quản trị viên', 'Quản trị toàn hệ thống'),
(3, 'staff', 'Nhân viên', 'Nhân viên phòng ban hỗ trợ'),
(4, 'knowledge_reviewer', 'Kiểm duyệt kiến thức', 'Xác minh nguồn và nội dung RAG');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `search_synonyms`
--

CREATE TABLE `search_synonyms` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `canonical_term` varchar(255) NOT NULL,
  `synonym_term` varchar(255) NOT NULL,
  `category` varchar(120) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `search_synonyms`
--

INSERT INTO `search_synonyms` (`id`, `canonical_term`, `synonym_term`, `category`, `is_active`) VALUES
(1, 'đăng ký học phần', 'đăng ký môn', 'hoc_vu', 1),
(2, 'đăng ký học phần', 'dkhp', 'hoc_vu', 1),
(3, 'mã số sinh viên', 'mssv', 'sinh_vien', 1),
(4, 'học phí', 'công nợ', 'hoc_phi', 1),
(5, 'thời khóa biểu', 'tkb', 'lich_hoc', 1),
(6, 'điểm trung bình tích lũy', 'gpa', 'diem', 1),
(7, 'phúc khảo', 'xem lại điểm', 'thi_cu', 1),
(8, 'bảo lưu', 'tạm dừng học', 'hoc_vu', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `semesters`
--

CREATE TABLE `semesters` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `academic_year_id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(100) NOT NULL,
  `semester_number` tinyint(3) UNSIGNED DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `registration_start` datetime DEFAULT NULL,
  `registration_end` datetime DEFAULT NULL,
  `tuition_due_date` datetime DEFAULT NULL,
  `is_current` tinyint(1) NOT NULL DEFAULT 0
) ;

--
-- Đang đổ dữ liệu cho bảng `semesters`
--

INSERT INTO `semesters` (`id`, `academic_year_id`, `code`, `name`, `semester_number`, `start_date`, `end_date`, `registration_start`, `registration_end`, `tuition_due_date`, `is_current`) VALUES
(1, 1, 'HK_HE_2026', 'Học kỳ hè năm học 2025-2026', 3, '2026-06-01', '2026-07-31', '2026-06-01 08:00:00', '2026-06-15 17:00:00', '2026-07-20 17:00:00', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `student_profiles`
--

CREATE TABLE `student_profiles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `student_code` varchar(50) NOT NULL,
  `program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `cohort_year` smallint(5) UNSIGNED DEFAULT NULL,
  `class_code` varchar(50) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female','other','undisclosed') DEFAULT NULL,
  `place_of_birth` varchar(255) DEFAULT NULL,
  `citizen_id` varchar(30) DEFAULT NULL,
  `permanent_address` text DEFAULT NULL,
  `current_address` text DEFAULT NULL,
  `enrollment_date` date DEFAULT NULL,
  `expected_graduation_date` date DEFAULT NULL,
  `academic_status` enum('studying','reserved','graduated','suspended','withdrawn','dismissed') NOT NULL DEFAULT 'studying',
  `advisor_name` varchar(150) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `student_profiles`
--

INSERT INTO `student_profiles` (`id`, `user_id`, `student_code`, `program_id`, `cohort_year`, `class_code`, `date_of_birth`, `gender`, `place_of_birth`, `citizen_id`, `permanent_address`, `current_address`, `enrollment_date`, `expected_graduation_date`, `academic_status`, `advisor_name`, `created_at`, `updated_at`) VALUES
(1, 2, '075205019210', 1, 2023, 'CNTT2023', '2005-06-07', 'male', 'Đồng Tháp', NULL, NULL, NULL, '2023-09-05', '2027-08-31', 'studying', 'ThS. Nguyễn Minh Khoa', '2026-07-11 16:34:11', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `subjects`
--

CREATE TABLE `subjects` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `code` varchar(50) NOT NULL,
  `name` varchar(255) NOT NULL,
  `credits` tinyint(3) UNSIGNED NOT NULL,
  `theory_periods` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `practice_periods` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `faculty_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `subjects`
--

INSERT INTO `subjects` (`id`, `code`, `name`, `credits`, `theory_periods`, `practice_periods`, `faculty_id`, `description`, `status`) VALUES
(1, 'MOB101', 'Lập trình thiết bị di động', 3, 30, 30, 1, 'Xây dựng ứng dụng di động cơ bản và tích hợp API.', 'active'),
(2, 'ECOM201', 'Thương mại điện tử', 3, 30, 15, 1, 'Nền tảng thương mại điện tử và vận hành kênh bán hàng số.', 'active'),
(3, 'NET301', 'Lập trình mạng', 3, 30, 30, 1, 'Socket, giao thức mạng và ứng dụng client-server.', 'active'),
(4, 'POL101', 'Lịch sử Đảng Cộng sản Việt Nam', 2, 30, 0, 1, 'Kiến thức nền tảng về lịch sử Đảng Cộng sản Việt Nam.', 'active'),
(5, 'DST401', 'Lập trình phân tán', 3, 30, 30, 1, 'Kiến trúc phân tán, RPC, message queue và dịch vụ web.', 'active'),
(6, 'PM401', 'Quản trị dự án phần mềm', 3, 30, 15, 1, 'Lập kế hoạch, quản lý rủi ro và theo dõi tiến độ dự án phần mềm.', 'active');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `subject_prerequisites`
--

CREATE TABLE `subject_prerequisites` (
  `subject_id` bigint(20) UNSIGNED NOT NULL,
  `prerequisite_subject_id` bigint(20) UNSIGNED NOT NULL,
  `requirement_type` enum('prerequisite','corequisite','previous') NOT NULL DEFAULT 'prerequisite',
  `minimum_letter_grade` varchar(5) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `system_notifications`
-- (See below for the actual view)
--
CREATE TABLE `system_notifications` (
`id` bigint(20) unsigned
,`title` varchar(255)
,`content` longtext
,`type` varchar(5)
,`created_at` datetime
);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_key` varchar(120) NOT NULL,
  `setting_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`setting_value`)),
  `description` varchar(500) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT 0,
  `updated_by` bigint(20) UNSIGNED DEFAULT NULL,
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `system_settings`
--

INSERT INTO `system_settings` (`setting_key`, `setting_value`, `description`, `is_public`, `updated_by`, `updated_at`) VALUES
('chatbot.fallback_message', '{\"vi\": \"Mình chưa tìm thấy thông tin đủ chính xác trong hệ thống. Bạn có thể cung cấp thêm học kỳ, năm học hoặc tạo ticket hỗ trợ.\"}', 'Câu trả lời khi thiếu context', 1, NULL, '2026-07-11 16:34:11'),
('rag.max_context_chunks', '{\"value\": 5}', 'Số chunk tối đa gửi tới Gemini', 0, NULL, '2026-07-11 16:34:11'),
('rag.min_final_score', '{\"value\": 0.62}', 'Ngưỡng tối thiểu để dùng context RAG', 0, NULL, '2026-07-11 16:34:11'),
('rag.require_verified', '{\"value\": true}', 'Chỉ dùng kiến thức đã kiểm duyệt', 0, NULL, '2026-07-11 16:34:11'),
('security.max_login_attempts', '{\"value\": 5}', 'Số lần đăng nhập sai trước khi khóa tạm thời', 0, NULL, '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tickets`
--

CREATE TABLE `tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ticket_number` varchar(30) NOT NULL,
  `student_id` bigint(20) UNSIGNED DEFAULT NULL,
  `requester_name` varchar(150) NOT NULL,
  `requester_student_code` varchar(50) DEFAULT NULL,
  `category` varchar(120) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `description` longtext NOT NULL,
  `priority` enum('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `status` enum('open','in_progress','waiting_student','resolved','closed','cancelled') NOT NULL DEFAULT 'open',
  `assigned_to` bigint(20) UNSIGNED DEFAULT NULL,
  `source_chat_session_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `resolved_at` datetime DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tickets`
--

INSERT INTO `tickets` (`id`, `ticket_number`, `student_id`, `requester_name`, `requester_student_code`, `category`, `subject`, `description`, `priority`, `status`, `assigned_to`, `source_chat_session_id`, `created_at`, `updated_at`, `resolved_at`, `closed_at`) VALUES
(1, 'TK20260722175643149', 1, 'Phạm Anh Tuấn', '075205019210', 'chatbot', '[Báo lỗi Chatbot] Câu trả lời không chính xác', 'CÂU HỎI CỦA SINH VIÊN:\nnono\n\nCÂU TRẢ LỜI CỦA CHATBOT:\n<strong>Mình chưa chắc bạn đang muốn hỏi gì.</strong><br>Để mình hỗ trợ đúng hơn, bạn có thể nói rõ một trong các hướng sau: lịch học, lịch thi, học phí, điểm, thông báo, hoặc nhập lại câu hỏi theo cách ngắn hơn một chút.', 'normal', 'closed', NULL, 3, '2026-07-22 22:56:43', '2026-07-22 22:58:05', NULL, '2026-07-22 22:58:05'),
(2, 'TK-20260722-9CC6', 1, 'Phạm Anh Tuấn', '075205019210', NULL, 'tạo ticket', 'tạo ticket', 'normal', 'resolved', NULL, 3, '2026-07-22 22:57:02', '2026-07-22 22:58:39', '2026-07-22 22:58:39', NULL),
(3, 'TK-20260723-1F9C', 1, 'Phạm Anh Tuấn', '075205019210', NULL, 'tạo ticket vấn đề vị trí trường học', 'tạo ticket vấn đề vị trí trường học', 'normal', 'closed', NULL, 3, '2026-07-23 13:53:57', '2026-07-23 13:56:16', NULL, '2026-07-23 13:56:16');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ticket_attachments`
--

CREATE TABLE `ticket_attachments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ticket_message_id` bigint(20) UNSIGNED NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `stored_path` varchar(1000) NOT NULL,
  `mime_type` varchar(150) DEFAULT NULL,
  `size_bytes` bigint(20) UNSIGNED DEFAULT NULL,
  `checksum_sha256` char(64) DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `ticket_messages`
--

CREATE TABLE `ticket_messages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `sender_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `sender_role` enum('student','admin','system') NOT NULL,
  `message` longtext NOT NULL,
  `is_internal_note` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `ticket_messages`
--

INSERT INTO `ticket_messages` (`id`, `ticket_id`, `sender_user_id`, `sender_role`, `message`, `is_internal_note`, `created_at`) VALUES
(1, 2, 2, 'student', 'tạo ticket', 0, '2026-07-22 22:57:02'),
(2, 2, 1, 'admin', 'hmmmmmmm', 0, '2026-07-22 22:57:30'),
(3, 2, 2, 'student', 'jj', 0, '2026-07-22 22:58:36'),
(4, 3, 2, 'student', 'tạo ticket vấn đề vị trí trường học', 0, '2026-07-23 13:53:57'),
(5, 3, 1, 'admin', 'vị trí ở võ oanh bình thạnh', 0, '2026-07-23 13:54:42');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tuition_extension_requests`
--

CREATE TABLE `tuition_extension_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `reason` text NOT NULL,
  `requested_due_date` date DEFAULT NULL,
  `status` enum('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `reviewer_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewer_note` text DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tuition_invoices`
--

CREATE TABLE `tuition_invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `invoice_number` varchar(60) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `subtotal` decimal(15,2) NOT NULL DEFAULT 0.00,
  `discount_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `outstanding_amount` decimal(15,2) GENERATED ALWAYS AS (greatest(`subtotal` - `discount_amount` - `paid_amount`,0)) STORED,
  `currency` char(3) NOT NULL DEFAULT 'VND',
  `due_date` datetime DEFAULT NULL,
  `status` enum('draft','unpaid','partially_paid','paid','overdue','cancelled','waived') NOT NULL DEFAULT 'unpaid',
  `issued_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tuition_invoices`
--

INSERT INTO `tuition_invoices` (`id`, `student_id`, `semester_id`, `invoice_number`, `description`, `subtotal`, `discount_amount`, `paid_amount`, `currency`, `due_date`, `status`, `issued_at`, `updated_at`) VALUES
(1, 1, 1, 'HP-075205019210-HE2026', 'Học phí học kỳ hè năm học 2025-2026', 17640000.00, 0.00, 8000000.00, 'VND', '2026-07-20 17:00:00', 'partially_paid', '2026-06-20 08:30:00', '2026-07-11 16:34:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tuition_invoice_items`
--

CREATE TABLE `tuition_invoice_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `item_type` enum('tuition_credit','insurance','service','penalty','other') NOT NULL,
  `reference_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(10,2) NOT NULL DEFAULT 1.00,
  `unit_price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `amount` decimal(15,2) GENERATED ALWAYS AS (`quantity` * `unit_price`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `tuition_invoice_items`
--

INSERT INTO `tuition_invoice_items` (`id`, `invoice_id`, `item_type`, `reference_id`, `description`, `quantity`, `unit_price`) VALUES
(1, 1, 'tuition_credit', NULL, '18 tín chỉ chương trình chất lượng cao', 18.00, 980000.00),
(2, 1, 'service', NULL, 'Phí dịch vụ sinh viên học kỳ hè', 1.00, 0.00);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tuition_payments`
--

CREATE TABLE `tuition_payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `invoice_id` bigint(20) UNSIGNED NOT NULL,
  `transaction_code` varchar(100) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `payment_method` enum('bank_transfer','payment_gateway','cash','scholarship','waiver','other') NOT NULL,
  `payment_status` enum('pending','success','failed','refunded') NOT NULL DEFAULT 'pending',
  `paid_at` datetime DEFAULT NULL,
  `gateway_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`gateway_payload`)),
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `unanswered_questions`
--

CREATE TABLE `unanswered_questions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_message_id` bigint(20) UNSIGNED DEFAULT NULL,
  `normalized_question` text NOT NULL,
  `detected_intent` varchar(120) DEFAULT NULL,
  `occurrence_count` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `status` enum('new','reviewing','resolved','ignored') NOT NULL DEFAULT 'new',
  `resolved_article_id` bigint(20) UNSIGNED DEFAULT NULL,
  `first_seen_at` datetime NOT NULL DEFAULT current_timestamp(),
  `last_seen_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `unanswered_questions`
--

INSERT INTO `unanswered_questions` (`id`, `user_message_id`, `normalized_question`, `detected_intent`, `occurrence_count`, `status`, `resolved_article_id`, `first_seen_at`, `last_seen_at`) VALUES
(1, 1, 'ngay mai minh co lich hoc gi', 'personal_schedule', 1, 'new', NULL, '2026-07-11 16:56:53', '2026-07-11 16:56:53'),
(2, 23, 'hom nay ngay nhieu', 'academic_knowledge', 1, 'new', NULL, '2026-07-20 19:28:47', '2026-07-20 19:28:47'),
(3, 25, 'truong minh ai day mon lap trinh may tinh', 'academic_knowledge', 1, 'new', NULL, '2026-07-20 19:29:07', '2026-07-20 19:29:07'),
(4, 41, 'toi muon huy mon lap trinh mang', 'academic_knowledge', 1, 'new', NULL, '2026-07-21 04:01:22', '2026-07-21 04:01:22'),
(5, 45, 'co toi muon', 'academic_knowledge', 1, 'new', NULL, '2026-07-21 04:01:50', '2026-07-21 04:01:50'),
(6, 47, 'toi muon huy', 'academic_knowledge', 1, 'new', NULL, '2026-07-21 04:02:01', '2026-07-21 04:02:01'),
(7, 51, 'nono', 'academic_knowledge', 1, 'new', NULL, '2026-07-22 22:56:35', '2026-07-22 22:56:35'),
(8, 55, 'truong hutech co gan uth khong', 'academic_knowledge', 1, 'new', NULL, '2026-07-23 13:52:53', '2026-07-23 13:52:53'),
(9, 65, 'uth a', 'academic_knowledge', 1, 'new', NULL, '2026-08-01 18:14:41', '2026-08-01 18:14:41'),
(10, 67, 'vi tri truong uth', 'academic_knowledge', 1, 'new', NULL, '2026-08-01 18:14:50', '2026-08-01 18:14:50');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `uploaded_documents`
--

CREATE TABLE `uploaded_documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uploaded_by` bigint(20) UNSIGNED DEFAULT NULL,
  `original_name` varchar(255) NOT NULL,
  `stored_path` varchar(1000) NOT NULL,
  `mime_type` varchar(150) DEFAULT NULL,
  `size_bytes` bigint(20) UNSIGNED DEFAULT NULL,
  `checksum_sha256` char(64) DEFAULT NULL,
  `processing_status` enum('uploaded','extracting','chunking','ready','failed') NOT NULL DEFAULT 'uploaded',
  `extracted_text` longtext DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `processed_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `username` varchar(80) NOT NULL,
  `email` varchar(190) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role_id` tinyint(3) UNSIGNED NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `avatar_url` varchar(500) DEFAULT NULL,
  `status` enum('active','inactive','locked','pending') NOT NULL DEFAULT 'active',
  `email_verified_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Đang đổ dữ liệu cho bảng `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `role_id`, `full_name`, `phone`, `avatar_url`, `status`, `email_verified_at`, `last_login_at`, `password_changed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'admin', 'admin@ut.edu.vn', '$2y$10$W2oozq4/9JIhil22lbWxV.rLBEBMNEemaKAJ6ENmumvOEqMJMseBW', 2, 'Ban Quản trị UTH', NULL, NULL, 'active', NULL, '2026-08-01 18:15:22', '2026-07-11 16:57:47', '2026-07-11 16:34:11', '2026-08-01 18:15:22', NULL),
(2, '075205019210', '075205019210@student.ut.edu.vn', '$2y$10$OWYB7T6e.0YS3FVTNjJTZ.atjXEnVZQHdxWiFDlnEDYTQbDRzFSEe', 1, 'Phạm Anh Tuấn', NULL, NULL, 'active', NULL, '2026-08-01 18:13:56', '2026-07-11 16:56:28', '2026-07-11 16:34:11', '2026-08-01 18:13:56', NULL);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_active_verified_knowledge`
-- (See below for the actual view)
--
CREATE TABLE `v_active_verified_knowledge` (
`id` bigint(20) unsigned
,`title` varchar(500)
,`category` varchar(120)
,`subcategory` varchar(120)
,`intent_code` varchar(120)
,`keywords` text
,`answer_content` longtext
,`route_url` varchar(1000)
,`audience` enum('all','prospective_student','student','lecturer','staff','parent')
,`faculty_id` bigint(20) unsigned
,`program_id` bigint(20) unsigned
,`cohort_from` smallint(5) unsigned
,`cohort_to` smallint(5) unsigned
,`semester_code` varchar(30)
,`academic_year_code` varchar(20)
,`valid_from` datetime
,`valid_until` datetime
,`priority` tinyint(3) unsigned
,`confidence_level` enum('low','medium','high','authoritative')
,`source_title` varchar(500)
,`source_url` varchar(1000)
,`document_number` varchar(100)
,`issued_date` date
);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_chat_quality_summary`
-- (See below for the actual view)
--
CREATE TABLE `v_chat_quality_summary` (
`report_date` date
,`assistant_messages` bigint(21)
,`insufficient_context_count` decimal(23,0)
,`average_confidence` decimal(12,10)
,`thumbs_up` decimal(23,0)
,`thumbs_down` decimal(23,0)
);

-- --------------------------------------------------------

--
-- Cấu trúc đóng vai cho view `v_unpaid_tuition`
-- (See below for the actual view)
--
CREATE TABLE `v_unpaid_tuition` (
`id` bigint(20) unsigned
,`student_code` varchar(50)
,`full_name` varchar(150)
,`academic_year` varchar(20)
,`semester` varchar(100)
,`invoice_number` varchar(60)
,`subtotal` decimal(15,2)
,`discount_amount` decimal(15,2)
,`paid_amount` decimal(15,2)
,`outstanding_amount` decimal(15,2)
,`due_date` datetime
,`status` enum('draft','unpaid','partially_paid','paid','overdue','cancelled','waived')
);

-- --------------------------------------------------------

--
-- Cấu trúc cho view `class_schedules`
--
DROP TABLE IF EXISTS `class_schedules`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `class_schedules`  AS SELECT `css`.`id` AS `id`, `sp`.`student_code` AS `mssv`, `s`.`name` AS `subject_name`, coalesce(`css`.`room`,'') AS `room`, `css`.`day_of_week` AS `day_of_week`, `css`.`start_time` AS `start_time`, `css`.`end_time` AS `end_time` FROM ((((`class_schedule_sessions` `css` join `course_sections` `cs` on(`cs`.`id` = `css`.`course_section_id`)) join `subjects` `s` on(`s`.`id` = `cs`.`subject_id`)) join `enrollments` `e` on(`e`.`course_section_id` = `cs`.`id`)) join `student_profiles` `sp` on(`sp`.`id` = `e`.`student_id`)) WHERE `e`.`enrollment_status` in ('registered','studying') ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `system_notifications`
--
DROP TABLE IF EXISTS `system_notifications`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `system_notifications`  AS SELECT `announcements`.`id` AS `id`, `announcements`.`title` AS `title`, `announcements`.`content` AS `content`, CASE WHEN `announcements`.`announcement_type` = 'event' THEN 'event' ELSE 'news' END AS `type`, coalesce(`announcements`.`published_at`,`announcements`.`created_at`) AS `created_at` FROM `announcements` WHERE `announcements`.`status` = 'published' AND (`announcements`.`expires_at` is null OR `announcements`.`expires_at` >= current_timestamp()) ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_active_verified_knowledge`
--
DROP TABLE IF EXISTS `v_active_verified_knowledge`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_active_verified_knowledge`  AS SELECT `ka`.`id` AS `id`, `ka`.`title` AS `title`, `ka`.`category` AS `category`, `ka`.`subcategory` AS `subcategory`, `ka`.`intent_code` AS `intent_code`, `ka`.`keywords` AS `keywords`, `ka`.`answer_content` AS `answer_content`, `ka`.`route_url` AS `route_url`, `ka`.`audience` AS `audience`, `ka`.`faculty_id` AS `faculty_id`, `ka`.`program_id` AS `program_id`, `ka`.`cohort_from` AS `cohort_from`, `ka`.`cohort_to` AS `cohort_to`, `ka`.`semester_code` AS `semester_code`, `ka`.`academic_year_code` AS `academic_year_code`, `ka`.`valid_from` AS `valid_from`, `ka`.`valid_until` AS `valid_until`, `ka`.`priority` AS `priority`, `ka`.`confidence_level` AS `confidence_level`, `ks`.`title` AS `source_title`, `ks`.`source_url` AS `source_url`, `ks`.`document_number` AS `document_number`, `ks`.`issued_date` AS `issued_date` FROM (`knowledge_articles` `ka` left join `knowledge_sources` `ks` on(`ks`.`id` = `ka`.`source_id`)) WHERE `ka`.`verification_status` = 'verified' AND `ka`.`deleted_at` is null AND (`ka`.`valid_from` is null OR `ka`.`valid_from` <= current_timestamp()) AND (`ka`.`valid_until` is null OR `ka`.`valid_until` >= current_timestamp()) AND (`ks`.`id` is null OR `ks`.`status` = 'active') ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_chat_quality_summary`
--
DROP TABLE IF EXISTS `v_chat_quality_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_chat_quality_summary`  AS SELECT cast(`cm`.`created_at` as date) AS `report_date`, count(0) AS `assistant_messages`, sum(`cm`.`answer_status` = 'insufficient_context') AS `insufficient_context_count`, avg(`cm`.`confidence_score`) AS `average_confidence`, sum(`cf`.`rating` = 'up') AS `thumbs_up`, sum(`cf`.`rating` = 'down') AS `thumbs_down` FROM (`chat_messages` `cm` left join `chat_feedback` `cf` on(`cf`.`message_id` = `cm`.`id`)) WHERE `cm`.`sender_type` = 'assistant' GROUP BY cast(`cm`.`created_at` as date) ;

-- --------------------------------------------------------

--
-- Cấu trúc cho view `v_unpaid_tuition`
--
DROP TABLE IF EXISTS `v_unpaid_tuition`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_unpaid_tuition`  AS SELECT `ti`.`id` AS `id`, `sp`.`student_code` AS `student_code`, `u`.`full_name` AS `full_name`, `ay`.`code` AS `academic_year`, `sem`.`name` AS `semester`, `ti`.`invoice_number` AS `invoice_number`, `ti`.`subtotal` AS `subtotal`, `ti`.`discount_amount` AS `discount_amount`, `ti`.`paid_amount` AS `paid_amount`, `ti`.`outstanding_amount` AS `outstanding_amount`, `ti`.`due_date` AS `due_date`, `ti`.`status` AS `status` FROM ((((`tuition_invoices` `ti` join `student_profiles` `sp` on(`sp`.`id` = `ti`.`student_id`)) join `users` `u` on(`u`.`id` = `sp`.`user_id`)) join `semesters` `sem` on(`sem`.`id` = `ti`.`semester_id`)) join `academic_years` `ay` on(`ay`.`id` = `sem`.`academic_year_id`)) WHERE `ti`.`status` in ('unpaid','partially_paid','overdue') ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `academic_deadlines`
--
ALTER TABLE `academic_deadlines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_deadline_semester` (`semester_id`),
  ADD KEY `idx_deadline_due` (`status`,`due_at`);
ALTER TABLE `academic_deadlines` ADD FULLTEXT KEY `ft_deadline_search` (`title`,`description`);

--
-- Chỉ mục cho bảng `academic_years`
--
ALTER TABLE `academic_years`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Chỉ mục cho bảng `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `fk_announcement_publisher` (`published_by`),
  ADD KEY `idx_announcement_live` (`status`,`published_at`,`expires_at`);
ALTER TABLE `announcements` ADD FULLTEXT KEY `ft_announcement_search` (`title`,`summary`,`content`);

--
-- Chỉ mục cho bảng `announcement_audiences`
--
ALTER TABLE `announcement_audiences`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_audience_announcement` (`announcement_id`),
  ADD KEY `idx_audience_lookup` (`audience_type`,`audience_value`);

--
-- Chỉ mục cho bảng `api_usage_logs`
--
ALTER TABLE `api_usage_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_api_usage_user` (`user_id`),
  ADD KEY `idx_api_usage_provider_time` (`provider`,`created_at`);

--
-- Chỉ mục cho bảng `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_user_time` (`user_id`,`created_at`);

--
-- Chỉ mục cho bảng `chat_feedback`
--
ALTER TABLE `chat_feedback`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_feedback_user_message` (`message_id`,`user_id`),
  ADD KEY `fk_feedback_user` (`user_id`);

--
-- Chỉ mục cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_message_parent` (`parent_message_id`),
  ADD KEY `idx_message_session_time` (`session_id`,`created_at`);
ALTER TABLE `chat_messages` ADD FULLTEXT KEY `ft_chat_content` (`content`,`normalized_content`);

--
-- Chỉ mục cho bảng `chat_sessions`
--
ALTER TABLE `chat_sessions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `session_uuid` (`session_uuid`),
  ADD KEY `idx_chat_user_activity` (`user_id`,`last_activity_at`);

--
-- Chỉ mục cho bảng `class_schedule_sessions`
--
ALTER TABLE `class_schedule_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_schedule_section` (`course_section_id`),
  ADD KEY `idx_schedule_day_time` (`day_of_week`,`start_time`);

--
-- Chỉ mục cho bảng `course_sections`
--
ALTER TABLE `course_sections`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_section_semester_code` (`semester_id`,`section_code`),
  ADD KEY `idx_section_subject` (`subject_id`);

--
-- Chỉ mục cho bảng `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_student_section` (`student_id`,`course_section_id`),
  ADD KEY `fk_enrollment_section` (`course_section_id`),
  ADD KEY `idx_enrollment_status` (`enrollment_status`);

--
-- Chỉ mục cho bảng `exam_schedules`
--
ALTER TABLE `exam_schedules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_exam_section` (`course_section_id`),
  ADD KEY `idx_exam_date` (`exam_date`,`start_time`);

--
-- Chỉ mục cho bảng `faculties`
--
ALTER TABLE `faculties`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Chỉ mục cho bảng `faq`
--
ALTER TABLE `faq`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_topic_group` (`topic_group`),
  ADD KEY `idx_priority` (`priority`);
ALTER TABLE `faq` ADD FULLTEXT KEY `ft_keywords_answer` (`tu_khoa`,`noi_dung`,`variations`);

--
-- Chỉ mục cho bảng `grades`
--
ALTER TABLE `grades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `enrollment_id` (`enrollment_id`);

--
-- Chỉ mục cho bảng `knowledge_articles`
--
ALTER TABLE `knowledge_articles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ka_source` (`source_id`),
  ADD KEY `fk_ka_faculty` (`faculty_id`),
  ADD KEY `fk_ka_program` (`program_id`),
  ADD KEY `fk_ka_creator` (`created_by`),
  ADD KEY `fk_ka_reviewer` (`reviewed_by`),
  ADD KEY `idx_knowledge_filter` (`verification_status`,`category`,`valid_from`,`valid_until`),
  ADD KEY `idx_knowledge_intent` (`intent_code`),
  ADD KEY `idx_knowledge_priority` (`priority`);
ALTER TABLE `knowledge_articles` ADD FULLTEXT KEY `ft_knowledge_search` (`title`,`keywords`,`answer_content`);

--
-- Chỉ mục cho bảng `knowledge_chunks`
--
ALTER TABLE `knowledge_chunks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_article_chunk` (`article_id`,`chunk_index`);
ALTER TABLE `knowledge_chunks` ADD FULLTEXT KEY `ft_chunk_text` (`heading`,`chunk_text`);

--
-- Chỉ mục cho bảng `knowledge_question_examples`
--
ALTER TABLE `knowledge_question_examples`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_kqe_article` (`article_id`);
ALTER TABLE `knowledge_question_examples` ADD FULLTEXT KEY `ft_question_example` (`example_question`,`normalized_question`);

--
-- Chỉ mục cho bảng `knowledge_sources`
--
ALTER TABLE `knowledge_sources`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_source_official` (`is_official`,`status`),
  ADD KEY `idx_source_document` (`document_number`);

--
-- Chỉ mục cho bảng `programs`
--
ALTER TABLE `programs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_programs_faculty` (`faculty_id`);

--
-- Chỉ mục cho bảng `rag_retrieval_logs`
--
ALTER TABLE `rag_retrieval_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_retrieval_article` (`article_id`),
  ADD KEY `fk_retrieval_chunk` (`chunk_id`),
  ADD KEY `idx_retrieval_message_rank` (`user_message_id`,`rank_position`),
  ADD KEY `idx_retrieval_selected` (`selected_for_context`,`final_score`);

--
-- Chỉ mục cho bảng `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Chỉ mục cho bảng `search_synonyms`
--
ALTER TABLE `search_synonyms`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_synonym` (`canonical_term`,`synonym_term`),
  ADD KEY `idx_synonym_term` (`synonym_term`);

--
-- Chỉ mục cho bảng `semesters`
--
ALTER TABLE `semesters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_semester_year_code` (`academic_year_id`,`code`);

--
-- Chỉ mục cho bảng `student_profiles`
--
ALTER TABLE `student_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `student_code` (`student_code`),
  ADD UNIQUE KEY `citizen_id` (`citizen_id`),
  ADD KEY `idx_student_program` (`program_id`),
  ADD KEY `idx_student_status` (`academic_status`);

--
-- Chỉ mục cho bảng `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `fk_subject_faculty` (`faculty_id`);
ALTER TABLE `subjects` ADD FULLTEXT KEY `ft_subject_search` (`code`,`name`,`description`);

--
-- Chỉ mục cho bảng `subject_prerequisites`
--
ALTER TABLE `subject_prerequisites`
  ADD PRIMARY KEY (`subject_id`,`prerequisite_subject_id`,`requirement_type`),
  ADD KEY `fk_sp_prerequisite` (`prerequisite_subject_id`);

--
-- Chỉ mục cho bảng `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_key`),
  ADD KEY `fk_setting_user` (`updated_by`);

--
-- Chỉ mục cho bảng `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ticket_number` (`ticket_number`),
  ADD KEY `idx_ticket_status_priority` (`status`,`priority`),
  ADD KEY `idx_ticket_student` (`student_id`);

--
-- Chỉ mục cho bảng `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_ticket_attachment_message` (`ticket_message_id`);

--
-- Chỉ mục cho bảng `ticket_messages`
--
ALTER TABLE `ticket_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ticket_message_time` (`ticket_id`,`created_at`);

--
-- Chỉ mục cho bảng `tuition_extension_requests`
--
ALTER TABLE `tuition_extension_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_extension_student` (`student_id`),
  ADD KEY `fk_extension_invoice` (`invoice_id`),
  ADD KEY `fk_extension_reviewer` (`reviewer_id`);

--
-- Chỉ mục cho bảng `tuition_invoices`
--
ALTER TABLE `tuition_invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `fk_invoice_semester` (`semester_id`),
  ADD KEY `idx_invoice_student_status` (`student_id`,`status`),
  ADD KEY `idx_invoice_due` (`due_date`);

--
-- Chỉ mục cho bảng `tuition_invoice_items`
--
ALTER TABLE `tuition_invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_invoice_item_invoice` (`invoice_id`);

--
-- Chỉ mục cho bảng `tuition_payments`
--
ALTER TABLE `tuition_payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_code` (`transaction_code`),
  ADD KEY `fk_payment_invoice` (`invoice_id`),
  ADD KEY `idx_payment_status_date` (`payment_status`,`paid_at`);

--
-- Chỉ mục cho bảng `unanswered_questions`
--
ALTER TABLE `unanswered_questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_unanswered_message` (`user_message_id`),
  ADD KEY `fk_unanswered_article` (`resolved_article_id`),
  ADD KEY `idx_unanswered_status_count` (`status`,`occurrence_count`);
ALTER TABLE `unanswered_questions` ADD FULLTEXT KEY `ft_unanswered_question` (`normalized_question`);

--
-- Chỉ mục cho bảng `uploaded_documents`
--
ALTER TABLE `uploaded_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_document_checksum` (`checksum_sha256`),
  ADD KEY `fk_document_uploader` (`uploaded_by`);

--
-- Chỉ mục cho bảng `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_users_role` (`role_id`),
  ADD KEY `idx_users_status` (`status`),
  ADD KEY `idx_users_name` (`full_name`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `academic_deadlines`
--
ALTER TABLE `academic_deadlines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `academic_years`
--
ALTER TABLE `academic_years`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT cho bảng `announcement_audiences`
--
ALTER TABLE `announcement_audiences`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `api_usage_logs`
--
ALTER TABLE `api_usage_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `chat_feedback`
--
ALTER TABLE `chat_feedback`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT cho bảng `chat_sessions`
--
ALTER TABLE `chat_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `class_schedule_sessions`
--
ALTER TABLE `class_schedule_sessions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `course_sections`
--
ALTER TABLE `course_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `exam_schedules`
--
ALTER TABLE `exam_schedules`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `faculties`
--
ALTER TABLE `faculties`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `faq`
--
ALTER TABLE `faq`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=146;

--
-- AUTO_INCREMENT cho bảng `grades`
--
ALTER TABLE `grades`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `knowledge_articles`
--
ALTER TABLE `knowledge_articles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=258;

--
-- AUTO_INCREMENT cho bảng `knowledge_chunks`
--
ALTER TABLE `knowledge_chunks`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=260;

--
-- AUTO_INCREMENT cho bảng `knowledge_question_examples`
--
ALTER TABLE `knowledge_question_examples`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=130;

--
-- AUTO_INCREMENT cho bảng `knowledge_sources`
--
ALTER TABLE `knowledge_sources`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `programs`
--
ALTER TABLE `programs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `rag_retrieval_logs`
--
ALTER TABLE `rag_retrieval_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT cho bảng `roles`
--
ALTER TABLE `roles`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `search_synonyms`
--
ALTER TABLE `search_synonyms`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT cho bảng `semesters`
--
ALTER TABLE `semesters`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `student_profiles`
--
ALTER TABLE `student_profiles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT cho bảng `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT cho bảng `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `ticket_messages`
--
ALTER TABLE `ticket_messages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `tuition_extension_requests`
--
ALTER TABLE `tuition_extension_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tuition_invoices`
--
ALTER TABLE `tuition_invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT cho bảng `tuition_invoice_items`
--
ALTER TABLE `tuition_invoice_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT cho bảng `tuition_payments`
--
ALTER TABLE `tuition_payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `unanswered_questions`
--
ALTER TABLE `unanswered_questions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `uploaded_documents`
--
ALTER TABLE `uploaded_documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `academic_deadlines`
--
ALTER TABLE `academic_deadlines`
  ADD CONSTRAINT `fk_deadline_semester` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcement_publisher` FOREIGN KEY (`published_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `announcement_audiences`
--
ALTER TABLE `announcement_audiences`
  ADD CONSTRAINT `fk_audience_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `api_usage_logs`
--
ALTER TABLE `api_usage_logs`
  ADD CONSTRAINT `fk_api_usage_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `fk_audit_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `chat_feedback`
--
ALTER TABLE `chat_feedback`
  ADD CONSTRAINT `fk_feedback_message` FOREIGN KEY (`message_id`) REFERENCES `chat_messages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_feedback_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `fk_message_parent` FOREIGN KEY (`parent_message_id`) REFERENCES `chat_messages` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_message_session` FOREIGN KEY (`session_id`) REFERENCES `chat_sessions` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `chat_sessions`
--
ALTER TABLE `chat_sessions`
  ADD CONSTRAINT `fk_chat_session_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `class_schedule_sessions`
--
ALTER TABLE `class_schedule_sessions`
  ADD CONSTRAINT `fk_schedule_section` FOREIGN KEY (`course_section_id`) REFERENCES `course_sections` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `course_sections`
--
ALTER TABLE `course_sections`
  ADD CONSTRAINT `fk_section_semester` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`),
  ADD CONSTRAINT `fk_section_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`);

--
-- Các ràng buộc cho bảng `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `fk_enrollment_section` FOREIGN KEY (`course_section_id`) REFERENCES `course_sections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_enrollment_student` FOREIGN KEY (`student_id`) REFERENCES `student_profiles` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `exam_schedules`
--
ALTER TABLE `exam_schedules`
  ADD CONSTRAINT `fk_exam_section` FOREIGN KEY (`course_section_id`) REFERENCES `course_sections` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `grades`
--
ALTER TABLE `grades`
  ADD CONSTRAINT `fk_grade_enrollment` FOREIGN KEY (`enrollment_id`) REFERENCES `enrollments` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `knowledge_articles`
--
ALTER TABLE `knowledge_articles`
  ADD CONSTRAINT `fk_ka_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ka_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ka_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ka_reviewer` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_ka_source` FOREIGN KEY (`source_id`) REFERENCES `knowledge_sources` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `knowledge_chunks`
--
ALTER TABLE `knowledge_chunks`
  ADD CONSTRAINT `fk_chunk_article` FOREIGN KEY (`article_id`) REFERENCES `knowledge_articles` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `knowledge_question_examples`
--
ALTER TABLE `knowledge_question_examples`
  ADD CONSTRAINT `fk_kqe_article` FOREIGN KEY (`article_id`) REFERENCES `knowledge_articles` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `programs`
--
ALTER TABLE `programs`
  ADD CONSTRAINT `fk_programs_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `rag_retrieval_logs`
--
ALTER TABLE `rag_retrieval_logs`
  ADD CONSTRAINT `fk_retrieval_article` FOREIGN KEY (`article_id`) REFERENCES `knowledge_articles` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_retrieval_chunk` FOREIGN KEY (`chunk_id`) REFERENCES `knowledge_chunks` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_retrieval_message` FOREIGN KEY (`user_message_id`) REFERENCES `chat_messages` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `semesters`
--
ALTER TABLE `semesters`
  ADD CONSTRAINT `fk_semester_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`);

--
-- Các ràng buộc cho bảng `student_profiles`
--
ALTER TABLE `student_profiles`
  ADD CONSTRAINT `fk_student_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_student_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `subjects`
--
ALTER TABLE `subjects`
  ADD CONSTRAINT `fk_subject_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `subject_prerequisites`
--
ALTER TABLE `subject_prerequisites`
  ADD CONSTRAINT `fk_sp_prerequisite` FOREIGN KEY (`prerequisite_subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_sp_subject` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `system_settings`
--
ALTER TABLE `system_settings`
  ADD CONSTRAINT `fk_setting_user` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `ticket_attachments`
--
ALTER TABLE `ticket_attachments`
  ADD CONSTRAINT `fk_ticket_attachment_message` FOREIGN KEY (`ticket_message_id`) REFERENCES `ticket_messages` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `tuition_extension_requests`
--
ALTER TABLE `tuition_extension_requests`
  ADD CONSTRAINT `fk_extension_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tuition_invoices` (`id`),
  ADD CONSTRAINT `fk_extension_reviewer` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_extension_student` FOREIGN KEY (`student_id`) REFERENCES `student_profiles` (`id`);

--
-- Các ràng buộc cho bảng `tuition_invoices`
--
ALTER TABLE `tuition_invoices`
  ADD CONSTRAINT `fk_invoice_semester` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`),
  ADD CONSTRAINT `fk_invoice_student` FOREIGN KEY (`student_id`) REFERENCES `student_profiles` (`id`);

--
-- Các ràng buộc cho bảng `tuition_invoice_items`
--
ALTER TABLE `tuition_invoice_items`
  ADD CONSTRAINT `fk_invoice_item_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tuition_invoices` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `tuition_payments`
--
ALTER TABLE `tuition_payments`
  ADD CONSTRAINT `fk_payment_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `tuition_invoices` (`id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `unanswered_questions`
--
ALTER TABLE `unanswered_questions`
  ADD CONSTRAINT `fk_unanswered_article` FOREIGN KEY (`resolved_article_id`) REFERENCES `knowledge_articles` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_unanswered_message` FOREIGN KEY (`user_message_id`) REFERENCES `chat_messages` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `uploaded_documents`
--
ALTER TABLE `uploaded_documents`
  ADD CONSTRAINT `fk_document_uploader` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Các ràng buộc cho bảng `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

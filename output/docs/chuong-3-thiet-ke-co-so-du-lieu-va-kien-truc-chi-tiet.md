# CHƯƠNG 3: THIẾT KẾ CƠ SỞ DỮ LIỆU VÀ KIẾN TRÚC CHI TIẾT

> **Ghi chú định dạng khi dán vào Word:** sử dụng phông Times New Roman, cỡ chữ 12 pt, khổ giấy A4, căn lề theo quy định của báo cáo. Các dòng bắt đầu bằng `[CHÈN HÌNH ...]` là vị trí để bổ sung ảnh hoặc sơ đồ minh họa.

Chương 2 đã trình bày mô hình phân tích ở mức nghiệp vụ, trong đó các đối tượng chính được khái quát thành Sinh viên, Admin, FAQ, Message và Feedback. Khi chuyển sang giai đoạn triển khai, nhóm thực hiện cần cụ thể hóa các đối tượng này thành schema MySQL, các endpoint xử lý request và các thành phần giao diện có thể chạy được trên môi trường PHP/MySQL thực tế. Vì vậy, schema triển khai hiện tại được mở rộng so với mô hình khái niệm ban đầu nhằm đáp ứng thêm các nhu cầu tra cứu dữ liệu cá nhân, quản lý nguồn tri thức, truy xuất RAG, lưu lịch sử hội thoại và xử lý ticket hỗ trợ.

Sự mở rộng này không làm thay đổi các nghiệp vụ cốt lõi đã được xác định ở Chương 1 và Chương 2. Về mặt hiện thực, bảng `users` kết hợp với `roles` đảm nhiệm việc quản lý tài khoản Sinh viên và Admin; `student_profiles` lưu phần thông tin riêng của sinh viên; `knowledge_articles` và `knowledge_chunks` hiện thực kho tri thức phục vụ RAG; `chat_messages` và `chat_feedback` hiện thực Message và Feedback; còn nhóm bảng `tickets` hiện thực luồng hỗ trợ sau khi chatbot không đủ dữ liệu trả lời. Ngoài ra, bảng `faq` vẫn được giữ lại như một lớp tương thích đối với dữ liệu FAQ cũ và được liên kết với quá trình nhập dữ liệu sang kho tri thức chuẩn hóa.

## 3.1. Chi tiết hóa schema triển khai thực tế (MySQL)

Schema chính của hệ thống được triển khai trong MySQL 8.0+ và sử dụng InnoDB cho các bảng nghiệp vụ. File `database/do_an_udpm_database_complete.sql` thực hiện tạo cơ sở dữ liệu `do_an_udpm`, thiết lập bộ ký tự `utf8mb4`, múi giờ `+07:00` và tạm thời tắt kiểm tra khóa ngoại trong quá trình tạo bảng. File `database_full_export.sql` là bản tổng hợp đầy đủ của schema và dữ liệu trong dự án. Bên cạnh đó, `fix_users.sql` và `seed_student.sql` được sử dụng để bổ sung tài khoản, hồ sơ sinh viên, môn học, lớp học phần, lịch học và dữ liệu đăng ký mẫu.

Ở mức triển khai, schema không chỉ lưu cặp câu hỏi - câu trả lời như mô hình FAQ đơn giản. Cơ sở dữ liệu còn lưu nguồn của tài liệu, trạng thái kiểm duyệt, thời hạn hiệu lực, ngữ cảnh học kỳ - năm học, lịch sử truy xuất, điểm tin cậy, trạng thái trả lời và thông tin ticket. Cách tổ chức này giúp hệ thống có thể kiểm soát nguồn dữ liệu trước khi đưa vào context cho mô hình AI, đồng thời giữ lại nhật ký để Admin có cơ sở kiểm tra và cải thiện kho tri thức.

### 3.1.1. Kiểu dữ liệu, ràng buộc và index chi tiết từng bảng

#### a) Quy tắc chung của schema

Các bảng chính đều sử dụng khóa chính tự tăng. Những mã định danh có khả năng được tham chiếu giữa nhiều bảng sử dụng `BIGINT UNSIGNED`, trong khi bảng `roles` và các trường trạng thái ngắn sử dụng kiểu nhỏ hơn để tiết kiệm không gian. Các trường ngày giờ sử dụng `DATETIME`, ngày học sử dụng `DATE`, giờ học sử dụng `TIME`, nội dung văn bản dài sử dụng `TEXT` hoặc `LONGTEXT`, còn dữ liệu cấu hình và dữ liệu trích xuất có cấu trúc được lưu bằng `JSON`.

| Nhóm bảng | Các bảng triển khai | Vai trò dữ liệu |
|---|---|---|
| Xác thực và tổ chức | `roles`, `users`, `faculties`, `programs`, `student_profiles` | Tài khoản, vai trò, khoa, chương trình đào tạo và hồ sơ sinh viên |
| Học vụ | `academic_years`, `semesters`, `subjects`, `subject_prerequisites`, `course_sections`, `class_schedule_sessions`, `enrollments`, `exam_schedules`, `grades` | Năm học, học kỳ, môn học, lớp học phần, lịch học, lịch thi và điểm |
| Học phí | `tuition_invoices`, `tuition_invoice_items`, `tuition_payments`, `tuition_extension_requests` | Hóa đơn, chi tiết khoản thu, giao dịch và yêu cầu gia hạn |
| Thông báo | `announcements`, `announcement_audiences`, `academic_deadlines` | Tin tức, thông báo, đối tượng nhận và hạn chót |
| Kho tri thức | `knowledge_sources`, `knowledge_articles`, `knowledge_question_examples`, `knowledge_chunks`, `search_synonyms`, `faq` | Nguồn tài liệu, bài tri thức, câu hỏi mẫu, đoạn văn và dữ liệu FAQ tương thích |
| Chatbot và RAG | `chat_sessions`, `chat_messages`, `rag_retrieval_logs`, `chat_feedback`, `unanswered_questions` | Phiên chat, tin nhắn, nhật ký truy xuất, đánh giá và câu hỏi chưa có đáp án |
| Hỗ trợ | `tickets`, `ticket_messages`, `ticket_attachments` | Ticket, trao đổi hai chiều và tệp đính kèm |
| Vận hành | `system_settings`, `uploaded_documents`, `audit_logs`, `api_usage_logs` | Cấu hình hệ thống, nhập tài liệu, nhật ký quản trị và nhật ký gọi API |

**Bảng 3.1.** Phân nhóm các bảng trong schema triển khai hiện tại

#### b) Nhóm xác thực, tài khoản và hồ sơ sinh viên

Bảng `roles` có khóa chính `id` kiểu `TINYINT UNSIGNED`, trường `code` kiểu `VARCHAR(30)` được đặt `UNIQUE`, cùng các trường tên và mô tả. Các role được seed trong schema gồm `student`, `admin`, `staff` và `knowledge_reviewer`. Việc lưu role ở một bảng riêng giúp hệ thống không phải ghi trực tiếp chuỗi quyền vào nhiều bản ghi người dùng và cho phép bổ sung vai trò mới mà không thay đổi cấu trúc bảng `users`.

Bảng `users` là bảng tài khoản trung tâm. Trường `id` sử dụng `BIGINT UNSIGNED AUTO_INCREMENT` và là khóa chính. `username` có kiểu `VARCHAR(80) NOT NULL UNIQUE`, `email` có kiểu `VARCHAR(190)` và có thể rỗng nhưng nếu có giá trị thì không được trùng. Mật khẩu không lưu dạng văn bản mà lưu trong `password_hash VARCHAR(255)`. Trường `role_id TINYINT UNSIGNED NOT NULL` liên kết đến `roles(id)`. Trạng thái tài khoản được giới hạn bằng `ENUM('active','inactive','locked','pending')`, giúp các màn hình đăng nhập phân biệt tài khoản đang hoạt động, bị khóa hoặc chưa kích hoạt. Hai index phụ `idx_users_status(status)` và `idx_users_name(full_name)` hỗ trợ lọc tài khoản theo trạng thái và tìm kiếm theo họ tên trong phân hệ quản trị.

Bảng `faculties` và `programs` tách thông tin tổ chức khỏi hồ sơ sinh viên. `faculties.code VARCHAR(30)` và `programs.code VARCHAR(50)` là các mã duy nhất. `programs.faculty_id BIGINT UNSIGNED NULL` liên kết đến khoa bằng khóa ngoại có `ON DELETE SET NULL`, vì việc xóa một khoa không nên làm mất hồ sơ chương trình đào tạo. Các trường `degree_level` và `status` được giới hạn bằng `ENUM`; `total_credits` và `standard_duration_semesters` dùng kiểu số nguyên không dấu. Index `idx_programs_faculty` hỗ trợ lấy danh sách chương trình theo khoa.

Bảng `student_profiles` dùng `id BIGINT UNSIGNED` làm khóa chính và liên kết một - một với `users` thông qua `user_id BIGINT UNSIGNED NOT NULL UNIQUE`. Mã sinh viên `student_code VARCHAR(50) NOT NULL UNIQUE` được dùng trong giao diện và các truy vấn tra cứu. Các trường `cohort_year`, `class_code`, `date_of_birth`, `gender`, `place_of_birth`, `academic_status` và thông tin địa chỉ phục vụ việc cá nhân hóa câu trả lời. `program_id` là khóa ngoại có thể rỗng và dùng `ON DELETE SET NULL`; `user_id` dùng `ON DELETE CASCADE` để khi xóa tài khoản thì hồ sơ phụ thuộc không còn bản ghi mồ côi. Hai index `idx_student_program` và `idx_student_status` hỗ trợ lọc sinh viên theo chương trình và trạng thái học tập.

#### c) Nhóm học vụ, lịch học, lịch thi và điểm

`academic_years` lưu mã năm học bằng `VARCHAR(20) UNIQUE`, thời gian bắt đầu - kết thúc bằng `DATE` và cờ `is_current BOOLEAN`. Ràng buộc `CHECK (end_date >= start_date)` ngăn dữ liệu có thời gian kết thúc trước thời gian bắt đầu. `semesters` liên kết với `academic_years` bằng `academic_year_id`, dùng cặp `UNIQUE KEY uk_semester_year_code (academic_year_id, code)` để không trùng mã học kỳ trong cùng một năm học và cũng áp dụng kiểm tra thứ tự ngày.

`subjects` lưu mã môn học `code VARCHAR(50) UNIQUE`, tên môn, số tín chỉ và số tiết lý thuyết - thực hành bằng các kiểu số nguyên không dấu. Mô tả môn học sử dụng `TEXT`. Bảng có khóa ngoại `faculty_id` và full-text index `ft_subject_search(code, name, description)` để hỗ trợ tìm kiếm môn học theo mã, tên hoặc mô tả.

`subject_prerequisites` là bảng liên kết nhiều - nhiều giữa một môn học và môn điều kiện. Bảng không có cột `id` riêng mà sử dụng khóa chính ghép `(subject_id, prerequisite_subject_id, requirement_type)`. Hai khóa ngoại đều trỏ về `subjects(id)` và có `ON DELETE CASCADE`. Ràng buộc `CHECK (subject_id <> prerequisite_subject_id)` ngăn một môn tự tham chiếu chính nó.

`course_sections` biểu diễn lớp học phần cụ thể theo từng học kỳ. `semester_id` và `subject_id` là khóa ngoại bắt buộc; cặp `(semester_id, section_code)` được đặt `UNIQUE` để tránh trùng mã lớp trong cùng học kỳ. `delivery_mode` và `status` dùng `ENUM` để giới hạn các trạng thái hợp lệ. Index `idx_section_subject(subject_id)` hỗ trợ tra cứu các lớp theo môn.

`class_schedule_sessions` lưu các buổi học, trong đó `day_of_week TINYINT UNSIGNED` bị giới hạn từ 1 đến 7, `start_time` và `end_time` dùng `TIME`, đồng thời có `CHECK (end_time > start_time)`. Khóa ngoại `course_section_id` có `ON DELETE CASCADE`, bởi khi xóa lớp học phần thì các buổi học phụ thuộc cũng phải được xóa. Index ghép `idx_schedule_day_time(day_of_week, start_time)` phục vụ sắp xếp lịch theo thứ và giờ bắt đầu.

`enrollments` liên kết sinh viên với lớp học phần. Cặp `(student_id, course_section_id)` là duy nhất nhằm ngăn một sinh viên đăng ký trùng một lớp. Trạng thái đăng ký dùng `ENUM('registered','studying','withdrawn','completed','failed','cancelled')`, còn `registered_at` dùng `DATETIME` mặc định thời điểm hiện tại. Index `idx_enrollment_status` hỗ trợ lọc các bản ghi đang học, đã hoàn thành hoặc đã hủy.

`exam_schedules` lưu loại kỳ thi, ngày, giờ, thời lượng, phòng, cơ sở và số ghế. Index `idx_exam_date(exam_date, start_time)` phục vụ truy vấn lịch thi theo thứ tự thời gian. `grades` liên kết một - một với `enrollments` nhờ `enrollment_id UNIQUE`; các điểm thành phần dùng `DECIMAL(5,2)`, điểm hệ 4 dùng `DECIMAL(4,2)`. Hai ràng buộc `CHECK` giới hạn điểm hệ 10 trong khoảng 0 đến 10 và điểm hệ 4 trong khoảng 0 đến 4.

#### d) Nhóm học phí và giao dịch

`tuition_invoices` sử dụng `invoice_number VARCHAR(60) UNIQUE` để nhận diện hóa đơn. Các giá trị tiền dùng `DECIMAL(15,2)`, tránh sai số của kiểu số thực. Trường `outstanding_amount` là cột sinh tự động, được tính từ `subtotal - discount_amount - paid_amount` và không âm. Các index `idx_invoice_student_status(student_id, status)` và `idx_invoice_due(due_date)` hỗ trợ màn hình tra cứu công nợ và lọc hóa đơn đến hạn.

`tuition_invoice_items` lưu từng khoản trong hóa đơn. `quantity` dùng `DECIMAL(10,2)`, `unit_price` và cột sinh `amount` dùng `DECIMAL(15,2)`. Việc tách hóa đơn và chi tiết khoản thu cho phép một hóa đơn bao gồm nhiều loại phí khác nhau.

`tuition_payments` có `transaction_code VARCHAR(100) UNIQUE`, `amount DECIMAL(15,2)`, trạng thái giao dịch và phương thức thanh toán dùng `ENUM`. Dữ liệu trả về từ cổng thanh toán có thể lưu trong `gateway_payload JSON`. Index `idx_payment_status_date(payment_status, paid_at)` hỗ trợ đối soát giao dịch theo trạng thái và thời gian.

`tuition_extension_requests` lưu yêu cầu gia hạn, lý do, ngày đề nghị, trạng thái và người duyệt. Khóa ngoại `reviewer_id` được phép rỗng và dùng `ON DELETE SET NULL` để không làm mất yêu cầu khi tài khoản người duyệt bị xóa.

#### e) Nhóm thông báo và hạn chót

`announcements` dùng `LONGTEXT` cho nội dung dài, `slug VARCHAR(255) UNIQUE` cho đường dẫn thân thiện và các trường `announcement_type`, `status` dạng `ENUM`. Full-text index `ft_announcement_search(title, summary, content)` phục vụ tìm kiếm thông báo. Index `idx_announcement_live(status, published_at, expires_at)` hỗ trợ lọc các thông báo đang được công bố và chưa hết hạn.

`announcement_audiences` cho phép một thông báo hướng đến tất cả người dùng, một vai trò, một khoa, một chương trình, một khóa hoặc một sinh viên. Cặp `audience_type` và `audience_value` được lập index `idx_audience_lookup` nhằm tìm nhanh đối tượng nhận.

`academic_deadlines` lưu hạn đăng ký học phần, học phí, thi, phúc khảo và các nghiệp vụ tương tự. Trường `due_at DATETIME NOT NULL` là thời điểm kết thúc, còn `status` và `audience_type` dùng `ENUM`. Index `idx_deadline_due(status, due_at)` giúp lấy các deadline còn hiệu lực; full-text index `ft_deadline_search(title, description)` hỗ trợ tìm theo nội dung.

#### f) Nhóm kho tri thức và RAG

`knowledge_sources` lưu nguồn của tri thức, gồm loại nguồn, tiêu đề, tổ chức, số văn bản, đường dẫn, đường dẫn tệp, checksum, ngày ban hành và trạng thái. `checksum_sha256 CHAR(64)` được dùng để nhận diện nội dung trùng lặp ở cấp nguồn. Các index `idx_source_official(is_official, status)` và `idx_source_document(document_number)` hỗ trợ lọc nguồn chính thức và tra cứu theo số văn bản.

`knowledge_articles` là bảng trung tâm của kho tri thức chuẩn hóa. Các trường `title`, `category`, `answer_content`, `keywords`, `intent_code`, `route_url` mô tả nội dung trả lời và khả năng điều hướng. Các trường `faculty_id`, `program_id`, `cohort_from`, `cohort_to`, `semester_code`, `academic_year_code`, `valid_from`, `valid_until` cho phép giới hạn câu trả lời theo ngữ cảnh. `verification_status` quy định bản ghi đang là nháp, chờ duyệt, đã xác minh, bị từ chối hoặc hết hạn; `confidence_level` mô tả mức tin cậy; `priority` dùng để ưu tiên khi xếp hạng. Bảng có full-text index `ft_knowledge_search(title, keywords, answer_content)` và các index lọc theo trạng thái, ý định và độ ưu tiên.

`knowledge_question_examples` lưu các cách hỏi mẫu liên kết với `knowledge_articles`. Full-text index `ft_question_example(example_question, normalized_question)` hỗ trợ tìm theo câu hỏi gốc và câu hỏi đã chuẩn hóa.

`knowledge_chunks` chia nội dung bài tri thức thành các đoạn. Cặp `(article_id, chunk_index)` là duy nhất nhờ `uk_article_chunk`; `chunk_text` dùng `LONGTEXT`, còn metadata và dữ liệu embedding có thể lưu bằng `JSON`. Full-text index `ft_chunk_text(heading, chunk_text)` được dùng trong truy xuất RAG. Trong phiên bản hiện tại, mã nguồn tạo tối thiểu một chunk cho bài tri thức; cấu trúc bảng vẫn cho phép mở rộng thành nhiều chunk khi dữ liệu lớn hơn.

`search_synonyms` lưu thuật ngữ chuẩn và các cách viết tương đương. Cặp `(canonical_term, synonym_term)` là duy nhất và có thêm `idx_synonym_term` trên từ đồng nghĩa để hỗ trợ chuẩn hóa truy vấn.

`faq` là bảng FAQ tương thích với dữ liệu cũ. Bảng sử dụng `tu_khoa TEXT NOT NULL`, `noi_dung LONGTEXT NOT NULL`, `topic_group`, `link_dieu_huong` và trạng thái kiểm duyệt. Các index gồm `idx_faq_topic(topic_group)`, `idx_faq_verified(verification_status, valid_from, valid_until)` và full-text index `ft_faq_search(tu_khoa, noi_dung)`. Trong `core/faq_helpers.php`, hàm `faqColumnSchema()` còn kiểm tra cả hai biến thể tên cột `keywords/answer` và `tu_khoa/noi_dung`, giúp mã nguồn tương thích với các phiên bản FAQ trước đó.

#### g) Nhóm chat, truy xuất và phản hồi

`chat_sessions` lưu một phiên trò chuyện bằng `session_uuid CHAR(36) UNIQUE`, người dùng, kênh, trạng thái, ngôn ngữ và thời điểm hoạt động cuối. Index `idx_chat_user_activity(user_id, last_activity_at)` hỗ trợ lấy các phiên gần đây của một tài khoản.

`chat_messages` lưu cả tin nhắn người dùng và câu trả lời của hệ thống. `sender_type` dùng `ENUM('user','assistant','system','tool')`. Ngoài nội dung gốc, bảng còn lưu nội dung chuẩn hóa, ý định phát hiện được, thực thể trích xuất bằng `JSON`, tên mô hình, độ trễ, điểm tin cậy và `answer_status`. Index `idx_message_session_time(session_id, created_at)` phục vụ xem lịch sử; full-text index `ft_chat_content(content, normalized_content)` phục vụ tìm kiếm.

`rag_retrieval_logs` lưu kết quả truy xuất theo từng tin nhắn người dùng. Các trường điểm số như `keyword_score`, `semantic_score`, `metadata_score`, `freshness_score` và `final_score` dùng `DECIMAL(10,6)`. Cờ `selected_for_context` cho biết chunk có được đưa vào context hay không. Index `idx_retrieval_message_rank(user_message_id, rank_position)` phục vụ xem thứ hạng theo câu hỏi; `idx_retrieval_selected(selected_for_context, final_score)` phục vụ phân tích các chunk được chọn.

`chat_feedback` liên kết đánh giá với `chat_messages` và người dùng. `rating` chỉ nhận `up` hoặc `down`; `reason_code` giới hạn các lý do như `incorrect`, `outdated`, `irrelevant`, `unclear`, `unsafe`, `helpful` và `other`. Ràng buộc `uk_feedback_user_message(message_id, user_id)` ngăn một người dùng gửi nhiều bản ghi đánh giá trùng cho cùng một câu trả lời.

`unanswered_questions` ghi lại các câu hỏi chưa có context đủ tin cậy. `occurrence_count` tăng khi câu hỏi chuẩn hóa trùng lặp xuất hiện lại; `status` theo dõi quá trình từ mới ghi nhận đến đã xử lý hoặc bỏ qua. Full-text index `ft_unanswered_question` và index `idx_unanswered_status_count` hỗ trợ Admin ưu tiên các câu hỏi xuất hiện nhiều.

#### h) Nhóm ticket và vận hành

`tickets` lưu yêu cầu hỗ trợ với `ticket_number VARCHAR(30) UNIQUE`, người yêu cầu, tiêu đề, mô tả, độ ưu tiên, trạng thái, người được phân công và phiên chat nguồn. Các trạng thái `open`, `in_progress`, `waiting_student`, `resolved`, `closed` và `cancelled` tương ứng với luồng xử lý trong giao diện Admin. Index `idx_ticket_status_priority(status, priority)` phục vụ danh sách ticket cần xử lý; `idx_ticket_student(student_id)` phục vụ lịch sử ticket của sinh viên.

`ticket_messages` lưu các lượt trao đổi trong ticket. `sender_role` giới hạn ở `student`, `admin` và `system`; index `idx_ticket_message_time(ticket_id, created_at)` đảm bảo truy vấn hội thoại theo thứ tự thời gian. `ticket_attachments` lưu tên tệp gốc, đường dẫn lưu, MIME type, kích thước và checksum; khóa ngoại đến `ticket_messages` có `ON DELETE CASCADE`.

`system_settings` dùng `setting_key VARCHAR(120)` làm khóa chính và `setting_value JSON` để lưu cấu hình như ngưỡng RAG, số chunk tối đa và câu trả lời fallback. `uploaded_documents` lưu tài liệu được tải lên để xử lý, trạng thái trích xuất/chunking và nội dung đã trích xuất; `uk_document_checksum` giúp tránh nhập trùng tệp. `audit_logs` lưu hành động, đối tượng, dữ liệu cũ - mới, IP và user agent; các index phục vụ xem lịch sử theo đối tượng hoặc người dùng. `api_usage_logs` lưu nhà cung cấp, mô hình, endpoint, token, độ trễ và trạng thái gọi API, với index `idx_api_usage_provider_time(provider, created_at)`.

#### i) Các view phục vụ tương thích và truy vấn an toàn

Ngoài bảng vật lý, schema tạo các view `system_notifications`, `class_schedules`, `v_active_verified_knowledge`, `v_unpaid_tuition` và `v_chat_quality_summary`. Trong đó, `v_active_verified_knowledge` là view quan trọng đối với chatbot. View chỉ lấy `knowledge_articles` chưa bị xóa, đã được xác minh, còn trong thời hạn hiệu lực và có nguồn đang hoạt động. Nhờ vậy, backend không truy vấn trực tiếp toàn bộ dữ liệu FAQ chưa kiểm duyệt để sinh câu trả lời.

**Bảng 3.2.** Các index và ràng buộc tiêu biểu phục vụ chatbot

| Thành phần | Ràng buộc/index | Mục đích triển khai |
|---|---|---|
| `users` | `UNIQUE(username)`, `UNIQUE(email)`, `idx_users_status`, `idx_users_name` | Định danh tài khoản và lọc người dùng |
| `student_profiles` | `UNIQUE(user_id)`, `UNIQUE(student_code)`, khóa ngoại đến `users`, `programs` | Bảo đảm một hồ sơ cho một tài khoản và không trùng MSSV |
| `knowledge_articles` | Full-text, `idx_knowledge_filter`, `idx_knowledge_intent`, `idx_knowledge_priority` | Tìm kiếm nội dung, lọc kiểm duyệt và ưu tiên |
| `knowledge_chunks` | `UNIQUE(article_id, chunk_index)`, full-text | Quản lý thứ tự chunk và tìm nội dung |
| `chat_sessions` | `UNIQUE(session_uuid)`, `idx_chat_user_activity` | Định danh phiên và tải lịch sử theo người dùng |
| `chat_messages` | `idx_message_session_time`, full-text | Lưu và truy vấn hội thoại |
| `rag_retrieval_logs` | `idx_retrieval_message_rank`, `idx_retrieval_selected` | Kiểm tra thứ hạng và quyết định đưa context |
| `chat_feedback` | `UNIQUE(message_id, user_id)` | Không ghi nhận đánh giá trùng |
| `tickets` | `UNIQUE(ticket_number)`, `idx_ticket_status_priority`, `idx_ticket_student` | Quản lý ticket theo trạng thái, ưu tiên và sinh viên |

#### j) Chiến lược chọn kiểu dữ liệu và index

Việc lựa chọn kiểu dữ liệu trong schema được gắn với cách hệ thống truy vấn. Các mã định danh và khóa ngoại dùng số nguyên không dấu để tăng miền giá trị và đồng nhất giữa các bảng. Các trường có tập giá trị hữu hạn dùng `ENUM` để hạn chế dữ liệu sai trạng thái. Các trường nội dung trả lời, mô tả ticket và nội dung nguồn dùng `TEXT` hoặc `LONGTEXT` vì có thể vượt quá giới hạn của `VARCHAR` thông thường. Những dữ liệu cần tìm kiếm theo từ khóa được đặt full-text index, trong khi dữ liệu cần lọc theo trạng thái và thời gian được đặt index ghép theo thứ tự điều kiện truy vấn.

Các index không được tạo tràn lan trên mọi cột, vì mỗi index đều làm tăng chi phí ghi dữ liệu. Index được ưu tiên ở các trường xuất hiện trong khóa ngoại, điều kiện lọc thường xuyên, thứ tự sắp xếp lịch hoặc tìm kiếm văn bản. Việc đánh giá thời gian thực thi cụ thể sẽ được trình bày ở Chương 5 nếu nhóm có số liệu đo trên môi trường triển khai.

### 3.1.2. Đối chiếu với script triển khai thực tế

Quá trình triển khai cơ sở dữ liệu được tổ chức theo các lớp script có vai trò khác nhau. `database/do_an_udpm_database_complete.sql` là script schema chính: script thiết lập database, tạo các bảng, tạo view, nhập dữ liệu FAQ legacy vào `faq`, sau đó chuyển dữ liệu này thành `knowledge_articles`, `knowledge_question_examples` và `knowledge_chunks`. Đây là bước hình thành cấu trúc dữ liệu chuẩn hóa cho hệ thống chatbot.

File `database_full_export.sql` chứa bản tổng hợp bắt đầu từ schema đầy đủ và các phần dữ liệu tương ứng. File này có thể được xem như bản sao lưu hoặc bản chuyển giao của database, dùng để đối chiếu khi cần kiểm tra toàn bộ cấu trúc và dữ liệu. Trong báo cáo, hai file được xem là hai nguồn triển khai chính thức đã được nhóm sử dụng, nhưng cần phân biệt rõ: một file mô tả quy trình tạo schema hoàn chỉnh, còn file còn lại là bản export tổng hợp.

File `fix_users.sql` bổ sung lại các tài khoản mẫu `admin` và sinh viên, đồng thời tạo bản ghi `student_profiles`. Mật khẩu trong file được lưu dưới dạng chuỗi băm tương thích với `password_verify()` của PHP. File này sử dụng `role_id` theo mã số đã có trong bảng `roles`, do đó phải được chạy trên database đã tạo bảng role và đã có dữ liệu role phù hợp.

File `seed_student.sql` phục vụ dữ liệu minh họa cho sinh viên, môn học, năm học, học kỳ, lớp học phần, lịch học và bản ghi đăng ký. File này giúp dashboard sinh viên có dữ liệu để kiểm tra các nghiệp vụ lịch học và tra cứu học vụ. Do đây là script seed bổ sung, các thông tin tài khoản mẫu và mật khẩu dùng cho kiểm thử đăng nhập cần được đối chiếu với script `fix_users.sql` hoặc bộ dữ liệu demo cuối cùng trước khi thực hiện kiểm thử chính thức.

Trong quá trình triển khai, nhóm không xem schema ở Chương 2 là danh sách bảng vật lý cuối cùng. Chương 2 mô tả các thực thể chính để giải thích nghiệp vụ; các script SQL sau đó bổ sung bảng nguồn, bảng chunk, bảng log, bảng ticket, bảng cấu hình và các view tương thích. Đây là bước chi tiết hóa từ mô hình khái niệm sang mô hình triển khai, nhằm đáp ứng yêu cầu thực tế của hệ thống mà không làm thay đổi các Use Case đã được phê duyệt.

**[CHÈN HÌNH 3.1: Sơ đồ ánh xạ từ các thực thể khái niệm trong Chương 2 sang các bảng triển khai trong schema MySQL.]**

## 3.2. Thiết kế API và Backend

### 3.2.1. Cấu trúc thư mục dự án (MVC/Core)

Mã nguồn hiện tại tổ chức theo hướng phân lớp giữa giao diện, endpoint xử lý request, logic dùng chung và dữ liệu. Cấu trúc này có đặc điểm gần với kiến trúc 3 tầng đã trình bày ở Chương 1 hơn là mô hình MVC đầy đủ theo nghĩa có các thư mục `controllers/`, `models/` và `views/` tách riêng. Cụ thể, `views/` đảm nhiệm giao diện PHP/HTML; `api/` đảm nhiệm vai trò tiếp nhận request và điều phối nghiệp vụ; `core/` chứa hàm dùng chung và các thao tác dữ liệu; `database/` chứa schema, script seed và công cụ kiểm tra; `tts/` là service độc lập cho chuyển văn bản thành giọng nói.

```text
do_an_udpm/
├── api/
│   ├── chatbot.php
│   ├── chat_feedback.php
│   ├── create_ticket.php
│   ├── get_student_chat.php
│   ├── get_ticket_chat.php
│   ├── report_bot.php
│   ├── student_reply.php
│   ├── text_to_speech.php
│   └── upload_avatar.php
├── core/
│   ├── faq_helpers.php
│   └── new_logic.php
├── css/
│   ├── admin.css
│   ├── dashboard.css
│   └── login.css
├── database/
│   ├── do_an_udpm_database_complete.sql
│   ├── do_an_udpm_demo_seed.sql
│   ├── faq_knowledge_seed.sql
│   ├── add_column.php
│   ├── add_new_tables.php
│   ├── check_db.php
│   ├── check_tables.php
│   ├── seed_faq_knowledge.php
│   └── setup_data.php
├── js/
│   ├── admin.js
│   └── chatbot.js
├── tts/
│   ├── requirements.txt
│   └── server.py
├── uploads/
├── views/
│   ├── login.php
│   ├── dashboard.php
│   └── admin_dashboard.php
├── .env
├── .htaccess
├── config.php
├── README.md
├── database_full_export.sql
├── fix_db.sh
├── fix_users.sql
├── seed_student.sql
└── test.js
```

**Bảng 3.3.** Vai trò của các thành phần chính trong kiến trúc backend

| Thành phần | Vai trò triển khai |
|---|---|
| `views/login.php` | Nhận thông tin đăng nhập, xác thực và điều hướng theo role |
| `views/dashboard.php` | Giao diện và nghiệp vụ phía Sinh viên, bao gồm dashboard, chatbot, lịch sử và ticket |
| `views/admin_dashboard.php` | Giao diện quản trị, xử lý các POST quản lý knowledge, người dùng và ticket |
| `api/chatbot.php` | Phân loại câu hỏi, tra cứu database, truy xuất RAG và trả JSON |
| `api/*.php` | Các endpoint cho feedback, ticket, hội thoại, TTS và avatar |
| `core/faq_helpers.php` | Kết nối PDO, chuẩn hóa tiếng Việt, truy vấn tài khoản, session chat, RAG view và ticket |
| `config.php` | Đọc `.env`, cấu hình MySQL và khóa Gemini |
| `js/chatbot.js` | Gửi câu hỏi, hiển thị câu trả lời, lưu lịch sử cục bộ, gọi TTS và feedback |
| `css/*.css` | Quy tắc hiển thị cho login, dashboard và Admin |
| `tts/server.py` | FastAPI service tạo file MP3 bằng gTTS |

Trong `core/faq_helpers.php`, nhóm thực hiện tập trung các hàm kết nối database bằng PDO, thiết lập chế độ exception, chuẩn hóa dữ liệu truy vấn và thao tác với các bảng dùng chung. Cách tập trung này giúp các endpoint không phải lặp lại logic kết nối và giảm nguy cơ mỗi endpoint xử lý schema theo một cách khác nhau. Các câu lệnh SQL trong các hàm truy vấn sử dụng prepared statement và truyền tham số riêng, hạn chế việc nối trực tiếp dữ liệu người dùng vào câu lệnh SQL.

File `core/new_logic.php` hiện không còn là luồng chatbot chính; nội dung file xác định logic chatbot mới đã được chuyển sang `api/chatbot.php`. Vì vậy, khi mô tả kiến trúc triển khai, `api/chatbot.php` được xem là điểm vào thực tế của module Bot, còn `core/faq_helpers.php` là lớp hỗ trợ dùng chung.

#### Ghi chú về thay đổi cơ chế xác thực so với thiết kế ban đầu

Ở giai đoạn phân tích và thiết kế, Chương 1 - Chương 2 mô hình hóa module đăng nhập theo hướng sử dụng JWT. Tuy nhiên, trong quá trình triển khai thực tế trên PHP thuần và để đồng bộ với các view PHP sử dụng cùng một phiên làm việc, nhóm đã điều chỉnh sang PHP Session kết hợp với `session_regenerate_id(true)`. Trong `views/login.php`, hệ thống kiểm tra người dùng bằng `appFindUserForLogin()`, xác minh mật khẩu bằng `password_verify()`, kiểm tra trạng thái tài khoản, sau đó xoay vòng session ID trước khi ghi `user_id`, `username`, `role`, họ tên và các thông tin cần thiết vào `$_SESSION`.

Việc điều chỉnh này không thay đổi yêu cầu nghiệp vụ về đăng nhập và phân quyền. Đây là thay đổi ở tầng hiện thực nhằm giảm độ phức tạp khi các view PHP và endpoint cùng sử dụng cơ chế session của máy chủ. Việc gọi `session_regenerate_id(true)` sau khi xác thực thành công cũng giúp thay đổi định danh phiên, từ đó giảm nguy cơ Session Fixation. Do dự án chưa có benchmark so sánh giữa hai phương án, báo cáo không khẳng định PHP Session có tốc độ cao hơn JWT; lý do chính được ghi nhận là sự phù hợp với kiến trúc PHP hiện tại và khả năng quản lý trạng thái đăng nhập tập trung.

Ở các trang cần quyền Admin, `views/admin_dashboard.php` kiểm tra `$_SESSION['role']` và chỉ cho phép các role `admin`, `staff` hoặc `knowledge_reviewer` tiếp tục. Ở `views/dashboard.php`, hệ thống yêu cầu role `student`. Cách kiểm tra này hiện thực đúng sự phân quyền đã mô tả trong các Use Case, dù cơ chế token đã được thay đổi ở mức triển khai.

### 3.2.2. Thiết kế các Endpoint API cốt lõi

Các endpoint được đặt trong thư mục `api/`. Phần lớn endpoint trả về JSON; riêng `api/text_to_speech.php` trả về dữ liệu nhị phân với `Content-Type: audio/mpeg` khi service TTS hoạt động. Bảng dưới đây tổng hợp các endpoint đang có trong source code.

| Endpoint | Phương thức và dữ liệu chính | Quyền truy cập | Kết quả xử lý |
|---|---|---|---|
| `api/chatbot.php` | `POST` JSON gồm `message`, có thể kèm `sessionUuid`, `mssv` và ngữ cảnh giao diện | Người dùng đã đăng nhập; một số nhánh có thể ghi nhận khách chưa đăng nhập | Trả `reply`, `suggestions`, `sessionUuid`, `messageId`, `intent`, `intentClass`, `answerStatus` |
| `api/chat_feedback.php` | `POST` JSON gồm `messageId`, `rating`, `reasonCode`, `comment` | Người dùng đã đăng nhập | Ghi đánh giá vào `chat_feedback`, chống trùng theo message và user |
| `api/report_bot.php` | `POST` JSON gồm câu hỏi, câu trả lời, `messageId`, MSSV và tên sinh viên | Giao diện chatbot | Ghi feedback không chính xác và tạo ticket hỗ trợ |
| `api/create_ticket.php` | `POST` JSON gồm `subject`, `description` | Sinh viên đã đăng nhập | Tạo `tickets` và tin nhắn đầu tiên trong `ticket_messages` |
| `api/get_student_chat.php` | `GET` với `id` ticket | Sinh viên, chỉ xem ticket thuộc MSSV trong session | Trả danh sách message của ticket và trạng thái đóng/mở |
| `api/get_ticket_chat.php` | `GET` với `id` ticket | Admin/staff/reviewer xem theo quyền; sinh viên chỉ xem ticket của mình | Trả hội thoại ticket theo vai trò |
| `api/student_reply.php` | `POST` form gồm `ticket_id`, `message` | Sinh viên, ticket chưa đóng và thuộc sinh viên | Thêm tin nhắn sinh viên và cập nhật trạng thái ticket |
| `api/text_to_speech.php` | `POST` JSON gồm `text`; hỗ trợ `OPTIONS` | Endpoint proxy nội bộ | Gọi FastAPI `/api/tts`, trả audio hoặc JSON lỗi |
| `api/upload_avatar.php` | `POST` multipart với trường `avatar` | Người dùng đã đăng nhập | Kiểm tra loại file/kích thước, lưu tệp và cập nhật `users.avatar_url` |

**Bảng 3.4.** Danh sách endpoint API cốt lõi

#### Luồng xử lý của `api/chatbot.php`

Khi nhận request, endpoint đọc JSON từ `php://input`, lấy trường `message` và loại bỏ khoảng trắng đầu cuối. Nếu thông điệp rỗng, hệ thống trả lỗi JSON và dừng xử lý. Sau đó, endpoint kết nối database thông qua `config.php` và `core/faq_helpers.php`, lấy hồ sơ sinh viên từ session hoặc từ MSSV được truyền kèm trong request khi phù hợp.

Bước tiếp theo là phân loại câu hỏi bằng `classifyQuestion()` và nhận diện thực thể bằng `detectEntities()`. Các nhóm intent hiện có gồm tạo ticket, điều hướng cổng thông tin, dữ liệu cá nhân của sinh viên, thông báo/deadline, trò chuyện thông thường và kiến thức học vụ. Thực thể có thể được nhận diện gồm mã học kỳ, mã năm học, khóa sinh viên và phạm vi thời gian như hôm nay, ngày mai hoặc tuần này.

Trước khi trả lời, hệ thống gọi `appEnsureChatSession()` để tìm hoặc tạo `chat_sessions`. Phiên được nhận diện bằng UUID, liên kết với user nếu người dùng đã đăng nhập và được lưu lại trong session PHP. Tin nhắn người dùng được ghi bằng `appLogChatMessage()`, trong đó lưu nội dung gốc, nội dung chuẩn hóa, intent và thực thể đã trích xuất.

Đối với các câu hỏi dữ liệu cá nhân, endpoint không gửi dữ liệu nhạy cảm cho Gemini mà truy vấn trực tiếp các bảng nghiệp vụ. `buildGradesReply()` lấy điểm qua `enrollments`, `course_sections`, `subjects`, `semesters`, `academic_years` và `grades`. `buildScheduleReply()` truy vấn lớp học phần và `class_schedule_sessions`; `buildExamsReply()` truy vấn `exam_schedules`; `buildTuitionReply()` truy vấn hóa đơn, học kỳ và năm học. Nếu không có hồ sơ sinh viên, hệ thống trả lời yêu cầu đăng nhập; nếu đã đăng nhập nhưng database chưa có dữ liệu, hệ thống ghi nhận câu hỏi chưa trả lời và trả fallback.

Đối với câu hỏi thông báo hoặc deadline, hệ thống sử dụng full-text search trên `announcements` và `academic_deadlines`, chỉ lấy các bản ghi đang công bố và chưa hết hạn. Đối với câu hỏi kiến thức học vụ, `retrieveRagChunks()` truy vấn view `v_active_verified_knowledge`, kết hợp full-text score của bài tri thức và chunk, sau đó tính thêm điểm phủ từ khóa, điểm metadata, điểm freshness và ưu tiên của bài. Ngưỡng mặc định được đọc từ `system_settings` với khóa `rag.min_final_score`; số chunk tối đa được đọc từ `rag.max_context_chunks`.

Mỗi kết quả truy xuất được ghi vào `rag_retrieval_logs`, bao gồm thứ hạng, điểm từ khóa, điểm metadata, điểm cuối cùng và lý do loại nếu thấp hơn ngưỡng. Chỉ các chunk đạt ngưỡng mới được đưa vào context. Nếu không có chunk được chọn, hệ thống ghi vào `unanswered_questions` và trả chuỗi `TICKET_OFFER` để JavaScript hiển thị đề nghị tạo ticket. Nếu có khóa Gemini, context đã kiểm duyệt được gửi đến model `gemini-2.5-flash-lite` với prompt yêu cầu không bịa dữ liệu và không tự đoán thông tin cá nhân. Nếu không có khóa Gemini hoặc Gemini lỗi, hệ thống vẫn có thể trả trực tiếp nội dung đã kiểm duyệt từ database.

#### Thiết kế lưu lịch sử, feedback và ticket

Sau mỗi nhánh trả lời, hàm đóng luồng `finish()` ghi một bản ghi assistant vào `chat_messages`, kèm intent, thực thể, tên mô hình, độ trễ, điểm tin cậy và trạng thái câu trả lời. Phía frontend lưu phiên và tin nhắn vào `localStorage` để khôi phục giao diện; đồng thời UUID của phiên database được giữ lại để các lần hỏi sau tiếp tục cùng một `chat_session`.

Khi sinh viên bấm Hữu ích hoặc Báo lỗi, `js/chatbot.js` gọi `api/chat_feedback.php` để ghi rating. Khi sinh viên báo câu trả lời sai, frontend có thể gọi thêm `api/report_bot.php`; endpoint này lưu feedback `down/incorrect` và tạo một ticket chứa câu hỏi cùng câu trả lời cần kiểm tra. Khi sinh viên chủ động yêu cầu hỗ trợ, chatbot trả về prefix `TICKET_CONFIRM:`; sau khi người dùng xác nhận, giao diện gọi `api/create_ticket.php`.

#### Thiết kế module TTS

TTS được tách thành một service Python trong thư mục `tts/`. `tts/server.py` tạo FastAPI app, khai báo endpoint `GET /health` để kiểm tra trạng thái và `POST /api/tts` để nhận văn bản. Văn bản được giới hạn độ dài, chuyển sang gTTS với ngôn ngữ `vi`, lưu tạm thành file MP3 và trả về `FileResponse` với MIME type `audio/mpeg`.

Frontend trong `js/chatbot.js` không gọi trực tiếp Python service mà gọi `../api/text_to_speech.php`. Proxy PHP kiểm tra JSON và văn bản đầu vào, gọi địa chỉ mặc định `http://127.0.0.1:8001/api/tts`, tách header khỏi body và chuyển tiếp MIME type cùng kích thước file. Frontend nhận blob, tạo Object URL và phát bằng đối tượng `Audio`. Cơ chế `speechRequestId` giúp bỏ qua kết quả của request cũ nếu người dùng chuyển sang phát câu trả lời khác. Nếu service Python không phản hồi, frontend dùng `SpeechSynthesisUtterance` của trình duyệt làm phương án dự phòng.

**[CHÈN HÌNH 3.2: Sơ đồ tuần tự triển khai API Chatbot - PHP - MySQL - Gemini/RAG.]**

**[CHÈN HÌNH 3.3: Sơ đồ tuần tự triển khai TTS - `js/chatbot.js` - `api/text_to_speech.php` - FastAPI/gTTS.]**

## 3.3. Thiết kế Frontend và Giao diện người dùng (UI/UX)

Frontend của hệ thống được xây dựng trực tiếp trong các view PHP, kết hợp CSS thuần và JavaScript phía trình duyệt. `views/login.php` là điểm vào xác thực; `views/dashboard.php` là không gian làm việc của Sinh viên; `views/admin_dashboard.php` là giao diện quản trị. Các file `css/login.css`, `css/dashboard.css` và `css/admin.css` tách các quy tắc hiển thị theo từng khu vực. `js/chatbot.js` xử lý phiên chat, gửi request, feedback và phát TTS; `js/admin.js` cung cấp các thao tác hỗ trợ ở phía Admin.

Thiết kế giao diện ưu tiên việc đưa các chức năng tra cứu thường xuyên lên cùng một không gian. Sinh viên có thể bắt đầu từ các liên kết nhanh như đào tạo trực tuyến, hỗ trợ trực tuyến, cổng thanh toán, dịch vụ sinh viên, chương trình khung, môn học điều kiện, công nợ và kết quả học tập. Những thao tác cần trao đổi nhiều bước như chatbot và ticket được hiển thị dưới dạng cửa sổ hoặc modal, giúp người dùng không phải rời khỏi dashboard chính.

### 3.3.1. Sơ đồ điều hướng (Navigation Map)

Ở cấp hệ thống, `.htaccess` đặt `views/login.php` làm `DirectoryIndex`. Khi người dùng gửi form đăng nhập, `login.php` xác thực tài khoản và chuyển hướng theo role. Sinh viên được chuyển đến `dashboard.php`; các role Admin, Staff và Knowledge Reviewer được chuyển đến `admin_dashboard.php`. Khi session không hợp lệ, các view đưa người dùng quay lại màn hình đăng nhập.

Luồng điều hướng chính của Sinh viên được mô tả như sau:

```text
Trang gốc
   |
   v
views/login.php
   |
   +-- Đăng nhập hợp lệ, role = student
   |       |
   |       v
   |   views/dashboard.php
   |       |
   |       +-- Sidebar tra cứu nhanh
   |       |     +-- Đào tạo trực tuyến
   |       |     +-- Hỗ trợ trực tuyến
   |       |     +-- Cổng thanh toán trực tuyến
   |       |     +-- Dịch vụ sinh viên
   |       |     +-- Chương trình khung
   |       |     +-- Môn học điều kiện
   |       |     +-- Công nợ
   |       |     +-- Kết quả học tập
   |       |
   |       +-- Chatbot UTH
   |       |     +-- Gửi câu hỏi
   |       |     +-- Nghe câu trả lời
   |       |     +-- Sao chép câu trả lời
   |       |     +-- Hữu ích / Báo lỗi
   |       |     +-- Tạo ticket
   |       |
   |       +-- Thông báo và lịch học
   |       +-- Hồ sơ, avatar và đăng xuất
   |       +-- Xem / trả lời ticket
   |
   +-- Đăng nhập hợp lệ, role = admin/staff/knowledge_reviewer
           |
           v
       views/admin_dashboard.php
           |
           +-- Tổng quan
           +-- Hỗ trợ Tickets
           +-- Kiểm duyệt tri thức
           +-- Quản lý Sinh viên
           +-- Lịch sử Chat
           +-- Hồ sơ / Cài đặt / Đăng xuất
```

Trong Admin Dashboard, việc chuyển tab được thực hiện thông qua tham số `tab` trên URL và biến `$currentTab`. Các tab hiện có là `dashboard`, `tickets`, `faq`, `users` và `logs`. Các thao tác thêm, sửa, duyệt tri thức, chỉnh sửa người dùng và xử lý ticket được gửi bằng form POST đến chính `admin_dashboard.php`, sau đó điều hướng trở lại tab tương ứng.

**[CHÈN HÌNH 3.4: Sơ đồ điều hướng tổng thể của hệ thống, vẽ lại từ luồng login, dashboard Sinh viên và Admin Dashboard.]**

### 3.3.2. Mockup các màn hình chính

#### a) Màn hình đăng nhập

Màn hình đăng nhập trong `views/login.php` được chia thành hai khu vực. Khu vực bên trái trình bày nhóm thông báo và các tab tin tức; khu vực bên phải trình bày logo, tiêu đề đăng nhập, ô tài khoản, ô mật khẩu và nút đăng nhập. Ô mật khẩu có nút chuyển đổi hiển thị hoặc che mật khẩu. Form sử dụng phương thức `POST` và gửi về `login.php`; thông báo lỗi được hiển thị ngay trên trang khi tài khoản không tồn tại, tài khoản không hoạt động hoặc mật khẩu không khớp.

**[CHÈN HÌNH 3.5: Ảnh giao diện màn hình đăng nhập.]**

#### b) Dashboard Sinh viên

`views/dashboard.php` trình bày thông tin cá nhân, các thẻ thống kê và các khu vực hỗ trợ học vụ. Sidebar chứa các liên kết nhanh, trong khi khu vực chính hiển thị thông báo, lịch học và các thông tin liên quan đến tài khoản. Người dùng có thể mở modal hồ sơ sinh viên, tải avatar qua `api/upload_avatar.php`, mở chi tiết lịch học hoặc xem thông báo ticket.

Thiết kế này tạo điểm vào thống nhất cho cả dữ liệu tĩnh và dữ liệu tra cứu trực tiếp. Các câu hỏi như kết quả học tập, lịch học, học phí hoặc lịch thi không cần chuyển sang trang mới; chúng được đưa vào cửa sổ chatbot và trả về từ backend tương ứng với dữ liệu trong database.

**[CHÈN HÌNH 3.6: Ảnh giao diện Dashboard Sinh viên.]**

#### c) Cửa sổ Chatbot và khu vực tương tác câu trả lời

Chatbot được nhúng trong dashboard dưới dạng widget. Khi mở, cửa sổ có khu vực hiển thị tin nhắn, ô nhập câu hỏi, nút gửi và nhóm gợi ý. Sau khi nhận câu trả lời, mỗi tin nhắn của bot có các thao tác Nghe, Sao chép, Hữu ích, Báo lỗi và menu Thêm. Menu Thêm cho phép người dùng báo cáo câu trả lời sai hoặc gửi yêu cầu hỗ trợ.

Khi API trả về `TICKET_OFFER`, JavaScript làm sạch prefix kỹ thuật và hiển thị lời mời tạo ticket. Khi API trả về `TICKET_CONFIRM:`, giao diện hiển thị nội dung để sinh viên xác nhận trước khi gửi. Cách xử lý này giữ cho các trạng thái nghiệp vụ không bị trộn lẫn với nội dung hiển thị cuối cùng.

Chức năng nghe câu trả lời được đặt ngay cạnh nội dung bot để người dùng không phải tìm một màn hình riêng. Trạng thái nút được thay đổi trong lúc phát; âm thanh cũ bị dừng khi người dùng chọn câu trả lời mới. Nếu service TTS không hoạt động, frontend chuyển sang giọng đọc mặc định của trình duyệt.

**[CHÈN HÌNH 3.7: Ảnh cửa sổ Chatbot với câu hỏi, câu trả lời, nhóm nút thao tác và nút nghe TTS.]**

#### d) Màn hình ticket hỗ trợ

Ticket được thiết kế như một luồng trao đổi hai chiều. Sinh viên có thể tạo ticket từ chatbot hoặc từ khu vực hỗ trợ, xem nội dung trao đổi và gửi phản hồi khi ticket chưa đóng. `api/get_ticket_chat.php` trả về danh sách message theo quyền; `api/student_reply.php` kiểm tra ticket thuộc MSSV trong session và từ chối gửi nếu ticket đã đóng.

Ở phía Admin, ticket được hiển thị theo trạng thái Mới, Đang xử lý, Đã phản hồi, Đã xử lý hoặc Đã đóng. Admin có thể mở modal trao đổi, gửi phản hồi và đóng ticket. Các trạng thái này được lưu trong `tickets.status`, còn nội dung từng lượt trao đổi được lưu trong `ticket_messages`.

**[CHÈN HÌNH 3.8: Ảnh modal trao đổi ticket của Sinh viên và modal phản hồi ticket của Admin.]**

#### e) Admin Dashboard

`views/admin_dashboard.php` có thanh điều hướng với các tab Tổng quan, Hỗ trợ Tickets, Kiểm duyệt tri thức, Quản lý Sinh viên và Lịch sử Chat. Tab Tổng quan hiển thị số lượng ticket và tình trạng xử lý. Tab Hỗ trợ Tickets có bộ lọc theo trạng thái và các thao tác mở, phản hồi hoặc đóng ticket. Tab Kiểm duyệt tri thức cho phép thêm nguồn, thêm bài knowledge, chỉnh sửa nội dung, thay đổi trạng thái kiểm duyệt và tạo/cập nhật chunk tương ứng.

Tab Quản lý Sinh viên sử dụng các hàm trong `core/faq_helpers.php` để tìm hoặc tạo chương trình đào tạo, tạo tài khoản và tạo hồ sơ sinh viên. Tab Lịch sử Chat truy vấn các phiên, tin nhắn, trạng thái câu trả lời, feedback và ticket liên quan để Admin có thể kiểm tra chất lượng phản hồi. Cách tổ chức này nối trực tiếp dữ liệu vận hành với kho tri thức, thay vì tách việc xử lý phản hồi sang một công cụ ngoài hệ thống.

**[CHÈN HÌNH 3.9: Ảnh Admin Dashboard tại tab Tổng quan.]**

**[CHÈN HÌNH 3.10: Ảnh tab Kiểm duyệt tri thức và bảng chỉnh sửa knowledge.]**

#### f) Quy tắc trình bày và khả năng sử dụng

Các màn hình được tách CSS theo vai trò, giúp thay đổi giao diện login, dashboard Sinh viên và Admin mà không làm ảnh hưởng lẫn nhau. Các thao tác phản hồi được đặt gần câu trả lời hoặc ticket tương ứng, giảm số bước khi người dùng muốn đánh giá hoặc yêu cầu hỗ trợ. Đối với nội dung từ backend, code sử dụng `htmlspecialchars()` ở các vị trí hiển thị dữ liệu người dùng; phía JavaScript có `escapeHTML()` và các hàm làm sạch nội dung trước khi đưa vào DOM.

Do source hiện tại sử dụng cả nội dung PHP inline trong view và JavaScript riêng, việc kiểm thử giao diện cần được thực hiện trên đúng môi trường chạy PHP/MySQL của dự án. Các ảnh chụp màn hình được chèn vào báo cáo chính thức sau khi nhóm kiểm tra lại phiên bản giao diện, tài khoản mẫu và dữ liệu hiển thị.

Như vậy, Chương 3 đã chuyển các mô hình khái niệm đã được duyệt thành cấu trúc schema, endpoint backend và luồng giao diện thực tế. Những điều chỉnh như mở rộng schema để lưu RAG/ticket và thay JWT bằng PHP Session được xem là các quyết định trong giai đoạn triển khai, có mục tiêu bảo đảm hệ thống chạy thống nhất với PHP view, MySQL và service TTS hiện có. Các kết quả kiểm thử, số liệu hiệu năng và đánh giá bảo mật sẽ được trình bày ở Chương 4 sau khi có dữ liệu kiểm thử thực tế.

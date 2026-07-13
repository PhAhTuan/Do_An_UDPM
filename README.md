# UTH Chatbot Portal

UTH Chatbot Portal là một hệ thống web tích hợp Chatbot thông minh dựa trên trí tuệ nhân tạo (AI), sử dụng Google Gemini API và kỹ thuật RAG. Dự án được thiết kế chuyên biệt để hỗ trợ sinh viên trường Đại học Giao thông Vận tải TP.HCM (UTH) trong việc tự động giải đáp các thắc mắc về học vụ, quy chế, lịch học, học phí, và thông tin trường.

## Tổng quan và Tính năng nổi bật

- Chatbot AI thông minh (Gemini + RAG): Trả lời câu hỏi tự nhiên theo ngữ cảnh, tìm kiếm và trích xuất thông tin nội bộ từ kho tri thức FAQ của trường.
- Cá nhân hóa cho Sinh viên: Cho phép tra cứu thời khóa biểu, lịch thi, hạn chót, truy xuất điểm thi, học phí và thông tin hồ sơ cá nhân.
- Phát Giọng Nói (Text-to-Speech - TTS): Phản hồi của Chatbot có thể được phát dưới dạng âm thanh tiếng Việt thông qua một service Python độc lập.
- Phân hệ Admin Dashboard: Quản trị viên có thể quản lý kiến thức nền (FAQ), thông tin người dùng, theo dõi lịch sử chat, thống kê, và xử lý Ticket (yêu cầu hỗ trợ) từ sinh viên.

[Hình ảnh giao diện hoặc Demo GIF có thể được thêm vào đây]

## Hướng dẫn cài đặt (Installation)

### Yêu cầu hệ thống
- Môi trường chạy PHP/MySQL (XAMPP cho Windows/Mac, hoặc MAMP/WAMP).
- Python 3.8 trở lên.
- Pip (Python Package Manager).

### Các bước cài đặt
1. Clone hoặc tải mã nguồn dự án về máy tính của bạn.
2. Đặt toàn bộ mã nguồn vào thư mục root của web server (ví dụ: thư mục `htdocs` của XAMPP/MAMP).
3. Thiết lập Cơ sở dữ liệu MySQL:
   - Mở công cụ quản lý MySQL (như phpMyAdmin).
   - Tạo hoặc sử dụng database có tên `do_an_udpm`.
   - Import file `database/do_an_udpm_database_complete.sql` để tạo schema chính.
   - Import tiếp file `database/do_an_udpm_demo_seed.sql` để thêm dữ liệu mẫu.
4. Cấu hình môi trường Web:
   - Tạo hoặc chỉnh sửa file `.env` tại thư mục gốc.
   - Thiết lập thông số database: `DB_HOST`, `DB_PORT` (thường là 3306 cho Windows/XAMPP, 8889 cho Mac/MAMP), `DB_USER`, `DB_PASS`, `DB_NAME=do_an_udpm`.
   - Cập nhật khóa API vào biến `GEMINI_API_KEY`.
5. Thiết lập Server TTS (Text-to-Speech):
   - Mở Terminal (Mac) hoặc Command Prompt (Windows) tại thư mục `tts` hoặc thư mục gốc chứa code TTS của dự án.
   - Cài đặt thư viện: 
     ```bash
     pip install -r requirements.txt
     ```

## Hướng dẫn sử dụng (Usage)

1. Khởi động Web Server (Apache/MySQL) trên XAMPP/MAMP.
2. Khởi động Server TTS:
   - Mở Terminal/Command Prompt tại thư mục chứa file server.py.
   - Chạy lệnh:
     ```bash
     uvicorn server:app --host 0.0.0.0 --port 8000
     ```
3. Truy cập vào hệ thống thông qua trình duyệt web:
   ```text
   http://localhost/<thư_mục_dự_án>
   ```
4. Sử dụng các tài khoản mẫu để đăng nhập:
   - Tài khoản Admin: `admin / admin123`
   - Tài khoản Sinh viên: `075205019210 / sv123`


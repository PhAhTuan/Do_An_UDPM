# Dự án UTH Chatbot Portal

## 📖 Giới thiệu
**UTH Chatbot Portal** là một hệ thống web tích hợp Chatbot thông minh dựa trên trí tuệ nhân tạo (AI), được thiết kế chuyên biệt để hỗ trợ sinh viên trường Đại học (UTH - University of Transport and Communications). 

Dự án kết hợp sức mạnh của **Google Gemini API** cùng kỹ thuật **RAG (Retrieval-Augmented Generation)** để tự động giải đáp các thắc mắc về học vụ, quy chế, thông tin trường, lịch học, học phí, và điểm thi. Ngoài ra, hệ thống còn hỗ trợ đọc phản hồi bằng giọng nói tiếng Việt thông qua công nghệ **Text-to-Speech (TTS)**.

## 🚀 Công nghệ sử dụng
- **Frontend:** HTML, CSS, JavaScript (Giao diện web trực quan, thân thiện cho sinh viên và admin).
- **Backend (Web & API):** PHP (Xử lý logic chính, tích hợp Gemini API, quản lý phiên chat, xác thực).
- **Backend (TTS Microservice):** Python với FastAPI và thư viện `gTTS`.
- **Cơ sở dữ liệu:** MySQL (lưu trữ thông tin sinh viên, lịch học, FAQ, lịch sử chat...).
- **AI / LLM:** Google Gemini API.

## ✨ Tính năng nổi bật
1. **Chatbot AI thông minh (Gemini + RAG):**
   - Trả lời câu hỏi tự nhiên theo ngữ cảnh.
   - Tìm kiếm và trích xuất thông tin nội bộ (FAQ, quy chế đào tạo) qua kỹ thuật RAG.
2. **Cá nhân hóa cho Sinh viên:**
   - Tra cứu thời khóa biểu, lịch thi, hạn chót (deadlines).
   - Truy xuất điểm thi, học phí, và thông tin hồ sơ sinh viên.
3. **Text-to-Speech (TTS):**
   - Phản hồi của Chatbot có thể được phát dưới dạng âm thanh tiếng Việt thông qua một service Python độc lập (`tts_server.py`).
4. **Phân hệ Admin Dashboard:**
   - Quản lý kiến thức nền (FAQ) cho Chatbot.
   - Quản lý thông tin người dùng / sinh viên.
   - Theo dõi lịch sử chat, đánh giá, thống kê (report).
   - Quản lý Ticket (yêu cầu hỗ trợ) từ sinh viên.

## 📂 Cấu trúc thư mục

```
Do_An_UDPM/
│
├── config.php              # Kết nối MySQL & Gemini API Key (dùng chung toàn dự án)
├── .htaccess               # Redirect URL gốc sang views/
│
├── views/                  # 🌐 Giao diện web (entry points)
│   ├── login.php
│   ├── dashboard.php
│   └── admin_dashboard.php
│
├── api/                    # 📡 API endpoints
│   ├── chatbot.php
│   ├── get_student_chat.php
│   ├── get_ticket_chat.php
│   ├── report_bot.php
│   ├── student_reply.php
│   ├── text_to_speech.php
│   └── upload_avatar.php
│
├── core/                   # 🤖 Logic nghiệp vụ
│   ├── faq_helpers.php
│   └── new_logic.php
│
├── tts/                    # 🔊 Python TTS microservice
│   ├── server.py
│   └── requirements.txt
│
├── database/               # 🗄 Scripts DB & seed data
│   ├── do_an_udpm_database_complete.sql
│   ├── do_an_udpm_demo_seed.sql
│   ├── uth_db.sql
│   ├── faq_knowledge_seed.sql
│   ├── add_column.php
│   ├── add_new_tables.php
│   ├── check_db.php
│   ├── check_tables.php
│   ├── seed_faq_knowledge.php
│   └── setup_data.php
│
├── css/                    # Stylesheet
├── js/                     # JavaScript (chatbot.js, admin.js)
└── uploads/                # File upload của người dùng
```

## 🛠 Hướng dẫn Cài đặt & Khởi chạy

### 1. Yêu cầu hệ thống
- Môi trường chạy PHP/MySQL (XAMPP, MAMP, hoặc WAMP).
- Python 3.8 trở lên.
- Pip (Python Package Manager).

### 2. Thiết lập Web (PHP & MySQL)
1. **Import Cơ sở dữ liệu:**
   - Mở phpMyAdmin (hoặc công cụ quản lý MySQL của bạn).
   - Dùng database tên `do_an_udpm`.
   - Import file `database/do_an_udpm_database_complete.sql` để tạo schema chính.
   - Import tiếp file `database/do_an_udpm_demo_seed.sql` để thêm tài khoản mẫu, hồ sơ sinh viên, lịch học, lịch thi, học phí, thông báo/deadline và knowledge đã kiểm duyệt.
   - Tài khoản mẫu sau khi import mới: `admin / admin123` và `075205019210 / sv123`.
2. **Cấu hình dự án:**
   - Mở file `.env`.
   - Kiểm tra `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME=do_an_udpm`.
   - Đặt khóa Gemini vào `GEMINI_API_KEY` trong `.env`, không đặt API key trong source code.
3. **Chạy web:**
   - Đặt toàn bộ mã nguồn vào thư mục root của web server (ví dụ: `htdocs` của XAMPP hoặc `htdocs` của MAMP).
   - Mở trình duyệt và truy cập: `http://localhost/<thư_mục_dự_án>`.

### 3. Thiết lập Server TTS (Text-to-Speech)
Server TTS cần được chạy song song để hỗ trợ tính năng phát âm thanh của bot.
1. Mở Terminal / Command Prompt tại thư mục dự án.
2. Cài đặt các thư viện Python:
   ```bash
   pip install -r requirements-tts.txt
   ```
3. Khởi chạy server FastAPI:
   ```bash
   uvicorn tts_server:app --host 0.0.0.0 --port 8000
   ```
   *(Server sẽ chạy tại `http://localhost:8000`)*

## 🛡 Lưu ý
- API Key của Gemini cần được bảo mật trong `.env`; không hardcode hoặc commit API key vào source code.
- Đối với MacOS dùng MAMP, cổng MySQL mặc định thường là `8889` thay vì `3306`. Hãy kiểm tra kỹ file `config.php`.

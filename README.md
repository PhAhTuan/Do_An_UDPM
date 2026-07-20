# Báo cáo Đồ án — UTH Chatbot Portal

> Tài liệu gồm **Phần 1** (Giới thiệu) · **Phần 2** (Thiết kế hệ thống) · **Phần 3** (Sản phẩm) · **Phần 4** (Tổng kết)
>
> **Phạm vi:** Web Application — PHP + MySQL + Python  
> **Nền tảng:** Apache (XAMPP/MAMP) · PHP 8.0+ · MySQL · Python 3.8+  
> **Môn học:** Ứng Dụng Phân Mềm (UDPM) — Đại học Giao thông Vận tải TP.HCM (UTH)

---

## Mục lục

- [Phần 1 — Giới thiệu](#phần-1--giới-thiệu)
  - [1.1 Bối cảnh và mục tiêu dự án](#11-bối-cảnh-và-mục-tiêu-dự-án)
  - [1.2 Giới thiệu tổng quan sản phẩm](#12-giới-thiệu-tổng-quan-sản-phẩm)
  - [1.3 Đối tượng người dùng](#13-đối-tượng-người-dùng)
  - [1.4 Các chức năng của sản phẩm](#14-các-chức-năng-của-sản-phẩm)
  - [1.5 Kiến thức và kỹ năng đã áp dụng](#15-kiến-thức-và-kỹ-năng-đã-áp-dụng)
  - [1.6 Phạm vi và hạn chế](#16-phạm-vi-và-hạn-chế)
- [Phần 2 — Thiết kế hệ thống](#phần-2--thiết-kế-hệ-thống)
  - [1. Tổng quan kiến trúc phần mềm](#1-tổng-quan-kiến-trúc-phần-mềm)
  - [2. Công nghệ và thành phần hạ tầng](#2-công-nghệ-và-thành-phần-hạ-tầng)
  - [3. Sơ đồ kiến trúc tổng thể](#3-sơ-đồ-kiến-trúc-tổng-thể)
  - [4. Luồng dữ liệu và các tầng](#4-luồng-dữ-liệu-và-các-tầng)
  - [5. Cấu trúc thư mục chi tiết](#5-cấu-trúc-thư-mục-chi-tiết)
  - [6. Mô hình dữ liệu và CSDL](#6-mô-hình-dữ-liệu-và-csdl)
  - [7. Các thuật toán](#7-các-thuật-toán)
- [Phần 3 — Sản phẩm](#phần-3--sản-phẩm)
  - [3.1 Tổng quan sản phẩm](#31-tổng-quan-sản-phẩm)
  - [3.2 Hướng dẫn cài đặt và sử dụng](#32-hướng-dẫn-cài-đặt-và-sử-dụng)
  - [3.3 Mô tả chi tiết từng chức năng](#33-mô-tả-chi-tiết-từng-chức-năng)
- [Phần 4 — Tổng kết](#phần-4--tổng-kết)
  - [4.1 Tự đánh giá sản phẩm](#41-tự-đánh-giá-sản-phẩm)
  - [4.2 So sánh với mục tiêu ban đầu](#42-so-sánh-với-mục-tiêu-ban-đầu)
  - [4.3 Hạn chế và rủi ro hiện tại](#43-hạn-chế-và-rủi-ro-hiện-tại)
  - [4.4 Hướng phát triển](#44-hướng-phát-triển)

---

## Phần 1 — Giới thiệu

### 1.1 Bối cảnh và mục tiêu dự án

Trong môi trường đại học, sinh viên thường phải tìm kiếm thông tin học vụ qua nhiều kênh khác nhau — website trường, email giảng viên, hỏi văn phòng khoa — gây tốn thời gian và không đồng nhất. Đặc biệt tại **Đại học Giao thông Vận tải TP.HCM (UTH)**, nhu cầu tra cứu tự động về lịch học, học phí, quy chế và thông tin cá nhân là rất cao.

**UTH Chatbot Portal** là hệ thống web do nhóm phát triển nhằm:

- **Tự động hóa** việc giải đáp thắc mắc học vụ thông qua Chatbot AI 24/7.
- **Cá nhân hóa** thông tin: sinh viên tra cứu điểm, lịch học, học phí theo đúng mã của mình.
- **Giảm tải** công việc cho bộ phận hỗ trợ sinh viên nhờ hệ thống Ticket tự động.
- **Tập trung hóa** kiến thức trường vào kho tri thức FAQ có thể quản lý và mở rộng.

Dự án được xây dựng trong khuôn khổ đồ án môn **Ứng Dụng Phân Mềm**, tập trung vào tích hợp AI thực dụng (Google Gemini API + RAG), kiến trúc web PHP có tổ chức và trải nghiệm người dùng thực tế.

---

### 1.2 Giới thiệu tổng quan sản phẩm

#### 1.2.1 UTH Chatbot Portal là gì?

UTH Chatbot Portal là hệ thống web hỗ trợ sinh viên xây dựng theo mô hình **một tài khoản — một hồ sơ học vụ — một Chatbot cá nhân hóa**:

```
Hệ thống
    ├── Phân hệ Sinh viên
    │       ├── Chatbot AI (RAG + Gemini)
    │       ├── Tra cứu học vụ (lịch học, điểm, học phí)
    │       └── Ticket hỗ trợ
    └── Phân hệ Admin
            ├── Quản lý kho tri thức FAQ
            ├── Quản lý tài khoản sinh viên
            ├── Theo dõi lịch sử chat
            └── Xử lý Ticket yêu cầu hỗ trợ
```

**Luồng sử dụng điển hình:**

1. Sinh viên truy cập → Đăng nhập bằng MSSV.
2. Vào Dashboard → Gõ câu hỏi vào Chatbot.
3. Hệ thống tìm trong FAQ (RAG) → Gửi prompt kèm context cho Gemini → Trả lời.
4. Sinh viên tra cứu lịch học / điểm / học phí ngay trong sidebar.
5. Nếu cần hỗ trợ thủ công → Tạo Ticket → Admin xử lý và phản hồi.

#### 1.2.2 Điểm nổi bật so với chatbot thông thường

| Khía cạnh | Chatbot AI thông thường | UTH Chatbot Portal |
|---|---|---|
| Nguồn tri thức | Kiến thức chung của LLM | RAG từ FAQ nội bộ UTH |
| Cá nhân hóa | Không có | Lấy dữ liệu học vụ theo MSSV |
| Phát giọng nói | Không có | TTS tiếng Việt (gTTS microservice) |
| Hỗ trợ thủ công | Không có | Hệ thống Ticket Admin ↔ Sinh viên |
| Quản lý tri thức | Không thể chỉnh sửa | Admin CRUD kho FAQ trực tiếp |

---

### 1.3 Đối tượng người dùng

| Nhóm | Nhu cầu | Tính năng hỗ trợ |
|---|---|---|
| Sinh viên UTH | Hỏi nhanh về học vụ, quy chế, lịch học | Chatbot AI, tra cứu cá nhân hóa |
| Sinh viên cần hỗ trợ đặc biệt | Vấn đề phức tạp, cần người thật giải quyết | Hệ thống Ticket |
| Quản trị viên trường | Cập nhật thông tin, quản lý chat, xử lý yêu cầu | Admin Dashboard toàn diện |

---

### 1.4 Các chức năng của sản phẩm

#### 1.4.1 Xác thực và hồ sơ

| STT | Chức năng | Mô tả | File liên quan |
|---|---|---|---|
| 1 | Đăng nhập sinh viên | MSSV + mật khẩu, tạo session | `views/login.php` |
| 2 | Đăng nhập admin | Tài khoản role=admin | `views/login.php` |
| 3 | Đăng xuất | Xóa session, redirect về Login | `views/login.php` |
| 4 | Hồ sơ cá nhân | Xem tên, lớp, khoa, email, SĐT | `views/dashboard.php` |
| 5 | Upload avatar | Đổi ảnh đại diện | `api/upload_avatar.php` |

#### 1.4.2 Chatbot AI (tính năng lõi)

| STT | Chức năng | Mô tả | File liên quan |
|---|---|---|---|
| 6 | Gửi / nhận tin nhắn | Giao tiếp tự nhiên tiếng Việt | `api/chatbot.php`, `js/chatbot.js` |
| 7 | RAG — tìm FAQ | Tìm kiếm kho tri thức trước khi gọi Gemini | `core/faq_helpers.php` |
| 8 | Tích hợp Gemini AI | Gọi Google Gemini API sinh câu trả lời | `api/chatbot.php` |
| 9 | Render Markdown | Câu trả lời hiển thị có định dạng | `js/chatbot.js` |
| 10 | Phát giọng nói (TTS) | Nghe câu trả lời bằng tiếng Việt | `api/text_to_speech.php`, `tts/server.py` |
| 11 | Lịch sử hội thoại | Lưu và hiển thị toàn bộ lịch sử chat | `api/chatbot.php` |
| 12 | Xóa lịch sử chat | Bắt đầu hội thoại mới | `api/delete_chat_history.php` |
| 13 | Phản hồi câu trả lời | Like / Dislike từng tin nhắn bot | `api/chat_feedback.php` |
| 14 | Báo cáo bot sai | Gắn cờ câu trả lời sai để cải thiện FAQ | `api/report_bot.php` |

#### 1.4.3 Tra cứu học vụ cá nhân hóa

| STT | Chức năng | Mô tả |
|---|---|---|
| 15 | Thời khóa biểu | Xem lịch học theo từng tuần/học kỳ |
| 16 | Lịch thi | Xem ngày thi, phòng thi |
| 17 | Điểm thi | Xem điểm theo từng môn, học kỳ |
| 18 | Học phí | Kiểm tra học phí, hạn đóng tiền |

#### 1.4.4 Ticket hỗ trợ

| STT | Chức năng | Mô tả | File liên quan |
|---|---|---|---|
| 19 | Tạo Ticket | Sinh viên gửi yêu cầu hỗ trợ | `api/create_ticket.php` |
| 20 | Xem chat Ticket | Theo dõi trao đổi trong ticket | `api/get_ticket_chat.php` |
| 21 | Phản hồi Ticket | Sinh viên reply vào ticket đang mở | `api/student_reply.php` |

#### 1.4.5 Admin Dashboard

| STT | Chức năng | Mô tả |
|---|---|---|
| 22 | Tổng quan thống kê | Số người dùng, chat, ticket, FAQ |
| 23 | Quản lý FAQ | CRUD câu hỏi-đáp trong kho tri thức |
| 24 | Quản lý sinh viên | Xem danh sách, thông tin, lịch sử |
| 25 | Lịch sử chat | Xem toàn bộ cuộc hội thoại của mọi sinh viên |
| 26 | Xử lý Ticket | Phản hồi, đóng, phân loại yêu cầu hỗ trợ |
| 27 | Xem chat Ticket | Đọc nội dung trao đổi từng ticket | 

#### 1.4.6 Sơ đồ chức năng tổng hợp

```
UTH Chatbot Portal
│
├── [Sinh viên]
│   ├── Xác thực ──────────── Đăng nhập MSSV, Đăng xuất, Upload Avatar
│   ├── Chatbot AI ─────────── Hỏi đáp RAG+Gemini, TTS, Feedback, Báo lỗi
│   ├── Học vụ cá nhân ─────── TKB, Lịch thi, Điểm, Học phí
│   └── Ticket ─────────────── Tạo, Xem, Phản hồi
│
└── [Admin]
    ├── Xác thực ──────────── Đăng nhập Admin
    ├── Quản lý FAQ ────────── Thêm / Sửa / Xóa câu hỏi-đáp
    ├── Quản lý sinh viên ──── Xem danh sách, hồ sơ, hoạt động
    ├── Lịch sử Chat ───────── Giám sát toàn bộ hội thoại
    ├── Thống kê ───────────── Tổng quan số liệu hệ thống
    └── Ticket ─────────────── Xử lý, phản hồi yêu cầu
```

---

### 1.5 Kiến thức và kỹ năng đã áp dụng

#### 1.5.1 Lập trình Web (PHP & Frontend)

| Kiến thức / Kỹ năng | Áp dụng trong dự án |
|---|---|
| PHP | Toàn bộ backend; session, xử lý form, kết nối MySQL |
| JavaScript (ES6+) | Chatbot frontend: fetch API, stream, event handler |
| HTML5 / CSS3 | Giao diện responsive, animation, glassmorphism |
| Fetch API / AJAX | Giao tiếp không đồng bộ với PHP backend |
| Render Markdown | Hiển thị câu trả lời Gemini có định dạng |

#### 1.5.2 Tích hợp AI và API

| Kiến thức / Kỹ năng | Áp dụng trong dự án |
|---|---|
| Google Gemini API | Gọi LLM sinh câu trả lời từ prompt có context |
| RAG (Retrieval-Augmented Generation) | Tìm FAQ → xây dựng context → prompt Gemini |
| REST API (HTTP/PHP) | Gọi Gemini API bằng cURL từ PHP |
| Prompt Engineering | Thiết kế system prompt vai trò UTH assistant |

#### 1.5.3 Cơ sở dữ liệu

| Kiến thức / Kỹ năng | Áp dụng trong dự án |
|---|---|
| MySQL | Thiết kế schema, truy vấn JOIN, subquery |
| PDO / MySQLi | Kết nối PHP-MySQL, prepared statement |
| Database migration | PHP script thêm cột, bảng mới khi cần |

#### 1.5.4 Hạ tầng và dịch vụ nền

| Kiến thức / Kỹ năng | Áp dụng trong dự án |
|---|---|
| Apache / .htaccess | Cấu hình web server, bảo mật đường dẫn |
| Python (FastAPI) | Microservice TTS độc lập |
| gTTS | Text-to-Speech tiếng Việt |
| Uvicorn | ASGI server cho Python microservice |
| Biến môi trường (.env) | Tách cấu hình nhạy cảm khỏi code |

#### 1.5.5 Bảng ánh xạ: môn học → thành phần code

| Nội dung môn Ứng Dụng Phân Mềm | Minh chứng trong UTH Chatbot Portal |
|---|---|
| Lập trình web backend | PHP xử lý session, form, API endpoint |
| Cơ sở dữ liệu quan hệ | MySQL schema 12+ bảng, JOIN phức tạp |
| Tích hợp dịch vụ bên thứ ba | Google Gemini API, gTTS |
| Kiến trúc phần mềm | Phân tách views/, api/, core/ |
| Giao tiếp client-server | AJAX/Fetch không đồng bộ |
| Microservice | TTS service Python độc lập |

---

### 1.6 Phạm vi và hạn chế

**Trong phạm vi đồ án:**
- Ứng dụng web (không có app mobile).
- Tập trung hỗ trợ học vụ UTH, chưa tích hợp hệ thống quản lý đào tạo thực tế.
- Từ điển FAQ nhập thủ công qua Admin / SQL seed.

**Hạn chế kỹ thuật đã ghi nhận:**
- API Gemini phụ thuộc kết nối internet và quota key.
- TTS phụ thuộc Python service chạy song song — nếu service tắt thì tính năng âm thanh không hoạt động.
- Chưa có cơ chế phân quyền chi tiết (chỉ có role admin / sinh viên).
- Chưa có tính năng học chủ động (quiz, kiểm tra) — thuần hỏi-đáp.

---

## Phần 2 — Thiết kế hệ thống

> **Phạm vi:** Toàn bộ mã nguồn `Do_An_UDPM/`  
> **Sản phẩm:** Hệ thống Chatbot web hỗ trợ sinh viên UTH — RAG + Gemini, PHP, MySQL, Python TTS.

---

### 1. Tổng quan kiến trúc phần mềm

#### 1.1 Mô hình kiến trúc lựa chọn

UTH Chatbot Portal được xây dựng theo mô hình **MVC-lite** (Model-View-Controller đơn giản hóa) trên nền PHP truyền thống, kết hợp kiến trúc **Microservice** cho tính năng TTS. Lý do lựa chọn:

- **Phù hợp stack PHP/MySQL:** Không cần framework nặng (Laravel/Symfony) cho quy mô đồ án; thuần PHP dễ triển khai trên XAMPP/MAMP.
- **Tách biệt rõ ràng:** Views (giao diện), API endpoints (xử lý logic), Core (nghiệp vụ dùng chung).
- **Microservice TTS:** Python service độc lập → có thể nâng cấp / thay thế engine TTS mà không ảnh hưởng backend PHP.

#### 1.2 Các tầng logic và trách nhiệm

| Tầng | Thành phần chính | Trách nhiệm | Thư mục |
|---|---|---|---|
| Presentation | `*.php` (views), `*.js`, `*.css` | Giao diện người dùng; render HTML; gửi AJAX request | `views/`, `js/`, `css/` |
| API / Controller | `api/*.php` | Nhận request, xử lý logic, trả JSON | `api/` |
| Business Logic | `core/faq_helpers.php` | RAG tìm kiếm FAQ, xây dựng context prompt | `core/` |
| Data Layer | MySQL queries trong PHP | Đọc/ghi CSDL qua PDO | trực tiếp trong `api/`, `views/` |
| AI Service | Google Gemini API | Sinh ngôn ngữ tự nhiên | External API |
| TTS Service | `tts/server.py` (FastAPI) | Text → MP3 tiếng Việt | `tts/` |

**Quy tắc phụ thuộc:**  
`views/` → gọi `api/*.php` qua AJAX → `api/` gọi `core/` và MySQL → `api/` gọi Gemini API hoặc TTS service.

#### 1.3 Các nguyên tắc thiết kế then chốt

**RAG trước LLM**  
Mọi câu hỏi đều đi qua `faq_helpers.php` tìm kiếm nội bộ trước. Chỉ khi không tìm thấy FAQ phù hợp, hệ thống mới dùng kiến thức chung của Gemini — giảm hallucination.

**Session-based Authentication**  
Xác thực qua PHP session (`$_SESSION`). Mỗi request API kiểm tra session hợp lệ trước khi xử lý.

**Microservice TTS độc lập**  
PHP không tự phát âm thanh mà gọi Python FastAPI service qua HTTP. Tách bạch ngôn ngữ và runtime.

**Cấu hình qua .env**  
API key và database credential tách ra file `.env`, không commit lên git — bảo mật và dễ deploy đa môi trường.

#### 1.4 Điểm vào hệ thống (Entry points)

| Thành phần | File | Vai trò |
|---|---|---|
| Config | `config.php` | Đọc `.env`, khởi tạo biến `$apiKey`, `$db_*` |
| Trang đăng nhập | `views/login.php` | Điểm vào duy nhất cho cả sinh viên và admin |
| Dashboard sinh viên | `views/dashboard.php` | Giao diện chính — chatbot + sidebar học vụ |
| Admin Dashboard | `views/admin_dashboard.php` | Toàn bộ chức năng quản trị |
| Chatbot API | `api/chatbot.php` | API lõi: RAG + Gemini + lưu lịch sử |
| TTS Service | `tts/server.py` | FastAPI nhận text → trả MP3 |

---

### 2. Công nghệ và thành phần hạ tầng

| Thành phần | Công nghệ / Thư viện |
|---|---|
| Backend | PHP 8.0+ (procedural + hàm helper) |
| Frontend | HTML5, CSS3 Vanilla, JavaScript ES6+ |
| Database | MySQL 5.7 / 8.0 |
| AI / LLM | Google Gemini API (`gemini-2.0-flash`) |
| RAG Engine | Tự xây dựng — keyword + fuzzy matching trên bảng FAQ |
| TTS Service | Python 3.8+, FastAPI, Uvicorn, gTTS |
| Web Server | Apache (XAMPP / MAMP) |
| HTTP Client (PHP) | cURL (gọi Gemini API, TTS proxy) |
| Cấu hình môi trường | File `.env` tùy chỉnh |

---

### 3. Sơ đồ kiến trúc tổng thể

#### 3.1 Sơ đồ phân tầng logic

```
┌──────────────────────────────────────────────────────────────────┐
│                    TẦNG PRESENTATION (Browser)                    │
│                                                                  │
│  views/login.php     views/dashboard.php    views/admin_dashboard │
│  css/login.css       css/dashboard.css      css/admin.css        │
│  js/chatbot.js       js/admin.js                                 │
│                                                                  │
│  Render HTML + CSS · AJAX/Fetch gọi API · Render Markdown · TTS  │
└─────────────────────────┬────────────────────────────────────────┘
                          │  HTTP / AJAX (JSON)
                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    TẦNG API / CONTROLLER (PHP)                    │
│                                                                  │
│  api/chatbot.php          api/text_to_speech.php                 │
│  api/chat_feedback.php    api/create_ticket.php                  │
│  api/delete_chat_history  api/get_student_chat.php               │
│  api/report_bot.php       api/student_reply.php                  │
│  api/upload_avatar.php    api/get_ticket_chat.php                │
│                                                                  │
│  Kiểm tra session · Xử lý input · Gọi Core · Trả JSON           │
└──────────┬───────────────────────┬───────────────────────────────┘
           │                       │
           ▼                       ▼
┌────────────────────┐   ┌─────────────────────────────────────────┐
│  TẦNG CORE / BIZ   │   │         TẦNG DỮ LIỆU (MySQL)            │
│  LOGIC (PHP)       │   │                                         │
│                    │   │  users          srs_cards (nếu có)      │
│  core/             │   │  student_info   chat_history            │
│  faq_helpers.php   │   │  faq_knowledge  chat_feedback           │
│                    │   │  tickets        ticket_messages          │
│  - searchFAQ()     │   │  schedules      exam_schedule           │
│  - fuzzyMatch()    │   │  grades         tuition_fees            │
│  - buildContext()  │   │  bot_reports    notifications           │
│  - buildPrompt()   │   │                                         │
└──────────┬─────────┘   └─────────────────────────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────────┐
│                    DỊCH VỤ BÊN NGOÀI                             │
│                                                                  │
│  ┌─────────────────────────┐    ┌──────────────────────────────┐ │
│  │  Google Gemini API      │    │  TTS Microservice (Python)   │ │
│  │  gemini-2.0-flash       │    │  FastAPI · Uvicorn · gTTS    │ │
│  │  Sinh câu trả lời NLP   │    │  Port: 8000                  │ │
│  │  (cURL từ PHP)          │    │  Text → MP3 tiếng Việt       │ │
│  └─────────────────────────┘    └──────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
```

#### 3.2 Sơ đồ triển khai thiết bị và mạng

```
[Máy tính người dùng]
        │
        │  HTTP (localhost)
        ▼
┌───────────────────────────────────────────────────────────────┐
│  Apache Web Server (XAMPP / MAMP)   Port: 80 / 8888           │
│                                                               │
│  ┌───────────────┐   ┌────────────────┐   ┌───────────────┐  │
│  │  views/       │   │  api/          │   │  core/        │  │
│  │  PHP pages    │──▶│  PHP endpoints │──▶│  faq_helpers  │  │
│  └───────────────┘   └───────┬────────┘   └───────────────┘  │
│                              │                               │
│                    ┌─────────▼──────────┐                    │
│                    │  MySQL (Port 3306   │                    │
│                    │  hoặc 8889 MAMP)   │                    │
│                    │  do_an_udpm        │                    │
│                    └────────────────────┘                    │
└───────────────────────────┬───────────────────────────────────┘
                            │
              ┌─────────────┼────────────────┐
              │             │                │
              ▼             ▼                ▼
    [Google Gemini    [TTS Service      [Trình duyệt
     API Cloud]        Python :8000]    sinh viên/admin]
     (HTTPS)           (localhost)
```

#### 3.3 Sequence: Luồng xử lý một tin nhắn Chatbot

```
Sinh viên        chatbot.js        api/chatbot.php     faq_helpers.php    Gemini API
    │                 │                   │                   │                │
    │── Nhập câu hỏi ─▶                   │                   │                │
    │                 │── POST /api/chat ─▶                   │                │
    │                 │                   │── searchFAQ() ───▶                │
    │                 │                   │                   │─ Fuzzy match   │
    │                 │                   │◀── FAQ context ───│                │
    │                 │                   │                   │                │
    │                 │                   │── buildPrompt()   │                │
    │                 │                   │   (system + ctx   │                │
    │                 │                   │    + history +    │                │
    │                 │                   │    question)      │                │
    │                 │                   │─────────── POST cURL ─────────────▶│
    │                 │                   │                   │◀── JSON resp ──│
    │                 │                   │── Lưu chat_history (MySQL)         │
    │                 │◀── JSON {answer} ─│                   │                │
    │◀── Render MD ───│                   │                   │                │
    │                 │                   │                   │                │
    │── Bấm TTS ──────▶                   │                   │                │
    │                 │── GET /api/tts ──▶│                   │                │
    │                 │                   │── proxy → :8000/tts                │
    │                 │◀── MP3 audio ─────│                   │                │
    │◀── Phát âm thanh│                   │                   │                │
```

---

### 4. Luồng dữ liệu và các tầng

#### 4.1 Tầng Presentation — Luồng hiển thị

**Thành phần:** `views/*.php`, `js/chatbot.js`, `css/*.css`

Cơ chế:
- PHP render HTML tĩnh ban đầu, nhúng session data (userId, tên sinh viên, lịch học) vào biến JavaScript.
- JavaScript `chatbot.js` lắng nghe sự kiện gửi tin → `fetch('/api/chatbot.php', {...})` → nhận JSON → render Markdown → cập nhật DOM.
- Giao diện Admin dùng tab switching JavaScript thuần — không reload trang.

**Ví dụ — Dashboard sinh viên hiển thị thời khóa biểu:**
```
views/dashboard.php
  → PHP query: SELECT * FROM schedules WHERE user_id = $userId
    → Render bảng TKB trong HTML
  → JavaScript: lắng nghe tab "Lịch học" → toggle display
```

#### 4.2 Tầng API / Controller — Luồng xử lý

**Thành phần:** `api/*.php`

Mọi API endpoint theo pattern:
```php
1. Kiểm tra session → nếu không hợp lệ: 401 Unauthorized
2. Đọc input (POST/GET) → validate
3. Kết nối MySQL (dùng config.php)
4. Gọi core/ nếu cần (faq_helpers.php)
5. Gọi Gemini API / TTS nếu cần (cURL)
6. Ghi kết quả vào MySQL
7. Trả về JSON response
```

**Ví dụ — api/chatbot.php (file lõi ~78KB):**
```
Nhận {message, session_id}
  → Lấy lịch sử hội thoại từ chat_history
  → searchFAQ($message) → trả về $faqContext
  → Lấy thông tin cá nhân sinh viên ($userInfo, $schedule, $grades)
  → buildPrompt($systemPrompt, $faqContext, $userInfo, $history, $message)
  → cURL POST → Gemini API
  → Lưu Q&A vào chat_history
  → Trả JSON {success, answer, session_id}
```

#### 4.3 Tầng Core — Nghiệp vụ RAG

**Thành phần:** `core/faq_helpers.php`

Đây là trái tim của RAG engine — thực hiện tìm kiếm trước khi gọi LLM:

```
searchFAQ($userQuestion)
  │
  ├── Bước 1: Tách từ khóa từ câu hỏi
  │   "học phí khi nào đóng" → ["học phí", "đóng"]
  │
  ├── Bước 2: Keyword matching
  │   SELECT * FROM faq_knowledge WHERE keywords LIKE '%học phí%'
  │
  ├── Bước 3: Fuzzy matching (tương đồng chuỗi)
  │   similar_text($question, $faq->question) → score %
  │
  ├── Bước 4: Lọc theo ngưỡng (threshold)
  │   Giữ lại FAQ có score > 40%
  │
  └── Bước 5: Trả về top-N FAQ làm context
      [{"question": "...", "answer": "..."}]
```

#### 4.4 Bảng tóm tắt hướng luồng dữ liệu

| Hành động người dùng | Presentation | API/Controller | Core / DB / AI |
|---|---|---|---|
| Đăng nhập | `login.php` form submit | `login.php` kiểm tra DB | MySQL `users` table |
| Gửi tin nhắn | `chatbot.js` fetch | `chatbot.php` | `faq_helpers` → Gemini → MySQL |
| Xem TKB | `dashboard.php` | Inline PHP query | MySQL `schedules` |
| Nghe TTS | `chatbot.js` | `text_to_speech.php` proxy | Python FastAPI `:8000` |
| Tạo Ticket | `chatbot.js` | `create_ticket.php` | MySQL `tickets` |
| Admin xem chat | `admin_dashboard.php` | `get_student_chat.php` | MySQL `chat_history` |

---

### 5. Cấu trúc thư mục chi tiết

#### Gốc dự án

```
Do_An_UDPM/
│
├── .env                     # Biến môi trường (API key, DB) — KHÔNG commit lên git
├── .gitignore               # Bỏ qua .env, uploads/, tmp/
├── .htaccess                # Bảo mật Apache, chặn truy cập thẳng vào api/
├── config.php               # Đọc .env, cung cấp $apiKey, $db_host, $db_port, ...
└── README.md                # Tài liệu dự án (file này)
```

#### Thư mục `views/` — Giao diện người dùng

```
views/
├── login.php                # Trang đăng nhập dùng chung (sinh viên + admin)
│                            # → Kiểm tra role → redirect đúng dashboard
├── dashboard.php            # Dashboard sinh viên (~63KB)
│                            # → Chatbot UI, sidebar TKB/điểm/học phí
└── admin_dashboard.php      # Admin Dashboard (~101KB)
                             # → Tab: Tổng quan, FAQ, Sinh viên, Chat, Ticket
```

#### Thư mục `api/` — REST API Endpoints

```
api/
├── chatbot.php              # API lõi (~78KB): RAG + Gemini + lưu history
├── text_to_speech.php       # Proxy PHP → Python TTS :8000 → trả MP3
├── chat_feedback.php        # POST: lưu like/dislike cho tin nhắn bot
├── create_ticket.php        # POST: sinh viên tạo ticket hỗ trợ mới
├── delete_chat_history.php  # DELETE: xóa toàn bộ hội thoại của session
├── get_student_chat.php     # GET: admin xem lịch sử chat của sinh viên
├── get_ticket_chat.php      # GET: lấy nội dung trao đổi trong ticket
├── report_bot.php           # POST: báo cáo câu trả lời sai của bot
├── student_reply.php        # POST: sinh viên phản hồi vào ticket
├── upload_avatar.php        # POST: upload và lưu ảnh đại diện
└── uploads/                 # Thư mục lưu file upload từ API
```

#### Thư mục `core/` — Nghiệp vụ lõi

```
core/
├── faq_helpers.php          # RAG engine (~32KB)
│                            # searchFAQ(), fuzzyMatch(), buildContext(), buildPrompt()
└── new_logic.php            # Logic bổ sung (xử lý edge case)
```

#### Thư mục `css/` và `js/`

```
css/
├── login.css                # Style trang đăng nhập (~10KB)
├── dashboard.css            # Style dashboard sinh viên (~18KB)
└── admin.css                # Style admin dashboard (~14KB)

js/
├── chatbot.js               # Logic chatbot frontend (~40KB)
│                            # Gửi tin, render Markdown, TTS, stream response
└── admin.js                 # Helper cho admin dashboard (~1KB)
```

#### Thư mục `tts/` — Microservice TTS

```
tts/
├── server.py                # FastAPI app: POST /tts → gTTS → trả MP3
└── requirements.txt         # fastapi, uvicorn, gTTS
```

#### Thư mục `database/` — Quản lý CSDL

```
database/
├── do_an_udpm_database_complete.sql  # Schema đầy đủ toàn bộ bảng
├── do_an_udpm_demo_seed.sql          # Dữ liệu mẫu (sinh viên, admin, lịch học, điểm)
├── faq_knowledge_seed.sql            # Kho tri thức FAQ (~119KB, 100+ câu hỏi-đáp)
├── uth_db.sql                        # Backup DB phiên bản khác
├── add_column.php                    # Migration: thêm cột mới
├── add_new_tables.php                # Migration: thêm bảng mới
├── check_db.php                      # Kiểm tra kết nối DB
├── check_tables.php                  # Kiểm tra cấu trúc bảng
├── seed_faq_knowledge.php            # Chạy seed FAQ từ SQL
└── setup_data.php                    # Khởi tạo dữ liệu ban đầu
```

#### Quy ước đặt tên file

| Pattern | Ý nghĩa |
|---|---|
| `views/*.php` | Trang giao diện đầy đủ (render HTML) |
| `api/*.php` | Endpoint nhận AJAX, trả JSON |
| `core/*_helpers.php` | Hàm nghiệp vụ dùng chung |
| `*_seed.sql` | Dữ liệu khởi tạo / mẫu |
| `*_complete.sql` | Schema đầy đủ |

---

### 6. Mô hình dữ liệu và CSDL

#### 6.1 Tổng quan bảng (MySQL — `do_an_udpm`)

| Bảng | Mô tả | Trường quan trọng |
|---|---|---|
| `users` | Tài khoản người dùng | `id`, `username` (MSSV), `password`, `role` (admin/student), `avatar` |
| `student_info` | Thông tin chi tiết sinh viên | `user_id`, `full_name`, `class`, `faculty`, `email`, `phone` |
| `faq_knowledge` | Kho tri thức RAG | `id`, `question`, `answer`, `keywords`, `category`, `created_at` |
| `chat_history` | Lịch sử hội thoại | `id`, `user_id`, `session_id`, `role` (user/assistant), `content`, `created_at` |
| `chat_feedback` | Phản hồi chất lượng | `id`, `message_id`, `user_id`, `feedback` (like/dislike) |
| `tickets` | Yêu cầu hỗ trợ | `id`, `user_id`, `title`, `content`, `status` (open/closed), `created_at` |
| `ticket_messages` | Trao đổi trong ticket | `id`, `ticket_id`, `sender_id`, `message`, `created_at` |
| `schedules` | Thời khóa biểu | `id`, `user_id`, `subject`, `room`, `day_of_week`, `start_time`, `end_time` |
| `exam_schedule` | Lịch thi | `id`, `user_id`, `subject`, `exam_date`, `room`, `time` |
| `grades` | Kết quả học tập | `id`, `user_id`, `subject`, `midterm`, `final`, `gpa`, `semester` |
| `tuition_fees` | Học phí | `id`, `user_id`, `amount`, `due_date`, `status` (paid/unpaid) |
| `bot_reports` | Báo cáo lỗi bot | `id`, `user_id`, `message_id`, `reason`, `created_at` |

#### 6.2 Quan hệ giữa các bảng (ERD tóm tắt)

```
users (1) ─────────────── (N) student_info
users (1) ─────────────── (N) chat_history
users (1) ─────────────── (N) chat_feedback
users (1) ─────────────── (N) tickets
users (1) ─────────────── (N) schedules
users (1) ─────────────── (N) exam_schedule
users (1) ─────────────── (N) grades
users (1) ─────────────── (N) tuition_fees
users (1) ─────────────── (N) bot_reports
tickets (1) ──────────── (N) ticket_messages
```

#### 6.3 Cấu trúc kho tri thức FAQ (`faq_knowledge`)

```sql
faq_knowledge
├── id           INT AUTO_INCREMENT
├── question     TEXT          -- Câu hỏi (dùng để fuzzy match)
├── answer       TEXT          -- Câu trả lời chuẩn
├── keywords     VARCHAR(500)  -- Từ khóa phân tách bằng dấu phẩy
├── category     VARCHAR(100)  -- Nhóm: "học phí", "lịch học", "quy chế"...
└── created_at   TIMESTAMP
```

Ví dụ bản ghi:
```
question: "Học phí học kỳ này đóng đến khi nào?"
answer:   "Học phí học kỳ 1 năm 2025-2026 có hạn chót ngày 15/09/2025..."
keywords: "học phí,hạn chót,đóng tiền,deadline"
category: "học phí"
```

---

### 7. Các thuật toán

#### 7.1 Thuật toán RAG — Tìm kiếm FAQ (core/faq_helpers.php)

**Mục đích:** Tìm câu trả lời trong kho nội bộ trước khi gọi Gemini, đảm bảo độ chính xác với nội dung UTH.

**Quy trình tìm kiếm:**

```
Input: $userQuestion = "học phí khi nào đóng?"
│
├── Bước 1: Tách từ khóa
│   extractKeywords("học phí khi nào đóng") → ["học phí", "đóng"]
│
├── Bước 2: Keyword Match (SQL LIKE)
│   SELECT * FROM faq_knowledge
│   WHERE keywords LIKE '%học phí%'
│   OR keywords LIKE '%đóng%'
│   → Tìm được 3 FAQ ứng viên
│
├── Bước 3: Fuzzy Match (PHP similar_text)
│   similar_text($userQuestion, $faq->question, $percent)
│   FAQ_1: "Học phí đóng khi nào?" → 78% ✓
│   FAQ_2: "Khi nào đóng bảo hiểm?" → 45% ✗ (< threshold 50%)
│   FAQ_3: "Mức học phí bao nhiêu?" → 52% ✓
│
├── Bước 4: Lọc & xếp hạng
│   Giữ FAQ có score > 50%, sắp xếp giảm dần
│
└── Bước 5: Trả về context
    [FAQ_1, FAQ_3] → buildContext() → chuỗi text cho prompt
```

**Ví dụ output context:**
```
[Thông tin từ cơ sở dữ liệu trường]:
Q: Học phí đóng khi nào?
A: Học phí học kỳ 1 hạn đóng ngày 15/09/2025...

Q: Mức học phí bao nhiêu?
A: Học phí sinh viên đại học UTH là 15,000,000 VNĐ/học kỳ...
```

#### 7.2 Xây dựng Prompt cho Gemini

**Cấu trúc prompt:**

```
[System Prompt]
Bạn là trợ lý ảo của Đại học Giao thông Vận tải TP.HCM (UTH),
tên MinLish. Hãy trả lời câu hỏi của sinh viên dựa trên thông tin
được cung cấp. Trả lời bằng tiếng Việt, ngắn gọn và chính xác.

[Context từ FAQ — nếu tìm thấy]
[Thông tin cá nhân sinh viên — nếu liên quan]
- Họ tên: Nguyễn Văn A
- Lớp: CNTT01
- TKB: ...

[Lịch sử hội thoại — 10 tin gần nhất]
User: câu hỏi trước
Assistant: trả lời trước
...

[Câu hỏi hiện tại]
User: học phí khi nào đóng?
```

**Quyết định đưa thông tin cá nhân vào prompt:**

```
if (câu hỏi liên quan "lịch học", "TKB", "thời khóa biểu"):
    → thêm $scheduleInfo vào prompt

if (câu hỏi liên quan "điểm", "kết quả"):
    → thêm $gradesInfo vào prompt

if (câu hỏi liên quan "học phí", "đóng tiền"):
    → thêm $tuitionInfo vào prompt
```

#### 7.3 TTS — Text to Speech Pipeline

**File:** `tts/server.py` + `api/text_to_speech.php`

```
Sinh viên bấm nút loa trên câu trả lời
    │
    ▼ JavaScript gọi
api/text_to_speech.php
    │ cURL POST {"text": "câu trả lời..."}
    ▼
tts/server.py (FastAPI :8000)
    │
    ├── Nhận text
    ├── gTTS(text, lang='vi')     # Text-to-Speech tiếng Việt
    ├── Xuất MP3 vào BytesIO
    └── Trả về audio/mpeg response
    │
    ▼ PHP nhận binary audio
api/text_to_speech.php
    │ Trả header('Content-Type: audio/mpeg')
    ▼
Browser phát âm thanh
```

#### 7.4 Phân quyền và điều hướng sau đăng nhập

**Bảng quyết định:**

| `$_SESSION['role']` | Màn hình đích |
|---|---|
| `'admin'` | `views/admin_dashboard.php` |
| `'student'` | `views/dashboard.php` |
| Không có session | `views/login.php` |

**Ví dụ kịch bản:**
- Admin đăng nhập `admin / admin123` → role = 'admin' → Admin Dashboard.
- Sinh viên đăng nhập `075205019210 / sv123` → role = 'student' → Dashboard sinh viên.
- Truy cập trực tiếp `/views/admin_dashboard.php` không có session → redirect Login.

---

## Phần 3 — Sản phẩm

### 3.1 Tổng quan sản phẩm

**UTH Chatbot Portal** là hệ thống web hỗ trợ sinh viên Đại học Giao thông Vận tải TP.HCM theo hướng tự động hóa và cá nhân hóa:

- Sinh viên đặt câu hỏi bằng ngôn ngữ tự nhiên — Bot tìm trong kho FAQ nội bộ trước, sau đó dùng AI sinh câu trả lời phù hợp ngữ cảnh UTH.
- Thông tin học vụ (TKB, điểm, học phí) hiển thị ngay trong Dashboard theo MSSV.
- Câu trả lời có thể phát thành âm thanh tiếng Việt; sinh viên đánh giá chất lượng hoặc báo lỗi.
- Khi vấn đề phức tạp: tạo Ticket → Admin nhận và phản hồi trực tiếp.

| Thông tin sản phẩm | Chi tiết |
|---|---|
| Nền tảng | Web (truy cập qua trình duyệt) |
| Web Server | Apache (XAMPP/MAMP) |
| Yêu cầu | Internet (để gọi Gemini API), Python `:8000` (TTS tùy chọn) |
| Tài khoản mặc định | Admin: `admin / admin123` · Sinh viên: `075205019210 / sv123` |
| Ngôn ngữ | Tiếng Việt |

---

### 3.2 Hướng dẫn cài đặt và sử dụng

#### Bước 1 — Chuẩn bị mã nguồn

```bash
# Clone về thư mục htdocs (XAMPP Windows) hoặc htdocs (MAMP Mac)
git clone <repository-url> Do_An_UDPM

# XAMPP: C:\xampp\htdocs\Do_An_UDPM\
# MAMP:  /Applications/MAMP/htdocs/Do_An_UDPM/
```

#### Bước 2 — Thiết lập CSDL

1. Khởi động MySQL từ XAMPP / MAMP Control Panel.
2. Mở phpMyAdmin → tạo database `do_an_udpm`.
3. Import theo thứ tự:

```
database/do_an_udpm_database_complete.sql   ← Schema (bắt buộc trước)
database/do_an_udpm_demo_seed.sql           ← Dữ liệu mẫu
database/faq_knowledge_seed.sql             ← Kho tri thức FAQ
```

#### Bước 3 — Cấu hình môi trường

Tạo file `.env` tại thư mục gốc:

```env
GEMINI_API_KEY=your_google_gemini_api_key

DB_HOST=127.0.0.1
DB_PORT=8889          # MAMP Mac: 8889  |  XAMPP Windows: 3306
DB_NAME=do_an_udpm
DB_USER=root
DB_PASS=root
```

> Lấy Gemini API Key tại: https://aistudio.google.com/

#### Bước 4 — Khởi động TTS Service (tùy chọn)

```bash
cd tts
pip install -r requirements.txt
uvicorn server:app --host 0.0.0.0 --port 8000
```

#### Bước 5 — Truy cập hệ thống

```
http://localhost/Do_An_UDPM/views/login.php
```

| Loại tài khoản | Tên đăng nhập | Mật khẩu |
|---|---|---|
| Admin | `admin` | `admin123` |
| Sinh viên | `075205019210` | `sv123` |

---

### 3.3 Mô tả chi tiết từng chức năng

#### Đăng nhập

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Xác thực người dùng, phân quyền vào đúng dashboard |
| Cách dùng | Nhập tên đăng nhập + mật khẩu → Đăng nhập |
| Hành vi | Kiểm tra DB → tạo `$_SESSION` → redirect theo role |
| Mã nguồn | `views/login.php` |

#### Chatbot AI

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Trả lời câu hỏi học vụ bằng tiếng Việt tự nhiên |
| Cách dùng | Nhập câu hỏi → Enter hoặc nút Gửi → Đọc câu trả lời |
| Hành vi | RAG tìm FAQ → build prompt → Gemini sinh trả lời → lưu lịch sử → render Markdown |
| Tính năng phụ | TTS (nút loa), Like/Dislike, Báo lỗi, Xóa lịch sử |
| Mã nguồn | `api/chatbot.php`, `js/chatbot.js`, `core/faq_helpers.php` |

#### Tra cứu học vụ (Sidebar Dashboard)

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Xem thông tin cá nhân, TKB, điểm, học phí theo MSSV |
| Cách dùng | Chọn tab tương ứng trong sidebar bên phải Dashboard |
| Hành vi | PHP query DB theo `$_SESSION['user_id']` → render bảng |
| Mã nguồn | `views/dashboard.php` |

#### Ticket hỗ trợ

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Gửi yêu cầu hỗ trợ khi chatbot không giải quyết được |
| Cách dùng | Bấm "Tạo Ticket" → điền tiêu đề + mô tả → Gửi |
| Hành vi | Tạo bản ghi `tickets` → Admin thấy trong dashboard → phản hồi qua `ticket_messages` |
| Mã nguồn | `api/create_ticket.php`, `api/student_reply.php` |

#### Admin — Quản lý FAQ

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Cập nhật kho tri thức để cải thiện chất lượng chatbot |
| Cách dùng | Tab "Quản lý FAQ" → Thêm / Sửa / Xóa câu hỏi-đáp |
| Hành vi | CRUD bảng `faq_knowledge`; thay đổi có hiệu lực ngay lần hỏi tiếp theo |
| Mã nguồn | `views/admin_dashboard.php` |

#### Admin — Xử lý Ticket

| Hạng mục | Nội dung |
|---|---|
| Mục đích | Hỗ trợ trực tiếp sinh viên có vấn đề phức tạp |
| Cách dùng | Tab "Tickets" → Chọn ticket → Xem nội dung → Phản hồi / Đóng |
| Hành vi | Ghi vào `ticket_messages` → sinh viên thấy phản hồi trong Dashboard |
| Mã nguồn | `views/admin_dashboard.php`, `api/get_ticket_chat.php` |

---

## Phần 4 — Tổng kết

### 4.1 Tự đánh giá sản phẩm

| Tiêu chí | Đánh giá | Ghi chú |
|---|---|---|
| Chatbot AI hoạt động | Đạt | RAG + Gemini trả lời đúng chủ đề UTH |
| Cá nhân hóa học vụ | Đạt | TKB, điểm, học phí hiển thị đúng MSSV |
| TTS tiếng Việt | Đạt | Python gTTS phát âm thanh rõ ràng |
| Admin Dashboard | Đạt | CRUD FAQ, xem chat, xử lý Ticket đầy đủ |
| Giao diện | Đạt | Material-inspired, responsive, có animation |
| Offline | Không áp dụng | Web app yêu cầu internet cho Gemini API |
| Bảo mật | Cơ bản | Session PHP, chặn direct access API qua .htaccess |

---

### 4.2 So sánh với mục tiêu ban đầu

| Mục tiêu đặt ra | Kết quả |
|---|---|
| Chatbot tự động giải đáp học vụ | **Hoàn thành** — RAG + Gemini hoạt động tốt |
| Cá nhân hóa theo MSSV | **Hoàn thành** — TKB, điểm, học phí |
| TTS tiếng Việt | **Hoàn thành** — microservice Python |
| Admin quản lý FAQ | **Hoàn thành** — CRUD đầy đủ |
| Ticket hỗ trợ | **Hoàn thành** — 2 chiều Sinh viên ↔ Admin |
| Thống kê hệ thống | **Hoàn thành** — Dashboard thống kê Admin |

---

### 4.3 Hạn chế và rủi ro hiện tại

- **Phụ thuộc Gemini API:** Nếu hết quota hoặc mất mạng → Chatbot không hoạt động.
- **TTS không tự khởi động:** Python service phải chạy thủ công song song với Apache.
- **Phân quyền đơn giản:** Chỉ có 2 role (admin/student), chưa có phân quyền chi tiết theo khoa/bộ môn.
- **RAG chưa có embedding vector:** Tìm kiếm dựa trên keyword + fuzzy match — có thể bỏ sót FAQ ngữ nghĩa tương đồng nhưng từ ngữ khác nhau.
- **Chưa có cơ chế học tập tự động:** Bot báo lỗi được ghi nhận nhưng không tự cập nhật FAQ.
- **Chưa có kiểm thử tự động:** Không có unit test / integration test.

---

### 4.4 Hướng phát triển

| Hướng | Mô tả |
|---|---|
| **Vector Search RAG** | Thay keyword matching bằng embedding (ChromaDB, Pinecone) → tìm kiếm ngữ nghĩa chính xác hơn |
| **Auto-learning FAQ** | Tự động đề xuất FAQ mới từ bot_reports và chat_history |
| **Multi-modal** | Hỗ trợ sinh viên gửi ảnh (chụp thời khóa biểu, hóa đơn học phí) |
| **Tích hợp LMS** | Kết nối trực tiếp hệ thống quản lý đào tạo thực tế của UTH (thay dữ liệu seed) |
| **Mobile App** | Phát triển app Android/iOS cho trải nghiệm tốt hơn trên điện thoại |
| **OAuth / SSO** | Đăng nhập qua tài khoản Google Workspace của trường |
| **Push Notification** | Nhắc học phí sắp đến hạn, lịch thi sắp tới |
| **Đa ngôn ngữ** | Hỗ trợ tiếng Anh cho sinh viên quốc tế |

---

## Thông tin đồ án

| Thông tin | Chi tiết |
|---|---|
| Môn học | Ứng Dụng Phân Mềm (UDPM) |
| Trường | Đại học Giao thông Vận tải TP.HCM (UTH) |
| Tên dự án | UTH Chatbot Portal |
| Nền tảng | Web — PHP + MySQL + Python |
| AI Engine | Google Gemini API + RAG tự xây dựng |
| TTS Service | Python FastAPI + gTTS |
| Database | MySQL (`do_an_udpm`) — 12+ bảng |
| File mã nguồn | ~20 file PHP/JS/CSS/Python chính |

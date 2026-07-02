<?php
session_start();
if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
    header("Location: login.php");
    exit();
}

$pdo = new PDO("mysql:host=localhost;dbname=uth_db;charset=utf8mb4", "root", "");

// LẤY THÔNG TIN CÁ NHÂN TỪ BẢNG USERS
$stmtUser = $pdo->prepare("SELECT * FROM users WHERE username = ?");
$stmtUser->execute([$_SESSION['username']]);
$studentInfo = $stmtUser->fetch(PDO::FETCH_ASSOC);

// Xử lý khi sinh viên bấm nút "Đã hiểu" -> Chuyển trạng thái thành 'read' (đã đọc) để ẩn thông báo
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'mark_read') {
    $stmtUpdate = $pdo->prepare("UPDATE tickets SET status = 'read' WHERE id = ?");
    $stmtUpdate->execute([$_POST['ticket_id']]);
    header("Location: dashboard.php"); // Load lại trang
    exit;
}

// Tìm các Ticket của MSSV này đã được Admin trả lời ('replied') nhưng chưa đọc
$mssv = $_SESSION['mssv'] ?? '';
$stmtNotice = $pdo->prepare("SELECT * FROM tickets WHERE mssv = ? AND status = 'replied' ORDER BY created_at DESC");
$stmtNotice->execute([$mssv]);
$notifications = $stmtNotice->fetchAll(PDO::FETCH_ASSOC);
$notiCount = count($notifications);
if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
    header("Location: login.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>UTH Portal - Dashboard Sinh Viên</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <header>
    <div class="brand">UTH PORTAL</div>
    
    <div class="user-dropdown">
        <div class="user-trigger" onclick="toggleUserMenu()">
            <img src="images/logo.png" alt="Avatar" class="header-avatar">
            <span class="user-name"><?php echo htmlspecialchars($_SESSION['ho_ten'] ?? 'Sinh viên'); ?></span>
            <span class="chevron">▼</span>
        </div>
        
        <div class="dropdown-menu" id="userMenu">
            
            <a href="#" class="dropdown-item"> Thông tin cá nhân</a>
            <a href="#" class="dropdown-item"> Đổi mật khẩu</a>
            
            <div style="padding: 10px 15px; font-weight: bold; border-top: 1px solid #2c3138; border-bottom: 1px solid #2c3138; color: var(--accent-teal);">
                  Thông báo mới (<?php echo $notiCount; ?>)
            </div>
            
            <?php foreach($notifications as $noti): ?>
                <a href="#" class="dropdown-item" style="background: rgba(0, 188, 212, 0.05); border-left: 3px solid var(--accent-teal);" 
                   onclick="openStudentChat(<?php echo $noti['id']; ?>, '<?php echo htmlspecialchars($noti['title'], ENT_QUOTES); ?>', '<?php echo htmlspecialchars($noti['content'], ENT_QUOTES); ?>'); toggleUserMenu();">
                      Cập nhật Ticket #<?php echo $noti['id']; ?>
                </a>
            <?php endforeach; ?>
            
            <?php if($notiCount == 0): ?>
                <div style="padding: 10px 15px; text-align: center; color: gray; font-size: 13px;">Không có thông báo mới.</div>
            <?php endif; ?>
            
            <div class="divider"></div>
            <a href="login.php" class="dropdown-item" style="color: #ff4d4d;"> Đăng xuất</a>
        </div>
    </div>
</header>

    <div class="container">
        <div class="main-grid">
            
            <div class="left-col">
                <div class="card">
                    <div class="card-header-title">
                        Thông tin sinh viên 
                        <span style="font-size:12px; color:var(--text-muted)">THẺ SINH VIÊN</span>
                    </div>
                    <div class="student-flex">
                        <img src="images/logo.png" alt="Avatar">
                        <div class="info-grid">
                            <div class="info-field"><span class="label">MSSV:</span> <span class="val"><?php echo $_SESSION['mssv']; ?></span></div>
                            <div class="info-field"><span class="label">Khóa học:</span> <span class="val">2023</span></div>
                            <div class="info-field"><span class="label">Họ tên:</span> <span class="val"><?php echo htmlspecialchars($_SESSION['ho_ten'] ?? 'Sinh viên'); ?></span></div>
                            <div class="info-field"><span class="label">Giới tính:</span> <span class="val">Nam</span></div>
                            <div class="info-field"><span class="label">Ngày sinh:</span> <span class="val">10/12/2005</span></div>
                            <div class="info-field"><span class="label">Bậc đào tạo:</span> <span class="val">Đại học - chính quy</span></div>
                            <div class="info-field"><span class="label">Nơi sinh:</span> <span class="val">TP. Đồng Nai</span></div>
                            <div class="info-field"><span class="label">Loại hình đào tạo:</span> <span class="val">Chất lượng cao</span></div>
                            <div class="info-field"><span class="label">Ngành:</span> <span class="val">Công nghệ thông tin</span></div>
                            <div class="info-field"><span class="label">Chuyên ngành:</span> <span class="val">Công nghệ thông tin</span></div>
                        </div>
                    </div>
                </div>

                <div class="split-cards">
                    <div class="card notice-card">
                        <div style="font-size: 14px; font-weight: bold; margin-bottom: 5px;">Thông báo/ sự kiện</div>
                        <div class="amount">1</div> 
                        <span class="status">Đang có sự kiện mới chờ đăng...</span>
                        <div style="color: #ff4d4d; font-size: 12px; font-weight: bold; margin-top: 10px; cursor: pointer;">Xem chi tiết</div>
                    </div>
                    <div class="card schedule-card">
                        <div class="card-header-title" style="margin:0; font-size: 14px;">Lịch học trong tuần</div>
                        <div class="amount">6</div>
                        <div style="font-size: 12px; font-weight: bold; margin-top: 20px; cursor: pointer;">Xem chi tiết</div>
                    </div>
                </div>
            </div>

            <div class="right-col">
                <div class="card calendar-card">
                    <div class="card-header-title">
                        Lịch theo tháng
                        <div class="cal-nav">
                            <span class="cal-btn" onclick="prevMonth()">&lt;</span> 
                            <span id="monthYear">tháng 6 2026</span> 
                            <span class="cal-btn" onclick="nextMonth()">&gt;</span>
                        </div>
                    </div>
                    <div class="cal-grid" id="calGrid">
                        </div>
                </div>
            </div>

        </div> <div class="action-grid">
            <div class="action-box">Đào tạo trực tuyến</div>
            <div class="action-box">Hỗ trợ trực tuyến</div>
            <div class="action-box">Cổng thanh toán<br>trực tuyến</div>
            <div class="action-box">Dịch vụ sinh viên</div>
            <div class="action-box">Chương trình<br>khung</div>
            <div class="action-box">Đăng ký học<br>phần</div>
            <div class="action-box">Đăng ký môn<br>học điều kiện</div>
            <div class="action-box">Tra cứu công nợ</div>
        </div>

        <div class="bottom-section">
            <div class="card">
                <div class="card-header-title">Kết quả học tập</div>
                <div style="font-size:12px; color:var(--text-muted); text-align:center; padding-top:40px;">Không có dữ liệu cho học kỳ này!</div>
            </div>
            <div class="card">
                <div class="card-header-title" style="justify-content: center;">Tiến độ học tập</div>
                <div class="progress-circle-container">
                    <div class="circle-bar">
                        <div class="circle-inner">Đã đạt: 90/120</div>
                    </div>
                </div>
            </div>
            <div class="card">
                <div class="card-header-title">Lớp học phần</div>
                <ul class="subject-list">
                    <li><span>Trí tuệ nhân tạo và ứng dụng</span> <span style="color: white; font-weight: bold;">3 Tín chỉ</span></li>
                    <li><span>Lập trình mạng</span> <span style="color: white; font-weight: bold;">3 Tín chỉ</span></li>
                </ul>
            </div>
        </div>
    </div>

    <div class="bot-widget">
        <button class="bot-launcher" onclick="toggleChatWindow()">💬</button>
        <div class="bot-window" id="botWindow">
            <div class="bot-header">
                <span>UTH Chatbot</span>
                <span style="cursor:pointer" onclick="toggleChatWindow()">X</span>
            </div>
            <div class="bot-body" id="chatBody">
                <div class="chat-msg bot">Xin chào! Mình là Chatbot hỗ trợ học tập UTH. Bạn cần giúp gì?</div>
                
                <div class="chat-suggestions" id="chatSuggestions">
                    <span class="suggestion-chip" onclick="sendQuickMessage('Học phí năm nay bao nhiêu?')"> Học phí năm nay</span>
                    <span class="suggestion-chip" onclick="sendQuickMessage('Cách đăng ký môn học?')"> Đăng ký môn học</span>
                    <span class="suggestion-chip" onclick="sendQuickMessage('Xem lịch học ở đâu?')"> Xem lịch học</span>
                    <span class="suggestion-chip" onclick="sendQuickMessage('Làm sao để cải thiện điểm?')"> Cải thiện điểm</span>
                </div>

            </div>
            <div class="bot-footer">
                <input type="text" id="userInput" placeholder="Nhập câu hỏi..." onkeypress="if(event.key === 'Enter') sendMessage()">
                <button onclick="sendMessage()">Gửi</button>
            </div>
        </div>
    </div>

    <script src="js/chatbot.js"></script>
    <script>
        
        let currentDate = new Date();
        
        function renderCalendar(date) {
            const calGrid = document.getElementById("calGrid");
            const monthYear = document.getElementById("monthYear");
            
            let year = date.getFullYear();
            let month = date.getMonth();
            
           
            monthYear.innerText = `tháng ${month + 1} ${year}`;
            
            
            calGrid.innerHTML = `
                <div class="cal-day sun">CN</div><div class="cal-day">T2</div><div class="cal-day">T3</div>
                <div class="cal-day">T4</div><div class="cal-day">T5</div><div class="cal-day">T6</div><div class="cal-day">T7</div>
            `;
            
            let firstDayIndex = new Date(year, month, 1).getDay(); // Ngày đầu tháng là thứ mấy (0-6)
            let lastDay = new Date(year, month + 1, 0).getDate(); // Số ngày trong tháng
            
            let today = new Date();
            
           
            for(let i = 0; i < firstDayIndex; i++) {
                calGrid.innerHTML += `<div class="cal-num empty"></div>`;
            }
            
           
            for(let i = 1; i <= lastDay; i++) {
                let isToday = (i === today.getDate() && month === today.getMonth() && year === today.getFullYear());
                let isSun = new Date(year, month, i).getDay() === 0;
                
                let className = "cal-num";
                if(isToday) className += " active";
                if(isSun) className += " sun-num";
                
                calGrid.innerHTML += `<div class="${className}">${i}</div>`;
            }
        }

        function prevMonth() {
            currentDate.setMonth(currentDate.getMonth() - 1);
            renderCalendar(currentDate);
        }

        function nextMonth() {
            currentDate.setMonth(currentDate.getMonth() + 1);
            renderCalendar(currentDate);
        }

        
        renderCalendar(currentDate);

        // ==== HIỆU ỨNG MENU USER DROPDOWN ====
        function toggleUserMenu() {
            document.getElementById("userMenu").classList.toggle("show");
        }

        
        window.onclick = function(event) {
            if (!event.target.closest('.user-dropdown')) {
                var dropdowns = document.getElementsByClassName("dropdown-menu");
                for (var i = 0; i < dropdowns.length; i++) {
                    var openDropdown = dropdowns[i];
                    if (openDropdown.classList.contains('show')) {
                        openDropdown.classList.remove('show');
                    }
                }
            }
        }
// Biến toàn cục để giữ lại câu hỏi gốc của SV
let current_original_content = ''; 

function openStudentChat(ticket_id, title, original_content) {
    document.getElementById('chat_ticket_id').value = ticket_id;
    document.getElementById('chatTitle').innerText = title;
    document.getElementById('studentChatModal').classList.add('active');
    current_original_content = original_content; 
    loadChat(ticket_id);
}

function loadChat(id) {
    let box = document.getElementById('studentChatHistory');
    box.innerHTML = '<div style="text-align: center; color: gray;">Đang tải...</div>';
    
    fetch('api_get_student_chat.php?id=' + id)
    .then(res => res.json())
    .then(data => {
        box.innerHTML = '';
        
        // In câu hỏi ban đầu của Sinh viên
        box.innerHTML += `<div class="msg-bubble msg-student">
                            <div style="font-size: 11px; opacity: 0.7; margin-bottom: 3px; color: #00bcd4;">📌 Câu hỏi của bạn</div>
                            <div>${current_original_content}</div>
                          </div>`;
        
        // In lịch sử Admin - SV nhắn qua lại
        data.messages.forEach(msg => {
            let role = msg.sender_role === 'admin' ? 'msg-admin' : 'msg-student';
            let sender = msg.sender_role === 'admin' ? 'Admin UTH' : 'Bạn';
            box.innerHTML += `<div class="msg-bubble ${role}">
                                <div style="font-size: 11px; opacity: 0.7; margin-bottom: 3px;"><b>${sender}</b></div>
                                <div>${msg.message}</div>
                                <div style="font-size: 10px; opacity: 0.5; margin-top: 5px; text-align: right;">${msg.time_str}</div>
                              </div>`;
        });
        box.scrollTop = box.scrollHeight;
        
        // Kiểm tra đóng Ticket
        if(data.is_closed == 1) {
            document.getElementById('chatInput').disabled = true;
            document.getElementById('chatInput').placeholder = "🔒 Ticket này đã bị đóng bởi Admin.";
            document.getElementById('btnSend').style.display = 'none';
        } else {
            document.getElementById('chatInput').disabled = false;
            document.getElementById('chatInput').placeholder = "Nhập tin nhắn trả lời...";
            document.getElementById('btnSend').style.display = 'inline-block';
        }
    });
}

// Xử lý gửi tin nhắn (Bạn nhớ tạo thêm 1 file api_student_reply.php để INSERT tin nhắn vào DB nhé)
document.getElementById('studentReplyForm').onsubmit = function(e) {
    e.preventDefault();
    let formData = new FormData(this);
    fetch('api_student_reply.php', { method: 'POST', body: formData })
    .then(() => {
        document.getElementById('chatInput').value = '';
        loadChat(document.getElementById('chat_ticket_id').value);
    });
};
    </script>
    <style>
    .stu-modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); z-index: 9999; justify-content: center; align-items: center; }
    .stu-modal-overlay.active { display: flex; }
    .stu-modal-box { background: #1e2227; width: 500px; padding: 25px; border-radius: 8px; border: 1px solid #00bcd4; box-shadow: 0 0 20px rgba(0, 188, 212, 0.2); }
    .stu-modal-title { color: #00bcd4; margin-bottom: 15px; font-size: 18px; font-weight: bold; }
    .stu-reply-content { background: #121416; padding: 15px; border-radius: 4px; color: #e0e0e0; min-height: 80px; margin-bottom: 20px; font-size: 15px; line-height: 1.5; border-left: 4px solid #5cb85c;}
    .btn-read { background: #00bcd4; color: black; border: none; padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer; float: right; }
    .btn-read:hover { background: #0097a7; }
</style>

<div class="stu-modal-overlay" id="studentNotiModal">
    <div class="stu-modal-box">
        <div class="stu-modal-title" id="notiTitle">Phản hồi từ Admin</div>
        <div style="font-size: 13px; color: gray; margin-bottom: 5px;">Nội dung phản hồi:</div>
        <div class="stu-reply-content" id="notiContent">...</div>
        
        <form method="POST" action="dashboard.php">
            <input type="hidden" name="action" value="mark_read">
            <input type="hidden" name="ticket_id" id="notiTicketId">
            <button type="submit" class="btn-read">✔ Đã hiểu và Ẩn thông báo</button>
        </form>
        <div style="clear: both;"></div>
    </div>
</div>

<script>
    // Hàm mở Popup thông báo
    function openStudentModal(id, title, content) {
        document.getElementById('notiTicketId').value = id;
        document.getElementById('notiTitle').innerText = title;
        document.getElementById('notiContent').innerText = content;
        document.getElementById('studentNotiModal').classList.add('active');
    }
</script>
<style>
    .profile-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 20px; }
    .info-item { background: #121416; padding: 12px; border-radius: 4px; border: 1px solid #2c3138; }
    .info-label { color: var(--text-muted); font-size: 12px; margin-bottom: 5px; }
    .info-value { color: white; font-weight: bold; font-size: 14px; }
    .stu-chat-box { height: 300px; overflow-y: auto; background: #121416; padding: 15px; display: flex; flex-direction: column; gap: 10px; }
    .msg-bubble { max-width: 80%; padding: 10px 15px; border-radius: 8px; font-size: 14px; }
    .msg-admin { background: #2c3138; align-self: flex-start; }
    .msg-student { background: rgba(0, 188, 212, 0.2); border: 1px solid var(--accent-teal); align-self: flex-end; }
</style>

<div class="stu-modal-overlay" id="profileModal">
    <div class="stu-modal-box" style="width: 700px;">
        <div class="stu-modal-title">Hồ sơ Sinh viên</div>
        
        <div class="profile-grid">
            <div class="info-item"><div class="info-label">MSSV</div><div class="info-value"><?php echo $studentInfo['username']; ?></div></div>
            <div class="info-item"><div class="info-label">Họ và tên</div><div class="info-value"><?php echo $studentInfo['ho_ten']; ?></div></div>
            <div class="info-item"><div class="info-label">Ngày sinh</div><div class="info-value"><?php echo date('d/m/Y', strtotime($studentInfo['ngay_sinh'])); ?></div></div>
            <div class="info-item"><div class="info-label">Nơi sinh</div><div class="info-value"><?php echo $studentInfo['noi_sinh']; ?></div></div>
            <div class="info-item"><div class="info-label">Giới tính</div><div class="info-value"><?php echo $studentInfo['gioi_tinh']; ?></div></div>
            <div class="info-item"><div class="info-label">Khóa học</div><div class="info-value"><?php echo $studentInfo['khoa_hoc']; ?></div></div>
            <div class="info-item"><div class="info-label">Bậc đào tạo</div><div class="info-value"><?php echo $studentInfo['bac_dao_tao']; ?></div></div>
            <div class="info-item"><div class="info-label">Loại hình đào tạo</div><div class="info-value"><?php echo $studentInfo['loai_hinh_dao_tao']; ?></div></div>
            <div class="info-item" style="grid-column: span 2;"><div class="info-label">Ngành học</div><div class="info-value"><?php echo $studentInfo['nganh']; ?></div></div>
            <div class="info-item" style="grid-column: span 2;"><div class="info-label">Chuyên ngành</div><div class="info-value"><?php echo $studentInfo['chuyen_nganh']; ?></div></div>
        </div>

        <button class="btn-read" style="margin-top: 20px;" onclick="document.getElementById('profileModal').classList.remove('active')">Đóng</button>
        <div style="clear: both;"></div>
    </div>
</div>
<div class="stu-modal-overlay" id="studentChatModal">
    <div class="stu-modal-box" style="width: 600px;">
        <div class="stu-modal-title" id="chatTitle">Chi tiết Ticket</div>
        
        <div class="stu-chat-box" id="studentChatHistory">
            </div>

        <form id="studentReplyForm" style="margin-top: 15px;">
            <input type="hidden" name="ticket_id" id="chat_ticket_id">
            <textarea name="message" id="chatInput" class="faq-input" placeholder="Nhập tin nhắn trả lời..." style="width: 100%; height: 80px; margin-bottom: 10px;" required></textarea>
            <button type="submit" class="btn-read" id="btnSend">Gửi phản hồi</button>
            <button type="button" class="btn-read" style="background:#444; margin-right:10px;" onclick="document.getElementById('studentChatModal').classList.remove('active')">Đóng</button>
        </form>
    </div>
</div>

<script>
// Hàm mở khung chat
function openStudentChat(ticket_id, title) {
    document.getElementById('chat_ticket_id').value = ticket_id;
    document.getElementById('chatTitle').innerText = title;
    document.getElementById('studentChatModal').classList.add('active');
    loadChat(ticket_id);
}

// Hàm tải tin nhắn từ server
function loadChat(id) {
    fetch('api_get_student_chat.php?id=' + id)
    .then(res => res.json())
    .then(data => {
        let box = document.getElementById('studentChatHistory');
        box.innerHTML = '';
        data.messages.forEach(msg => {
            let role = msg.sender_role === 'admin' ? 'msg-admin' : 'msg-student';
            box.innerHTML += `<div class="msg-bubble ${role}">${msg.message}</div>`;
        });
        box.scrollTop = box.scrollHeight;
        
        // Nếu admin đã đóng ticket thì khóa khung chat
        if(data.is_closed == 1) {
            document.getElementById('chatInput').disabled = true;
            document.getElementById('btnSend').style.display = 'none';
        }
    });
}

// Xử lý gửi tin nhắn
document.getElementById('studentReplyForm').onsubmit = function(e) {
    e.preventDefault();
    let formData = new FormData(this);
    fetch('api_student_reply.php', { method: 'POST', body: formData })
    .then(() => {
        document.getElementById('chatInput').value = '';
        loadChat(document.getElementById('chat_ticket_id').value);
    });
};
</script>
</body>
</html>
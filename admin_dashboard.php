<?php
session_start();
// Kết nối Database
$pdo = new PDO("mysql:host=localhost;dbname=uth_db;charset=utf8mb4", "root", "");

// XÁC ĐỊNH TAB ĐANG HOẠT ĐỘNG (Mặc định là dashboard nếu không có tham số)
$currentTab = $_GET['tab'] ?? 'dashboard';
// =========================================================================
// XỬ LÝ LỆNH TỪ GIAO DIỆN ADMIN (THÊM / SỬA / XÓA FAQ / REPLY TICKET)
// =========================================================================
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    $action = $_POST['action'];
    
    // 1. Thao tác với FAQ -> Xử lý xong giữ lại ở tab=faq
    if ($action === 'add_faq') {
        $stmt = $pdo->prepare("INSERT INTO faq (tu_khoa, noi_dung) VALUES (?, ?)");
        $stmt->execute([$_POST['tu_khoa'], $_POST['noi_dung']]);
        header("Location: admin_dashboard.php?tab=faq");
        exit;
    } 
    // Thêm vào khối if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']))
    // Xử lý Thêm Tài khoản Sinh viên (Đã bổ sung full thông tin)
    elseif ($action === 'add_user') {
        $stmt = $pdo->prepare("INSERT INTO users (username, password, ho_ten, ngay_sinh, noi_sinh, nganh, khoa_hoc, gioi_tinh, bac_dao_tao, loai_hinh_dao_tao, chuyen_nganh, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'student')");
        
        $stmt->execute([
            $_POST['mssv'],
            $_POST['password'],
            $_POST['ho_ten'],
            $_POST['ngay_sinh'],
            $_POST['noi_sinh'],
            $_POST['nganh'],
            $_POST['khoa_hoc'],
            $_POST['gioi_tinh'],
            $_POST['bac_dao_tao'],
            $_POST['loai_hinh_dao_tao'],
            $_POST['chuyen_nganh']
        ]);
        
        header("Location: admin_dashboard.php?tab=users");
        exit;
    }
    elseif ($action === 'edit_faq') {
        $stmt = $pdo->prepare("UPDATE faq SET tu_khoa = ?, noi_dung = ? WHERE id = ?");
        $stmt->execute([$_POST['tu_khoa'], $_POST['noi_dung'], $_POST['faq_id']]);
        header("Location: admin_dashboard.php?tab=faq");
        exit;
    } 
    elseif ($action === 'delete_faq') {
        $stmt = $pdo->prepare("DELETE FROM faq WHERE id = ?");
        $stmt->execute([$_POST['faq_id']]);
        header("Location: admin_dashboard.php?tab=faq");
        exit;
    }
    
    // 2. Thao tác Reply Ticket -> Xử lý xong giữ lại ở tab=tickets
    if ($action === 'reply_ticket') {
        $stmt = $pdo->prepare("UPDATE tickets SET admin_reply = ?, status = 'replied' WHERE id = ?");
        $stmt->execute([$_POST['reply_content'], $_POST['ticket_id']]);
        header("Location: admin_dashboard.php?tab=tickets");
        exit;
    }
}

// =========================================================================
// LẤY DỮ LIỆU TỪ DATABASE ĐỂ HIỂN THỊ RA WEB
// =========================================================================
$totalTickets = $pdo->query("SELECT COUNT(*) FROM tickets")->fetchColumn();
$pendingTickets = $pdo->query("SELECT COUNT(*) FROM tickets WHERE status = 'pending'")->fetchColumn();
$repliedTickets = $pdo->query("SELECT COUNT(*) FROM tickets WHERE status = 'replied'")->fetchColumn();
$totalFaq = $pdo->query("SELECT COUNT(*) FROM faq")->fetchColumn();

$recentTickets = $pdo->query("SELECT * FROM tickets ORDER BY created_at DESC LIMIT 10")->fetchAll(PDO::FETCH_ASSOC);
$faqs = $pdo->query("SELECT * FROM faq ORDER BY id DESC")->fetchAll(PDO::FETCH_ASSOC); 
$students = $pdo->query("SELECT * FROM users WHERE role = 'student' ORDER BY created_at DESC")->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UTH Admin Dashboard</title>
    <link rel="stylesheet" href="css/admin.css">
    <style>
        .faq-input { width: 100%; background: #121416; color: white; border: 1px solid #2c3138; padding: 12px; border-radius: 4px; margin: 8px 0 20px; outline: none; }
        .faq-input:focus { border-color: var(--accent-teal); }
        .action-form { display: inline-block; margin: 0; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="logo">UTH ADMIN</div>
        <div class="menu">
            <div class="menu-item <?php echo $currentTab === 'dashboard' ? 'active' : ''; ?>" onclick="switchTab('dashboard', this)">📊 Tổng quan</div>
            <div class="menu-item <?php echo $currentTab === 'tickets' ? 'active' : ''; ?>" onclick="switchTab('tickets', this)">🎫 Hỗ trợ Tickets</div>
            <div class="menu-item <?php echo $currentTab === 'faq' ? 'active' : ''; ?>" onclick="switchTab('faq', this)">📚 Quản lý Bot (FAQ)</div>
            <div class="menu-item <?php echo $currentTab === 'users' ? 'active' : ''; ?>" onclick="switchTab('users', this)">👥 Quản lý Sinh viên</div>
            <div class="menu-item <?php echo $currentTab === 'logs' ? 'active' : ''; ?>" onclick="switchTab('logs', this)">💬 Lịch sử Chat</div>
            <a href="login.php" class="menu-item" style="margin-top: auto; border-top: 1px solid #2c3138; color: var(--danger);">🚪 Đăng xuất</a>
        </div>
    </div>

    <div class="main-content">
        <div class="header">
            <div class="search-bar"><input type="text" placeholder="Tìm kiếm..."></div>
            <div class="admin-profile"><span>Admin UTH</span><div class="avatar">A</div></div>
        </div>

        <div id="tab-dashboard" class="tab-content <?php echo $currentTab === 'dashboard' ? 'active' : ''; ?>">
            <h2 class="page-title">Tổng quan hệ thống</h2>
            <div class="stats-grid">
                <div class="stat-card"><div class="stat-title">Tổng số Ticket</div><div class="stat-value"><?php echo $totalTickets; ?></div></div>
                <div class="stat-card danger"><div class="stat-title">Ticket chờ xử lý</div><div class="stat-value"><?php echo $pendingTickets; ?></div></div>
                <div class="stat-card success"><div class="stat-title">Ticket đã phản hồi</div><div class="stat-value"><?php echo $repliedTickets; ?></div></div>
                <div class="stat-card"><div class="stat-title">Dữ liệu đã Train</div><div class="stat-value"><?php echo $totalFaq; ?></div></div>
            </div>
            <div class="table-container">
                <h3 style="margin-bottom: 15px;">Ticket gần đây nhất</h3>
                <table>
                    <thead><tr><th>Mã</th><th>Sinh viên</th><th>Vấn đề</th><th>Trạng thái</th></tr></thead>
                    <tbody>
                        <?php foreach($recentTickets as $t): ?>
                        <tr>
                            <td>#<?php echo $t['id']; ?></td>
                            <td><?php echo htmlspecialchars($t['student_name']); ?></td>
                            <td><?php echo htmlspecialchars($t['title']); ?></td>
                            <td><span class="badge <?php echo $t['status']; ?>"><?php echo $t['status'] == 'pending' ? 'Chờ xử lý' : 'Đã trả lời'; ?></span></td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="tab-tickets" class="tab-content <?php echo $currentTab === 'tickets' ? 'active' : ''; ?>">
            <div class="page-title"><span>Quản lý Phiếu hỗ trợ (Tickets)</span></div>
            <div class="table-container">
                <table>
                    <thead><tr><th>Mã/Ngày</th><th>Sinh viên (MSSV)</th><th>Nội dung câu hỏi</th><th>Trạng thái</th><th>Hành động</th></tr></thead>
                    <tbody>
                        <?php foreach($recentTickets as $t): ?>
                        <tr>
                            <td><b>#<?php echo $t['id']; ?></b><br><span style="color:var(--text-muted); font-size:12px;"><?php echo date('d/m H:i', strtotime($t['created_at'])); ?></span></td>
                            <td><?php echo htmlspecialchars($t['student_name']); ?><br><span style="color:var(--text-muted); font-size:12px;"><?php echo htmlspecialchars($t['mssv']); ?></span></td>
                            <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"><?php echo htmlspecialchars($t['content']); ?></td>
                            <td><span class="badge <?php echo $t['status']; ?>"><?php echo $t['status'] == 'pending' ? 'Chờ xử lý' : 'Đã phản hồi'; ?></span></td>
                            <td>
                                <?php if($t['status'] == 'pending'): ?>
                                    <button class="btn" onclick="openReplyModal(<?php echo $t['id']; ?>, '<?php echo $t['student_name']; ?>', '<?php echo htmlspecialchars($t['content'], ENT_QUOTES); ?>')">Trả lời</button>
                                <?php else: ?>
                                    <button class="btn btn-outline" onclick="alert('Đã trả lời: <?php echo htmlspecialchars($t['admin_reply'], ENT_QUOTES); ?>')">Xem lại</button>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div id="tab-faq" class="tab-content <?php echo $currentTab === 'faq' ? 'active' : ''; ?>">
            <div class="page-title">
                <span>Kho dữ liệu huấn luyện Bot (FAQ)</span>
                <button class="btn" onclick="openFaqModal('add')">+ Thêm câu hỏi mới</button>
            </div>
            <div class="table-container">
                <table>
                    <thead><tr><th>STT</th><th>Từ khóa nhận diện</th><th>Nội dung tài liệu (AI đọc)</th><th>Thao tác</th></tr></thead>
                    <tbody>
                        <?php $stt = 1; foreach($faqs as $f): ?>
                        <tr>
                            <td><b>#<?php echo $stt++; ?></b></td>
                            <td style="color: var(--accent-teal);"><?php echo htmlspecialchars($f['tu_khoa']); ?></td>
                            <td style="max-width: 350px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                <?php echo htmlspecialchars($f['noi_dung']); ?>
                            </td>
                            <td>
                                <button class="btn btn-outline" onclick="openFaqModal('edit', <?php echo $f['id']; ?>, '<?php echo htmlspecialchars($f['tu_khoa'], ENT_QUOTES); ?>', '<?php echo htmlspecialchars($f['noi_dung'], ENT_QUOTES); ?>')">Sửa</button>
                                <form method="POST" class="action-form" onsubmit="return confirm('Bạn có chắc chắn muốn xóa?');">
                                    <input type="hidden" name="action" value="delete_faq">
                                    <input type="hidden" name="faq_id" value="<?php echo $f['id']; ?>">
                                    <button type="submit" class="btn-danger btn">Xóa</button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div id="tab-users" class="tab-content <?php echo $currentTab === 'users' ? 'active' : ''; ?>">
    <div class="page-title">
        <span>Danh sách Tài khoản Sinh viên</span>
        <button class="btn" onclick="document.getElementById('addUserModal').classList.add('active')">+ Cấp tài khoản mới</button>
    </div>
    <div class="table-container">
        <table>
            <thead><tr><th>MSSV (Tài khoản)</th><th>Họ và tên</th><th>Ngành / Khóa</th><th>Mật khẩu</th></tr></thead>
            <tbody>
                <?php foreach($students as $sv): ?>
                <tr>
                    <td><b><?php echo $sv['username']; ?></b></td>
                    <td><?php echo $sv['ho_ten']; ?></td>
                    <td><?php echo $sv['nganh']; ?> - <?php echo $sv['khoa_hoc']; ?></td>
                    <td style="color: var(--danger); font-family: monospace;"><?php echo $sv['password']; ?></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

        <div id="tab-logs" class="tab-content <?php echo $currentTab === 'logs' ? 'active' : ''; ?>">
            <div class="page-title"><span>Lịch sử trò chuyện Sinh viên - Bot</span></div>
            <p style="color: var(--text-muted); text-align: center; margin-top: 50px;">Tính năng đang được nâng cấp...</p>
        </div>
    </div>
    

<div class="modal-overlay" id="addUserModal">
    <div class="modal-box" style="width: 750px; max-height: 90vh; overflow-y: auto;">
        <div class="modal-header">
            <h3>Cấp tài khoản Sinh viên mới</h3>
            <span class="close-btn" onclick="closeModal('addUserModal')">✖</span>
        </div>
        <form method="POST" action="admin_dashboard.php">
            <input type="hidden" name="action" value="add_user">
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0 20px;">
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">MSSV (Dùng để đăng nhập) *</label>
                    <input type="text" name="mssv" class="faq-input" required>
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Mật khẩu *</label>
                    <input type="text" name="password" class="faq-input" value="123456" required>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Họ và tên *</label>
                    <input type="text" name="ho_ten" class="faq-input" required>
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngày sinh</label>
                    <input type="date" name="ngay_sinh" class="faq-input">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Giới tính</label>
                    <select name="gioi_tinh" class="faq-input" style="height: 44px;">
                        <option value="Nam">Nam</option>
                        <option value="Nữ">Nữ</option>
                    </select>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Nơi sinh</label>
                    <input type="text" name="noi_sinh" class="faq-input" placeholder="VD: TP. Hồ Chí Minh">
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Ngành học</label>
                    <input type="text" name="nganh" class="faq-input" placeholder="VD: Công nghệ thông tin">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Chuyên ngành</label>
                    <input type="text" name="chuyen_nganh" class="faq-input" placeholder="VD: Kỹ thuật phần mềm">
                </div>

                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Khóa học</label>
                    <input type="text" name="khoa_hoc" class="faq-input" placeholder="VD: Khóa 2021">
                </div>
                <div>
                    <label style="color:var(--text-muted); font-size:14px;">Bậc đào tạo</label>
                    <select name="bac_dao_tao" class="faq-input" style="height: 44px;">
                        <option value="Đại học">Đại học</option>
                        <option value="Cao đẳng">Cao đẳng</option>
                        <option value="Thạc sĩ">Thạc sĩ</option>
                    </select>
                </div>

                <div style="grid-column: span 2;">
                    <label style="color:var(--text-muted); font-size:14px;">Loại hình đào tạo</label>
                    <select name="loai_hinh_dao_tao" class="faq-input" style="height: 44px;">
                        <option value="Chính quy">Chính quy</option>
                        <option value="Vừa làm vừa học">Vừa làm vừa học</option>
                        <option value="Đào tạo từ xa">Đào tạo từ xa</option>
                    </select>
                </div>
            </div>
            
            <div style="text-align: right; margin-top: 10px; border-top: 1px solid #2c3138; padding-top: 15px;">
                <button type="button" class="btn btn-outline" style="margin-right: 10px;" onclick="closeModal('addUserModal')">Hủy bỏ</button>
                <button type="submit" class="btn">Tạo tài khoản</button>
            </div>
        </form>
    </div>
</div>
    <div class="modal-overlay" id="replyModal">
        <div class="modal-box">
            <div class="modal-header">
                <h3>Phản hồi Sinh viên</h3>
                <span class="close-btn" onclick="closeModal('replyModal')">✖</span>
            </div>
            <form method="POST" action="admin_dashboard.php">
                <input type="hidden" name="action" value="reply_ticket">
                <div class="student-info" id="modalStudentInfo"></div>
                <input type="hidden" name="ticket_id" id="modalTicketId">
                <textarea name="reply_content" placeholder="Nhập câu trả lời..." required></textarea>
                <div style="text-align: right;">
                    <button type="button" class="btn btn-outline" style="margin-right: 10px;" onclick="closeModal('replyModal')">Hủy</button>
                    <button type="submit" class="btn">Gửi phản hồi</button>
                </div>
            </form>
        </div>
    </div>

    <div class="modal-overlay" id="faqModal">
        <div class="modal-box">
            <div class="modal-header">
                <h3 id="faqModalTitle">Thêm dữ liệu cho Bot</h3>
                <span class="close-btn" onclick="closeModal('faqModal')">✖</span>
            </div>
            <form method="POST" action="admin_dashboard.php">
                <input type="hidden" name="action" id="faqAction" value="add_faq">
                <input type="hidden" name="faq_id" id="faqId" value="">
                
                <label style="color:var(--text-muted); font-size:14px;">Từ khóa nhận diện (cách nhau bằng dấu phẩy):</label>
                <input type="text" name="tu_khoa" id="faqTuKhoa" class="faq-input" placeholder="VD: học phí, hoc phi" required>
                
                <label style="color:var(--text-muted); font-size:14px;">Nội dung tài liệu (Để AI đọc và hiểu):</label>
                <textarea name="noi_dung" id="faqNoiDung" placeholder="Nhập quy chế chuẩn xác..." required style="height: 150px;"></textarea>
                
                <div style="text-align: right;">
                    <button type="button" class="btn btn-outline" style="margin-right: 10px;" onclick="closeModal('faqModal')">Hủy bỏ</button>
                    <button type="submit" class="btn" id="faqSubmitBtn">Lưu dữ liệu</button>
                </div>
            </form>
        </div>
    </div>
    

    <script>
        function switchTab(tabId, element) {
            document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
            document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
            document.getElementById('tab-' + tabId).classList.add('active');
            element.classList.add('active');
            
            // Đẩy trạng thái tab lên thanh URL để tránh mất vị trí khi refresh thủ công
            const url = new URL(window.location);
            url.searchParams.set('tab', tabId);
            window.history.pushState({}, '', url);
        }

        function closeModal(modalId) {
            document.getElementById(modalId).classList.remove('active');
        }

        function openReplyModal(ticketId, studentName, content) {
            document.getElementById('modalTicketId').value = ticketId;
            document.getElementById('modalStudentInfo').innerHTML = `<b>Sinh viên:</b> ${studentName}<br><br><b>Câu hỏi:</b> ${content}`;
            document.getElementById('replyModal').classList.add('active');
        }

        function openFaqModal(mode, id = '', tuKhoa = '', noiDung = '') {
            if (mode === 'add') {
                document.getElementById('faqModalTitle').innerText = 'Thêm dữ liệu huấn luyện mới';
                document.getElementById('faqAction').value = 'add_faq';
                document.getElementById('faqId').value = '';
                document.getElementById('faqTuKhoa').value = '';
                document.getElementById('faqNoiDung').value = '';
                document.getElementById('faqSubmitBtn').innerText = 'Thêm dữ liệu';
            } else if (mode === 'edit') {
                document.getElementById('faqModalTitle').innerText = 'Chỉnh sửa dữ liệu Bot';
                document.getElementById('faqAction').value = 'edit_faq';
                document.getElementById('faqId').value = id;
                document.getElementById('faqTuKhoa').value = tuKhoa;
                document.getElementById('faqNoiDung').value = noiDung;
                document.getElementById('faqSubmitBtn').innerText = 'Lưu thay đổi';
            }
            document.getElementById('faqModal').classList.add('active');
        }
    </script>
</body>
</html>
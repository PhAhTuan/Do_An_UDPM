<?php
session_start();
$error = "";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if ($username === 'admin' && $password === '123456') {
        $_SESSION['user'] = 'Admin';
        $_SESSION['role'] = 'admin';
        header("Location: admin.php");
        exit();
    } elseif ($username === '075205019210') {
        $_SESSION['user'] = 'Phạm Anh Tuấn';
        $_SESSION['role'] = 'student';
        $_SESSION['mssv'] = '075205019210';
        header("Location: dashboard.php");
        exit();
    } else {
        $error = "Tài khoản hoặc mật khẩu không chính xác!";
    }
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>UTH Portal - Đăng nhập</title>
    <link rel="stylesheet" href="css/login.css">
</head>
<body>
    <div class="login-container">
        <div class="notice-panel">
            <div class="tabs">
                <div class="tab-item active">THÔNG BÁO CHUNG</div>
                <div class="tab-item">CTCT-QL SINH VIÊN</div>
                <div class="tab-item">THÔNG TIN ĐÀO TẠO</div>
            </div>
            <div class="notice-list">
                <div class="notice-item">
                    <div class="notice-title">THÔNG BÁO Về việc điều chỉnh đăng ký học phần Học kỳ hè năm học 2025 - 2026</div>
                    <div class="notice-meta"><span>23/06/2026</span><a href="#" class="view-detail">Xem chi tiết</a></div>
                </div>
            </div>
        </div>

        <div class="login-card">
            <div class="logo-title">
                <h2>UTH</h2>
                <p>UNIVERSITY OF TRANSPORT<br>HO CHI MINH CITY</p>
            </div>
            <div class="form-title">ĐĂNG NHẬP HỆ THỐNG</div>
            
            <?php if(!empty($error)): ?>
                <div class="error-msg"><?php echo $error; ?></div>
            <?php endif; ?>

            <form action="login.php" method="POST">
                <div class="input-group">
                    <label>Tài khoản đăng nhập</label>
                    <input type="text" name="username" placeholder="Nhập MSSV hoặc tài khoản..." required value="075205019210">
                </div>
                <div class="input-group">
                    <label>Mật khẩu</label>
                    <input type="password" name="password" placeholder="••••••••" required value="123">
                </div>
                <button type="submit" class="btn-login">ĐĂNG NHẬP</button>
                <a href="#" class="forgot-pw">QUÊN MẬT KHẨU?</a>
            </form>
        </div>
    </div>
</body>
</html>
<?php
session_start();
header('Content-Type: application/json; charset=UTF-8');

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'Bạn chưa đăng nhập']);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_FILES['avatar'])) {
    echo json_encode(['success' => false, 'message' => 'Yêu cầu không hợp lệ']);
    exit;
}

$file = $_FILES['avatar'];
if ($file['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['success' => false, 'message' => 'Có lỗi khi tải file lên']);
    exit;
}

// Kiểm tra định dạng
$allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($file['type'], $allowedTypes)) {
    echo json_encode(['success' => false, 'message' => 'Chỉ chấp nhận file ảnh (JPG, PNG, GIF, WEBP)']);
    exit;
}

// Kiểm tra kích thước (tối đa 5MB)
if ($file['size'] > 5 * 1024 * 1024) {
    echo json_encode(['success' => false, 'message' => 'Dung lượng file vượt quá 5MB']);
    exit;
}

$uploadDir = __DIR__ . '/../uploads/avatars/';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0755, true);
}

$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
$filename = 'user_' . $_SESSION['user_id'] . '_' . time() . '.' . $ext;
$destination = $uploadDir . $filename;

if (move_uploaded_file($file['tmp_name'], $destination)) {
    // Lưu vào database
    include __DIR__.'/../config.php';
    require_once __DIR__.'/../core/faq_helpers.php';
    try {
        $pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
        
        // Cập nhật CSDL
        $avatarPath = 'uploads/avatars/' . $filename;
        dbExecute($pdo, 'UPDATE users SET avatar_url = ? WHERE id = ?', [$avatarPath, $_SESSION['user_id']]);
        
        // Cập nhật session
        $_SESSION['avatar'] = $avatarPath;
        
        echo json_encode(['success' => true, 'avatar_url' => $avatarPath]);
    } catch (Exception $e) {
        echo json_encode(['success' => false, 'message' => 'Lỗi cập nhật CSDL']);
    }
} else {
    echo json_encode(['success' => false, 'message' => 'Không thể lưu file']);
}

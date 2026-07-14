<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');
$error = '';
$scriptPath = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '/views/login.php');
$projectBase = rtrim(dirname(dirname($scriptPath)), '/');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $username = trim($_POST['username'] ?? '');
  $password = $_POST['password'] ?? '';
  include __DIR__ . '/../config.php';
  require_once __DIR__ . '/../core/faq_helpers.php';
  try {
    $pdo  = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);
    $user = appFindUserForLogin($pdo, $username);
    if (!$user) {
      $error = 'Debug: User not found in db';
    } else if ($user['status'] !== 'active') {
      $error = 'Debug: User not active';
    } else if (!password_verify($password, $user['password_hash'])) {
      $error = 'Debug: Password verify failed';
    } else {
      if (password_needs_rehash($user['password_hash'], PASSWORD_DEFAULT)) {
        dbExecute($pdo, 'UPDATE users SET password_hash = ?, password_changed_at = NOW() WHERE id = ?', [
          password_hash($password, PASSWORD_DEFAULT),
          (int)$user['id'],
        ]);
      }

      session_regenerate_id(true);
      $_SESSION['user_id']  = (int)$user['id'];
      $_SESSION['username'] = $user['username'];
      $_SESSION['role']     = $user['role_code'];
      $_SESSION['ho_ten']   = $user['full_name'];
      $_SESSION['avatar']   = $user['avatar_url'] ?? '';

      // Không tái sử dụng phiên chatbot của tài khoản đăng nhập trước đó.
      unset($_SESSION['chat_session_uuid'], $_SESSION['chat_session_db_id']);

      dbExecute($pdo, 'UPDATE users SET last_login_at = NOW() WHERE id = ?', [(int)$user['id']]);

      if ($user['role_code'] === 'admin' || $user['role_code'] === 'knowledge_reviewer' || $user['role_code'] === 'staff') {
        header('Location: ' . $projectBase . '/views/admin_dashboard.php');
        exit;
      }
      $_SESSION['mssv'] = $user['student_code'] ?: $user['username'];
      header('Location: ' . $projectBase . '/views/dashboard.php');
      exit;
    }
  } catch (Throwable $e) {
    $error = 'Debug SQL error: ' . $e->getMessage();
  }
} else {
  if (isset($_SESSION['user_id'])) {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
      $params = session_get_cookie_params();
      setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();
    session_start();
  }
}
?>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Portal UTH</title>
  <link rel="shortcut icon" type="image/png" href="https://portal.ut.edu.vn/images/logo_spinner.png">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<?php echo htmlspecialchars($projectBase . '/css/login.css', ENT_QUOTES, 'UTF-8'); ?>">
</head>

<body>

  <div class="login-wrapper">

    <!-- ===== LEFT PANEL: NEWS ===== -->
    <div class="news-panel">
      <div class="news-tabs-wrapper">
        <button class="nav-arrow" disabled>
          <svg focusable="false" aria-hidden="true" viewBox="0 0 24 24">
            <path d="M15.41 16.09l-4.58-4.59 4.58-4.59L14 5.5l-6 6 6 6z"></path>
          </svg>
        </button>
        <div class="news-tabs">
          <button class="tab-btn active">Thông báo chung<span class="tab-indicator"></span></button>
          <button class="tab-btn">CTCT- QL Sinh viên</button>
          <button class="tab-btn">Thông tin đào tạo</button>
          <button class="tab-btn">Đào tạo chất lượng cao</button>
          <button class="tab-btn">Viện Đào tạo & Hợp tác quốc tế</button>
        </div>
        <button class="nav-arrow">
          <svg focusable="false" aria-hidden="true" viewBox="0 0 24 24">
            <path d="M8.59 16.34l4.58-4.59-4.58-4.59L10 5.75l6 6-6 6z"></path>
          </svg>
        </button>
      </div>

      <div class="news-list">
        <div class="news-item">
          <a href="#" class="news-title">QUYẾT ĐỊNH Về việc công nhận kết quả đánh giá rèn luyện sinh viên đợt 1, năm học 2025-2026</a>
          <div class="news-meta">
            <span class="news-date">06/07/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">THÔNG BÁO Về việc điều chỉnh đăng ký học phần Học kỳ phụ năm học 2025 – 2026</a>
          <div class="news-meta">
            <span class="news-date">23/06/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">QUYẾT ĐỊNH Về việc ban hành mức thu học phí năm học 2026 – 2027</a>
          <div class="news-meta">
            <span class="news-date">10/06/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">THÔNG BÁO về việc bảo trì hệ thống thông tin</a>
          <div class="news-meta">
            <span class="news-date">10/06/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">THÔNG BÁO Về điều kiện sinh viên được tham gia xét học bổng khuyến khích học tập UTH học kỳ 2, năm học 2024-2025</a>
          <div class="news-meta">
            <span class="news-date">30/05/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">THÔNG BÁO Dự thảo kết quả đánh giá rèn luyện sinh viên hệ chính quy</a>
          <div class="news-meta">
            <span class="news-date">28/05/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
        <div class="news-item">
          <a href="#" class="news-title">THÔNG BÁO Về việc đăng ký học phần học kỳ phụ năm học 2025-2026 (Đợt 1)</a>
          <div class="news-meta">
            <span class="news-date">28/05/2026</span>
            <a href="#" class="news-link">Xem chi tiết</a>
          </div>
        </div>
      </div>

      <div class="news-footer">
        <a href="#" class="view-all">Xem tất cả</a>
      </div>
    </div>

    <!-- ===== RIGHT PANEL: LOGIN ===== -->
    <div class="login-panel">
      <div class="login-header">
        <a href="#" class="logo-link">
          <img src="https://portal.ut.edu.vn/images/logo_full.png" alt="logo_uth" onerror="this.src='data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMDAiIGhlaWdodD0iMTAwIiB2aWV3Qm94PSIwIDAgMzAwIDEwMCI+PHRleHQgeD0iMTAiIHk9IjYwIiBmb250LWZhbWlseT0iVGltZXMgTmV3IFJvbWFuIiBmb250LXNpemU9IjUwIiBmaWxsPSIjMDA3OTc2IiBmb250LXdlaWdodD0iYm9sZCI+VVRIPC90ZXh0Pjx0ZXh0IHg9IjExMCIgeT0iNDUiIGZvbnQtZmFtaWx5PSJUaW1lcyBOZXcgUm9tYW4iIGZvbnQtc2l6ZT0iMTYiIGZpbGw9IiNkMzJmMmYiIGZvbnQtd2VpZ2h0PSJib2xkIj5VTklWRVJTSVRZIE9GIFRSQU5TUE9SVDwvdGV4dD48dGV4dCB4PSIxMTAiIHk9IjY1IiBmb250LWZhbWlseT0iVGltZXMgTmV3IFJvbWFuIiBmb250LXNpemU9IjE0IiBmaWxsPSIjZDMyZjJmIiBmb250LXdlaWdodD0iYm9sZCI+SE9DSElNSU5IIENJVFk8L3RleHQ+PC9zdmc+'">
        </a>
        <h4 class="login-title">ĐĂNG NHẬP HỆ THỐNG</h4>
      </div>

      <?php if (!empty($error)): ?>
        <div class="alert-error"><?php echo htmlspecialchars($error, ENT_QUOTES, 'UTF-8'); ?></div>
      <?php endif; ?>

      <form action="<?php echo htmlspecialchars($scriptPath, ENT_QUOTES, 'UTF-8'); ?>" method="POST" class="login-form">
        <div class="mui-form-group">
          <div class="mui-input-wrapper">
            <input type="text" name="username" id="username" class="mui-input" value="<?php echo htmlspecialchars($_POST['username'] ?? '', ENT_QUOTES, 'UTF-8'); ?>" required placeholder=" ">
            <label for="username" class="mui-label">Tài khoản đăng nhập</label>
            <fieldset class="mui-fieldset">
              <legend><span>Tài khoản đăng nhập</span></legend>
            </fieldset>
          </div>
        </div>

        <div class="mui-form-group">
          <div class="mui-input-wrapper">
            <input type="password" name="password" id="password" class="mui-input" required placeholder=" ">
            <label for="password" class="mui-label">Mật khẩu</label>
            <fieldset class="mui-fieldset">
              <legend><span>Mật khẩu</span></legend>
            </fieldset>

            <button type="button" class="toggle-password" id="togglePassword">
              <svg class="eye-icon" id="eye-icon" focusable="false" viewBox="0 0 24 24">
                <path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5M12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5m0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3"></path>
              </svg>
              <svg class="eye-icon" id="eye-off-icon" focusable="false" viewBox="0 0 24 24" style="display:none;">
                <path d="M12 7c2.76 0 5 2.24 5 5 0 .65-.13 1.26-.36 1.83l2.92 2.92c1.51-1.26 2.7-2.89 3.43-4.75-1.73-4.39-6-7.5-11-7.5-1.4 0-2.74.25-3.98.7l2.16 2.16C10.74 7.13 11.35 7 12 7zM2 4.27l2.28 2.28.46.46C3.08 8.3 1.78 10.02 1 12c1.73 4.39 6 7.5 11 7.5 1.55 0 3.03-.3 4.38-.84l.42.42L19.73 22 21 20.73 3.27 3 2 4.27zM7.53 9.8l1.55 1.55c-.05.21-.08.43-.08.65 0 1.66 1.34 3 3 3 .22 0 .44-.03.65-.08l1.55 1.55c-.67.33-1.41.53-2.2.53-2.76 0-5-2.24-5-5 0-.79.2-1.53.53-2.2zm4.31-.78l3.15 3.15.02-.16c0-1.66-1.34-3-3-3l-.17.01z"></path>
              </svg>
            </button>
          </div>
        </div>

        <button type="submit" class="btn-contained">Đăng nhập<span class="ripple"></span></button>
        <button type="button" class="btn-text">Quên mật khẩu?<span class="ripple"></span></button>
      </form>
    </div>

  </div>

  <!-- News Modal -->
  <div id="newsModal" class="modal-overlay" style="display: none;">
    <div class="modal-content">
      <div class="modal-header">
        <h3 id="modalTitle">Chi tiết thông báo</h3>
        <button class="close-modal">&times;</button>
      </div>
      <div class="modal-body" id="modalContent">
        Nội dung...
      </div>
    </div>
  </div>

  <script>
    // --- PASSWORD TOGGLE ---
    const togglePassword = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('password');
    const eyeIcon = document.getElementById('eye-icon');
    const eyeOffIcon = document.getElementById('eye-off-icon');

    togglePassword.addEventListener('click', function() {
      const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordInput.setAttribute('type', type);
      if (type === 'text') {
        eyeIcon.style.display = 'none';
        eyeOffIcon.style.display = 'block';
      } else {
        eyeIcon.style.display = 'block';
        eyeOffIcon.style.display = 'none';
      }
    });

    // --- TABS SCROLLING ---
    const tabsContainer = document.querySelector('.news-tabs');
    const leftArrow = document.querySelectorAll('.nav-arrow')[0];
    const rightArrow = document.querySelectorAll('.nav-arrow')[1];

    leftArrow.addEventListener('click', () => {
      tabsContainer.scrollBy({
        left: -200,
        behavior: 'smooth'
      });
    });

    rightArrow.addEventListener('click', () => {
      tabsContainer.scrollBy({
        left: 200,
        behavior: 'smooth'
      });
    });

    tabsContainer.addEventListener('scroll', () => {
      leftArrow.disabled = tabsContainer.scrollLeft === 0;
      rightArrow.disabled = tabsContainer.scrollLeft + tabsContainer.clientWidth >= tabsContainer.scrollWidth - 1;
    });

    // --- NEWS MODAL ---
    const modal = document.getElementById('newsModal');
    const modalTitle = document.getElementById('modalTitle');
    const modalContent = document.getElementById('modalContent');
    const closeModal = document.querySelector('.close-modal');

    document.querySelectorAll('.news-item').forEach(item => {
      item.addEventListener('click', (e) => {
        e.preventDefault();
        const title = item.querySelector('.news-title').innerText;
        const date = item.querySelector('.news-date').innerText;
        modalTitle.innerText = title;
        modalContent.innerHTML = `
        <p style="color: #666; font-style: italic; margin-bottom: 15px;">Ngày đăng: ${date}</p>
        <p>Đây là nội dung chi tiết của: <strong>${title}</strong>.</p>
        <p style="margin-top: 15px;"><em>(Hệ thống đang hiển thị dữ liệu giả lập minh họa)</em></p>
      `;
        modal.style.display = 'flex';
      });
    });

    closeModal.addEventListener('click', () => {
      modal.style.display = 'none';
    });

    window.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.style.display = 'none';
      }
    });
  </script>
</body>

</html>
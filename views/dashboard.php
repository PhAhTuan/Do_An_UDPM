<?php
session_start();
header('Content-Type: text/html; charset=UTF-8');

// -- Xác thực ------------------------------------------------
if (!isset($_SESSION['role']) || $_SESSION['role'] !== 'student') {
  header('Location: login.php');
  exit();
}

// -- Kết nối DB ---------------------------------------------
include __DIR__ . '/../config.php';
require_once __DIR__ . '/../core/faq_helpers.php';
$pdo = connectDatabase($db_host, $db_port, $db_name, $db_user, $db_pass);

function dashH($value): string
{
  return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function dashDayLabel($day): string
{
  return [
    1 => 'Thứ 2',
    2 => 'Thứ 3',
    3 => 'Thứ 4',
    4 => 'Thứ 5',
    5 => 'Thứ 6',
    6 => 'Thứ 7',
    7 => 'Chủ nhật',
  ][(int)$day] ?? 'Chưa cập nhật';
}

function dashDateTime($value, string $format = 'd/m/Y H:i'): string
{
  if (!$value) {
    return 'Chưa cập nhật';
  }
  $time = strtotime((string)$value);
  return $time ? date($format, $time) : 'Chưa cập nhật';
}

function dashMoney($value): string
{
  return number_format((float)$value, 0, ',', '.') . ' VNĐ';
}

function dashStatusLabel(?string $status): string
{
  return match ($status) {
    'registered' => 'Đã đăng ký',
    'studying' => 'Đang học',
    'completed' => 'Hoàn thành',
    'pending' => 'Chờ công bố',
    'passed' => 'Đạt',
    'failed' => 'Không đạt',
    'unpaid' => 'Chưa đóng',
    'partially_paid' => 'Đã đóng một phần',
    'paid' => 'Đã đóng',
    'overdue' => 'Quá hạn',
    default => $status ?: 'Chưa cập nhật',
  };
}

// -- Mark-read ticket ---------------------------------------
if ($_SERVER['REQUEST_METHOD'] === 'POST' && ($_POST['action'] ?? '') === 'mark_read') {
  dbExecute($pdo, "UPDATE tickets SET status='resolved', resolved_at = NOW() WHERE id = ? AND requester_student_code = ?", [
    intval($_POST['ticket_id']),
    $_SESSION['mssv'] ?? '',
  ]);
  header('Location: dashboard.php');
  exit;
}

// -- Lấy thông tin sinh viên từ DB --------------------------
$studentInfo = appStudentByUserId($pdo, (int)$_SESSION['user_id']) ?: [];
$studentId    = (int)($studentInfo['student_id'] ?? 0);
$mssv         = $studentInfo['mssv'] ?? ($_SESSION['mssv'] ?? '');
$hoTen        = $studentInfo['ho_ten'] ?? ($_SESSION['ho_ten'] ?? 'Sinh viên');
$_SESSION['mssv'] = $mssv;
$_SESSION['ho_ten'] = $hoTen;
$nameParts    = preg_split('/\s+/u', trim($hoTen));
$tenGoi       = $nameParts ? end($nameParts) : $hoTen;
$ngaySinh     = $studentInfo['ngay_sinh']          ?? '';
$noiSinh      = $studentInfo['noi_sinh']           ?? '';
$nganh        = $studentInfo['nganh']              ?? '';
$khoaHoc      = $studentInfo['khoa_hoc']           ?? '';
$gioiTinh     = $studentInfo['gioi_tinh']          ?? '';
$bacDaoTao    = $studentInfo['bac_dao_tao']        ?? '';
$loaiHinh     = $studentInfo['loai_hinh_dao_tao']  ?? '';
$chuyenNganh  = $studentInfo['chuyen_nganh']       ?? '';
$avatar       = $studentInfo['avatar']             ?? '';
$avatarUrl    = !empty($avatar) ? (str_starts_with($avatar, 'http') ? $avatar : '../' . $avatar) . '?v=' . time() : "https://ui-avatars.com/api/?name=" . urlencode($hoTen) . "&background=e3f2fd&color=007976&size=150";

// -- Hệ thống Thông báo / Sự kiện ---------------------------
$systemNotifications = [];
try {
  $systemNotifications = dbFetchAll($pdo, "
        SELECT id, title, content, type, created_at
        FROM system_notifications
        ORDER BY created_at DESC
        LIMIT 10
    ");
} catch (Throwable $e) {
}

// -- Deadline / sự kiện học vụ sắp tới ----------------------
$upcomingDeadlines = [];
try {
  $upcomingDeadlines = dbFetchAll($pdo, "
        SELECT title, description, deadline_type, starts_at, due_at, source_url, audience_type, audience_value
        FROM academic_deadlines
        WHERE status = 'published'
          AND due_at >= DATE_SUB(NOW(), INTERVAL 14 DAY)
          AND (
              audience_type = 'all'
              OR (audience_type = 'student' AND audience_value = ?)
              OR (audience_type = 'cohort' AND audience_value = ?)
              OR (audience_type = 'program' AND audience_value = ?)
          )
        ORDER BY due_at ASC
        LIMIT 10
    ", [
    $mssv,
    (string)($studentInfo['cohort_year'] ?? ''),
    (string)($studentInfo['program_code'] ?? ''),
  ]);
} catch (Throwable $e) {
}

// -- Lịch học trong tuần ------------------------------------
$classSchedules = [];
$todaySchedule = [];
$tomorrowSchedule = [];
try {
  $classSchedules = dbFetchAll($pdo, "
        SELECT id, mssv, subject_name, room, day_of_week, start_time, end_time
        FROM class_schedules
        WHERE mssv = ?
        ORDER BY day_of_week ASC, start_time ASC
    ", [$mssv]);

  // Schema mới: 1=Monday ... 7=Sunday.
  $todayDayOfWeek = (int)date('N');
  $tomorrowDayOfWeek = (int)date('N', strtotime('+1 day'));

  foreach ($classSchedules as $class) {
    if ($class['day_of_week'] == $todayDayOfWeek) {
      $todaySchedule[] = $class;
    } elseif ($class['day_of_week'] == $tomorrowDayOfWeek) {
      $tomorrowSchedule[] = $class;
    }
  }
} catch (Throwable $e) {
}

// -- Lớp học phần, điểm, học phí -----------------------------
$enrolledSections = [];
$gradeRows = [];
$tuitionInvoices = [];
$currentSemesterName = 'Học kỳ hiện tại';
$earnedCredits = 0;
$totalCredits = max(1, (int)($studentInfo['total_credits'] ?? 120));

if ($studentId > 0) {
  try {
    $enrolledSections = dbFetchAll($pdo, "
            SELECT
                e.id AS enrollment_id,
                e.enrollment_status,
                s.code AS subject_code,
                s.name AS subject_name,
                s.credits,
                cs.section_code,
                cs.lecturer_name,
                cs.delivery_mode,
                sem.name AS semester_name,
                ay.code AS academic_year
            FROM enrollments e
            JOIN course_sections cs ON cs.id = e.course_section_id
            JOIN subjects s ON s.id = cs.subject_id
            JOIN semesters sem ON sem.id = cs.semester_id
            JOIN academic_years ay ON ay.id = sem.academic_year_id
            WHERE e.student_id = ?
              AND e.enrollment_status IN ('registered', 'studying', 'completed')
            ORDER BY sem.start_date DESC, s.name ASC
            LIMIT 20
        ", [$studentId]);

    if (!empty($enrolledSections[0]['semester_name'])) {
      $currentSemesterName = $enrolledSections[0]['semester_name'];
    }

    $gradeRows = dbFetchAll($pdo, "
            SELECT
                s.code AS subject_code,
                s.name AS subject_name,
                s.credits,
                sem.name AS semester_name,
                ay.code AS academic_year,
                g.attendance_score,
                g.process_score,
                g.midterm_score,
                g.final_exam_score,
                g.final_score_10,
                g.grade_4,
                g.letter_grade,
                g.result,
                g.published_at
            FROM enrollments e
            JOIN course_sections cs ON cs.id = e.course_section_id
            JOIN subjects s ON s.id = cs.subject_id
            JOIN semesters sem ON sem.id = cs.semester_id
            JOIN academic_years ay ON ay.id = sem.academic_year_id
            JOIN grades g ON g.enrollment_id = e.id
            WHERE e.student_id = ?
            ORDER BY sem.start_date DESC, s.name ASC
            LIMIT 20
        ", [$studentId]);

    $earnedCredits = (int)dbFetchValue($pdo, "
            SELECT COALESCE(SUM(s.credits), 0)
            FROM enrollments e
            JOIN course_sections cs ON cs.id = e.course_section_id
            JOIN subjects s ON s.id = cs.subject_id
            JOIN grades g ON g.enrollment_id = e.id
            WHERE e.student_id = ?
              AND g.result = 'passed'
        ", [$studentId]);

    $tuitionInvoices = dbFetchAll($pdo, "
            SELECT
                ti.invoice_number,
                ti.description,
                ti.subtotal,
                ti.discount_amount,
                ti.paid_amount,
                ti.outstanding_amount,
                ti.due_date,
                ti.status,
                sem.name AS semester_name,
                ay.code AS academic_year
            FROM tuition_invoices ti
            JOIN semesters sem ON sem.id = ti.semester_id
            JOIN academic_years ay ON ay.id = sem.academic_year_id
            WHERE ti.student_id = ?
            ORDER BY ti.issued_at DESC
            LIMIT 5
        ", [$studentId]);
  } catch (Throwable $e) {
  }
}

$progressPercent = min(100, max(0, round(($earnedCredits / $totalCredits) * 100)));
$eventCount = count($systemNotifications) + count($upcomingDeadlines);
$tickerText = $systemNotifications[0]['title'] ?? ($upcomingDeadlines[0]['title'] ?? 'Không có thông báo mới');

// -- Dữ liệu lịch tháng --------------------------------------
$calendarYear = (int)date('Y');
$calendarMonth = (int)date('n');
$calendarEvents = [];
$addCalendarEvent = function (string $date, string $type, string $title, ?string $time = null) use (&$calendarEvents): void {
  if ($date === '' || $title === '') {
    return;
  }
  $calendarEvents[$date][] = [
    'type' => $type,
    'title' => $title,
    'time' => $time,
  ];
};

$daysInCurrentMonth = (int)date('t');
foreach ($classSchedules as $class) {
  $dayOfWeek = (int)($class['day_of_week'] ?? 0);
  if ($dayOfWeek < 1 || $dayOfWeek > 7) {
    continue;
  }
  for ($day = 1; $day <= $daysInCurrentMonth; $day++) {
    $date = sprintf('%04d-%02d-%02d', $calendarYear, $calendarMonth, $day);
    if ((int)date('N', strtotime($date)) === $dayOfWeek) {
      $addCalendarEvent(
        $date,
        'schedule',
        (string)($class['subject_name'] ?? 'Lịch học'),
        substr((string)($class['start_time'] ?? ''), 0, 5)
      );
    }
  }
}
foreach ($systemNotifications as $noti) {
  $date = date('Y-m-d', strtotime((string)$noti['created_at']));
  if ((int)date('Y', strtotime($date)) === $calendarYear && (int)date('n', strtotime($date)) === $calendarMonth) {
    $addCalendarEvent($date, (string)($noti['type'] ?? 'news'), (string)($noti['title'] ?? 'Thông báo'));
  }
}
foreach ($upcomingDeadlines as $deadline) {
  $date = date('Y-m-d', strtotime((string)$deadline['due_at']));
  if ((int)date('Y', strtotime($date)) === $calendarYear && (int)date('n', strtotime($date)) === $calendarMonth) {
    $addCalendarEvent($date, 'deadline', (string)($deadline['title'] ?? 'Deadline'), date('H:i', strtotime((string)$deadline['due_at'])));
  }
}

// -- Deadline học vụ ----------------------------------------
$todayDeadlines = [];
$tomorrowDeadlines = [];
try {
  $todayDeadlines = dbFetchAll($pdo, "
        SELECT title, description, deadline_type, due_at, source_url
        FROM academic_deadlines
        WHERE status = 'published' AND DATE(due_at) = CURDATE()
        ORDER BY due_at ASC
    ");
  $tomorrowDeadlines = dbFetchAll($pdo, "
        SELECT title, description, deadline_type, due_at, source_url
        FROM academic_deadlines
        WHERE status = 'published' AND DATE(due_at) = DATE_ADD(CURDATE(), INTERVAL 1 DAY)
        ORDER BY due_at ASC
    ");
} catch (Throwable $e) {
}

// -- Thông báo ticket ---------------------------------------
$notifications = [];
$notiCount     = 0;
try {
  $notifications = dbFetchAll($pdo, "
        SELECT
            id,
            subject AS title,
            description AS content,
            status,
            created_at
        FROM tickets
        WHERE requester_student_code = ? AND status = 'waiting_student'
        ORDER BY updated_at DESC
    ", [$mssv]);
  $notiCount     = count($notifications);
} catch (Throwable $e) {
}
?>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>UTH Portal — Dashboard</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/dashboard.css?v=<?php echo filemtime(__DIR__ . '/../css/dashboard.css'); ?>">
</head>

<body>

  <!-- ===== SIDEBAR ===== -->
  <div class="sidebar-overlay" id="sidebarOverlay"></div>
  <div class="sidebar" id="sidebar">
    <div class="sidebar-header">
      <h3 class="sidebar-title">Menu chức năng</h3>
      <button class="close-sidebar" id="closeSidebar">&times;</button>
    </div>
    <div class="sidebar-nav">
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tôi muốn đào tạo trực tuyến')">Đào tạo trực tuyến</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tôi cần hỗ trợ trực tuyến')">Hỗ trợ trực tuyến</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Cho tôi xin link cổng thanh toán học phí')">Cổng thanh toán trực tuyến</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tôi muốn tra cứu thông tin dịch vụ sinh viên')">Dịch vụ sinh viên</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Cho tôi xem chương trình khung')">Chương trình khung</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tôi muốn đăng ký học phần')">Đăng ký học phần</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tra cứu danh sách môn học điều kiện')">Đăng ký môn học điều kiện</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Tôi còn nợ bao nhiêu tiền học phí?')">Tra cứu công nợ</a>
      <a href="#" class="sidebar-link" onclick="handleSidebarClick('Cho tôi xem kết quả học tập của tôi')">Kết quả học tập</a>
    </div>
  </div>
  <!-- ===== HEADER ===== -->
  <header class="app-header">
    <div class="header-left">
      <button class="menu-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="3" y1="12" x2="21" y2="12"></line>
          <line x1="3" y1="6" x2="21" y2="6"></line>
          <line x1="3" y1="18" x2="21" y2="18"></line>
        </svg>
      </button>
      <div class="logo-container">
        <a href="dashboard.php" style="display: flex; align-items: center;">
          <img src="https://portal.ut.edu.vn/images/logo_full.png" alt="logo_uth" style="height: 38px; object-fit: contain;">
        </a>
      </div>
    </div>

    <div class="header-right">
      <div class="user-dropdown">
        <div class="user-trigger" onclick="toggleUserMenu()" id="userTrigger">
          <!-- Default avatar image, should ideally be dynamically loaded -->
          <img src="<?php echo dashH($avatarUrl); ?>" id="headerAvatar" alt="Avatar" class="u-avatar">
          <span class="u-name"><?php echo dashH($hoTen); ?></span>
          <svg class="u-chevron" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="6 9 12 15 18 9"></polyline>
          </svg>
        </div>

        <div class="drop-menu" id="userMenu">
          <div class="drop-section">Thông báo (<?php echo $notiCount; ?>)</div>
          <?php if ($notiCount === 0): ?>
            <div style="padding:8px 12px;font-size:13px;color:#757575;font-style:italic">Không có thông báo mới</div>
          <?php else: ?>
            <?php foreach ($notifications as $noti): ?>
              <a href="#" class="drop-item noti-link"
                onclick="openStudentChat(<?php echo intval($noti['id']); ?>, <?php echo dashH(json_encode($noti['title'] ?? '', JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)); ?>, <?php echo dashH(json_encode($noti['content'] ?? '', JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)); ?>); closeUserMenu();">
                Ticket #<?php echo intval($noti['id']); ?> có phản hồi
              </a>
            <?php endforeach; ?>
          <?php endif; ?>
          <div class="drop-divider"></div>
          <a href="login.php" class="drop-item danger">Đăng xuất</a>
        </div>
      </div>
    </div>
  </header>

  <!-- ===== MAIN CONTENT ===== -->
  <div class="container">

    <div class="main-grid">

      <!-- LEFT SIDE -->
      <div class="left-col">
        <!-- Student Info Card -->
        <div class="card sv-card">
          <div class="sv-header">
            <h2 class="card-title">Thông tin sinh viên</h2>
            <span class="sv-badge" style="color: #007976; background: transparent; font-weight: 500; cursor: pointer; padding: 5px 10px; border-radius: 4px; transition: background 0.2s;" onmouseover="this.style.background='#f0f0f0'" onmouseout="this.style.background='transparent'" onclick="openStudentCardModal()">THẺ SINH VIÊN</span>
          </div>
          <div class="sv-body">
            <div class="sv-avatar-container">
              <!-- Placeholder for avatar as in screenshot -->
              <img src="<?php echo dashH($avatarUrl); ?>" alt="Avatar" class="sv-img" id="mainDashboardAvatar">
            </div>
            <div class="sv-details">
              <div class="sv-row">
                <span class="sv-label">MSSV:</span>
                <span class="sv-val"><?php echo dashH($mssv); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Khóa học:</span>
                <span class="sv-val"><?php echo dashH($khoaHoc ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Họ tên:</span>
                <span class="sv-val"><?php echo dashH($hoTen); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Giới tính:</span>
                <span class="sv-val"><?php echo dashH($gioiTinh ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Ngày sinh:</span>
                <span class="sv-val"><?php echo dashH($ngaySinh ? date('d/m/Y', strtotime($ngaySinh)) : 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Bậc đào tạo:</span>
                <span class="sv-val"><?php echo dashH($bacDaoTao ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Nơi sinh:</span>
                <span class="sv-val"><?php echo dashH($noiSinh ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row">
                <span class="sv-label">Loại hình đào tạo:</span>
                <span class="sv-val"><?php echo dashH($loaiHinh ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row" style="grid-column: 1 / -1;">
                <span class="sv-label">Ngành:</span>
                <span class="sv-val"><?php echo dashH($nganh ?: 'Chưa cập nhật'); ?></span>
              </div>
              <div class="sv-row" style="grid-column: 1 / -1; margin-top: -8px;">
                <span class="sv-label">Chuyên ngành:</span>
                <span class="sv-val"><?php echo dashH($chuyenNganh ?: 'Chưa cập nhật'); ?></span>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Stats Row -->
        <div class="stats-row">
          <div class="card event-card">
            <div style="display:flex; justify-content:space-between; align-items:center;">
              <h3 class="card-title" style="margin:0;">Thông báo/ sự kiện</h3>
              <div style="display:flex; align-items:center; gap:10px; max-width: 50%;">
                <marquee scrollamount="4" style="color:#d32f2f; font-size:13px; font-weight:500;"><?php echo dashH($tickerText); ?></marquee>
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#d32f2f">
                  <path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.9 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z" />
                </svg>
              </div>
            </div>
            <div class="event-number"><?php echo $eventCount; ?></div>
            <a href="javascript:void(0)" onclick="openSystemNotificationsModal()" class="event-link">Xem chi tiết</a>
          </div>

          <div class="card stat-card teal-bg">
            <div class="stat-top">
              <h3 class="stat-title white">Lịch học trong tuần</h3>
              <svg class="stat-icon white" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                <line x1="16" y1="2" x2="16" y2="6"></line>
                <line x1="8" y1="2" x2="8" y2="6"></line>
                <line x1="3" y1="10" x2="21" y2="10"></line>
              </svg>
            </div>
            <div class="stat-num white"><?php echo count($classSchedules); ?></div>
            <a href="javascript:void(0)" onclick="openScheduleModal()" class="stat-link white">Xem chi tiết</a>
          </div>
        </div>

      </div>

      <!-- RIGHT SIDE -->
      <div class="right-col">
        <!-- Calendar Card -->
        <div class="card cal-card">
          <div class="cal-header">
            <h3 class="cal-title">Lịch theo tháng</h3>
            <div class="cal-nav-container">
              <button class="cal-nav" type="button" id="calPrevBtn">‹</button>
              <div class="cal-month"><span id="calMonthLabel"></span> <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                  <line x1="16" y1="2" x2="16" y2="6"></line>
                  <line x1="8" y1="2" x2="8" y2="6"></line>
                  <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg></div>
              <button class="cal-nav" type="button" id="calNextBtn">›</button>
            </div>
          </div>

          <div class="cal-grid" id="calGrid">
            <!-- Calendar gets injected here via JS -->
          </div>
        </div>
      </div>

    </div>

    <!-- Bottom Actions -->
    <div class="action-grid">
      <div class="action-card" onclick="openChatbotWithMsg('Tôi muốn đào tạo trực tuyến')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 10v6M2 10l10-5 10 5-10 5z"></path>
            <path d="M6 12v5c3 3 9 3 12 0v-5"></path>
          </svg>
        </div>
        <div class="action-text">Đào tạo trực<br>tuyến</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Tôi cần hỗ trợ trực tuyến')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 9a2 2 0 0 1-2 2H6l-4 4V4c0-1.1.9-2 2-2h8a2 2 0 0 1 2 2v5Z"></path>
            <path d="M18 9h2a2 2 0 0 1 2 2v11l-4-4h-6a2 2 0 0 1-2-2v-1"></path>
          </svg>
        </div>
        <div class="action-text">Hỗ trợ trực<br>tuyến</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Cho tôi xin link cổng thanh toán học phí')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="1" x2="12" y2="23"></line>
            <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
          </svg>
        </div>
        <div class="action-text">Cổng thanh toán<br>trực tuyến</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Tôi muốn tra cứu thông tin dịch vụ sinh viên')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
          </svg>
        </div>
        <div class="action-text">Dịch vụ sinh<br>viên</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Cho tôi xem chương trình khung')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="3" y1="9" x2="21" y2="9"></line>
            <line x1="9" y1="21" x2="9" y2="9"></line>
          </svg>
        </div>
        <div class="action-text">Chương trình<br>khung</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Tôi muốn đăng ký học phần')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <path d="M8 14s1.5 2 4 2 4-2 4-2"></path>
            <line x1="9" y1="9" x2="9.01" y2="9"></line>
            <line x1="15" y1="9" x2="15.01" y2="9"></line>
          </svg>
        </div>
        <div class="action-text">Đăng ký học<br>phần</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Tra cứu danh sách môn học điều kiện')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
          </svg>
        </div>
        <div class="action-text">Đăng ký môn<br>học điều kiện</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Tôi còn nợ bao nhiêu tiền học phí?')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
          </svg>
        </div>
        <div class="action-text">Tra cứu công nợ</div>
      </div>
      <div class="action-card" onclick="openChatbotWithMsg('Cho tôi xem kết quả học tập của tôi')">
        <div class="action-icon">
          <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
            <line x1="16" y1="2" x2="16" y2="6"></line>
            <line x1="8" y1="2" x2="8" y2="6"></line>
            <line x1="3" y1="10" x2="21" y2="10"></line>
          </svg>
        </div>
        <div class="action-text">Kết quả học tập</div>
      </div>
    </div>

    <!-- Bottom Details Row -->
    <div class="details-row">
      <!-- Kết quả học tập -->
      <div class="card details-card">
        <div class="details-header">
          <h3 class="card-title">Kết quả học tập</h3>
          <select class="details-select">
            <option><?php echo dashH($currentSemesterName); ?></option>
          </select>
        </div>
        <?php if (empty($gradeRows)): ?>
          <div class="details-empty">
            <svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24" fill="#e8eaf6">
              <path d="M20 6h-8l-2-2H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2z" />
            </svg>
            <p>Chưa có điểm được công bố cho học kỳ này.</p>
          </div>
        <?php else: ?>
          <table class="details-table compact-table">
            <thead>
              <tr>
                <th style="text-align:left;">Môn học</th>
                <th>Điểm</th>
                <th>Chữ</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach (array_slice($gradeRows, 0, 5) as $grade): ?>
                <tr>
                  <td>
                    <strong><?php echo dashH($grade['subject_name']); ?></strong>
                    <span class="muted-line"><?php echo dashH($grade['subject_code']); ?> · <?php echo (int)$grade['credits']; ?> tín chỉ</span>
                  </td>
                  <td style="text-align:center;"><?php echo $grade['final_score_10'] !== null ? dashH($grade['final_score_10']) : 'Chưa có'; ?></td>
                  <td style="text-align:center;"><?php echo dashH($grade['letter_grade'] ?: dashStatusLabel($grade['result'] ?? null)); ?></td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>

      <!-- Tiến độ học tập -->
      <div class="card details-card">
        <div class="details-header">
          <h3 class="card-title">Tiến độ học tập</h3>
        </div>
        <div class="progress-circle">
          <!-- SVG for Donut Chart mimic -->
          <svg viewBox="0 0 36 36" class="circular-chart">
            <path class="circle-bg" fill="none" stroke="#e0e0e0" stroke-width="3.8"
              d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
            <path class="circle" fill="none" stroke="#10b981" stroke-width="3.8" stroke-linecap="round"
              stroke-dasharray="<?php echo $progressPercent; ?>, 100"
              d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
          </svg>
          <div class="progress-text">
            Đã đạt: <?php echo $earnedCredits; ?>/<?php echo $totalCredits; ?>
            <span><?php echo $progressPercent; ?>%</span>
          </div>
        </div>
      </div>

      <!-- Lớp học phần -->
      <div class="card details-card">
        <div class="details-header" style="flex-direction: row; gap: 10px;">
          <h3 class="card-title">Lớp học phần</h3>
          <select class="details-select">
            <option><?php echo dashH($currentSemesterName); ?></option>
          </select>
        </div>
        <?php if (empty($enrolledSections)): ?>
          <div class="details-empty">
            <p>Chưa có lớp học phần trong học kỳ hiện tại.</p>
          </div>
        <?php else: ?>
          <table class="details-table compact-table">
            <thead>
              <tr>
                <th style="text-align: left;">Môn học</th>
                <th style="text-align: right;">Tín chỉ</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach (array_slice($enrolledSections, 0, 6) as $section): ?>
                <tr>
                  <td>
                    <strong><?php echo dashH($section['subject_name']); ?></strong>
                    <span class="muted-line"><?php echo dashH($section['section_code']); ?> · <?php echo dashH($section['lecturer_name'] ?: 'Chưa cập nhật GV'); ?></span>
                  </td>
                  <td style="text-align: right;"><?php echo (int)$section['credits']; ?></td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>
    </div>

  </div><!-- /.container -->

  <!-- Student Card Modal -->
  <div id="studentCardModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 2000; align-items: center; justify-content: center;">
    <div class="modal-box" style="width: 90%; max-width: 600px; background: transparent; border-radius: 0; overflow: visible; box-shadow: none; position: relative;">

      <!-- Close Button -->
      <button onclick="closeStudentCardModal()" style="position: absolute; right: -15px; top: -15px; background: #fff; border: 2px solid #007976; color: #007976; width: 36px; height: 36px; border-radius: 50%; font-size: 20px; font-weight: bold; cursor: pointer; z-index: 10; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 10px rgba(0,0,0,0.3); transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.1)'" onmouseout="this.style.transform='scale(1)'">&times;</button>

      <!-- ID Card Container -->
      <div style="background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 15px 35px rgba(0,0,0,0.2); display: flex; flex-direction: column;">

        <!-- Card Header -->
        <div style="background: #007976; padding: 15px 25px; display: flex; align-items: center; gap: 15px;">
          <img src="https://portal.ut.edu.vn/images/logo_full.png" alt="UTH Logo" style="height: 40px; filter: brightness(0) invert(1);">
          <div style="color: #fff; border-left: 2px solid rgba(255,255,255,0.3); padding-left: 15px;">
            <div style="font-weight: 700; font-size: 18px; letter-spacing: 1px;">THẺ SINH VIÊN</div>
            <div style="font-size: 12px; opacity: 0.9;">STUDENT ID CARD</div>
          </div>
        </div>

        <!-- Card Body -->
        <div style="padding: 30px 25px; display: flex; gap: 30px; position: relative; z-index: 1; flex-wrap: wrap;">
          <!-- Left: Photo & Upload -->
          <div style="width: 140px; flex-shrink: 0; display: flex; flex-direction: column; align-items: center; margin: 0 auto;">
            <div style="position: relative; width: 140px; height: 180px; border-radius: 8px; border: 3px solid #007976; overflow: hidden; background: #fff; box-shadow: 0 4px 12px rgba(0,0,0,0.15);">
              <img src="<?php echo dashH($avatarUrl); ?>" id="modalAvatarPreview" alt="Avatar" style="width: 100%; height: 100%; object-fit: cover;">

              <label for="avatarUploadInput" style="position: absolute; bottom: 0; left: 0; right: 0; background: rgba(0,121,118,0.85); color: #fff; padding: 8px 0; text-align: center; font-size: 13px; font-weight: 500; cursor: pointer; backdrop-filter: blur(4px); transition: background 0.2s;" onmouseover="this.style.background='rgba(0,121,118,1)'" onmouseout="this.style.background='rgba(0,121,118,0.85)'">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align: text-bottom; margin-right: 4px;">
                  <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                  <polyline points="17 8 12 3 7 8"></polyline>
                  <line x1="12" y1="3" x2="12" y2="15"></line>
                </svg> Đổi ảnh
              </label>
              <input type="file" id="avatarUploadInput" style="display: none;" accept="image/*" onchange="uploadAvatar()">
            </div>
            <!-- Barcode dummy -->
            <div style="margin-top: 15px; width: 100%; height: 40px; background: repeating-linear-gradient(90deg, #333, #333 2px, transparent 2px, transparent 4px, #333 4px, #333 5px, transparent 5px, transparent 8px, #333 8px, #333 12px, transparent 12px, transparent 15px); opacity: 0.7;"></div>
            <div style="font-size: 11px; letter-spacing: 2px; color: #555; margin-top: 5px;"><?php echo dashH($mssv); ?></div>
          </div>

          <!-- Right: Details -->
          <div style="flex: 1; min-width: 250px; padding-top: 10px;">
            <h4 style="color: #007976; font-size: 24px; margin-bottom: 20px; font-weight: 700; text-transform: uppercase;"><?php echo dashH($hoTen); ?></h4>

            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 10px; font-size: 15px; color: #333; margin-bottom: 12px;">
              <div style="font-weight: 600; color: #666;">MSSV:</div>
              <div style="font-weight: 700; color: #007976;"><?php echo dashH($mssv); ?></div>
            </div>

            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 10px; font-size: 15px; color: #333; margin-bottom: 12px;">
              <div style="font-weight: 600; color: #666;">Ngày sinh:</div>
              <div><?php echo dashH($ngaySinh ? date('d/m/Y', strtotime($ngaySinh)) : 'Chưa cập nhật'); ?></div>
            </div>

            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 10px; font-size: 15px; color: #333; margin-bottom: 12px;">
              <div style="font-weight: 600; color: #666;">Khóa học:</div>
              <div><?php echo dashH($khoaHoc ?: 'Chưa cập nhật'); ?></div>
            </div>

            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 10px; font-size: 15px; color: #333; margin-bottom: 12px;">
              <div style="font-weight: 600; color: #666;">Bậc đào tạo:</div>
              <div><?php echo dashH($bacDaoTao ?: 'Chưa cập nhật'); ?></div>
            </div>

            <div style="display: grid; grid-template-columns: 100px 1fr; gap: 10px; font-size: 15px; color: #333; margin-bottom: 12px;">
              <div style="font-weight: 600; color: #666;">Ngành:</div>
              <div style="font-weight: 600;"><?php echo dashH($nganh ?: 'Chưa cập nhật'); ?></div>
            </div>

          </div>
        </div>
      </div>
    </div>
  </div>

  <script>
    function openStudentCardModal() {
      document.getElementById('studentCardModal').style.display = 'flex';
    }

    function closeStudentCardModal() {
      document.getElementById('studentCardModal').style.display = 'none';
    }

    function uploadAvatar() {
      const fileInput = document.getElementById('avatarUploadInput');
      const file = fileInput.files[0];
      if (!file) return;

      // Basic check
      if (file.size > 2 * 1024 * 1024) {
        alert("Dung lượng file quá lớn! Vui lòng chọn ảnh dưới 2MB.");
        return;
      }

      const formData = new FormData();
      formData.append('avatar', file);

      // Show loading state
      const label = document.querySelector('label[for="avatarUploadInput"]');
      const originalText = label.innerHTML;
      label.innerHTML = 'Đang tải...';

      fetch('../api/upload_avatar.php', {
          method: 'POST',
          body: formData
        })
        .then(res => res.json())
        .then(data => {
          if (data.success) {
            const newUrl = (data.avatar_url.startsWith('http') ? data.avatar_url : '../' + data.avatar_url) + '?v=' + new Date().getTime();
            document.getElementById('mainDashboardAvatar').src = newUrl;
            document.getElementById('modalAvatarPreview').src = newUrl;
            if (document.getElementById('headerAvatar')) {
              document.getElementById('headerAvatar').src = newUrl;
            }
          } else {
            alert(data.message || 'Có lỗi xảy ra!');
          }
        })
        .catch(err => {
          alert('Không thể kết nối tới máy chủ!');
        })
        .finally(() => {
          label.innerHTML = originalText;
          fileInput.value = ""; // Reset input
        });
    }
  </script>

  <!-- ===== CHATBOT WIDGET ===== -->
  <div class="bot-widget" id="botWidget">
    <button class="bot-launcher" id="botLauncher" aria-label="Mở chatbot Bảo Bảo">💬</button>

    <div class="bot-window" id="botWindow">
      <!-- SIDEBAR HISTORY -->
      <div class="bot-sidebar" id="botSidebar">
        <div class="sidebar-header">
          <span style="font-weight:600; color:#fff;">Lịch sử trò chuyện</span>
          <button class="bot-btn-sm" onclick="toggleHistory()" style="font-size:16px;">✕</button>
        </div>
        <button class="new-chat-btn" onclick="startNewChat()">+ Trò chuyện mới</button>
        <div class="history-list" id="historyList">
          <!-- History items will be populated by JS -->
        </div>
      </div>

      <div class="bot-head">
        <div class="bot-head-info">
          <div>
            <div class="bot-nm">ChatBot UTH</div>
            <div class="bot-st">Trợ lý sinh viên • Trực tuyến</div>
          </div>
        </div>
        <div class="bot-head-acts">
          <button class="bot-btn-sm" id="historyToggleBtn" title="Lịch sử trò chuyện" onclick="toggleHistory()" style="font-size:12px; font-weight:600; width:auto; padding:0 8px;">Lịch sử</button>
          <button class="bot-btn-sm bot-voice-toggle" id="voiceToggleBtn" type="button" title="Tự đọc câu trả lời: tắt" aria-label="Bật hoặc tắt tự đọc câu trả lời" aria-pressed="false" onclick="toggleVoiceMode()">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon>
              <path d="M15.54 8.46a5 5 0 0 1 0 7.07"></path>
              <path d="M19.07 4.93a10 10 0 0 1 0 14.14"></path>
            </svg>
            <span>Đọc</span>
          </button>
          <button class="bot-btn-sm" id="expandChatBtn" title="Mở rộng" onclick="expandChatbot()" style="font-size:16px;">⛶</button>
          <button class="bot-btn-sm" id="closeChatBtn" title="Đóng">✕</button>
        </div>
      </div>

      <div class="bot-body" id="chatBody">
        <div class="chat-msg bot">
          Chào <?php echo dashH($hoTen); ?>! 👋 Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
        </div>
        <div class="chat-suggestions" id="chatSuggestions">
          <button class="suggestion-chip" onclick="sendQuickMessage('Cho tôi xem kết quả học tập')">Xem điểm</button>
          <button class="suggestion-chip" onclick="sendQuickMessage('Ngày mai mình có lịch học gì?')">Lịch ngày mai</button>
          <button class="suggestion-chip" onclick="sendQuickMessage('Tôi còn nợ bao nhiêu tiền học phí?')">Học phí</button>
        </div>
      </div>

      <div class="bot-foot">
        <input type="text" id="userInput" placeholder="Nhập câu hỏi của bạn…" autocomplete="off" onkeypress="if(event.key === 'Enter') sendMessage();">
        <button class="bot-send" id="sendBtn" onclick="sendMessage();">Gửi</button>
      </div>
    </div>
  </div>

  <!-- ===== TICKET MODAL ===== -->
  <div class="modal-overlay" id="ticketModal">
    <div class="modal-box">
      <div class="modal-title" id="modalTitle">Phản hồi từ Ban quản trị</div>
      <div class="modal-body" id="modalBody"></div>
      <form method="POST" action="dashboard.php">
        <input type="hidden" name="action" value="mark_read">
        <input type="hidden" name="ticket_id" id="modalTicketId">
        <button type="submit" class="modal-close">Đã hiểu</button>
      </form>
    </div>
  </div>

  <!-- System Notifications Modal -->
  <div id="sysNotiModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 2000; align-items: center; justify-content: center;">
    <div class="modal-box" style="width: 90%; max-width: 500px; background: #fff; border-radius: 12px; overflow: hidden;">
      <div style="background: #007976; color: #fff; padding: 15px; position: relative;">
        <h3 style="margin: 0; font-size: 18px;">Thông báo & Sự kiện</h3>
        <button onclick="document.getElementById('sysNotiModal').style.display='none'" style="position: absolute; right: 15px; top: 15px; background: none; border: none; color: #fff; font-size: 20px; cursor: pointer;">&times;</button>
      </div>
      <div style="padding: 20px; max-height: 400px; overflow-y: auto;">
        <?php if (empty($systemNotifications) && empty($upcomingDeadlines)): ?>
          <p style="text-align: center; color: #666;">Không có thông báo hoặc deadline mới.</p>
        <?php else: ?>
          <?php foreach ($systemNotifications as $noti): ?>
            <div style="padding: 12px; border-left: 4px solid <?php echo ($noti['type'] ?? '') === 'event' ? '#ff9800' : '#2196f3'; ?>; background: #f9f9f9; margin-bottom: 15px; border-radius: 4px;">
              <h4 style="margin: 0 0 5px 0; color: #333; font-size: 16px;"><?php echo dashH($noti['title'] ?? 'Thông báo'); ?></h4>
              <span style="font-size: 12px; color: #888; display: block; margin-bottom: 8px;"><?php echo dashH(dashDateTime($noti['created_at'] ?? null)); ?></span>
              <p style="margin: 0; color: #555; font-size: 14px;"><?php echo nl2br(dashH($noti['content'] ?? '')); ?></p>
            </div>
          <?php endforeach; ?>
          <?php foreach ($upcomingDeadlines as $deadline): ?>
            <div style="padding: 12px; border-left: 4px solid #d32f2f; background: #fff8f8; margin-bottom: 15px; border-radius: 4px;">
              <h4 style="margin: 0 0 5px 0; color: #333; font-size: 16px;"><?php echo dashH($deadline['title'] ?? 'Deadline'); ?></h4>
              <span style="font-size: 12px; color: #d32f2f; display: block; margin-bottom: 8px;">Hạn: <?php echo dashH(dashDateTime($deadline['due_at'] ?? null)); ?></span>
              <p style="margin: 0; color: #555; font-size: 14px;"><?php echo nl2br(dashH($deadline['description'] ?? '')); ?></p>
            </div>
          <?php endforeach; ?>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <!-- Class Schedule Modal -->
  <div id="scheduleModal" class="modal-overlay" style="display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.6); z-index: 2000; align-items: center; justify-content: center;">
    <div class="modal-box" style="width: 95%; max-width: 800px; background: #fff; border-radius: 12px; overflow: hidden;">
      <div style="background: #333; color: #fff; padding: 15px; position: relative;">
        <h3 style="margin: 0; font-size: 18px;">Lịch học trong tuần</h3>
        <button onclick="document.getElementById('scheduleModal').style.display='none'" style="position: absolute; right: 15px; top: 15px; background: none; border: none; color: #fff; font-size: 20px; cursor: pointer;">&times;</button>
      </div>
      <div style="padding: 20px; max-height: 500px; overflow-y: auto;">
        <?php if (empty($classSchedules)): ?>
          <p style="text-align: center; color: #666;">Bạn không có lịch học tuần này.</p>
        <?php else: ?>
          <table style="width: 100%; border-collapse: collapse; text-align: left;">
            <thead>
              <tr style="background: #f1f1f1; border-bottom: 2px solid #ddd;">
                <th style="padding: 12px; color: #333;">Thứ</th>
                <th style="padding: 12px; color: #333;">Môn học</th>
                <th style="padding: 12px; color: #333;">Thời gian</th>
                <th style="padding: 12px; color: #333;">Phòng</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($classSchedules as $class): ?>
                <tr style="border-bottom: 1px solid #eee;">
                  <td style="padding: 12px; font-weight: bold; color: #007976;"><?php echo dashH(dashDayLabel($class['day_of_week'] ?? 0)); ?></td>
                  <td style="padding: 12px;"><?php echo dashH($class['subject_name'] ?? 'Chưa cập nhật'); ?></td>
                  <td style="padding: 12px; color: #555;"><?php echo dashH(date('H:i', strtotime($class['start_time'])) . ' - ' . date('H:i', strtotime($class['end_time']))); ?></td>
                  <td style="padding: 12px;"><span style="background: #e3f2fd; color: #1976d2; padding: 4px 8px; border-radius: 4px; font-size: 13px; font-weight: 500;"><?php echo dashH($class['room'] ?: 'Chưa cập nhật'); ?></span></td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        <?php endif; ?>
      </div>
    </div>
  </div>

  <script>
    function openSystemNotificationsModal() {
      document.getElementById('sysNotiModal').style.display = 'flex';
    }

    function openScheduleModal() {
      document.getElementById('scheduleModal').style.display = 'flex';
    }
    // Chat context
    window.UTH_CONTEXT = {
      userId: <?php echo json_encode((int)($_SESSION['user_id'] ?? 0)); ?>,
      studentName: <?php echo json_encode($hoTen, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      studentFirstName: <?php echo json_encode($tenGoi, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      mssv: <?php echo json_encode($mssv, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      todayDate: <?php echo json_encode(date('Y-m-d'), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      todayLabel: <?php echo json_encode(date('d/m/Y'), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      tomorrowLabel: <?php echo json_encode(date('d/m/Y', strtotime('+1 day')), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      todaySchedule: <?php echo json_encode($todaySchedule, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      tomorrowSchedule: <?php echo json_encode($tomorrowSchedule, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      todayDeadlines: <?php echo json_encode($todayDeadlines, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      tomorrowDeadlines: <?php echo json_encode($tomorrowDeadlines, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      systemNotifications: <?php echo json_encode($systemNotifications, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>
    };

    function openChatbotWithMsg(msg) {
      // Open the chatbot window
      const botWindow = document.getElementById('botWindow');
      botWindow.style.display = 'flex';

      // Wait a tiny bit for the UI to show, then trigger the message
      setTimeout(() => {
        document.getElementById('userInput').value = msg;
        if (typeof sendMessage === 'function') {
          sendMessage();
        }
      }, 100);
    }


    function expandChatbot() {
      const botWindow = document.getElementById('botWindow');
      if (botWindow.classList.contains('expanded')) {
        botWindow.classList.remove('expanded');
        botWindow.style.width = '';
        botWindow.style.height = '';
      } else {
        botWindow.classList.add('expanded');
        botWindow.style.width = '80vw';
        botWindow.style.height = '85vh';
      }
    }

    // Chat launcher
    if (document.getElementById('botLauncher')) {
      document.getElementById('botLauncher').addEventListener('click', () => {
        if (typeof toggleChatWindow === 'function') toggleChatWindow();
      });
    }

    // Toggle user menu
    function toggleUserMenu() {
      const menu = document.getElementById('userMenu');
      menu.classList.toggle('show');
    }

    function closeUserMenu() {
      document.getElementById('userMenu').classList.remove('show');
    }
    document.addEventListener('click', e => {
      if (!document.getElementById('userTrigger').contains(e.target) && !document.getElementById('userMenu').contains(e.target)) {
        closeUserMenu();
      }
    });

    function openStudentChat(id, title, content) {
      document.getElementById('modalTitle').textContent = title || 'Phản hồi từ Ban quản trị';
      document.getElementById('modalBody').textContent = content || '';
      document.getElementById('modalTicketId').value = id;
      document.getElementById('ticketModal').classList.add('active');
    }
    document.getElementById('ticketModal').addEventListener('click', e => {
      if (e.target === document.getElementById('ticketModal'))
        document.getElementById('ticketModal').classList.remove('active');
    });

    const calendarData = {
      year: <?php echo (int)$calendarYear; ?>,
      month: <?php echo (int)$calendarMonth; ?>,
      today: <?php echo json_encode(date('Y-m-d'), JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>,
      events: <?php echo json_encode($calendarEvents, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES); ?>
    };
    let calendarCursor = {
      year: calendarData.year,
      month: calendarData.month
    };

    function pad2(value) {
      return String(value).padStart(2, '0');
    }

    function dotClassForEvent(type) {
      if (type === 'deadline') return 'd2';
      if (type === 'event') return 'd3';
      return 'd1';
    }

    function renderCalendar() {
      const grid = document.getElementById('calGrid');
      const label = document.getElementById('calMonthLabel');
      if (!grid || !label) return;
      grid.innerHTML = '';
      label.textContent = `tháng ${calendarCursor.month} ${calendarCursor.year}`;

      const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

      days.forEach((d, i) => {
        const el = document.createElement('div');
        el.className = 'cal-day-name' + (i === 0 ? ' sun' : '');
        el.textContent = d;
        grid.appendChild(el);
      });

      const firstDay = new Date(calendarCursor.year, calendarCursor.month - 1, 1).getDay();
      const daysInMonth = new Date(calendarCursor.year, calendarCursor.month, 0).getDate();

      for (let i = 0; i < firstDay; i++) {
        const el = document.createElement('div');
        el.className = 'cal-cell empty';
        grid.appendChild(el);
      }

      for (let i = 1; i <= daysInMonth; i++) {
        const dateKey = `${calendarCursor.year}-${pad2(calendarCursor.month)}-${pad2(i)}`;
        const events = calendarData.events[dateKey] || [];
        const el = document.createElement('div');
        el.className = 'cal-cell';

        if (events.length > 0) {
          el.classList.add('has-event');
          el.title = events.map(item => `${item.time ? item.time + ' - ' : ''}${item.title}`).join('\n');
        }
        if (dateKey === calendarData.today) el.classList.add('today');

        const num = document.createElement('div');
        num.className = 'cal-num';
        num.textContent = i;
        el.appendChild(num);

        if (events.length > 0) {
          const dots = document.createElement('div');
          dots.className = 'cal-dots';
          [...new Set(events.map(item => dotClassForEvent(item.type)))].slice(0, 3).forEach(dotClass => {
            const dot = document.createElement('span');
            dot.className = `dot ${dotClass}`;
            dots.appendChild(dot);
          });
          el.appendChild(dots);
        }
        grid.appendChild(el);
      }
    }

    document.getElementById('calPrevBtn')?.addEventListener('click', () => {
      calendarCursor.month -= 1;
      if (calendarCursor.month < 1) {
        calendarCursor.month = 12;
        calendarCursor.year -= 1;
      }
      renderCalendar();
    });

    document.getElementById('calNextBtn')?.addEventListener('click', () => {
      calendarCursor.month += 1;
      if (calendarCursor.month > 12) {
        calendarCursor.month = 1;
        calendarCursor.year += 1;
      }
      renderCalendar();
    });

    renderCalendar();

    // Sidebar logic
    const menuBtn = document.querySelector('.menu-btn');
    const sidebar = document.getElementById('sidebar');
    const sidebarOverlay = document.getElementById('sidebarOverlay');
    const closeSidebarBtn = document.getElementById('closeSidebar');

    function toggleSidebar() {
      sidebar.classList.toggle('active');
      if (sidebar.classList.contains('active')) {
        sidebarOverlay.style.display = 'block';
        setTimeout(() => sidebarOverlay.classList.add('active'), 10);
      } else {
        sidebarOverlay.classList.remove('active');
        setTimeout(() => sidebarOverlay.style.display = 'none', 300);
      }
    }

    menuBtn.addEventListener('click', toggleSidebar);
    closeSidebarBtn.addEventListener('click', toggleSidebar);
    sidebarOverlay.addEventListener('click', toggleSidebar);

    function handleSidebarClick(msg) {
      toggleSidebar();
      openChatbotWithMsg(msg);
    }
  </script>
  <script src="../js/chatbot.js?v=<?php echo filemtime(__DIR__ . '/../js/chatbot.js'); ?>"></script>
</body>

</html>
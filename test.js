
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
  
  fetch('api_upload_avatar.php', {
    method: 'POST',
    body: formData
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      const newUrl = data.avatar_url + '?v=' + new Date().getTime();
      document.getElementById('mainDashboardAvatar').src = newUrl;
      document.getElementById('modalAvatarPreview').src = newUrl;
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


function openSystemNotificationsModal() {
  document.getElementById('sysNotiModal').style.display = 'flex';
}
function openScheduleModal() {
  document.getElementById('scheduleModal').style.display = 'flex';
}
// Chat context
window.UTH_CONTEXT = {
  studentName: "<?php echo htmlspecialchars($hoTen, ENT_QUOTES, 'UTF-8'); ?>",
  studentFirstName: "<?php echo htmlspecialchars($hoTen, ENT_QUOTES, 'UTF-8'); ?>",
  mssv: "<?php echo htmlspecialchars($mssv, ENT_QUOTES, 'UTF-8'); ?>",
  todaySchedule: <?php echo json_encode($todaySchedule); ?>,
  tomorrowSchedule: <?php echo json_encode($tomorrowSchedule); ?>
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


// Chat launcher
const botWindow = document.getElementById('botWindow');
if(document.getElementById('botLauncher')) {
  document.getElementById('botLauncher').addEventListener('click', () => {
    botWindow.style.display = botWindow.style.display === 'flex' ? 'none' : 'flex';
  });
  document.getElementById('closeChatBtn').addEventListener('click', () => botWindow.style.display = 'none');
  document.getElementById('clearChatBtn').addEventListener('click', () => {
    if (confirm('Xóa toàn bộ lịch sử?')) { localStorage.removeItem('uth_chat_history'); location.reload(); }
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
  document.getElementById('modalBody').textContent  = content || '';
  document.getElementById('modalTicketId').value    = id;
  document.getElementById('ticketModal').classList.add('active');
}
document.getElementById('ticketModal').addEventListener('click', e => {
  if (e.target === document.getElementById('ticketModal'))
    document.getElementById('ticketModal').classList.remove('active');
});

// Render static calendar
function renderStaticCalendar() {
  const grid = document.getElementById('calGrid');
  const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  
  days.forEach((d, i) => {
    const el = document.createElement('div');
    el.className = 'cal-day-name' + (i === 0 ? ' sun' : '');
    el.textContent = d;
    grid.appendChild(el);
  });
  
  for(let i=0; i<3; i++) {
    const el = document.createElement('div');
    el.className = 'cal-cell empty';
    grid.appendChild(el);
  }
  
  const eventDays = [1, 2, 3, 4, 7, 14, 15, 18, 19, 20, 21, 27, 28];
  
  for(let i=1; i<=31; i++) {
    const el = document.createElement('div');
    el.className = 'cal-cell';
    
    if (eventDays.includes(i)) el.classList.add('has-event');
    if (i === 8) el.classList.add('today');
    
    const num = document.createElement('div');
    num.className = 'cal-num';
    num.textContent = i;
    el.appendChild(num);
    
    if(eventDays.includes(i)) {
      const dots = document.createElement('div');
      dots.className = 'cal-dots';
      dots.innerHTML = '<span class="dot d1"></span>';
      if(i%2===0) dots.innerHTML += '<span class="dot d2"></span>';
      if(i%3===0) dots.innerHTML += '<span class="dot d3"></span>';
      el.appendChild(dots);
    }
    grid.appendChild(el);
  }
}
renderStaticCalendar();

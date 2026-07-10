// ==========================================
// 1. QUẢN LÝ LỊCH SỬ TRÒ CHUYỆN (SESSIONS)
// ==========================================
const CHAT_STORAGE_VERSION = '2026-07-10-navigation-fixes-v3';
const CHAT_STORAGE_VERSION_KEY = 'uth_chat_storage_version';
if (localStorage.getItem(CHAT_STORAGE_VERSION_KEY) !== CHAT_STORAGE_VERSION) {
    localStorage.removeItem('uth_chat_sessions');
    localStorage.removeItem('uth_current_session');
    localStorage.setItem(CHAT_STORAGE_VERSION_KEY, CHAT_STORAGE_VERSION);
}

function readStoredChatSessions() {
    try {
        const value = JSON.parse(localStorage.getItem('uth_chat_sessions') || '[]');
        return Array.isArray(value) ? value : [];
    } catch (e) {
        localStorage.removeItem('uth_chat_sessions');
        return [];
    }
}

let chatSessions = readStoredChatSessions();
let currentSessionId = localStorage.getItem('uth_current_session') || null;
const VOICE_AUTO_KEY = 'uth_chat_voice_auto';
const TTS_API_URL = '../api/text_to_speech.php';
let voiceAutoRead = localStorage.getItem(VOICE_AUTO_KEY) === '1';
let activeAudio = null;
let activeSpeechButton = null;
let speechRequestId = 0;

function speechSupported() {
    return typeof fetch === 'function'
        && typeof Audio !== 'undefined'
        && typeof URL !== 'undefined'
        && typeof URL.createObjectURL === 'function';
}

function setSpeechButtonState(button, isReading) {
    if (!button) return;
    button.classList.toggle('is-reading', isReading);
    button.title = isReading ? "Dừng đọc" : "Nghe câu trả lời";
    button.setAttribute('aria-label', button.title);
}

function stopSpeech() {
    speechRequestId += 1;
    if (activeAudio) {
        activeAudio.pause();
        activeAudio.currentTime = 0;
    }
    if (activeSpeechButton) {
        setSpeechButtonState(activeSpeechButton, false);
    }
    activeAudio = null;
    activeSpeechButton = null;
}

function cleanSpeechText(value) {
    const tmp = document.createElement('div');
    tmp.innerHTML = String(value || '');
    tmp.querySelectorAll('script,style').forEach(el => el.remove());
    return (tmp.innerText || tmp.textContent || '')
        .replace(/\s+/g, ' ')
        .trim();
}

async function readSpeechError(response) {
    try {
        const contentType = response.headers.get('Content-Type') || '';
        if (contentType.includes('application/json')) {
            const data = await response.json();
            return data.message || data.detail || "Không tạo được giọng nói.";
        }
        const text = await response.text();
        return text || "Không tạo được giọng nói.";
    } catch (e) {
        return "Không tạo được giọng nói.";
    }
}

async function speakText(text, button = null) {
    const clean = cleanSpeechText(text);
    if (!clean) return;
    if (!speechSupported()) {
        alert("Trình duyệt chưa hỗ trợ phát giọng nói.");
        return;
    }

    // Nếu đang phát chính đoạn audio của nút này thì dừng lại
    if (activeSpeechButton === button && activeAudio) {
        stopSpeech();
        return;
    }

    // Dừng âm thanh cũ (nếu có)
    stopSpeech();
    const requestId = ++speechRequestId;

    // Hiển thị trạng thái đang đọc
    if (button) {
        setSpeechButtonState(button, true);
        activeSpeechButton = button;
    }

    try {
        const response = await fetch(TTS_API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text: clean })
        });

        if (!response.ok) {
            throw new Error(await readSpeechError(response));
        }

        const blob = await response.blob();
        if (requestId !== speechRequestId || (button && activeSpeechButton !== button)) return;
        if (!blob.size) throw new Error("File giọng nói rỗng.");

        const audioUrl = URL.createObjectURL(blob);
        activeAudio = new Audio(audioUrl);

        const resetSpeechState = () => {
            if (activeSpeechButton === button) {
                setSpeechButtonState(button, false);
                activeSpeechButton = null;
                activeAudio = null;
            }
            URL.revokeObjectURL(audioUrl);
        };

        // Reset nút khi phát xong
        activeAudio.onended = resetSpeechState;

        activeAudio.onerror = () => {
            console.error("Lỗi khi phát audio.");
            resetSpeechState();
        };

        await activeAudio.play().catch(e => {
            console.error("Lỗi phát giọng nói:", e);
            resetSpeechState();
        });
    } catch (error) {
        console.error("Lỗi gọi API TTS (Python), chuyển sang trình đọc mặc định của trình duyệt:", error);
        
        // Fallback to native browser TTS
        if ('speechSynthesis' in window) {
            const utterance = new SpeechSynthesisUtterance(clean);
            utterance.lang = 'vi-VN';
            
            utterance.onend = () => {
                if (activeSpeechButton === button) {
                    setSpeechButtonState(button, false);
                    activeSpeechButton = null;
                }
            };
            
            utterance.onerror = (e) => {
                console.error("Lỗi TTS mặc định:", e);
                if (activeSpeechButton === button) {
                    setSpeechButtonState(button, false);
                    activeSpeechButton = null;
                }
            };
            
            window.speechSynthesis.speak(utterance);
        } else {
            if (requestId === speechRequestId && activeSpeechButton === button) {
                setSpeechButtonState(button, false);
                activeSpeechButton = null;
            }
            alert(error.message || "Không thể tải giọng nói lúc này.");
        }
    }
}

function updateVoiceToggleButton() {
    const btn = document.getElementById("voiceToggleBtn");
    if (!btn) return;

    const supported = speechSupported();
    btn.disabled = !supported;
    btn.classList.toggle('unsupported', !supported);
    btn.classList.toggle('active', voiceAutoRead);
    btn.setAttribute('aria-pressed', voiceAutoRead ? 'true' : 'false');
    btn.title = supported
        ? (voiceAutoRead ? "Tự đọc câu trả lời: bật" : "Tự đọc câu trả lời: tắt")
        : "Trình duyệt chưa hỗ trợ phát giọng nói";
}

function toggleVoiceMode() {
    if (!speechSupported()) return;
    voiceAutoRead = !voiceAutoRead;
    localStorage.setItem(VOICE_AUTO_KEY, voiceAutoRead ? '1' : '0');
    if (!voiceAutoRead) stopSpeech();
    updateVoiceToggleButton();
}

function saveSessions() {
    localStorage.setItem('uth_chat_sessions', JSON.stringify(chatSessions));
    if (currentSessionId) {
        localStorage.setItem('uth_current_session', currentSessionId);
    }
}

function startNewChat() {
    currentSessionId = "SS-" + Date.now();
    chatSessions.unshift({
        id: currentSessionId,
        dbSessionUuid: null,
        title: "Trò chuyện mới",
        messages: [],
        date: new Date().toLocaleString('vi-VN')
    });
    saveSessions();
    renderHistoryList();

    // Xóa trắng UI
    let name = window.UTH_CONTEXT ? window.UTH_CONTEXT.studentFirstName : '';
    document.getElementById("chatBody").innerHTML = `
      <div class="chat-msg bot">
        Chào ${escapeHTML(name)}! 👋 Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
      </div>
      <div class="chat-suggestions" id="chatSuggestions">
        <button class="suggestion-chip" onclick="sendQuickMessage('Cho tôi xem kết quả học tập')">Xem điểm</button>
        <button class="suggestion-chip" onclick="sendQuickMessage('Ngày mai mình có lịch học gì?')">Lịch ngày mai</button>
        <button class="suggestion-chip" onclick="sendQuickMessage('Tôi còn nợ bao nhiêu tiền học phí?')">Học phí</button>
      </div>
    `;

    // Ẩn sidebar nếu đang bật
    var sb = document.getElementById("botSidebar");
    if (sb) sb.style.display = "none";
}

function loadChatSession(id) {
    currentSessionId = id;
    saveSessions();
    const session = chatSessions.find(s => s.id === id);
    if (!session) return;

    // Render tin nhắn lên UI
    const body = document.getElementById("chatBody");
    body.innerHTML = '';
    session.messages.forEach(msg => {
        appendMessage(msg.content, msg.role, null, false, { messageId: msg.messageId || null }); // false = đừng lưu đè
    });

    // Nếu không có tin nhắn nào thì hiện lời chào
    if(session.messages.length === 0){
        let name = window.UTH_CONTEXT ? window.UTH_CONTEXT.studentFirstName : '';
        body.innerHTML = `
          <div class="chat-msg bot">
            Chào ${escapeHTML(name)}! 👋 Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
          </div>
        `;
    }

    // Ẩn sidebar
    var sb = document.getElementById("botSidebar");
    if (sb) sb.style.display = "none";
    body.scrollTop = body.scrollHeight;
}

function saveMessageToHistory(role, content, meta = {}) {
    if (!currentSessionId) {
        currentSessionId = "SS-" + Date.now();
        chatSessions.unshift({
            id: currentSessionId,
            dbSessionUuid: null,
            title: content.substring(0, 30) + "...", // Lấy tin đầu tiên làm title
            messages: [],
            date: new Date().toLocaleString('vi-VN')
        });
    }

    let session = chatSessions.find(s => s.id === currentSessionId);
    if (session) {
        if(session.messages.length === 0 && role === 'user') {
             session.title = content.substring(0, 30) + "..."; // Cập nhật title
        }
        session.messages.push({ role, content, messageId: meta.messageId || null });
        saveSessions();
        renderHistoryList();
    }
}

function renderHistoryList() {
    const list = document.getElementById("historyList");
    if (!list) return;
    list.innerHTML = '';

    if (chatSessions.length === 0) {
        list.innerHTML = '<div style="padding:15px;text-align:center;color:#888;font-size:13px;">Chưa có lịch sử trò chuyện.</div>';
        return;
    }

    chatSessions.forEach(session => {
        const div = document.createElement('div');
        div.className = 'history-item';
        div.onclick = () => loadChatSession(session.id);

        const textWrap = document.createElement('div');
        const title = document.createElement('div');
        title.className = 'history-title';
        title.textContent = session.title || 'Trò chuyện';
        const date = document.createElement('div');
        date.className = 'history-date';
        date.textContent = session.date || '';
        textWrap.appendChild(title);
        textWrap.appendChild(date);
        div.appendChild(textWrap);
        list.appendChild(div);
    });
}

function toggleHistory() {
    var sb = document.getElementById("botSidebar");
    if (sb) {
        sb.style.display = (sb.style.display === "flex") ? "none" : "flex";
        if (sb.style.display === "flex") {
            renderHistoryList();
        }
    }
}

let lastUserMessage = "";

// ==========================================
// 2. LOGIC GỬI NHẬN CHATBOT
// ==========================================
async function sendMessage() {
    var input = document.getElementById("userInput");
    var text = input.value.trim();
    if(!text) return;

    lastUserMessage = text;

    // 1. In tin nhắn user
    appendMessage(text, 'user', null, true);
    input.value = "";

    // 2. Typing indicator
    let typingId = "typing-" + Date.now();
    appendMessage("...", 'bot', typingId, false);

    // Chuẩn bị mảng history để gửi cho API
    let session = chatSessions.find(s => s.id === currentSessionId);
    let apiHistory = session ? session.messages.slice(0, -1) : []; // Bỏ qua câu hỏi vừa rồi

    try {
        const ctx = window.UTH_CONTEXT || {};
        let dbSessionUuid = session ? (session.dbSessionUuid || null) : null;
        const response = await fetch('../api/chatbot.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: text,
                sessionUuid: dbSessionUuid,
                history: apiHistory.map(m => ({role: m.role==='user'?'user':'model', text: m.content})),
                studentName: ctx.studentName || "",
                studentFirstName: ctx.studentFirstName || "",
                mssv: ctx.mssv || "",
                todayDate: ctx.todayDate || "",
                todayLabel: ctx.todayLabel || "",
                tomorrowLabel: ctx.tomorrowLabel || "",
                todaySchedule: ctx.todaySchedule || [],
                tomorrowSchedule: ctx.tomorrowSchedule || [],
                todayDeadlines: ctx.todayDeadlines || [],
                tomorrowDeadlines: ctx.tomorrowDeadlines || [],
                systemNotifications: ctx.systemNotifications || []
            })
        });

        if (!response.ok) {
            throw new Error("HTTP " + response.status);
        }
        const data = await response.json();
        let botReply = data.reply || "Mình chưa nhận được nội dung trả lời từ hệ thống.";
        let suggestions = Array.isArray(data.suggestions) ? data.suggestions : [];
        session = chatSessions.find(s => s.id === currentSessionId);
        if (session && data.sessionUuid) {
            session.dbSessionUuid = data.sessionUuid;
            saveSessions();
        }
        const botMeta = { messageId: data.messageId || null };

        let typingElement = document.getElementById(typingId);
        if(typingElement) typingElement.remove();

        // 4. BỘ LỌC TICKET
        if (botReply.includes("TICKET_TRIGGER:")) {
            let cleanReply = botReply.replace("TICKET_TRIGGER:", "").trim();
            appendMessage(cleanReply, 'bot', null, true, botMeta);
            saveMockTicket(text);
        } else {
            appendMessage(botReply, 'bot', null, true, botMeta);
        }
        renderBotSuggestions(suggestions);

    } catch (error) {
        let typingElement = document.getElementById(typingId);
        if(typingElement) typingElement.remove();
        appendMessage("Lỗi kết nối đến máy chủ AI. Bạn thử gửi lại sau vài giây nhé.", 'bot', null, false);
    }
}

function escapeHTML(value) {
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function renderBotSuggestions(suggestions) {
    document.querySelectorAll(".chat-ai-suggestions").forEach(el => el.remove());
    if (!suggestions || suggestions.length === 0) return;

    const body = document.getElementById("chatBody");
    const row = document.createElement("div");
    row.className = "chat-ai-suggestions";

    suggestions.slice(0, 4).forEach(text => {
        const btn = document.createElement("button");
        btn.className = "suggestion-chip ai-chip";
        btn.type = "button";
        btn.textContent = text;
        btn.onclick = () => sendQuickMessage(text);
        row.appendChild(btn);
    });

    body.appendChild(row);
    body.scrollTop = body.scrollHeight;
}

function appendMessage(msg, sender, id = null, save = false, meta = {}) {
    var body = document.getElementById("chatBody");
    var div = document.createElement("div");
    div.className = "chat-msg " + sender;
    if (id) div.id = id;

    div.innerHTML = sender === 'user' ? escapeHTML(msg) : msg;

    // Thêm menu tùy chọn cho tin nhắn của bot (trừ tin nhắn chào và typing)
    if (sender === 'bot' && msg !== "..." && !msg.includes('👋 Mình là')) {
        let wrapper = document.createElement("div");
        wrapper.className = "bot-msg-wrapper";
        if (id) {
           wrapper.id = id + "-wrapper";
           div.id = "";
        }
        wrapper.appendChild(div);

        let actionsRow = document.createElement("div");
        actionsRow.className = "bot-msg-actions-row";

        let q = lastUserMessage || "N/A";
        let messageId = meta.messageId || null;

        // Speak btn
        let speakBtn = document.createElement("button");
        speakBtn.className = "bot-action-icon bot-speak-btn";
        speakBtn.title = "Nghe câu trả lời";
        speakBtn.setAttribute("aria-label", "Nghe câu trả lời");
        speakBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"></polygon><path d="M15.54 8.46a5 5 0 0 1 0 7.07"></path></svg>`;
        speakBtn.onclick = () => speakText(div.innerText, speakBtn);

        // Copy btn
        let copyBtn = document.createElement("button");
        copyBtn.className = "bot-action-icon";
        copyBtn.title = "Sao chép";
        copyBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>`;
        copyBtn.onclick = () => {
            navigator.clipboard.writeText(div.innerText);
            copyBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="#007976" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>`;
            setTimeout(() => {
                copyBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>`;
            }, 2000);
        };

        // Good btn
        let goodBtn = document.createElement("button");
        goodBtn.className = "bot-action-icon";
        goodBtn.title = "Hữu ích";
        goodBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 9V5a3 3 0 0 0-3-3l-4 9v11h11.28a2 2 0 0 0 2-1.7l1.38-9a2 2 0 0 0-2-2.3zM7 22H4a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2h3"></path></svg>`;
        goodBtn.onclick = function() {
            this.style.color = "#007976";
            this.disabled = true;
            sendFeedback(messageId, 'up', 'helpful');
        };

        // Bad/Report btn
        let badBtn = document.createElement("button");
        badBtn.className = "bot-action-icon";
        badBtn.title = "Chưa chính xác";
        badBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17"></path></svg>`;
        badBtn.onclick = function() {
            sendFeedback(messageId, 'down', 'incorrect');
            reportBotMessage(this, q, msg, true, messageId);
        };

        // More menu
        let menuContainer = document.createElement("div");
        menuContainer.className = "bot-msg-menu-container";

        let moreBtn = document.createElement("button");
        moreBtn.className = "bot-action-icon";
        moreBtn.title = "Tùy chọn";
        moreBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"></circle><circle cx="12" cy="5" r="1"></circle><circle cx="12" cy="19" r="1"></circle></svg>`;

        let dropdown = document.createElement("div");
        dropdown.className = "bot-msg-dropdown";

        let reportItem = document.createElement("div");
        reportItem.className = "dropdown-item";
        reportItem.innerHTML = "Báo cáo câu trả lời sai";
        reportItem.onclick = function() {
            sendFeedback(messageId, 'down', 'incorrect');
            reportBotMessage(this, q, msg, false, messageId);
        };
        dropdown.appendChild(reportItem);

        let infoItem = document.createElement("div");
        infoItem.className = "dropdown-item";
        infoItem.innerHTML = "Về câu trả lời này";
        infoItem.onclick = function() { alert("Câu trả lời được tự động sinh ra bởi AI ChatBot UTH.\nNếu bạn bấm nghe, giọng đọc là giọng AI được tạo tự động, không phải người thật.\nDữ liệu được cung cấp độc quyền từ hệ thống UTH Portal."); };
        dropdown.appendChild(infoItem);

        moreBtn.onclick = function(e) {
            e.stopPropagation();
            document.querySelectorAll('.bot-msg-dropdown.show').forEach(el => {
                if(el !== dropdown) el.classList.remove('show');
            });
            dropdown.classList.toggle("show");
        };

        menuContainer.appendChild(moreBtn);
        menuContainer.appendChild(dropdown);

        actionsRow.appendChild(speakBtn);
        actionsRow.appendChild(copyBtn);
        actionsRow.appendChild(goodBtn);
        actionsRow.appendChild(badBtn);
        actionsRow.appendChild(menuContainer);

        wrapper.appendChild(actionsRow);
        body.appendChild(wrapper);

        if (save && voiceAutoRead) {
            speakText(div.innerText, speakBtn);
        }
    } else {
        body.appendChild(div);
    }
    body.scrollTop = body.scrollHeight;

    if (save) {
        saveMessageToHistory(sender, msg, meta);
    }
}

async function sendFeedback(messageId, rating, reasonCode) {
    if (!messageId) return;
    try {
        await fetch('../api/chat_feedback.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ messageId, rating, reasonCode })
        });
    } catch (e) {
        console.error("Lỗi lưu đánh giá", e);
    }
}

async function reportBotMessage(item, question, answer, isIcon = false, messageId = null) {
    if (isIcon) {
        item.disabled = true;
        item.style.color = "#d9534f";
    } else {
        item.style.pointerEvents = "none";
        item.innerHTML = "Đã gửi báo cáo";
        item.style.color = "#4CAF50";
    }

    try {
        await fetch('../api/report_bot.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                question: question,
                answer: answer,
                messageId: messageId,
                studentName: window.UTH_CONTEXT ? window.UTH_CONTEXT.studentName : "",
                mssv: window.UTH_CONTEXT ? window.UTH_CONTEXT.mssv : ""
            })
        });
    } catch (e) {
        console.error("Lỗi gửi báo cáo", e);
    }
}

function saveMockTicket(question) {
    let tickets = JSON.parse(sessionStorage.getItem("mock_tickets")) || [];
    let sName = (window.UTH_CONTEXT && window.UTH_CONTEXT.studentName) ? window.UTH_CONTEXT.studentName : "Sinh Viên";
    tickets.push({
        id: "TK-" + Math.floor(Math.random() * 10000),
        student: sName,
        question: question,
        status: "Chưa xử lý"
    });
    sessionStorage.setItem("mock_tickets", JSON.stringify(tickets));
}

function toggleChatWindow() {
    var w = document.getElementById("botWindow");
    w.style.display = (w.style.display === "flex") ? "none" : "flex";
    if(w.style.display === "flex") {
        // Load session hiện tại nếu có
        if(!currentSessionId && chatSessions.length > 0) {
            currentSessionId = chatSessions[0].id;
            loadChatSession(currentSessionId);
        } else if (currentSessionId) {
            loadChatSession(currentSessionId);
        } else {
            startNewChat();
        }
    }
}

function sendQuickMessage(text) {
    document.getElementById("userInput").value = text;
    var suggestions = document.getElementById("chatSuggestions");
    if(suggestions) suggestions.style.display = "none";
    sendMessage();
}

// Khởi tạo
document.addEventListener("DOMContentLoaded", () => {
    let closeBtn = document.getElementById("closeChatBtn");
    if(closeBtn) closeBtn.onclick = toggleChatWindow;

    updateVoiceToggleButton();

    // Đóng dropdown khi click ra ngoài
    document.addEventListener("click", () => {
        document.querySelectorAll('.bot-msg-dropdown.show').forEach(el => el.classList.remove('show'));
    });
});

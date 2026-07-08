// ==========================================
// 1. QUẢN LÝ LỊCH SỬ TRÒ CHUYỆN (SESSIONS)
// ==========================================
let chatSessions = JSON.parse(localStorage.getItem('uth_chat_sessions')) || [];
let currentSessionId = localStorage.getItem('uth_current_session') || null;
const VOICE_AUTO_KEY = 'uth_chat_voice_auto';
let voiceAutoRead = localStorage.getItem(VOICE_AUTO_KEY) === '1';
let activeUtterance = null;
let activeSpeechButton = null;
let activeSpeechToken = 0;

function speechSupported() {
    return 'speechSynthesis' in window && 'SpeechSynthesisUtterance' in window;
}

function setSpeechButtonState(button, isReading) {
    if (!button) return;
    button.classList.toggle('is-reading', isReading);
    button.title = isReading ? "Dừng đọc" : "Nghe câu trả lời";
    button.setAttribute('aria-label', button.title);
}

function stopSpeech() {
    activeSpeechToken++;
    if (speechSupported()) {
        window.speechSynthesis.cancel();
    }
    if (activeSpeechButton) {
        setSpeechButtonState(activeSpeechButton, false);
    }
    activeUtterance = null;
    activeSpeechButton = null;
}

function cleanSpeechText(value) {
    const tmp = document.createElement('div');
    tmp.innerHTML = String(value || '');
    tmp.querySelectorAll('script,style').forEach(el => el.remove());
    return (tmp.innerText || tmp.textContent || '')
        .replace(/\s+/g, ' ')
        .replace(/\s+([.,:;!?])/g, '$1')
        .trim();
}

function normalizeVoiceName(value) {
    return String(value || '')
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase();
}

function voiceScore(voice) {
    const name = normalizeVoiceName(voice.name);
    const lang = normalizeVoiceName(voice.lang);
    let score = 0;

    if (lang === 'vi-vn') score += 120;
    else if (lang.startsWith('vi')) score += 95;

    if (name.includes('google') && (lang.startsWith('vi') || name.includes('tieng viet') || name.includes('vietnam'))) score += 200;
    else if (name.includes('google')) score += 35;

    if (name.includes('tieng viet') || name.includes('vietnam') || name.includes('vietnamese')) score += 45;
    if (/(female|nu|linh|hoaimy|hoai my|mai|an|trang|my|vy)/i.test(name)) score += 20;
    if (voice.default) score += 5;

    return score;
}

function preferredVietnameseVoice() {
    if (!speechSupported()) return null;
    const voices = window.speechSynthesis.getVoices();
    return voices
        .map(voice => ({ voice, score: voiceScore(voice) }))
        .filter(item => item.score > 0)
        .sort((a, b) => b.score - a.score)[0]?.voice || null;
}

function speechChunks(text) {
    const maxLen = 180;
    const parts = String(text || '')
        .split(/(?<=[.!?。！？])\s+|\n+/u)
        .map(part => part.trim())
        .filter(Boolean);
    const chunks = [];

    parts.forEach(part => {
        if (part.length <= maxLen) {
            chunks.push(part);
            return;
        }
        let current = '';
        part.split(/([,;:，；：]\s*)/u).forEach(piece => {
            if (!piece) return;
            if ((current + piece).length > maxLen && current.trim()) {
                chunks.push(current.trim());
                current = piece;
            } else {
                current += piece;
            }
        });
        if (current.trim()) chunks.push(current.trim());
    });

    return chunks.length ? chunks : [text];
}

function speakNextChunk(chunks, voice, button, token, index = 0) {
    if (token !== activeSpeechToken || index >= chunks.length) {
        setSpeechButtonState(button, false);
        if (token === activeSpeechToken) {
            activeUtterance = null;
            activeSpeechButton = null;
        }
        return;
    }

    const utterance = new SpeechSynthesisUtterance(chunks[index]);
    utterance.lang = 'vi-VN';
    utterance.rate = 0.94;
    utterance.pitch = 1.04;
    utterance.volume = 1;
    if (voice) utterance.voice = voice;

    activeUtterance = utterance;
    activeSpeechButton = button;
    setSpeechButtonState(button, true);

    utterance.onend = () => speakNextChunk(chunks, voice, button, token, index + 1);
    utterance.onerror = () => {
        setSpeechButtonState(button, false);
        if (token === activeSpeechToken) {
            activeUtterance = null;
            activeSpeechButton = null;
        }
    };

    window.speechSynthesis.speak(utterance);
}

function speakText(text, button = null) {
    if (!speechSupported()) {
        alert("Trình duyệt hiện chưa hỗ trợ đọc giọng nói.");
        return;
    }

    const clean = cleanSpeechText(text);
    if (!clean) return;

    if (activeSpeechButton === button && activeUtterance) {
        stopSpeech();
        return;
    }

    stopSpeech();
    const token = activeSpeechToken;
    const voice = preferredVietnameseVoice();
    speakNextChunk(speechChunks(clean), voice, button, token, 0);
}

function updateVoiceToggleButton() {
    const btn = document.getElementById("voiceToggleBtn");
    if (!btn) return;

    const supported = speechSupported();
    const voice = preferredVietnameseVoice();
    const voiceLabel = voice ? ` • ${voice.name}` : '';
    btn.disabled = !supported;
    btn.classList.toggle('unsupported', !supported);
    btn.classList.toggle('active', supported && voiceAutoRead);
    btn.setAttribute('aria-pressed', supported && voiceAutoRead ? 'true' : 'false');
    btn.title = supported
        ? (voiceAutoRead ? `Tự đọc câu trả lời: bật${voiceLabel}` : `Tự đọc câu trả lời: tắt${voiceLabel}`)
        : "Trình duyệt chưa hỗ trợ đọc giọng nói";
}

function toggleVoiceMode() {
    if (!speechSupported()) {
        alert("Trình duyệt hiện chưa hỗ trợ đọc giọng nói.");
        return;
    }
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
        Chào ${name}! 👋 Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
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
        appendMessage(msg.content, msg.role, null, false); // false = đừng lưu đè
    });

    // Nếu không có tin nhắn nào thì hiện lời chào
    if(session.messages.length === 0){
        let name = window.UTH_CONTEXT ? window.UTH_CONTEXT.studentFirstName : '';
        body.innerHTML = `
          <div class="chat-msg bot">
            Chào ${name}! 👋 Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
          </div>
        `;
    }

    // Ẩn sidebar
    var sb = document.getElementById("botSidebar");
    if (sb) sb.style.display = "none";
    body.scrollTop = body.scrollHeight;
}

function saveMessageToHistory(role, content) {
    if (!currentSessionId) {
        currentSessionId = "SS-" + Date.now();
        chatSessions.unshift({
            id: currentSessionId,
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
        session.messages.push({ role, content });
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

        div.innerHTML = `
            <div>
                <div class="history-title">${session.title}</div>
                <div class="history-date">${session.date}</div>
            </div>
        `;
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
        const response = await fetch('api_chatbot.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: text,
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

        let typingElement = document.getElementById(typingId);
        if(typingElement) typingElement.remove();

        // 4. BỘ LỌC TICKET
        if (botReply.includes("TICKET_TRIGGER:")) {
            let cleanReply = botReply.replace("TICKET_TRIGGER:", "").trim();
            appendMessage(cleanReply, 'bot', null, true);
            saveMockTicket(text);
        } else {
            appendMessage(botReply, 'bot', null, true);
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

function appendMessage(msg, sender, id = null, save = false) {
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
        goodBtn.onclick = function() { this.style.color = "#007976"; this.disabled = true; };

        // Bad/Report btn
        let badBtn = document.createElement("button");
        badBtn.className = "bot-action-icon";
        badBtn.title = "Chưa chính xác";
        badBtn.innerHTML = `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10 15v4a3 3 0 0 0 3 3l4-9V2H5.72a2 2 0 0 0-2 1.7l-1.38 9a2 2 0 0 0 2 2.3zm7-13h2.67A2.31 2.31 0 0 1 22 4v7a2.31 2.31 0 0 1-2.33 2H17"></path></svg>`;
        badBtn.onclick = function() { reportBotMessage(this, q, msg, true); };

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
        reportItem.onclick = function() { reportBotMessage(this, q, msg); };
        dropdown.appendChild(reportItem);

        let infoItem = document.createElement("div");
        infoItem.className = "dropdown-item";
        infoItem.innerHTML = "Về câu trả lời này";
        infoItem.onclick = function() { alert("Câu trả lời được tự động sinh ra bởi AI ChatBot UTH.\nDữ liệu được cung cấp độc quyền từ hệ thống UTH Portal."); };
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
        saveMessageToHistory(sender, msg);
    }
}

async function reportBotMessage(item, question, answer, isIcon = false) {
    if (isIcon) {
        item.disabled = true;
        item.style.color = "#d9534f";
    } else {
        item.style.pointerEvents = "none";
        item.innerHTML = "Đã gửi báo cáo";
        item.style.color = "#4CAF50";
    }

    try {
        await fetch('api_report_bot.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                question: question,
                answer: answer,
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
    if (speechSupported()) {
        window.speechSynthesis.onvoiceschanged = updateVoiceToggleButton;
    }

    // Đóng dropdown khi click ra ngoài
    document.addEventListener("click", () => {
        document.querySelectorAll('.bot-msg-dropdown.show').forEach(el => el.classList.remove('show'));
    });
});

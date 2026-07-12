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
    if (button.dataset.action === 'speak') {
        button.textContent = isReading ? "Dừng đọc" : "Nghe";
    }
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
        Chào ${escapeHTML(name)}! Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
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
            Chào ${escapeHTML(name)}! Mình là <strong>ChatBot UTH</strong>. Mình có thể giúp gì cho bạn?
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

        // 4. Xử lý prefix đặc biệt từ chatbot.php
        if (botReply.startsWith('TICKET_CONFIRM:')) {
            // SV chủ động muốn tạo ticket: hiển confirm inline
            let topicText = botReply.replace('TICKET_CONFIRM:', '').trim();
            appendMessage(
                'Mình hiểu bạn muốn gửi yêu cầu hỗ trợ lên admin. Hãy xác nhận nội dung bên dưới nhé:',
                'bot', null, true, botMeta
            );
            showTicketConfirm(topicText || text);
        } else if (botReply.includes('TICKET_OFFER')) {
            // Bot không biết: gợi ý tạo ticket
            let cleanReply = botReply.replace(' TICKET_OFFER', '').trim();
            appendMessage(cleanReply, 'bot', null, true, botMeta);
            showTicketOffer(text);
        } else if (botReply.includes('TICKET_TRIGGER:')) {
            // Legacy fallback
            let cleanReply = botReply.replace('TICKET_TRIGGER:', '').trim();
            appendMessage(cleanReply, 'bot', null, true, botMeta);
            showTicketConfirm(text);
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

function stripUiIcons(value) {
    return String(value || '').replace(/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/gu, '').trim();
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

    div.innerHTML = sender === 'user' ? escapeHTML(msg) : stripUiIcons(msg);

    // Thêm thao tác cho tin nhắn của bot (trừ tin nhắn chào và typing)
    const isGreeting = String(msg || '').includes('Mình là <strong>ChatBot UTH</strong>');
    if (sender === 'bot' && msg !== "..." && !isGreeting) {
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
        speakBtn.className = "bot-action-btn bot-speak-btn";
        speakBtn.dataset.action = "speak";
        speakBtn.title = "Nghe câu trả lời";
        speakBtn.setAttribute("aria-label", "Nghe câu trả lời");
        speakBtn.textContent = "Nghe";
        speakBtn.onclick = () => speakText(div.innerText, speakBtn);

        // Copy btn
        let copyBtn = document.createElement("button");
        copyBtn.className = "bot-action-btn";
        copyBtn.title = "Sao chép";
        copyBtn.textContent = "Sao chép";
        copyBtn.onclick = () => {
            navigator.clipboard.writeText(div.innerText);
            copyBtn.textContent = "Đã chép";
            setTimeout(() => {
                copyBtn.textContent = "Sao chép";
            }, 2000);
        };

        // Good btn
        let goodBtn = document.createElement("button");
        goodBtn.className = "bot-action-btn";
        goodBtn.title = "Hữu ích";
        goodBtn.textContent = "Hữu ích";
        goodBtn.onclick = function() {
            this.style.color = "#007976";
            this.textContent = "Đã ghi nhận";
            this.disabled = true;
            sendFeedback(messageId, 'up', 'helpful');
        };

        // Bad/Report btn
        let badBtn = document.createElement("button");
        badBtn.className = "bot-action-btn";
        badBtn.title = "Chưa chính xác";
        badBtn.textContent = "Báo lỗi";
        badBtn.onclick = function() {
            sendFeedback(messageId, 'down', 'incorrect');
            reportBotMessage(this, q, msg, true, messageId);
        };

        // More menu
        let menuContainer = document.createElement("div");
        menuContainer.className = "bot-msg-menu-container";

        let moreBtn = document.createElement("button");
        moreBtn.className = "bot-action-btn";
        moreBtn.title = "Tùy chọn";
        moreBtn.textContent = "Thêm";

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

        // --- Mục Gửi yêu cầu hỗ trợ ---
        let ticketItem = document.createElement("div");
        ticketItem.className = "dropdown-item";
        ticketItem.style.cssText = "border-top: 1px solid #eee; color: #007976; font-weight: 600;";
        ticketItem.innerHTML = "Gửi yêu cầu hỗ trợ";
        ticketItem.onclick = function() {
            dropdown.classList.remove('show');
            openTicketForm(q);
        };
        dropdown.appendChild(ticketItem);

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
        item.textContent = "Đã báo lỗi";
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

// ==========================================
// TICKET SYSTEM - Tạo ticket thực vào DB
// ==========================================

/**
 * Gọi API tạo ticket vào DB, hiển thị thông báo kết quả trong chat.
 */
async function createRealTicket(subject, description) {
    try {
        const res = await fetch('../api/create_ticket.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ subject, description })
        });
        const data = await res.json();
        if (data.success) {
            appendMessage(
                `<strong>Ticket ${data.ticket_number} đã được gửi thành công!</strong><br>` +
                `Admin UTH sẽ xem xét và phản hồi sớm nhất có thể. ` +
                `Khi có phản hồi, bạn sẽ thấy thông báo ở góc phải trên cùng trang.`,
                'bot', null, true
            );
        } else {
            appendMessage(
                `Không thể tạo ticket: ${data.error || 'Lỗi hệ thống.'} Bạn vui lòng thử lại sau.`,
                'bot', null, false
            );
        }
    } catch (e) {
        appendMessage('Lỗi kết nối, không gửi được ticket. Vui lòng thử lại.', 'bot', null, false);
    }
}

/**
 * Hiển confirm inline trong chatbot khi bot gợi ý tạo ticket (SV tự yêu cầu).
 * @param {string} userQuestion - câu hỏi gốc của SV
 */
function showTicketConfirm(userQuestion) {
    const body = document.getElementById('chatBody');

    // Xóa confirm cũ nếu có
    document.querySelectorAll('.ticket-confirm-block').forEach(el => el.remove());

    const block = document.createElement('div');
    block.className = 'chat-msg bot ticket-confirm-block';
    block.style.cssText = 'border: 1.5px solid #007976; border-radius: 12px; padding: 14px 16px; background: #f0fdfc;';
    block.innerHTML = `
        <div style="margin-bottom:10px; color:#007976; font-weight:600; font-size:14px;">Gửi ticket hỗ trợ?</div>
        <div style="font-size:13px; color:#444; margin-bottom:12px; line-height:1.5;">
            Mình sẽ chuyển câu hỏi của bạn lên Ban quản trị UTH:<br>
            <em style="color:#222;">“${escapeHTML(userQuestion)}”</em>
        </div>
        <div style="display:flex; gap:10px; flex-wrap:wrap;">
            <button id="confirmTicketBtn" class="suggestion-chip" style="background:#007976; color:#fff; font-weight:600; border:none;" onclick="handleConfirmTicket()">Xác nhận gửi</button>
            <button class="suggestion-chip" style="background:#eee; color:#555;" onclick="handleCancelTicket()">Hủy</button>
        </div>
    `;
    body.appendChild(block);
    body.scrollTop = body.scrollHeight;

    // Lưu nội dung đang chờ xác nhận
    window._pendingTicketQuestion = userQuestion;
}

/**
 * Hiển nút mời tạo ticket sau khi bot trả lời không biết (insufficient_context).
 * @param {string} userQuestion
 */
function showTicketOffer(userQuestion) {
    const body = document.getElementById('chatBody');
    document.querySelectorAll('.ticket-offer-block').forEach(el => el.remove());

    const block = document.createElement('div');
    block.className = 'ticket-offer-block';
    block.style.cssText = 'display:flex; gap:8px; flex-wrap:wrap; margin-top:6px; padding: 0 4px;';
    block.innerHTML = `
        <button class="suggestion-chip ai-chip" style="border:1.5px solid #007976; color:#007976; background:#f0fdfc; font-weight:600;"
            onclick="showTicketConfirmFromOffer()">Gửi ticket hỗ trợ</button>
    `;
    body.appendChild(block);
    body.scrollTop = body.scrollHeight;
    window._pendingTicketQuestion = userQuestion;
}

function showTicketConfirmFromOffer() {
    document.querySelectorAll('.ticket-offer-block').forEach(el => el.remove());
    showTicketConfirm(window._pendingTicketQuestion || lastUserMessage);
}

async function handleConfirmTicket() {
    const question = window._pendingTicketQuestion || lastUserMessage;
    document.querySelectorAll('.ticket-confirm-block').forEach(el => el.remove());
    window._pendingTicketQuestion = null;

    appendMessage('Bạn: “' + escapeHTML(question) + '” — Đang gửi ticket...', 'bot', null, false);
    await createRealTicket(
        mb_substr_compat(question, 0, 100) || 'Yêu cầu hỗ trợ',
        question
    );
}

function handleCancelTicket() {
    document.querySelectorAll('.ticket-confirm-block').forEach(el => el.remove());
    window._pendingTicketQuestion = null;
    appendMessage('Ok, mình đã hủy. Bạn có thể hỏi lại bất kỳ lúc nào nhé!', 'bot', null, false);
}

/** Tiện ích cắt chuỗi */
function mb_substr_compat(str, start, length) {
    return Array.from(str).slice(start, start + length).join('');
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

// ==========================================
// TICKET FORM MODAL (mở từ dấu "...")
// ==========================================

/**
 * Mở form modal điền tiêu đề + nội dung ticket chi tiết.
 * @param {string} contextMessage - câu hỏi/ngữ cảnh từ cuộc trò chuyện
 */
function openTicketForm(contextMessage) {
    // Xóa modal cũ nếu có
    document.getElementById('chatbotTicketModal')?.remove();

    const overlay = document.createElement('div');
    overlay.id = 'chatbotTicketModal';
    overlay.style.cssText = `
        position:fixed; inset:0; z-index:99999;
        background:rgba(0,0,0,0.5);
        backdrop-filter:blur(4px);
        display:flex; align-items:center; justify-content:center;
        animation: ctmFadeIn .2s ease;
    `;

    overlay.innerHTML = `
        <style>
        @keyframes ctmFadeIn { from{opacity:0} to{opacity:1} }
        @keyframes ctmSlide  { from{transform:translateY(20px) scale(.97);opacity:0} to{transform:none;opacity:1} }
        #ctmBox {
            background:#fff; border-radius:18px; width:96%; max-width:480px;
            box-shadow:0 24px 64px rgba(0,0,0,.22);
            animation:ctmSlide .25s cubic-bezier(.34,1.56,.64,1);
            overflow:hidden; display:flex; flex-direction:column;
        }
        #ctmHeader {
            background:linear-gradient(135deg,#007976,#00b5ad);
            padding:18px 22px; display:flex; align-items:center; gap:12px;
        }
        #ctmHeaderText h4 {margin:0 0 2px;color:#fff;font-size:15px;font-weight:700;}
        #ctmHeaderText p  {margin:0;color:rgba(255,255,255,.8);font-size:12px;}
        #ctmCloseBtn {
            margin-left:auto;height:32px;border-radius:8px;padding:0 10px;
            background:rgba(255,255,255,.18);border:1.5px solid rgba(255,255,255,.3);
            color:#fff;cursor:pointer;display:flex;align-items:center;justify-content:center;
            transition:background .18s; flex-shrink:0;font-size:12px;font-weight:600;
        }
        #ctmCloseBtn:hover{background:rgba(255,255,255,.32);}
        #ctmBody {padding:22px;}
        .ctm-label {display:block;font-size:12px;font-weight:700;color:#555;margin-bottom:5px;text-transform:uppercase;letter-spacing:.4px;}
        .ctm-field {
            width:100%;border:1.5px solid #dce0e8;border-radius:10px;
            padding:11px 14px;font-size:14px;font-family:inherit;
            background:#fafbfc;color:#1e2329;box-sizing:border-box;
            transition:border-color .2s,box-shadow .2s;
        }
        .ctm-field:focus{outline:none;border-color:#007976;box-shadow:0 0 0 3px rgba(0,121,118,.12);background:#fff;}
        .ctm-field-group{margin-bottom:16px;}
        .ctm-hint {font-size:11.5px;color:#999;margin-top:5px;}
        #ctmFooter {
            display:flex;justify-content:flex-end;gap:10px;
            padding:14px 22px;border-top:1px solid #edf0f4;background:#fafbfc;
        }
        #ctmCancelBtn {
            padding:9px 18px;border-radius:9px;border:1.5px solid #dce0e8;
            background:#fff;color:#555;font-size:14px;cursor:pointer;
            transition:background .18s;
        }
        #ctmCancelBtn:hover{background:#f5f5f5;}
        #ctmSubmitBtn {
            padding:9px 22px;border-radius:9px;border:none;
            background:linear-gradient(135deg,#007976,#009e96);color:#fff;
            font-size:14px;font-weight:600;cursor:pointer;
            display:flex;align-items:center;gap:7px;
            box-shadow:0 2px 8px rgba(0,121,118,.3);
            transition:transform .15s,box-shadow .15s;
        }
        #ctmSubmitBtn:hover{transform:translateY(-1px);box-shadow:0 4px 14px rgba(0,121,118,.4);}
        #ctmSubmitBtn:disabled{background:#aaa;box-shadow:none;cursor:not-allowed;transform:none;}
        </style>

        <div id="ctmBox">
            <div id="ctmHeader">
                <div id="ctmHeaderText">
                    <h4>Gửi yêu cầu hỗ trợ</h4>
                    <p>Admin UTH sẽ phản hồi sớm nhất có thể</p>
                </div>
                <button id="ctmCloseBtn" onclick="document.getElementById('chatbotTicketModal').remove()">Đóng</button>
            </div>

            <div id="ctmBody">
                <div class="ctm-field-group">
                    <label class="ctm-label" for="ctmSubject">Tiêu đề yêu cầu</label>
                    <input class="ctm-field" id="ctmSubject" type="text" maxlength="150"
                        placeholder="VD: Thắc mắc về lịch thi học kỳ 1..."
                        value="${escapeHTML(contextMessage || '').substring(0, 80)}">
                    <p class="ctm-hint">Tóm tắt ngắn gọn vấn đề của bạn</p>
                </div>
                <div class="ctm-field-group">
                    <label class="ctm-label" for="ctmDesc">Mô tả chi tiết</label>
                    <textarea class="ctm-field" id="ctmDesc" rows="5"
                        placeholder="Mô tả đầy đủ vấn đề: bạn cần hỗ trợ điều gì, đã thử cách nào, thông tin liên quan (học kỳ, môn học, mã SV…)"
                    >${escapeHTML(contextMessage || '')}</textarea>
                    <p class="ctm-hint">Cung cấp càng nhiều thông tin, admin càng dễ hỗ trợ</p>
                </div>
            </div>

            <div id="ctmFooter">
                <button id="ctmCancelBtn" onclick="document.getElementById('chatbotTicketModal').remove()">Hủy</button>
                <button id="ctmSubmitBtn" onclick="submitTicketForm()">Gửi yêu cầu</button>
            </div>
        </div>
    `;

    // Đóng khi click ra ngoài
    overlay.addEventListener('click', e => {
        if (e.target === overlay) overlay.remove();
    });

    document.body.appendChild(overlay);
    setTimeout(() => document.getElementById('ctmSubject')?.focus(), 200);
}

async function submitTicketForm() {
    const subject = (document.getElementById('ctmSubject')?.value || '').trim();
    const desc    = (document.getElementById('ctmDesc')?.value || '').trim();

    if (!subject) {
        document.getElementById('ctmSubject').focus();
        document.getElementById('ctmSubject').style.borderColor = '#e53935';
        return;
    }
    if (!desc) {
        document.getElementById('ctmDesc').focus();
        document.getElementById('ctmDesc').style.borderColor = '#e53935';
        return;
    }

    const btn = document.getElementById('ctmSubmitBtn');
    btn.disabled = true;
    btn.textContent = 'Đang gửi...';

    try {
        const res = await fetch('../api/create_ticket.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ subject, description: desc })
        });
        const data = await res.json();

        document.getElementById('chatbotTicketModal')?.remove();

        if (data.success) {
            appendMessage(
                `<strong>Ticket ${data.ticket_number} đã được gửi!</strong><br>` +
                `<em style="font-size:13px;color:#555;">Tiêu đề: ${escapeHTML(subject)}</em><br><br>` +
                `Admin UTH sẽ xem xét và phản hồi sớm nhất có thể. ` +
                `Bạn sẽ thấy thông báo ở phần <strong>Thông báo ticket</strong> trên trang Portal.`,
                'bot', null, true
            );
        } else {
            appendMessage(
                `Không thể gửi ticket: ${data.error || 'Lỗi hệ thống.'} Vui lòng thử lại sau.`,
                'bot', null, false
            );
        }
    } catch (e) {
        document.getElementById('chatbotTicketModal')?.remove();
        appendMessage('Lỗi kết nối, không gửi được ticket. Vui lòng thử lại.', 'bot', null, false);
    }
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

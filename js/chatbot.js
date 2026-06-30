// Thay thế hàm sendMessage cũ
async function sendMessage() {
    var input = document.getElementById("userInput");
    var text = input.value.trim();
    if(!text) return;

    // 1. In tin nhắn của sinh viên lên màn hình
    appendMessage(text, 'user');
    input.value = "";

    // 2. Tạo hiệu ứng "Đang gõ..." (Typing indicator) để tăng UX
    let typingId = "typing-" + Date.now();
    appendMessage("...", 'bot', typingId);

    try {
        // 3. Bắn dữ liệu sang api_chatbot.php
        const response = await fetch('api_chatbot.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ message: text })
        });

        const data = await response.json();
        let botReply = data.reply;

        // Xóa hiệu ứng "Đang gõ..."
        let typingElement = document.getElementById(typingId);
        if(typingElement) typingElement.remove();

        // 4. BỘ LỌC ĐỊNH TUYẾN TICKET 
        if (botReply.includes("TICKET_TRIGGER:")) {
            // Cắt bỏ chữ TICKET_TRIGGER bị ẩn đi, chỉ in câu xin lỗi ra
            let cleanReply = botReply.replace("TICKET_TRIGGER:", "").trim();
            appendMessage(cleanReply, 'bot');
            
            // Đẩy ticket ngầm sang trang Admin (Lưu SessionStorage)
            saveMockTicket(text); 
        } else {
            // Nếu AI trả lời bình thường
            appendMessage(botReply, 'bot');
        }

    } catch (error) {
        let typingElement = document.getElementById(typingId);
        if(typingElement) typingElement.remove();
        appendMessage("Lỗi kết nối đến máy chủ AI.", 'bot');
    }
}

// Cập nhật hàm appendMessage (Thêm tham số ID để quản lý hiệu ứng gõ)
function appendMessage(msg, sender, id = null) {
    var body = document.getElementById("chatBody");
    var div = document.createElement("div");
    div.className = "chat-msg " + sender;
    if (id) div.id = id;
    div.innerHTML = msg;
    body.appendChild(div);
    body.scrollTop = body.scrollHeight; // Tự động cuộn xuống tin nhắn mới nhất
}

// Hàm lưu Ticket ảo (Giữ nguyên)
function saveMockTicket(question) {
    let tickets = JSON.parse(sessionStorage.getItem("mock_tickets")) || [];
    tickets.push({
        id: "TK-" + Math.floor(Math.random() * 10000),
        student: "Phạm Anh Tuấn (075205019210)",
        question: question,
        status: "Chưa xử lý"
    });
    sessionStorage.setItem("mock_tickets", JSON.stringify(tickets));
}

function toggleChatWindow() {
    var w = document.getElementById("botWindow");
    w.style.display = (w.style.display === "flex") ? "none" : "flex";
}

function sendQuickMessage(text) {
    document.getElementById("userInput").value = text;
    var suggestions = document.getElementById("chatSuggestions");
    if(suggestions) suggestions.style.display = "none";
    sendMessage();
}
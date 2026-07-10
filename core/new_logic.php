<?php
// Logic chatbot chính đã được chuyển sang api/chatbot.php để dùng schema v2:
// - dữ liệu cá nhân truy vấn trực tiếp database,
// - RAG chỉ qua v_active_verified_knowledge,
// - lịch sử/feedback/retrieval logs ghi vào các bảng chat_* và rag_*.
throw new RuntimeException('Use api/chatbot.php for the UTH Chatbot v2 flow.');

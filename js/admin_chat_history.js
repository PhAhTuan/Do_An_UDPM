(() => {
    'use strict';

    const state = {
        page: 1,
        totalPages: 1,
        loading: false,
        initialized: false
    };

    const els = {};

    function cacheElements() {
        els.tab = document.getElementById('tab-logs');
        els.form = document.getElementById('chatLogFilterForm');
        els.keyword = document.getElementById('chatLogKeyword');
        els.status = document.getElementById('chatLogStatus');
        els.intent = document.getElementById('chatLogIntent');
        els.fromDate = document.getElementById('chatLogFromDate');
        els.toDate = document.getElementById('chatLogToDate');
        els.tableBody = document.getElementById('chatLogTableBody');
        els.total = document.getElementById('chatLogTotal');
        els.pageInfo = document.getElementById('chatLogPageInfo');
        els.prev = document.getElementById('chatLogPrev');
        els.next = document.getElementById('chatLogNext');
        els.refresh = document.getElementById('chatLogRefresh');
        els.reset = document.getElementById('chatLogReset');
        els.modal = document.getElementById('chatSessionModal');
        els.modalTitle = document.getElementById('chatSessionModalTitle');
        els.modalStudent = document.getElementById('chatSessionModalStudent');
        els.modalMeta = document.getElementById('chatSessionModalMeta');
        els.modalMessages = document.getElementById('chatSessionMessages');
    }

    function initialize() {
        if (state.initialized) {
            return;
        }
        cacheElements();
        if (!els.tab || !els.form || !els.tableBody) {
            return;
        }

        state.initialized = true;

        els.form.addEventListener('submit', (event) => {
            event.preventDefault();
            loadSessions(1);
        });

        els.reset?.addEventListener('click', () => {
            els.form.reset();
            loadSessions(1);
        });

        els.refresh?.addEventListener('click', () => {
            loadSessions(state.page);
        });

        els.prev?.addEventListener('click', () => {
            if (state.page > 1) {
                loadSessions(state.page - 1);
            }
        });

        els.next?.addEventListener('click', () => {
            if (state.page < state.totalPages) {
                loadSessions(state.page + 1);
            }
        });

        els.tableBody.addEventListener('click', (event) => {
            const button = event.target.closest('[data-chat-session-id]');
            if (!button) {
                return;
            }
            const sessionId = Number(button.dataset.chatSessionId);
            if (Number.isInteger(sessionId) && sessionId > 0) {
                openSession(sessionId);
            }
        });

        document.querySelectorAll('[data-close-chat-session-modal]').forEach((button) => {
            button.addEventListener('click', closeSessionModal);
        });

        document.addEventListener('keydown', (event) => {
            if (event.key === 'Escape' && els.modal?.classList.contains('active')) {
                closeSessionModal();
            }
        });

        if (els.tab.classList.contains('active')) {
            loadSessions(1);
        }
    }

    async function loadSessions(page = 1) {
        initialize();
        if (!state.initialized || state.loading) {
            return;
        }

        state.loading = true;
        state.page = Math.max(1, page);
        renderLoadingRows();
        setFilterDisabled(true);

        const params = new URLSearchParams({
            page: String(state.page),
            limit: '20'
        });

        addParam(params, 'q', els.keyword?.value);
        addParam(params, 'status', els.status?.value);
        addParam(params, 'intent', els.intent?.value);
        addParam(params, 'from_date', els.fromDate?.value);
        addParam(params, 'to_date', els.toDate?.value);

        try {
            const response = await fetch(`../api/get_chat_sessions.php?${params.toString()}`, {
                method: 'GET',
                credentials: 'same-origin',
                headers: { Accept: 'application/json' }
            });
            const data = await readJson(response);
            if (!response.ok || !data.success) {
                throw new Error(data.message || 'Không thể tải lịch sử trò chuyện.');
            }

            state.page = Number(data.pagination?.page || 1);
            state.totalPages = Number(data.pagination?.totalPages || 1);
            renderSessions(Array.isArray(data.sessions) ? data.sessions : []);
            renderPagination(data.pagination || {});
        } catch (error) {
            renderTableError(error instanceof Error ? error.message : 'Đã xảy ra lỗi.');
            renderPagination({ page: 1, totalPages: 1, total: 0 });
        } finally {
            state.loading = false;
            setFilterDisabled(false);
        }
    }

    async function openSession(sessionId) {
        if (!els.modal || !els.modalMessages) {
            return;
        }

        els.modal.classList.add('active');
        document.body.classList.add('chat-log-modal-open');
        els.modalTitle.textContent = 'Chi tiết cuộc trò chuyện';
        els.modalStudent.textContent = '';
        els.modalMeta.innerHTML = '';
        els.modalMessages.innerHTML = '<div class="chat-log-loading">Đang tải nội dung phiên chat...</div>';

        try {
            const response = await fetch(
                `../api/get_chat_session_messages.php?session_id=${encodeURIComponent(sessionId)}`,
                {
                    method: 'GET',
                    credentials: 'same-origin',
                    headers: { Accept: 'application/json' }
                }
            );
            const data = await readJson(response);
            if (!response.ok || !data.success) {
                throw new Error(data.message || 'Không thể tải nội dung phiên chat.');
            }
            renderSessionDetail(data.session || {}, Array.isArray(data.messages) ? data.messages : []);
        } catch (error) {
            els.modalMessages.innerHTML = `<div class="chat-log-error">${escapeHtml(
                error instanceof Error ? error.message : 'Đã xảy ra lỗi.'
            )}</div>`;
        }
    }

    function closeSessionModal() {
        els.modal?.classList.remove('active');
        document.body.classList.remove('chat-log-modal-open');
    }

    function renderSessions(sessions) {
        if (!sessions.length) {
            els.tableBody.innerHTML = `
                <tr>
                    <td colspan="8" class="chat-log-empty">Không tìm thấy phiên trò chuyện phù hợp.</td>
                </tr>
            `;
            return;
        }

        els.tableBody.innerHTML = sessions.map((session, index) => {
            const displayName = session.full_name || session.username || 'Không xác định';
            const studentCode = session.student_code || session.username || '—';
            const title = session.title || 'Phiên trò chuyện không có tiêu đề';
            const messageCount = Number(session.message_count || 0);
            const rowNumber = (state.page - 1) * 20 + index + 1;
            const lastMessage = truncate(stripHtml(session.last_message || ''), 100);
            const status = statusMeta(session.status);
            const intent = session.last_intent || '—';
            const feedbackCount = Number(session.feedback_count || 0);

            return `
                <tr>
                    <td>${rowNumber}</td>
                    <td>
                        <strong>${escapeHtml(displayName)}</strong>
                        <div class="chat-log-secondary">MSSV: ${escapeHtml(studentCode)}</div>
                    </td>
                    <td class="chat-log-title-cell">
                        <div class="chat-log-session-title">${escapeHtml(title)}</div>
                        ${lastMessage ? `<div class="chat-log-secondary">${escapeHtml(lastMessage)}</div>` : ''}
                    </td>
                    <td>
                        <strong>${messageCount}</strong>
                        <div class="chat-log-secondary">${Number(session.user_message_count || 0)} hỏi / ${Number(session.assistant_message_count || 0)} đáp</div>
                    </td>
                    <td><span class="chat-log-status ${status.className}">${status.label}</span></td>
                    <td>
                        <span class="chat-log-intent">${escapeHtml(intent)}</span>
                        ${feedbackCount > 0 ? `<div class="chat-log-feedback">${feedbackCount} feedback</div>` : ''}
                    </td>
                    <td>${escapeHtml(formatDateTime(session.last_activity_at || session.started_at))}</td>
                    <td>
                        <button type="button" class="btn btn-outline btn-sm" data-chat-session-id="${Number(session.id)}">
                            Xem chi tiết
                        </button>
                    </td>
                </tr>
            `;
        }).join('');
    }

    function renderSessionDetail(session, messages) {
        const displayName = session.full_name || session.username || 'Không xác định';
        const studentCode = session.student_code || session.username || '—';
        const status = statusMeta(session.status);

        els.modalTitle.textContent = session.title || 'Chi tiết cuộc trò chuyện';
        els.modalStudent.textContent = `${displayName} — ${studentCode}`;
        els.modalMeta.innerHTML = `
            <span>Trạng thái: <strong>${escapeHtml(status.label)}</strong></span>
            <span>Bắt đầu: <strong>${escapeHtml(formatDateTime(session.started_at))}</strong></span>
            <span>Hoạt động gần nhất: <strong>${escapeHtml(formatDateTime(session.last_activity_at))}</strong></span>
            <span>Số tin nhắn: <strong>${messages.length}</strong></span>
        `;

        if (!messages.length) {
            els.modalMessages.innerHTML = '<div class="chat-log-empty">Phiên chat chưa có tin nhắn.</div>';
            return;
        }

        els.modalMessages.innerHTML = messages.map((message) => {
            const sender = senderMeta(message.sender_type);
            const content = stripHtml(message.content || '');
            const meta = [];
            meta.push(formatDateTime(message.created_at));
            if (message.detected_intent) meta.push(`Intent: ${message.detected_intent}`);
            if (message.answer_status && message.sender_type === 'assistant') meta.push(`Trạng thái: ${message.answer_status}`);
            if (message.latency_ms) meta.push(`${message.latency_ms} ms`);
            if (message.feedback_rating) meta.push(`Feedback: ${message.feedback_rating}`);

            return `
                <article class="chat-log-message ${sender.className}">
                    <div class="chat-log-message-sender">${escapeHtml(sender.label)}</div>
                    <div class="chat-log-message-content">${escapeHtml(content)}</div>
                    <div class="chat-log-message-meta">${meta.map((item) => `<span>${escapeHtml(item)}</span>`).join('')}</div>
                </article>
            `;
        }).join('');

        requestAnimationFrame(() => {
            els.modalMessages.scrollTop = 0;
        });
    }

    function renderPagination(pagination) {
        const total = Number(pagination.total || 0);
        const page = Number(pagination.page || 1);
        const totalPages = Math.max(1, Number(pagination.totalPages || 1));
        state.page = page;
        state.totalPages = totalPages;

        if (els.total) els.total.textContent = `${total} phiên chat`;
        if (els.pageInfo) els.pageInfo.textContent = `Trang ${page}/${totalPages}`;
        if (els.prev) els.prev.disabled = page <= 1;
        if (els.next) els.next.disabled = page >= totalPages;
    }

    function renderLoadingRows() {
        els.tableBody.innerHTML = `
            <tr>
                <td colspan="8" class="chat-log-loading">Đang tải lịch sử trò chuyện...</td>
            </tr>
        `;
    }

    function renderTableError(message) {
        els.tableBody.innerHTML = `
            <tr>
                <td colspan="8" class="chat-log-error">${escapeHtml(message)}</td>
            </tr>
        `;
    }

    function setFilterDisabled(disabled) {
        els.form?.querySelectorAll('input, select, button').forEach((element) => {
            element.disabled = disabled;
        });
    }

    function addParam(params, key, value) {
        const normalized = String(value || '').trim();
        if (normalized !== '') params.set(key, normalized);
    }

    async function readJson(response) {
        const text = await response.text();
        try {
            return JSON.parse(text);
        } catch {
            throw new Error('Máy chủ trả về dữ liệu không hợp lệ.');
        }
    }

    function statusMeta(status) {
        switch (status) {
            case 'closed': return { label: 'Đã đóng', className: 'is-closed' };
            case 'archived': return { label: 'Đã lưu trữ', className: 'is-archived' };
            default: return { label: 'Đang hoạt động', className: 'is-active' };
        }
    }

    function senderMeta(senderType) {
        switch (senderType) {
            case 'user': return { label: 'Sinh viên', className: 'is-user' };
            case 'assistant': return { label: 'Chatbot', className: 'is-assistant' };
            case 'system': return { label: 'Hệ thống', className: 'is-system' };
            default: return { label: 'Công cụ', className: 'is-tool' };
        }
    }

    function formatDateTime(value) {
        if (!value) return '—';
        const date = new Date(String(value).replace(' ', 'T'));
        if (Number.isNaN(date.getTime())) return String(value);
        return date.toLocaleString('vi-VN', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        });
    }

    function stripHtml(value) {
        const documentNode = new DOMParser().parseFromString(String(value || ''), 'text/html');
        return documentNode.body.textContent || '';
    }

    function truncate(value, maxLength) {
        return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
    }

    function escapeHtml(value) {
        return String(value ?? '')
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&#039;');
    }

    window.uthChatHistory = { initialize, loadSessions };
    document.addEventListener('DOMContentLoaded', initialize);
})();

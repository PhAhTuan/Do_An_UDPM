window.onload = function() {
    let tickets = JSON.parse(sessionStorage.getItem("mock_tickets")) || [];
    let tbody = document.getElementById("ticketTableBody");
    
    tickets.forEach(tk => {
        let tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${tk.id}</td>
            <td>${tk.student}</td>
            <td>${tk.question}</td>
            <td><span class="badge pending">${tk.status}</span></td>
            <td><button class="btn-action" onclick="resolveTicket('${tk.id}', this)">Xử lý Ticket</button></td>
        `;
        tbody.insertBefore(tr, tbody.firstChild);
    });
}

function resolveTicket(id, btn) {
    alert("Đã xử lý ticket " + id + " thành công!");
    let row = btn.closest("tr");
    row.querySelector(".badge").className = "badge success";
    row.querySelector(".badge").innerText = "Đã xử lý";
    btn.remove();
}
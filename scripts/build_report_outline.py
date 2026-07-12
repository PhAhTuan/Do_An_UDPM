from docx import Document
from docx.enum.section import WD_SECTION
from docx.enum.style import WD_STYLE_TYPE
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH, WD_BREAK, WD_LINE_SPACING
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Cm, Inches, Pt, RGBColor


OUT = "/Users/tanhiep/Desktop/Do_An_UDPM/output/docs/de-cuong-muc-luc-bao-cao-chatbot.docx"

NAVY = "1F4E79"
BLUE = "2F75B5"
LIGHT_BLUE = "D9EAF7"
PALE_BLUE = "EEF5FB"
GREY = "666666"
LIGHT_GREY = "F2F4F7"
DARK = "222222"


def set_cell_shading(cell, fill):
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = tc_pr.find(qn("w:shd"))
    if shd is None:
        shd = OxmlElement("w:shd")
        tc_pr.append(shd)
    shd.set(qn("w:fill"), fill)


def set_cell_border(cell, **kwargs):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    borders = tc_pr.first_child_found_in("w:tcBorders")
    if borders is None:
        borders = OxmlElement("w:tcBorders")
        tc_pr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        if edge in kwargs:
            edge_data = kwargs.get(edge)
            tag = "w:{}".format(edge)
            element = borders.find(qn(tag))
            if element is None:
                element = OxmlElement(tag)
                borders.append(element)
            for key in ["val", "sz", "space", "color"]:
                if key in edge_data:
                    element.set(qn("w:{}".format(key)), str(edge_data[key]))


def set_cell_margins(cell, top=110, start=120, bottom=110, end=120):
    tc = cell._tc
    tc_pr = tc.get_or_add_tcPr()
    tc_mar = tc_pr.first_child_found_in("w:tcMar")
    if tc_mar is None:
        tc_mar = OxmlElement("w:tcMar")
        tc_pr.append(tc_mar)
    for m, value in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tc_mar.find(qn("w:" + m))
        if node is None:
            node = OxmlElement("w:" + m)
            tc_mar.append(node)
        node.set(qn("w:w"), str(value))
        node.set(qn("w:type"), "dxa")


def set_repeat_table_header(row):
    tr_pr = row._tr.get_or_add_trPr()
    tbl_header = OxmlElement("w:tblHeader")
    tbl_header.set(qn("w:val"), "true")
    tr_pr.append(tbl_header)


def set_table_widths(table, widths_cm):
    table.autofit = False
    for row in table.rows:
        for idx, width in enumerate(widths_cm):
            cell = row.cells[idx]
            cell.width = Cm(width)
            tc_pr = cell._tc.get_or_add_tcPr()
            tc_w = tc_pr.find(qn("w:tcW"))
            if tc_w is None:
                tc_w = OxmlElement("w:tcW")
                tc_pr.append(tc_w)
            tc_w.set(qn("w:w"), str(int(width * 567)))
            tc_w.set(qn("w:type"), "dxa")
    tbl = table._tbl
    tbl_pr = tbl.tblPr
    tbl_w = tbl_pr.find(qn("w:tblW"))
    if tbl_w is None:
        tbl_w = OxmlElement("w:tblW")
        tbl_pr.append(tbl_w)
    tbl_w.set(qn("w:w"), str(int(sum(widths_cm) * 567)))
    tbl_w.set(qn("w:type"), "dxa")


def add_page_number(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = paragraph.add_run()
    fld_char1 = OxmlElement("w:fldChar")
    fld_char1.set(qn("w:fldCharType"), "begin")
    instr_text = OxmlElement("w:instrText")
    instr_text.set(qn("xml:space"), "preserve")
    instr_text.text = " PAGE "
    fld_char2 = OxmlElement("w:fldChar")
    fld_char2.set(qn("w:fldCharType"), "end")
    run._r.append(fld_char1)
    run._r.append(instr_text)
    run._r.append(fld_char2)
    run.font.name = "Times New Roman"
    run.font.size = Pt(10)
    run.font.color.rgb = RGBColor.from_string(GREY)


def set_repeat_header_font(run):
    run.font.name = "Times New Roman"
    run._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")


def add_run(paragraph, text, bold=False, italic=False, color=DARK, size=13):
    run = paragraph.add_run(text)
    run.bold = bold
    run.italic = italic
    run.font.name = "Times New Roman"
    run._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")
    run.font.size = Pt(size)
    run.font.color.rgb = RGBColor.from_string(color)
    return run


def add_body(doc, text, bold_prefix=None):
    p = doc.add_paragraph(style="Normal")
    p.paragraph_format.first_line_indent = Cm(0.7)
    p.paragraph_format.space_after = Pt(5)
    p.paragraph_format.line_spacing = 1.22
    if bold_prefix and text.startswith(bold_prefix):
        add_run(p, bold_prefix, bold=True)
        add_run(p, text[len(bold_prefix):])
    else:
        add_run(p, text)
    return p


def add_bullet(doc, text, level=0):
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.left_indent = Cm(0.7 + level * 0.55)
    p.paragraph_format.first_line_indent = Cm(-0.35)
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.line_spacing = 1.16
    add_run(p, text, size=12.5)
    return p


def add_outline_item(doc, number, title, level=1, note=None):
    style = {1: "Heading 1", 2: "Heading 2", 3: "Heading 3"}[level]
    p = doc.add_paragraph(style=style)
    p.paragraph_format.keep_with_next = True
    if level == 1:
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(4)
    elif level == 2:
        p.paragraph_format.space_before = Pt(5)
        p.paragraph_format.space_after = Pt(2)
    else:
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(1)
    label = f"{number}. {title}" if title else number
    add_run(p, label, bold=(level == 1), size={1: 14, 2: 13, 3: 12.5}[level])
    if note:
        q = doc.add_paragraph(style="Outline Note")
        q.paragraph_format.left_indent = Cm(1.35 + (level - 1) * 0.55)
        q.paragraph_format.space_after = Pt(3)
        add_run(q, "Dự kiến: ", bold=True, color=BLUE, size=11.5)
        add_run(q, note, color=GREY, size=11.5)
    return p


def add_separator(doc):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(3)
    pPr = p._p.get_or_add_pPr()
    pBdr = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "8")
    bottom.set(qn("w:space"), "1")
    bottom.set(qn("w:color"), LIGHT_BLUE)
    pBdr.append(bottom)
    pPr.append(pBdr)


def setup_styles(doc):
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Times New Roman"
    normal._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")
    normal.font.size = Pt(13)
    normal.font.color.rgb = RGBColor.from_string(DARK)
    normal.paragraph_format.line_spacing = 1.22
    normal.paragraph_format.space_after = Pt(5)

    for name, size, color, before, after in [
        ("Heading 1", 14, NAVY, 10, 4),
        ("Heading 2", 13, BLUE, 5, 2),
        ("Heading 3", 12.5, DARK, 2, 1),
    ]:
        s = styles[name]
        s.font.name = "Times New Roman"
        s._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")
        s.font.size = Pt(size)
        s.font.bold = True
        s.font.color.rgb = RGBColor.from_string(color)
        s.paragraph_format.space_before = Pt(before)
        s.paragraph_format.space_after = Pt(after)
        s.paragraph_format.keep_with_next = True

    if "Outline Note" not in styles:
        s = styles.add_style("Outline Note", WD_STYLE_TYPE.PARAGRAPH)
    else:
        s = styles["Outline Note"]
    s.font.name = "Times New Roman"
    s._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")
    s.font.size = Pt(11.5)
    s.font.italic = True
    s.font.color.rgb = RGBColor.from_string(GREY)
    s.paragraph_format.line_spacing = 1.08

    # Use real list numbering for the short approval checklist.
    bullet = styles["List Bullet"]
    bullet.font.name = "Times New Roman"
    bullet._element.rPr.rFonts.set(qn("w:eastAsia"), "Times New Roman")
    bullet.font.size = Pt(12.5)


def add_title(doc, text, subtitle=None):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(12)
    add_run(p, text, bold=True, color=NAVY, size=16)
    if subtitle:
        q = doc.add_paragraph()
        q.alignment = WD_ALIGN_PARAGRAPH.CENTER
        q.paragraph_format.space_after = Pt(14)
        add_run(q, subtitle, italic=True, color=GREY, size=11.5)


def add_table(doc, headers, rows, widths_cm, header_fill=NAVY):
    table = doc.add_table(rows=1, cols=len(headers))
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    table.style = "Table Grid"
    set_table_widths(table, widths_cm)
    header = table.rows[0]
    set_repeat_table_header(header)
    for i, text in enumerate(headers):
        cell = header.cells[i]
        cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
        set_cell_shading(cell, header_fill)
        set_cell_margins(cell)
        set_cell_border(cell, top={"val": "single", "sz": 6, "color": header_fill}, bottom={"val": "single", "sz": 6, "color": header_fill}, left={"val": "single", "sz": 4, "color": "FFFFFF"}, right={"val": "single", "sz": 4, "color": "FFFFFF"})
        p = cell.paragraphs[0]
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(0)
        r = add_run(p, text, bold=True, color="FFFFFF", size=11.5)
        set_repeat_header_font(r)
    for ridx, row in enumerate(rows):
        cells = table.add_row().cells
        for i, value in enumerate(row):
            cell = cells[i]
            cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
            set_cell_margins(cell, top=105, bottom=105)
            set_cell_shading(cell, "FFFFFF" if ridx % 2 == 0 else PALE_BLUE)
            set_cell_border(cell, top={"val": "single", "sz": 3, "color": "D9E2F3"}, bottom={"val": "single", "sz": 3, "color": "D9E2F3"}, left={"val": "single", "sz": 3, "color": "D9E2F3"}, right={"val": "single", "sz": 3, "color": "D9E2F3"})
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            p.paragraph_format.line_spacing = 1.08
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT if i else WD_ALIGN_PARAGRAPH.CENTER
            add_run(p, str(value), size=11.2)
    doc.add_paragraph().paragraph_format.space_after = Pt(2)
    return table


def add_cover(doc):
    sec = doc.sections[0]
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(12)
    add_run(p, "ĐẠI HỌC GIAO THÔNG VẬN TẢI TP. HỒ CHÍ MINH", bold=True, color=DARK, size=14)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(12)
    add_run(p, "VIỆN CÔNG NGHỆ THÔNG TIN VÀ KỸ THUẬT ĐIỆN TỬ", bold=True, color=DARK, size=13)
    add_separator(doc)
    for _ in range(2):
        doc.add_paragraph().paragraph_format.space_after = Pt(12)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(p, "ĐỀ CƯƠNG CHI TIẾT BÁO CÁO", bold=True, color=NAVY, size=21)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(24)
    add_run(p, "BẢN DỰ THẢO ĐỂ DUYỆT MỤC LỤC", bold=True, color=BLUE, size=14)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after = Pt(8)
    add_run(p, "Đề tài", bold=True, color=DARK, size=14)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(36)
    add_run(p, "HỆ THỐNG CHATBOT THÔNG TIN SINH VIÊN", bold=True, color="C00000", size=17)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(4)
    add_run(p, "Môn: Công nghệ phần mềm", size=13)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_after = Pt(18)
    add_run(p, "GVHD: Lê Văn Quốc Anh", size=13)
    rows = [
        ("Ngô Trương Tín", "087206003569"),
        ("Nguyễn Hồng Đông", "089206016594"),
        ("Nguyễn Tấn Hiệp", "087205010642"),
        ("Phạm Anh Tuấn", "036206024969"),
    ]
    add_table(doc, ["Thành viên nhóm", "MSSV"], rows, [8.0, 5.0], header_fill=BLUE)
    for _ in range(2):
        doc.add_paragraph().paragraph_format.space_after = Pt(10)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(p, "Tài liệu này chỉ dùng để duyệt cấu trúc báo cáo; nội dung chi tiết và số trang sẽ được cập nhật sau.", italic=True, color=GREY, size=11)
    doc.add_page_break()


def build():
    doc = Document()
    sec = doc.sections[0]
    sec.page_width = Cm(21)
    sec.page_height = Cm(29.7)
    sec.top_margin = Cm(2.2)
    sec.bottom_margin = Cm(2.0)
    sec.left_margin = Cm(2.5)
    sec.right_margin = Cm(2.0)
    sec.header_distance = Cm(1.0)
    sec.footer_distance = Cm(1.0)
    setup_styles(doc)

    # Header/footer: clean, restrained, consistent with the existing report.
    header = sec.header.paragraphs[0]
    header.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    add_run(header, "ĐỀ CƯƠNG BÁO CÁO - HỆ THỐNG CHATBOT THÔNG TIN SINH VIÊN", color=GREY, size=9)
    footer = sec.footer.paragraphs[0]
    add_page_number(footer)

    add_cover(doc)

    add_title(doc, "HƯỚNG DẪN DUYỆT ĐỀ CƯƠNG", "Phạm vi của file này: duyệt cấu trúc trước khi triển khai nội dung")
    add_body(doc, "Bản đề cương được xây dựng dựa trên báo cáo hiện có trong main.pdf và mã nguồn hiện tại của dự án. Các mục đã có trong báo cáo cũ được giữ lại, đồng thời bổ sung các phần còn thiếu để báo cáo mô tả được đầy đủ quá trình phân tích, thiết kế, cài đặt, kiểm thử và đánh giá hệ thống.")
    add_bullet(doc, "Nếu bạn đồng ý với cấu trúc này, chỉ cần nhắn: “Duyệt mục lục”. Sau đó mình sẽ bắt đầu viết nội dung theo từng chương.")
    add_bullet(doc, "Nếu muốn thay đổi, bạn có thể ghi rõ mục cần thêm, xóa, đổi tên hoặc đổi thứ tự; số trang sẽ chỉ được chốt sau khi nội dung và hình minh họa hoàn thành.")
    add_bullet(doc, "Trong bước viết nội dung, các sơ đồ, ảnh giao diện, luồng xử lý, API, cơ sở dữ liệu và kết quả kiểm thử sẽ được đối chiếu với dự án thực tế.")
    add_separator(doc)
    add_title(doc, "MỤC LỤC ĐỀ XUẤT", "Bố cục chi tiết dự kiến cho báo cáo hoàn chỉnh")

    front = [
        ("PHẦN MỞ ĐẦU", "Các phần giới thiệu trước nội dung chính của báo cáo."),
        ("Lời cảm ơn", "Giữ lại nội dung hiện có và hiệu chỉnh cho thống nhất tên đề tài."),
        ("Tóm tắt đồ án", "Tóm tắt bài toán, giải pháp, công nghệ, kết quả và giới hạn."),
        ("Mục lục", "Cập nhật tự động sau khi hoàn thiện nội dung."),
        ("Danh mục hình", "Liệt kê các sơ đồ UML, kiến trúc, giao diện và kết quả minh họa."),
        ("Danh mục bảng", "Liệt kê các bảng yêu cầu, dữ liệu, ca kiểm thử và kết quả."),
        ("Danh mục từ viết tắt", "AI, API, FAQ, RAG, TTS, UML, DB, CRUD và các thuật ngữ sử dụng trong báo cáo."),
    ]
    add_table(doc, ["Phần", "Nội dung dự kiến"], front, [5.0, 11.8], header_fill=NAVY)
    # Keep the actual chapter outline together on a fresh page instead of leaving
    # a single chapter heading at the bottom of the front-matter page.
    doc.add_page_break()

    outline = [
        ("CHƯƠNG 1", "TỔNG QUAN VÀ KIẾN TRÚC HỆ THỐNG", 1, "Giới thiệu bài toán, mục tiêu, phạm vi và kiến trúc tổng thể."),
        ("1.1", "Đặt vấn đề và bối cảnh thực tế", 2, "Nhu cầu tra cứu thông tin sinh viên và hạn chế của phương thức tư vấn thủ công."),
        ("1.2", "Mục tiêu đề tài", 2, "Xác định mục tiêu tổng quát và các mục tiêu cụ thể cần đạt."),
        ("1.2.1", "Mục tiêu tổng quát", 3, "Xây dựng hệ thống chatbot hỗ trợ sinh viên trực tuyến."),
        ("1.2.2", "Mục tiêu cụ thể", 3, "Chatbot, kho tri thức, quản trị, phản hồi/ticket, lịch sử và TTS."),
        ("1.3", "Đối tượng sử dụng, phạm vi và giới hạn", 2, "Mô tả sinh viên, Admin/Staff/Knowledge Reviewer và các chức năng ngoài phạm vi."),
        ("1.3.1", "Đối tượng sử dụng", 3, "Vai trò, nhu cầu và quyền hạn của từng nhóm người dùng."),
        ("1.3.2", "Phạm vi chức năng", 3, "Chat, tra cứu thông tin, lịch sử, feedback/ticket và quản trị."),
        ("1.3.3", "Giới hạn của đề tài", 3, "Các hệ thống ngoài phạm vi tích hợp và các giới hạn dữ liệu/triển khai."),
        ("1.4", "Quy trình nghiệp vụ tổng quát", 2, "Luồng sinh viên đặt câu hỏi, báo lỗi/tạo ticket và luồng Admin xử lý."),
        ("1.4.1", "Luồng sinh viên đặt câu hỏi", 3, "Từ đăng nhập, nhập câu hỏi, nhận câu trả lời đến lưu lịch sử."),
        ("1.4.2", "Luồng báo lỗi và yêu cầu hỗ trợ", 3, "Feedback, tạo ticket, trao đổi và cập nhật trạng thái."),
        ("1.4.3", "Luồng Admin quản lý tri thức", 3, "Tiếp nhận phản hồi, cập nhật FAQ/knowledge và theo dõi kết quả."),
        ("1.5", "Kiến trúc hệ thống", 2, "Trình bày kiến trúc 3 tầng và các thành phần giao tiếp với nhau."),
        ("1.5.1", "Kiến trúc ba tầng", 3, "Presentation, Business Logic và Data Layer."),
        ("1.5.2", "Các thành phần chính và cách giao tiếp", 3, "Frontend, PHP API, MySQL, AI/RAG và TTS service."),
        ("1.5.3", "Luồng xử lý câu hỏi bằng AI/RAG", 3, "Chuẩn hóa câu hỏi, truy xuất knowledge, tạo câu trả lời và fallback."),
        ("1.5.4", "Luồng chuyển văn bản thành giọng nói", 3, "Frontend gọi proxy PHP, proxy gọi FastAPI/gTTS và trả audio/mpeg."),
        ("1.6", "Công nghệ và môi trường triển khai", 2, "Mô tả công nghệ sử dụng và vai trò của từng thành phần."),
        ("1.6.1", "Frontend: HTML, CSS và JavaScript", 3, "Giao diện sinh viên, giao diện Admin và các tương tác phía trình duyệt."),
        ("1.6.2", "Backend/API: PHP", 3, "Xác thực, nghiệp vụ, API chatbot, feedback, ticket và proxy TTS."),
        ("1.6.3", "Cơ sở dữ liệu MySQL", 3, "Lưu tài khoản, hồ sơ, knowledge, chat, feedback và ticket."),
        ("1.6.4", "AI/RAG và kho tri thức", 3, "Kết hợp dữ liệu nội bộ với mô hình AI để tăng tính phù hợp của câu trả lời."),
        ("1.6.5", "FastAPI và gTTS", 3, "Microservice tạo âm thanh tiếng Việt, tách khỏi backend PHP."),
        ("1.7", "Kết luận chương 1", 2, "Tóm tắt bài toán và cơ sở để chuyển sang phân tích, thiết kế."),

        ("CHƯƠNG 2", "PHÂN TÍCH YÊU CẦU VÀ THIẾT KẾ HỆ THỐNG", 1, "Đặc tả yêu cầu và xây dựng các mô hình UML, dữ liệu."),
        ("2.1", "Khảo sát và xác định yêu cầu", 2, "Từ nhu cầu thực tế suy ra yêu cầu chức năng và phi chức năng."),
        ("2.2", "Xác định tác nhân và quyền hạn", 2, "Sinh viên, Admin, Staff/Knowledge Reviewer và quyền truy cập tương ứng."),
        ("2.3", "Yêu cầu chức năng", 2, "Liệt kê chức năng theo từng phân hệ."),
        ("2.3.1", "Đăng nhập và phân quyền", 3, "Xác thực tài khoản, session, vai trò và chuyển hướng giao diện."),
        ("2.3.2", "Trò chuyện với Chatbot", 3, "Gửi câu hỏi, nhận câu trả lời, TTS và lưu lịch sử."),
        ("2.3.3", "Lịch sử, đánh giá và báo lỗi", 3, "Xem lịch sử, đánh giá câu trả lời và báo lỗi."),
        ("2.3.4", "Ticket hỗ trợ", 3, "Tạo ticket, trao đổi, cập nhật trạng thái và đóng ticket."),
        ("2.3.5", "Chức năng quản trị", 3, "Quản lý tài khoản, knowledge/FAQ, phản hồi, ticket và Dashboard."),
        ("2.4", "Yêu cầu phi chức năng", 2, "Bảo mật, hiệu năng, độ ổn định, khả năng sử dụng và bảo trì."),
        ("2.5", "Sơ đồ Use Case", 2, "Use Case tổng quát và các Use Case theo từng nhóm chức năng."),
        ("2.5.1", "Sơ đồ Use Case tổng quát", 3, "Quan hệ giữa tác nhân và các nhóm chức năng chính."),
        ("2.5.2", "Use Case của Sinh viên", 3, "Tài khoản, chatbot, lịch sử, feedback, ticket và cài đặt."),
        ("2.5.3", "Use Case của Admin", 3, "Tài khoản, knowledge, ticket/phản hồi và thống kê."),
        ("2.6", "Đặc tả chi tiết các Use Case tiêu biểu", 2, "Mục tiêu, tác nhân, tiền điều kiện, luồng chính, luồng phụ và ngoại lệ."),
        ("2.6.1", "Đăng nhập hệ thống (UC-00)", 3, "Đặc tả xác thực và phân quyền."),
        ("2.6.2", "Trò chuyện với Bot (UC-01)", 3, "Đặc tả truy vấn, truy xuất knowledge, trả lời và TTS."),
        ("2.6.3", "Đánh giá/báo lỗi và tạo ticket", 3, "Đặc tả feedback, báo lỗi và yêu cầu hỗ trợ."),
        ("2.6.4", "Quản lý knowledge/FAQ", 3, "Đặc tả thêm, sửa, xóa, duyệt và tìm kiếm dữ liệu tri thức."),
        ("2.6.5", "Quản trị người dùng và ticket", 3, "Đặc tả các thao tác của Admin."),
        ("2.7", "Sơ đồ hoạt động", 2, "Mô tả trình tự xử lý theo thời gian và các nhánh điều kiện."),
        ("2.7.1", "Luồng Sinh viên trò chuyện với Bot", 3, "Từ nhập câu hỏi đến nhận câu trả lời và lưu lịch sử."),
        ("2.7.2", "Luồng báo lỗi/tạo ticket", 3, "Từ đánh giá câu trả lời đến xử lý yêu cầu hỗ trợ."),
        ("2.7.3", "Luồng Admin xử lý hệ thống", 3, "Xem, cập nhật và hoàn tất phản hồi/ticket."),
        ("2.8", "Lược đồ lớp (Class Diagram)", 2, "Các lớp User, Student, Admin, Chatbot, Message, Knowledge/FAQ, Feedback, Ticket và TTS."),
        ("2.9", "Sơ đồ tuần tự (Sequence Diagram)", 2, "Trao đổi thông điệp giữa người dùng, giao diện, API, AI, TTS và cơ sở dữ liệu."),
        ("2.9.1", "Sequence Diagram - Trò chuyện với Bot", 3, "Luồng xử lý truy vấn và trả lời."),
        ("2.9.2", "Sequence Diagram - Phát âm thanh TTS", 3, "Luồng gọi service và nhận file âm thanh."),
        ("2.9.3", "Sequence Diagram - Feedback/Ticket", 3, "Luồng gửi phản hồi và tạo yêu cầu hỗ trợ."),
        ("2.9.4", "Sequence Diagram - Admin xử lý", 3, "Luồng Admin cập nhật knowledge và ticket."),
        ("2.10", "Sơ đồ thực thể - mối quan hệ và thiết kế dữ liệu", 2, "ERD, bảng dữ liệu, khóa và quan hệ."),
        ("2.10.1", "Các bảng dữ liệu chính", 3, "Users/Student, knowledge/FAQ, chat, feedback, tickets và ticket_messages."),
        ("2.10.2", "Mối quan hệ và ràng buộc dữ liệu", 3, "Khóa chính, khóa ngoại, trạng thái và các ràng buộc nghiệp vụ."),
        ("2.11", "Kết luận chương 2", 2, "Tóm tắt thiết kế làm cơ sở cho cài đặt."),

        ("CHƯƠNG 3", "CÀI ĐẶT VÀ TRIỂN KHAI HỆ THỐNG", 1, "Giải thích cách hiện thực hệ thống từ mã nguồn thực tế."),
        ("3.1", "Cấu trúc mã nguồn và phân chia module", 2, "views, api, core, css, js, tts và database."),
        ("3.2", "Môi trường cài đặt và khởi chạy", 2, "PHP/MAMP hoặc WAMP, MySQL, Python, FastAPI và cấu hình biến môi trường."),
        ("3.3", "Cài đặt cơ sở dữ liệu", 2, "Import schema, dữ liệu mẫu và các bảng nghiệp vụ."),
        ("3.3.1", "Kết nối cơ sở dữ liệu và cấu hình", 3, "PDO, .env, cổng MySQL và xử lý lỗi kết nối."),
        ("3.3.2", "Tài khoản và hồ sơ sinh viên", 3, "Đăng nhập, mật khẩu băm, session và thông tin cá nhân."),
        ("3.3.3", "Knowledge/FAQ và truy xuất dữ liệu", 3, "Dữ liệu nguồn, trạng thái duyệt và dữ liệu dùng cho RAG."),
        ("3.3.4", "Chat, feedback và ticket", 3, "Lưu phiên chat, tin nhắn, đánh giá và trao đổi hỗ trợ."),
        ("3.4", "Cài đặt xác thực và phân quyền", 2, "Kiểm tra session, vai trò và bảo vệ các endpoint/giao diện."),
        ("3.5", "Cài đặt module Chatbot AI/RAG", 2, "Phân tích câu hỏi và sinh câu trả lời theo dữ liệu hệ thống."),
        ("3.5.1", "Chuẩn hóa văn bản tiếng Việt", 3, "Loại dấu, chuẩn hóa khoảng trắng, token và từ dừng."),
        ("3.5.2", "Nhận diện ngữ cảnh và thực thể", 3, "Học kỳ, năm học, ngày và thông tin liên quan đến câu hỏi."),
        ("3.5.3", "Truy xuất và xếp hạng knowledge/FAQ", 3, "Tính điểm phù hợp, ưu tiên bằng chứng liên quan và giảm trả lời nhầm."),
        ("3.5.4", "Sinh câu trả lời bằng AI", 3, "Kết hợp dữ liệu truy xuất, ngữ cảnh sinh viên và mô hình AI."),
        ("3.5.5", "Fallback khi không đủ dữ liệu", 3, "Thông báo giới hạn, gợi ý hỏi lại hoặc chuyển sang ticket."),
        ("3.5.6", "Lưu lịch sử và phản hồi", 3, "Ghi nhận phiên chat, message, rating và retrieval log."),
        ("3.6", "Cài đặt module Text-to-Speech", 2, "Tách service Python khỏi backend PHP và phát âm thanh ở frontend."),
        ("3.6.1", "FastAPI/gTTS service", 3, "Endpoint health và endpoint tạo MP3 tiếng Việt."),
        ("3.6.2", "PHP proxy cùng nguồn", 3, "Kiểm tra dữ liệu, gọi service và trả về audio/mpeg."),
        ("3.6.3", "Phát audio ở giao diện Chatbot", 3, "Blob audio, chống phát nhầm phản hồi cũ và xử lý lỗi."),
        ("3.7", "Cài đặt phân hệ Sinh viên", 2, "Dashboard, chatbot, lịch sử, hồ sơ, feedback và ticket."),
        ("3.8", "Cài đặt phân hệ Admin", 2, "Dashboard, quản lý knowledge, người dùng, feedback và ticket."),
        ("3.9", "Bảo mật và xử lý lỗi", 2, "Băm mật khẩu, prepared statement, kiểm tra quyền, giới hạn input và log lỗi."),
        ("3.10", "Triển khai hệ thống trong môi trường cục bộ", 2, "Cấu hình virtual host/localhost, database và TTS service."),
        ("3.11", "Kết luận chương 3", 2, "Tóm tắt các module đã hiện thực."),

        ("CHƯƠNG 4", "KIỂM THỬ VÀ ĐÁNH GIÁ HỆ THỐNG", 1, "Chứng minh hệ thống hoạt động đúng qua ca kiểm thử và luồng thực tế."),
        ("4.1", "Mục tiêu, phạm vi và phương pháp kiểm thử", 2, "Xác định loại kiểm thử, tiêu chí đạt và dữ liệu kiểm thử."),
        ("4.2", "Môi trường và dữ liệu kiểm thử", 2, "localhost, PHP/MySQL, trình duyệt, tài khoản mẫu và dữ liệu knowledge."),
        ("4.3", "Kiểm thử chức năng", 2, "Bảng test case, kết quả mong đợi, kết quả thực tế và trạng thái."),
        ("4.3.1", "Đăng nhập và phân quyền", 3, "Đúng/sai mật khẩu, tài khoản bị khóa và chuyển đúng giao diện."),
        ("4.3.2", "Truy vấn Chatbot và FAQ/RAG", 3, "Câu hỏi đại diện theo học vụ, học phí, lịch thi và quy chế."),
        ("4.3.3", "Câu hỏi gần giống và câu hỏi ngoài phạm vi", 3, "Đánh giá khả năng tránh trả lời nhầm và fallback."),
        ("4.3.4", "Lịch sử, feedback và ticket", 3, "Lưu, xem, phản hồi, trao đổi và cập nhật trạng thái."),
        ("4.3.5", "Quản trị knowledge và người dùng", 3, "Thêm/sửa/xóa/tìm kiếm và kiểm tra quyền Admin."),
        ("4.3.6", "Text-to-Speech", 3, "Kiểm tra HTTP, content-type audio/mpeg, MP3 và phát ở trình duyệt."),
        ("4.4", "Kiểm thử tích hợp và End-to-End", 2, "Theo dõi toàn bộ luồng từ giao diện đến API, database, AI và TTS."),
        ("4.5", "Kiểm thử giao diện và phân quyền", 2, "Kiểm tra hiển thị, thao tác và không truy cập chéo giữa các vai trò."),
        ("4.6", "Kiểm thử lỗi và độ ổn định", 2, "Database lỗi, TTS chưa chạy, input rỗng, timeout và dữ liệu bất thường."),
        ("4.7", "Kết quả, nhận xét và vấn đề còn tồn tại", 2, "Tổng hợp tỷ lệ đạt, lỗi phát hiện và hướng xử lý."),
        ("4.8", "Kết luận chương 4", 2, "Đánh giá mức đáp ứng của hệ thống so với yêu cầu."),

        ("CHƯƠNG 5", "KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN", 1, "Tổng kết kết quả, giới hạn và khả năng mở rộng."),
        ("5.1", "Kết quả đạt được", 2, "Đối chiếu kết quả với mục tiêu và yêu cầu ban đầu."),
        ("5.2", "Hạn chế của hệ thống", 2, "Phụ thuộc dữ liệu knowledge, AI/TTS, bảo mật và phạm vi triển khai."),
        ("5.3", "Hướng phát triển", 2, "Mở rộng dữ liệu, cải thiện RAG, monitoring, triển khai production và đa ngôn ngữ."),
        ("5.4", "Kết luận chung", 2, "Khẳng định giá trị ứng dụng và bài học của nhóm."),

        ("TÀI LIỆU THAM KHẢO", "", 1, "Liệt kê các nguồn được trích dẫn trong báo cáo."),
        ("PHỤ LỤC", "", 1, "Đặt các nội dung chi tiết, ảnh chụp và bảng dữ liệu ở cuối báo cáo."),
        ("Phụ lục A", "Hướng dẫn cài đặt và khởi chạy hệ thống", 2, "Các bước chuẩn bị database, web server và TTS service."),
        ("Phụ lục B", "Danh sách API và tham số chính", 2, "Bảng endpoint, phương thức, input, output và quyền truy cập."),
        ("Phụ lục C", "Bộ dữ liệu và ca kiểm thử chi tiết", 2, "Các câu hỏi mẫu, kết quả mong đợi và ảnh chụp minh chứng."),
        ("Phụ lục D", "Ảnh giao diện hệ thống", 2, "Đăng nhập, dashboard sinh viên, chatbot, ticket và Admin."),
        ("Phụ lục E", "Các sơ đồ và hình minh họa khổ lớn", 2, "Đưa các hình khó đọc khi đặt trong phần nội dung chính."),
    ]
    for number, title, level, note in outline:
        add_outline_item(doc, number, title, level, note)

    add_title(doc, "ĐỊNH HƯỚNG NỘI DUNG SAU KHI DUYỆT", "Các minh chứng sẽ được đưa vào khi viết báo cáo")
    rows = [
        ("Chương 1", "Tổng quan, bài toán, phạm vi, kiến trúc 3 tầng, AI/RAG và TTS.", "Sơ đồ kiến trúc, luồng dữ liệu và bảng công nghệ."),
        ("Chương 2", "Yêu cầu, Use Case, Activity, Class, Sequence và ERD.", "Các sơ đồ UML/ERD đã có và các sơ đồ bổ sung cho ticket/TTS."),
        ("Chương 3", "Cách cài đặt theo mã nguồn thực tế: PHP, MySQL, JavaScript, FastAPI/gTTS.", "Ảnh cấu trúc thư mục, đoạn mã minh họa, ảnh giao diện và luồng API."),
        ("Chương 4", "Kiểm thử trên môi trường localhost với tài khoản và dữ liệu mẫu.", "Bảng test case, ảnh kết quả, log/API response và nhận xét."),
        ("Chương 5", "Kết quả, hạn chế, bài học và hướng phát triển.", "Đối chiếu mục tiêu với kết quả đạt được."),
    ]
    add_table(doc, ["Phần", "Nội dung sẽ viết", "Minh chứng dự kiến"], rows, [2.6, 7.1, 7.1], header_fill=BLUE)
    add_body(doc, "Nguyên tắc triển khai nội dung: viết đúng theo hệ thống đang chạy và mã nguồn hiện tại; không mô tả chức năng chưa có minh chứng. Khi cần, các tên bảng, endpoint, cổng dịch vụ và kết quả kiểm thử sẽ được kiểm tra lại trước khi đưa vào báo cáo chính thức.")
    add_separator(doc)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(p, "Mời bạn duyệt hoặc ghi chú các mục cần chỉnh sửa trước khi mình bắt đầu viết nội dung.", bold=True, color=NAVY, size=13)

    doc.core_properties.title = "Đề cương chi tiết báo cáo - Hệ thống Chatbot Thông tin Sinh viên"
    doc.core_properties.subject = "Mục lục dự thảo để duyệt"
    doc.core_properties.author = "Nhóm thực hiện"
    doc.save(OUT)
    print(OUT)


if __name__ == "__main__":
    build()

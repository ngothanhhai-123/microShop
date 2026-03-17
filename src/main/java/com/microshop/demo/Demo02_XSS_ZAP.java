package com.microshop.demo;
import jakarta.servlet.http.*;
//ZAP sẽ gửi payload <script>alert(1)</script> qua tham số search và thấy nó phản hồi ngay trên trình duyệt.v
public class Demo02_XSS_ZAP extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        try {
            String query = req.getParameter("search");
            resp.setContentType("text/html");
            // LỖI: In trực tiếp input chưa qua mã hóa ra HTML
            resp.getWriter().println("<h1>Kết quả tìm kiếm cho: " + query + "</h1>");
        } catch (Exception e) {}
    }
}
package com.microshop.demo;
import jakarta.servlet.http.*;
//ZAP sẽ phát hiện việc trang web in ra toàn bộ cấu trúc thư mục hoặc lỗi SQL (Stack trace) khi có ngoại lệ
public class Demo06_InfoExposure_ZAP extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        try {
            int a = 1 / 0; // Cố tình gây lỗi chia cho 0
        } catch (Exception e) {
            try {
                // LỖI: In toàn bộ Stack Trace ra trình duyệt cho người dùng (và Hacker) xem
                e.printStackTrace(resp.getWriter());
            } catch (Exception ex) {}
        }
    }
}
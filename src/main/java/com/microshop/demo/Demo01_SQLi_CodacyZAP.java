package com.microshop.demo;
import java.sql.*;
import jakarta.servlet.http.*;
//ZAP sẽ bắn payload vào tham số username trên URL, còn Codacy sẽ phát hiện luồng dữ liệu đi thẳng vào executeQuery.
public class Demo01_SQLi_CodacyZAP extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        try {
            String username = req.getParameter("username");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/microshop", "root", "");
            Statement st = conn.createStatement();
            // LỖI: Nối chuỗi SQL kinh điển
            st.executeQuery("SELECT * FROM nguoi_dung WHERE ten_dang_nhap = '" + username + "'");
        } catch (Exception e) {}
    }
}
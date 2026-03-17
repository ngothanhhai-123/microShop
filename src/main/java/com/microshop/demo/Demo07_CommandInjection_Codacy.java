package com.microshop.demo;
import jakarta.servlet.http.*;
//Codacy sẽ bắt lỗi cho phép người dùng thực thi lệnh hệ thống (OS Command).
public class Demo07_CommandInjection_Codacy extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        try {
            String domain = req.getParameter("domain");
            // LỖI: Truyền dữ liệu trực tiếp vào bash/cmd của máy chủ hệ điều hành
            Runtime.getRuntime().exec("ping -c 4 " + domain);
        } catch (Exception e) {}
    }
}
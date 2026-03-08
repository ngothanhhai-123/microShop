package com.microshop.filter;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
// ok
@WebFilter(urlPatterns = {"/profile/*", "/payment/*"})
public class AuthenticationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession();

        Object user = session.getAttribute("user");

        if (user == null) {
            // Lưu lại trang người dùng muốn truy cập (để quay lại sau khi login)
            if (session.getAttribute("redirectAfterLogin") == null) {
                String redirectAfterLogin = req.getRequestURI();
                if (req.getQueryString() != null) {
                    redirectAfterLogin += "?" + req.getQueryString();
                }
                session.setAttribute("redirectAfterLogin", redirectAfterLogin);
            }

            // Kiểm tra nếu người dùng đang vào trang thanh toán
            String requestURI = req.getRequestURI();
            if (requestURI.contains("/payment")) {
                // Chuyển hướng kèm thông báo chỉ dành cho thanh toán
                res.sendRedirect(req.getContextPath() + "/login?from=payment");
            } else {
                // Các trang khác chỉ chuyển hướng về login bình thường
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        // Nếu đã đăng nhập thì cho qua
        chain.doFilter(request, response);
    }
}

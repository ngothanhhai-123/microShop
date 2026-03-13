Các bước cần có để thực hiện quá trình kiểm duyệt tự động (DAST) bằng công cụ OWASP-ZAP:

Bước 1: 
- Đặt file Dockerfile (không có đuôi mở rộng) tại thư mục gốc của dự án (ngang hàng với các thư mục database, src, target, uploads...).
- Tạo thư mục .github/workflows/ tại thư mục gốc. Sau đó, đặt 2 file kịch bản dast.yml (quét baseline) và dast_full.yml (quét chuyên sâu) vào trong thư mục này.
Bước 2: Khởi tạo Git cục bộ (Local Repository)
- Nếu thư mục dự án của bạn chưa được quản lý bởi Git, hãy mở Terminal tại thư mục đó và chạy lệnh:
        git init
Bước 3: Kết nối với GitHub (Remote Repository):
- Đăng nhập vào GitHub và tạo một Repository mới (đặt tên theo dự án của bạn).
- Kết nối mã nguồn trên máy tính của bạn với Repo trên GitHub bằng lệnh:
        git remote add origin https://github.com/ten-tai-khoan-cua-ban/ten-repo.git
Bước 4: Tạo nhánh làm việc và đẩy mã nguồn (Push Code)
- Thông thường, để an toàn và dễ kiểm soát lỗi phát sinh, không nên làm việc trên nhánh main -> tạo 1 nhánh mới và đẩy lên theo các lệnh sau:
        git checkout -b ten_nhanh_cua_ban
        git add .
        git commit -m "Cấu hình quy trình quét DAST tự động bằng ZAP"
        git push -u origin ten_nhanh_cua_ban
Bước 5: Kiểm tra quá trình hoạt động
- Sau khi lệnh push thành công, hãy truy cập vào Repository của bạn trên trình duyệt web GitHub. Chuyển sang tab Actions, bạn sẽ thấy các tiến trình (workflows) của OWASP ZAP đang được tự động kích hoạt và chạy kiểm duyệt.

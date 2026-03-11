import os, sys, subprocess, platform

RED, GREEN, YELLOW, CYAN, WHITE, RESET = "\033[91m", "\033[92m", "\033[93m", "\033[96m", "\033[97m", "\033[0m"

print(f"{CYAN}====================================================================={RESET}")
print(f"{GREEN}Tool scan full source sử dụng GitLeaks + PMD + SpotBugs{RESET}")
print(f"{YELLOW}Chịu trách nhiệm: Nguyễn Hải Hưng - Học viện Công nghệ BCVT{RESET}")
print(f"{CYAN}====================================================================={RESET}\n")

is_win = os.name == 'nt'
gitleaks_bin = "gitleaks.exe" if is_win else "./gitleaks"
mvn_bin = "mvnw.cmd" if is_win else "./mvnw"

print(f"{WHITE}[*] Kiểm tra môi trường...{RESET}")
if not os.path.exists(gitleaks_bin.replace("./", "")) or not os.path.exists(mvn_bin.replace("./", "")):
    print(f"{YELLOW}[WARNING]{RESET} Thiếu công cụ GitLeaks hoặc Maven. Đang gọi setup-env.py để phục hồi...")
    subprocess.run([sys.executable, "setup-env.py"])
    if not os.path.exists(gitleaks_bin.replace("./", "")):
        print(f"{RED}[ERROR]{RESET} Phục hồi thất bại. Không tìm thấy Gitleaks.")
        sys.exit(1)
else:
    print(f"{CYAN}[INFO]{RESET} Môi trường đã sẵn sàng.")

# Tao thu muc audit-reports
os.makedirs("audit-reports", exist_ok=True)

print(f"\n{CYAN}====================================================================={RESET}")
print(f"{WHITE}[*] GitLeaks - full source & history{RESET}")
print(f"{CYAN}====================================================================={RESET}")
subprocess.run([gitleaks_bin, "detect", "--source", ".", "-f", "json", "-r", "audit-reports/gitleaks-audit.json"])
print(f"{CYAN}[INFO]{RESET} Báo cáo chi tiết Gitleaks lưu tại: audit-reports/gitleaks-audit.json\n")

print(f"{CYAN}====================================================================={RESET}")
print(f"{WHITE}[*] PMD & SpotBugs - full source{RESET}")
print(f"{CYAN}====================================================================={RESET}")
print(f"{CYAN}[INFO]{RESET} Đang thực hiện quét, quá trình sẽ mất khoảng 15-30s...")
print(f"{CYAN}[INFO]{RESET} Let's go grab a coffee!")

# Chay Maven va redirect log
log_path = os.path.join("audit-reports", "maven-audit.log")
with open(log_path, "w") as log_file:
    subprocess.run([mvn_bin, "clean", "compile", "pmd:check", "spotbugs:check", "-P", "audit-mode"], stdout=log_file, stderr=subprocess.STDOUT)

# Doc file log de boc tach Dashboard
with open(log_path, "r", encoding="utf-8") as f:
    log_content = f.readlines()

build_success = any("BUILD SUCCESS" in line for line in log_content)

if build_success:
    print(f"\n{CYAN}[TỔNG KẾT MAVEN BUILD]{RESET}")
    print(f"{CYAN}------------------------------------------------------------------------{RESET}")
    print(f"{GREEN}[INFO] BUILD SUCCESS{RESET}")
    print(f"{CYAN}------------------------------------------------------------------------{RESET}")
    for line in log_content:
        if "Total time:" in line or "Finished at:" in line:
            print(line.strip())

    print(f"\n{YELLOW}[KẾT QUẢ PMD]{RESET}")
    for line in log_content:
        if "You have" in line and "warnings" in line and "pmd.xml" in line:
            print(line.strip())

    print(f"\n{YELLOW}[KẾT QUẢ SPOTBUGS]{RESET}")
    for line in log_content:
        if "BugInstance size is" in line or "Error size is" in line or "Total bugs:" in line:
            print(line.strip())

    print(f"\n{CYAN}====================================================================================================={RESET}")
    print(f"{GREEN}[AUDIT SCAN THÀNH CÔNG]{RESET}")
    print(f"{WHITE}Tất cả kết quả được lưu tại thư mục: {YELLOW}audit-reports{RESET}")
    print(f"{CYAN}====================================================================================================={RESET}")
else:
    print(f"\n{CYAN}[TỔNG KẾT MAVEN BUILD]{RESET}")
    print(f"{RED}[ERROR] Maven build thất bại!{RESET}")
    print(f"{RED}[ERROR] Quá trình quét PMD/SpotBugs không thể hoàn tất.{RESET}")
    print(f"{RED}[ERROR] Vui lòng kiểm tra chi tiết tại: audit-reports/maven-audit.log{RESET}")

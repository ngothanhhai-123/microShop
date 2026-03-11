import os, sys, subprocess, platform, json, urllib.request, zipfile, tarfile

# 0. Bảng màu ANSI
RED, GREEN, YELLOW, CYAN, WHITE, RESET = "\033[91m", "\033[92m", "\033[93m", "\033[96m", "\033[97m", "\033[0m"

print(f"{CYAN}================================================================================={RESET}")
print(f"{GREEN}Tool cài đặt môi trường pha 1 (GitLeaks + PMD + SpotBugs){RESET}")
print(f"{YELLOW}Chịu trách nhiệm: Nguyễn Hải Hưng - Học viện Công nghệ Bưu chính Viễn thông{RESET}")
print(f"{CYAN}================================================================================={RESET}\n")

# 1. Check Git
try:
    git_ver = subprocess.check_output(["git", "--version"], text=True).strip()
    print(f"{CYAN}[INFO]{RESET} Tìm thấy [GIT]    : {git_ver} {GREEN}[OK]{RESET}")
except FileNotFoundError:
    print(f"{RED}[ERROR]{RESET} Không tìm thấy 'git'. Vui lòng cài đặt 'Git for Windows/Mac/Linux'!")
    sys.exit(1)

# 2. Check Python
if sys.version_info < (3, 9):
    print(f"{RED}[ERROR]{RESET} Python của bạn quá cũ. Vui lòng cập nhật lên Python 3.9 trở lên để chạy pre-commit!")
    sys.exit(1)
print(f"{CYAN}[INFO]{RESET} Tìm thấy [PYTHON] : Python {platform.python_version()} {GREEN}[OK]{RESET}")

# 3. Check Java
try:
    java_ver = subprocess.check_output(["java", "-version"], stderr=subprocess.STDOUT, text=True).splitlines()[0]
    print(f"{CYAN}[INFO]{RESET} Tìm thấy [JAVA]   : {java_ver} {GREEN}[OK]{RESET}")
except FileNotFoundError:
    print(f"{YELLOW}[WARNING]{RESET} Không tìm thấy 'java' trong PATH. Vui lòng kiểm tra lại!")

print()

# 4. Cai dat Pre-commit
print(f"{WHITE}[*] Cài đặt pre-commit hook{RESET}")
print(f"{CYAN}[INFO]{RESET} Cập nhật pip và cài đặt thư viện pre-commit...")
subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "pip", "pre-commit"], stdout=subprocess.DEVNULL)

print(f"{CYAN}[INFO]{RESET} Tích hợp hook vào .git/hooks...")
if subprocess.run([sys.executable, "-m", "pre_commit", "install"]).returncode == 0:
    print(f"{GREEN}[INFO]{RESET} Pre-commit đã tích hợp thành công vào Git luồng commit.")
else:
    print(f"{RED}[ERROR]{RESET} Lỗi khi cài đặt pre-commit hook!")

print()

# 5. GitLeaks Download Logic (Da nen tang)
print(f"{WHITE}[*] Cài đặt GitLeaks{RESET}")
is_win = os.name == 'nt'
gitleaks_exe = "gitleaks.exe" if is_win else "gitleaks"

# Goi GitHub API lay phien ban moi nhat
try:
    with urllib.request.urlopen('https://api.github.com/repos/gitleaks/gitleaks/releases/latest') as response:
        latest_ver = json.loads(response.read().decode())['tag_name'].lstrip('v')
except Exception as e:
    print(f"{RED}[ERROR]{RESET} Không thể kết nối đến GitHub API: {e}")
    latest_ver = None

need_download = True
if os.path.exists(gitleaks_exe) and latest_ver:
    curr_ver = subprocess.check_output([f"./{gitleaks_exe}" if not is_win else gitleaks_exe, "version"], text=True).strip()
    if latest_ver in curr_ver:
        print(f"{CYAN}[INFO]{RESET} GitLeaks: v{latest_ver} {GREEN}[OK]{RESET}")
        need_download = False
    else:
        print(f"{CYAN}[INFO]{RESET} Phát hiện phiên bản mới v{latest_ver}. Đang tiến hành cập nhật...")

if need_download and latest_ver:
    print(f"{CYAN}[INFO]{RESET} Đang tải GitLeaks v{latest_ver} từ GitHub...")
    sys_os = platform.system().lower()
    machine = platform.machine().lower()
    
    # Mapping OS architecture
    arch = "x64" if machine in ["x86_64", "amd64"] else ("arm64" if "arm" in machine or "aarch" in machine else "x86")
    ext = "zip" if is_win else "tar.gz"
    
    download_url = f"https://github.com/gitleaks/gitleaks/releases/download/v{latest_ver}/gitleaks_{latest_ver}_{sys_os}_{arch}.{ext}"
    file_name = f"gitleaks.{ext}"
    
    try:
        urllib.request.urlretrieve(download_url, file_name)
        if is_win:
            print(f"{CYAN}[INFO]{RESET} Đang giải nén Gitleaks...")
            with zipfile.ZipFile(file_name, 'r') as zip_ref:
                zip_ref.extract("gitleaks.exe")
        else:
            print(f"{CYAN}[INFO]{RESET} Đang giải nén Gitleaks...")
            with tarfile.open(file_name, 'r:gz') as tar_ref:
                tar_ref.extract("gitleaks")
            os.chmod("gitleaks", 0o755) # Cap quyen thuc thi cho Mac/Linux
        
        os.remove(file_name)
        print(f"{GREEN}[INFO]{RESET} Cài đặt GitLeaks thành công!")
    except Exception as e:
        print(f"{RED}[ERROR]{RESET} Tải GitLeaks thất bại. Vui lòng kiểm tra mạng.")

print()

# 6. Check Maven Wrapper
print(f"{WHITE}[*] Kiểm tra maven{RESET}")
mvnw_file = "mvnw.cmd" if is_win else "mvnw"
if os.path.exists(mvnw_file):
    print(f"{CYAN}[INFO]{RESET} Đã phát hiện Maven Wrapper '{mvnw_file}' {GREEN}[OK]{RESET}")
    if not is_win:
        os.chmod(mvnw_file, 0o755) # Dam bao bash script chay duoc tren Unix
else:
    print(f"{YELLOW}[WARNING]{RESET} Không tìm thấy {mvnw_file}")

print(f"\n{CYAN}================================================================================={RESET}")
print(f"{GREEN}                        HOÀN TẤT THIẾT LẬP MÔI TRƯỜNG!{RESET}")
print(f"{CYAN}================================================================================={RESET}")
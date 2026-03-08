@echo off
setlocal EnableDelayedExpansion

:: =================================================================================
:: 0. KHOI TAO MA MAU ANSI (Dung cho UI Console)
:: =================================================================================
for /F "delims=#" %%E in ('"prompt #$E# & for %%a in (1) do rem"') do set "ESC=%%E"
set "RED=%ESC%[91m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "CYAN=%ESC%[96m"
set "WHITE=%ESC%[97m"
set "RESET=%ESC%[0m"

echo %CYAN%=================================================================================%RESET%
echo %GREEN%        Tool cai dat moi truong pha 1 (GitLeaks + PMD + SpotBugs) %RESET%
echo %YELLOW%        Chiu trach nhiem: Nguyen Hai Hung - Hoc vien Cong nghe BCVT %RESET%
echo %CYAN%=================================================================================%RESET%
echo.

:: =================================================================================
:: 1. Check Git
:: =================================================================================
git --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo %RED%[ERROR]%RESET% Khong tim thay 'git'. Vui long cai dat 'Git for Windows'!
    pause
    exit /b 1
) ELSE (
    FOR /F "tokens=*" %%v IN ('git --version') DO echo %CYAN%[INFO]%RESET%  Tim thay [GIT]    : %%v %GREEN%[OK]%RESET%
) 
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 2. Check Python va Phien ban (Yeu cau >= 3.9)
:: =================================================================================
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo %RED%[ERROR]%RESET% Khong tim thay 'python'. Vui long kiem tra lai!
    pause
    exit /b 1
) ELSE (
    :: Luu tam chuoi phien ban vao bien PY_VER
    FOR /F "tokens=*" %%v IN ('python --version 2^>^&1') DO set "PY_VER=%%v"
    
    :: Dung chinh Python de check version cua no
    python -c "import sys; sys.exit(0 if sys.version_info >= (3,9) else 1)"
    
    :: Dung !ERRORLEVEL! vi dang kiem tra ben trong khoi lenh ELSE (...)
    IF !ERRORLEVEL! EQU 0 (
        echo %CYAN%[INFO]%RESET%  Tim thay [PYTHON] : !PY_VER! %GREEN%[OK]%RESET%
    ) ELSE (
        echo %CYAN%[INFO]%RESET%  Tim thay [PYTHON] : !PY_VER!
        echo %YELLOW%[WARN]%RESET%  Python cua ban qua cu. Vui long cap nhat len Python 3.9+ !
    )
)
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 3. Check JAVA_HOME
:: =================================================================================
IF "%JAVA_HOME%"=="" (
    echo %YELLOW%[WARN]%RESET%  Chua thiet lap bien moi truong JAVA_HOME! 
) ELSE (
    echo %CYAN%[INFO]%RESET%  Tim thay [JAVA_HOME]: %JAVA_HOME% %GREEN%[OK]%RESET%
)
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 4. Check Java va Phien ban (Yeu cau Java 21)
:: =================================================================================
java -version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo %YELLOW%[WARN]%RESET%  Khong tim thay 'java' trong PATH. Vui long kiem tra lai!
) ELSE (
    :: Dung bien dem (count) de chi lay dong dau tien thay vi dung GOTO 
    set /a j_count=0
    FOR /F "tokens=*" %%v IN ('java -version 2^>^&1') DO (
        IF !j_count! EQU 0 (
            set "JAVA_VER=%%v"
            set /a j_count=1
        )
    )

    java -version 2>&1 | findstr "21." >nul
    IF !ERRORLEVEL! EQU 0 (
        echo %CYAN%[INFO]%RESET%  Tim thay [JAVA]   : !JAVA_VER! %GREEN%[OK]%RESET%
    ) ELSE (
        echo %CYAN%[INFO]%RESET%  Tim thay [JAVA]   : !JAVA_VER!
        echo %YELLOW%[WARN]%RESET%  Du an yeu cau Java 21. Phien ban Java hien tai khong khop!
        echo         Vui long kiem tra lai bien moi truong PATH va JAVA_HOME.
    )
)
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 5. Cai dat Pre-commit Hook
:: =================================================================================
echo %WHITE%[*] Tien hanh cai dat Pre-commit hook...%RESET%
echo %CYAN%[INFO]%RESET%  Cap nhat pip...
python -m pip install --upgrade pip >nul 2>&1
echo %CYAN%[INFO]%RESET%  Cai dat thu vien pre-commit...
python -m pip install pre-commit >nul 2>&1

echo %CYAN%[INFO]%RESET%  Tich hop hook vao .git/hooks...
python -m pre_commit install
IF %ERRORLEVEL% EQU 0 (
    echo %GREEN%[OK]%RESET%    Pre-commit da tich hop thanh cong vao Git luong commit.
) ELSE (
    echo %RED%[ERROR]%RESET% Loi khi cai dat pre-commit hook!
)
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 6. Chuan bi cong cu quet thu cong (GitLeaks CLI)
:: =================================================================================
echo %WHITE%[*] Kiem tra va cai dat GitLeaks CLI...%RESET%
:: Goi GitHub API de lay phien ban on dinh moi nhat
FOR /F "tokens=*" %%v IN ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/gitleaks/gitleaks/releases/latest').tag_name.TrimStart('v')"') DO SET LATEST_VERSION=%%v

set GITLEAKS_EXE=gitleaks.exe
set NEED_DOWNLOAD=1

IF EXIST "%GITLEAKS_EXE%" (
    FOR /F "tokens=*" %%c IN ('%GITLEAKS_EXE% version') DO SET CURRENT_VERSION=%%c
    echo !CURRENT_VERSION! | findstr /C:"!LATEST_VERSION!" >nul
    IF !ERRORLEVEL! EQU 0 (
        echo %CYAN%[INFO]%RESET%  GitLeaks        : v!LATEST_VERSION! %GREEN%[OK]%RESET%
        set NEED_DOWNLOAD=0
    ) ELSE (
        echo %CYAN%[INFO]%RESET%  Phat hien phien ban moi v!LATEST_VERSION!. Dang tien hanh cap nhat...
    )
)

IF !NEED_DOWNLOAD! EQU 1 (
    echo %CYAN%[INFO]%RESET%  Dang tai GitLeaks v!LATEST_VERSION! tu GitHub...
    set DOWNLOAD_URL=https://github.com/gitleaks/gitleaks/releases/download/v!LATEST_VERSION!/gitleaks_!LATEST_VERSION!_windows_x64.zip
    powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile 'gitleaks.zip'"
    
    IF EXIST "gitleaks.zip" (
        echo %CYAN%[INFO]%RESET%  Dang giai nen Gitleaks...
        powershell -Command "Expand-Archive -Path 'gitleaks.zip' -DestinationPath '.' -Force"
        del gitleaks.zip
        echo %GREEN%[OK]%RESET%    Cai dat GitLeaks thanh cong!
    ) ELSE (
        echo %RED%[ERROR]%RESET% Tai GitLeaks that bai. Vui long kiem tra mang.
    )
)
echo %CYAN%---------------------------------------------------------------------------------%RESET%

:: =================================================================================
:: 7. Kiem tra Maven Wrapper
:: =================================================================================
echo %WHITE%[*] Kiem tra Maven Wrapper...%RESET%
IF EXIST "mvnw.cmd" (
    echo %CYAN%[INFO]%RESET%  Tim thay Maven Wrapper 'mvnw.cmd' %GREEN%[OK]%RESET%
) ELSE (
    echo %YELLOW%[WARN]%RESET%  Khong tim thay 'mvnw.cmd'. Hay dam bao ban co Maven de chay SAST.
)
echo.

echo %CYAN%=================================================================================%RESET%
echo %GREEN%                          HOAN TAT THIET LAP MOI TRUONG! %RESET%
echo %CYAN%=================================================================================%RESET%
pause

@echo off
setlocal EnableDelayedExpansion
echo =================================================================================
echo Tool cai dat moi truong pha 1 (GitLeaks + PMD + SpotBugs)
echo Chiu trach nhiem: Nguyen Hai Hung - Hoc vien Cong nghe Buu Chinh Vien Thong
echo =================================================================================

:: 1. Check Git
git --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Khong tim thay 'git'. Vui long cai dat 'Git for Windows'!
    pause
    exit /b 1
) ELSE (
    FOR /F "tokens=*" %%v IN ('git --version') DO echo [INFO] Tim thay [GIT]    : %%v [OK]
) 

:: 2. Check Python va Phien ban (Yeu cau >= 3.9)
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Khong tim thay 'python'. Vui long kiem tra lai!
    pause
    exit /b 1
) ELSE (
    :: Luu tam chuoi phien ban vao bien PY_VER
    FOR /F "tokens=*" %%v IN ('python --version 2^>^&1') DO set "PY_VER=%%v"
    
    :: Dung chinh Python de check version cua no
    python -c "import sys; sys.exit(0 if sys.version_info >= (3,9) else 1)"
    
    :: Dung !ERRORLEVEL! vi dang kiem tra ben trong khoi lenh ELSE (...)
    IF !ERRORLEVEL! EQU 0 (
        echo [INFO] Tim thay [PYTHON] : !PY_VER! [OK]
    ) ELSE (
        echo [INFO] Tim thay [PYTHON] : !PY_VER!
        echo [WARNING] Python cua ban qua cu. Vui long cap nhat len Python 3.9 tro len de chay pre-commit!
    )
)

:: 3. Check JAVA_HOME
IF "%JAVA_HOME%"=="" (
    echo [WARNING] Chua thiet lap bien moi truong JAVA_HOME! 
) ELSE (
    echo [INFO] Tim thay [JAVA_HOME]: %JAVA_HOME% [OK]
)

:: 4. Check Java va Phien ban (Yeu cau Java 21)
java -version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Khong tim thay 'java' trong PATH. Vui long kiem tra lai!
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
        echo [INFO] Tim thay [JAVA]   : !JAVA_VER! [OK]
    ) ELSE (
        echo [INFO] Tim thay [JAVA]   : !JAVA_VER!
        echo [WARNING] Du an yeu cau Java 21. Phien ban Java hien tai khong khop!
        echo           Vui long kiem tra lai bien moi truong PATH va JAVA_HOME.
    )
)

:: 5. Cai dat Pre-commit Hook
echo [*] Cai dat pre-commit hook
echo [INFO] Cap nhat pip...
python -m pip install --upgrade pip >nul 2>&1
echo [INFO] Cai dat thu vien pre-commit...
python -m pip install pre-commit >nul 2>&1

echo [INFO] Tich hop hook vao .git/hooks...
python -m pre_commit install
IF %ERRORLEVEL% EQU 0 (
    echo [INFO] Pre-commit da tich hop thanh cong vao Git luong commit.
) ELSE (
    echo [ERROR] Loi khi cai dat pre-commit hook!
)

:: 6. Chuan bi cong cu quet thu cong (GitLeaks CLI)
:: Goi GitHub API de lay phien ban on dinh moi nhat
echo [*] Cai dat GitLeaks
FOR /F "tokens=*" %%v IN ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/gitleaks/gitleaks/releases/latest').tag_name.TrimStart('v')"') DO SET LATEST_VERSION=%%v

set GITLEAKS_EXE=gitleaks.exe
set NEED_DOWNLOAD=1

IF EXIST "%GITLEAKS_EXE%" (
    FOR /F "tokens=*" %%c IN ('%GITLEAKS_EXE% version') DO SET CURRENT_VERSION=%%c
    echo !CURRENT_VERSION! | findstr /C:"!LATEST_VERSION!" >nul
    IF !ERRORLEVEL! EQU 0 (
        echo [INFO] GitLeaks: v!LATEST_VERSION! [OK]
        set NEED_DOWNLOAD=0
    ) ELSE (
        echo [INFO] Phat hien phien ban moi v!LATEST_VERSION!. Dang tien hanh cap nhat...
    )
)

IF !NEED_DOWNLOAD! EQU 1 (
    echo [INFO] Dang tai GitLeaks v!LATEST_VERSION! tu GitHub...
    set DOWNLOAD_URL=https://github.com/gitleaks/gitleaks/releases/download/v!LATEST_VERSION!/gitleaks_!LATEST_VERSION!_windows_x64.zip
    powershell -Command "Invoke-WebRequest -Uri '!DOWNLOAD_URL!' -OutFile 'gitleaks.zip'"
    
    IF EXIST "gitleaks.zip" (
        echo [INFO] Dang giai nen Gitleaks...
        powershell -Command "Expand-Archive -Path 'gitleaks.zip' -DestinationPath '.' -Force"
        del gitleaks.zip
        echo [INFO] Cai dat GitLeaks thanh cong!
    ) ELSE (
        echo [ERROR] Tai GitLeaks that bai. Vui long kiem tra mang.
    )
)

:: 7. Kiem tra Maven Wrapper
echo [*] Kiem tra maven
IF EXIST "mvnw.cmd" (
    echo [INFO] Da phat hien Maven Wrapper 'mvnw.cmd' [OK]
) ELSE (
    echo [WARNING] Khong tim thay mvnw.cmd
)
echo.

echo =================================================================================
echo                         HOAN TAT THIET LAP MOI TRUONG!
echo =================================================================================
pause
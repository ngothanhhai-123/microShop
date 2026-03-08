@echo off
setlocal EnableDelayedExpansion
echo =====================================================================
echo Tool scan full source su dung GitLeaks + PMD + SpotBugs
echo Chiu trach nhiem: Nguyen Hai Hung - Hoc vien Cong nghe BCVT
echo =====================================================================
echo.

:: Kiem tra moi truong
echo [*] Kiem tra moi truong...
set MISSING_TOOL=0
IF NOT EXIST "gitleaks.exe" set MISSING_TOOL=1
IF NOT EXIST "mvnw.cmd" set MISSING_TOOL=1

IF !MISSING_TOOL! EQU 1 (
    echo [WARNING] Thieu cong cu GitLeaks hoac Maven. Dang goi setup-env.bat de phuc hoi...
    call setup-env.bat
    :: Sau khi setup xong, kiem tra lai
    IF NOT EXIST "gitleaks.exe" (
        echo [ERROR] Phuc hoi that bai. Khong tim thay Gitleaks.
        pause
        exit /b 1
    )
) ELSE (
    echo [INFO] Moi truong da san sang.
)

echo.
echo =====================================================================
echo [*] GitLeaks - full source ^& history
echo =====================================================================
gitleaks.exe detect --source . -f json -r audit-reports\gitleaks-audit.json
echo [INFO] Bao cao chi tiet Gitleaks luu tai: audit-reports\gitleaks-audit.json

echo.
echo =====================================================================
echo [*] PMD ^& SpotBugs - full source
echo =====================================================================
echo [INFO] Dang thuc hien quet, qua trinh se mat khoang 15-30s...
echo [INFO] Let's go grab a coffee!

call mvnw.cmd clean compile pmd:check spotbugs:check -P audit-mode > audit-reports\maven-audit.log 2>&1

:: Kiem tra trang thai Build truoc tien (Fail-Fast)
findstr /C:"BUILD SUCCESS" audit-reports\maven-audit.log >nul
IF %ERRORLEVEL% EQU 0 (
    echo.
    echo [TONG KET MAVEN BUILD]
    echo [INFO] ------------------------------------------------------------------------
    echo [INFO] BUILD SUCCESS
    echo [INFO] ------------------------------------------------------------------------
    findstr /C:"Total time:" audit-reports\maven-audit.log
    findstr /C:"Finished at:" audit-reports\maven-audit.log

    echo.
    echo [KET QUA PMD]
    findstr /C:"You have" audit-reports\maven-audit.log

    echo.
    echo [KET QUA SPOTBUGS]
    findstr /C:"BugInstance size is" audit-reports\maven-audit.log
    findstr /C:"Error size is" audit-reports\maven-audit.log
    findstr /C:"Total bugs:" audit-reports\maven-audit.log

    echo.
    echo =====================================================================================================
    echo [AUDIT SCAN THANH CONG]
    echo Tat ca ket qua duoc luu tai thu muc: audit-reports
    echo =====================================================================================================
) ELSE (
    echo.
    echo [TONG KET MAVEN BUILD]
    echo [ERROR] Maven build that bai!
    echo [ERROR] Qua trinh quet PMD/SpotBugs khong the hoan tat.
    echo [ERROR] Vui long kiem tra chi tiet tai: audit-reports\maven-audit.log
)

pause

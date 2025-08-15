@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ========================================
:: Safe System Cleanup & Maintenance Tool
:: - Preview + confirm
:: - Logging
:: - Space-freed report (bytes, 64-bit via PowerShell)
:: ========================================

title Safe System Cleanup Tool

:: Log file in script folder
set "LOG_FILE=%~dp0cleanup_log.txt"
echo Cleanup Log - %date% %time% > "%LOG_FILE%"
echo ====================================== >> "%LOG_FILE%"

:: -------------------------------
:: Admin rights check (recommended)
:: -------------------------------
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo [WARNING] Best run as Administrator. Some steps may fail without elevation.
    echo.
    timeout /t 2 >nul
)

:: -------------------------------
:: MENU
:: -------------------------------
:menu
cls
echo ========================================
echo       Safe Windows System Cleanup
echo ========================================
echo.
echo [1] Temporary files only
echo [2] Temporary files + Recent items
echo [3] Full cleanup (Temp, Recent, Prefetch)
echo [4] Full cleanup + System repairs (DISM, SFC)
echo [5] Exit
echo.
choice /C 12345 /N /M "Choose an option (1-5): "
set "cleanup_level=%errorlevel%"

if "%cleanup_level%"=="5" goto :end
if "%cleanup_level%"=="1" goto :temp_only
if "%cleanup_level%"=="2" goto :temp_recent
if "%cleanup_level%"=="3" goto :full_cleanup
if "%cleanup_level%"=="4" goto :full_with_repair

goto :menu

:temp_only
call :confirm_and_clean "Temporary files" clean_temp_files
goto :completion

:temp_recent
call :confirm_and_clean "Temporary files" clean_temp_files
call :confirm_and_clean "Recent items" clean_recent_items
goto :completion

:full_cleanup
call :confirm_and_clean "Temporary files" clean_temp_files
call :confirm_and_clean "Recent items" clean_recent_items
call :confirm_and_clean "Prefetch files" clean_prefetch
goto :completion

:full_with_repair
call :confirm_and_clean "Temporary files" clean_temp_files
call :confirm_and_clean "Recent items" clean_recent_items
call :confirm_and_clean "Prefetch files" clean_prefetch
call :confirm_and_clean "System repairs" system_repairs
goto :completion

:: ========================================
:: GENERIC CONFIRM + PREVIEW WRAPPER
:: ========================================
:confirm_and_clean
set "desc=%~1"
set "func=%~2"
echo.
echo [PREVIEW] %desc%:
call :preview_%func%
echo.
choice /C YN /N /M "Proceed with cleaning %desc%? (Y/N): "
if errorlevel 2 (
    echo [SKIP] %desc%
    echo [SKIP] %desc% >> "%LOG_FILE%"
) else (
    call :%func%
)
goto :eof

:: ========================================
:: PREVIEW FUNCTIONS
:: ========================================
:preview_clean_temp_files
if exist "%TEMP%" (
    echo -- %TEMP%
    dir "%TEMP%" /a /s /b 2>nul | findstr . >nul
) else echo -- %TEMP% (not found)

if exist "C:\Windows\Temp" (
    echo -- C:\Windows\Temp
    dir "C:\Windows\Temp" /a /s /b 2>nul | findstr . >nul
) else echo -- C:\Windows\Temp (not found)

if exist "%USERPROFILE%\AppData\Local\Temp" (
    echo -- %USERPROFILE%\AppData\Local\Temp
    dir "%USERPROFILE%\AppData\Local\Temp" /a /s /b 2>nul | findstr . >nul
) else echo -- %USERPROFILE%\AppData\Local\Temp (not found)
goto :eof

:preview_clean_recent_items
if exist "%USERPROFILE%\Recent" (
    echo -- %USERPROFILE%\Recent
    dir "%USERPROFILE%\Recent" /a /s /b 2>nul | findstr . >nul
) else echo -- %USERPROFILE%\Recent (not found)
goto :eof

:preview_clean_prefetch
if exist "C:\Windows\Prefetch" (
    echo -- C:\Windows\Prefetch
    dir "C:\Windows\Prefetch" /a /s /b 2>nul | findstr . >nul
) else echo -- C:\Windows\Prefetch (not found / no access)
goto :eof

:preview_system_repairs
echo Will run:
echo   DISM /Online /Cleanup-Image /CheckHealth
echo   DISM /Online /Cleanup-Image /RestoreHealth
echo   sfc /scannow
goto :eof

:: ========================================
:: CLEANUP HELPERS
:: ========================================

:DeleteTree
set "TGT=%~1"
if not exist "%TGT%" goto :eof

:: Log a snapshot of items (pre-delete)
echo --- Listing before delete: %TGT% >> "%LOG_FILE%"
dir "%TGT%" /a /s /b 2>nul >> "%LOG_FILE%"

:: Delete files recursively
del /f /a /q "%TGT%\*" /s >nul 2>&1

:: Remove subdirectories (deepest first)
for /f "delims=" %%D in ('dir "%TGT%" /ad /b /s 2^>nul ^| sort /R') do (
    rd /s /q "%%D" 2>nul
)
goto :eof

:GetSizeDirPS
set "PSPATH=%~1"
set "%~2=0"
for /f "delims=" %%A in ('powershell -NoProfile -Command "$p='%PSPATH%'; if (Test-Path -LiteralPath $p) { (Get-ChildItem -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } else { 0 }"') do (
    set "%~2=%%A"
)
if not defined %~2 set "%~2=0"
goto :eof

:SumFreedPS_3
set "B1=%~1" & set "B2=%~2" & set "B3=%~3"
set "A1=%~4" & set "A2=%~5" & set "A3=%~6"
set "%~7=0"
for /f "delims=" %%F in ('powershell -NoProfile -Command "[int64]$b1=%B1%; [int64]$b2=%B2%; [int64]$b3=%B3%; [int64]$a1=%A1%; [int64]$a2=%A2%; [int64]$a3=%A3%; [Console]::WriteLine(($b1+$b2+$b3)-($a1+$a2+$a3))"') do (
    set "%~7=%%F"
)
goto :eof

:DiffFreedPS_1
set "BB=%~1"
set "AA=%~2"
set "%~3=0"
for /f "delims=" %%F in ('powershell -NoProfile -Command "[int64]$b=%BB%; [int64]$a=%AA%; [Console]::WriteLine($b-$a)"') do (
    set "%~3=%%F"
)
goto :eof

:: ========================================
:: CLEANUP TASKS
:: ========================================
:clean_temp_files
echo [TASK] Cleaning temporary files...
echo --- Temp Files --- >> "%LOG_FILE%"

call :GetSizeDirPS "%TEMP%" B1
call :GetSizeDirPS "C:\Windows\Temp" B2
call :GetSizeDirPS "%USERPROFILE%\AppData\Local\Temp" B3

call :DeleteTree "%TEMP%"
call :DeleteTree "C:\Windows\Temp"
call :DeleteTree "%USERPROFILE%\AppData\Local\Temp"

call :GetSizeDirPS "%TEMP%" A1
call :GetSizeDirPS "C:\Windows\Temp" A2
call :GetSizeDirPS "%USERPROFILE%\AppData\Local\Temp" A3

call :SumFreedPS_3 %B1% %B2% %B3% %A1% %A2% %A3% FREED
echo Freed: %FREED% bytes
echo Temp files cleaned – Freed %FREED% bytes >> "%LOG_FILE%"
goto :eof

:clean_recent_items
echo [TASK] Cleaning recent items...
echo --- Recent Items --- >> "%LOG_FILE%"

call :GetSizeDirPS "%USERPROFILE%\Recent" B
call :DeleteTree "%USERPROFILE%\Recent"
call :GetSizeDirPS "%USERPROFILE%\Recent" A

call :DiffFreedPS_1 %B% %A% FREED
echo Freed: %FREED% bytes
echo Recent items cleared – Freed %FREED% bytes >> "%LOG_FILE%"
goto :eof

:clean_prefetch
echo [TASK] Cleaning prefetch files...
echo --- Prefetch Files --- >> "%LOG_FILE%"

call :GetSizeDirPS "C:\Windows\Prefetch" B
call :DeleteTree "C:\Windows\Prefetch"
call :GetSizeDirPS "C:\Windows\Prefetch" A

call :DiffFreedPS_1 %B% %A% FREED
echo Freed: %FREED% bytes
echo Prefetch cleared – Freed %FREED% bytes >> "%LOG_FILE%"
goto :eof

:system_repairs
echo [TASK] Running system repairs...
echo --- System Repairs --- >> "%LOG_FILE%"
echo DISM /Online /Cleanup-Image /CheckHealth >> "%LOG_FILE%"
DISM /Online /Cleanup-Image /CheckHealth >> "%LOG_FILE%" 2>&1
echo DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG_FILE%"
DISM /Online /Cleanup-Image /RestoreHealth >> "%LOG_FILE%" 2>&1
echo sfc /scannow >> "%LOG_FILE%"
sfc /scannow >> "%LOG_FILE%" 2>&1
echo System repairs completed >> "%LOG_FILE%"
goto :eof

:: ========================================
:: COMPLETION
:: ========================================
:completion
echo.
echo ========================================
echo          Cleanup Completed
echo ========================================
echo [INFO] Actions logged in: %LOG_FILE%
echo.
pause
goto :menu

:end
echo Exiting...
endlocal
exit /b
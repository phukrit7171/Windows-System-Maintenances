@echo off
setlocal EnableDelayedExpansion

:: ========================================
:: Safer System Cleanup & Maintenance Tool
:: With preview, confirmations, logging, and space freed report
:: ========================================

title Safe System Cleanup Tool

:: Log file
set "LOG_FILE=%~dp0cleanup_log.txt"
echo Cleanup Log - %date% %time% > "%LOG_FILE%"
echo ====================================== >> "%LOG_FILE%"

:: Function: Get folder size in bytes
:get_size
set "folder=%~1"
set size=0
for /f "usebackq tokens=3" %%A in (`dir "%folder%" /s /-c 2^>nul ^| find "File(s)"`) do (
    set /a size+=%%A
)
set "%~2=%size%"
goto :eof

:: Check admin rights
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo [WARNING] This script is best run as Administrator.
    echo Some operations may fail without admin rights.
    echo.
    timeout /t 3 >nul
)

:: Menu
:menu
cls
echo ========================================
echo    Safe Windows System Cleanup Tool
echo ========================================
echo.
echo What would you like to clean?
echo [1] Temporary files only
echo [2] Temporary files + Recent items
echo [3] Full cleanup (temp, recent, prefetch)
echo [4] Full cleanup + System repairs
echo [5] Exit
echo.
choice /C 12345 /M "Choose an option (1-5)"
set "cleanup_level=%errorlevel%"

if %cleanup_level%==5 goto :EOF
if %cleanup_level%==1 goto :temp_only
if %cleanup_level%==2 goto :temp_recent
if %cleanup_level%==3 goto :full_cleanup
if %cleanup_level%==4 goto :full_with_repair

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
:: FUNCTIONS
:: ========================================

:confirm_and_clean
set "desc=%~1"
set "func=%~2"
echo.
echo [PREVIEW] %desc% to be cleaned:
call :preview_%func%
echo.
choice /C YN /M "Proceed with cleaning %desc%?"
if errorlevel 2 (
    echo   [SKIP] %desc% >> "%LOG_FILE%"
    echo   [INFO] Skipped %desc%
) else (
    call :%func%
)
goto :eof


:: PREVIEW FUNCTIONS
:preview_clean_temp_files
dir "%temp%" /a /s /b 2>nul
dir "C:\Windows\Temp" /a /s /b 2>nul
dir "%USERPROFILE%\AppData\Local\Temp" /a /s /b 2>nul
goto :eof

:preview_clean_recent_items
dir "%userprofile%\Recent" /a /s /b 2>nul
goto :eof

:preview_clean_prefetch
dir "C:\Windows\Prefetch" /a /s /b 2>nul
goto :eof

:preview_system_repairs
echo DISM /CheckHealth and /RestoreHealth
echo sfc /scannow
goto :eof


:: CLEANUP FUNCTIONS
:clean_temp_files
echo [TASK] Cleaning temporary files...
call :get_size "%temp%" before
call :get_size "C:\Windows\Temp" before2
call :get_size "%USERPROFILE%\AppData\Local\Temp" before3
set /a total_before=before+before2+before3

del /f /s /q "%temp%\*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
del /f /s /q "%USERPROFILE%\AppData\Local\Temp\*" >nul 2>&1

call :get_size "%temp%" after
call :get_size "C:\Windows\Temp" after2
call :get_size "%USERPROFILE%\AppData\Local\Temp" after3
set /a total_after=after+after2+after3

set /a freed=total_before-total_after
echo Freed: !freed! bytes
echo Temp files cleaned – Freed !freed! bytes >> "%LOG_FILE%"
goto :eof

:clean_recent_items
echo [TASK] Cleaning recent items...
call :get_size "%userprofile%\Recent" before
del /f /s /q "%userprofile%\Recent\*" >nul 2>&1
call :get_size "%userprofile%\Recent" after
set /a freed=before-after
echo Freed: !freed! bytes
echo Recent items cleared – Freed !freed! bytes >> "%LOG_FILE%"
goto :eof

:clean_prefetch
echo [TASK] Cleaning prefetch files...
call :get_size "C:\Windows\Prefetch" before
del /f /s /q "C:\Windows\Prefetch\*" >nul 2>&1
call :get_size "C:\Windows\Prefetch" after
set /a freed=before-after
echo Freed: !freed! bytes
echo Prefetch cleared – Freed !freed! bytes >> "%LOG_FILE%"
goto :eof

:system_repairs
echo [TASK] Running system repairs...
echo --- System Repairs --- >> "%LOG_FILE%"
DISM /Online /Cleanup-Image /CheckHealth
DISM /Online /Cleanup-Image /RestoreHealth
sfc /scannow
echo System repairs completed >> "%LOG_FILE%"
goto :eof


:: ========================================
:: COMPLETION
:: ========================================
:completion
echo.
echo ========================================
echo         Cleanup Completed!
echo ========================================
echo [INFO] Actions logged in: %LOG_FILE%
echo.
pause
goto :menu

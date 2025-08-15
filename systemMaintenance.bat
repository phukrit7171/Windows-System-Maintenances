@echo off
setlocal EnableDelayedExpansion

:: Enhanced Windows System Cleanup Script
:: Improved version with better error handling and safety checks

title System Cleanup and Maintenance Tool

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo.
    echo [WARNING] This script requires administrator privileges for full functionality.
    echo Some operations may fail without admin rights.
    echo.
    timeout /t 3 >nul
)

echo ========================================
echo    Windows System Cleanup Tool
echo ========================================
echo.

:: Ask user what they want to clean
echo What would you like to clean?
echo [1] Temporary files only
echo [2] Temporary files + Recent items
echo [3] Full cleanup (temp files, recent items, prefetch)
echo [4] Full cleanup + System repairs
echo [5] Exit
echo.
choice /C 12345 /M "Choose an option (1-5)"
set cleanup_level=%errorlevel%

if %cleanup_level%==5 goto :EOF
if %cleanup_level%==1 goto :temp_only
if %cleanup_level%==2 goto :temp_recent
if %cleanup_level%==3 goto :full_cleanup
if %cleanup_level%==4 goto :full_with_repair

:temp_only
echo.
echo [INFO] Cleaning temporary files...
call :clean_temp_files
goto :completion

:temp_recent
echo.
echo [INFO] Cleaning temporary files and recent items...
call :clean_temp_files
call :clean_recent_items
goto :completion

:full_cleanup
echo.
echo [INFO] Performing full cleanup...
call :clean_temp_files
call :clean_recent_items
call :clean_prefetch
goto :completion

:full_with_repair
echo.
echo [INFO] Performing full cleanup with system repairs...
call :clean_temp_files
call :clean_recent_items
call :clean_prefetch
call :system_repairs
goto :completion

:: ========================================
:: CLEANUP FUNCTIONS
:: ========================================

:clean_temp_files
echo [TASK] Cleaning temporary files...

:: Clean current directory temp files
if exist "*.tmp" (
    echo   - Removing .tmp files from current directory...
    del "*.tmp" /f /q >nul 2>&1
)

:: Clean user temp folder
if exist "%temp%" (
    echo   - Cleaning user temp folder...
    pushd "%temp%" >nul 2>&1
    if !errorlevel!==0 (
        for /d %%D in (*) do (
            rd /s /q "%%D" >nul 2>&1
        )
        del /f /q * >nul 2>&1
        popd
    ) else (
        echo   [WARNING] Cannot access user temp folder
    )
)

:: Clean Windows temp folder
if exist "C:\Windows\Temp" (
    echo   - Cleaning Windows temp folder...
    del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo   [WARNING] Some Windows temp files could not be deleted (may require admin rights)
    )
)

:: Clean user profile temp
if exist "%USERPROFILE%\appdata\local\temp" (
    echo   - Cleaning user profile temp...
    del /s /f /q "%USERPROFILE%\appdata\local\temp\*.*" >nul 2>&1
)

echo   [DONE] Temporary files cleanup completed
goto :eof

:clean_recent_items
echo [TASK] Cleaning recent items...
if exist "%userprofile%\Recent" (
    del /s /f /q "%userprofile%\Recent\*.*" >nul 2>&1
    echo   [DONE] Recent items cleared
) else (
    echo   [INFO] Recent items folder not found
)
goto :eof

:clean_prefetch
echo [TASK] Cleaning prefetch files...
if exist "C:\Windows\Prefetch" (
    del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
    if !errorlevel!==0 (
        echo   [DONE] Prefetch files cleared
    ) else (
        echo   [WARNING] Could not clear prefetch files (requires admin rights)
    )
) else (
    echo   [INFO] Prefetch folder not accessible
)
goto :eof

:system_repairs
echo [TASK] Running system integrity checks...
echo.
echo This may take several minutes...

echo [SCAN] Running DISM health check...
DISM /Online /Cleanup-Image /CheckHealth >nul 2>&1
if !errorlevel!==0 (
    echo   [INFO] DISM health check passed
    echo [SCAN] Running DISM restore health...
    DISM /Online /Cleanup-Image /RestoreHealth
) else (
    echo   [WARNING] DISM health check failed or requires admin rights
)

echo.
echo [SCAN] Running System File Checker...
sfc /scannow

if !errorlevel!==0 (
    echo   [DONE] System file check completed successfully
) else (
    echo   [WARNING] System file check encountered issues
)
goto :eof

:completion
echo.
echo ========================================
echo           Cleanup Complete!
echo ========================================
echo.

:: Show disk space freed (basic estimate)
echo [INFO] Cleanup operations completed.
echo [TIP] Consider running Disk Cleanup utility for additional space savings.
echo [TIP] Restart your computer if system repairs were performed.
echo.

pause
goto :EOF
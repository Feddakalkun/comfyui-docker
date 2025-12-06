@echo off
setlocal
cd /d "%~dp0"

:: Check for admin privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges.
    echo Restarting as administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Starting Update Process...
powershell -ExecutionPolicy Bypass -File "scripts\update.ps1"
pause

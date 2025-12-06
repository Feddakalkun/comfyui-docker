@echo off
setlocal
cd /d "%~dp0"

:: Check for admin privileges (needed for Symlinks)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script requires administrator privileges to create Symbolic Links.
    echo Restarting as administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Starting Model Import...
powershell -ExecutionPolicy Bypass -File "scripts\import_local_models.ps1"
pause

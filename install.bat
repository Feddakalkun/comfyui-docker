@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: FEDDAKALKUN ComfyUI - Ultimate Enhanced Installer
:: ============================================================================

:: Step 1: Safety + context - Anchor to root
set "ROOT=%~dp0"
cd /d "%ROOT%"

:: Check for admin privileges and re-launch if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This installer requires administrator privileges.
    echo Restarting as administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Starting Enhanced Installer (PowerShell)...
powershell -ExecutionPolicy Bypass -File "%ROOT%scripts\install.ps1"

pause

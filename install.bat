@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: FEDDAKALKUN ComfyUI - Flagship Pack Installer
:: Installs I2V-wan22-advanced-v2.json workflow with all dependencies
:: ============================================================================

:: Step 1: Safety + context - Anchor to root
set "ROOT=%~dp0"
cd /d "%ROOT%"

:: Check for admin privileges and re-launch if needed
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This installer requires administrator privileges.
    echo Restarting as administrator...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs -Wait"
    exit /b
)

echo.
echo ============================================================================
echo Starting Flagship Pack Installation (PowerShell)
echo ============================================================================
echo.
echo Components:
echo - WAN 2.2 I2V (Image-to-Video) Models
echo - Frame Interpolation (RIFE)
echo - LLM Prompt Generator (Mistral 7B GGUF)
echo - Florence2 Image Captioning
echo - All Required Custom Nodes
echo.
echo This may take 10-20 minutes on first run (model downloads).
echo.

powershell -ExecutionPolicy Bypass -File "%ROOT%scripts\install.ps1"

if %errorlevel% equ 0 (
    echo.
    echo ============================================================================
    echo Installation Complete! You can now run: START_HERE.bat or run.bat
    echo ============================================================================
) else (
    echo.
    echo Installation failed. Check the logs folder for details.
)

pause

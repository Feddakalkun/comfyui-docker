@echo off
setlocal
cd /d %~dp0

:: ==================================================
:: FEDDAKALKUN ComfyUI - Model Downloader
:: ==================================================

echo Starting Model Downloader...
echo This will download large files. Please be patient.
echo.

powershell -ExecutionPolicy Bypass -File "%~dp0download_models.ps1"

pause

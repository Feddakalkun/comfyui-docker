@echo off
setlocal
cd /d %~dp0

:: ==================================================
:: FEDDAKALKUN ComfyUI - Portable Run Script
:: ==================================================

:: Set up Portable Environment Paths
set "ROOT=%~dp0"
set "PYTHON_DIR=%ROOT%python_embeded"

:: Add portable tools to PATH
set "PATH=%PYTHON_DIR%;%PYTHON_DIR%\Scripts;%PATH%"

if not exist "%PYTHON_DIR%\python.exe" (
    echo [ERROR] Portable Python not found!
    echo Please run install.bat first to set up the portable environment.
    pause
    exit /b 1
)

echo Launching ComfyUI (Portable Mode)...
cd ComfyUI
set PYTHONPATH=%CD%
"%PYTHON_DIR%\python.exe" "main.py" --windows-standalone-build
pause

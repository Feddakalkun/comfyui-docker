@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: FEDDAKALKUN ComfyUI Asset Sync (Hugging Face)
:: ============================================================================

:: Anchor to root (Parent of scripts)
set "ROOT=%~dp0.."
cd /d "%ROOT%"

:: Initialize sync log
echo ========================================= >> logs\sync_log.txt
echo Sync started: %date% %time% >> logs\sync_log.txt
echo ========================================= >> logs\sync_log.txt
echo.

echo [SYNC] Starting asset synchronization...
echo [SYNC] Starting asset synchronization... >> logs\sync_log.txt

:: Check if ComfyUI exists
if not exist "ComfyUI" (
    echo ERROR: ComfyUI directory not found!
    echo Please run 'install.bat' first to set up ComfyUI.
    echo ERROR: ComfyUI directory not found >> logs\sync_log.txt
    pause
    exit /b 1
)

:: Set Hugging Face dataset URL
set "HF_BASE=https://huggingface.co/datasets/getgoingafd/workstation_main/resolve/main"

:: Counter for tracking
set ADDED_COUNT=0
set SKIPPED_COUNT=0

echo.
echo [SYNC] Syncing LoRAs...
echo [SYNC] Syncing LoRAs... >> logs\sync_log.txt

:: Create LoRAs directory if it doesn't exist
if not exist "ComfyUI\models\loras" mkdir "ComfyUI\models\loras"

:: We need to handle Hugging Face file downloads
:: Since batch can't easily handle this, we'll use git with sparse checkout
cd ComfyUI
if not exist ".git\sync_repo" (
    :: Initialize a temporary repo for syncing
    mkdir sync_repo_temp
    cd sync_repo_temp
    git init
    git remote add origin https://huggingface.co/datasets/getgoingafd/workstation_main
    git config core.sparseCheckout true
    
    echo LoRAs/* > .git/info/sparse-checkout
    echo Workflows/* >> .git/info/sparse-checkout
    echo Wildcards/* >> .git/info/sparse-checkout
    
    git pull origin main --depth 1
    if !errorlevel! neq 0 (
        echo ERROR: Failed to fetch from Hugging Face >> logs\sync_log.txt
        echo ERROR: Failed to fetch assets from Hugging Face. Check internet connection.
        cd ..
        rmdir /s /q sync_repo_temp 2>nul
        pause
        exit /b 1
    )
    
    :: Move files to proper locations
    if exist "LoRAs" (
        echo Syncing LoRAs...
        xcopy "LoRAs\*" "..\models\loras\" /E /I /Y >nul 2>&1
        if !errorlevel! equ 0 (
            for /f %%i in ('dir /s /b LoRAs\* 2^>nul ^| find /c /v ""') do (
                set /a ADDED_COUNT+=%%i
                echo [ADD] LoRAs/ (%%i files) >> ..\..\logs\sync_log.txt
                echo [ADD] LoRAs/ (%%i files)
            )
        )
    )
    
    if exist "Workflows" (
        echo Syncing Workflows...
        if not exist "..\user\default\workflows" mkdir "..\user\default\workflows"
        xcopy "Workflows\*" "..\user\default\workflows\" /E /I /Y >nul 2>&1
        if !errorlevel! equ 0 (
            for /f %%i in ('dir /s /b Workflows\* 2^>nul ^| find /c /v ""') do (
                set /a ADDED_COUNT+=%%i
                echo [ADD] Workflows/ (%%i files) >> ..\..\logs\sync_log.txt
                echo [ADD] Workflows/ (%%i files)
            )
        )
    )
    
    if exist "Wildcards" (
        echo Syncing Wildcards...
        if not exist "..\custom_nodes\ComfyUI-Impact-Pack\wildcards" mkdir "..\custom_nodes\ComfyUI-Impact-Pack\wildcards"
        xcopy "Wildcards\*" "..\custom_nodes\ComfyUI-Impact-Pack\wildcards\" /E /I /Y >nul 2>&1
        if !errorlevel! equ 0 (
            for /f %%i in ('dir /s /b Wildcards\* 2^>nul ^| find /c /v ""') do (
                set /a ADDED_COUNT+=%%i
                echo [ADD] Wildcards/ (%%i files) >> ..\..\logs\sync_log.txt
                echo [ADD] Wildcards/ (%%i files)
            )
        )
    )
    
    cd ..
    rmdir /s /q sync_repo_temp 2>nul
) else (
    echo Assets already synced in previous run. >> logs\sync_log.txt
    echo [INFO] Assets already synced in previous run
)

cd ..

:: Summary
echo.
echo ================================================
echo  Asset Sync Complete!
echo ================================================
echo.
echo Sync Summary:
echo • Assets added: !ADDED_COUNT!
echo • Assets skipped: !SKIPPED_COUNT!
echo.
echo Synced to:
echo • LoRAs: ComfyUI\models\loras\
echo • Workflows: ComfyUI\user\default\workflows\
echo • Wildcards: ComfyUI\custom_nodes\ComfyUI-Impact-Pack\wildcards\
echo.
echo Log saved in: %ROOT%logs\sync_log.txt
echo ================================================

echo.
echo Sync completed successfully! >> logs\sync_log.txt
echo Total added: !ADDED_COUNT! >> logs\sync_log.txt
echo Total skipped: !SKIPPED_COUNT! >> logs\sync_log.txt
echo ========================================= >> logs\sync_log.txt
echo. >> logs\sync_log.txt

pause
endlocal
@echo off
setlocal
cd /d %~dp0

:: ==================================================
:: FEDDAKALKUN AI SUITE - PORTABLE LAUNCHER
:: ==================================================

:: Set up Portable Environment Paths
set "ROOT=%~dp0"
set "PYTHON_DIR=%ROOT%python_embeded"
set "NODE_DIR=%ROOT%node_embeded"
set "GIT_DIR=%ROOT%git_embeded\cmd"

:: Add portable tools to PATH (temporarily for this session)
set "PATH=%PYTHON_DIR%;%PYTHON_DIR%\Scripts;%NODE_DIR%;%GIT_DIR%;%PATH%"

:MENU
cls
echo ==================================================
echo   FEDDAKALKUN AI SUITE - PORTABLE LAUNCHER
echo ==================================================
echo.
echo  [1] Launch ComfyUI
echo  [2] Launch GGAFD Shop (Website)
echo  [3] Launch AI Assistant (Phone App)
echo  [4] Launch ALL
echo.
echo  [5] Tools (Download Models, Sync Assets)
echo  [6] Exit
echo.
set /p CHOICE="Select an option: "

if "%CHOICE%"=="1" goto COM
if "%CHOICE%"=="2" goto WEB
if "%CHOICE%"=="3" goto APP
if "%CHOICE%"=="4" goto ALL
if "%CHOICE%"=="5" goto TOOLS
if "%CHOICE%"=="6" exit

goto MENU

:COM
cls
echo ==================================================
echo   Launching ComfyUI...
echo ==================================================
echo.
echo [                    ] 0%%
timeout /t 1 >nul
echo [=====               ] 25%%
cd ComfyUI
set PYTHONPATH=%CD%
echo [==========          ] 50%%
timeout /t 1 >nul
echo [===============     ] 75%%
start "" "..\python_embeded\python.exe" "main.py" --windows-standalone-build
echo [====================] 100%%
echo.
echo ComfyUI started in a new window!
timeout /t 2 >nul
cd ..
goto MENU

:WEB
call :CHECK_NODE
if %errorlevel% neq 0 goto MENU
cls
echo ==================================================
echo   Launching GGAFD Shop...
echo ==================================================
echo.
echo [                    ] 0%%
cd GGAFD-com
echo [==========          ] 50%%
start "GGAFD Shop" cmd /k "npm install && npm run dev"
echo [====================] 100%%
echo.
Shop started!
timeout /t 2 >nul
cd ..
goto MENU

:APP
call :CHECK_NODE
if %errorlevel% neq 0 goto MENU
cls
echo ==================================================
echo   Launching AI Assistant...
echo ==================================================
echo.
echo [                    ] 0%%
cd ggafd-phone
echo [==========          ] 50%%
start "AI Assistant" cmd /k "npm install && npm run dev"
echo [====================] 100%%
echo.
App started!
timeout /t 2 >nul
cd ..
goto MENU

:ALL
call :CHECK_NODE
if %errorlevel% neq 0 goto MENU
cls
echo ==================================================
echo   Launching EVERYTHING...
echo ==================================================
echo.
echo [                    ] 0%%
cd ComfyUI
set PYTHONPATH=%CD%
start "" "..\python_embeded\python.exe" "main.py" --windows-standalone-build
cd ..
echo [======              ] 33%%
cd GGAFD-com
start "GGAFD Shop" cmd /k "npm install && npm run dev"
cd ..
echo [=============       ] 66%%
cd ggafd-phone
start "AI Assistant" cmd /k "npm install && npm run dev"
cd ..
echo [====================] 100%%
echo.
All systems go!
timeout /t 2 >nul
goto MENU

:TOOLS
cls
echo ==================================================
echo   TOOLS MENU
echo ==================================================
echo.

echo  [1] Download Models (SDXL, etc.)
echo  [2] Sync Assets (LoRAs, Workflows)
echo  [3] Back to Main Menu
echo.
set /p TOOL_CHOICE="Select an option: "

if "%TOOL_CHOICE%"=="1" (
    echo Launching Model Downloader...
    call scripts\download_models.bat
    pause
    goto TOOLS
)
if "%TOOL_CHOICE%"=="2" (
    echo Launching Asset Sync...
    call scripts\sync_updates.bat
    pause
    goto TOOLS
)
if "%TOOL_CHOICE%"=="3" goto MENU
goto TOOLS

:CHECK_NODE
if not exist "%NODE_DIR%\node.exe" (
    echo.
    echo [ERROR] Portable Node.js not found in node_embeded!
    echo Please run install.bat to download portable tools.
    echo.
    pause
    exit /b 1
)
exit /b 0
@echo off
setlocal
cd /d "%~dp0"

set /p SUBREDDIT="Enter subreddit name (e.g. midjourney): "
set /p LIMIT="Enter number of images (default 25): "
if "%LIMIT%"=="" set LIMIT=25

echo.
echo Scraping r/%SUBREDDIT%...
python_embeded\python.exe scripts\reddit_scraper.py %SUBREDDIT% --limit %LIMIT%

echo.
pause


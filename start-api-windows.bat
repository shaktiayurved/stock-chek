@echo off
title NCR Quick Stock Finder - Local API (MOCK MODE)
cd /d "%~dp0"

echo ============================================================
echo  NCR QUICK STOCK FINDER - Local API (MOCK MODE, demo data)
echo ============================================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js nahi mila. Pehle install karein: https://nodejs.org
  pause
  exit /b 1
)

echo [1/3] Dependencies install ho rahi hain (pehli baar thoda time lagega)...
call npm install --no-audit --no-fund
if errorlevel 1 ( echo [ERROR] npm install fail hua & pause & exit /b 1 )

echo [2/3] API build ho rahi hai...
call npm run build:api
if errorlevel 1 ( echo [ERROR] build fail hua & pause & exit /b 1 )

echo [3/3] API start ho rahi hai: http://localhost:8787
echo        (MOCK MODE = demo data, UI testing only)
echo        Is window ko band NA karein. Band karne ke liye Ctrl+C.
echo.

set MOCK_MODE=true
set PORT=8787
set ALLOW_CHROME_EXTENSIONS=true
node apps\api\dist\server.js

pause

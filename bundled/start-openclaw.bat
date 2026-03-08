@echo off
chcp 65001 >nul
title OpenClaw Gateway

:: 设置路径
set "NODE_HOME=%~dp0nodejs"
set "PATH=%NODE_HOME%;%PATH%"
set "OPENCLAW_DIR=%~dp0openclaw"

:: 检查是否已运行
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo OpenClaw 已在运行中...
    timeout /t 3 >nul
    exit /b 0
)

:: 启动 OpenClaw
cd /d "%OPENCLAW_DIR%"
echo 正在启动 OpenClaw...
start "" "%NODE_HOME%\node.exe" "%OPENCLAW_DIR%\node_modules\openclaw\dist\cli.js" gateway start

:: 等待启动
timeout /t 5 >nul

:: 打开浏览器
start http://localhost:18789

exit /b 0

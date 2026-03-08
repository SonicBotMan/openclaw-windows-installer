@echo off
chcp 65001 >nul
title OpenClaw Gateway

:: 设置路径
set "NODE_HOME=%~dp0nodejs"
set "PATH=%NODE_HOME%;%PATH%"
set "OPENCLAW_DIR=%~dp0openclaw"

:: 停止 OpenClaw
cd /d "%OPENCLAW_DIR%"
echo 正在停止 OpenClaw...
"%NODE_HOME%\node.exe" "%OPENCLAW_DIR%\node_modules\openclaw\dist\cli.js" gateway stop
echo OpenClaw 已停止
timeout /t 3 >nul

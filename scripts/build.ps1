# OpenClaw Windows Installer 构建脚本
# 需要在 Windows 上运行

param(
    [string]$NodeVersion = "22.12.0",
    [string]$OpenClawVersion = "2026.3.7"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw Windows Installer Builder  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 下载 Node.js 便携版
Write-Host "[1/5] 下载 Node.js v$NodeVersion..." -ForegroundColor Yellow
$NodeUrl = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"
$NodeZip = "$ProjectRoot\temp\node.zip"
$NodeDir = "$ProjectRoot\ bundled\nodejs"

if (!(Test-Path "$NodeDir\node.exe")) {
    New-Item -ItemType Directory -Force -Path "$ProjectRoot\temp" | Out-Null
    Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZip
    Expand-Archive -Path $NodeZip -DestinationPath "$ProjectRoot\temp\node" -Force
    Move-Item "$ProjectRoot\temp\node\node-v$NodeVersion-win-x64\*" $NodeDir -Force
    Remove-Item "$ProjectRoot\temp\node" -Recurse -Force
    Remove-Item $NodeZip -Force
    Write-Host "  ✓ Node.js 已下载" -ForegroundColor Green
} else {
    Write-Host "  ✓ Node.js 已存在" -ForegroundColor Green
}

# 步骤 2: 安装 OpenClaw
Write-Host "[2/5] 安装 OpenClaw v$OpenClawVersion..." -ForegroundColor Yellow
$OpenClawDir = "$ProjectRoot\bundled\openclaw"

if (!(Test-Path "$OpenClawDir\node_modules\openclaw")) {
    New-Item -ItemType Directory -Force -Path $OpenClawDir | Out-Null
    Push-Location $OpenClawDir
    
    # 创建 package.json
    @{
        name = "openclaw-app"
        version = $OpenClawVersion
        dependencies = @{
            openclaw = $OpenClawVersion
        }
    } | ConvertTo-Json | Out-File -FilePath "package.json" -Encoding UTF8
    
    # 使用便携版 npm 安装
    $env:PATH = "$NodeDir;$env:PATH"
    & npm install --production
    
    Pop-Location
    Write-Host "  ✓ OpenClaw 已安装" -ForegroundColor Green
} else {
    Write-Host "  ✓ OpenClaw 已存在" -ForegroundColor Green
}

# 步骤 3: 构建配置工具
Write-Host "[3/5] 构建 Tauri 配置工具..." -ForegroundColor Yellow
$ConfigToolDir = "$ProjectRoot\config-tool"

if (Get-Command "cargo" -ErrorAction SilentlyContinue) {
    Push-Location $ConfigToolDir
    
    # 安装依赖
    if (!(Test-Path "node_modules")) {
        npm install
    }
    
    # 构建 Tauri
    npm run tauri build
    
    # 复制输出
    Copy-Item "src-tauri\target\release\openclaw-config.exe" "$ProjectRoot\bundled\" -Force
    
    Pop-Location
    Write-Host "  ✓ 配置工具已构建" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Cargo 未安装，跳过配置工具构建" -ForegroundColor Yellow
    Write-Host "    请手动安装 Rust 和 Tauri: https://tauri.app" -ForegroundColor Gray
}

# 步骤 4: 创建图标
Write-Host "[4/5] 创建图标..." -ForegroundColor Yellow
$AssetsDir = "$ProjectRoot\assets"

if (!(Test-Path "$AssetsDir\icon.ico")) {
    New-Item -ItemType Directory -Force -Path $AssetsDir | Out-Null
    Write-Host "  ⚠ 请手动添加图标文件到 assets/ 目录:" -ForegroundColor Yellow
    Write-Host "    - icon.ico (安装程序图标)" -ForegroundColor Gray
    Write-Host "    - icon-web.ico (网页快捷方式图标)" -ForegroundColor Gray
    Write-Host "    - icon-config.ico (配置工具图标)" -ForegroundColor Gray
} else {
    Write-Host "  ✓ 图标已存在" -ForegroundColor Green
}

# 步骤 5: 构建安装包
Write-Host "[5/5] 构建 Inno Setup 安装包..." -ForegroundColor Yellow

if (Get-Command "iscc" -ErrorAction SilentlyContinue) {
    & iscc "$ProjectRoot\installer\setup.iss"
    Write-Host "  ✓ 安装包已生成" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Inno Setup 未安装" -ForegroundColor Yellow
    Write-Host "    请安装 Inno Setup: https://jrsoftware.org/isdl.php" -ForegroundColor Gray
    Write-Host "    然后手动编译 installer/setup.iss" -ForegroundColor Gray
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  构建完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "输出目录: $ProjectRoot\output\" -ForegroundColor Cyan

#!/bin/bash
# OpenClaw Windows Installer 构建脚本
# 用于 Linux/macOS 生成 Windows 安装包

set -e

NODE_VERSION="22.12.0"
OPENCLAW_VERSION="2026.3.7"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR')"

echo "========================================"
echo "  OpenClaw Windows Installer Builder  "
echo "========================================"
echo ""

# 步骤 1: 下载 Node.js 便携版
echo "[1/5] 下载 Node.js v$NODE_VERSION..."
NODE_URL="https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-win-x64.zip"
NODE_ZIP="$PROJECT_ROOT/temp/node.zip"
NODE_DIR="$PROJECT_ROOT/bundled/nodejs"

if [ ! -f "$NODE_DIR/node.exe" ]; then
    mkdir -p "$PROJECT_ROOT/temp"
    curl -L -o "$NODE_ZIP" "$NODE_URL"
    unzip -q "$NODE_ZIP" -d "$PROJECT_ROOT/temp/node"
    mv "$PROJECT_ROOT/temp/node/node-v$NODE_VERSION-win-x64/"* "$NODE_DIR/"
    rm -rf "$PROJECT_ROOT/temp/node" "$NODE_ZIP"
    echo "  ✓ Node.js 已下载"
else
    echo "  ✓ Node.js 已存在"
fi

# 步骤 2: 安装 OpenClaw
echo "[2/5] 安装 OpenClaw v$OPENCLAW_VERSION..."
OPENCLAW_DIR="$PROJECT_ROOT/bundled/openclaw"

if [ ! -d "$OPENCLAW_DIR/node_modules/openclaw" ]; then
    mkdir -p "$OPENCLAW_DIR"
    cd "$OPENCLAW_DIR"
    
    # 创建 package.json
    cat > package.json << EOF
{
  "name": "openclaw-app",
  "version": "$OPENCLAW_VERSION",
  "dependencies": {
    "openclaw": "$OPENCLAW_VERSION"
  }
}
EOF
    
    # 使用系统 npm 安装（会下载 Windows 版本的包）
    npm install --production
    
    cd "$PROJECT_ROOT"
    echo "  ✓ OpenClaw 已安装"
else
    echo "  ✓ OpenClaw 已存在"
fi

# 步骤 3: 准备配置工具源码
echo "[3/5] 准备配置工具..."
echo "  ✓ 配置工具源码已准备"
echo "  注意: 需要在 Windows 上构建 Tauri 应用"

# 步骤 4: 创建目录结构
echo "[4/5] 创建输出目录..."
mkdir -p "$PROJECT_ROOT/output"
mkdir -p "$PROJECT_ROOT/assets"

# 步骤 5: 打包文件
echo "[5/5] 打包文件..."
cd "$PROJECT_ROOT"
zip -r "output/openclaw-windows-bundle-$OPENCLAW_VERSION.zip" \
    bundled/ \
    config-tool/ \
    installer/ \
    README.md \
    -x "*.git*" "*node_modules/.cache*" "*target/debug*"

echo ""
echo "========================================"
echo "  构建完成！"
echo "========================================"
echo ""
echo "输出文件: $PROJECT_ROOT/output/openclaw-windows-bundle-$OPENCLAW_VERSION.zip"
echo ""
echo "后续步骤:"
echo "1. 在 Windows 上解压此文件"
echo "2. 安装 Rust: https://rustup.rs"
echo "3. 安装 Tauri: https://tauri.app"
echo "4. 安装 Inno Setup: https://jrsoftware.org/isdl.php"
echo "5. 运行 scripts/build.ps1 完成构建"

# OpenClaw Windows Installer

一键安装 OpenClaw 到 Windows 电脑，无需任何外部依赖。

## 功能特性

- ✅ 一键安装，自动部署 Node.js + OpenClaw
- ✅ 安装时配置 GLM / MiniMax API Keys
- ✅ 桌面快捷方式 - 打开网页对话
- ✅ 桌面快捷方式 - 配置工具（修改模型、API 地址、Key）
- ✅ 完全离线可用
- ✅ 自动注册 Windows 服务（开机启动）

## 构建步骤

### 1. 准备依赖

```bash
# 安装 Node.js 便携版
# 下载 https://nodejs.org/dist/v22.12.0/node-v22.12.0-win-x64.zip
# 解压到 bundled/nodejs/

# 安装 OpenClaw
cd bundled/openclaw
npm init -y
npm install openclaw
```

### 2. 构建配置工具

```bash
cd config-tool
npm install
npm run tauri build
```

### 3. 构建安装包

```bash
# 使用 Inno Setup 编译 installer/setup.iss
```

## 目录结构

```
openclaw-windows-installer/
├── installer/
│   └── setup.iss          # Inno Setup 安装脚本
├── bundled/
│   ├── nodejs/            # 便携版 Node.js
│   ├── openclaw/          # OpenClaw 应用
│   ├── start-openclaw.bat # 启动 OpenClaw
│   └── openclaw-config.json # 配置模板
├── config-tool/           # Tauri 配置工具
│   ├── src/               # 前端代码
│   └── src-tauri/         # Rust 后端
└── scripts/
    └── build.ps1          # PowerShell 构建脚本
```

## 安装后效果

安装完成后，用户桌面会有两个快捷方式：

1. **OpenClaw 网页** - 打开 http://localhost:18789 进行对话
2. **OpenClaw 配置** - 修改模型、API 地址、密钥

## 开发者

由 OpenClaw AI 助手「小华」创建
分析模型: MiniMax M2.5-highspeed

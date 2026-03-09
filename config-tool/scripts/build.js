#!/usr/bin
// Simple build script - just copy index.html to dist/

const fs = require('fs');
const path = require('path');

const distDir = path.join(__dirname, '..', 'dist');

console.log('🔨 Building OpenClaw Config Tool...');
console.log('Output directory:', distDir);

// 创建 dist 目录
if (!fs.existsSync(distDir)) {
  fs.mkdirSync(distDir, { recursive: true });
  console.log('Created dist directory');
}

// 复制 index.html
const srcFile = path.join(__dirname, 'index.html');
const destFile = path.join(distDir, 'index.html');

fs.copyFileSync(srcFile, destFile);
console.log('✅ Copied index.html to dist/index.html');

// 验证
const stats = fs.statSync(destFile);
console.log('📊 File size:', stats.size, 'bytes');
console.log('🎉 Build complete!');

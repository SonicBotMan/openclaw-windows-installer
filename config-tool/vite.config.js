import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  // 纯 HTML 项目
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    target: 'esnext',
    // Tauri 需要保留原始代码
    minify: false,
    sourcemap: true
  },
  // 开发服务器配置
  server: {
    port: 5173,
    strictPort: true,
    // Tauri 开发时的 CORS 设置
    cors: true
  },
  // 确保 Tauri 的特殊协议被正确处理
  optimizeDeps: {
    exclude: ['@tauri-apps/api']
  }
})

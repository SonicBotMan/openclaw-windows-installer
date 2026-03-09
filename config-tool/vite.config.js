import { defineConfig } from 'vite'

// Vite 配置 - 纯 HTML 项目
export default defineConfig({
  // 根目录
  root: '.',
  
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    minify: false,
    sourcemap: false
  },
  
  server: {
    port: 5173,
    strictPort: true
  }
})

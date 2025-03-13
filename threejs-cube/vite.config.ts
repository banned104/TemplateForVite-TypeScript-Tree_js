import { defineConfig } from 'vite'
import babel from 'vite-plugin-babel'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    babel()
  ],
    // 自定义静态资源处理
    build: {
        assetsInlineLimit: 4096, // 小于 4KB 的资源会被内联为 base64
        assetsDir: 'assets', // 静态资源输出目录
        rollupOptions: {
          output: {
            assetFileNames: 'assets/[name].[hash].[ext]', // 静态资源文件名格式
          }
        }
      }
})

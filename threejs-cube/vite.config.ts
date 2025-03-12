import { defineConfig } from 'vite'
import babel from 'vite-plugin-babel'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    babel()
  ],
})

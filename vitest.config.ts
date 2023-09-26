/// <reference types="vitest" />

import { defineConfig } from 'vite'

export default defineConfig({
  test: {
    globals: true,
    environment: 'happy-dom',
    coverage: {
      // provider: 'istanbul', // or 默认 'v8'
      // 输出 coverage/
      // reporter: ['text', 'html', 'clover', 'json'], // 默认
      // reporter: [
      //   ["lcov", { projectRoot: "./src" }],
      //   ["json", { file: "coverage.json" }],
      //   ["html"],
      //   ["text"],
      // ]
    },
  },
})

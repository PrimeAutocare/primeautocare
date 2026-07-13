import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig(({ command }) => ({
  plugins: [react(), tailwindcss()],
  // Vitest's transform pipeline needs this set explicitly; the production
  // build (Vite 8's oxc pipeline) already handles automatic JSX on its own
  // and warns if this is also set, so only apply it outside `vite build`.
  ...(command !== "build" && { esbuild: { jsx: "automatic" } }),
  test: {
    environment: "jsdom",
    globals: true,
    setupFiles: "./src/test/setup.js",
  },
}))
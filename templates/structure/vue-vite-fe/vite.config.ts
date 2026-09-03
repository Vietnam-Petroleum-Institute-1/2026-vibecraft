/// <reference types="vitest/config" />
import path from 'node:path';

import vue from '@vitejs/plugin-vue';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    // Mirrors tsconfig.json's `paths: { "@/*": ["./src/*"] }` — TS only
    // type-checks that alias, Vite's own resolver needs it declared here too.
    alias: {
      '@': path.resolve(import.meta.dirname, './src'),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./vitest.setup.ts'],
  },
});

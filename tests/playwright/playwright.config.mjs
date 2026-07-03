import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: '.',
  timeout: 30000,
  use: {
    baseURL: 'http://localhost:4397',
    headless: true,
    viewport: { width: 1280, height: 720 },
  },
  webServer: {
    command: 'python3 -m http.server 4397',
    port: 4397,
    cwd: '../../',
    reuseExistingServer: true,
    timeout: 10000,
  },
});

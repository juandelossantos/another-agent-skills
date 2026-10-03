// @ts-check
import { defineConfig, devices } from '@playwright/test';

const PORT = 4321;
const BASE = '/another-agent-skills/';

// Playwright smoke runs against the BUILT static output, served by `astro preview`
// (which honors `base`). Build first: `npm run build`.
export default defineConfig({
  testDir: './tests',
  testMatch: '**/*.spec.mjs',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  reporter: [['list']],
  use: {
    baseURL: `http://localhost:${PORT}${BASE}`,
    trace: 'off',
  },
  webServer: {
    command: 'node tests/static-server.mjs',
    url: `http://localhost:${PORT}${BASE}`,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});

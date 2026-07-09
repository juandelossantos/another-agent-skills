import { test, expect } from '@playwright/test';

test('docs page shows previous release in history', async ({ page }) => {
  await page.goto('/docs/');
  await expect(page.locator('body')).toBeVisible();
  const body = await page.textContent('body');
  expect(body).toContain('v3.0.0');
});

test('docs page shows correct skill count', async ({ page }) => {
  await page.goto('/docs/');
  const body = await page.textContent('body');
  expect(body).toContain('57');
});

test('universal-loop docs page loads', async ({ page }) => {
  await page.goto('/docs/universal-loop.html');
  await expect(page.locator('body')).toBeVisible();
  const title = await page.textContent('h1');
  expect(title).toContain('Universal');
});

test('no console errors on docs page', async ({ page }) => {
  const errors = [];
  page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
  await page.goto('/docs/');
  expect(errors.length).toBe(0);
});

test('self-improvement skill page loads', async ({ page }) => {
  await page.goto('/docs/skill/self-improvement.html');
  await expect(page.locator('body')).toBeVisible();
});

test('enforcement page shows current gate counts', async ({ page }) => {
  await page.goto('/docs/enforcement.html');
  const body = await page.textContent('body');
  expect(body).toContain('14 gates');
});

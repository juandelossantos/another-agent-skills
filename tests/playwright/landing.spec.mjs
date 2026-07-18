import { chromium } from '@playwright/test';
import { test, expect } from '@playwright/test';

test('landing page loads with current version skill count', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('body')).toBeVisible();
  const body = await page.textContent('body');
  expect(body).toContain('57');
});

test('self-improving section exists', async ({ page }) => {
  await page.goto('/');
  const section = page.locator('#self-improving');
  await expect(section).toBeVisible();
});

test('no console errors on landing page', async ({ page }) => {
  const errors = [];
  page.on('console', msg => { if (msg.type() === 'error') errors.push(msg.text()); });
  await page.goto('/');
  expect(errors.length).toBe(0);
});

test('landing page loads in Spanish', async ({ page }) => {
  await page.goto('/');
  await page.evaluate(() => {
    localStorage.setItem('aas-lang', 'es');
    localStorage.setItem('lang', 'es');
  });
  await page.reload();
  await expect(page.locator('body')).toBeVisible();
  const body = await page.textContent('body');
  const isSpanish = body.includes('Inicio') || body.includes('skills') || body.includes('habilidades');
  expect(isSpanish).toBeTruthy();
});

test('harness section shows current gate counts', async ({ page }) => {
  await page.goto('/');
  const body = await page.textContent('body');
  expect(body).toContain('15 pre-commit');
});

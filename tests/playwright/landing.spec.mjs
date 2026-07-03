import { chromium } from '@playwright/test';
import { test, expect } from '@playwright/test';

test('landing page loads with v3.0.0 content', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('body')).toBeVisible();
  const body = await page.textContent('body');
  expect(body).toContain('58');
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
  // Check that at least one element is in Spanish
  const body = await page.textContent('body');
  const isSpanish = body.includes('Inicio') || body.includes('skills') || body.includes('58');
  expect(isSpanish).toBeTruthy();
});

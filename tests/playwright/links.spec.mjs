import { test, expect } from '@playwright/test';

test('all internal links on landing page are valid', async ({ page }) => {
  await page.goto('/');
  const links = await page.locator('a[href^="/"]').all();
  const results = await Promise.allSettled(
    links.map(async (link) => {
      const href = await link.getAttribute('href');
      if (!href || href.startsWith('https://')) return { href, status: 'ok' };
      try {
        const resp = await page.goto(href);
        return { href, status: resp ? resp.status() : 'no response' };
      } catch { return { href, status: 'error' }; }
    })
  );
  const errors = results.filter(r => r.status === 'fulfilled' && r.value.status !== 200 && r.value.status !== 'ok');
  expect(errors.length).toBe(0);
});

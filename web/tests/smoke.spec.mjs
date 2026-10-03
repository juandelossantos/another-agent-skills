/*
 * Playwright smoke — runs against the built output served by `astro preview`
 * (see playwright.config.mjs). Covers both locales, both themes, console
 * cleanliness, and no horizontal overflow on a 390px viewport.
 *
 * Paths are relative to baseURL (`/another-agent-skills/`), so use `./` and
 * `es/` — a leading `/` would drop the base path.
 */
import { test, expect } from '@playwright/test';

function collectErrors(page) {
  const errors = [];
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(`console: ${msg.text()}`);
  });
  page.on('pageerror', (err) => errors.push(`pageerror: ${err.message}`));
  return errors;
}

test.describe('EN landing', () => {
  test('renders with zero console/page errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('./');
    await expect(page.locator('h1')).toContainText('Turn AI agents into');
    await expect(page.locator('#flow')).toBeVisible();
    await expect(page.locator('#enforcement')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('theme toggle switches and persists across reload', async ({ page }) => {
    await page.goto('./');
    const html = page.locator('html');

    // Don't assume the OS preference: read the applied theme, flip it, and
    // assert the choice persists across a reload.
    const initial = await html.getAttribute('data-theme');
    const toggled = initial === 'dark' ? 'light' : 'dark';

    await page.locator('[data-action="theme"]').click();
    await expect(html).toHaveAttribute('data-theme', toggled);

    await page.reload();
    await expect(html).toHaveAttribute('data-theme', toggled);
  });

  test('no horizontal overflow at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('./');
    const overflow = await page.evaluate(() => {
      const doc = document.documentElement;
      return doc.scrollWidth - doc.clientWidth;
    });
    expect(overflow).toBeLessThanOrEqual(1);
  });

  test('language link points to the ES route', async ({ page }) => {
    await page.goto('./');
    const langLink = page.locator('a.header__control[hreflang="es"]');
    await expect(langLink).toBeVisible();
    await expect(langLink).toHaveAttribute('href', /\/another-agent-skills\/es\/$/);
  });
});

test.describe('ES landing', () => {
  test('renders in Spanish with zero console errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('es/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
    await expect(page.locator('h1')).toContainText('Convierte agentes de IA');
    await expect(page.locator('#enforcement')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('language link points back to the EN route', async ({ page }) => {
    await page.goto('es/');
    const langLink = page.locator('a.header__control[hreflang="en"]');
    await expect(langLink).toHaveAttribute('href', /\/another-agent-skills\/$/);
  });

  test('no horizontal overflow at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('es/');
    const overflow = await page.evaluate(() => {
      const doc = document.documentElement;
      return doc.scrollWidth - doc.clientWidth;
    });
    expect(overflow).toBeLessThanOrEqual(1);
  });
});

test.describe('reduced motion', () => {
  test.use({ reducedMotion: 'reduce' });

  test('content stays visible with reduced motion', async ({ page }) => {
    await page.goto('./');
    // The flow nodes must be lit/visible (static fallback), not dimmed.
    await expect(page.locator('.flow__node').first()).toBeVisible();
    await expect(page.locator('.harness__blocked-note')).toBeVisible();
  });
});

/* ------------------------------------------------------------------ *
 * Docs site smoke
 * ------------------------------------------------------------------ */

test.describe('docs EN', () => {
  test('renders the shell (sidebar, content, TOC) with zero console errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('docs/enforcement/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page.locator('.docs-sidebar')).toBeVisible();
    await expect(page.locator('.docs-sidebar a[aria-current="page"]')).toContainText('Enforcement');
    await expect(page.locator('h1.docs-title')).toContainText('Enforcement');
    await expect(page.locator('.docs-tldr')).toBeVisible();
    await expect(page.locator('[data-toc-list]')).toBeVisible();
    await expect(page.locator('.docs-content h2').first()).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('search overlay opens, filters, marks matches, and closes on Escape', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('docs/enforcement/');

    const input = page.locator('#docs-search-input');
    await input.click();
    await expect(page.locator('#docs-search-panel')).toBeVisible();
    await expect(input).toHaveAttribute('aria-expanded', 'true');

    await input.fill('branch');
    await expect(page.locator('[data-search-item]').first()).toBeVisible();
    await expect(page.locator('#docs-search-panel mark').first()).toBeVisible();
    await expect(page.locator('[data-search-count]')).toContainText('result');

    await input.press('Escape');
    await expect(page.locator('#docs-search-panel')).toBeHidden();
    await expect(input).toHaveAttribute('aria-expanded', 'false');
    expect(errors).toEqual([]);
  });

  test('Ctrl K focuses the search input', async ({ page }) => {
    await page.goto('docs/enforcement/');
    await page.keyboard.press('Control+k');
    await expect(page.locator('#docs-search-input')).toBeFocused();
  });

  test('TOC scroll-spy follows the page', async ({ page }) => {
    await page.goto('docs/enforcement/');
    await page.evaluate(() => document.getElementById('turn-it-on')?.scrollIntoView());
    await expect(page.locator('[data-toc-list] a[href="#turn-it-on"]')).toHaveClass(/is-active/);
  });

  test('theme toggle switches and persists across reload', async ({ page }) => {
    await page.goto('docs/enforcement/');
    const html = page.locator('html');
    const initial = await html.getAttribute('data-theme');
    const toggled = initial === 'dark' ? 'light' : 'dark';
    await page.locator('.docs-header [data-action="theme"]').click();
    await expect(html).toHaveAttribute('data-theme', toggled);
    await page.reload();
    await expect(html).toHaveAttribute('data-theme', toggled);
  });

  test('mobile drawer opens and closes at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('docs/enforcement/');
    const menu = page.locator('[data-action="sidebar"]');
    await expect(menu).toBeVisible();
    await menu.click();
    await expect(page.locator('#docs-sidebar')).toHaveClass(/is-open/);
    await page.keyboard.press('Escape');
    await expect(page.locator('#docs-sidebar')).not.toHaveClass(/is-open/);
  });

  test('no horizontal overflow at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('docs/enforcement/');
    const overflow = await page.evaluate(() => {
      const doc = document.documentElement;
      return doc.scrollWidth - doc.clientWidth;
    });
    expect(overflow).toBeLessThanOrEqual(1);
  });

  test('language link points to the ES docs route', async ({ page }) => {
    await page.goto('docs/enforcement/');
    const langLink = page.locator('a.header__control[hreflang="es"]');
    await expect(langLink).toHaveAttribute(
      'href',
      /\/another-agent-skills\/es\/docs\/enforcement\/$/,
    );
  });
});

test.describe('docs ES', () => {
  test('renders in Spanish with zero console errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('es/docs/enforcement/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
    await expect(page.locator('h1.docs-title')).toContainText('Enforcement');
    await expect(page.locator('.docs-sidebar a[aria-current="page"]')).toContainText('Enforcement');
    await expect(page.locator('.docs-tldr')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('no horizontal overflow at 390px', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto('es/docs/enforcement/');
    const overflow = await page.evaluate(() => {
      const doc = document.documentElement;
      return doc.scrollWidth - doc.clientWidth;
    });
    expect(overflow).toBeLessThanOrEqual(1);
  });
});


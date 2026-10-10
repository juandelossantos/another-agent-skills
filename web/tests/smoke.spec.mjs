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

  test('the Docs nav link resolves to the in-site docs route', async ({ page }) => {
    await page.goto('./');
    const docsLink = page.locator('.header__links a', { hasText: 'Docs' });
    await expect(docsLink).toHaveAttribute('href', /\/another-agent-skills\/docs\/$/);
    await docsLink.click();
    await expect(page).toHaveURL(/\/another-agent-skills\/docs\/$/);
    await expect(page.locator('h1.docs-title')).toBeVisible();
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

  test('the Docs nav link resolves to the ES in-site docs route', async ({ page }) => {
    await page.goto('es/');
    const docsLink = page.locator('.header__links a', { hasText: 'Docs' });
    await expect(docsLink).toHaveAttribute('href', /\/another-agent-skills\/es\/docs\/$/);
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

  test('the hero terminal commands fit without horizontal scroll at desktop width', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 900 });
    await page.goto('./');
    // With reduced motion the terminal renders fully typed (static), so every
    // command line must fit its box — no inner horizontal scrollbar.
    const overflowing = await page.evaluate(() =>
      Array.from(document.querySelectorAll('.terminal__typing'))
        .filter((el) => el.scrollWidth > el.clientWidth + 1)
        .map((el) => el.textContent.trim()),
    );
    expect(overflowing).toEqual([]);
  });
});

test.describe('no JavaScript', () => {
  test.use({ javaScriptEnabled: false });

  test('landing content stays visible and static', async ({ page }) => {
    await page.goto('./');
    await expect(page.locator('h1')).toContainText('Turn AI agents into');
    await expect(page.locator('#enforcement')).toBeVisible();
    await expect(page.locator('.flow__node').first()).toBeVisible();
    // The terminal output is only hidden by JS; without JS it must be visible.
    await expect(page.locator('.terminal__output')).toBeVisible();
  });

  test('docs shell stays visible and the search stays a plain input', async ({ page }) => {
    await page.goto('docs/enforcement/');
    await expect(page.locator('.docs-sidebar')).toBeVisible();
    await expect(page.locator('h1.docs-title')).toContainText('Enforcement');
    await expect(page.locator('.docs-content')).toBeVisible();
    await expect(page.locator('#docs-search-panel')).toBeHidden();
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

  test('a Bloque E tutorial renders with commands, outcome and active nav', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('docs/first-gated-commit/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'en');
    await expect(page.locator('h1.docs-title')).toContainText('Your first gated commit');
    await expect(page.locator('.docs-sidebar a[aria-current="page"]')).toContainText(
      'Your first gated commit',
    );
    await expect(page.locator('.docs-tldr')).toBeVisible();
    await expect(page.locator('.docs-content pre').first()).toBeVisible();
    await expect(page.locator('.docs-content')).toContainText('What you should see');
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

  test('a Bloque E tutorial renders in neutral Spanish', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('es/docs/first-gated-commit/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
    await expect(page.locator('h1.docs-title')).toContainText('Tu primer commit con compuerta');
    await expect(page.locator('.docs-content')).toContainText('Lo que deberías ver');
    await expect(page.locator('.docs-content pre').first()).toBeVisible();
    expect(errors).toEqual([]);
  });
});

/* ------------------------------------------------------------------ *
 * Skills reference catalog
 * ------------------------------------------------------------------ */

test.describe('skills reference', () => {
  test('EN renders the grouped catalog with zero console errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('docs/skills/');
    await expect(page.locator('h1.docs-title')).toContainText('Skills');
    await expect(page.locator('.skills-catalog')).toBeVisible();
    await expect(page.locator('.skill')).toHaveCount(58);
    await expect(page.locator('#cat-testing')).toBeVisible();
    await expect(page.locator('.skill__source').first()).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('ES renders the catalog in Spanish with zero console errors', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('es/docs/skills/');
    await expect(page.locator('.skill')).toHaveCount(58);
    await expect(page.locator('.docs-content')).toContainText('Se activa cuando');
    expect(errors).toEqual([]);
  });

  test('the compact index links jump to the category anchors', async ({ page }) => {
    await page.goto('docs/skills/');
    await page.locator('a[href="#cat-testing"]').first().click();
    await expect(page.locator('#cat-testing')).toBeInViewport();
  });

  test('search finds a skill by name and opens its anchor', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('docs/skills/');

    const input = page.locator('#docs-search-input');
    await input.click();
    await expect(page.locator('#docs-search-panel')).toBeVisible();

    await input.fill('doubt');
    const item = page
      .locator('[data-search-item]', { hasText: 'doubt-driven-development' })
      .first();
    await expect(item).toBeVisible();
    await expect(item.locator('mark')).toBeVisible();

    await item.click();
    await expect(page).toHaveURL(/#skill-doubt-driven-development$/);
    await expect(page.locator('#skill-doubt-driven-development')).toBeInViewport();
    expect(errors).toEqual([]);
  });

  test('search finds a skill in ES and opens its /es anchor', async ({ page }) => {
    await page.goto('es/docs/skills/');
    const input = page.locator('#docs-search-input');
    await input.click();
    await input.fill('doubt');
    const item = page
      .locator('[data-search-item]', { hasText: 'doubt-driven-development' })
      .first();
    await expect(item).toBeVisible();
    await item.click();
    await expect(page).toHaveURL(/es\/docs\/skills\/#skill-doubt-driven-development$/);
  });

  test('the sidebar Skills group navigates to a skill anchor', async ({ page }) => {
    await page.goto('docs/enforcement/');
    // The group is collapsed by default; expand it and a category (native <details>).
    await page.locator('[data-skills-group] > summary').click();
    await page.locator('[data-skill-category="process"] > summary').click();
    await page.locator('[data-skill-link="doubt-driven-development"]').click();
    await expect(page).toHaveURL(/\/docs\/skills\/#skill-doubt-driven-development$/);
    await expect(page.locator('#skill-doubt-driven-development')).toBeInViewport();
  });

  test('opening a skill anchor reveals and marks its sidebar link', async ({ page }) => {
    await page.goto('docs/skills/#skill-doubt-driven-development');
    const link = page.locator('[data-skill-link="doubt-driven-development"]');
    // The category is collapsed in the markup; the enhancement opens it.
    await expect(link).toBeVisible();
    await expect(link).toHaveClass(/is-active/);
    await expect(page.locator('#skill-doubt-driven-development')).toBeInViewport();
  });
});

/* ------------------------------------------------------------------ *
 * Sidebar consistency + edit link
 * ------------------------------------------------------------------ */

test.describe('sidebar consistency', () => {
  test('all top-level sections are uniform collapsible <details>', async ({ page }) => {
    await page.goto('docs/enforcement/');
    const groups = page.locator('.docs-nav > details.docs-nav__group');
    await expect(groups).toHaveCount(5);
    // Every section is a native <details> with its own <summary> label.
    await expect(groups.locator('> summary')).toHaveCount(5);
    // Only the section holding the current page (Concepts) is open.
    const open = page.locator('.docs-nav > details.docs-nav__group[open]');
    await expect(open).toHaveCount(1);
    await expect(open.locator('> summary')).toContainText('Concepts');
  });

  test('"Skills" appears exactly once and expands to the categories and skills', async ({ page }) => {
    await page.goto('docs/enforcement/');
    await expect(page.locator('.docs-nav a', { hasText: /^Skills$/ })).toHaveCount(1);

    // The branch is a native <details>; the chevron summary toggles it.
    await page.locator('[data-skills-group] > summary').click();
    await expect(page.locator('[data-skill-category]')).toHaveCount(13);
    await expect(page.locator('[data-skill-link]')).toHaveCount(58);
  });

  test('the edit link opens the GitHub editor for the page locale file', async ({ page }) => {
    await page.goto('docs/skills/');
    const en = page.locator('.docs-edit a');
    await expect(en).toHaveAttribute('href', /\/edit\/main\/web\/src\/content\/docs\/skills\.en\.md$/);
    await expect(en).toHaveAttribute('target', '_blank');
    await expect(en).toHaveAttribute('rel', /noopener/);

    await page.goto('es/docs/skills/');
    await expect(page.locator('.docs-edit a')).toHaveAttribute(
      'href',
      /\/edit\/main\/web\/src\/content\/docs\/skills\.es\.md$/,
    );
  });
});

/* ------------------------------------------------------------------ *
 * Discoverability (social card + AEO search deep link)
 * ------------------------------------------------------------------ */

test.describe('discoverability', () => {
  test('the social card is served as a real PNG', async ({ page }) => {
    const res = await page.request.get('og.png');
    expect(res.status()).toBe(200);
    expect(res.headers()['content-type']).toContain('image/png');
    const body = await res.body();
    // 1200x630 PNG signature + non-trivial size (not the old placeholder).
    expect(body.slice(1, 4).toString('ascii')).toBe('PNG');
    expect(body.readUInt32BE(16)).toBe(1200);
    expect(body.readUInt32BE(20)).toBe(630);
    expect(body.length).toBeGreaterThan(20_000);
  });

  test('og:image and twitter:image use the absolute card URL', async ({ page }) => {
    await page.goto('./');
    const og = await page.locator('meta[property="og:image"]').getAttribute('content');
    const tw = await page.locator('meta[name="twitter:image"]').getAttribute('content');
    expect(og).toMatch(/^https:\/\/juandelossantos\.github\.io\/another-agent-skills\/og\.png$/);
    expect(tw).toBe(og);
  });

  test('the docs search deep link (?q=) opens the overlay pre-filled', async ({ page }) => {
    await page.goto('docs/?q=branch');
    const input = page.locator('#docs-search-input');
    await expect(input).toHaveValue('branch');
    await expect(page.locator('#docs-search-panel')).toBeVisible();
    await expect(page.locator('[data-search-item]').first()).toBeVisible();
  });
});

/* ------------------------------------------------------------------ *
 * Theme toggle advertises the TARGET mode (label + icon), not the
 * current one. aria-pressed still reflects the current state.
 * ------------------------------------------------------------------ */

const THEME_CASES = [
  { name: 'landing EN', path: './', toDark: 'Dark', toLight: 'Light' },
  { name: 'landing ES', path: 'es/', toDark: 'Oscuro', toLight: 'Claro' },
  { name: 'docs EN', path: 'docs/enforcement/', toDark: 'Dark', toLight: 'Light' },
  { name: 'docs ES', path: 'es/docs/enforcement/', toDark: 'Oscuro', toLight: 'Claro' },
];

for (const c of THEME_CASES) {
  test(`${c.name}: theme toggle names the target mode`, async ({ page }) => {
    await page.addInitScript(() => {
      try {
        localStorage.setItem('aas-theme', 'light');
      } catch {
        /* ignore */
      }
    });
    await page.goto(c.path);

    const html = page.locator('html');
    const btn = page.locator('[data-action="theme"]').first();
    const text = btn.locator('[data-theme-text]');

    // Light mode: the current state is light (aria-pressed), the label and
    // icon advertise the target (dark).
    await expect(html).toHaveAttribute('data-theme', 'light');
    await expect(btn).toHaveAttribute('aria-pressed', 'true');
    await expect(text).toHaveText(c.toDark);
    await expect(btn.locator('.icon--moon')).toBeVisible();
    await expect(btn.locator('.icon--sun')).toBeHidden();

    // Switch to dark: the target becomes light.
    await btn.click();
    await expect(html).toHaveAttribute('data-theme', 'dark');
    await expect(btn).toHaveAttribute('aria-pressed', 'false');
    await expect(text).toHaveText(c.toLight);
    await expect(btn.locator('.icon--sun')).toBeVisible();
    await expect(btn.locator('.icon--moon')).toBeHidden();
  });
}

/* ------------------------------------------------------------------ *
 * Docs never break words mid-word; wide tables scroll instead.
 * ------------------------------------------------------------------ */

const TABLE_PAGES = [
  { name: 'docs EN', path: 'docs/agents/' },
  { name: 'docs ES', path: 'es/docs/agents/' },
];

for (const p of TABLE_PAGES) {
  test(`${p.name}: no aggressive word-breaking in prose, lists, code or tables`, async ({ page }) => {
    await page.goto(p.path);

    // Nothing in the rendered docs may use the aggressive modes.
    const aggressive = await page.evaluate(() => {
      const bad = [];
      document.querySelectorAll('.docs-content *').forEach((el) => {
        const cs = getComputedStyle(el);
        if (cs.wordBreak === 'break-all' || cs.overflowWrap === 'anywhere' || cs.hyphens === 'auto') {
          bad.push(`${el.tagName}.${el.className} => ${cs.wordBreak} / ${cs.overflowWrap} / ${cs.hyphens}`);
        }
      });
      return bad;
    });
    expect(aggressive).toEqual([]);

    // Prose, lists, inline code and table cells break only at word boundaries.
    const prose = await page.evaluate(() => {
      const sel = '.docs-content p, .docs-content li, .docs-content th, .docs-content td, .docs-content code:not(pre code)';
      return Array.from(document.querySelectorAll(sel)).map((el) => {
        const cs = getComputedStyle(el);
        return { tag: el.tagName, wordBreak: cs.wordBreak, overflowWrap: cs.overflowWrap };
      });
    });
    expect(prose.length).toBeGreaterThan(0);
    for (const s of prose) {
      expect(s.wordBreak, `${s.tag} word-break`).toBe('normal');
      expect(s.overflowWrap, `${s.tag} overflow-wrap`).toBe('break-word');
    }
  });

  test(`${p.name}: wide tables scroll with 0 horizontal page overflow at 390px`, async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    await page.goto(p.path);

    const overflow = await page.evaluate(() => {
      const doc = document.documentElement;
      return doc.scrollWidth - doc.clientWidth;
    });
    expect(overflow).toBeLessThanOrEqual(1);

    // The rendered table is wrapped and scrolls horizontally rather than
    // squeezing its columns into mid-word breaks.
    const wrap = page.locator('.docs-table-wrap').first();
    await expect(wrap).toBeVisible();
    const scrolls = await wrap.evaluate((el) => el.scrollWidth > el.clientWidth + 1);
    expect(scrolls).toBe(true);
  });
}

/* ------------------------------------------------------------------ *
 * Code copy buttons (docs). A denied async clipboard (insecure context,
 * permission, document not focused) must fall back to execCommand instead
 * of raising an unhandled rejection and silently doing nothing.
 * ------------------------------------------------------------------ */

const COPY_PAGES = [
  { name: 'docs EN', path: 'docs/enforcement/' },
  { name: 'docs ES', path: 'es/docs/enforcement/' },
];

for (const p of COPY_PAGES) {
  test(`${p.name}: the code copy button reports a result with zero console errors`, async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto(p.path);
    const btn = page.locator('.docs-copy').first();
    await expect(btn).toBeVisible();
    await btn.click();
    await expect(btn).toHaveAttribute('data-copied', 'true');
    // The unhandled `writeText` rejection used to surface here.
    expect(errors).toEqual([]);
  });
}

/* ------------------------------------------------------------------ *
 * Blog (index + article, EN + ES)
 * ------------------------------------------------------------------ */

test.describe('blog', () => {
  test('EN index renders the publication home and links to the featured post', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('blog/');
    await expect(page.locator('h1.blog-index__title')).toBeVisible();
    await expect(page.locator('.blog-featured')).toBeVisible();
    await expect(page.locator('.blog-index__rss')).toBeVisible();
    await page.locator('.blog-featured__title a').click();
    await expect(page).toHaveURL(/\/another-agent-skills\/blog\/the-human-in-command\/$/);
    await expect(page.locator('h1.blog-post__title')).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('EN post renders the cover+title hero, byline, TOC, share and prose', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('blog/the-human-in-command/');
    await expect(page.locator('h1.blog-post__title')).toContainText('The human defines');
    await expect(page.locator('.blog-post__hero img')).toBeVisible();
    await expect(page.locator('.blog-post__byline')).toContainText('David Emilio Sierra Puentes');
    await expect(page.locator('.blog-post__tldr')).toBeVisible();
    await expect(page.locator('.blog-toc')).toBeVisible();
    await expect(page.locator('.blog-post__share, .blog-share').first()).toBeVisible();
    await expect(page.locator('.blog-prose h2').first()).toBeVisible();
    expect(errors).toEqual([]);
  });

  test('the share "copy link" button reports a result', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('blog/the-human-in-command/');
    const btn = page.locator('[data-share-copy]').first();
    await expect(btn).toBeVisible();
    await btn.click();
    await expect(btn).toHaveAttribute('data-copied', 'true');
    expect(errors).toEqual([]);
  });

  test('the table of contents links jump to a section', async ({ page }) => {
    await page.goto('blog/the-human-in-command/');
    const first = page.locator('.blog-toc__item a').first();
    const href = await first.getAttribute('href');
    await first.click();
    await expect(page.locator(`.blog-prose ${href}`)).toBeInViewport();
  });

  test('no horizontal overflow at 390px (index + post)', async ({ page }) => {
    await page.setViewportSize({ width: 390, height: 844 });
    for (const path of ['blog/', 'blog/the-human-in-command/']) {
      await page.goto(path);
      const overflow = await page.evaluate(() => {
        const doc = document.documentElement;
        return doc.scrollWidth - doc.clientWidth;
      });
      expect(overflow, `${path} overflows`).toBeLessThanOrEqual(1);
    }
  });

  test('ES index + post render in Spanish', async ({ page }) => {
    const errors = collectErrors(page);
    await page.goto('es/blog/');
    await expect(page.locator('html')).toHaveAttribute('lang', 'es');
    await page.goto('es/blog/the-human-in-command/');
    await expect(page.locator('h1.blog-post__title')).toContainText('El humano define');
    await expect(page.locator('.blog-post__byline')).toContainText('David Emilio Sierra Puentes');
    expect(errors).toEqual([]);
  });

  test('the language link on a post points to the ES post', async ({ page }) => {
    await page.goto('blog/the-human-in-command/');
    const langLink = page.locator('a.header__control[hreflang="es"]');
    await expect(langLink).toHaveAttribute(
      'href',
      /\/another-agent-skills\/es\/blog\/the-human-in-command\/$/,
    );
  });

  test('the landing nav works from the blog (anchor returns to the landing)', async ({ page }) => {
    await page.goto('blog/');
    const flow = page.locator('.header__links a', { hasText: /^Flow$/ });
    await expect(flow).toHaveAttribute('href', /\/another-agent-skills\/#flow$/);
  });
});


/*
 * Automated accessibility gate (axe-core via Playwright).
 *
 * Runs axe on the landing (EN + ES) and a docs page (EN + ES), in both themes,
 * at desktop and 390px. Asserts ZERO violations for WCAG 2.1/2.2 A + AA.
 *
 * Paths are relative to baseURL (`/another-agent-skills/`), so use `./` and
 * `es/` — a leading `/` would drop the base path.
 *
 * Any rule that is genuinely not applicable is disabled *individually* with a
 * documented reason below — never blanket-disabled.
 */
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

// axe's contrast check blends an element's transient opacity while a fade-in
// transition is mid-flight, which produces false "low contrast" reports that
// are not WCAG violations of the settled page. Run axe on the settled DOM:
// emulate the site's own reduced-motion path (a first-class, supported state)
// and freeze the reveal transition so the scan is deterministic.
test.use({ reducedMotion: 'reduce' });

const SETTLE_CSS =
  '*{animation:none!important;transition:none!important}' +
  '[data-anim="on"] [data-reveal]:not([data-revealed="true"]){opacity:1!important;transform:none!important}' +
  // The flow diagram's pre-reveal "dormant" state (opacity .28) is transient:
  // it lights up on scroll, and reduced motion skips it. Neutralize it so the
  // settled-state scan is deterministic in either motion mode.
  '[data-flow][data-state="ready"] .flow__node{opacity:1!important}';

const TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

/** Rules disabled with a reason (keep this list empty unless justified). */
const DISABLED_RULES = [
  // Example shape (not currently used):
  // { id: 'region', reason: 'The docs shell uses <main>/<aside> landmarks; the
  //   landing has a single <main> and header/footer — verified manually.' },
];

const PAGES = [
  { name: 'landing EN', path: './' },
  { name: 'landing ES', path: 'es/' },
  { name: 'docs EN', path: 'docs/enforcement/' },
  { name: 'docs ES', path: 'es/docs/enforcement/' },
  { name: 'tutorial EN', path: 'docs/first-gated-commit/' },
  { name: 'tutorial ES', path: 'es/docs/first-gated-commit/' },
  { name: 'skills EN', path: 'docs/skills/' },
  { name: 'skills ES', path: 'es/docs/skills/' },
];

const THEMES = ['light', 'dark'];
const VIEWPORTS = [
  { name: 'desktop', width: 1280, height: 800 },
  { name: '390px', width: 390, height: 844 },
];

function formatViolations(violations) {
  return violations
    .map((v) => {
      const nodes = v.nodes
        .map((n) => `      - ${n.target.join(' ')} :: ${n.failureSummary?.replace(/\n/g, ' ')}`)
        .join('\n');
      return `  [${v.impact}] ${v.id}: ${v.help}\n${nodes}`;
    })
    .join('\n');
}

for (const p of PAGES) {
  for (const theme of THEMES) {
    for (const vp of VIEWPORTS) {
      test(`${p.name} · ${theme} · ${vp.name} · axe 0 violations`, async ({ page }) => {
        await page.addInitScript((t) => {
          try {
            localStorage.setItem('aas-theme', t);
          } catch {
            /* ignore */
          }
        }, theme);
        await page.setViewportSize({ width: vp.width, height: vp.height });
        await page.goto(p.path);
        // Ensure the inline theme bootstrap applied our choice.
        await expect(page.locator('html')).toHaveAttribute('data-theme', theme);
        await page.addStyleTag({ content: SETTLE_CSS });

        let builder = new AxeBuilder({ page }).withTags(TAGS);
        for (const rule of DISABLED_RULES) {
          builder = builder.disableRules(rule.id);
        }
        const results = await builder.analyze();

        expect(
          results.violations,
          `axe violations on ${p.name} (${theme}, ${vp.name}):\n${formatViolations(results.violations)}`,
        ).toEqual([]);
      });
    }
  }
}

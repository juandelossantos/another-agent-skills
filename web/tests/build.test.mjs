/*
 * Build assertions — run with `node --test tests/build.test.mjs` after
 * `astro build`. They check the built `dist/` output (not the source), so they
 * catch routing, i18n, SEO and AEO regressions the way a crawler would see them.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const DIST = fileURLToPath(new URL('../dist/', import.meta.url));
const read = (rel) => readFileSync(new URL(rel, new URL('../dist/', import.meta.url)), 'utf8');
const has = (rel) => existsSync(new URL(rel, new URL('../dist/', import.meta.url)));

const SITE = 'https://juandelossantos.github.io';
const BASE = '/another-agent-skills';

test('build produced the expected pages and SEO files', () => {
  for (const rel of [
    'index.html',
    'es/index.html',
    'sitemap-index.xml',
    'robots.txt',
    'llms.txt',
    'favicon.svg',
    'og.png',
  ]) {
    assert.ok(has(rel), `missing dist/${rel}`);
  }
});

test('EN landing renders the hero, terminal channels and lifecycle', () => {
  const html = read('index.html');
  assert.match(html, /Turn AI agents into/);
  assert.match(html, /disciplined senior engineers/);
  assert.match(html, /Most skill libraries sell capability/);
  // three install channels
  assert.match(html, /git clone https:\/\/github\.com\/juandelossantos\/another-agent-skills\.git/);
  assert.match(html, /releases\/latest\/download\/bootstrap\.sh/);
  assert.match(html, /npx @juandelossantos\/another-agent-skills install/);
  // lifecycle strip
  assert.match(html, /DEFINE/);
  assert.match(html, /SHIP/);
});

test('EN landing has all sections and the L1/L2/L3 proof', () => {
  const html = read('index.html');
  for (const id of ['problem', 'flow', 'harness', 'loop', 'enforcement', 'compat', 'skills', 'workflows', 'faq', 'start']) {
    assert.match(html, new RegExp(`id="${id}"`), `missing section #${id}`);
  }
  assert.match(html, /BLOCKED: every code change needs a matching test/);
  assert.match(html, /Local hooks/);
  assert.match(html, /Remote gates check/);
  assert.match(html, /CODEOWNERS review/);
});

test('EN head has canonical, hreflang EN/ES/x-default and OG/Twitter', () => {
  const html = read('index.html');
  assert.match(html, new RegExp(`<link rel="canonical" href="${SITE}${BASE}/"`));
  assert.match(html, new RegExp(`<link rel="alternate" hreflang="en" href="${SITE}${BASE}/"`));
  assert.match(html, new RegExp(`<link rel="alternate" hreflang="es" href="${SITE}${BASE}/es/"`));
  assert.match(html, /hreflang="x-default"/);
  assert.match(html, /property="og:title"/);
  assert.match(html, /name="twitter:card"/);
});

test('ES landing is routed at /es/ and localized (neutral Spanish)', () => {
  const html = read('es/index.html');
  assert.match(html, /<html lang="es"/);
  assert.match(html, /Convierte agentes de IA en/);
  assert.match(html, /ingenieros senior disciplinados/);
  assert.match(html, /DEFINIR/);
  assert.match(html, /ENTREGAR/);
  assert.match(html, new RegExp(`<link rel="canonical" href="${SITE}${BASE}/es/"`));
  // no voseo (Argentine Spanish)
  assert.doesNotMatch(html, /tenés|podés|Cloná|ejecutá|instalá|agregá|mirá|corré|andá/i);
});

test('JSON-LD graph has Organization, WebSite, SoftwareApplication, FAQPage, HowTo, BreadcrumbList', () => {
  const html = read('index.html');
  const blocks = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map((m) => m[1]);
  assert.ok(blocks.length >= 1, 'no JSON-LD block found');
  const json = blocks.join('\n');
  for (const type of ['Organization', 'WebSite', 'SoftwareApplication', 'FAQPage', 'HowTo', 'BreadcrumbList']) {
    assert.match(json, new RegExp(`"@type":\\s*"${type}"`), `JSON-LD missing ${type}`);
  }
  assert.match(json, /"@context":\s*"https:\/\/schema\.org"/);
  // valid JSON
  assert.doesNotThrow(() => JSON.parse(blocks[0]));
});

test('robots.txt allows crawling and points at the sitemap', () => {
  const txt = read('robots.txt');
  assert.match(txt, /User-agent: \*/);
  assert.match(txt, /Allow: \//);
  assert.match(txt, new RegExp(`Sitemap: ${SITE}${BASE}/sitemap-index\\.xml`));
});

test('llms.txt exposes citable facts and links (AEO)', () => {
  const txt = read('llms.txt');
  assert.match(txt, /57 composable skills/);
  assert.match(txt, /MIT/);
  assert.match(txt, /L1/);
  assert.match(txt, /gates/);
  assert.match(txt, /https:\/\/github\.com\/juandelossantos\/another-agent-skills/);
});

test('sitemap-index.xml references the base path and a sitemap file', () => {
  const xml = read('sitemap-index.xml');
  assert.match(xml, new RegExp(`${SITE}${BASE}/`));
  assert.match(xml, /sitemap-0\.xml/);
});

test('built assets are served under the configured base', () => {
  const html = read('index.html');
  assert.match(html, new RegExp(`(href|src)="${BASE}/`));
  assert.ok(!/href="\/_astro\//.test(html), 'asset URL missing the base prefix');
});

test('dist directory resolved', () => {
  assert.ok(existsSync(DIST), `dist not found at ${DIST}`);
});

/* ------------------------------------------------------------------ *
 * Docs site (content collections, search index, sidebar/TOC, JSON-LD)
 * ------------------------------------------------------------------ */

const DOC_SLUGS = [
  'overview',
  'getting-started',
  'lifecycle',
  'skills',
  'enforcement',
  'agents',
  'distribution',
  'branch-protection',
  'faq',
];

/** overview is the docs home; the rest live at /docs/<slug>/. */
const docPath = (locale, slug) => {
  const prefix = locale === 'en' ? '' : 'es/';
  if (slug === 'overview') return `${prefix}docs/index.html`;
  return `${prefix}docs/${slug}/index.html`;
};

test('docs: every page is built in EN and ES', () => {
  for (const slug of DOC_SLUGS) {
    for (const locale of ['en', 'es']) {
      const rel = docPath(locale, slug);
      assert.ok(has(rel), `missing dist/${rel}`);
    }
  }
  assert.ok(has('docs/search.json'), 'missing dist/docs/search.json');
  assert.ok(has('es/docs/search.json'), 'missing dist/es/docs/search.json');
});

test('docs: search index is valid JSON with citable entries per locale', () => {
  for (const rel of ['docs/search.json', 'es/docs/search.json']) {
    const items = JSON.parse(read(rel));
    assert.ok(Array.isArray(items) && items.length >= DOC_SLUGS.length, `${rel} too small`);
    for (const item of items) {
      for (const key of ['title', 'section', 'snippet', 'url']) {
        assert.equal(typeof item[key], 'string', `${rel} item missing ${key}`);
        assert.ok(item[key].length > 0, `${rel} item has empty ${key}`);
      }
      assert.match(item.url, /\/docs\//, `${rel} url not under docs`);
    }
  }
});

test('docs EN page has sidebar (active item), TOC, TL;DR and search overlay', () => {
  const html = read('docs/enforcement/index.html');
  // sidebar nav tree with the active page marked
  assert.match(html, /class="docs-sidebar"/);
  assert.match(html, /docs-nav__link docs-nav__link--active/);
  assert.match(html, /aria-current="page"/);
  // collapsible reference group
  assert.match(html, /class="docs-nav__group"/);
  // on-this-page TOC
  assert.match(html, /data-toc-list/);
  assert.match(html, /docs-toc__link/);
  // citable TL;DR
  assert.match(html, /class="docs-tldr"/);
  assert.match(html, /TL;DR/);
  // search overlay wiring
  assert.match(html, /role="combobox"/);
  assert.match(html, /role="listbox"/);
  assert.match(html, /data-search-src="\/another-agent-skills\/docs\/search\.json"/);
  // pager + edit
  assert.match(html, /class="docs-pager"/);
  assert.match(html, /Edit this page/);
});

test('docs EN page has canonical, hreflang pair and BreadcrumbList JSON-LD', () => {
  const html = read('docs/enforcement/index.html');
  assert.match(html, new RegExp(`<link rel="canonical" href="${SITE}${BASE}/docs/enforcement/"`));
  assert.match(html, new RegExp(`<link rel="alternate" hreflang="en" href="${SITE}${BASE}/docs/enforcement/"`));
  assert.match(html, new RegExp(`<link rel="alternate" hreflang="es" href="${SITE}${BASE}/es/docs/enforcement/"`));
  assert.match(html, /property="og:title"/);
  assert.match(html, /name="twitter:card"/);
  const blocks = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map((m) => m[1]);
  assert.ok(blocks.length >= 1, 'no JSON-LD block on docs page');
  const json = blocks.join('\n');
  assert.match(json, /"@type":\s*"BreadcrumbList"/);
  assert.match(json, /"@type":\s*"TechArticle"/);
  assert.doesNotThrow(() => JSON.parse(blocks[0]));
});

test('docs ES pages are routed under /es/docs and use neutral Spanish', () => {
  const html = read('es/docs/enforcement/index.html');
  assert.match(html, /<html lang="es"/);
  assert.match(html, new RegExp(`<link rel="canonical" href="${SITE}${BASE}/es/docs/enforcement/"`));
  assert.match(html, /Las tres capas/);
  assert.match(html, /En esta página/);
  // no voseo (Argentine Spanish)
  assert.doesNotMatch(html, /tenés|podés|Cloná|ejecutá|instalá|agregá|mirá|corré|andá|hacé/i);
});

test('docs index renders the browse card grid and links to the other pages', () => {
  const html = read('docs/index.html');
  assert.match(html, /class="docs-cards"/);
  assert.match(html, /class="docs-card"/);
  assert.match(html, /href="\/another-agent-skills\/docs\/getting-started\/"/);
});

test('sitemap includes the EN and ES docs pages', () => {
  const xml = read('sitemap-0.xml');
  assert.match(xml, new RegExp(`${SITE}${BASE}/docs/`));
  assert.match(xml, new RegExp(`${SITE}${BASE}/docs/enforcement/`));
  assert.match(xml, new RegExp(`${SITE}${BASE}/es/docs/enforcement/`));
});

test('llms.txt lists the docs routes', () => {
  const txt = read('llms.txt');
  assert.match(txt, new RegExp(`${SITE}${BASE}/docs/`));
  assert.match(txt, new RegExp(`${SITE}${BASE}/es/docs/`));
  assert.match(txt, /Docs search index/);
});


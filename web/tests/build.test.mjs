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
  'first-gated-commit',
  'wire-remote-enforcement',
  'no-git-and-later-git',
  'migrate-a-legacy-project',
  'move-to-another-machine',
  'lifecycle',
  'skills',
  'enforcement',
  'agents',
  'distribution',
  'branch-protection',
  'faq',
];

/** Bloque E tutorials: slug -> the title shown in each locale. */
const TUTORIALS = [
  { slug: 'first-gated-commit', en: 'Your first gated commit', es: 'Tu primer commit con compuerta' },
  { slug: 'wire-remote-enforcement', en: 'Wire the remote enforcement', es: 'Conecta el enforcement remoto' },
  { slug: 'no-git-and-later-git', en: 'Start without git, add it later', es: 'Empieza sin git y agrégalo después' },
  { slug: 'migrate-a-legacy-project', en: 'Migrate a legacy project', es: 'Migra un proyecto heredado' },
  { slug: 'move-to-another-machine', en: 'Move to another machine', es: 'Muévete a otra máquina' },
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

/* ------------------------------------------------------------------ *
 * Bloque E — tutorials, FAQ coverage and the landing Docs links
 * ------------------------------------------------------------------ */

test('tutorials: all five exist in EN and ES with a TL;DR and a Tutorials sidebar group', () => {
  for (const t of TUTORIALS) {
    for (const locale of ['en', 'es']) {
      const rel = docPath(locale, t.slug);
      assert.ok(has(rel), `missing dist/${rel}`);
      const html = read(rel);
      assert.match(html, /class="docs-tldr"/, `${rel} has no TL;DR`);
      assert.match(html, /docs-nav__link--active/, `${rel} has no active sidebar link`);
      assert.match(html, /docs-nav__section">(Tutorials|Tutoriales)</, `${rel} missing the tutorials group`);
    }
  }
});

test('tutorials: each has copy-paste commands and a "what you should see" outcome', () => {
  for (const t of TUTORIALS) {
    for (const locale of ['en', 'es']) {
      const html = read(docPath(locale, t.slug));
      assert.match(html, /<pre/, `${t.slug} (${locale}) has no code block`);
      const outcome = locale === 'en' ? /What you should see/ : /Lo que deberías ver/;
      assert.match(html, outcome, `${t.slug} (${locale}) has no outcome section`);
    }
  }
});

test('tutorials: each is in the search index, the sitemap and llms.txt', () => {
  for (const locale of ['en', 'es']) {
    const items = JSON.parse(read(locale === 'en' ? 'docs/search.json' : 'es/docs/search.json'));
    const urls = items.map((i) => i.url);
    for (const t of TUTORIALS) {
      assert.ok(
        urls.some((u) => u.endsWith(`/docs/${t.slug}/`)),
        `${locale} search index missing ${t.slug}`,
      );
    }
  }
  const xml = read('sitemap-0.xml');
  const txt = read('llms.txt');
  for (const t of TUTORIALS) {
    assert.match(xml, new RegExp(`${BASE}/docs/${t.slug}/`), `sitemap missing ${t.slug}`);
    assert.match(xml, new RegExp(`${BASE}/es/docs/${t.slug}/`), `sitemap missing es/${t.slug}`);
    assert.match(txt, new RegExp(`${BASE}/docs/${t.slug}/`), `llms.txt missing ${t.slug}`);
    assert.match(txt, new RegExp(`${BASE}/es/docs/${t.slug}/`), `llms.txt missing es/${t.slug}`);
  }
});

test('tutorials: the ES pages use neutral Spanish (no voseo)', () => {
  for (const t of TUTORIALS) {
    const html = read(docPath('es', t.slug));
    assert.doesNotMatch(
      html,
      /tenés|podés|Cloná|ejecutá|instalá|agregá|mirá|corré|andá|hacé/i,
      `${t.slug} uses voseo`,
    );
  }
});

test('FAQ answers the Bloque E questions E1-E8 in EN and ES', () => {
  const en = read('docs/faq/index.html');
  const es = read('es/docs/faq/index.html');
  // E1 install once vs per project
  assert.match(en, /per project or once/);
  // E2 cross-platform
  assert.match(en, /Windows, macOS, and Linux/);
  // E3 collaborator without AAS
  assert.match(en, /teammate clones my project/);
  // E4 legacy migration
  assert.match(en, /inherited or migrated a project/);
  assert.match(en, /init-agents --repair/);
  // E5 new machine
  assert.match(en, /changed machines/);
  assert.match(en, /aas install/);
  // E6 version drift
  assert.match(en, /new release/);
  assert.match(en, /non-blocking drift advisory/);
  // E7 L1/L2/L3
  assert.match(en, /What are L1, L2, and L3/);
  // E8 the four git flows
  assert.match(en, /Which git and GitHub setups are supported/);
  assert.match(en, /Git later/);
  // ES parity on the same eight answers
  assert.match(es, /por proyecto o una vez/);
  assert.match(es, /Windows, macOS y Linux/);
  assert.match(es, /no tiene el framework/);
  assert.match(es, /proyecto que usaba el framework/);
  assert.match(es, /Cambié de máquina/);
  assert.match(es, /release nuevo/);
  assert.match(es, /L1, L2 y L3/);
  assert.match(es, /configuraciones de git y GitHub/);
});

test('landing Docs links resolve to the in-site docs routes (base + locale aware)', () => {
  const en = read('index.html');
  const es = read('es/index.html');
  assert.match(en, new RegExp(`href="${BASE}/docs/"`), 'EN landing does not link to /docs/');
  assert.match(es, new RegExp(`href="${BASE}/es/docs/"`), 'ES landing does not link to /es/docs/');
  for (const html of [en, es]) {
    assert.doesNotMatch(
      html,
      /github\.com\/juandelossantos\/another-agent-skills\/tree\/main\/docs/,
      'landing still points at the repository docs folder',
    );
  }
});


/*
 * SEO / AEO / structured-data assertions — run with
 * `node --test tests/seo.test.mjs` after `astro build`.
 *
 * These read the built `dist/` output the way a crawler or an answer engine
 * would: canonical + hreflang, OG/Twitter (with a real absolute image), the
 * sitemap with hreflang alternates, robots.txt, llms.txt, and the JSON-LD graph
 * (parsed as JSON, with the required fields present).
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const dist = (rel) => fileURLToPath(new URL(`../dist/${rel}`, import.meta.url));
const read = (rel) => readFileSync(dist(rel), 'utf8');
const has = (rel) => existsSync(dist(rel));

const SITE = 'https://juandelossantos.github.io';
const BASE = '/another-agent-skills';
const OG_URL = `${SITE}${BASE}/og.png`;

/** Parse every `<script type="application/ld+json">` block on a page. */
function jsonLdBlocks(html) {
  const raw = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map(
    (m) => m[1],
  );
  assert.ok(raw.length >= 1, 'no JSON-LD block found');
  return raw.map((block) => {
    assert.doesNotThrow(() => JSON.parse(block), 'JSON-LD block is not valid JSON');
    return JSON.parse(block);
  });
}

/** Flatten a `@graph` page (or a single node) into its typed nodes. */
function nodesOf(blocks) {
  const nodes = [];
  for (const block of blocks) {
    if (Array.isArray(block['@graph'])) nodes.push(...block['@graph']);
    else nodes.push(block);
  }
  return nodes;
}

const byType = (nodes, type) => nodes.filter((n) => n['@type'] === type);

/** Extract a `<link>`'s href for a rel/hreflang pair. */
function linkHref(html, rel, hreflang) {
  const re = new RegExp(
    `<link rel="${rel}"[^>]*hreflang="${hreflang}"[^>]*href="([^"]+)"|<link rel="${rel}"[^>]*href="([^"]+)"[^>]*hreflang="${hreflang}"`,
  );
  const m = html.match(re);
  return m ? m[1] || m[2] : null;
}

/* ------------------------------------------------------------------ *
 * Social card (the real 1200x630 OG image)
 * ------------------------------------------------------------------ */

test('og.png exists, is a real PNG and is 1200x630', () => {
  assert.ok(has('og.png'), 'missing dist/og.png');
  const buf = readFileSync(dist('og.png'));
  assert.equal(buf.slice(1, 4).toString('ascii'), 'PNG', 'og.png is not a PNG');
  // PNG IHDR: width at byte 16, height at byte 20 (big-endian).
  assert.equal(buf.readUInt32BE(16), 1200, 'og.png width must be 1200');
  assert.equal(buf.readUInt32BE(20), 630, 'og.png height must be 630');
  // The placeholder was ~3 KB; a real rendered card is much larger.
  assert.ok(buf.length > 20_000, `og.png looks like a placeholder (${buf.length} bytes)`);
});

test('the OG card generator is kept in the repo and wired to an npm script', () => {
  assert.ok(has('../scripts/generate-og.mjs'), 'missing scripts/generate-og.mjs');
  const pkg = JSON.parse(readFileSync(fileURLToPath(new URL('../package.json', import.meta.url)), 'utf8'));
  assert.match(pkg.scripts.og, /generate-og\.mjs/);
});

/* ------------------------------------------------------------------ *
 * Per-page head: canonical, hreflang, OG/Twitter
 * ------------------------------------------------------------------ */

const PAGES = [
  { rel: 'index.html', locale: 'en', en: `${SITE}${BASE}/`, es: `${SITE}${BASE}/es/` },
  { rel: 'es/index.html', locale: 'es', en: `${SITE}${BASE}/`, es: `${SITE}${BASE}/es/` },
  {
    rel: 'docs/enforcement/index.html',
    locale: 'en',
    en: `${SITE}${BASE}/docs/enforcement/`,
    es: `${SITE}${BASE}/es/docs/enforcement/`,
  },
  {
    rel: 'es/docs/enforcement/index.html',
    locale: 'es',
    en: `${SITE}${BASE}/docs/enforcement/`,
    es: `${SITE}${BASE}/es/docs/enforcement/`,
  },
  {
    rel: 'docs/first-gated-commit/index.html',
    locale: 'en',
    en: `${SITE}${BASE}/docs/first-gated-commit/`,
    es: `${SITE}${BASE}/es/docs/first-gated-commit/`,
  },
  {
    rel: 'es/docs/first-gated-commit/index.html',
    locale: 'es',
    en: `${SITE}${BASE}/docs/first-gated-commit/`,
    es: `${SITE}${BASE}/es/docs/first-gated-commit/`,
  },
];

for (const page of PAGES) {
  test(`${page.rel}: canonical + hreflang (en/es/x-default) are correct`, () => {
    const html = read(page.rel);
    const canonical = page.locale === 'en' ? page.en : page.es;
    assert.match(html, new RegExp(`<link rel="canonical" href="${canonical}"`));
    assert.equal(linkHref(html, 'alternate', 'en'), page.en);
    assert.equal(linkHref(html, 'alternate', 'es'), page.es);
    // x-default always points at the EN page.
    assert.equal(linkHref(html, 'alternate', 'x-default'), page.en);
  });

  test(`${page.rel}: OG/Twitter tags point at the absolute og.png`, () => {
    const html = read(page.rel);
    for (const prop of ['og:title', 'og:description', 'og:type', 'og:url', 'og:image']) {
      assert.match(html, new RegExp(`property="${prop}"`), `missing ${prop}`);
    }
    for (const name of ['twitter:card', 'twitter:title', 'twitter:description', 'twitter:image']) {
      assert.match(html, new RegExp(`name="${name}"`), `missing ${name}`);
    }
    assert.match(html, new RegExp(`property="og:image" content="${OG_URL.replace(/[.]/g, '\\.')}"`));
    assert.match(html, new RegExp(`name="twitter:image" content="${OG_URL.replace(/[.]/g, '\\.')}"`));
    assert.match(html, /property="og:image:width" content="1200"/);
    assert.match(html, /property="og:image:height" content="630"/);
    assert.match(html, /property="og:image:alt"/);
    assert.match(html, /name="twitter:image:alt"/);
  });
}

/* ------------------------------------------------------------------ *
 * JSON-LD graph
 * ------------------------------------------------------------------ */

test('landing JSON-LD graph is valid and complete', () => {
  const nodes = nodesOf(jsonLdBlocks(read('index.html')));

  const org = byType(nodes, 'Organization')[0];
  assert.ok(org, 'missing Organization');
  for (const field of ['name', 'url', 'logo', 'sameAs']) assert.ok(org[field], `Organization.${field}`);

  const website = byType(nodes, 'WebSite')[0];
  assert.ok(website, 'missing WebSite');
  assert.equal(website.url, `${SITE}${BASE}/`);
  assert.equal(website.inLanguage, 'en');
  assert.ok(website.publisher, 'WebSite.publisher');
  const action = website.potentialAction;
  assert.equal(action?.['@type'], 'SearchAction', 'WebSite.potentialAction must be a SearchAction');
  assert.match(action.target?.urlTemplate ?? '', /\/docs\/\?q=\{search_term_string\}$/);
  assert.equal(action['query-input'], 'required name=search_term_string');

  const app = byType(nodes, 'SoftwareApplication')[0];
  assert.ok(app, 'missing SoftwareApplication');
  for (const field of ['name', 'applicationCategory', 'operatingSystem', 'softwareVersion', 'license', 'offers']) {
    assert.ok(app[field], `SoftwareApplication.${field}`);
  }
  assert.equal(app.offers['@type'], 'Offer');

  const faq = byType(nodes, 'FAQPage')[0];
  assert.ok(faq, 'missing FAQPage');
  assert.ok(Array.isArray(faq.mainEntity) && faq.mainEntity.length >= 5, 'FAQPage needs questions');
  for (const q of faq.mainEntity) {
    assert.equal(q['@type'], 'Question');
    assert.ok(q.name, 'Question.name');
    assert.equal(q.acceptedAnswer?.['@type'], 'Answer');
    assert.ok(q.acceptedAnswer?.text, 'Answer.text');
  }

  const howTo = byType(nodes, 'HowTo')[0];
  assert.ok(howTo, 'missing HowTo');
  assert.ok(Array.isArray(howTo.step) && howTo.step.length >= 3, 'HowTo needs steps');
  howTo.step.forEach((s, i) => {
    assert.equal(s['@type'], 'HowToStep');
    assert.equal(s.position, i + 1);
    assert.ok(s.name && s.text, 'HowToStep.name/text');
  });

  const crumbs = byType(nodes, 'BreadcrumbList')[0];
  assert.ok(crumbs, 'missing BreadcrumbList');
  assert.ok(Array.isArray(crumbs.itemListElement) && crumbs.itemListElement.length >= 1);
});

test('docs JSON-LD graph is valid and has BreadcrumbList + TechArticle', () => {
  for (const rel of ['docs/enforcement/index.html', 'es/docs/enforcement/index.html']) {
    const nodes = nodesOf(jsonLdBlocks(read(rel)));

    const crumbs = byType(nodes, 'BreadcrumbList')[0];
    assert.ok(crumbs, `${rel}: missing BreadcrumbList`);
    assert.ok(crumbs.itemListElement.length >= 3, `${rel}: breadcrumb needs Docs > Section > Page`);

    const article = byType(nodes, 'TechArticle')[0];
    assert.ok(article, `${rel}: missing TechArticle`);
    for (const field of ['headline', 'description', 'inLanguage', 'url', 'isPartOf', 'about']) {
      assert.ok(article[field], `${rel}: TechArticle.${field}`);
    }
    assert.match(article.url, /\/docs\/enforcement\/$/);
  }
});

/* ------------------------------------------------------------------ *
 * Sitemap, robots, llms.txt
 * ------------------------------------------------------------------ */

test('sitemap includes the landing and docs with hreflang alternates', () => {
  const xml = read('sitemap-0.xml');
  for (const url of [
    `${SITE}${BASE}/`,
    `${SITE}${BASE}/es/`,
    `${SITE}${BASE}/docs/`,
    `${SITE}${BASE}/docs/enforcement/`,
    `${SITE}${BASE}/es/docs/enforcement/`,
  ]) {
    assert.match(xml, new RegExp(`<loc>${url.replace(/[.]/g, '\\.')}</loc>`), `sitemap missing ${url}`);
  }
  // Every docs URL carries xhtml:link hreflang alternates.
  assert.match(xml, /xhtml:link rel="alternate" hreflang="en-US"/);
  assert.match(xml, /xhtml:link rel="alternate" hreflang="es-ES"/);
  const docsUrl = xml.match(
    /<url><loc>https:\/\/juandelossantos\.github\.io\/another-agent-skills\/docs\/<\/loc>([\s\S]*?)<\/url>/,
  );
  assert.ok(docsUrl, 'docs entry not found in sitemap');
  assert.match(docsUrl[1], /hreflang="en-US"/);
  assert.match(docsUrl[1], /hreflang="es-ES"/);
});

test('robots.txt allows crawling and references the sitemap index', () => {
  const txt = read('robots.txt');
  assert.match(txt, /User-agent: \*/);
  assert.match(txt, /Allow: \//);
  assert.match(txt, new RegExp(`Sitemap: ${SITE}${BASE}/sitemap-index\\.xml`));
});

test('llms.txt lists the key landing + docs pages in EN and ES with citable facts', () => {
  const txt = read('llms.txt');
  for (const url of [
    `${SITE}${BASE}/`,
    `${SITE}${BASE}/es/`,
    `${SITE}${BASE}/docs/`,
    `${SITE}${BASE}/es/docs/`,
    `${SITE}${BASE}/docs/enforcement/`,
    `${SITE}${BASE}/es/docs/enforcement/`,
    `${SITE}${BASE}/docs/first-gated-commit/`,
    `${SITE}${BASE}/es/docs/move-to-another-machine/`,
  ]) {
    assert.match(txt, new RegExp(url.replace(/[.]/g, '\\.')), `llms.txt missing ${url}`);
  }
  // citable facts
  assert.match(txt, /58/);
  assert.match(txt, /MIT/);
  assert.match(txt, /L1/);
  assert.match(txt, /gates/);
});

/* ------------------------------------------------------------------ *
 * AEO: citable TL;DR per page
 * ------------------------------------------------------------------ */

test('landing exposes citable TL;DR lines (AEO)', () => {
  const html = read('index.html');
  assert.match(html, /TL;DR:/, 'landing has no citable TL;DR');
  assert.match(html, /Most skill libraries sell capability/);
});

test('every docs page renders a citable TL;DR', () => {
  const slugs = [
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
  for (const locale of ['en', 'es']) {
    for (const slug of slugs) {
      const rel =
        slug === 'overview'
          ? `${locale === 'en' ? '' : 'es/'}docs/index.html`
          : `${locale === 'en' ? '' : 'es/'}docs/${slug}/index.html`;
      const html = read(rel);
      assert.match(html, /class="docs-tldr"/, `${rel} has no TL;DR block`);
    }
  }
});

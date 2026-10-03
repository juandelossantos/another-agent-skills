/*
 * Skills reference assertions.
 *
 * Two layers:
 *  - the generated dataset (`src/data/skills.json`) must cover all 57 skills,
 *    each with a `what`, at least one trigger, a `whenToUse`, and a complete,
 *    non-fallback ES translation;
 *  - the built pages (`dist/docs/skills/` + ES) must render the 57 skills,
 *    the category index anchors, a TL;DR, and be discoverable (sitemap,
 *    search index, llms.txt).
 *
 * Run with `node --test tests/skills.test.mjs` after `npm run build`.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

const dataset = JSON.parse(
  readFileSync(fileURLToPath(new URL('../src/data/skills.json', import.meta.url)), 'utf8'),
);

const dist = (rel) => fileURLToPath(new URL(`../dist/${rel}`, import.meta.url));
const read = (rel) => readFileSync(dist(rel), 'utf8');
const has = (rel) => existsSync(dist(rel));

const SITE = 'https://juandelossantos.github.io';
const BASE = '/another-agent-skills';

/* ------------------------------------------------------------------ *
 * Dataset
 * ------------------------------------------------------------------ */

test('dataset: 57 skills across the declared categories', () => {
  assert.equal(dataset.skillCount, 57, 'skillCount must be 57');
  assert.equal(dataset.skills.length, 57, 'skills must contain 57 entries');
  assert.ok(dataset.categories.length >= 8, 'expected the category groups');

  const categoryIds = new Set(dataset.categories.map((c) => c.id));
  for (const skill of dataset.skills) {
    assert.ok(categoryIds.has(skill.category), `${skill.name}: unknown category ${skill.category}`);
  }
  // Every category has at least one skill.
  for (const id of categoryIds) {
    assert.ok(
      dataset.skills.some((s) => s.category === id),
      `category ${id} is empty`,
    );
  }
});

test('dataset: every skill has a name, title, what, trigger, when-to-use and source', () => {
  for (const skill of dataset.skills) {
    assert.match(skill.name, /^[a-z0-9-]+$/, `${skill.name}: bad name`);
    assert.ok(skill.title && skill.title.length > 0, `${skill.name}: missing title`);
    assert.ok(skill.audience && skill.audience.length > 0, `${skill.name}: missing audience`);
    assert.ok(skill.what && skill.what.length > 0, `${skill.name}: missing what`);
    assert.ok(
      Array.isArray(skill.triggers) && skill.triggers.length >= 1,
      `${skill.name}: needs at least one trigger`,
    );
    assert.ok(
      Array.isArray(skill.whenToUse) && skill.whenToUse.length >= 1,
      `${skill.name}: needs at least one when-to-use`,
    );
    assert.ok(Array.isArray(skill.whenNotToUse), `${skill.name}: whenNotToUse must be an array`);
    assert.ok(Array.isArray(skill.guides), `${skill.name}: guides must be an array`);
    assert.equal(skill.guideCount, skill.guides.length, `${skill.name}: guideCount mismatch`);
    assert.match(
      skill.docsUrl,
      new RegExp(`^https://github\\.com/juandelossantos/another-agent-skills/blob/main/skills/${skill.name}/SKILL\\.md$`),
      `${skill.name}: docsUrl must point at the source SKILL.md`,
    );
  }
});

test('dataset: the ES translation is complete and never a fallback', () => {
  for (const skill of dataset.skills) {
    const es = skill.es;
    assert.ok(es, `${skill.name}: missing es block`);
    assert.equal(es.fallback, false, `${skill.name}: ES fell back to EN`);
    assert.ok(es.what && es.what.length > 0, `${skill.name}: ES what missing`);
    assert.ok(Array.isArray(es.triggers) && es.triggers.length >= 1, `${skill.name}: ES triggers missing`);
    assert.ok(
      Array.isArray(es.whenToUse) && es.whenToUse.length >= 1,
      `${skill.name}: ES whenToUse missing`,
    );
    assert.ok(Array.isArray(es.whenNotToUse), `${skill.name}: ES whenNotToUse missing`);
    // Not a copy-paste of the English source.
    assert.notEqual(es.what, skill.what, `${skill.name}: ES what is the English string`);
    assert.notDeepEqual(es.whenToUse, skill.whenToUse, `${skill.name}: ES whenToUse is English`);
  }
});

test('dataset: ES copy is neutral Spanish (no voseo)', () => {
  const voseo = /tenés|podés|querés|sabés|debés|hacés|decís|Cloná|ejecutá|instalá|agregá|mirá|corré|andá|hacé|fijate/i;
  for (const skill of dataset.skills) {
    const text = JSON.stringify(skill.es);
    assert.doesNotMatch(text, voseo, `${skill.name}: voseo in the ES translation`);
  }
});

/* ------------------------------------------------------------------ *
 * Rendered pages
 * ------------------------------------------------------------------ */

test('pages: the skills reference is built in EN and ES', () => {
  for (const rel of ['docs/skills/index.html', 'es/docs/skills/index.html']) {
    assert.ok(has(rel), `missing dist/${rel}`);
  }
});

test('pages: EN renders all 57 skills and the 13 category sections', () => {
  const html = read('docs/skills/index.html');
  assert.equal((html.match(/id="skill-/g) ?? []).length, 57, 'expected 57 rendered skills');
  assert.equal(
    (html.match(/class="skills-cat"/g) ?? []).length,
    dataset.categories.length,
    'expected one section per category',
  );
  for (const skill of dataset.skills) {
    assert.ok(html.includes(`id="skill-${skill.name}"`), `missing rendered skill ${skill.name}`);
  }
  // The compact index links resolve to the rendered category anchors.
  for (const category of dataset.categories) {
    assert.ok(html.includes(`href="#cat-${category.id}"`), `index missing #cat-${category.id}`);
    assert.ok(html.includes(`id="cat-${category.id}"`), `catalog missing #cat-${category.id}`);
  }
  // Per-skill anatomy: what, triggers, use and non-use, guide count, source.
  assert.match(html, /Activates when/);
  assert.match(html, /Use it for/);
  assert.match(html, /Don(?:&#39;|')t use it for/);
  assert.match(html, /class="skill__guides"/);
  assert.match(html, /blob\/main\/skills\/test-driven-development\/SKILL\.md/);
});

test('pages: ES renders all 57 skills with the Spanish copy', () => {
  const html = read('es/docs/skills/index.html');
  assert.match(html, /<html lang="es"/);
  assert.equal((html.match(/id="skill-/g) ?? []).length, 57, 'expected 57 rendered skills');
  assert.match(html, /Se activa cuando/);
  assert.match(html, /Úsala para/);
  assert.match(html, /No la uses para/);
  for (const skill of dataset.skills) {
    assert.ok(html.includes(`id="skill-${skill.name}"`), `missing rendered skill ${skill.name}`);
    // Every skill shows its Spanish `what` (proves no silent EN fallback).
    assert.ok(
      html.includes(skill.es.what.slice(0, 40)),
      `${skill.name}: ES page is missing the Spanish what`,
    );
  }
  // No voseo in the rendered page.
  assert.doesNotMatch(html, /tenés|podés|Cloná|ejecutá|instalá|agregá|mirá|corré|andá|hacé/i);
});

test('pages: both locales have a citable TL;DR', () => {
  for (const rel of ['docs/skills/index.html', 'es/docs/skills/index.html']) {
    assert.match(read(rel), /class="docs-tldr"/, `${rel} has no TL;DR`);
  }
});

/* ------------------------------------------------------------------ *
 * Discoverability
 * ------------------------------------------------------------------ */

test('discoverability: sitemap lists the EN and ES skills reference', () => {
  const xml = read('sitemap-0.xml');
  assert.match(xml, new RegExp(`${SITE}${BASE}/docs/skills/`), 'sitemap missing EN skills');
  assert.match(xml, new RegExp(`${SITE}${BASE}/es/docs/skills/`), 'sitemap missing ES skills');
});

test('discoverability: the search index includes the skills page in both locales', () => {
  for (const rel of ['docs/search.json', 'es/docs/search.json']) {
    const items = JSON.parse(read(rel));
    const entry = items.find((item) => item.url.endsWith('/docs/skills/'));
    assert.ok(entry, `${rel} missing the skills page`);
    assert.ok(entry.title && entry.snippet, `${rel} skills entry lacks a citable snippet`);
  }
});

test('discoverability: llms.txt lists the skills reference', () => {
  const txt = read('llms.txt');
  assert.match(txt, /Skills reference/);
  assert.match(txt, new RegExp(`${SITE}${BASE}/docs/skills/`));
  assert.match(txt, new RegExp(`${SITE}${BASE}/es/docs/skills/`));
});

/* ------------------------------------------------------------------ *
 * Sidebar (the same dataset, as real anchor links)
 * ------------------------------------------------------------------ */

/** EN anchor on the skills page, base- and locale-aware. */
const skillHref = (locale, name) =>
  `${BASE}${locale === 'es' ? '/es' : ''}/docs/skills/#skill-${name}`;

/** The sidebar nav markup of a built page (scoped so labels elsewhere don't count). */
function sidebarNav(rel) {
  const html = read(rel);
  const start = html.indexOf('<nav class="docs-nav"');
  const end = html.indexOf('</nav>', start);
  return html.slice(start, end);
}

test('sidebar: every top-level section is a uniform collapsible <details>', () => {
  for (const rel of ['docs/skills/index.html', 'es/docs/skills/index.html']) {
    const nav = sidebarNav(rel);
    const groups = [...nav.matchAll(/<details class="docs-nav__group"( open)?>/g)];
    assert.equal(groups.length, 5, `${rel}: expected five top-level sections`);
    assert.equal(groups.filter((m) => m[1]).length, 1, `${rel}: exactly the active section is open`);
    assert.equal((nav.match(/docs-nav__section/g) ?? []).length, 0, `${rel}: plain labels remain`);
  }
});

test('sidebar: "Skills" appears exactly once, under Concepts, with its categories', () => {
  for (const rel of ['docs/skills/index.html', 'es/docs/skills/index.html']) {
    const nav = sidebarNav(rel);
    const labels = [...nav.matchAll(/<a\b[^>]*>([\s\S]*?)<\/a>/g)]
      .map((m) => m[1].replace(/<[^>]+>/g, '').trim())
      .filter((text) => text === 'Skills');
    assert.equal(labels.length, 1, `${rel}: expected exactly one "Skills" entry`);
    // That single entry is the branch link that owns the categories.
    assert.match(
      nav,
      /docs-nav__branch[\s\S]*?href="[^"]*\/docs\/skills\/"[\s\S]*?data-skills-group/,
      `${rel}: Skills is not an expandable branch`,
    );
    assert.equal((nav.match(/data-skill-category="/g) ?? []).length, dataset.categories.length);
    assert.equal((nav.match(/data-skill-link="/g) ?? []).length, 57);
  }
});

test('sidebar: EN exposes the 57 skill links as base-aware anchors', () => {
  const html = read('docs/skills/index.html');
  // The collapsible Skills branch, its 13 category sub-groups and 57 links.
  assert.match(html, /data-skills-group/, 'missing the Skills sidebar branch');
  assert.match(html, /docs-nav__branch-details/, 'Skills branch is not marked');
  assert.equal((html.match(/data-skill-category="/g) ?? []).length, dataset.categories.length);
  assert.equal((html.match(/data-skill-link="/g) ?? []).length, 57);
  for (const skill of dataset.skills) {
    assert.ok(
      html.includes(`href="${skillHref('en', skill.name)}"`),
      `EN sidebar missing ${skill.name}`,
    );
  }
});

test('sidebar: ES exposes the 57 skill links under /es, base-aware', () => {
  const html = read('es/docs/skills/index.html');
  assert.equal((html.match(/data-skill-link="/g) ?? []).length, 57);
  for (const skill of dataset.skills) {
    assert.ok(
      html.includes(`href="${skillHref('es', skill.name)}"`),
      `ES sidebar missing ${skill.name}`,
    );
  }
  // The category labels are localized from the dataset.
  assert.ok(html.includes('Fundamentos'), 'ES sidebar missing a localized category');
});

test('sidebar: the skills group is global and native (works with JS off)', () => {
  // Rendered on every docs page, not just the skills page.
  const html = read('docs/enforcement/index.html');
  assert.equal((html.match(/data-skill-link="/g) ?? []).length, 57);
  // Native <details>/<summary> — no JS required to expand.
  assert.match(html, /<details[^>]*data-skills-group/);
  assert.match(html, /docs-nav__cat-summary/);
});

/* ------------------------------------------------------------------ *
 * Search index (one entry per skill, anchored on the skills page)
 * ------------------------------------------------------------------ */

test('search index: EN+ES index each of the 57 skills with its anchor', () => {
  for (const locale of ['en', 'es']) {
    const rel = locale === 'en' ? 'docs/search.json' : 'es/docs/search.json';
    const items = JSON.parse(read(rel));
    const skills = items.filter((item) => item.url.includes('#skill-'));
    assert.equal(skills.length, 57, `${rel} should index 57 skills`);
    for (const skill of dataset.skills) {
      const item = skills.find((i) => i.url === skillHref(locale, skill.name));
      assert.ok(item, `${rel} missing ${skill.name}`);
      assert.equal(item.title, skill.name, `${rel} ${skill.name}: title must be the name`);
      assert.ok(item.section && item.section.length > 0, `${rel} ${skill.name}: missing section`);
      assert.ok(item.snippet && item.snippet.length > 0, `${rel} ${skill.name}: missing snippet`);
    }
  }
});

test('search index: the skill snippet is the localized what-it-does line', () => {
  const en = JSON.parse(read('docs/search.json')).filter((i) => i.url.includes('#skill-'));
  const es = JSON.parse(read('es/docs/search.json')).filter((i) => i.url.includes('#skill-'));
  for (const skill of dataset.skills) {
    assert.equal(
      en.find((i) => i.title === skill.name).snippet,
      skill.what,
      `${skill.name}: EN snippet is not the dataset what`,
    );
    assert.equal(
      es.find((i) => i.title === skill.name).snippet,
      skill.es.what,
      `${skill.name}: ES snippet is not the Spanish what`,
    );
  }
});

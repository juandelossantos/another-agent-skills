# web/ — Another Agent Skills landing + docs (Astro)

The public landing and documentation site for Another Agent Skills. It is
bilingual (EN at `/` and `/docs/`, ES at `/es/` and `/es/docs/`), light + dark,
accessible (WCAG 2.2 AA intent), and reproducible from the approved mockup in
[`docs/mockups/phase10/`](../docs/mockups/phase10/). The docs site is plain
Astro (no Starlight, no runtime framework): content collections + a hand-built
docs layout, search over a build-generated JSON index, and SEO/AEO per page.

## Boundary rule (non-negotiable)

The repository **core stays build-free**: `skills/`, `rules/`, hooks,
`install.sh`, `scripts/`, and `bin/aas` must never require Node or a build step.
The Astro build lives **only** in `web/`. The core CI (`gates`,
`.github/workflows/gates.yml`) runs `tests/run-all.sh` (shell suites) and never
runs this build. Do not add `web/` to the core CI, and do not make any core
script depend on anything in here.

## Requirements

- Node `>= 22.12.0` (Astro 7 requires it)
- npm

## Commands

```bash
cd web
npm install          # install Astro, @astrojs/sitemap, Playwright (dev)
npm run dev          # dev server at http://localhost:4321/another-agent-skills/
npm run skills       # regenerate src/data/skills.json from ../skills/*/SKILL.md
npm run build        # static build to dist/ (runs `skills` first, then type-checks)
npm run typecheck    # astro sync + tsc --noEmit (i18n key parity, typed props)
npm run og           # regenerate public/og.png (1200x630 social card)
npm run preview      # serve the built dist/ (Astro 7 preview runs in the background; `npx astro preview stop` stops it)
npm test             # build + node:test assertions against dist/
npm run test:e2e     # build + Playwright smoke + axe a11y gate (needs browsers, see below)
npm run test:all     # both
```

First Playwright run needs a browser:

```bash
npx playwright install chromium
```

## Structure

```
web/
├── astro.config.mjs        # site/base, static output, i18n (EN default + /es/), sitemap
├── playwright.config.mjs   # smoke + axe against `astro preview`
├── scripts/
│   ├── generate-og.mjs      # deterministic 1200x630 social card (`npm run og`)
│   └── generate-skills.mjs  # ../skills/*/SKILL.md -> src/data/skills.json (`npm run skills`)
├── public/
│   ├── robots.txt          # allow + sitemap ref
│   ├── llms.txt            # AEO: concise, citable facts + links
│   ├── favicon.svg
│   └── og.png              # real 1200x630 social card (regenerate: `npm run og`)
├── src/
│   ├── content.config.ts   # `docs` collection: frontmatter schema + glob loader
│   ├── content/docs/       # one Markdown file per page per locale (<slug>.en.md / <slug>.es.md)
│   ├── docs/
│   │   ├── nav.ts          # collection queries: getDocs, groups, prev/next, loadDoc
│   │   ├── paths.ts        # docsHome / docsHref / docsSearchIndex (base + locale aware)
│   │   └── seo.ts          # BreadcrumbList + TechArticle JSON-LD
│   ├── config.ts           # external links + product version
│   ├── data/
│   │   ├── skills.es.json   # ES translation map (input, hand-maintained)
│   │   └── skills.json      # generated dataset (output of `npm run skills`)
│   ├── icons.ts            # inlined Lucide paths (no CDN, no deps)
│   ├── json-ld.ts          # inline JSON-LD serialization (escapes <, >, &)
│   ├── seo.ts              # JSON-LD graph (Organization/WebSite/SoftwareApplication/FAQPage/HowTo/BreadcrumbList)
│   ├── styles/
│   │   ├── fonts.css       # self-hosted Newsreader + JetBrains Mono (OFL)
│   │   ├── fonts/*.woff2
│   │   ├── tokens.css      # palettes, type scale, hue-per-phase, spacing, motion
│   │   ├── global.css      # reset, component layer, sections, responsive, reduced motion
│   │   └── docs.css        # docs layout block (sidebar / TOC / content / search), from the mockup
│   ├── i18n/
│   │   ├── en.ts           # canonical dictionary shape
│   │   ├── es.ts           # typed as `typeof en` → parity enforced at build
│   │   ├── docs.ts         # docs-shell strings (EN canonical, ES typed)
│   │   ├── index.ts        # getDictionary / Locale helpers
│   │   └── routes.ts       # localePath (base-aware), alternateLocale
│   ├── components/         # reusable layer (see contract below) + Docs* shell pieces
│   ├── layouts/
│   │   ├── BaseLayout.astro
│   │   └── DocsLayout.astro
│   ├── scripts/
│   │   ├── landing.js      # theme toggle + terminal + flow/harness/loop (progressive enhancement)
│   │   └── docs.js         # theme, drawer, search overlay, TOC scroll-spy, code copy
│   ├── pages/
│   │   ├── index.astro            # EN landing
│   │   ├── es/index.astro         # ES landing
│   │   ├── docs/index.astro       # EN docs home (overview)
│   │   ├── docs/[...slug].astro   # EN docs pages
│   │   ├── docs/search.json.ts    # EN build-generated search index
│   │   ├── es/docs/index.astro    # ES docs home
│   │   ├── es/docs/[...slug].astro
│   │   └── es/docs/search.json.ts
└── tests/
    ├── build.test.mjs      # node:test against dist/
    ├── seo.test.mjs        # node:test: OG card, canonical/hreflang, sitemap, JSON-LD
    ├── skills.test.mjs     # node:test: the skills dataset, ES coverage and rendered pages
    ├── a11y.spec.mjs       # Playwright + axe: 0 WCAG violations (EN/ES, light/dark, 2 viewports)
    │                       #   + Label in Name (2.5.3) and landmark-unique, which the tag gate skips
    └── smoke.spec.mjs      # Playwright smoke
```

## Component contract

The reusable components mirror the mockup's documented layer
(`docs/mockups/phase10/README.md`) with the same class contract, so the CSS is
unchanged from the approved design:

| Component | Classes | Notes |
|---|---|---|
| `Icon.astro` | `icon`, `icon--sun`, `icon--moon`, `icon--copy`, `icon--check`, `icon--menu`, `icon--close` | Inlined Lucide; decorative by default, pass `label` for a11y |
| `SectionHead.astro` | `section-head__*` | eyebrow + title + lede + optional link |
| `Card.astro` | `card`, `card--rule`, `card--skill`, `card--feature`, `card--wide` | hue via `data-hue` |
| `Chip.astro` | `chip`, `chip--agent`, `chip--more`, `chip--hue`, `chip--level`, `chip--status`, `chip--soon` | level state via `data-on`/`data-off`/`data-later` |
| `Command.astro` | `command`, `command__code`, `command__copy`, `command--lg` | copy button (`data-action="copy"`) |
| `Stat.astro` | `stat`, `stat__value`, `stat__label` | optional `attrs` for JS hooks |
| `Level.astro` | `level`, `level--authority` | L1/L2/L3 |
| `Step.astro` | `step`, `step__idx` | `data-step` for the loop animation |
| `FaqItem.astro` | `faq-item`, `faq-item__question`, `faq-item__answer` | native `<details>` |
| `Header.astro`, `Footer.astro` | `header__*`, `footer__*` | theme + language controls |
| `FlowDiagram.astro`, `HarnessDiagram.astro`, `LoopDiagram.astro` | `flow__*`, `harness__*`, `loop__*` | seek-safe animations, static fallback |

## Docs structure

The docs site is a `docs` content collection rendered by `DocsLayout.astro`
through `components/DocsPage.astro`. Pages are Markdown; the shell (sidebar,
search, TOC, pager) is generated from the collection.

### Add a page

1. Create `src/content/docs/<slug>.en.md` and `src/content/docs/<slug>.es.md`.
   The two files share the same `<slug>`, `order`, and `section`.
2. Add the required frontmatter (below). The route slug is the filename without
   the locale suffix, so `enforcement.en.md` becomes `/docs/enforcement/`.
3. Build. The page appears in the sidebar, the prev/next pager, the search
   index, the sitemap, and (if it has `##` headings) the "On this page" TOC.

`overview` is special: it is the docs home (`/docs/`), so it has no
`/docs/overview/` route and it renders the browse card grid.

The `tutorials` section holds the five Bloque E walkthroughs
(`first-gated-commit`, `wire-remote-enforcement`, `no-git-and-later-git`,
`migrate-a-legacy-project`, `move-to-another-machine`), each with copy-paste
commands and a "what you should see" outcome.

### Frontmatter

```yaml
---
title: "Enforcement (L1/L2/L3)"   # page title + breadcrumb + sidebar label
description: "One sentence used for meta description, OG/Twitter and JSON-LD."
lang: "en"                         # "en" | "es" (must match the file suffix)
order: 12                          # sort key within the whole docs nav
section: "concepts"                # "start" | "tutorials" | "concepts" | "reference" | "help"
tldr: "One citable line."          # optional; shown as the page TL;DR and used
                                   # as the search snippet (AEO)
---
```

### Skills reference

The `skills` page is the detailed catalog of all 58 skills. It is generated,
never hand-written: `npm run skills` reads each `../skills/<name>/SKILL.md`
(frontmatter plus the `When to Use` / `When NOT to Use` sections) and the ES
translation map, then writes `src/data/skills.json`. The page renders that
dataset through `components/SkillsCatalog.astro`.

- Dataset entry: `{ name, title, category, tier, audience, workflow, what,
  triggers[], whenToUse[], whenNotToUse[], guides[], guideCount, docsUrl, es }`.
- Categories come from `AGENTS-EXTENDED.md` Rule 1; an unmapped skill falls back
  to its `tier` and is reported by the generator.
- ES: `src/data/skills.es.json` holds the neutral-Spanish `what`, `triggers`,
  `whenToUse` and `whenNotToUse` for every skill. A missing translation falls
  back to EN, is reported by the generator, and exits non-zero so it cannot ship
  silently.
- The generator is dependency-free and deterministic (no timestamp); the build
  runs it before `astro build`.

### i18n rule

Every page must exist in both locales. EN is canonical; ES is **neutral Spanish**
(no voseo). `src/i18n/docs.ts` holds the docs-shell strings with `docsEs` typed as
`typeof docsEn`, so a missing key fails the build. The Spanish content is checked
for voseo in `tests/build.test.mjs`.

### Search

Each locale gets a build-generated index at `docs/search.json` (EN) and
`es/docs/search.json` (ES), produced by the `.json.ts` endpoints from the
collection (`title`, `section`, `snippet`, `url`). `docs.js` fetches it on first
focus and renders the overlay. No external search service, no tracker.

## Motion and no-JS

All content is visible without JS. `src/scripts/landing.js` only *adds* motion and
the theme toggle. `prefers-reduced-motion: reduce` short-circuits the animations
to their fully-legible static state. The theme is applied before paint by an
inline script that respects `prefers-color-scheme` on first load and persists the
choice in `localStorage`.

## i18n

EN is the default locale (no prefix); ES is served at `/es/`. The language
control is a real link between the two routes (better for SEO than a client-side
toggle). `es.ts` is typed as the EN dictionary, so a missing key fails the build.

Spanish is **neutral** (no voseo) — asserted by `tests/build.test.mjs`.

## Fonts

Newsreader (display serif) and JetBrains Mono (mono) are **self-hosted** from
`src/styles/fonts/` (downloaded from Google Fonts, OFL licensed). No network
request to a font CDN at runtime, and no tracker.

## Social card

`public/og.png` is a real, on-brand 1200x630 card (warm background, Newsreader
headline, burnt-orange accent, product name and thesis), generated
deterministically by `scripts/generate-og.mjs`: headless Chromium screenshots an
HTML card with the self-hosted fonts inlined as data URIs. Regenerate with
`npm run og`. The landing and docs reference it with absolute URLs through
`og:image` / `twitter:image`.

## Deploy

The site is published to GitHub Pages by
[`.github/workflows/deploy-web.yml`](../.github/workflows/deploy-web.yml) — a
workflow **separate from the core CI** (the core `gates` workflow never builds
`web/`; see the boundary rule above).

- **Trigger:** every push to `main`, plus manual `workflow_dispatch`.
- **build** — `npm ci` + `npm run build` in `web/`, then uploads `web/dist` as
  the Pages artifact (Node 24, npm cache keyed on `web/package-lock.json`).
- **deploy** — publishes the artifact to the `github-pages` environment with
  `actions/deploy-pages@v4`.
- **verify** — a post-deploy job curls the **live** site and fails the run if a
  page does not return `200`: the EN landing, the ES landing (`/es/`), the docs
  (`/docs/`), a tutorial (`/docs/first-gated-commit/`) and `sitemap-index.xml`.
  It retries with backoff (Pages/CDN lag) but ultimately fails loudly.

### One-time Pages source switch (required)

GitHub Pages must build from **GitHub Actions**:

> **Settings → Pages → Build and deployment → Source: GitHub Actions**

This repo currently uses `build_type: legacy` (source `main`, path `/`), which
serves the OLD static site at the repository root. Switching the source to
"GitHub Actions" **replaces that legacy root site** with the Astro `web/dist`
output at `https://juandelossantos.github.io/another-agent-skills/`.

`actions/configure-pages` is used with `enablement: true`, but that only
**creates** a Pages site when none exists — it does **not** migrate an
already-enabled legacy site to the Actions source. So this switch is a one-time
human step; until it is done, the `deploy` step (and the `verify` job) fail
loudly.

### Known deploy gap (F5)

GitHub Pages **ignores `_headers`**, so the `Cache-Control` directive in the
repo-root `_headers` file does not apply to the deployed site — and there is no
CSP or HSTS on Pages. Decide between a
`<meta http-equiv="Content-Security-Policy">` (limited: no HSTS, no
`frame-ancestors`) or fronting Pages with a CDN (e.g. Cloudflare) that can set
real response headers. Tracked in `PLAN.md`.

## Known follow-ups

- The docs site is bilingual and complete for the current pages. The landing's
  "Docs" links now resolve to the in-site routes (`/docs/` EN, `/es/docs/` ES)
  through `docsHome()` in `src/docs/paths.ts`, so there is no repository-folder
  link left to migrate.

# Phase 10 landing + docs MOCKUP

This is a **static mockup for review only**. It is not the production landing or
documentation site. Nothing here is wired into the build, the tests, or the live
site. The real implementation happens only after this direction is approved.

## What it is

A self-contained preview of the Phase 10 refresh, built against the contract in
[`DESIGN.md`](../../../DESIGN.md) (section "Phase 10 - Landing Refresh") and
[`INTENT.md`](../../../INTENT.md). It has two views that share one design system:

1. **`index.html`** - the landing page (twelve sections, three animations).
2. **`docs.html`** - a representative documentation view, "Enforcement (L1/L2/L3)".


- Evolves the current editorial-premium system (Newsreader serif display +
  system UI body + JetBrains Mono) with the warm dark/light palettes.
- Twelve sections in the DESIGN.md order: Header, Hero, Problem, Flow, Harness,
  The Loop, Enforcement, Compatibility, Skills, Workflows, FAQ, Final CTA, Footer.
- Three seek-safe explanatory animations (no libraries): Flow, Harness, Loop.
- Light and dark are first-class. EN/ES is a working toggle. WCAG 2.2 AA intent.

## Docs view mockup (`docs.html`)

The documentation view is one representative page, **Enforcement (L1/L2/L3)**. It
is chosen because it is the differentiator and it exercises the component layer
(`level`, `step`, `chip`, the `command` copy button, `icon`).

- **Sidebar**: a nav tree with sections, one active item (`aria-current="page"`),
  and a collapsible "Reference" group. The group is a native `<details>`, so it
  works with JS off. Product title at the top, a version chip at the bottom.
  At <= 1000px it becomes a drawer toggled by the Lucide `menu` button.
- **Search**: a real `<input type="search">` in the header. With JS it opens a
  results overlay (`role="dialog"` wrapping a `role="listbox"`): typing filters
  six docs entries (title + section + snippet, with the match marked), `↑↓`
  moves the active option, `Enter` opens it, `Esc` closes. `⌘K` / `Ctrl K`
  focuses it. `aria-expanded`, `aria-controls` and `aria-activedescendant` are
  wired. Without JS it degrades to a plain input.
- **Content**: title + one-line **TL;DR** (AEO), prose, a callout/admonition, a
  code block with a copy button, a table (scrolls internally on narrow screens),
  a numbered steps list, and an **"On this page"** TOC. The TOC is a right rail
  on desktop and inline above the content on mobile, with active-section
  highlighting from a scroll-spy.
- **Header**: breadcrumb, theme toggle, language toggle, GitHub link.
- **Footer nav**: previous / next pager plus an "Edit this page" link.

### How to review the docs view

Open it directly (no build, no server):

```
docs/mockups/phase10/docs.html
```

Try these:

1. **Search**: focus the header input (or press `Ctrl K`). Type `branch`, then
   use `↑`/`↓` and `Enter`. Press `Esc` to close.
2. **TOC**: scroll the page; the active item in "On this page" follows. At
   <= 1100px the TOC moves inline above the content.
3. **Drawer**: narrow the window to <= 1000px and press the `menu` button. `Esc`
   or the backdrop closes it.
4. **Theme / language**: the header toggles work as on the landing (EN/ES,
   persisted). Spanish is neutral (no voseo).
5. **No JS**: disable JavaScript and reload. The sidebar and content stay
   visible; the search is a plain input; the collapsible group still opens.
6. **Reduced motion**: enable `prefers-reduced-motion`; transitions stop and the
   content stays fully legible.

### Intentional differences from the landing

- The sidebar **version chip** (`v6.3.2 · current docs`) is a docs version
  indicator, not the landing "version footer" anti-pattern the bans call out.
- Relative links use `../../` and resolve when the mockup is opened from the
  repository. When previewing over a static server, serve from the **repo root**
  (for example `python3 -m http.server 8141` then open
  `/docs/mockups/phase10/docs.html`) so the `../../` links resolve.

## How to review

Open the file directly (no build step, no server):

```
docs/mockups/phase10/index.html
```

Double-click it, or:

```bash
xdg-open docs/mockups/phase10/index.html
```

Try these:

1. **Theme**: click the toggle in the header. Reload to confirm the choice persists.
2. **Language**: click ES / EN. Every visible string should switch and the page
   `lang` attribute should follow.
3. **Flow**: scroll to "Six phases" and watch the path draw and the nodes light.
4. **Harness**: scroll to "A task flows down the machine". The packet travels down
   and is blocked (red) at Guardrails.
5. **Loop**: scroll to "The agent that audits itself". The run orbits and the
   counter increments.
6. **Enforcement**: the "blocked commit" block is the thesis proof. Check the copy.
7. **Reduced motion**: enable it in your OS (or DevTools > Rendering > Emulate
   `prefers-reduced-motion`) and reload. Everything stays static and fully legible.
8. **Keyboard**: Tab through the page. Focus rings, the accordion, and the toggles
   must all be operable.

## What is intentionally not done

- No production assets, fonts are loaded from Google Fonts (matching the current
  site). A real build may self-host them.
- npm and Homebrew are labeled "soon" (they are not live as of 2026-10-03).
- SEO files (`sitemap.xml`, `robots.txt`), `llms.txt`, `hreflang`, and the full
  JSON-LD set are Phase 10 implementation work, not mockup work.
- The mockup links to real docs with relative paths (`../../`), which resolve
  when opened from the repository.

## Component layer

Repeated content patterns are extracted into reusable components with a stable
class contract, so the real implementation reuses them instead of re-authoring
markup. Only patterns that actually repeat are extracted. The class contract:

| Component | Classes | Markup contract |
|---|---|---|
| `section-head` | `section-head`, `section-head__eyebrow`, `section-head__title`, `section-head__lede`, `section-head__link` | `<div class="section-head">` wrapping an optional eyebrow `<p>`, a title `<h2>`, a lede `<p>`, and an optional trailing link. The link is `<a class="section-head__link">` whose label is a `<span data-i18n>` followed by an arrow `<svg class="icon">`. Use the pieces standalone (for example the eyebrow inside the flex CTA). |
| `section-conclusion` | `section-conclusion` | Closing italic line: `<p class="section-conclusion" data-i18n>`. |
| `card` | `card`, `card__title`, `card__desc`, `card__list` | `<article class="card card--skill">` or `<div class="card card--rule">`. Variants: `--rule` (accent top rule), `--skill` (bordered, hue top border), `--feature` / `--wide` (grid span 2). |
| `chip` | `chip`, `chip--agent`, `chip--more`, `chip--hue`, `chip--level`, `chip--status`, `chip--soon` | `<span class="chip chip--…">` with an optional leading `<svg class="icon">`. Level chips use `data-on` / `data-off` / `data-later`. |
| `command` | `command`, `command__code`, `command__copy`, `command__copy-text` | `<div class="command"><code class="command__code">…</code><button class="command__copy" data-action="copy">` holding an `icon--copy` and an `icon--check`. `--lg` variant for the final CTA. |
| `stat` | `stat`, `stat__value`, `stat__label` | `<div class="stat"><span class="stat__value">12</span><span class="stat__label">…</span></div>`. |
| `level` | `level`, `level__head`, `level__icon`, `level__tag`, `level__title`, `level__desc` | `<article class="level" data-level="L1">` with a head row (icon + tag), then title and desc. `--authority` marks the L2 row. |
| `step` | `step`, `step__idx` | `<li class="step" data-step="…"><span class="step__idx">01</span><span>…</span></li>`. `is-active` is set by JS. |
| `faq-item` | `faq-item`, `faq-item__question`, `faq-item__icon`, `faq-item__answer` | `<details class="faq-item"><summary class="faq-item__question">` wrapping a `<span data-i18n>` label and a plus `<svg class="icon faq-item__icon">`, then `<p class="faq-item__answer">`. |
| `icon` | `icon`, `icon--menu`, `icon--close`, `icon--sun`, `icon--moon`, `icon--copy`, `icon--check` | Official Lucide SVG inlined (`viewBox="0 0 24 24"`, `stroke="currentColor"`, `stroke-width="2"`, round caps/joins). Dependency-free, no network, works without JS. Decorative icons carry `aria-hidden="true"`; the theme/hamburger pairs are toggled in CSS. |

The docs view reuses the same components (`level`, `step`, `chip`, the `command`
copy button, `icon`) and the same header primitives, and adds a docs layout layer
on top. No token or palette fork.

## Files

| File | Role |
|---|---|
| `index.html` | The full landing mockup |
| `docs.html` | The docs view mockup (Enforcement L1/L2/L3) |
| `css/mockup.css` | Design system + all landing section styles + animation states |
| `css/docs-mockup.css` | Docs layout block (loaded after `mockup.css`; reuses its tokens) |
| `js/mockup.js` | Inline EN/ES i18n, toggles, terminal, the three landing animations |
| `js/docs-mockup.js` | Docs i18n, drawer, search overlay, TOC scroll-spy, copy |
| `README.md` | This note |

## Verification performed

- `node --check js/mockup.js` and `node --check js/docs-mockup.js` pass.
- Landing, opened headless (Playwright): no console errors, page renders, theme
  toggle works, language toggle works (EN and ES), the three animations run, and
  the reduced-motion path is static and legible.
- Docs view, opened headless (Playwright, served from the repo root): 0 console
  and page errors; light + dark render; EN + ES switch (neutral Spanish, no
  voseo); no horizontal overflow at 320 and 390; the mobile drawer opens/closes
  with `Esc` and the backdrop; the search overlay filters, marks matches, moves
  with `↑↓`, navigates on `Enter`, closes on `Esc`, and opens with `Ctrl K`; the
  TOC scroll-spy follows the page; the copy button works; reduced-motion and
  no-JS are legible (sidebar and content visible, search is a plain input). All
  measured text meets WCAG AA (>= 4.5:1, >= 3:1 for large text) in both themes.

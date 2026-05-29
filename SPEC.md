# Spec: Landing Page + Documentation

## Objective

A landing page and documentation system for Another Agent Skills — the verified quality pipeline for AI coding agents. The landing page is the public face of the project, showing the pipeline, skills, and quick start. The docs provide deeper usage guides.

Audience: Senior developers using AI coding agents (OpenCode, Claude Code, Cursor, Codex) who want production-grade, non-slop outputs.

## Research Context

Three reference sites analyzed:

- **tasteskill.dev** — Single-page, skill grid with install command, testimonials, anti-slop positioning
- **impeccable.style** — Multi-page, lifecycle-organized commands, live mode demo, rich testimonials
- **open-design.ai** — README-driven, magazine editorial style, multi-language, full ecosystem docs

Key insights borrowed:
- Install command in hero (all three)
- Skills showcase grid (tasteskill, impeccable)
- Pipeline/lifecycle visual (impeccable commands by phase, open-design detect→discover→direct→deliver)
- Dark theme + code snippets (impeccable)
- FAQ section (open-design)

Rejected:
- Testimonials section (too early — no user base yet)
- Live interactive demo (scope too large for MVP)
- Multi-language README translations (too early — start with EN + ES)

## Architecture Decisions

- **Chosen**: Static HTML/CSS/JS, no framework. Maximum performance, zero dependencies, deployable anywhere.
- **Rejected**: React/Next.js — overkill for a landing page. Framework adds JS bundle, build step, complexity.
- **Rejected**: Tailwind — no build step needed. Plain CSS with custom properties is cleaner for a single page.
- **Rejected**: Separate language pages — JS-based i18n via JSON keeps content DRY.
- **Trade-off accepted**: i18n toggle adds ~200ms for JSON fetch on first load, but avoids duplicating HTML.

## Tech Stack

- **Frontend**: HTML5 + CSS3 (custom properties, no framework)
- **JS**: Vanilla ES6 (no dependencies, < 5KB gzip)
- **Animations**: CSS animations + IntersectionObserver for scroll-triggered reveals
- **Themes**: CSS custom properties with `data-theme` attribute toggle
- **i18n**: JSON translation files, JS runtime swap
- **Icons**: Inline SVG (no icon library dependency)
- **Font**: Newsreader (Google Fonts, serif display) + System UI (`system-ui, -apple-system, sans-serif`) + JetBrains Mono (Google Fonts, code/labels)
- **Markdown docs**: GitHub-flavored Markdown, rendered by GitHub
- **Hosting**: GitHub Pages (`juandelossantos.github.io/another-agent-skills`)
- **CI/CD**: GitHub Actions — build static files, deploy to Pages on push to main

## Commands

```bash
# Local dev — serve the landing page
python3 -m http.server 8080
# or
npx serve .

# Validate HTML
npx html-validate index.html

# Deploy (manual)
git push origin main
# GitHub Actions auto-deploys to Pages
```

## Project Structure

```
another-agent-skills/
├── index.html             # Landing page (English primary)
├── i18n/
│   ├── en.json            # English translations
│   └── es.json            # Spanish translations
├── css/
│   └── style.css          # All styles (light + dark themes)
├── js/
│   ├── main.js            # Theme toggle, i18n, navigation
│   └── animations.js      # IntersectionObserver + reveal logic
├── assets/
│   └── og-image.png       # Open Graph share image
├── docs/
│   ├── QUICKSTART.md      # 3 commands to start
│   ├── PIPELINE.md        # Design review pipeline guide
│   ├── SKILLS-CATALOG.md  # All 31 skills with descriptions
│   ├── PROCESS.md         # AGENTS.md, pre-commit, gates explainer
│   ├── CONTRIBUTING.md    # How to add/modify skills
│   └── FAQ.md             # Frequently asked questions
├── SPEC.md                # (this file)
└── development/           # Dev artifacts (ignored by git)
```

## Code Style

- HTML: semantic elements (`<header>`, `<nav>`, `<main>`, `<section>`, `<footer>`)
- CSS: custom properties in `:root`, BEM-like class naming, mobile-first media queries
- JS: ES modules pattern (not true modules — IIFE scoping), camelCase functions
- i18n: Flat JSON key-value, no nesting deeper than 2 levels

## Testing Strategy

- **Manual**: Visual review in Chrome, Firefox, Safari at 360px, 768px, 1024px, 1440px
- **Accessibility**: Keyboard tab through all interactive elements, check focus indicators
- **Theme check**: Toggle dark/light, verify contrast on all sections
- **i18n check**: Toggle EN/ES, verify all visible text changes
- **No automated tests** — static site, no logic to unit test

## Process — Mockup then Evolve

1. `index.html` starts as a mockup (layout, colors, dark/light toggle, pipeline placeholder)
2. First commit: `mockup: initial landing page structure` — this is commit 0
3. Every approved section iteration = a new commit
4. No throwaway prototypes. The mockup becomes the final page.
5. If a design decision is rejected, revert to previous commit — nothing is lost.
6. **Local review before any push**: `python3 -m http.server 8080`, review in browser, then push.

## SEO Requirements

- Semantic HTML5 (`<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`)
- Single `<h1>` per page, hierarchical headings (h1 → h2 → h3)
- `<meta name="description">` and `<meta name="keywords">`
- Open Graph tags (`og:title`, `og:description`, `og:image`, `og:url`)
- Twitter Card tags
- `<link rel="canonical">`
- `aria-label` on all interactive elements
- Structured data (JSON-LD) for SoftwareApplication schema
- Sitemap.xml (can be manual, simple XML)
- Robots.txt
- Alt text on all images
- Performance: LCP < 2.5s, target 90+ Lighthouse

## Acceptance Criteria

- [ ] Landing page loads under 2s on 4G (measured via DevTools throttling)
- [ ] Dark/light theme toggle works, persists preference in localStorage
- [ ] Language toggle (EN/ES) swaps all visible text, persists preference
- [ ] Pipeline visual animates on scroll (nodes light up in sequence)
- [ ] All links work (internal anchors, docs, GitHub)
- [ ] Responsive: works at 360px, 768px, 1024px, 1440px
- [ ] Keyboard navigable, visible focus indicators
- [ ] Lighthouse score > 90 on all categories (desktop + mobile)
- [ ] No JS errors in console
- [ ] GitHub Pages deploys automatically on push to main

## Boundaries

- **Out of scope**: Blog, changelog page, interactive demo, user accounts, analytics, testimonials
- **Phase 2 (future)**: Live playground, search for docs, video walkthrough, community showcase
- **Won't do**: Third-party dependencies, JS framework, server-side rendering, CMS

## Dependencies

- [x] GitHub repository (exists)
- [x] GitHub Pages enabled (repo settings)
- [x] Newsreader + JetBrains Mono fonts (Google Fonts)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| i18n JSON fetch fails | Low | Medium | Fallback to English keys if fetch fails |
| GH Pages cache old version | Low | Low | Set `no-cache` headers via `_headers` file |
| CSS becomes unmaintainable | Medium | Medium | Use custom properties + organized sections |
| Animations feel sluggish on low-end devices | Medium | Low | Respect `prefers-reduced-motion`, keep animations minimal |

## Timeline

1. **Mockup** — 1 HTML standalone preview for visual approval
2. **Landing page** — Full index.html with all sections, themes, i18n
3. **Docs** — 6 markdown files (QUICKSTART, PIPELINE, SKILLS-CATALOG, PROCESS, CONTRIBUTING, FAQ)
4. **Deploy** — GitHub Actions workflow + final review

# INTENT.md — Phase 10: Landing & Docs Refresh + Discoverability

> Discovery gate (spec-driven-development P0). 5 dimensions ≥ 80% required before SPEC.md.
> Created 2026-10-03. Owner: project maintainer. Status: **complete**.

---

## 1. Objective (what + why)

**What:** Redesign the public web presence (landing + one representative docs page) so the
framework's real value is visible, legible, and discoverable — bilingual (EN/ES), accessible
(WCAG 2.2 AA), and findable by both search engines and answer engines (SEO + AEO).

**Why now:** The framework has outgrown its face. Phase 7 (multi-agent) and Phase 9
(distribution) are shipped, but the landing still sells "Designed for OpenCode" and a single
install path. There is no `sitemap.xml`, no `robots.txt`, no structured data, no AEO — so
neither Google nor ChatGPT/Perplexity can find or cite us. Meanwhile the category (Superpowers,
`skills.addy.ie`) is moving to design-forward sites; a generic look would erase our one
structural advantage: **mechanical enforcement** (L1/L2/L3, remote `gates`, "the agent never commits").

**The thesis to communicate:** *Most skill libraries sell capability. We sell discipline you can
verify.* The landing must **show** the enforcement (not promise it).

## 2. Audience

| Segment | Who | What they need in 30s |
|---|---|---|
| **Primary** | Senior engineers using AI coding agents (OpenCode, Claude Code, Cursor, Codex, Gemini…) | "This won't slow me down, and it stops slop." Proof, not hype. |
| **Secondary** | Tech leads / CTOs evaluating agent guardrails for a team | Trust signals: mechanical gates, auditability, portability, MIT, no lock-in. |
| **Tertiary** | Answer engines (ChatGPT, Perplexity, AI Overviews) and directories | Citable, structured, machine-readable facts (AEO). |

## 3. Constraints

- **Stack (frozen):** static HTML + CSS + vanilla JS (no build for the core). Astro only in Phase 11.
  No new runtime dependencies; no framework migration in Phase 10.
- **Assets:** self-hosted or system fonts preferred (privacy + performance); no external trackers by default.
- **Themes:** **light AND dark** must both be first-class and eye-friendly (soft contrast, generous line-height).
- **Bilingual:** EN + ES in parity (i18n JSON), every visible string keyed.
- **Process:** design → **mockup in `docs/`** → review (`critique-skill`) → **explicit approval** → develop.
  Commits + push to `feat/phase10-landing`; **PR only when ready to launch**.
- **Budget/time:** no external services required; manual npm/Homebrew steps remain the maintainer's.
- **Accessibility:** WCAG 2.2 AA is a gate, not a nice-to-have.

## 4. Success metrics (measurable)

| Metric | Target | How |
|---|---|---|
| Lighthouse (Performance / A11y / Best-practices / SEO) | ≥ 95 / 100 / 100 / 100 | Lighthouse CI / manual |
| axe-core violations (landing + docs page) | **0** | Playwright + axe |
| `sitemap.xml` + `robots.txt` | present, valid | file + validator |
| Structured data (JSON-LD) | `SoftwareApplication`, `Organization`, `FAQPage`, `HowTo`, `BreadcrumbList` — 0 Rich Results errors | Rich Results Test |
| AEO surface | `llms.txt` + FAQ answers directly citable | manual check in an answer engine |
| i18n parity EN/ES | 100% keys present both sides | existing parity test |
| Tests | suite green; new behavioral tests for the new surfaces | `tests/run-all.sh` |
| Design verdict | `critique-skill`: AI-slop **PASS**, no P0 issues | review report |

## 5. Scope

**In:** landing redesign (hero kept + improved), one representative docs page, the three
**explanatory animations** (flow / harness / loop), light+dark, EN/ES, SEO (sitemap/robots/
canonical/hreflang/meta/OG), structured data, AEO (`llms.txt`, FAQ), WCAG 2.2 AA, keyword map,
`#workflows` own style (Phase 8.1 debt), README + value-doc sync.

**Out:** Astro/Starlight migration (Phase 11), a blog, analytics accounts (optional, deferred),
npm/Homebrew activation (manual, post-2026-10-06), any core change to skills/hooks/`install.sh`.

---

### Open decisions (resolved)

- **Direction:** evolve the current **editorial-premium** (Newsreader serif + warm dark) and
  borrow the best of `skills.addy.ie` (lifecycle visual, phase chips, copy-command CTA, pillars,
  hue-per-phase) — see `DESIGN.md`.
- **Mockup scope:** landing + one representative docs page.
- **Single job:** explain **and** convert, with clear hierarchy (thesis+proof above, single
  primary CTA below).
- **Hero:** keep the terminal animation; extend it with the **three real install channels**
  (`git clone` / pinned `curl` bootstrap / `npx`) and multi-agent output.

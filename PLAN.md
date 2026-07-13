# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **4.2.0** (released 2026-07-10) |
| Lint | 0 errors, 0 warnings |
| Health | ✅ HEALTHY |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 29 suites passing |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | v4.0.0 | Foundation Repair & Critical Stubs |
| **QS** | v4.1.0 | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |

---

## Phase 4: Docs Honesty (Expanded)

**Branch:** `feat/docs-honesty`
**Goal:** Every doc surface reflects current v4.2.0 state. Zero stale versions, hook refs, i18n gaps, or nav inconsistencies.
**Origin:** Deep audit (2026-07-13) found 42 issues across 6 dimensions.

### Group A — Version Truth (P0-P1)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| A1 | Bump canonical version | `VERSION` | File reads `4.2.0` |
| A2 | Fix HEALTH-CHECK.md stale refs | `HEALTH-CHECK.md` | Header v4.2.0, VERSION check v4.2.0, landing page ref v4.2.0, validate-skill-table ✅ PASS |
| A3 | Fix docs "Current version" | `docs/index.html:106` | Table cell reads `v4.2.0` |
| A4 | Fix README banner + anchor | `README.md:66` | Banner highlights v4.2.0, anchor points to existing heading |

### Group B — Hook Version Drift (P1-P2)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| B1 | Fix i18n hook refs (v7→v4) | `i18n/en.json:139`, `i18n/es.json:139` | `faq.a5` reads `commit-msg hook v4` |
| B2 | Rewrite git-hooks README | `scripts/git-hooks/README.md` | Describes current commit-msg v4 + pre-commit v11 |
| B3 | Fix README hook ref (v5→v4) | `README.md:131` | `commit-msg v4` not v5 |
| B4 | Update PATTERNS.md hook refs | `PATTERNS.md` | References current v4, not deprecated v6 |
| B5 | Update ANTI-PATTERNS.md hook refs | `ANTI-PATTERNS.md` | References current v4, not deprecated v6 |
| B6 | Update GLOSSARY.md hook ref | `GLOSSARY.md` | Three-Gate Approval entry references current v4 |

### Group C — i18n Fixes (P1-P3)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| C1 | Fix landing page i18n fetch path | `js/main.js:30` | Toggle loads translations from `docs/i18n/` |
| C2 | Add missing `footer.*` keys | `i18n/en.json`, `i18n/es.json` | 7 footer keys present and translated |
| C3 | Add missing landing page section keys | `i18n/en.json`, `i18n/es.json` | Hero, problem, howitworks, compatible, selfimproving, references keys present |
| C4 | Translate `philosophy.principle8` to ES | `i18n/es.json:81` | Spanish translation, not English copy-paste |
| C5 | Sync `faq.a10` EN ↔ ES | `i18n/en.json` | EN includes Singhal et al. citation matching ES |
| C6 | Fix enforcement.html i18n gate count | `docs/i18n/en.json` | Describes 1 TDD gate, not 4 |
| C7 | Normalize "gate" translation in ES | `i18n/es.json` | Consistent term (`puertas`) across all keys |
| C8 | Fix duplicate `"08 /"` numbering | `i18n/en.json`, `i18n/es.json` | `selfimproving` uses `"09 /"` or `"08b /"` |

### Group D — Navigation & Sidebar (P1-P2)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| D1 | Fix enforcement.html nav chain | `docs/enforcement.html:122-125` | `enforcement → design-review → rules → philosophy` (not skip) |
| D2 | Align skill page sidebar | All `docs/skill/*.html` | Same 13 items + order as main docs sidebar |
| D3 | Fix Spanish text in EN docs | `docs/skill/fullstack-shipping.html:150,158,166` | "Ver" → "See" |
| D4 | Add search to skill page sidebars | All `docs/skill/*.html` | Search input present, consistent with main docs |
| D5 | Rebuild self-improvement.html template | `docs/skill/self-improvement.html` | Standard layout: sidebar, breadcrumb, consistent with 56 other pages |

### Group E — Content Gaps (P2)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| E1 | Fill 5 empty skill content pages | `test-driven-development.html`, `code-review-and-quality.html`, `doubt-driven-development.html`, `observability-and-instrumentation.html`, `multi-agent-orchestration.html` | Each `.docs__skill-content` div has non-empty, accurate skill summary |

### Group F — Polish (P2-P3)

| # | Task | File(s) | Acceptance |
|---|---|---|---|
| F1 | Fix CSS cache-buster consistency | `index.html:51-52`, all `docs/*.html` | All pages reference same `style.css?v=3` |
| F2 | Fix PROGRESS_STATUS.md plan ref | `PROGRESS_STATUS.md:6` | References `PLAN.md` not `development/PLAN-v5-TDD-FIRST.md` |
| F3 | Fix README Prior Art skill count | `README.md:386` | "Expanded to **57** skills" |
| F4 | Add frontend-pwa to AGENTS.md mindmap | `AGENTS.md:87` | Present in Frontend hierarchy |
| F5 | Clarify SOUL.md historical hook ref | `SOUL.md:50` | Notes v5 was later simplified to v4 |

### Verification Gate

| # | Check | Command |
|---|---|---|
| V1 | Version consistency sweep | `rg "v4\.[012]" -n --include="*.md" --include="*.html" --include="*.json"` — all current refs match v4.2.0 |
| V2 | Lint + validate + health-check | `bash scripts/skill-lint.sh && bash scripts/validate-skill-table.sh && bash scripts/validate-release-notes.sh` — 0 errors, 0 warnings |
| V3 | Cross-reference 4 files | README, RELEASE-NOTES, PROGRESS_STATUS, PLAN.md all agree on version + stats |

---

## Phase 5: Release v5.0.0

Version bump, final release notes, tag.

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections

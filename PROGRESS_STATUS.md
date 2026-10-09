# Project Progress Status

> **Last updated:** 2026-10-06  
> **Current version:** 6.4.0
> **Status:** v6.4.0 released — **/gate wedge skill (58th)** + npm-first onboarding — **Phase 8 complete (Remote Enforcement live on `main`)**, **Phase 9 complete (Distribution & Upgrades)**, **Phase 10 complete (public web: Astro landing + docs + skills reference + tutorials)**, **Phase 13 complete (type-aware TDD gate — code/docs/config/shim, PR #61)** and **Phase 14 complete (distribution closeout: Homebrew dropped, npm/web live, channel-consistency check, release idempotency — PRs #66/#67/#68)**. **npm published (6.4.0)**; Homebrew **not planned**. 0 errors, 2 warnings, 153 guides across 58 skills, 142 test suites green (+ web: 74 node + 85 e2e, axe 0)  
> **Current plan:** `PLAN.md` — **Phase 14 complete**; next: **T2** (web + docs update live), **E1** (essay), and the backlog **B13/B15/B16/B19/B20**.
> **Plan:** `PLAN.md` — single source of truth for project roadmap

---

## What Exists Now










### 58 Custom Skills

| Skill | Lines | Guides | Description |
|---|---|---|---|
| `adapt-skill` | 136 | 2 |  |
| `api-and-interface-design` | 125 | 2 | Design stable APIs and module boundaries with clear contracts. Use when designin |
| `architecture-analysis` | 232 | 3 | Evaluate architecture options with 2-3 alternatives before building. Challenges  |
| `audit-skill` | 157 | 4 |  |
| `backend-api-mastery` | 180 | 5 | Design production-grade APIs with intentional architecture before writing endpoi |
| `browser-testing-with-devtools` | 79 | 1 | Test interfaces in real browsers: inspect DOM, capture console errors, analyze n |
| `ci-cd-and-automation` | 129 | 2 | Automate CI/CD pipeline setup, quality gates, and deployment. Use when configuri |
| `clarify-skill` | 126 | 4 | Rewrite confusing UX copy so interfaces explain themselves: labels, buttons, err |
| `cli-tools` | 125 | 2 | Build production-grade CLI tools with argument parsing, exit codes, colored outp |
| `code-review-and-quality` | 148 | 3 |  |
| `code-simplification` | 166 | 2 | Simplify code for clarity without changing behavior. Use when refactoring code t |
| `context-engineering` | 138 | 2 |  |
| `critique-skill` | 180 | 3 | Evaluate interfaces with two-pass design review: scoring, persona tests, AI slop |
| `customize-opencode` | 102 | 2 | Edit or create OpenCode's own configuration. Use ONLY when configuring |
| `debugging-and-error-recovery` | 103 | 5 |  |
| `debugging-three-strikes` | 83 | 0 | Stop speculative debugging after 3 same-bug strikes. Diagnose systematically bef |
| `delight-skill` | 156 | 4 |  |
| `deprecation-and-migration` | 99 | 2 | Manage deprecation and migration of old systems, APIs, and features. Covers suns |
| `dev-environment-audit` | 161 | 4 |  |
| `documentation-and-adrs` | 74 | 3 |  |
| `doubt-driven-development` | 99 | 2 |  |
| `engineering-fundamentals` | 196 | 8 | Define the universal engineering philosophy for all platform skills: discovery,  |
| `frontend-desktop` | 247 | 3 | Build production-grade desktop apps with native OS integration. Default: Tauri v |
| `frontend-mobile` | 250 | 3 | Build production-grade mobile apps with native design tokens and platform compli |
| `frontend-pwa` | 207 | 4 | Build installable, offline-first web apps for all devices with native migration  |
| `frontend-ui-engineering` | 123 | 2 | Build production-quality UIs with component architecture, state management, and  |
| `frontend-web` | 250 | 8 | Build production-grade web interfaces. Triggers: website, landing page, web app, |
| `fullstack-shipping` | 185 | 3 | Build, test, and deploy with production-grade CI/CD, testing, orchestration, and |
| `gate` | 136 | 2 |  |
| `git-init-and-versioning` | 250 | 6 | Initialize and configure Git before writing code. Decides mono vs multi-repo, cr |
| `git-workflow-and-versioning` | 193 | 3 | Manage git workflow practices: branching, committing, resolving conflicts, paral |
| `hard-skill` | 157 | 4 | Fix critical and high-severity accessibility, input, and state issues determinis |
| `idea-refine` | 113 | 2 | Refine raw ideas into sharp, actionable concepts through divergent and convergen |
| `incremental-implementation` | 95 | 2 |  |
| `industrial-brutalist-ui` | 96 | 0 | Design raw mechanical interfaces with Swiss typographic print and military termi |
| `interview-me` | 108 | 2 | Extract what the user actually wants through one-question-at-a-time interviewing |
| `minimalist-ui` | 91 | 0 | Design editorial product UI inspired by Notion and Linear: warm monochrome palet |
| `multi-agent-orchestration` | 86 | 1 |  |
| `observability-and-instrumentation` | 112 | 2 | Instrument code so production behavior is visible: structured logging, metrics,  |
| `optimize-skill` | 146 | 4 | Fix performance issues: bundle size, animations, reflows, lazy loading, image op |
| `output-skill` | 104 | 2 | Prevent placeholders, truncated code, and half-finished agent outputs. Use when  |
| `performance-optimization` | 105 | 2 | Optimize application performance beyond the frontend: Core Web Vitals, load time |
| `planning-and-task-breakdown` | 97 | 2 |  |
| `polish-skill` | 143 | 2 | Fix design detail issues: spacing, alignment, consistency, token compliance. Use |
| `project-health-check` | 220 | 2 |  |
| `project-metrics` | 162 | 2 | Log empirical quality metrics across projects: build pass rate, rework, coverage |
| `redesign-skill` | 80 | 0 | Improve existing codebases systematically: scan the UI, diagnose issues across 8 |
| `security-and-hardening` | 37 | 0 | Harden code against vulnerabilities: OWASP prevention, input validation, authent |
| `self-improvement` | 97 | 4 | Audit and fix project issues via self-improvement loop: detect, diagnose, propos |
| `shipping-and-launch` | 177 | 2 |  |
| `skill-creator` | 172 | 2 | Generate new agent skills from a workflow description: SKILL.md with frontmatter |
| `skill-improver` | 163 | 2 |  |
| `soft-premium-ui` | 92 | 0 |  |
| `source-driven-development` | 97 | 2 | Ground every implementation decision in official documentation before writing co |
| `spec-driven-development` | 180 | 3 | Create comprehensive specifications from user requests through research, critica |
| `test-driven-development` | 146 | 6 |  |
| `typeset-skill` | 143 | 2 | Fix typography and reading rhythm issues: typeface, weight, size, line-height, s |
| `user-onboarding` | 197 | 2 | Capture user preferences once, persist across projects. Creates a user profile f |

### Architecture Decisions Implemented

| Decision | Status | Where |
|---|---|---|
| DRY foundation skill | ✅ Active | `engineering-fundamentals` |
| Lazy loading (skills as indices) | ✅ Active | All 13 platform skills |
| Context persistence (Rule 0b) | ✅ Active | `AGENTS.md` |
| User profile auto-detection (Rule 0) | ✅ Active | `user-onboarding` |
| Token optimization (caveman-inspired) | ✅ Active | All skills and `AGENTS.md` |
| Commit approval gate (Rule 12) | ✅ Active | `BUILD-INTEGRATION-GUIDE.md`, `AGENTS.md` |
| Self-review mandatory (ADR-001) | ✅ Active | `ADRs/001-self-review-principle.md` |
| Pre-action checklist (Rule 0d) | ✅ Active | `AGENTS.md` (post-incident) |
| Rule 12 speed bump (no batch approval) | ✅ Active | `AGENTS.md` |
| Development artifacts convention (Rule 11) | ✅ Active | `AGENTS.md`, `DEVELOPMENT.md` |
| Smart merge for init-agents | ✅ Active | `scripts/init-agents.sh` |
| Backup before skill overwrite | ✅ Active | `install.sh` |
| Purpose-driven sessions | ✅ Active | `AGENTS.md`, `user-onboarding`, `init-agents` |
| `.sessionrc` per-project config | ✅ Active | `scripts/init-agents.sh` |
| AGENTS.md split (Core + Extended) | ✅ Active | `AGENTS.md` + `AGENTS-EXTENDED.md` |
| Rule 0e (Context eviction) | ✅ Active | `AGENTS.md` |
| SESSION_CONTEXT compression | ✅ Active | `development/SESSION_CONTEXT.md` + `ARCHIVE_2026-05.md` |
| Commit Manifest Protocol | ✅ Active | `AGENTS-EXTENDED.md` (behavioral enforcement of Rule 12) |
| Pre-commit git hook (Rule 12) | ✅ Active | `scripts/git-hooks/pre-commit` (mechanical — blocks `git commit` without token) |
| Commit Manifest self-check | ✅ Active | `AGENTS-EXTENDED.md` (anti-rationalization before manifest) |
| Post-commit verification | ✅ Active | `AGENTS-EXTENDED.md` (build/test/regression check after each commit) |
| 3 Strikes Protocol | ✅ Active | `skills/debugging-three-strikes/GUIDE.md` (stop after 3 failed fix attempts) |
| User profile: github_username | ✅ Active | `skills/user-onboarding/SKILL.md` + `ONBOARDING-QUESTIONS-GUIDE.md` |
| Incident documentation | ✅ Active | `development/INCIDENT_001` + `INCIDENT_002` |
| Edit-guard structural integrity gate | ✅ Active | `scripts/edit-guard.sh` + `AGENTS.md` Step 3 |
| Pre-commit structural HTML check (v4) | ✅ Active | `scripts/git-hooks/pre-commit` |
| Global framework distribution | ✅ Active | `install.sh` copies rules/scripts/SOUL/EXTENDED/VERSION to `~/.config/opencode/` |
| Smart symlinks in projects | ✅ Active | `init-agents.sh` links 12 framework files from global to project |

### What Was Refactored This Cycle

| Skill | Before | After | Reduction |
|---|---|---|---|
| `project-health-check` | 391 | 190 | **-51%** |
| `dev-environment-audit` | 335 | 152 | **-55%** |
| `project-metrics` | 305 | 147 | **-52%** |
| `architecture-analysis` | 364 | 202 | **-44%** |
| `user-onboarding` | 281 | 188 | **-33%** |
| `frontend-pwa` | 285 | 195 | **-32%** |
| `spec-driven-development` | 329 | 163 | **-50%** |
| `fullstack-shipping` | 307 | 225 | **-27%** |
| `git-init-and-versioning` | 356 | 243 | **-32%** |
| `engineering-fundamentals` | 276 | 162 | **-41%** |
| `frontend-desktop` | 251 | 236 | **-6%** |
| `backend-api-mastery` | 316 | 195 | **-38%** |

**All 58 skills ≤ 250 lines. Total context saved: ~1,700 lines.**

---

## What's Left

### In Progress

- **T1 — npm activation (DONE)** — first publish + Trusted Publisher (workflow **`release.yml`** — the publish is chained via `workflow_call` — environment `npm-release`, staged). `@juandelossantos/another-agent-skills@6.4.0` is **live**. **Homebrew is not planned.** See `docs/DISTRIBUTION.md`.
- **T2 — Web + docs update once LIVE** — after the Pages deploy is verified live: point the README + docs at the live URL, drop the "not yet deployed" wording, verify the live SEO/`llms.txt`/OG, and revisit the security-headers gap (GitHub Pages ignores `_headers`; decide a meta-CSP or a CDN proxy).

### Completed

- **Phase 10: Landing & Docs Refresh + Descubribilidad (v6.3.0)** — the public web in `web/`: an Astro bilingual (EN/ES) landing + docs site with the skills reference (57 skills / 151 guides, derived from the generated dataset), five tutorials, FAQ, SEO/AEO (sitemap, robots, `llms.txt`, JSON-LD, hreflang), a WCAG 2.2 AA a11y gate, and a legacy `docs/` pointer. Shipped on `feat/phase10-landing` (10 commits); **PR/merge/deploy pending** (see T1/T2).
- **Phase 9: Distribution & Upgrades (v6.3.0)** — pinned, attested releases (`scripts/build-release.sh` + `.github/workflows/release.yml`); checksum-verified `curl` bootstrap (`bootstrap.sh`); `aas` CLI (install/upgrade/doctor/uninstall); agent selection (`--agents auto|all|<list>`); portable projects (`.aas/config`, `scripts/aas-resolve.sh`, hook shims — no absolute symlinks); detection/guidance/legacy repair (`init-agents --dry-run`/`--repair`/`--force`, backup hygiene, non-blocking drift notice); npm wrapper (`npm/`, no payload) + OIDC trusted publishing (idempotent). Merged to `main` via PRs #47–#52. See `docs/DISTRIBUTION.md`.
- **Phase 8: Remote Enforcement — Gate Integrity (v6.2.0)** — **Remote enforcement is live on `main`** (merged via PRs #36–#43): branch protection (solo-safe + lockout guard + code-owner guard) + required `gates` check (`.github/workflows/gates.yml`) + `CODEOWNERS` L3 config integrity; P8.4 closed by design (philosophy A); docs honesty (INCIDENT_004 correction + L1/L2/L3 model, PR #39); ship-to-users (`templates/gates.yml` + `init-agents`/`install` wiring + L2 checklist, PR #40); remote E2E + fresh-repo `pre-commit` fix (PR #42); Gate 0 → explicit L1 prompt + solo-compatible remote approval via GitHub Environment (PR #41); closure review (script injection, fresh-repo hook block, L3 honesty, PR #43).
- **Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails (v6.2.0)** — Dual-contract plugin (`setup()` v2 + `server()` v1), multi-agent detection (15 agents) + version gating, per-agent skills/guardrails, **philosophy A** (the agent never commits/pushes — no token bypass), global install hardening (`--plugin-only`/`--skills-only`/`--guardrails-only`). Merged to `main` via PR #35. Test cadence formalized: `tests/` behavioral (permanent), `tests/task/` capped at 20.
- **Phase 3: Output Contracts** — All 57 skills now have standardized Output Contracts declaring artifact, format, location, and quality criteria. Check 16 warnings: 37 → 0. Word count advisories resolved: 4 → 0. Guides improved: CONTRACT-TEMPLATES.md (+WebSocket, +module boundaries), VERSIONING-STRATEGIES.md (+breaking rules, +edge cases), WORKFLOW-SCENARIOS.md (+6 browser testing scenarios).
- **Phase QS: Quick Start Guide** — User-facing workflow guide, full Spanish i18n (60 keys), nav chain fixed across 13 docs pages, COMMIT_APPROVED gate restored (later superseded by DECISION_APPROVED + OVERRIDE_APPROVED in v5.1.0), README prominent link.
- **Phase 2: Complete Critical Stubs** — 15 stub skills completed with full content, workflows, and guides. `visual-frontend-mastery` merged into `frontend-ui-engineering` (57 skills). 
- **Phase 1: Foundation Repair** — 29 descriptions quoted (YAML-safe), 4 stray lines cleaned, 23 flat guides moved to `guides/`. Pre-flight blocks on `main`. ANSI colors fixed in all scripts. 13/13 test suites.

### Planned

- **Phase 11: Docs site — Astro + Starlight** — SEO per language, search, sidebar/versioning, GitHub Pages (core stays build-free).
- **Backlog** — B1 (init-agents vs sync-hooks hook integrity), B2 (v11 override drift), B3 (tdd-gate false-pass), universal test scoping.
- Troubleshooting guide — common issues
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts (Newsreader + JetBrains Mono)

---

## Known Limitations

| Limitation | Impact | Workaround |
|---|---|---|---|
| OpenCode-first invocation | Cursor/Kiro still need manual adapter setup — Claude Code now gets full automatic parity (skills + hooks) via `bash install.sh --agent claude` | `bash install.sh --agent cursor` or `--agent kiro` |
| English/Spanish only | Other language speakers limited | Core principles are language-agnostic |

---

## How to Use This Status

**For users:** Check if a feature you need is "In Progress" or "Planned". Open an issue if something critical is missing.

**For contributors:** Pick any item in "What's Left", read `DEVELOPMENT.md` for conventions, and open a PR.

**For maintainers:** Update this file after every significant change. It's the single source of truth for project state.

---

## Version History

| Version | Date | Key Changes |
|---|---|---|---|---|
| **6.3.0** | 2026-10-03 | **Phase 8: Remote Enforcement — Gate Integrity** — branch protection on `main` + required `gates` check + `CODEOWNERS` L3; L1/L2/L3 model; `templates/gates.yml`; remote E2E; Gate 0 → L1 prompt + GitHub Environment approval (PRs #36–#43). **Phase 9: Distribution & Upgrades** — pinned, attested releases; checksum-verified `curl` bootstrap; `aas` CLI; portable projects; npm wrapper + OIDC trusted publishing (PRs #47–#52). **Phase 10: Landing & Docs Refresh + Descubribilidad** — public Astro web in `web/`: bilingual landing + docs, skills reference (57 skills / 151 guides), tutorials, SEO/AEO/a11y; complete on `feat/phase10-landing` (10 commits). **Pending PR/merge/deploy**; npm activation (**T1**, DONE) and the web/docs update once live (**T2**) remain; Homebrew is **not planned**. |
| **6.2.0** | 2026-10-01 | **Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails** — dual-contract plugin (v1 `server()` + v2 `setup()`), multi-agent detection (15 agents) + version gating, per-agent skills/guardrails, philosophy A (agent never commits/pushes, no token bypass), global install hardening. **Phase 8: Remote Enforcement — COMPLETE** — branch protection + required `gates` check + `CODEOWNERS` L3; docs honesty (INCIDENT_004 + L1/L2/L3 model); ship-to-users (`templates/gates.yml`); remote E2E; Gate 0 → L1 prompt + GitHub Environment approval. Remote enforcement **live on `main`** (PRs #36–#43). |
| **6.0.0** | 2026-07-18 | **Phase 6: Design Skill Integrity** — Design flow redefined with mechanical gates. 17-section DESIGN.md schema, 3-mode design-gate.sh, TDD enforcement (no override), Gate 0: DECISION_APPROVED block (15 gates total), design-upgrade.sh, token-validate.sh, approval-gate.sh, direction+platform wiring, critique-skill upgrade, 43 stale refs cleaned. 3 commits, 33+24+1 files. Browser-verified EN+ES, Playwright 12/12. |
| **5.0.0** | 2026-07-13 | **Phase 4: Docs Honesty** — 42 issues fixed across 6 groups (version truth, hook drift, i18n, nav, content gaps, polish). 86 files changed, +629/−470. Browser-verified nav chain, sidebar, theme/language toggles. 0 lint warnings. |
| **4.2.0** | 2026-07-10 | **Phase 3: Output Contracts** — All 57 skills have standardized Output Contracts. Check 16 warnings: 37→0. Word count advisories resolved. Guides improved: CONTRACT-TEMPLATES, VERSIONING-STRATEGIES, WORKFLOW-SCENARIOS. Pre-flight gate added for .gitignore/.env.example. |
| **4.1.0** | 2026-07-08 | Quick Start Guide & Navigation Overhaul: user-facing walkthrough, full Spanish i18n, nav chain fixed, COMMIT_APPROVED gate restored, TDD gate covers all text formats. |
| **4.0.0** | 2026-07-08 | Foundation Repair & Critical Stubs: 15 stubs completed, frontmatter fixes, flat guide consolidation, 57 skills, CI portable via STACK_CONFIG.md. |
| **3.1.0** | 2026-07-07 | TDD Enforcement Gate: commit-msg v4 (TDD gate), pre-commit v11 (14 gates), tdd-gate.sh, sync-hooks subcommand, 25 new tests, SPEC-TDD-GATE.md. All hooks renumbered, bug fixes. |
| **2.5.0** | 2026-06-23 | Phase 10: Integration & Hardening. test-e2e.sh E2E integration test. run-regression.sh --skill flag. Pre-commit Gate 12 enhanced with dashboard + regression checks. |
| **2.4.0** | 2026-06-22 | Phase 9: Advanced Evaluation. Trigger accuracy dashboard, regression test suite, LLM-as-Judge pattern. 3 new scripts in scripts/eval/. EVAL-GUIDE.md updated. |
| **2.3.0** | 2026-06-22 | Phase 8: Documentation & Standard Compliance. docs/EVAL-GUIDE.md (280 lines, 9 sections). agentskills.io compliance badge. Landing page + docs + i18n updated. Eval system linked from 3 skills. |
| **2.0.0** | 2026-06-18 | Standardized Frontmatter: version, allowed-tools, tier fields across all 55 skills. agentskills.io alignment. 14 new skills created. Skill smells detection (7 checks) in skill-lint.sh. validate-skill-table.sh now dynamic. |
| **1.15.0** | 2026-06-17 | Three-Gate Approval: TEST_LOG + COMMIT_MANIFEST + COMMIT_APPROVED v6 hook, log-test-results.sh, audit trail in APPROVAL_LOG. |
| **1.14.0** | 2026-06-17 | Time-Window Approval: replace SHA256 token system with timestamp-based commit-approval.sh, commit-msg v5 with <5 min freshness check, updated Rule 12. |
| **1.13.0** | 2026-06-16 | Spec-Driven Refinements: P2 Structured Clarification + P10 Convergence in spec-driven-development, Research Artifact persistence in architecture-analysis, [S]/[P]/[Pm] task markers in planning-and-task-breakdown. |
| **1.12.0** | 2026-06-16 | Design Principles Edition: 4 new principles in DESIGN-CORE.md (Ground in Subject, Hero as Thesis, Typography Carries Personality, Structure is Information), Phase 3c Design Plan Review in frontend-web, Phase 0 pre-build critique in critique-skill, Writing Philosophy in clarify-skill. |
| **1.11.0** | 2026-06-16 | Harness Edition: HARNESS.md (6-component architecture), SOUL.md principles 9-10, AI-Generated Code Review Checklist (8 checks), Memory.md for 2 skills, landing page rework (hero→harness), docs enforcement page harness section. |
| **1.10.0** | 2026-06-16 | Progress validation gate: validate-skill-table.sh in pre-commit hook (v8), PROGRESS_STATUS.md added to STEERING-GUIDE.md as HIGH severity, inventory rebuilt from disk, docs/i18n fixed. |
| **1.9.0** | 2026-06-12 | Framework distribution: install.sh copies rules/scripts/SOUL/EXTENDED/VERSION to global; init-agents creates smart symlinks; status report (INSTALLED/LINKED/SKIPPED/MISSING); idempotent, customization-safe, resilient. |
| **1.7.0** | 2026-06-03 | Documentation system: 51 pages (10 main + 41 skill), bilingual EN/ES, skills catalog with filters, generation script, landing page integration. |
| **1.6.0** | 2026-06-03 | Landing page redesign: FAQ, quick start, skills grid, compatible agents, philosophy, enforcement, how it works sections. skill-gate.sh, approve-commit.sh --auto, Rule 12 formalization. |
| **1.5.0** | 2026-05-30 | SOUL.md, universal stack detection, project enforcement hook, CI template, stack analysis, approve-commit.sh, skill-lint.sh, runtime hook controls, rules layered architecture. |
| **1.4.1** | 2026-05-29 | Guardian Pattern enforcement, Session Start Protocol, PR Review Gate, safe reinstall. |
| **1.4.0** | 2026-05-29 | Enforcement gates (pre-commit v6, commit-msg v3), skills restructured with lazy loading. |
| **11.1** | 2026-05-29 | Hero section repair (arrows, command, install box). Edit-guard structural integrity gate (INCIDENT-005). Pre-commit hook v4 with HTML marker validation. |
| **11.0** | 2026-05-25 | All 15 skills ≤ 248 lines. Windows support (install.ps1 + uninstall.ps1). Cross-shell (Zsh/Bash/Fish). Agent adapters (Claude/Cursor). |
| 10.0 | 2026-05-25 | All 14 skills < 356 lines, lazy loading on 13/14, smart merge, universal paths, token optimization applied |
| 9.6 | 2026-05-24 | 13 skills, multi-platform (web/PWA/mobile), context persistence, lazy loading backend-api-mastery |
| 9.0 | 2026-05-23 | 9 skills, web-centric, AGENTS.md lifecycle, Turbo Mode |
| 1.0 | 2026-05-22 | Fork from addyosmani/agent-skills, first custom skills |

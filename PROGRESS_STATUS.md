# Project Progress Status

> **Last updated:** 2026-06-18  
> **Current version:** 2.0.0 (Standardized Frontmatter — Eval Framework)  
> **Status:** Production-ready — Linux/macOS/Windows, Zsh/Bash/Fish/PowerShell, OpenCode/Claude/Cursor  
> **Current plan:** Phase 6.5 (Rule 6 compliance: 16 guide violations, 0 errors target), Phase 6 (description optimization), Phase 9 (LLM-as-Judge)

---

## What Exists Now


### 57 Custom Skills

| Skill | Lines | Guides | Description |
|---|---|---|---|
| `adapt-skill` | 132 | 2 | Fix responsive layout issues, missing mobile behavior, touch targets, |
| `api-and-interface-design` | 43 | 0 | Design stable APIs and module boundaries with clear contracts. Use when designin |
| `architecture-analysis` | 225 | 3 | Evaluate architecture options with critical thinking before any build decision. |
| `audit-skill` | 154 | 2 | Five-dimension technical quality audit with P0-P3 severity scoring. |
| `backend-api-mastery` | 201 | 5 | Design production-grade APIs with intentional architecture decisions before any |
| `browser-testing-with-devtools` | 80 | 0 | Test interfaces in real browsers. Available tools vary by agent platform: |
| `ci-cd-and-automation` | 39 | 0 | Automate CI/CD pipeline setup, quality gates, and deployment automation. |
| `clarify-skill` | 95 | 2 | Rewrite confusing UX copy so interfaces explain themselves. Covers labels, |
| `cli-tools` | 113 | 2 | Build production-grade CLI tools with standard argument parsing, exit |
| `code-review-and-quality` | 138 | 3 | Conducts multi-axis code review. Use before merging any change. Use when reviewi |
| `code-simplification` | 40 | 0 | Simplify code for clarity without changing behavior. Use when refactoring code |
| `context-engineering` | 126 | 2 |  |
| `critique-skill` | 169 | 3 | Two-pass design review with scoring, persona tests, and AI slop detection. |
| `customize-opencode` | 34 | 0 | Edit or create OpenCode's own configuration files: opencode.json, files under |
| `debugging-and-error-recovery` | 92 | 5 | Guides systematic root-cause debugging. Use when tests fail, builds break, |
| `debugging-three-strikes` | 23 | 1 | Stop speculative debugging when the same bug comes back 3 times. |
| `delight-skill` | 152 | 2 | Add micro-interactions, transitions, hover states, and feedback |
| `deprecation-and-migration` | 34 | 0 | Manage deprecation and migration of old systems, APIs, and features. |
| `dev-environment-audit` | 155 | 4 | Audit development environment (MCPs, CLI tools, runtimes) before code. |
| `documentation-and-adrs` | 70 | 3 | Records decisions and documentation. Use when making architectural decisions, |
| `doubt-driven-development` | 90 | 2 |  |
| `engineering-fundamentals` | 217 | 4 | Universal engineering philosophy for all platform skills. Defines discovery, |
| `frontend-desktop` | 240 | 3 | Build production-grade desktop applications with native OS integration. |
| `frontend-mobile` | 243 | 3 | Build production-grade mobile apps with native design tokens and platform compli |
| `frontend-pwa` | 199 | 4 | Build installable, offline-first web apps for all devices with migration path to |
| `frontend-ui-engineering` | 48 | 0 | Build production-quality UIs with intentional component architecture, state mana |
| `frontend-web` | 235 | 6 | Build production-grade web interfaces. Built on engineering-fundamentals. |
| `fullstack-shipping` | 184 | 3 | End-to-end build, test, and deploy workflows with production-grade discipline. |
| `git-init-and-versioning` | 249 | 5 | Initialize and configure Git repositories before any code is written. |
| `git-workflow-and-versioning` | 183 | 3 | Structures git workflow practices. Use when making any code change. Use when com |
| `hard-skill` | 153 | 2 | Apply deterministic mechanical fixes for P0/P1 accessibility, input |
| `idea-refine` | 43 | 0 | Refine raw ideas into sharp, actionable concepts through structured divergent |
| `incremental-implementation` | 89 | 2 |  |
| `industrial-brutalist-ui` | 78 | 0 | Raw mechanical interfaces fusing Swiss typographic print with military |
| `interview-me` | 40 | 0 | Extract what the user actually wants through one-question-at-a-time interviewing |
| `minimalist-ui` | 71 | 0 | Editorial product UI inspired by Notion and Linear. Warm monochrome palette, |
| `multi-agent-orchestration` | 83 | 1 | Patterns for orchestrating multiple OpenCode agents in parallel, pipeline, or sw |
| `observability-and-instrumentation` | 34 | 0 | Instrument code so production behavior is visible and diagnosable. Covers struct |
| `optimize-skill` | 142 | 2 | Fix performance issues: bundle size, expensive animations, reflows, lazy |
| `output-skill` | 51 | 0 | Keeps agent outputs complete. Prevents placeholders, truncated code, |
| `performance-optimization` | 34 | 0 | Optimize application performance beyond the frontend. Covers Core Web Vitals, |
| `planning-and-task-breakdown` | 83 | 2 |  |
| `polish-skill` | 139 | 2 | Fix design detail issues: spacing, alignment, consistency, token |
| `project-health-check` | 213 | 2 | Audit existing projects before new work. Use when entering projects with code, |
| `project-metrics` | 154 | 2 | Track empirical quality metrics across projects and sessions. Logs build pass |
| `redesign-skill` | 67 | 0 | Systematic approach to improving existing codebases. Scan the UI, diagnose |
| `security-and-hardening` | 35 | 0 | Hardens code against vulnerabilities. Covers OWASP prevention, input validation, |
| `shipping-and-launch` | 163 | 2 |  |
| `skill-creator` | 159 | 2 | Generate new agent skills from a workflow description. Creates the complete |
| `skill-improver` | 159 | 2 | Analyze failing eval cases and propose improvements to existing skills. |
| `soft-premium-ui` | 72 | 0 | Polished, calm, expensive UI with softer contrast, generous whitespace, |
| `source-driven-development` | 35 | 0 | Ground every implementation decision in official documentation before writing co |
| `spec-driven-development` | 205 | 2 | Native pipeline from user request to verified code. Creates comprehensive |
| `test-driven-development` | 141 | 6 | Drives development with tests. Use when implementing any logic, fixing any bug, |
| `typeset-skill` | 139 | 2 | Fix typography and reading rhythm issues. Covers typeface, weight, size, |
| `user-onboarding` | 191 | 2 | Capture user preferences once, persist across all projects. |
| `visual-frontend-mastery` | 46 | 0 | Build distinctive, production-grade frontend interfaces with intentional visual  |

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
| `git-init-and-versioning` | 356 | 242 | **-32%** |
| `engineering-fundamentals` | 276 | 162 | **-41%** |
| `frontend-desktop` | 251 | 238 | **-5%** |
| `backend-api-mastery` | 316 | 232 | **-27%** |

**All 41 skills ≤ 250 lines. Total context saved: ~1,700 lines.**

---

## What's Left

### In Progress

- (none)

### Planned

- Troubleshooting guide — common issues
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts (Newsreader + JetBrains Mono)
- Copy button micro-interaction (scale + check icon)
- Promotion campaign (see development/PROMOTION-PLAN.md)

---

## Known Limitations

| Limitation | Impact | Workaround |
|---|---|---|
| OpenCode-first invocation | Claude/Cursor need adapter setup | `bash install.sh --agent claude` or `--agent cursor` |
| No automated testing | Breaks not caught until user report | Manual testing after every change |
| English/Spanish only | Other language speakers limited | Core principles are language-agnostic |

---

## How to Use This Status

**For users:** Check if a feature you need is "In Progress" or "Planned". Open an issue if something critical is missing.

**For contributors:** Pick any item in "What's Left", read `DEVELOPMENT.md` for conventions, and open a PR.

**For maintainers:** Update this file after every significant change. It's the single source of truth for project state.

---

## Version History

| Version | Date | Key Changes |
|---|---|---|---|
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

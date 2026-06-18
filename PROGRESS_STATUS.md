# Project Progress Status

> **Last updated:** 2026-06-18  
> **Current version:** 2.0.0 (Standardized Frontmatter — Eval Framework)  
> **Status:** Production-ready — Linux/macOS/Windows, Zsh/Bash/Fish/PowerShell, OpenCode/Claude/Cursor  
> **Current plan:** Evaluation framework (evals/ per skill, trigger testing, skill tiers, meta-skills), Phase 1-10 per IMPROVEMENT-PLAN.md

---

## What Exists Now

### 41 Custom Skills

| Skill | Lines | Guides | Description |
|---|---|---|---|
| `adapt-skill` | 132 | 1 | Responsive layout fixes |
| `architecture-analysis` | 225 | 3 | Evaluate architecture options with trade-offs |
| `audit-skill` | 151 | 0 | Five-dimension technical quality audit |
| `backend-api-mastery` | 235 | 4 | Production APIs: protocol, DB, auth, testing, docs |
| `clarify-skill` | 181 | 0 | Rewrite confusing UX copy |
| `cli-tools` | 113 | 2 | Terminal-based tools with standard UX |
| `code-review-and-quality` | 138 | 0 | Multi-axis code review with quality gates, AI-generated code review checklist |
| `context-engineering` | 150 | 0 | Optimize agent context setup |
| `critique-skill` | 169 | 1 | Two-pass design review with scoring |
| `debugging-and-error-recovery` | 92 | 0 | Systematic root-cause debugging |
| `debugging-three-strikes` | 23 | 1 | Stop speculative debugging at 3 failures |
| `delight-skill` | 149 | 0 | Micro-interactions and transitions |
| `dev-environment-audit` | 155 | 4 | MCPs, CLI tools, runtime verification |
| `documentation-and-adrs` | 70 | 0 | Record decisions and documentation |
| `doubt-driven-development` | 250 | 0 | Adversarial fresh-context review |
| `engineering-fundamentals` | 242 | 0 | Universal philosophy: discovery, contracts, anti-slop |
| `frontend-desktop` | 240 | 2 | Production desktop apps (Tauri/Electron) |
| `frontend-mobile` | 243 | 2 | Production mobile apps (RN/Flutter) |
| `frontend-pwa` | 199 | 3 | Offline-first web apps with native migration |
| `frontend-web` | 235 | 5 | Production web interfaces with anti-slop rules |
| `fullstack-shipping` | 228 | 3 | CI/CD, deployment, monitoring, rollback |
| `git-init-and-versioning` | 249 | 4 | Git setup, branching, hooks, commit gates |
| `git-workflow-and-versioning` | 183 | 0 | Atomic commits, branching, conflict resolution |
| `hard-skill` | 150 | 0 | Deterministic P0/P1 mechanical fixes |
| `incremental-implementation` | 250 | 0 | Thin vertical slices, test each |
| `industrial-brutalist-ui` | 78 | 0 | Raw industrial mechanical UI |
| `minimalist-ui` | 71 | 0 | Editorial product UI (Notion/Linear) |
| `multi-agent-orchestration` | 83 | 1 | Orchestrate >2 agents in parallel/pipeline |
| `optimize-skill` | 139 | 0 | Fix performance bottlenecks |
| `output-skill` | 51 | 0 | Complete output enforcement |
| `planning-and-task-breakdown` | 247 | 0 | Decompose into verifiable chunks |
| `polish-skill` | 139 | 1 | Fix design detail: spacing, alignment, tokens |
| `project-health-check` | 213 | 2 | Audit existing codebases with decision gate |
| `project-metrics` | 154 | 2 | Background quality logging |
| `redesign-skill` | 67 | 0 | Systematic UI improvement |
| `shipping-and-launch` | 160 | 0 | Production launch prep and rollback |
| `soft-premium-ui` | 72 | 0 | Polished, calm premium UI |
| `spec-driven-development` | 205 | 2 | Research-backed specs with implement gate |
| `test-driven-development` | 141 | 0 | TDD cycle with anti-pattern checks |
| `typeset-skill` | 139 | 1 | Fix typography and reading rhythm |
| `user-onboarding` | 191 | 2 | Persistent user preferences across projects |

**Total: 41 custom skills, 47 guides, 3 evals, 3 memory. All SKILL.md ≤ 250 lines.**

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
| **2.0.0** | 2026-06-18 | Standardized Frontmatter: version, allowed-tools, tier fields across all 36 skills. agentskills.io alignment. Skill lint smells detection. |
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

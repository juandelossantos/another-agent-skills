# Health Check — another-agent-skills

**Date:** 2026-06-16
**Version:** 1.9.0
**Auditor:** OpenCode Agent
**Status:** ⚠️ REQUIRES ATTENTION

---

## Summary

| Metric | Value |
|---|---|
| Critical Issues | **1** (systemic: steering file integrity) |
| Warnings | **5** |
| Passes | **53/53** (100%) |
| Overall | **⚠️ REQUIRES ATTENTION** |

---

## Foundational: PASS (19/19)

| Check | Status | Notes |
|---|---|---|
| SKILL.md files | ✅ 41 on disk in `skills/` | All ≤ 250 lines, max = 250 |
| Guide files | ✅ 47 (`*GUIDE.md` + `GUIDE.md`) | Across all skills |
| Evals.md files | ✅ 3 | `code-review-and-quality`, `spec-driven-development`, `test-driven-development` |
| Memory.md files | ✅ 1 | `debugging-and-error-recovery` |
| Scripts (`.sh`) | ✅ 14 + 1 `project-pre-commit` | All pass `bash -n` |
| Rules files | ✅ 5 | behavioral, context, enforcement, project, skills |
| ADRs | ✅ 5 | Complete |
| AGENTS.md | ✅ 120 lines | Stable |
| AGENTS-EXTENDED.md | ✅ 418 lines | Stable |
| SOUL.md | ✅ 162 lines | Stable |
| VERSION | ✅ 1.9.0 | Consistent across README, RELEASE-NOTES, PROGRESS_STATUS |
| Always-loaded tokens | ✅ ~282 lines (~4,230 tokens, 1.9% of 200K) | Within budget |
| Pre-commit hook | ✅ v7 | Executable (755) |
| commit-msg hook | ✅ v4 | Executable (755) |
| approve-commit.sh | ✅ | Executable |
| task-manifest.sh | ✅ | Executable |
| Skill lint | ✅ 0 errors, 0 warnings | |
| Shell syntax | ✅ 17/17 files pass `bash -n` | |
| Editor guard | ✅ `scripts/edit-guard.sh` | Pre/post edit structural integrity |

---

## Steering File Integrity: PASS (5/5)

Per `STEERING-GUIDE.md` and Rule 0b:

| File | Severity | Status | Notes |
|---|---|---|---|
| `STACK_CONFIG.md` | 🔴 BLOCKING | ✅ Present | Meta-project (shell + markdown) |
| `SPEC.md` | 🟡 HIGH | ✅ Present | Outdated: says "31 skills" (C3) |
| `HEALTH-CHECK.md` | 🟡 HIGH | ✅ Present | This file |
| `design/DESIGN-LOCK.md` | 🔵 MEDIUM | ✅ Absent (acceptable) | Landing page is the spec |
| `.sessionrc` | ⚪ INFO | ✅ Present (local) | Not git-tracked |

---

## Landing Page & Docs: PASS (10/10)

| Check | Status | Notes |
|---|---|---|
| Meta tags | ✅ Complete | OG, Twitter Cards, canonical, JSON-LD |
| `prefers-reduced-motion` | ✅ Present | `css/style.css:1528-1537` |
| CSS custom properties | ✅ Extensive | Dark + light themes, spacing, radius |
| Skill count accuracy | ✅ "41 skills" | Consistent: hero, stats, FAQ |
| Enforcement display | ✅ Levels 1-4 | Level 4 Manifest Gate highlighted |
| Internal links | ✅ 19/19 resolve | Zero broken |
| Orphan PNGs | ✅ Clean | All 34 in `design/archive/` |
| i18n documented | ✅ | `i18n/README.md` + `docs/i18n/README.md` |
| i18n EN/ES parity | ✅ | Both systems match |
| ADRs | ✅ 5 | Complete |

---

## Inventory Accuracy

### What the project owns (`skills/`): 41 skills

| Skill | Lines | Guides | Description |
|---|---|---|---|
| `adapt-skill` | 129 | 1 | Responsive layout fixes |
| `architecture-analysis` | 202 | 3 | Evaluate architecture options |
| `audit-skill` | 148 | 0 | Five-dimension quality audit |
| `backend-api-mastery` | 232 | 4 | Production API design |
| `clarify-skill` | 163 | 0 | Rewrite confusing UX copy |
| `cli-tools` | 110 | 2 | Production-grade CLI tools |
| `code-review-and-quality` | 113 | 0 | Multi-axis code review |
| `context-engineering` | 142 | 0 | Optimize agent context setup |
| `critique-skill` | 132 | 1 | Two-pass design review |
| `debugging-and-error-recovery` | 89 | 0 | Systematic root-cause debugging |
| `debugging-three-strikes` | 20 | 1 | Stop speculative debugging at 3 failures |
| `delight-skill` | 146 | 0 | Micro-interactions and transitions |
| `dev-environment-audit` | 152 | 4 | Audit dev environment before coding |
| `documentation-and-adrs` | 62 | 0 | Records decisions and documentation |
| `doubt-driven-development` | 244 | 0 | Adversarial fresh-context review |
| `engineering-fundamentals` | 239 | 0 | Universal engineering philosophy |
| `frontend-desktop` | 237 | 2 | Production desktop apps (Tauri/Electron) |
| `frontend-mobile` | 240 | 2 | Production mobile apps (RN/Flutter) |
| `frontend-pwa` | 196 | 3 | Offline-first web apps |
| `frontend-web` | 212 | 5 | Production web interfaces |
| `fullstack-shipping` | 225 | 3 | End-to-end build, test, deploy |
| `git-init-and-versioning` | 250 | 4 | Git init, branching, hooks |
| `git-workflow-and-versioning` | 180 | 0 | Git workflow, atomic commits |
| `hard-skill` | 147 | 0 | Deterministic P0/P1 fixes |
| `incremental-implementation` | 245 | 0 | Thin vertical slices |
| `industrial-brutalist-ui` | 75 | 0 | Raw industrial mechanical UI |
| `minimalist-ui` | 68 | 0 | Editorial product UI (Notion/Linear) |
| `multi-agent-orchestration` | 80 | 1 | Orchestrate multiple agents |
| `optimize-skill` | 136 | 0 | Performance issue fixes |
| `output-skill` | 48 | 0 | Complete output enforcement |
| `planning-and-task-breakdown` | 223 | 0 | Break work into ordered tasks |
| `polish-skill` | 136 | 1 | Fix design detail issues |
| `project-health-check` | 210 | 2 | Audit projects before work |
| `project-metrics` | 151 | 2 | Track empirical quality metrics |
| `redesign-skill` | 64 | 0 | Systematic UI improvement |
| `shipping-and-launch` | 152 | 0 | Production launch prep |
| `soft-premium-ui` | 69 | 0 | Polished, calm premium UI |
| `spec-driven-development` | 163 | 2 | Research-backed specs |
| `test-driven-development` | 138 | 0 | Test-driven development |
| `typeset-skill` | 136 | 1 | Fix typography issues |
| `user-onboarding` | 188 | 2 | Capture user preferences |

**Totals:** 41 skills, 47 guides, 3 evals, 1 memory. All SKILL.md ≤ 250 lines.

### What's available at runtime (project + inherited): ~55 skills

The framework distribution system (`install.sh` + `init-agents.sh`) also symlinks 7 inherited skills from upstream (addyosmani/agent-skills): `source-driven-development`, `code-simplification`, `security-and-hardening`, `performance-optimization`, `ci-cd-and-automation`, `deprecation-and-migration`, `browser-testing-with-devtools`. Plus `api-and-interface-design`, `visual-frontend-mastery`, `frontend-ui-engineering`, `idea-refine`, `interview-me`, `observability-and-instrumentation`, `using-agent-skills`. These are documented separately — not counted in project inventory.

---

## 🔴 Critical Issues (1)

### C1. PROGRESS_STATUS.md — stale skill inventory (SYSTEMIC)

**Root cause:** The file claims to be "single source of truth for project state" but has no verification mechanism. It was manually edited and never validated against disk.

**What's wrong:**
- 7 upstream-only skills listed as if project-owned (`source-driven-development`, `code-simplification`, `security-and-hardening`, `performance-optimization`, `ci-cd-and-automation`, `deprecation-and-migration`, `browser-testing-with-devtools`)
- 7 project skills missing from table (`clarify-skill`, `debugging-three-strikes`, `industrial-brutalist-ui`, `minimalist-ui`, `optimize-skill`, `redesign-skill`, `soft-premium-ui`)
- 26/34 line counts wrong
- Contradictory summary lines (22 guides vs 46 guides)

**How this violates our philosophy:**
- **Rule 0b** (Context Persistence) — A new session reads PROGRESS_STATUS.md and gets wrong state
- **SOUL.md Principle 2** — "A rule that lives only in a file is a suggestion" — PROGRESS_STATUS.md says "update after every change" but there's no mechanical enforcement
- **STEERING-GUIDE.md** — PROGRESS_STATUS.md is not listed as a steering file, so Rule 0b never validates it

**Impact:** A new-session agent relying on PROGRESS_STATUS.md will:
- Think there are 7 skills that the project doesn't own (confusing when searching `skills/`)
- Miss 7 skills that actually exist
- Get wrong line counts → wrong context budget estimates

---

## ⚠️ Warnings (5)

### W1. `install.ps1` not executable — inconsistent with `uninstall.ps1`

`install.ps1` is `-rw-r--r--` but `uninstall.ps1` is `-rwxr-xr-x`.

### W2. `scripts/project-pre-commit` not executable

130+ line shell script, `#!/bin/sh`, but `-rw-r--r--`. All other `scripts/*.sh` are executable.

### W3. `.env.example` missing

Convention gap. Low impact (no runtime env vars), but violates standards.

### W4. `docs/i18n/{en,es}.json` — "What's New" still references v1.8.0

The documentation site's "What's New" section was never updated for v1.9.0.

### W5. `SPEC.md` says "31 skills" (line 84)

Should say "41 skills". Not critical per se because SPEC.md is about the landing page spec, but the stale number reduces credibility.

---

## Recommendations (Priority Order)

### Systemic fix (prevents recurrence)

1. **Make PROGRESS_STATUS.md verifiable:** Add a validation script that compares the skill table against disk state. Run in pre-commit hook.
2. **Add PROGRESS_STATUS.md to STEERING-GUIDE.md** as 🟡 HIGH severity — so Rule 0b validates it on session start.
3. **After above is done:** Rebuild PROGRESS_STATUS.md with `bash scripts/generate-skill-table.sh` (or similar).

### Immediate fixes

4. **Fix PROGRESS_STATUS.md** — Replace the stale table with the accurate inventory above.
5. **Fix SPEC.md** — "31 skills" → "41 skills".
6. **Fix docs/i18n** — Update What's New to v1.9.0.
7. **Fix permissions** — `chmod +x install.ps1 scripts/project-pre-commit`.

---

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-16 | Re-audit: C1 downgraded from "7 phantom skills" to "stale inventory" | Skills exist as upstream symlinks at runtime; they're not missing, just miscategorized |
| 2026-06-12 | v1.9.0 released | Framework distribution: global install + smart symlinks |
| 2026-06-12 | commit-msg hook fixed | Was not executable (644 → 755) |
| 2026-06-12 | Orphan PNGs moved to `design/archive/` | 34 files cleaned |
| 2026-06-12 | i18n split documented | README.md in both i18n/ and docs/i18n/ |

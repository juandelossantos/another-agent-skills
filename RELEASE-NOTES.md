# Release Notes

## 1.11.0 (2026-06-16)

v1.11.0: Harness Edition — Agent = Model + Harness. Full 6-component harness architecture.

### The Harness Architecture

- **docs/HARNESS.md** — 6-component harness architecture (instructions, tools, sandboxes, orchestration, guardrails, observability)
- **SOUL.md principles 9 & 10** — "Generation is solved. Verification, judgment, and direction are the new craft." + "Agent = Model + Harness. Most agent failures are configuration failures."
- **AI-Generated Code Review Checklist** — 8 specific failure-mode checks for code produced by AI agents
- **Memory.md ×2** — engineering-fundamentals (harness failures) + backend-api-mastery (API antipatterns)

### Landing & Docs Reframe

- **"Enforcement" → "The Harness"** across all docs: i18n EN/ES, sidebar nav, FAQ q8-q10, paper reference
- **index.html** — FAQ entries + fallback texts synced, `data-i18n-html` for clickable HARNESS.md link
- **docs/enforcement.html** — Harness Architecture section + gate 9 (PROGRESS_STATUS validation)
- **All 10 docs HTML pages** — sidebar nav "Enforcement" → "The Harness"

### Docs Site Audit

- **PROGRESS_STATUS.md finalized**, HEALTH-CHECK.md re-audited (3 Memory.md, 170-line SOUL.md)
- **PR #4 merged, v1.11.0 tagged, GitHub release published**
- **Paper URL**: Google Drive PDF — added as clickable `<a>` in references and FAQ

### README Restructure

- **Badge v1.11.0**, tagline + 6 harness components
- **New "The Harness" section** — dedicated section with architecture table
- **"What's New v1.11.0"** replaces stale v1.10/v1.9/v1.8 changelogs
- **Agent Compatibility** trimmed from 106 → 25 lines (matrix table + link to AGENT-ADAPTERS.md)
- **Development Lifecycle** trimmed, **Design Review Pipeline** section removed
- **HARNESS.md** added to Documentation Map

## 1.10.0 (2026-06-16)

v1.10.0: Progress validation gate — PROGRESS_STATUS.md is now verified on every commit.

### Progress Validation Gate

- **Pre-commit hook v8** — New gate: `validate-skill-table.sh` runs when PROGRESS_STATUS.md is staged. If the skill table doesn't match disk state, commit is **BLOCKED**
- **Steering file** — PROGRESS_STATUS.md added to STEERING-GUIDE.md as 🟡 HIGH severity. Rule 0b now scans it on session start
- **Inventory accuracy rebuilt** — Skill table rebuilt from actual disk state. 7 upstream skills separated from 41 project-owned. Line counts corrected. Contradictory summary eliminated
- **Shell scripts made executable** — `install.ps1` and `scripts/project-pre-commit` now executable (were `644` instead of `755`)

### Fixes

- **SPEC.md** — "31 skills" → "41 skills" (stale count from v1.7.0)
- **docs/i18n** — What's New section updated from v1.8.0 to v1.9.0 in both EN and ES
- **HEALTH-CHECK.md** — Re-audited: 1 critical (stale inventory), 5 warnings, 53/53 passes

## 1.9.0 (2026-06-12)

v1.9.0: Framework distribution — `init-agents` now delivers the complete framework, not just AGENTS.md.

### Framework Distribution

- **Global installation** — `install.sh` now copies rules/, enforcement scripts, SOUL.md, AGENTS-EXTENDED.md, and VERSION to `~/.config/opencode/`
- **Smart symlinks** — `init-agents.sh` creates symlinks from the project to `~/.config/opencode/`, so all framework files are available without duplication
- **Idempotent** — Running `init-agents` twice doesn't break anything. Existing symlinks are reused, local files are preserved
- **Customization-safe** — If you have a local SOUL.md or rules/, they are never overwritten. The framework detects and respects them
- **Resilient** — If `~/.config/opencode/` doesn't exist (install.sh not run), `init-agents` shows a clear warning and still creates AGENTS.md + STACK_CONFIG.md

### Status Report

- **Clear output** — `init-agents` now shows INSTALLED, LINKED, SKIPPED, and MISSING sections so you know exactly what was set up
- **Framework links: 12 linked, 0 preserved, 0 missing** — complete visibility into what's connected

### What's Linked

| File | Source | Purpose |
|---|---|---|
| `rules/common/` | `~/.config/opencode/rules/common/` | 5 rule files (behavioral, enforcement, context, skills, project) |
| `scripts/` | `~/.config/opencode/scripts/` | 8 enforcement scripts (skill-gate, edit-guard, task-manifest, etc.) |
| `SOUL.md` | `~/.config/opencode/SOUL.md` | Framework identity |
| `AGENTS-EXTENDED.md` | `~/.config/opencode/AGENTS-EXTENDED.md` | Anti-rationalization table |
| `VERSION` | `~/.config/opencode/VERSION` | Framework version |

## 1.8.0 (2026-06-10)

v1.8.0: Mayéutic Enforcement — Rule 0j Task Manifest, doubt-driven-development evals, Mayéutic Challenge.

### Mayéutic Challenge (Rule 0g)

- **SOUL.md** — New Mayéutic enforcement section: agent must challenge non-trivial decisions, say "no" when justified
- **Rule 0j** — Task Manifest: `.git/TASK_MANIFEST` required before executing any non-trivial task. Includes files affected, edge cases, alternatives, risks
- **scripts/task-manifest.sh** — Mechanical enforcement: `bash scripts/task-manifest.sh check` verifies manifest exists
- **Landing page** — Level 4 manifest gate section added to enforcement flow
- **i18n EN/ES** — Mayéutic enforcement translations for landing page

### Evals & Memory

- **evals.md ×3** — Added to: test-driven-development, code-review-and-quality, spec-driven-development
- **memory.md** — Added to debugging-and-error-recovery (incident-driven learning)
- **continuity docs** — Session state documentation for cross-session continuity

### Docs Expansion

- **What's New section** — Added to docs landing page (`docs/index.html`)
- **Customization page** — Expanded with code examples and configuration guide
- **Rules page** — Expanded with specific triggers and detailed descriptions
- **Agents page** — Expanded with descriptions and setup examples
- **Philosophy fix** — Clickable references with `target=_blank`

## 1.6.0 (2026-06-03)

v1.6.0: Landing page redesign with new sections, mechanical enforcement scripts, and Rule 12 formalization.

### Landing Page Enhancements

- **FAQ section** — 6 frequently asked questions with clear answers
- **Quick Start section** — 3-step installation guide on landing page
- **Skills grid** — Visual showcase of all 38 skills
- **Compatible agents section** — OpenCode, Claude Code, Cursor, Kiro support
- **Philosophy section** — SOUL.md principles explained
- **Enforcement section** — 3 levels of mechanical enforcement
- **How it works section** — 6-phase lifecycle visual

### New Scripts

- **skill-gate.sh** — Mechanical Rule 1 enforcement: registers skill consultation before any action
- **approve-commit.sh --auto** — Approval in chat, token auto-generated (no manual copy-paste)

### Rule 12 Formalization

- **Approval keywords** — "yes commit" and "yes push" now formally accepted as approval
- **Guardian Pattern reminder** — Updated enforcement text to remove jargon

### Fixes

- Hero section: copy function, i18n cache-busting, honest social proof
- METR citation accurate + references section
- Footer credits and nav consistency
- Border separator removed

### Documentation

- README updated with v1.6.0 features
- PROGRESS_STATUS.md updated with current metrics (38 skills, 46 guides)
- HEALTH-CHECK.md refreshed (v1.6.0 audit)

## 1.4.1 (2026-05-29)

v1.4.1: Guardian Pattern enforcement, Session Start Protocol, PR Review Gate, safe reinstall.

### Guardian Pattern (Rule 12 expansion)

- **DECISION POINT block**: Mandatory format before any mutation (commit, push, merge, rebase)
- **Session Start Protocol**: Agent MUST read Rules 0-12, check git state, acknowledge Guardian Pattern before any tool execution
- **guardianReminder hook**: Plugin fires alert whenever mutation tool is detected, validates decision point was presented
- **ANTI_SLOP_REMINDER**: Now includes Guardian Pattern reminder alongside core principles

### PR Review Gate (Rule 12b)

- **scripts/pr-review-checklist.sh**: Mechanical checklist before PR merge
  - Verifies: PR state, diff size, no secrets, tests, skills ≤250l, hook compliance
  - Exit codes: 0=pass, 1=fail, 2=warn
- **AGENTS.md**: Rule 12b documented with full workflow

### Safe Reinstall

- **init-agents**: Backs up existing hooks before overwriting (prevents data loss)
- **pre-commit fix**: Uses `git rev-parse` + `is-ancestor` instead of `fetch --dry-run` (avoids tag false positives)
- **pre-commit fix**: Allows commits when ahead of origin, only blocks when behind

### Plugin Enhancement

- OpenCode agent-discipline plugin now registers 5 hooks: editGuard, preFlight, guardianReminder, commitApproval, sessionCompact

### Documentation

- README updated with v1.4.1 features: Guardian Pattern, Session Start Protocol, PR Review Gate, safe reinstall

## 1.4.0 (2026-05-29)

v1.4.0: Add mechanical enforcement gates (Phase 3), restructure 7 skills with lazy loading.

### Enforcement Gates

- **Pre-commit v6** (9 gates): Branch check, staged changes, remote sync, HTML integrity, hash verification, build verification (bash -n on shell scripts), anti-slop detection (10 patterns), debug 3-strikes tracking, SPEC enforcement (warn on new scripts without design doc)
- **Commit-msg v3**: SHA256 hash verification aligned with pre-commit algorithm
- **Escape hatch**: OVERRIDE: reason → logged to .git/OVERRIDE_LOG, 3 escapes = ESCALATION required
- **OpenCode plugin**: Agent discipline plugin with editGuard, preFlight, commitApproval, sessionCompact hooks

### Skills Restructured (Lazy Loading)

- **test-driven-development**: 383l → 72l + 5 guides (TDD-CYCLE, PROVE-IT, TEST-PYRAMID, WRITING-TESTS, ANTI-PATTERNS, BROWSER-TESTING)
- **debugging-and-error-recovery**: 300l → 63l + 2 guides (TRIAGE, ERROR-PATTERNS)
- **code-review-and-quality**: 347l → 79l + 3 guides (FIVE-AXIS, REVIEW-PROCESS, CHANGE-SIZING)
- **git-workflow-and-versioning**: 300l → 66l + 3 guides (COMMIT-PRINCIPLES, BRANCHING, PRE-COMMIT)
- **documentation-and-adrs**: 278l → 62l + 3 guides (ADR-GUIDE, INLINE-DOCS, README)
- **incremental-implementation**: 245l (unchanged, already ≤250l)
- **planning-and-task-breakdown**: 223l (unchanged, already ≤250l)

All skills now ≤250 lines via lazy loading pattern (SKILL.md as index + guides/ loaded on-demand).

### Install Script

- install.sh: Added install_opencode_plugin() function to copy agent-discipline plugin to ~/.config/opencode/plugins/

## 1.3.0 (2026-05-29)

v1.3.0: Add native JS plugin for agent discipline.

### Agent Discipline Plugin

- **OpenCode plugin**: Native JavaScript plugin in .opencode/plugins/agent-discipline/
- **Hooks**: editGuard (file integrity on edit/create/delete), preFlight (git state before risky commands), commitApproval (mutation gate for commit/push/merge), sessionCompact (context eviction reminder)
- **Override tracking**: logOverride(), getOverrideCount(), isEscalationRequired() for 3-strikes escalation
- **Multi-agent support**: Claude Code (.claude-plugin/), Cursor (.cursor-plugin/), Kiro (.kiro/)

## 1.2.0 (2026-05-28)

v1.2.0: Add 9-skill design review pipeline, restructure README with Mermaid diagram and DESIGN-SKILLS.md catalog.

### New Skills (Design Review Pipeline)

- **critique-skill** — Two-pass design quality review with Nielsen 10 heuristics scoring, 4 persona tests, 25-entry AI slop anti-patterns catalog
- **audit-skill** — Five-dimension technical quality audit (a11y, perf, theming, responsive, anti-patterns) with P0-P3 severity routing
- **clarify-skill** — UX copy rewriting for labels, errors, empty states, buttons, tooltips, and confirmations with voice tuning per audience
- **hard-skill** — Mechanical P0/P1 fixes for accessibility (ARIA, keyboard, focus), input validation, state handling, and confirmation dialogs
- **polish-skill** — Design detail fixes: spacing tokens, alignment, border radius, shadow depth, color token drift
- **typeset-skill** — Typography correction: type ramp application, line-height tuning, letter-spacing, paragraph rhythm
- **adapt-skill** — Responsive layout fixes: breakpoint gaps, touch targets (≥44px), viewport (100dvh), overflow, hover-only actions
- **optimize-skill** — Performance fixes: bundle code-splitting, lazy loading, image optimization, animation compositing, layout thrashing elimination
- **delight-skill** — Micro-interactions: hover/tap feedback, state transitions (150-400ms), loading skeletons, success/error animation, page enter stagger

### Documentation

- **README restructured**: Added Mermaid flowchart showing Core Lifecycle ↔ Design Review Pipeline interaction; consolidated Skills at a Glance to 12 core lifecycle skills with a link to DESIGN-SKILLS.md for the 21 design skills
- **DESIGN-SKILLS.md**: New catalog documenting all 21 design-related skills across three tiers (platform, direction, review pipeline) with ecosystem map and usage triggers
- **Documentation Map**: Fixed table separator format, added DESIGN-SKILLS.md entry, updated pre-flight hook description
- Pre-commit hook v3: SHA256-based mutation approval enforcement (Rule 0d mechanical checklist)
- scripts/pre-flight.sh: 5-point git state diagnostic (repo, branch, working tree, remote, upstream)
- AGENTS.md Rule 0d: Pre-Action Checklist + Branch Interview protocol

## 1.1.0 (2026-05-26)

v1.1.0: Fix 9 audit issues, add RELEASE-GUIDE, add release.sh, hash-bound commit hook

- Fix executable permissions on pre-commit hook and uninstall.sh
- Remove orphan AGENTS.md.backup from root
- Add SKILL.md to debugging-three-strikes
- Add RELEASE-GUIDE.md to git-init-and-versioning (Phase 9)
- Update Rule 6: 250 lines max, micro-skills exempt from 2-guide rule
- Update HEALTH-CHECK.md metrics
- Add scripts/release.sh with -m and -y flags for non-interactive usage
- Recreate cli-tools skill with 2 guides (110-line SKILL.md)
- Add competitive advantages section to README
- Add RELEASE-NOTES section for v1.1.0
- GitHub Releases: v1.0.0 + v1.1.0 published
- **Pre-commit hook v2**: SHA256 hash binding for commit message integrity — prevents silent approval bypass
- **Anti-rationalization table**: expanded to 25 entries (6 new failure-mode defenses for process compliance)
- **Rule 0d**: added SHA256 token generation step to pre-action checklist


## 1.0.0 (2026-05-26)

Initial versioned release of Another Agent Skills.

### Features
- **Design Core Extraction (ADR-004):** 3 shared CORE guides (DESIGN, ANTI-SLOP, PRE-FLIGHT)
  in `engineering-fundamentals/guides/`. All platforms (web, mobile, desktop, pwa)
  now share the same Three Dials design system.
- **Frontend Web v2:** Three Dials System replaces 8 fixed directions. Brief Inference (Phase 0b),
  Design System Map (Phase 3b). 85+ anti-slop tells, 54 pre-flight checks.
- **Frontend Mobile:** New Three Dials system. Animation guides (Reanimated + Gesture Handler),
  discovery guide for mobile.
- **Frontend Desktop:** Three Dials applied. Native Tauri integration guides (menus, system tray,
  file dialogs, global shortcuts), discovery guide, examples.
- **Frontend PWA:** Three Dials with cross-device constraints. Discovery guide.
- **5 specialized skills:** industrial-brutalist-ui, minimalist-ui, soft-premium-ui, output-skill,
  redesign-skill.
- **Auto-update system:** `VERSION`, `RELEASE-NOTES.md`, `scripts/check-update.sh` — checks for
  updates when entering projects. Asks before updating.

### ADRs
- ADR-003: Frontend Web v2 — Three Dials System
- ADR-004: Design Core Extraction

### Fixes
- HEALTH-CHECK.md metrics updated (skills, always-loaded, pre-flight count)
- SKILL.md line counts corrected (< 250 each)
- IMAGE-STRATEGY.md now referenced from SKILL.md
- .opencode/skills/ symlinks for discoverable skills
- Pre-action checklist: commit message visibility + git status/fetch check

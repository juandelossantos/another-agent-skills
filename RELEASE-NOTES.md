# Release Notes

## 3.1.1 (2026-07-08) — Test Infrastructure & TDD Enhancement

### New
- `tests/run-all.sh` — Unified test runner: runs 9 suites (audit, init, TDD gate, pre-commit gates, Gate 14 behavioral, sync hooks, skill lint, eval e2e). Continues on failure. Color output with summary.
- `tests/test-pre-commit-gate-14.sh` — Behavioral test for Gate 14: asserts block on failure, pass on success, skip when missing. 7 assertions.
- `scripts/git-hooks/pre-commit` v11 — Added Gate 14 (Test Runner): runs `bash tests/run-all.sh` before every commit. Bypass via `SKIP_TEST_RUNNER=true` env var.
- TDD gate (`scripts/tdd-gate.sh`): name-pairing check (test file name must match code file stem) + new-test enforcement (at least one staged test file must be new, not in HEAD).
- `.github/workflows/ci.yml` — Added 5 new steps: init tests, TDD gate tests, pre-commit gate tests, sync hooks tests, `tests/run-all.sh`.
- `tests/playwright/package.json` + `package-lock.json` — Tracked in git for reproducible Playwright browser tests.
- `development/SPEC-TDD-GATE.md` v1.1.0 — Updated decision tree, behavior docs, verification steps for name-pairing + new-test.

### Changed
- Pre-commit hook bumped v10 → v11 (14 gates). All doc surfaces updated: README, DEVELOPMENT.md, docs/enforcement.html, docs/EVAL-GUIDE.md, homepage, docs homepage, i18n EN/ES.
- TDD gate is stricter: code without name-matched test blocks. Code with only pre-existing tests blocks. Override remains available.
- `docs/js/docs.js` — Added i18n cache buster (`?v=Date.now()`) to prevent stale translations. All 12 doc pages bumped to `?v=3`.

### Fixed
- `scripts/init-agents.sh` — `--skip-self-improvement` flag boolean was reversed (line 59). Now correctly sets `WITH_SELF_IMPROVEMENT=false`.
- Docs i18n cache: stale translations no longer persist after file edits.

### Tests
- 46 project tests across 6 suites (14 TDD gate + 7 pre-commit gates + 7 Gate 14 behavioral + 7 sync hooks + 7 init features + 3 audit wrapper + 1 audit engine golden).

## 3.1.0 (2026-07-07) — TDD Enforcement Gate

### New
- `scripts/tdd-gate.sh` — Standalone TDD enforcement gate. Detects `.sh`, `.js`, `.py` extensions plus shebang-based shell scripts (`#!/usr/bin/env bash`, `#!/bin/sh`) and `scripts/git-hooks/` directory. Blocks commits that modify code files without corresponding test files.
- `scripts/git-hooks/commit-msg` v7 — Four-gate approval pipeline: TEST_LOG → COMMIT_MANIFEST → COMMIT_APPROVED (<5 min) → **TDD gate** (Gate 4). TDD override via commit message body (`OVERRIDE: reason`).
- `scripts/git-hooks/pre-commit` v10 — 13 sequential gates (1-13, no gaps). Fixed duplicate gate 6 / missing gate 10 bug from v9.
- `scripts/init-agents.sh sync-hooks` — New subcommand: copies hooks from `scripts/git-hooks/` to `.git/hooks/`, backs up existing hooks, makes executable.
- `development/SPEC-TDD-GATE.md` — Full specification: decision tree, file patterns, edge cases, override mechanism, block message format, 5 exit codes, logging spec.
- 3 test suites (25 tests): `test-tdd-gate.sh` (11), `test-pre-commit-gates.sh` (7), `test-sync-hooks.sh` (7). All passing.

### Changed
- `scripts/pr-review-checklist.sh` — Removed stale `sha256` check (commit-msg uses time-window approval, not SHA tokens).
- All documentation surfaces updated: README, AGENTS.md, HEALTH-CHECK.md, index.html, docs/enforcement.html, docs/HARNESS.md, i18n EN/ES (13 files).
- `scripts/git-hooks/pre-commit` gates renumbered: v9 → v10, 12 gates → 13 sequential gates (1-13), Test Runner gate added for Phase 0.5.

### Fixed
- **Extensionless shell scripts** — TDD gate now detects shebang lines (`#!/usr/bin/env bash`, `#!/bin/sh`) and `scripts/git-hooks/` directory entries. 3 new regression tests.
- **Pre-commit gate numbering** — Duplicate gate 6 and missing gate 10 fixed. All 13 gates sequential.

## 3.0.0 (2026-07-XX) — Universal Self-Improvement Loop

### New
- `scripts/universal-audit.sh` — Config-driven audit engine: `--json` (valid JSON), `--init` (config scaffold), subshell-bug-free, 6 config-gated checks, portable (works in any project, any stack)
- `scripts/audit-markdown.sh` — Thin wrapper over `universal-audit.sh` (backward compat)
- `.audit-config.json` — Stack-aware audit configuration (auto-detects Node, Python, Rust, Go)
- `init-agents` now includes the self-improvement loop **by default** (no flag required)
- `tests/audit/` — 17 engine tests + 3 wrapper-contract tests = 20 total
- `tests/init/` — 7 init-agents scaffolding tests

### Fixed
- **Placeholder precision** — Skips fenced code blocks; requires `TODO:`/`FIXME:` colons (88% false-positive reduction)
- **Subshell counter bug** — Broken links and table mismatches now block (were silently ignored)
- **Nested fence bug** — Awk `RLENGTH` fix for 4-backtick outer fences (CommonMark-compliant)
- **`--json` stub** — Now emits valid, schema-consistent JSON (was a no-op)

### Universal
- `skills/self-improvement/SKILL.md` — Now stack-agnostic: uses project-root paths, user's test command from `STACK_CONFIG.md`, `tier: stable` (was draft)
- 4 guides: `UNIVERSAL-USAGE.md`, `CONFIG-REFERENCE.md`, `EXAMPLE-NODE.md`, `EXAMPLE-PYTHON.md`
- Test contract improved: behavioral golden (not count-based), 5 domain-edge tests

### Cross-Platform
- `init-agents` `link_or_copy()` — Tries symlink, falls back to copy (Windows Git Bash support)
- Agent-agnostic: detects OpenCode, Claude Code, Cursor, Devin, Gemini CLI

### Docs
- `docs/universal-loop.html` — New architecture documentation for the universal loop
- Landing page, README, i18n EN/ES updated

## 2.7.0 (2026-07-XX) — Self-Improvement Loop

### New
- `skills/self-improvement/` — Self-improvement loop skill: detect (audit-markdown.sh), diagnose, propose, execute with human approval. Max 3 iterations per session
- `scripts/generate-adr.sh` — MADR-format ADR generator for auto-documentation
- `scripts/audit-markdown.sh` — Added `--json` flag for machine-readable output

### Visibility
- Landing page — New "Self-Improving" section (EN + ES) with 4-step pipeline
- Docs — What's New in v2.7.0
- README.md — Self-Improvement Loop featured

### Skills added
- `self-improvement` — 58th skill: closed-loop quality pipeline

---

## 2.6.1 (2026-07-XX) — Workflow Patterns

### New Documentation
- `PATTERNS.md` — Catalog of 8 workflow patterns (Guardian, Lazy Loading, Skill Gate, Edit Barrier, Commit Manifest, Design Gate, Three-Gate Approval, Context Budget) with Mermaid diagrams and trade-off analysis
- `AGENTS.md` — Skill hierarchy Mermaid mindmap and lifecycle Mermaid flowchart added

### Skills Updated
- `planning-and-task-breakdown` — References section with PATTERNS.md, ANTI-PATTERNS.md, GLOSSARY.md links; PATTERNS.md consult item added to verification checklist

---

## 2.6.0 (2026-07-XX) — Knowledge Infrastructure

### New Documentation
- `ANTI-PATTERNS.md` — Catalog of 11 agent workflow anti-patterns across 4 categories, with code examples (bad + good), rule/skill cross-references, and mechanical fix for each
- `GLOSSARY.md` — A-Z glossary of 40+ framework terms validated against external sources (Anthropic docs, ai-system-design-guide) with source file cross-references

### New Documentation (F1)
- `ANTI-PATTERNS.md` — Catalog of 11 agent workflow anti-patterns across 4 categories, with code examples (bad + good), rule/skill cross-references, and mechanical fix for each
- `GLOSSARY.md` — A-Z glossary of 40+ framework terms validated against external sources (Anthropic docs, ai-system-design-guide) with source file cross-references

### Docs Updated
- `README.md` — Documentation Map updated with links to ANTI-PATTERNS.md and GLOSSARY.md

---

## 2.5.0 (2026-06-23) — Phase 10: Integration & Hardening

E2E integration test, pre-commit eval gate enhancements, and single-skill regression testing.

### New Tools
- `scripts/eval/test-e2e.sh` — End-to-end integration test for the eval system. Creates a temp skill with known evals, runs full pipeline (lint → evals → dashboard → regression), cleans up on success AND failure.

### Changed
- `scripts/eval/run-regression.sh` — New `--skill <name>` flag for single-skill regression testing
- `scripts/git-hooks/pre-commit` — Gate 12 now runs trigger-dashboard and regression checks on changed skills, not just evals

## 2.4.0 (2026-06-22) — Phase 9: Advanced Evaluation

Quantitative eval tooling: trigger accuracy dashboard, regression test suite, and LLM-as-Judge pattern.

### New Tools
- `scripts/eval/trigger-dashboard.sh` — Per-skill trigger accuracy dashboard. Reports positive/negative case counts, calculates accuracy, flags skills below 90% threshold. Tracks history in `.trigger-stats.json` for trend comparison.
- `scripts/eval/run-regression.sh` — Regression test suite. Runs ALL 350 eval cases across all 57 skills, records baseline in `.regression-results.json`, detects regressions on subsequent runs. Exit code 1 if regression found.
- `scripts/eval/run-llm-judge.sh` — LLM-as-Judge evaluation pattern. Generates structured judge prompts with position swapping (A→B and B→A rubric order) to eliminate ordering bias per whitepaper §4.

### Documentation
- `docs/EVAL-GUIDE.md` — New "Advanced Evaluation" section covering all three tools
- `skills/skill-improver` — References updated with links to dashboard, regression, and LLM-as-Judge

## 2.3.0 (2026-06-22) — Phase 8: Documentation & Standard Compliance

Documentation system for skill evaluation, agentskills.io compliance badge, landing page and docs updated.

### New
- `docs/EVAL-GUIDE.md` — Complete eval system documentation covering format spec
  (schema.json), 4 eval types (trigger_positive, trigger_negative, execution,
  regression), skill tiers (read-only/draft/action-allowed), how to add evals,
  how to run eval scripts (run-evals.sh, run-golden.sh, run-adversarial.sh,
  check-coverage.sh), trigger accuracy targets (90%), CI/pre-commit integration,
  coverage checklist, and examples
- agentskills.io compliance badge added to README.md

### Changed
- Landing page: skills stats now link to EVAL-GUIDE.md, new FAQ entry "How does
  the eval system work?" with full explanation
- Documentation site: EVAL-GUIDE sidebar link across 68 pages, overview card
  spanning full width
- i18n EN/ES synced across landing page (`i18n/en.json`, `i18n/es.json`) and
  docs site (`docs/i18n/en.json`, `docs/i18n/es.json`)

### Skills
- `engineering-fundamentals` — Added Phase 8: Eval System Integration. Foundation
  skill now references docs/EVAL-GUIDE.md and describes the 4 eval failure modes
  (trigger, execution, token budget, regression)
- `skill-creator` — References section adds link to docs/EVAL-GUIDE.md
- `skill-improver` — References section adds link to docs/EVAL-GUIDE.md

## 2.2.0 (2026-06-18)

Phase 6: Description Optimization — 57 skills, 6 quality criteria enforced, Check 15 in linter.

### Description Optimization
- **Check 15** in `skill-lint.sh`: validates every skill description against 6 criteria (verb-led, trigger keywords front-loaded, anti-trigger clause, ≤200 chars, 3+ distinct triggers, no internal jargon)
- All 57 skill descriptions rewritten to meet 6/6 criteria
- 34 skills gained anti-trigger clauses
- Removed internal jargon from all descriptions
- `skill-creator` workflow updated to generate 6/6 compliant descriptions
- Added 28 new verbs to the linter's valid verb list (Capture, Debug, Instrument, Automate, Simplify, etc.)

### Mechanical Enforcement
- New verb additions are now tracked via the linter's verb list
- `validate-release-notes.sh` blocks commits with insufficient release notes

## 2.1.0 (2026-06-18)

Phase 6.5: Rule 6 Compliance — 0 guide violations, checks enforced, task planning protocol.

### Rule 6 Compliance
- Check 14 added to `skill-lint.sh`: skills >100 lines with <2 guides → ERROR
- All 57 skills now have ≥2 guides (54 total guides)
- 4 monoliths transformed to index+guides pattern (clarify, doubt-driven, incremental, planning)
- 3 dense skills trimmed under 1250 words (backend-api-mastery, fullstack-shipping, engineering-fundamentals)
- 8 skills received new guides (audit, optimize, context-engineering, delight, hard, shipping, skill-creator, skill-improver)
- 4 skills had existing files renamed to -GUIDE convention (adapt, critique, polish, typeset)

### Description Optimization (Phase 6)
- **Check 15** added to `skill-lint.sh`: validates description quality (verb-led, anti-trigger, ≤200 chars)
- All 57 skill descriptions now meet 6 quality criteria
- 34 skills gained anti-trigger clauses
- Removed internal jargon from descriptions (cross-skill references, hardcoded paths)
- `skill-creator` workflow updated to generate descriptions that meet 6 criteria by default

### Mechanical Enforcement
- `commit-approval.sh` now requires `--plan-approved` and `--manifest-presented` flags
- `skill-gate.sh` now has `require <skill>` to verify specific skills were loaded
- `validate-skill-table.sh` validates guide counts (not just line counts)
- `validate-health-check.sh` (new) verifies HEALTH-CHECK.md matches live linter state
- Pre-commit test command chains: skill-lint → validate-table → validate-health

### Health Tracking
- HEALTH-CHECK.md status auto-verified against linter
- PROGRESS_STATUS.md guide counts validated by tooling
- Task template standardized (see `docs/TASK-TEMPLATE.md`)

## 2.0.0 (2026-06-18)

v2.0.0: Standardized Frontmatter + Eval System — 55 skills, 336 evaluations, pre-commit v9.

### Standardized Frontmatter (agentskills.io)
- All 55 skills now include `version`, `allowed-tools`, `tier`, `license`, and `metadata` fields in YAML frontmatter.
- Aligned with the agentskills.io open standard for cross-platform portability.

### 14 New Skills
- **Discovery Pipeline:** `interview-me` → `idea-refine` (pre-spec refinement)
- **UI Foundation:** `frontend-ui-engineering` (cross-platform UI principles)
- **Quality:** `code-simplification`, `security-and-hardening`, `deprecation-and-migration`
- **Performance:** `performance-optimization` (system-level), `observability-and-instrumentation`
- **API/Integration:** `api-and-interface-design`, `ci-cd-and-automation`
- **Testing:** `browser-testing-with-devtools` (tool-agnostic)
- **Other:** `source-driven-development`, `customize-opencode`

### Skill Smells Detection
- `skill-lint.sh` now detects 7 quality issues: weak descriptions, ALWAYS/NEVER caps, token limit warnings, missing frontmatter fields, and progressive disclosure gaps.

### Tool-Agnostic Design
- Removed hardcoded browser/MCP/CLI dependencies from 8 skills.
- Skills describe the *what* (capabilities), not the *how* (specific tools).

### Eval Framework (Phases 1-3)
- `scripts/eval/schema.json` — JSON Schema for standardized skill evaluation.
- `scripts/eval/run-evals.sh` — Trigger runner (166 cases, --all/--skill/--list modes).
- `scripts/eval/run-golden.sh` — Golden dataset runner (58 cases with rubric).
- `scripts/eval/run-adversarial.sh` — Red-team runner (114 cases: rephrasing + boundaries + edges).
- `scripts/eval/check-coverage.sh` — Coverage reporter (55/55 full coverage).
- **Pre-commit v9** — New eval gate runs trigger + golden evals on changed skills.
- **CI pipeline** — 3 eval steps in GitHub Actions.
- `validate-skill-table.sh` now dynamic (handles any skill count).
- **55/55 skills** with trigger + golden + adversarial eval coverage (336 total cases, 0 failures).

## 1.15.0 (2026-06-17)

v1.15.0: Three-Gate Approval — TEST_LOG + COMMIT_MANIFEST + COMMIT_APPROVED.

### Three Mandatory Gates

Every commit now requires all three gates to pass:

1. **TEST_LOG** — Agent runs tests and logs results via `bash scripts/log-test-results.sh <pass> <fail> <cmd>`. The hook checks that the file exists, status=PASS, and is less than 1 hour old.
2. **COMMIT_MANIFEST** — Agent presents a written manifest via `commit-approval.sh`. The hook checks that the file exists and has content >20 bytes.
3. **COMMIT_APPROVED** — Fresh timestamped approval (<5 min) with matching commit message.

### New Files

- **`scripts/log-test-results.sh`** — Logs test pass/fail to `.git/TEST_LOG`. Rejects if fail >0.
- **`commit-msg` hook v6** — Verifies all 3 gates. Logs every attempt to `.git/APPROVAL_LOG` with timestamp and result (APPROVED/BLOCKED).

### Updated Files

- **`scripts/commit-approval.sh`** — v3: now writes COMMIT_MANIFEST, reads TEST_LOG, logs to APPROVAL_LOG.

## 1.14.0 (2026-06-17)

v1.14.0: Time-Window Approval — Replace SHA256 token system with frictionless timestamp-based approval.

### What Changed

The old `approve-commit.sh` used SHA256 hashes to bind commit messages to approval tokens. This created:
- **False security:** The `--auto` flag bypassed real verification (agent asserted "user said yes")
- **Complexity for no benefit:** The user never saw or touched the token
- **Maintenance burden:** Hash mismatches blocked legitimate commits

The new system uses a **time-window check** instead:

1. Agent presents DECISION POINT (manifest + diff + test results)
2. User says "yes commit" in chat
3. Agent runs `bash scripts/commit-approval.sh "message"`  
4. This writes `.git/COMMIT_APPROVED` with timestamp + message (plain text, no hash)
5. Agent commits
6. `commit-msg` hook v5 checks: file exists? <5 min old? message matches? → allows
7. File deleted after successful commit (no reuse)

### Files

- **NEW** `scripts/commit-approval.sh` — Timestamp-based approval writer
- **REMOVED** `scripts/approve-commit.sh` — Replaced by commit-approval.sh
- **UPDATED** `scripts/git-hooks/commit-msg` — v5: time-window check replaces hash verification
- **UPDATED** `scripts/git-hooks/pre-commit` — Removed stale COMMIT_APPROVED reference
- **UPDATED** `rules/common/enforcement.md` — Rule 12 reflects new time-window mechanism
- **UPDATED** `AGENTS-EXTENDED.md` — Commit Manifest Protocol updated
- **UPDATED** `install.sh`, `init-agents.sh` — Reference commit-approval.sh instead

### Impact

- Zero friction for the developer (no tokens, no scripts to run)
- 10 automated tests pass (sin args, format, freshness, expired, valid, reuse)
- All SKILL.md files unchanged
- commit-msg hook version: v4 → v5

## 1.13.0 (2026-06-16)

v1.13.0: Spec-Driven Refinements — Clarification, Convergence, Research Artifact, Parallel Markers.

### Structured Clarification (spec-driven-development)

- **P2 — Structured Clarification** — New phase after research, before discovery. Coverage scan flags vague nouns/verbs/numbers. Sequential questioning (one gap per question). Records answers in SPEC.md "Clarifications" section. Skip option for spikes (explicit waiver required, silence is not consent).

### Convergence Check (spec-driven-development)

- **P10 — Convergence** — Post-implementation verification. Each SPEC.md acceptance criterion checked against running code. FAIL items generate new tasks. Unplanned features flagged as scope creep. Produces CONVERGENCE REPORT with PASS/FAIL per criterion.
- Pipeline grows from 9 to 11 phases (P0-P10).

### Research Artifact (architecture-analysis)

- **Phase 2** — Findings now persist to `architecture/research.md` with evaluated technologies, benchmarks, sources, and decision context. Survives session boundaries and context compaction.
- New verification gate: `architecture/research.md` exists.

### Parallel Task Markers (planning-and-task-breakdown)

- **`[S]`/`[P]`/`[Pm]` markers** — Task template now includes marker field for sequential, parallelizable, and merge-point tasks. Grouping examples show parallelization patterns.
- New red flag: "All tasks marked [P] with no sequential tasks."

## 1.12.0 (2026-06-16)

v1.12.0: Design Principles Edition — 4 new design principles, pre-build plan review, writing philosophy.

### Design Principles (DESIGN-CORE.md)

- **Ground in the Subject** — Before any design decision, name Subject, Audience, and Single Job. Every layout/color/type decision traces back to this contract.
- **Hero Is a Thesis** — The hero opens with the single most characteristic thing about the subject, not a template slot.
- **Typography Carries Personality** — Pair display and body faces deliberately. No default system pairs. Typeface selection is a design decision.
- **Structure Is Information** — Numbered markers, dividers, labels must encode something true about the content, not decorate it.

### Pre-Build Design Plan Review

- **frontend-web Phase 3c** — Create a compact token system (color, type, layout, signature) and critique it against the brief before writing any code.
- **critique-skill Phase 0** — Design Plan Review: verify contract, check each token against brief, identify bold choice, cross-reference DESIGN-CORE.md. PASS/REVISE verdict antes de construir.

### Writing Philosophy

- **clarify-skill** — New "Writing Philosophy" section: words are design material, not decoration. Active voice, end-user side, plain terms, errors that explain.

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

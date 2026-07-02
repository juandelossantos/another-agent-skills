# Glossary

> A-Z reference of specialized terms used across the framework.
> Each term links to the source file where it's defined or primarily used.

---

## A

### Agent Loop

The core execution pattern where an agent iteratively reasons, acts (calls tools), observes results, and repeats until a goal is reached or a termination condition fires. Also called "the agentic loop." Must include termination guards (max iterations, token budget, timeout).

**Source:** `rules/common/enforcement.md` — Rule 12; Anthropic Claude docs "Build a tool-using agent"

### Anti-Rationalization

The practice of identifying and rejecting common rationalizations that lead agents to skip process steps. Documented as a table in `AGENTS-EXTENDED.md` with 25+ entries like "This is too small for a skill" and "The user already said yes before."

**Source:** `AGENTS-EXTENDED.md` — Anti-Rationalization table

### Approval Drift

The failure mode where approval from a previous commit is implicitly reused for subsequent commits without re-approval. Prevented by the Session-Level Lock (Rule 12) which requires explicit approval per commit.

**Source:** `rules/common/enforcement.md` — Rule 12

---

## B

### Batch-Mode Prevention

The mechanical rule that prevents multiple file edits from flowing into a single unapproved commit. After the last edit, the agent MUST STOP, present a Commit Manifest, and wait for explicit approval. Token generation and `git commit` MUST be in separate bash calls.

**Source:** `AGENTS-EXTENDED.md` — Edit-to-Commit Barrier

### Branch Interview

Step 2 of the Pre-Action Checklist (Rule 0d) where the agent presents the current git state and asks the user about branch intent before making any changes.

**Source:** `rules/common/enforcement.md` — Rule 0d

---

## C

### Commit Barrier (Edit-to-Commit)

The protocol that separates file editing from committing. Edits are approved during the Plan phase. Commits require a separate approval in the Commit phase. This prevents batch-mode commits.

**Source:** `AGENTS-EXTENDED.md` — Rule 0d Edit-to-Commit Barrier

### Commit Manifest

A structured block presented to the user before every commit, listing files changed, line counts, commit message, and a Rule 12 checklist. Requires explicit "yes commit" approval.

**Source:** `AGENTS-EXTENDED.md` — Commit Manifest Protocol

### COMMIT_APPROVED

A filesystem token written by `commit-approval.sh` after user says "yes commit." The commit-msg hook verifies this file exists, is <5 minutes old, and matches the commit message before allowing the commit.

**Source:** `scripts/commit-approval.sh`, `scripts/git-hooks/commit-msg`

### Context Budget (60/25/15)

The allocation strategy for context window usage: 60% current task, 25% core rules, 15% recent history. Enforced by compaction when messages exceed 20 turns.

**Source:** `rules/common/context.md` — Rule 0e

### Context Compaction

The process of evicting or compressing low-priority context when the session exceeds 20 messages. Applies the 60/25/15 budget: current task preserved, core rules summarized, history truncated. Never evicts active work.

**Source:** `rules/common/context.md` — Rule 0e

---

## D

### DECISION POINT

A mandatory block presented before any mutation, containing the proposed change, files affected, and approval request. Invalid responses ("ok", "mmhm", "continue") are rejected.

**Source:** `rules/common/enforcement.md` — Rule 12 Guardian Pattern

### Design Gate

A mechanical gate (`scripts/design-gate.sh`) that blocks implementation of visual/design work unless DESIGN.md is present and the appropriate design skill has been loaded.

**Source:** `scripts/design-gate.sh`, `AGENTS-EXTENDED.md`

### Design Skin

A category of skill that defines visual direction and output enforcement. Includes `industrial-brutalist-ui`, `minimalist-ui`, `soft-premium-ui`, `output-skill`, and `redesign-skill`.

**Source:** `AGENTS-EXTENDED.md` — Skill Hierarchy

### Development Artifacts

All draft, analysis, review, simulation, audit, roadmap, and refinement files. MUST be created in `development/` (gitignored). Never in the repo root or `skills/`.

**Source:** `rules/common/project.md` — Rule 11

---

## E

### Edit Guard

A protocol (`scripts/edit-guard.sh`) that verifies file integrity before and after every file edit. Pre-flight checks structural markers exist. Post-flight verifies line count hasn't changed unexpectedly.

**Source:** `scripts/edit-guard.sh`, `AGENTS-EXTENDED.md` — Edit Guard Protocol

### Edit-to-Commit Barrier

See [Commit Barrier](#commit-barrier-edit-to-commit).

**Source:** `AGENTS-EXTENDED.md` — Rule 0d Edit-to-Commit Barrier

---

## G

### Guardian Pattern

The meta-pattern that governs all git mutations. Before every commit, merge, push, or any mutating operation, the agent must present a DECISION POINT and receive explicit user approval. No batch-mode, no implied consent.

**Source:** `rules/common/enforcement.md` — Rule 12

---

## H

### Harness Engineering

The discipline of designing the deterministic driver code around an agent — context assembly, tool execution, budgets, stop conditions, durable state, observability — rather than tuning the model itself. Formalized in SOUL.md Principle 10: Agent = Model + Harness.

**Source:** `SOUL.md` — Principles 9 & 10

---

## I

### Intent Mapping

The process of detecting the user's platform or task type before invoking a skill. Defined in Rule 2: "web" → `frontend-web`, "mobile" → `frontend-mobile`, etc.

**Source:** `rules/common/skills.md` — Rule 2

---

## L

### Language Compliance

The rule (Rule 10) that agents must detect the user's language from their prompt and respond exclusively in that language. Never mix languages.

**Source:** `rules/common/project.md` — Rule 10

### Lazy Loading

The architecture where skills are kept as ~250-line indexes and guides are loaded on-demand via the `skill()` tool. Saves ~45% of always-loaded tokens compared to loading all content at session start.

**Source:** `rules/common/context.md` — Rule 6

### Loopmaxxing

The anti-pattern of running more iterations without a verifiable exit condition, assuming more loops = better result. Coined as the multi-step descendant of token-maxxing. Prevented by budgeted iteration with verification gates.

**Source:** `AGENTS-EXTENDED.md` — Anti-Rationalization table

---

## M

### Mayéutic Challenge

The principle (Rule 0g) that agents must challenge non-trivial decisions before accepting them. Named after the Socratic method of midwifing truth through questioning. The agent must verify objectives, challenge suboptimal approaches, surface tradeoffs, question scope creep, and say "no" when justified.

**Source:** `rules/common/behavioral.md` — Rule 0g

### Mayéutic Enforcement

The behavioral gate that requires the agent to write a `.git/TASK_MANIFEST` before executing non-trivial tasks. The manifest must contain: files affected, edge cases, alternatives, and risks. Verified by `scripts/task-manifest.sh`.

**Source:** `SOUL.md` — Mayéutic Enforcement section

---

## O

### Output Enforcement

The practice of preventing placeholders, truncated code, and half-finished agent outputs. Enforced by the `output-skill` which validates completion before delivery.

**Source:** `.opencode/skills/output-skill/SKILL.md`

---

## P

### PR Review Gate

A mechanical gate (`scripts/pr-review-checklist.sh`) run before merging any PR. Verifies: PR state, diff size, no secrets, code with tests, skill file sizes, hooks integrity, descriptive commit messages.

**Source:** `scripts/pr-review-checklist.sh`, `AGENTS-EXTENDED.md` — Rule 12b

### Pre-Flight

The initial check (Step 1 of Rule 0d) that runs `git status`, `git fetch --dry-run`, and `git branch --show-current` before ANY edit, creation, or deletion. Blocks if working tree is dirty or branch is wrong.

**Source:** `scripts/pre-flight.sh`, `rules/common/enforcement.md` — Rule 0d

---

## S

### Session-Level Lock

The rule that after any user approval, the agent resets to "unapproved" state immediately. No session-level "approved mode" exists. Every commit is a separate decision. Previous approval does NOT transfer.

**Source:** `AGENTS-EXTENDED.md` — Commit Manifest Protocol

### Skill Lint

An automated validation (`scripts/skill-lint.sh`) that checks all skills against Rule 6 compliance: SKILL.md ≤ 250 lines, ≥2 guides per skill (if >100 lines), no ALWAYS/NEVER caps violations, consistent VERSION references.

**Source:** `scripts/skill-lint.sh`

### Skill Gate

A mechanical enforcement (`scripts/skill-gate.sh`) that provides filesystem-level verification that skills were consulted before implementation. The pre-commit hook blocks commits if no skills were loaded.

**Source:** `scripts/skill-gate.sh`, `AGENTS-EXTENDED.md` — Skill Gate Enforcement

### Skill Hierarchy

The layered organization of skills: Foundation → Frontend → Backend → DevOps → Process → Quality. Each layer has specific skills. Defined in Rule 1 and the full table in AGENTS-EXTENDED.md.

**Source:** `rules/common/skills.md` — Rule 1

### Stack Agnosticism

The default stance (Rule 5) that skills must work across technology stacks. Defaults: React/Next.js/Tailwind (web), React Native/Expo (mobile), Tauri/Rust (desktop). Adapted when user specifies otherwise via SPEC.md Tech Stack.

**Source:** `rules/common/project.md` — Rule 5

---

## T

### TASK_MANIFEST

A file written to `.git/TASK_MANIFEST` before executing non-trivial tasks. Contains: files affected, edge cases, alternatives, risks. Verified by `scripts/task-manifest.sh check`.

**Source:** `scripts/task-manifest.sh`

### Trigger Accuracy

A metric tracked by the eval system (`scripts/eval/trigger-dashboard.sh`) measuring how often a skill activates on the correct input (positive cases) and does NOT activate on incorrect input (negative cases). Target: ≥90%.

**Source:** `scripts/eval/trigger-dashboard.sh`

### TEST_LOG

A log file in `.git/TEST_LOG` written by `scripts/log-test-results.sh`. Required by the commit-msg hook (Gate 1/3) — must be <1 hour old for commit to proceed.

**Source:** `scripts/log-test-results.sh`

### Three-Gate Approval

The commit approval mechanism requiring three gates: (1) TEST_LOG fresh, (2) COMMIT_MANIFEST present, (3) COMMIT_APPROVED fresh (<5 min). All three must pass for the commit-msg hook to allow the commit.

**Source:** `scripts/git-hooks/commit-msg` — v6

### Time-Window Approval

The mechanism where `commit-approval.sh` writes a timestamped approval file valid for 5 minutes. Prevents reuse of old approvals across sessions or commits.

**Source:** `scripts/commit-approval.sh`

### TOOL_GAP

The principle (Rule 0h) that when verification tools cannot reach the world (no network, no build environment, no test runner), the agent must report "ship status unknown" and STOP. Never fake a win on a gap.

**Source:** `rules/common/behavioral.md` — Rule 0h

### Turbo Mode

A reduced-scope mode for trivial/prototype work (Rule 4). Reduces research phase and extended discovery. Never reduces: SPEC.md, .gitignore, anti-slop rules, build verification, pre-commit checklist, or secrets scanning.

**Source:** `rules/common/project.md` — Rule 4

---

## U

### Universal First (Rule 0k)

The rule that before any implementation, the agent must ask: "Does this work on OpenCode, Claude Code, Cursor, Devin, and Gemini CLI?" If not, the design must be configurable (env vars), descriptive (capabilities, not tools), and fallback-compatible.

**Source:** `rules/common/behavioral.md` — Rule 0k

---

## Index by Source File

| Source File | Terms Defined |
|---|---|
| `SOUL.md` | Harness Engineering, Loopmaxxing, Mayéutic Enforcement |
| `rules/common/behavioral.md` | Mayéutic Challenge, TOOL_GAP, Universal First |
| `rules/common/context.md` | Context Budget, Lazy Loading |
| `rules/common/enforcement.md` | Branch Interview, Commit Barrier, Guardian Pattern, Pre-Flight, Session-Level Lock |
| `rules/common/project.md` | Development Artifacts, Language Compliance, Stack Agnosticism, Turbo Mode |
| `rules/common/skills.md` | Intent Mapping, Skill Gate, Skill Hierarchy |
| `AGENTS-EXTENDED.md` | Anti-Rationalization, Batch-Mode Prevention, Commit Manifest, DECISION POINT, Design Gate, Edit Guard, PR Review Gate, Three-Gate Approval |
| `AGENTS-EXTENDED.md` | Edit-to-Commit Barrier, Skill Gate Enforcement |
| `scripts/` | COMMIT_APPROVED, COMMIT_MANIFEST, TASK_MANIFEST, TEST_LOG, Time-Window Approval |
| `.opencode/skills/` | Design Skin, Output Enforcement |

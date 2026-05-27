---
name: engineering-fundamentals
description: >
  Universal engineering philosophy for all platform skills. Defines discovery,
  contracts, anti-slop, quality gates. All platform skills (frontend-web,
  frontend-mobile, backend-api, etc.) reference this skill as their foundation.
  Never invoke directly.
license: MIT
compatibility: opencode
metadata:
  audience: all-engineers
  type: foundation-skill
---

# Engineering Fundamentals

**Foundation for all platform skills. Never invoke directly.**

Platform skills add implementation specifics to this philosophy.

## Core Philosophy

1. **Contracts Before Code** — No file until SPEC.md, DESIGN.md, DESIGN-LOCK.md, .gitignore exist.
2. **Discovery Before Design** — No code until assumptions surfaced and confirmed.
3. **Anti-Slop** — Default AI output is generic. Intentionality prevents that.
4. **Gates Before Progress** — Every phase ends with user confirmation.
5. **Behavioral Discipline** — See AGENTS.md Rule 0c. Think before coding. Simplicity first. Surgical changes. Goal-driven execution.

## Pre-Flight: Repo State Check (Before ANY phase)

Before any phase, if the project is a git repository:
1. `git status` — working tree must be clean (no unstaged changes, no untracked files that would conflict)
2. `git log --oneline -3` — understand recent context
3. `git fetch --dry-run` — check if remote has unpulled changes (blocking: do NOT work on a stale base)

**If working tree is dirty** → commit or stash before new work.
**If remote has unpulled changes** → `git pull --rebase` before new work.
**If not a git repo** → `git init` first (see `git-init-and-versioning`).

This is not optional. It runs before Phase 0 and before any edit, creation, or deletion of files.

---

## Universal Process

### Phase 0 — Language Detection

Detect immediately. Spanish keywords → Spanish. English keywords → English. Other → that language, fallback to English. Never mix.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE UNTIL COMPLETE.**

**Surface:** Audience, Core problem, Scale (MVP/Standard/Complex), Platform-specific. **Discover (min 5):** Audience, Purpose, Scope, Context, Constraints. **Extended (non-trivial):** Data, Security, Integrations, Offline, Scalability.

**Confirm:** Summarize. Ask "Is this correct? Shall we proceed?" Only after explicit yes, proceed.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If no SPEC.md exists and this is new work (not a one-off tweak), invoke `spec-driven-development`.

Must include: Objective, Scope, Tech stack (locked versions), Project structure, Acceptance criteria, Boundaries.

#### 2B: DESIGN.md (VISUAL ONLY)

**CRITICAL:** DESIGN.md is for **visual identity and tokens ONLY**.

**What goes in:** Colors, Typography, Spacing, Border radius, Elevation/shadows, Motion tokens, Component visual tokens, Do's and Don'ts.

**What NEVER goes in:** Tech versions, folder structure, API routes, state management, auth, DB schema, business logic.

**Paths:**
- **Path A** — DESIGN.md exists: Read it, extract tokens, build within them.
- **Path B** — No DESIGN.md, user wants visual system: Generate with visual tokens only. Present for confirmation.
- **Path C** — No DESIGN.md, one-off task: Do the task. Mention once that DESIGN.md improves consistency.

**AFTER DESIGN.md CONFIRMED — MANDATORY STOP:**

Do NOT write code yet. DEFINE is complete, not BUILD.

1. Check if SPEC.md exists. If not, invoke `spec-driven-development`.
2. Invoke `planning-and-task-breakdown` for implementation plan.
3. Only after plan exists and is confirmed, proceed to BUILD.

#### 2C: Design Asset Lock (MANDATORY after visual approval)

Create `design/` directory:

```
design/
├── DESIGN-LOCK.md          # Snapshot of approved visual decisions
└── approved/               # Screenshots, previews, moodboards
```

`DESIGN-LOCK.md` must contain: Direction, Final Palette, Final Typography, Key Decisions, References.

**Rules:**
- DESIGN-LOCK.md is a SNAPSHOT. Never changes after approval unless explicitly requested.
- During BUILD, MUST read `design/DESIGN-LOCK.md` before writing any code. Do not rely on memory.

#### 2D: Lifecycle Awareness

Respect `AGENTS.md` lifecycle:
- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → Platform-specific skill + `incremental-implementation`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch`

---

### Phase 3 — Design Direction (Path B only)

Use the platform-specific skill's direction system (e.g., frontend-web: Three Dials System). Do not blend.

See platform skill for detailed direction selection.

---

### Phase 4 — Anti-Slop Principles

**Intentionality:** NO defaults without justification. Every choice has a reason. Timid palettes, safe fonts, default layouts = forbidden.

**Tokens Over Hardcoding:** NO hardcoded values. All from DESIGN.md/theme. Used twice = must be a token.

**Performance:** NO convenience-over-performance tradeoffs. Measure: 60fps, fast loads, minimal bundles.

**Accessibility:** NOT optional. Always: 4.5:1 contrast, focus indicators, reduced motion. Accessibility is a gate.

---

### Phase 5 — Quality Gates

Before declaring complete:

1. **Contracts present** — SPEC.md and DESIGN.md exist and were read.
2. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
3. **No hardcoded tokens** — All colors, fonts, spacing from token system.
4. **Accessibility** — Contrast 4.5:1, focus indicators, reduced motion fallback.
5. **Build passes** — Compilation succeeds without errors.
6. **Visual consistency** — No design element deviates from DESIGN.md without explicit approval.

---

### Phase 6 — Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Default for now." | #1 sign of AI output. |
| "Too small for DESIGN.md." | 3 lines of tokens help even one-offs. |
| "Quality later." | Quality is a gate, not afterthought. |
| "user didn't ask for [practice]." | Senior engineers apply best practices by default. |
| "I remember design." | Context drifts. DESIGN-LOCK.md is ground truth. |
| "I know what they want." | 1% confidence. Discovery forces 95%. |

---

### Phase 7 — Red Flags

Code before reqs. "Start building?" before "done" defined. Assumptions unsurfaced. Contracts skipped. Hardcoded values. Accessibility optional. DESIGN-LOCK.md not read. Features not in spec.

---

## Platform Skill Template

Every platform skill follows `PLATFORM-SKILL-TEMPLATE.md` — read it before creating. Core structure: Stack Detection → Discovery → Contracts → Direction → Anti-Slop → Build → QA → Verification. Each phase references `engineering-fundamentals` + adds platform-specific rules.

---

## Verification

SPEC.md with Objective/Scope/Stack/Acceptance/Boundaries. DESIGN.md with visual tokens. DESIGN-LOCK.md read before coding. Discovery done before code. User confirmed each gate. No hardcoded tokens. Accessibility (4.5:1 contrast, focus, reduced motion). Build passes.

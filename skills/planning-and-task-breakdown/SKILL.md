---
name: planning-and-task-breakdown
description: Decompose work into small, verifiable tasks with explicit acceptance criteria. Use when a spec needs breakdown into implementable steps. Do NOT use for single-file changes.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: plan
---

# Planning and Task Breakdown

## Overview

Decompose work into small, verifiable tasks with explicit acceptance criteria. Every task should be small enough to implement, test, and verify in a single focused session.

## When to Use

- You have a spec and need to break it into implementable units
- A task feels too large or vague to start
- Work needs to be parallelized across multiple agents or sessions
- The implementation order isn't obvious

## When NOT to Use

- Single-file changes with obvious scope
- Spec already contains well-defined tasks

## Output Contract

Task breakdown plan — ordered task list (any project, any stack) with acceptance criteria, verification steps, dependencies, and file scope per task, sized XS/S/M/L, with parallelization markers ([S]/[P]/[Pm]), checkpoint every 2-3 tasks, reviewed and approved by user before implementation.

## The Planning Process

### Step 1: Enter Plan Mode
Read the spec and relevant code. Identify patterns, map dependencies, note risks. **Do NOT write code during planning.** The output is a plan document, not implementation.

### Step 2: Identify the Dependency Graph
Map what depends on what. Implementation order follows the dependency graph bottom-up: build foundations first.

```
Database schema → API models → API endpoints → Frontend client → UI
```

### Step 3: Slice Vertically
Build one complete feature path at a time, not all of one layer.

**Bad:** Task 1: All DB → Task 2: All API → Task 3: All UI
**Good:** Task 1: Create account → Task 2: Log in → Task 3: Create task

### Step 4: Write Tasks
→ See `guides/TEMPLATES.md` for full templates.

Each task needs: Description, Acceptance criteria, Verification steps, Dependencies, Files touched, Estimated scope.

### Step 5: Order and Checkpoint
Arrange so dependencies are satisfied, each task leaves a working state, checkpoints every 2-3 tasks, and high-risk tasks are early (fail fast).

## Task Sizing

→ See `guides/TEMPLATES.md` for checkpoint format.

| Size | Files | Scope |
|---|---|---|
| XS | 1 | Single function or config |
| S | 1-2 | One component or endpoint |
| M | 3-5 | One feature slice |
| L | 5+ | Break it down further |

If a task takes >2 hours, has >3 acceptance criteria, touches independent subsystems, or has "and" in the title — break it down.

## Parallelization

→ See `guides/PARALLELIZATION-AND-ANTI-PATTERNS.md` for full guide.

Mark tasks: `[S]` sequential, `[P]` parallelizable, `[Pm]` merge point.

## References

- [PATTERNS.md](../../PATTERNS.md) — Workflow pattern selection guide. Consult before choosing a pattern (Guardian, Lazy Loading, Skill Gate, etc.).
- [ANTI-PATTERNS.md](../../ANTI-PATTERNS.md) — Common workflow anti-patterns to avoid.
- [GLOSSARY.md](../../GLOSSARY.md) — Terminology reference for framework terms.

## Verification

Before starting implementation, confirm:

- [ ] PATTERNS.md consulted for workflow pattern selection
- [ ] Every task has acceptance criteria
- [ ] Every task has a verification step
- [ ] Task dependencies are identified and ordered correctly
- [ ] No task touches more than ~5 files
- [ ] Checkpoints exist between major phases
- [ ] The human has reviewed and approved the plan

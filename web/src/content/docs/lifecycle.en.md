---
title: "Lifecycle"
description: "The six-phase development lifecycle: Define, Plan, Build, Verify, Review, Ship. Each phase has an exit criterion and a set of skills."
lang: "en"
order: 10
section: "concepts"
tldr: "Every task runs Define, Plan, Build, Verify, Review, Ship. No phase is optional, and each phase has an exit criterion and a set of skills that carry it."
---

## The path

```
DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP
```

No phase is optional. Every step has a skill. Every skill has a gate.

## Phase 1: Define

Write the spec before any code. Interview requirements. Lock scope.

- **Skills:** `spec-driven-development`, `architecture-analysis`, `interview-me`, `idea-refine`
- **Output:** `SPEC.md`, `DESIGN.md`, `.gitignore`
- **Gate:** No code until the contract exists.

## Phase 2: Plan

Break the work into atomic tasks. Each task must be independently testable.

- **Skills:** `planning-and-task-breakdown`
- **Output:** A task list with acceptance criteria.

## Phase 3: Build

Implement one slice at a time. Test each slice before expanding.

- **Skills:** `incremental-implementation`, `test-driven-development`, `source-driven-development`, `doubt-driven-development`
- **Output:** Working code with tests.
- **Gate:** Each slice is tested before it expands.

## Phase 4: Verify

Run the tests. Check the build. Verify behavior against the spec.

- **Skills:** `test-driven-development`, `debugging-and-error-recovery`, `browser-testing-with-devtools`
- **Output:** Passing tests, clean build.

> **TOOL_GAP:** If the tools cannot reach the world, report "ship status unknown." Never fake a win. The absence of evidence is not evidence of absence.

## Phase 5: Review

Code review, security, performance, quality.

- **Skills:** `code-review-and-quality`, `security-and-hardening`, `performance-optimization`
- **Output:** A review report and passing quality gates.
- **UI work:** run the design review pipeline: critique, audit, clarify, hard, polish, typeset, adapt, optimize, delight.

## Phase 6: Ship

Clean commits, CI/CD, deploy.

- **Skills:** `git-workflow-and-versioning`, `ci-cd-and-automation`, `shipping-and-launch`
- **Output:** Deployed code and updated documentation.

## Purpose-driven execution

The lifecycle weights phases by the purpose of the session, so a brainstorming session is not forced through Ship.

| Purpose | Primary phases | Key skills |
|---|---|---|
| Brainstorming | Define | `interview-me`, `idea-refine` |
| Development | Define to Build | `spec-driven-development`, `incremental-implementation`, `test-driven-development` |
| Code review | Review | `code-review-and-quality`, `security-and-hardening`, `performance-optimization` |
| Debugging | Verify | `debugging-and-error-recovery` |
| PR review | Review to Ship | `pr-review-checklist.sh` |

## Why the phases matter

The phases are not ceremony. They are the places where a mistake is still cheap to fix. A wrong spec costs a conversation. A wrong build costs a day. A wrong deploy costs trust.

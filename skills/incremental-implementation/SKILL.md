---
name: incremental-implementation
description: Build features incrementally in thin vertical slices. Use when touching multiple files or when a task feels too large for one step. Do NOT use for single-file changes.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: build
---

# Incremental Implementation

## Overview

Build in thin vertical slices — implement one piece, test it, verify it, then expand. Each increment should leave the system in a working, testable state.

## When to Use

- Implementing any multi-file change
- Building a new feature from a task breakdown
- Refactoring existing code
- Any time you're tempted to write >100 lines before testing

**When NOT to use:** Single-file, single-function changes where scope is already minimal.

## The Increment Cycle

```
Implement → Test → Verify → Commit → Next slice
```

1. **Implement** the smallest complete piece of functionality
2. **Test** — run the test suite (or write a test if none exists)
3. **Verify** — tests pass, build succeeds, manual check
4. **Commit** — descriptive message (see `git-workflow-and-versioning`)
5. **Move to the next slice**

## Slicing Strategies

→ See `guides/SLICING-STRATEGIES.md` for detailed examples.

| Strategy | When | Structure |
|---|---|---|
| **Vertical** | Preferred | One complete feature path per slice |
| **Contract-First** | Parallel FE/BE | Define API contract first, then parallel |
| **Risk-First** | High uncertainty | Riskiest piece first (fail fast) |

## Implementation Rules

### Rule 0: Simplicity First
Ask "What is the simplest thing that could work?" before writing code. Three similar lines is better than a premature abstraction.

### Rule 0.5: Scope Discipline
Touch only what the task requires. Note improvements outside scope — don't fix them. Refer to `incremental-implementation` for the scope rule.

### Rule 1: One Thing at a Time
Each increment changes one logical thing. Don't mix feature work with refactoring.

### Rule 2: Keep It Compilable
Project must build and tests must pass after each increment.

### Rule 3: Feature Flags
Flag incomplete features behind env vars so you can merge without exposing.

### Rule 4: Safe Defaults
New code defaults to safe, conservative behavior (opt-in, not opt-out).

### Rule 5: Rollback-Friendly
Each increment independently revertable. Additive changes preferred over modifications.

## Increment Checklist

- [ ] Change does one thing and does it completely
- [ ] All existing tests pass
- [ ] Build succeeds
- [ ] Type checking passes
- [ ] Linting passes
- [ ] New functionality works as expected
- [ ] Descriptive commit message

## Verification

- [ ] Each increment individually tested and committed
- [ ] Full test suite passes; build is clean
- [ ] Feature works end-to-end as specified
- [ ] No uncommitted changes remain

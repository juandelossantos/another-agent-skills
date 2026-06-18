---
name: code-simplification
description: >
  Simplify code for clarity without changing behavior. Use when refactoring code
  that works but is harder to read, maintain, or extend than it should be.
  Complements code-review-and-quality: review finds issues, simplification resolves them.
  Do NOT use when behavior must change, or for pure formatting/linting.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: review-simplify
---

# Code Simplification

**Reduce unnecessary complexity while preserving behavior.**

Complements `code-review-and-quality`. Where code review identifies problems, code simplification fixes them by reducing complexity without changing what the code does.

## When to Use

- Code is correct but harder to read than necessary
- Abstractions don't earn their complexity
- Functions or components are too large
- Duplicated logic could be unified
- After code review reveals complexity issues

## When NOT to Use

- Behavior must change (use feature implementation skills)
- Only formatting or linting issues (use formatter/linter)
- The code is already as simple as it can be

## Relationship

`code-review-and-quality` → identifies issues → `code-simplification` → resolves them.

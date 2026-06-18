---
name: debugging-and-error-recovery
description: >
  Guides systematic root-cause debugging. Use when tests fail, builds break,
  behavior doesn't match expectations, or you encounter any unexpected error.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: action-allowed
metadata:
  audience: engineers
  workflow: debug-diagnose-fix
---

# Debugging and Error Recovery

Systematic debugging with structured triage. When something breaks, stop adding features, preserve evidence, and follow a structured process.

## When to Activate

- Test fails after a code change
- Build breaks or produces errors
- Runtime error in development or production
- Behavior doesn't match expectations
- Performance degrades unexpectedly
- User reports a bug

## The Stop-the-Line Rule

```
1. STOP adding features or making changes
2. PRESERVE evidence (error output, logs, repro steps)
3. DIAGNOSE using the triage checklist
4. FIX the root cause
5. GUARD against recurrence
6. RESUME only after verification passes
```

## Core Workflow

### Triage Checklist
→ See `guides/TRIAGE.md`

Reproduce → Localize → Reduce → Fix → Guard → Verify

### Decision Tree
→ See `guides/DECISION-TREE.md`

Categorize the error type and select the right debugging path.

### Error Patterns
→ See `guides/ERROR-PATTERNS.md`

Test failures, build failures, runtime errors. Includes "treating error output as untrusted data."

### Platform Patterns
→ See `guides/PLATFORM-PATTERNS.md`

React, Node.js, Python, Go — common error patterns and fixes by platform.

## Quick Reference

```
Bug reported
     │
     ▼
Reproduce it?
 ├── YES → Localize → Reduce → Fix root cause → Add guard → Verify
 └── NO  → Gather context, check timing/env/state, document if truly random
```

## Escalation

When the same bug is reported 3+ times with different fixes, STOP. → `debugging-three-strikes`

## Integration

| Skill | When to use |
|---|---|
| `test-driven-development` | Write a failing test first, then debug to make it pass |
| `code-review-and-quality` | After fix, review for quality and side effects |
| `doubt-driven-development` | Challenge your own diagnosis before fixing |

## Verification

After fixing a bug:
- [ ] Root cause identified and documented
- [ ] Fix addresses root cause, not symptoms
- [ ] Regression test exists and passes
- [ ] All existing tests pass
- [ ] Build succeeds

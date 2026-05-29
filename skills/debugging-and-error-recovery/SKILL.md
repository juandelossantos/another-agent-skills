---
name: debugging-and-error-recovery
description: >
  Guides systematic root-cause debugging. Use when tests fail, builds break,
  behavior doesn't match expectations, or you encounter any unexpected error.
---

# Debugging and Error Recovery

Systematic debugging with structured triage. When something breaks, stop adding features, preserve evidence, and follow a structured process.

## The Stop-the-Line Rule

When anything unexpected happens:

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

### Error Patterns
→ See `guides/ERROR-PATTERNS.md`

Test failures, build failures, runtime errors.

## Detailed Guides

| Guide | Content |
|-------|---------|
| `guides/TRIAGE.md` | 6-step checklist: Reproduce → Localize → Reduce → Fix → Guard → Verify |
| `guides/ERROR-PATTERNS.md` | Error-specific triage patterns, common error types |

## Quick Reference

```
Bug reported
     │
     ▼
Reproduce it?
 ├── YES → Localize → Reduce → Fix root cause → Add guard → Verify
 └── NO  → Gather context, check timing/env/state, document if truly random
```

## Verification

After fixing a bug:

- [ ] Root cause is identified and documented
- [ ] Fix addresses the root cause, not just symptoms
- [ ] A regression test exists
- [ ] All existing tests pass
- [ ] Build succeeds

---
name: debugging-three-strikes
description: "Stop speculative debugging after 3 same-bug strikes. Diagnose systematically before writing code. Use when repetitive fixes fail. Do NOT use for first-time bugs."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: action-allowed
metadata:
  audience: engineers
  workflow: diagnose-stabilize
---

# 3 Strikes Protocol

**When the same bug is reported 3+ times with different fixes, STOP.**

## Trigger: Test Failure Recurrence

A mechanical pre-commit check reads `.git/STRIKES_LOG`. Same test name failing 3 consecutive commits → BLOCK and escalate.

```
Commit 1: test-X FAIL → strike 1 (logged)
Commit 2: test-X FAIL → strike 2 (logged)
Commit 3: test-X FAIL → BLOCK. Escalating.
```

Other triggers: session-level agent memory (same component fixed twice), `bug-tag:` in commit body repeating.

## Protocol

**Strike 1 — Diagnose then fix.** Every attempt starts with evidence, not speculation. Inspect DOM, network, console, logs. Document root cause. Fix. Verify tests pass.

**Strike 2 — Your diagnosis was wrong.** Re-diagnose with fresh context. Fix + add regression guard (test coverage, instrumentation, or lint rule).

**Strike 3 — Systemic failure.** The diagnosis-fix-verify cycle works but the system reproduces the bug. BLOCK. No more fix code.

**Agent must on strike 3:**
1. Stop all commits
2. Inspect real state (computed styles, network, console, DOM)
3. Document root cause vs expected behavior
4. Report to user before any fix code

## Escalation Matrix

| Root Cause | Route To |
|---|---|
| Test gap (no regression guard) | `test-driven-development` |
| Spec gap (requirements missed) | `code-review-and-quality` |
| Process gap (no quality gate) | `doubt-driven-development` |
| Architecture gap (design flaw) | `architecture-analysis` |
| Unknown or recurring after escalation | Full `project-health-check` + improvement loop |

## Anti-Patterns

1. **Same fix, harder** — The definition of insanity. Strike 3 means your approach is wrong.
2. **Skipping diagnosis** — "I know what's wrong" without inspecting. You didn't last 2 times.
3. **Not escalating** — Fixing strike 3 locally when the problem is systemic.
4. **Ignoring strike log** — Strike 3 didn't come from nowhere. The log told you test X was failing.

## Verification

- [ ] Strike 1: diagnose before fix, evidence documented
- [ ] Strike 2: re-diagnose, add regression guard
- [ ] Strike 3: BLOCK, escalate to appropriate skill
- [ ] `bash tests/run-all.sh` passes after fix

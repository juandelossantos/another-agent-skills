---
name: code-review-and-quality
description: >
  Conducts multi-axis code review. Use before merging any change. Use when reviewing
  code written by yourself, another agent, or a human.
---

# Code Review and Quality

Multi-dimensional code review with quality gates. Every change gets reviewed before merge.

**The approval standard:** Approve when it definitely improves overall code health. Perfect code doesn't exist — the goal is continuous improvement.

## When to Use

- Before merging any PR or change
- After completing a feature implementation
- When another agent or model produced code you need to evaluate
- When refactoring existing code
- After any bug fix (review both fix and regression test)

## Five-Axis Review

→ See `guides/FIVE-AXIS.md`

1. **Correctness** — Does it do what it claims?
2. **Readability** — Can another engineer understand it?
3. **Architecture** — Does it fit the system?
4. **Security** — Any vulnerabilities?
5. **Performance** — Any bottlenecks?

## Severity Labels

Every finding gets a severity label. Use these in review output:

| Label | Meaning | Action |
|---|---|---|
| 🔴 `blocking` | Must fix before merge | YES — blocks approval |
| 🟠 `important` | Should fix; may block depending on context | YES — discuss if disagree |
| 🟡 `nit` | Minor style or preference issue | NO — not blocking |
| 🔵 `suggestion` | Optional improvement worth considering | NO — FYI only |
| 📚 `learning` | Educational note for the author | NO — knowledge sharing |
| 🌟 `praise` | Explicitly highlight great work | NO — morale |

## TOOL_GAP: When You Can't Verify

Inspired by Sub-Zero Skill. If verification tools cannot reach the world:

| Verdict | Meaning | Action |
|---|---|---|
| ✅ PASS | Evidence confirms the claim | Proceed |
| ❌ FAIL | Evidence contradicts the claim | Fix, re-verify (max 3 cycles) |
| ⚠️ TOOL_GAP | Cannot reach the world to verify | **STOP. Report "ship status unknown." Never fake a win.** |

**Examples of TOOL_GAP:**
- "Tests pass" but test runner isn't installed → TOOL_GAP
- "URL returns 200" but no network access → TOOL_GAP
- "Build works" but build tool missing → TOOL_GAP
- "Code is clean" but linter not available → TOOL_GAP

**Rule:** The absence of evidence is not evidence of absence. If you can't check, say so.

## Core Workflows

### Review Process
→ See `guides/REVIEW-PROCESS.md`

Understand context → Review tests → Review implementation → Categorize findings → Verify

### Change Sizing
→ See `guides/CHANGE-SIZING.md`

Target ~100-300 lines. Split larger changes. Separate refactoring from feature work.

## Detailed Guides

| Guide | Content |
|-------|---------|
| `guides/FIVE-AXIS.md` | The 5 review dimensions explained |
| `guides/REVIEW-PROCESS.md` | Step-by-step review workflow |
| `guides/CHANGE-SIZING.md` | Sizing rules, splitting strategies |

## Quick Reference

```
PR submitted
     │
     ▼
Understand context + review tests first
     │
     ▼
Review code (5 axes)
     │
     ▼
Categorize findings with severity labels
     │
     ▼
Check: Can I verify? → TOOL_GAP if not
     │
     ▼
Verify: tests pass, build succeeds
     │
     ▼
Approve or Request Changes
```

## Red Flags

- PRs merged without any review
- "LGTM" without evidence of actual review
- Security-sensitive changes without security review
- Large PRs that are "too big to review properly"
- No regression tests with bug fix PRs

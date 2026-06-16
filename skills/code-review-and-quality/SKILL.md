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

## AI-Generated Code Review Checklist

Code produced by AI agents has distinct failure modes that differ from human-written code. Review it with these additional checks:

| Check | Why It Matters |
|---|---|
| **1. Hallucinated dependencies** | AI may reference packages that don't exist or have different APIs. Verify every import, require, and dependency against actual package registries. |
| **2. Subtle correctness gaps** | Code that "looks right" and passes happy-path tests may fail under edge cases. Push on boundary conditions, empty states, concurrent access, and invalid inputs. |
| **3. Superficial error handling** | AI commonly generates `try/catch(Exception)` with logging but no recovery. Verify that every error path has a meaningful fallback, not just a stack trace. |
| **4. Imports from real packages** | AI can fabricate import paths, fake subpackages, or reference APIs that don't exist in the installed version. Cross-reference against the actual package's public API. |
| **5. "Looks clever" skepticism** | Most clever AI-generated code is overengineered. If it's hard to understand at a glance, it's hard to maintain. Prefer simplicity over cleverness. |
| **6. Error paths, not just happy path** | AI optimizes for the success case. Trace every function's failure modes: what happens when a network call fails, a file doesn't exist, a response is malformed? |
| **7. Hallucinated configuration** | AI may invent config keys, environment variables, or CLI flags that don't exist. Verify against real documentation. |
| **8. Over-engineered abstraction** | AI tends to create abstractions (factories, strategies, builders) before they're needed. Prefer concrete implementations; abstract only when duplication is proven. |

**Pattern to reject:** "This looks right at a glance" without tracing through edge cases. AI-generated code requires the same or greater scrutiny than human-written code.

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

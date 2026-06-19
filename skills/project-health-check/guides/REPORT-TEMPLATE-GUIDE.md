# Report Template Guide

Phase 2 report template for `project-health-check`.

## HEALTH-CHECK.md Template

```markdown
# Project Health Check

**Date:** YYYY-MM-DD
**Auditor:** OpenCode Agent
**Status:** ⚠️ REQUIRES ATTENTION / ✅ HEALTHY

## Summary

- **Critical Issues:** N
- **Warnings:** N
- **Passes:** N
- **Overall:** HEALTHY / DEGRADED / CRITICAL

---

## Stack & Versions

| Check | Current | Required | Status |
|---|---|---|---|
| Node.js | 18.x | >= 20.9 | 🔴 FAIL |
| Next.js | 14.2 | >= 16.1.1 | 🔴 FAIL |
| ... | ... | ... | ... |

**Recommendation:** [Action]

---

## Project Structure

| Check | Status | Notes |
|---|---|---|
| SPEC.md | 🔴 Missing | No specification |
| DESIGN.md | 🔴 Missing | No visual contract |
| Tests | ⚠️ Partial | Only 2 test files |
| ... | ... | ... |

---

## Code Quality

| Check | Status | Files Affected |
|---|---|---|
| No Tailwind generics | 🔴 FAIL | `Button.tsx` uses `bg-blue-500` |
| Distinctive fonts | 🔴 FAIL | `layout.tsx` uses Inter |
| ... | ... | ... |

---

## Recommendations (Priority Order)

1. **🔴 CRITICAL:** [Issue and impact]
2. **⚠️ WARN:** [Issue and impact]
3. **💡 NICE:** [Suggestion]

---

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| YYYY-MM-DD | [A/B/C] | [Reason] |
```

## Report Rules

- Be honest. No sugarcoating.
- Link specific files and line numbers.
- Distinguish blocking vs non-blocking.
- One-sentence impact per issue: "This means..."

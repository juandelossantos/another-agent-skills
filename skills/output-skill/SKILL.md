---
name: output-skill
description: "Prevent placeholders, truncated code, and half-finished agent outputs. Use when the agent ships incomplete work. Do NOT use for one-off drafts."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  stack: any
  workflow: quality-enforcement
---

# Output Enforcement Skill

**Ship complete, runnable code — no shortcuts, no placeholders, no truncation.**

This is a pre-output self-audit. Complements the project's post-commit audit (`universal-audit.sh`) and pre-commit Gate 8 (Anti-Slop). Catches incomplete output before it's delivered.

## Core Process

### Phase 1 — Scope Lock

Before writing any code, declare the scope:

```
SCOPE:
  - src/api/handler.ts  (full implementation)
  - tests/handler.test.ts  (unit tests)
  - src/types.ts  (type updates only)
```

List every file and what it needs. Do NOT start writing until scope is set.

### Phase 2 — Output

Write each file end-to-end. Complete the current function before any break. If output is genuinely too long, use the truncation protocol.

### Phase 3 — Self-Audit

Before delivering, scan your own output for patterns:

| Category | Patterns to Check |
|---|---|
| **Truncation** | `// ...`, `/* ... */`, `... (remaining)` |
| **Structural shortcut** | `rest is similar`, `repeat for others`, `same for each item` |
| **Deferred work** | `// TODO:`, `// FIXME:`, `// implement later` |
| **Incomplete integration** | `add your API key`, `your token here`, `replace with actual` |

### Truncation Protocol

When output exceeds context limits:

1. Complete the current function/method (no mid-function breaks)
2. State remaining scope: "Remaining: [file list not yet delivered]"
3. End with: "Continue with [next file] when ready."
4. On continuation, re-check scope from Phase 1. Deliver remaining files completely.

## Detection Patterns

| Expression | Type | Severity |
|---|---|---|
| `// \.\.\.` or `/\* \.\.\. \*/` | Truncation | Block |
| `rest is similar|same for|repeat for` | Structural shortcut | Block |
| `for brevity|for brevity|you get the idea` | Evasion | Block |
| `TODO:|FIXME:|HACK:|XXX:` | Deferred work | Block |
| `add your|your.*here|replace with actual` | Incomplete integration | Block |
| `let me know if you want|let me continue` | Hand-off | Warn |

## Anti-Patterns

1. **"I'll continue later"** — Hand-off without completing the current function. Always finish the function.
2. **"Rest is obvious"** — Assuming the user can fill in the rest. Ship complete code.
3. **"Similar for others"** — One example != complete implementation. Every variant must be explicit.
4. **"You get the idea"** — The idea is not runnable code. The test runner requires actual code.
5. **Scope creep** — Adding unplanned files mid-output without updating the scope declaration.
6. **Skipping self-audit** — Delivering without scanning for patterns. Always scan before finalizing.

## Verification

- [ ] Scope declared before output started
- [ ] Each file in scope delivered completely (no mid-function breaks)
- [ ] Self-audit scan passed (no truncation, shortcut, defer, or incomplete patterns)
- [ ] Remaining scope stated if output was truncated
- [ ] Code is runnable as-delivered (no "add your X" or missing imports)
- [ ] `grep -nE '// \.\.\.|TODO:|for brevity|rest is similar|repeat for'` on output returns 0 matches

---
name: hard-skill
description: >
  Apply deterministic mechanical fixes for P0/P1 accessibility, input
  robustness, and state handling issues. Fixes what audit finds. Covers
  web, mobile, desktop, and PWA. Cross-platform only — does not fix
  design or copy issues.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  stack: any
  workflow: audit-harden
---

# Harden Skill

**Apply deterministic, mechanical fixes for P0/P1 issues found by `audit`.**

Harden does NOT redesign. It fixes what audit finds: accessibility, input robustness, state handling. If something needs a design decision, escalate to `polish` or `redesign`.

## When to Use

- After `audit` finds P0/P1 items
- User says "make this accessible"
- User says "handle edge cases better"
- Before shipping to production

Do NOT use for:
- Design decisions (use `polish`, `redesign`)
- Performance fixes (use `optimize`)
- Copy rewriting (use `clarify`)
- New features (use `build` skills)

## Process

### 1. Receive Audit Findings

Read output from `audit-skill`. If none exists, run a quick scan:

```bash
# Manual checklist — run against every component/file
- Are interactive elements keyboard-accessible?
- Are form labels present and associated?
- Does reduced motion break the layout?
- Are focus indicators visible?
- Are inputs validated with user-friendly feedback?
- Are empty/loading/error states handled?
- Are destructive actions reversible or confirmed?
```

### 2. Fix by Category

#### Accessibility Fixes

| Issue | Fix |
|---|---|
| Missing ARIA labels | Add `aria-label` or `aria-labelledby` |
| Keyboard trap | Ensure tab cycle completes |
| No focus indicator | Add `:focus-visible` outline |
| Reduced motion breakage | Wrap animations in `prefers-reduced-motion` |
| Missing semantic HTML | Replace `<div>` with `<button>`, `<nav>`, etc. |
| Low contrast | Adjust to WCAG AA (4.5:1 text, 3:1 large) |

#### Input Robustness

| Issue | Fix |
|---|---|
| Unvalidated input | Add type-specific validation with messages |
| Missing loading state | Add spinner/skeleton during async ops |
| Missing error state | Show error boundary or fallback UI |
| Missing empty state | Show message + action when list is empty |
| Uncontrolled race | Cancel inflight requests on unmount |
| Missing confirmation | Add confirm dialog on destructive actions |

#### State Handling

| Issue | Fix |
|---|---|
| No offline detection | Add `navigator.onLine` checks or event listeners |
| No retry on failure | Add retry button on transient errors |
| No fallback on missing data | Add null/undefined checks before render |
| Missing error boundary | Wrap component in error boundary |

### 3. Output Format

```
/harden the checkout form

Fix 1: Add aria-label to quantity stepper
  - Currently: <button>-</button> <span>1</span> <button>+</button>
  - Fix: <button aria-label="Decrease quantity">-</button>
    <span aria-role="status">1</span>
    <button aria-label="Increase quantity">+</button>

Fix 2: Add validation to card number input
  - Currently: free text, no format check
  - Fix: pattern="[0-9]{16}", error="Card number is 16 digits"

Fix 3: Confirm before clearing cart
  - Currently: "Clear cart" fires immediately
  - Fix: confirm dialog "Clear all 3 items?"
```

### 4. Escalation Rules

Escalate to other skills when:

| Finding | Escalate to |
|---|---|
| Wrong radius, spacing, or color | `polish` |
| Confusing UX flow | `redesign` |
| Performance bottleneck | `optimize` |
| Ambiguous copy | `clarify` |
| Wrong typeface or sizing | `typeset` |

If a fix requires a design decision (not a mechanical transformation), stop and escalate. Do not guess.

## Pitfalls

- **Over-hardening** — Not every `<div>` needs ARIA. Not every interaction needs loading state. Hardening is for audit findings, not speculative perfection.
- **Fixing design during harden** — Hard contrast fix applies the token. Changing the token is a design decision.
- **Silently changing behavior** — Every fix must preserve or improve behavior. Never remove a feature during hardening.

## AI Slop Detection

Same 25 anti-patterns as `critique-skill`. After applying fixes, re-scan for:

| Anti-pattern | Most likely in harden fixes |
|---|---|
| Perfect overlap | Duplicate loading states |
| False specificity | Vague ARIA labels like "button" |
| The middle path | Grey toast for success |
| Three equal cards | Three identical error messages |
| Ambiguous empty state | "Something went wrong" |

## QA Gates

- [ ] Every fix traces to a specific audit finding
- [ ] ARIA labels are descriptive, not generic
- [ ] Form labels properly associated (`htmlFor`/`aria-labelledby`)
- [ ] `prefers-reduced-motion` respected
- [ ] Focus indicators visible on all interactive elements
- [ ] Empty/loading/error states present where meaningful
- [ ] Destructive actions have confirmation
- [ ] No design decisions made — only mechanical fixes
- [ ] AI slop re-scanned post-fix

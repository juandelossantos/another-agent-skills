---
name: audit-skill
description: Audit code across 5 dimensions (accessibility, performance, theming, responsive, anti-patterns) with P0-P3 severity scoring. Use before shipping. Do NOT use for design critique.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-engineers
  stack: any
  workflow: audit-fix
---

# Audit Skill

**Technical counterpart to `critique-skill`.** Where critique asks "does this feel right", audit asks "does this hold up".

Audit documents; it does not fix. Route findings to `harden`, `polish`, `optimize`, or `clarify`.

## When to Use

- Before shipping to production
- During a quality sprint
- When tech lead says "we should look at [accessibility/performance]"
- After a feature is functionally complete but not reviewed

Do NOT use for:
- Design quality (use `critique-skill`)
- One-off tweaks (use individual fix skills directly)
- Incomplete features (audit finds issues that are just unfinished)

## Process

### Phase 1 — Scan (5 Dimensions)

Score each dimension 0-4:

| Dim | What it checks | Typical score |
|---|---|---|
| **Accessibility** | WCAG contrast, ARIA, keyboard nav, semantic HTML, form labels | Often the lowest |
| **Performance** | Layout thrashing, expensive animations, lazy loading, bundle weight | Usually decent |
| **Theming** | Hardcoded colors, dark mode coverage, token consistency | Often overlooked |
| **Responsive** | Breakpoint behavior, touch targets, mobile viewport | Depends on platform |
| **Anti-patterns** | Deterministic AI slop detection (same 25 as `critique-skill`) | Tells a story |

### Phase 2 — Severity Rating

| Severity | Definition | Action |
|---|---|---|
| **P0** | Blocks release. Security, broken layout, 0 contrast. | Route to `harden` immediately |
| **P1** | Should fix this sprint. Missing labels, no dark mode. | Route to `harden` or `polish` |
| **P2** | Next cycle. Minor token drift, optional performance. | Document for backlog |
| **P3** | Polish. Nice-to-have. | Log for future |

### Phase 3 — Output

```
/impeccable audit the checkout flow

Accessibility: 2/4 (partial)
  P0: Missing form labels on 4 inputs
  P1: Contrast 3.1:1 on disabled button state
  P2: No visible focus indicator on custom dropdown

Performance: 3/4 (good)
  P1: Hero image not lazy-loaded (340KB)

Theming: 2/4 (partial)
  P1: 3 hardcoded colors outside token system
  P2: Dark mode missing on 2 components

Responsive: 3/4 (good)
  P2: Touch target under 44px on mobile nav

Anti-patterns: 2.8/4
  P1: Three equal feature cards detected
```

## Dimension Details

### Accessibility

Score based on:

| Check | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| Color contrast | 0 elements pass | Some pass | Most pass | All pass AA | All pass AAA |
| Keyboard nav | Not possible | Partial | All interactive reachable | Logical order + visible focus | Skip links + shortcuts |
| ARIA | Missing or wrong | Partial | Correct on interactive | Correct everywhere + live regions | Full semantic + ARIA |
| Form labels | Missing | Some labeled | All labeled | + error association | + hints + autocomplete |
| Semantic HTML | Div soup | Some semantics | Mostly semantic | Correct landmarks | Full ARIA + semantic |

### Performance

| Check | Red flag |
|---|---|
| Layout thrashing | Forced reflows in animation loops |
| Expensive animations | Animating `width`, `height`, `top`, `left` |
| Missing lazy load | Images below fold without `loading=lazy` |
| Bundle weight | > 500KB critical path JS |
| Render blocking | CSS/JS blocking first paint |
| No code splitting | Single giant bundle |

### Theming

| Check | Red flag |
|---|---|
| Hardcoded colors | Any `color: #...` outside token file |
| Missing dark mode | Light-only UI in a theming-capable stack |
| Token drift | Component uses different gray than the system |
| Inline styles | `style={{ color: '#...' }}` scattered |

### Responsive

| Check | Red flag |
|---|---|
| Breakpoint gaps | Layout breaks between defined breakpoints |
| Touch targets | Interactive elements < 44px (iOS) / 48dp (Android) |
| Viewport issues | `100vh` on mobile, no `100dvh` fallback |
| Overflow | Content spills horizontally on small viewports |
| Hover-only | Actions unavailable on touch devices |

→ See `guides/SCORING-GUIDE.md` for severity scoring criteria.
→ See `guides/AUDIT-CHECKLIST.md` for the full 5-dimension checklist.

## Pitfalls

- **Confusing with `critique-skill`** — Audit is implementation quality. Critique is design quality. Run both.
- **Fixing P3s before P0s** — Severity exists for a reason. Start at the top.
- **Skipping dimensions you think are fine** — Theming and responsive are the most commonly assumed-fine-but-not.

## Related Commands

| Finding | Route to |
|---|---|
| P0 accessibility | `harden` |
| P0-P1 performance | `optimize` |
| P1 theming | `polish`, `typeset` |
| P1 responsive | `adapt` |
| P0-P1 any | `harden` |
| P2-P3 any | `polish` |

## QA Gates

- [ ] All 5 dimensions scored
- [ ] All findings tagged P0-P3
- [ ] P0 items clearly identified as blocking
- [ ] No fixes applied — audit documents only
- [ ] Recommendations routed to correct fix skills

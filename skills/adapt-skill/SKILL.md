---
name: adapt-skill
description: Fix responsive layout issues, missing mobile behavior, touch targets, and viewport handling. Use when layouts break between breakpoints. Do NOT use for static layouts with no responsive requirements.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-engineers
  stack: any
  workflow: audit-adapt
---

# Adapt Skill

**Fix responsive behavior so layouts work at every size.**

Adapt is the responsive counterpart to `polish`. Where `polish` fixes the design system, `adapt` fixes the viewport.

## When to Use

- Layout breaks between defined breakpoints
- Mobile feels like an afterthought (tabs, full-width cards, tiny targets)
- Touch interactions don't work
- Horizontal scroll overflow
- User says "this doesn't work on my phone"
- After adding responsive review to a shipping pipeline

## When NOT to Use

- Creating new responsive layouts from scratch (use `build` skills)
- Animations (use `delight` or `optimize`)
- Typography scaling (use `typeset`)
- Performance (use `optimize`)

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Responsive CSS fixes | CSS | Source files | Works at 360px, 768px, 1024px, 1440px+ |

## Process

### 1. Scan at Breakpoints

Test each major viewport width:

| Width | Type | Common issues |
|---|---|---|
| 360px | Small mobile | Touch targets, overflow, stacked tabs, cramped forms |
| 768px | Tablet | Split view breaks, sticky elements overlap |
| 1024px | Desktop | Content too wide, whitespace imbalance |
| 1440px+ | Wide | Columns stretch too far, line-length > 80ch |

### 2. Fix by Category

#### Layout

| Issue | Fix |
|---|---|
| Overflow (horizontal scroll) | Add `overflow-x: hidden` or `min-width: 0` on flex children |
| Broken grid columns | Add `grid-template-columns: repeat(auto-fit, minmax(280px, 1fr))` instead of fixed cols |
| Stacked panels | Side-by-side → stacked below breakpoint |
| Sticky overlaps | Check `position: sticky` elements don't overlap content |

#### Touch

| Issue | Fix |
|---|---|
| Touch target < 44px | Increase size or padding to minimum 44px (iOS HIG) / 48dp (Material) |
| Hover-only actions | Add `onClick` or tap fallback |
| No touch feedback | Add `:active` state for tap feedback |
| Carousel too small | Make swipe targets large enough for thumb reach |

#### Input & Forms

| Issue | Fix |
|---|---|
| Tiny input fields | Set `font-size: 16px` on mobile (prevents iOS zoom on focus) |
| Cramped radio/checkbox | Increase touch area beyond visible element |
| Date picker too small | Use native `<input type=date>` on mobile |

#### Viewport

| Issue | Fix |
|---|---|
| `100vh` on mobile | Add `100dvh` fallback (dynamic viewport height) |
| Missing `viewport` meta | Ensure `<meta name="viewport" content="width=device-width, initial-scale=1">` |
| Element hidden on mobile without reason | Verify `hidden` / `display: none` was intentional |

### 3. Output Format

```
/adapt the dashboard layout

Fix 1: Mobile overflow
  - Before: <div class="grid grid-cols-3"> on mobile
  - After: grid-cols-1 below 768px, grid-cols-3 above

Fix 2: Touch target on filter dropdown
  - Before: height 32px (too small)
  - After: min-height 44px

Fix 3: 100vh on mobile
  - Before: height: 100vh (address bar overlap)
  - After: height: 100dvh
```

### 4. Escalation Rules

| Finding | Escalate to |
|---|---|
| Needs complete mobile layout rethink | `redesign` or `build` |
| Touch gesture complexity | `delight` for interaction design |
| Responsive images | `optimize` for image loading strategy |
| Animation on scroll | `delight` for scroll-driven animations |

## Pitfalls

- **Only checking one breakpoint** — Test at least small mobile, tablet, desktop.
- **Fixing with magic numbers** — Every breakpoint should match the design system or content needs.
- **Ignoring landscape** — Mobile landscape is a real viewport. Check it.
- **Breaking hover-only actions** — On touch devices, there is no hover. Always provide tap fallback.

## QA Gates

- [ ] No horizontal scroll at 360px width
- [ ] Touch targets ≥ 44px / 48dp on mobile
- [ ] `100vh` replaced with `100dvh` where needed
- [ ] Forms have `font-size: 16px` on mobile
- [ ] No hover-only interaction without tap fallback
- [ ] Mobile layout does not replicate desktop columns
- [ ] Viewport meta tag present
- [ ] Tablet layout works (768px-1024px)
- [ ] Line-length ≤ 80ch on wide screens

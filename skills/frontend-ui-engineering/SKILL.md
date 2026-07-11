---
name: frontend-ui-engineering
description: "Build production-quality UIs with component architecture, state management, and layout discipline. Use across web, mobile, desktop, or PWA. Do NOT use for platform-specific implementation."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  stack: any
  workflow: design-build
  foundation: engineering-fundamentals
---

# Frontend UI Engineering

**Universal UI principles that apply across web, mobile, desktop, and PWA.**

This is a **foundation skill** referenced by platform-specific skills (frontend-web, frontend-mobile, frontend-desktop, frontend-pwa). It covers UI principles that transcend platform boundaries.

> **Sources:** React.dev (react.dev/learn) — component composition, props patterns, conditional rendering, thinking in React hierarchy. web.dev (Google) — WCAG color contrast (4.5:1 normal, 3:1 large text), focus-visible keyboard navigation, ARIA accessibility patterns.

## When to Use

- Building any user-facing component
- Designing component architecture or state management
- Implementing layouts, navigation, or responsive patterns
- Referenced automatically by platform skills

## When NOT to Use

- Platform-specific work (use the dedicated platform skill)
- API or backend work (use backend-api-mastery)

## Output Contract

No standalone artifact. UI architecture patterns and accessibility rules realized through platform-specific skills (frontend-web, frontend-mobile, frontend-desktop, frontend-pwa).

## Relationship to Platform Skills

```
frontend-ui-engineering (this skill — universal UI principles)
├── frontend-web (web-specific)
├── frontend-mobile (native mobile)
├── frontend-desktop (desktop)
└── frontend-pwa (progressive web)
```

## Component Architecture

Components are the building blocks of every UI. Design them with clear contracts (props interface), composition over inheritance (children, slots), and single responsibility.

**Key patterns:**
- **Composition** — nest components via `children` or slot props. Avoid deep prop drilling.
- **Props interface** — every component has a typed props contract. Required props are explicit, optional props have sensible defaults.
- **Container vs presentational** — separate data fetching (container) from rendering (presentational). Presentational components are reusable across projects.
- **Conditional rendering** — show/hide UI based on state. Use ternary expressions for binary states, early returns for guard clauses.

See `guides/COMPONENT-ARCHITECTURE.md` for detailed patterns and examples.

## State Management

State is data that changes over time. Choose the right scope for each piece of state:

| Scope | When to Use | Example |
|---|---|---|
| Local (component) | Only this component needs it | Form input value |
| Lifted (parent) | Parent and children share it | Selected item in a list |
| Context (subtree) | Deep descendants need it | Theme, user preferences |
| External store | Many unrelated components need it | Cached API data |

**Rules:**
- Start with local state, lift only when needed
- Context is not a state management solution — it avoids prop drilling, but doesn't manage mutations
- External stores (Redux, Zustand, Jotai) are for global state, not for everything

See `guides/STATE-MANAGEMENT.md` for migration patterns between state scopes.

## Layout Discipline

Layout is the structure that holds components. Use the right tool for the job:

| Pattern | Purpose | When |
|---|---|---|
| Grid | 2D layout (rows + columns) | Page-level structure |
| Flexbox | 1D layout (row OR column) | Component-level alignment |
| Spacing tokens | Consistent gaps between elements | Every layout |
| Responsive breakpoints | Adapt layout to viewport | Mobile, tablet, desktop |

**Responsive rules:**
- Design mobile-first (smallest screen first)
- Use relative units (rem, %) not fixed pixels for layout
- Test at breakpoints: 375px, 768px, 1024px, 1440px

## Accessibility

Accessibility is not optional. Every UI must meet WCAG AA as a minimum:

- **Color contrast:** 4.5:1 for normal text, 3:1 for large text (≥18pt/24px)
- **Focus indicators:** visible on keyboard navigation (`:focus-visible`), never removed
- **ARIA:** use native HTML semantics first, ARIA only when semantics don't exist
- **Tab order:** follows visual order, no unexpected jumps
- **Reduced motion:** respect `prefers-reduced-motion`, provide static alternatives

## Anti-Patterns

1. Prop drilling — passing data through 5+ component layers without context or composition.
2. God component — a single component that handles data fetching, state, layout, and rendering.
3. Over-engineering state — Redux for a toggle button.
4. No responsive design — a desktop-only layout that breaks on mobile.
5. Removing focus outlines — `outline: none` without providing an alternative.
6. Inline styles instead of design tokens — hardcoded colors and spacing everywhere.

## Verification

- [ ] Component props have clear interfaces (typed, documented)
- [ ] State scope chosen correctly (local → lifted → context → external)
- [ ] Layout uses appropriate pattern (grid, flexbox, spacing tokens)
- [ ] Responsive breakpoints tested at 375px, 768px, 1024px
- [ ] Color contrast meets WCAG AA (4.5:1 normal, 3:1 large)
- [ ] Focus indicators visible on keyboard navigation
- [ ] `prefers-reduced-motion` respected for animations

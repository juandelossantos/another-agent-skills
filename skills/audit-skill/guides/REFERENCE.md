# Audit Reference Guide

**Quick-lookup tables for audit thresholds and budgets.**

## Accessibility Thresholds

| Check | Pass | Warn | Fail |
|---|---|---|---|
| Text contrast (normal) | ≥ 4.5:1 | 3:1 – 4.49:1 | < 3:1 |
| Text contrast (large) | ≥ 3:1 | 2.5:1 – 2.99:1 | < 2.5:1 |
| Touch target | ≥ 48px | 44px – 47px | < 44px |
| Focus indicator | ≥ 2px outline, contrast ≥ 3:1 | Visible but thin | None |
| Keyboard nav | All reachable | Most reachable | Trap or unreachable |

### ARIA Patterns Quick Reference

| Component | Role | Key Attribute |
|---|---|---|
| Button | `button` (implicit on `<button>`) | `aria-label` if no visible text |
| Navigation | `navigation` (implicit on `<nav>`) | `aria-label="Main"` if multiple navs |
| Dialog | `dialog` | `aria-modal="true"`, `aria-labelledby` |
| Tab panel | `tablist`, `tab`, `tabpanel` | `aria-selected`, `aria-controls`, `aria-labelledby` |
| Alert | `alert` | `aria-live="assertive"` or implicit on `role="alert"` |
| Combobox | `combobox` | `aria-expanded`, `aria-controls`, `aria-activedescendant` |
| Progress | `progressbar` | `aria-valuenow`, `aria-valuemin`, `aria-valuemax` |

## Performance Budgets

| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| LCP | < 2500ms | 2500ms – 4000ms | > 4000ms |
| FID | < 100ms | 100ms – 300ms | > 300ms |
| TBT | < 200ms | 200ms – 600ms | > 600ms |
| CLS | < 0.1 | 0.1 – 0.25 | > 0.25 |
| JS bundle (critical) | < 300KB | 300KB – 500KB | > 500KB |
| Image weight per page | < 500KB | 500KB – 1MB | > 1MB |
| Time to Interactive | < 3.5s | 3.5s – 5s | > 5s |

### How to measure

```bash
# Lighthouse CI
npx lighthouse https://example.com --view

# Web Vitals in browser
new PerformanceObserver((list) => { /* see AUDIT-PROTOCOL.md */ })

# Bundle analysis
npx source-map-explorer build/static/js/*.js
```

## Theming — Hardcoded Color Patterns

| Pattern | Likely Means | Should Be |
|---|---|---|
| `#3B82F6` | Tailwind blue-500 | Token: `--color-primary` |
| `#EF4444` | Tailwind red-500 | Token: `--color-danger` |
| `#10B981` | Tailwind emerald-500 | Token: `--color-success` |
| `#F59E0B` | Tailwind amber-500 | Token: `--color-warning` |
| `#6B7280` | Tailwind gray-500 | Token: `--color-muted` or `--color-text-secondary` |
| `#F9FAFB` | Tailwind gray-50 | Token: `--color-bg-subtle` |
| `#111827` | Tailwind gray-900 | Token: `--color-text-primary` |

## Responsive Breakpoints (Common)

| Label | Width | Typical device |
|---|---|---|
| Small mobile | 360px | iPhone SE, Galaxy S |
| Large mobile | 390px – 428px | iPhone 15 Pro, Pixel 8 |
| Tablet | 768px – 834px | iPad mini, iPad Air |
| Desktop | 1024px – 1440px | Laptops, external monitors |
| Wide | 1440px+ | Ultrawide, 4K |

### Touch Targets by Platform

| Platform | Minimum | Recommended |
|---|---|---|
| iOS (HIG) | 44pt | 48pt |
| Android (Material) | 48dp | 48dp |
| Web (WCAG) | 44px | 48px |
| Desktop | 32px | 40px |

## Anti-Pattern Severity

| Anti-pattern | Default severity | Detected by |
|---|---|---|
| Missing form labels | P0 | Tab through form |
| Zero contrast text | P0 | Contrast check |
| Layout broken at 360px | P0 | Resize browser |
| Hardcoded colors | P1 | Grep scan |
| Missing dark mode | P1 | Toggle OS theme |
| Touch target < 44px | P1 | querySelector check |
| Ambiguous button copy | P2 | Visual scan |
| No loading state | P1 | Slow network simulation |
| Missing focus indicator | P1 | Tab through page |
| Three equal feature cards | P2 | Visual scan |

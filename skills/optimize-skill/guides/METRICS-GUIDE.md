# Optimize Skill — Performance Budgets

## Core Web Vitals

| Metric | Target | Poor |
|---|---|---|
| LCP (Largest Contentful Paint) | <2.5s | >4.0s |
| FID (First Input Delay) / INP | <100ms / <200ms | >300ms |
| CLS (Cumulative Layout Shift) | <0.1 | >0.25 |

## Bundle Budgets

| Resource | Target | Warning |
|---|---|---|
| Critical path JS | <500KB | >500KB |
| Total JS (route) | <300KB | >500KB |
| Total CSS | <100KB | >200KB |
| Fonts | <50KB | >100KB |
| Images (per page) | <1MB | >3MB |

## Process

1. **Measure** — Lighthouse, DevTools, or real-user monitoring
2. **Identify** — Which metric is failing and what causes it
3. **Fix** — Apply the specific fix for the specific bottleneck
4. **Verify** — Re-measure to confirm improvement
5. **Guard** — Add performance budget to CI/CD

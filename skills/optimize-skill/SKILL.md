---
name: optimize-skill
description: "Fix performance issues: bundle size, animations, reflows, lazy loading, image optimization, render blocking. Use after profiling reveals bottlenecks. Do NOT use for cosmetic changes."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-engineers
  stack: any
  workflow: audit-optimize
---

# Optimize Skill

**Fix performance issues so applications load fast and animate smoothly.**

Performance fixes are deterministic. Profile first, then apply the specific fix for the specific bottleneck.

## When to Use

- After profiling reveals a specific bottleneck
- User says "this page is slow"
- Lighthouse / PageSpeed score is below target
- User says "animations jank" or "scrolling stutters"
- Bundle size exceeds budget (500KB critical path JS)
- Images are loading at full resolution on mobile

## When NOT to Use

- Speculative optimization (measure first)
- Design changes that happen to improve performance
- Pre-optimization during initial build (build clean first, optimize later)

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Performance fixes | HTML/CSS/JS code changes | Source files | Profile-validated, Lighthouse ≥90, critical JS <500KB |

## Process

### 1. Profile

Identify the bottleneck before fixing:

| Symptom | Likely cause |
|---|---|
| Slow first load | Large bundle, render-blocking resources, unoptimized images |
| Slow after load | Missing lazy load, too many fonts, too much JS |
| Janky animation | Animating `width`/`height`/`top`/`left`, missing `will-change` |
| Janky scroll | Layout thrashing, expensive handlers on scroll/resize |
| Slow interaction | Long tasks, heavy computation on main thread |

### 2. Fix by Category

#### Bundle Size

| Issue | Fix |
|---|---|
| No code splitting | Add dynamic imports for route-level chunks |
| Large dependency | Replace with smaller alternative or tree-shake |
| Duplicate polyfills | Deduplicate, use core-js selectively |
| Unused CSS | Remove dead styles, use purge (Tailwind JIT) |
| Heavy library only used once | Inline the small part, remove the import |

#### Images

| Issue | Fix |
|---|---|
| Full-res images on mobile | Serve responsive sizes via `srcset` |
| No lazy loading | Add `loading="lazy"` to below-fold images |
| Giant hero image | Compress to WebP/AVIF, limit to viewport width |
| Missing dimensions | Add `width` and `height` to prevent CLS |
| Icon as image file | Inline SVG or icon sprite |

#### Animation

| Issue | Fix |
|---|---|
| Animating `width` | Switch to `transform: scaleX()` |
| Animating `top`/`left` | Switch to `transform: translate()` |
| No `will-change` | Add `will-change: transform, opacity` on animated elements |
| Expensive filter | Prefer `box-shadow` or separate overlay element |
| JS animation | Switch to CSS animation or Web Animations API |

#### Rendering

| Issue | Fix |
|---|---|
| Layout thrashing | Batch DOM reads before writes, use `requestAnimationFrame` |
| Expensive scroll handler | Debounce or use `IntersectionObserver` |
| Long task > 50ms | Defer with `requestIdleCallback` or split into microtasks |
| Reflow on scroll | Avoid reading `offsetTop`, `scrollTop` in scroll handlers |

### 3. Output Format

```
/optimize the product listing page

Fix 1: Lazy load images
  - Before: <img src="...">
  - After: <img loading="lazy" src="...">

Fix 2: Code-split review form
  - Before: import ReviewForm from './ReviewForm' (eager)
  - After: const ReviewForm = lazy(() => import('./ReviewForm'))

Fix 3: Reduce hero image
  - Before: 2400x1600 JPEG (1.2MB)
  - After: 1200x800 WebP (180KB) via <picture> + srcset

Fix 4: Animation jank on hover card
  - Before: transition: width 200ms, height 200ms
  - After: transition: transform 200ms; transform: scale(1.05)
```

### 4. Escalation Rules

| Finding | Escalate to |
|---|---|
| Need new component structure for performance | `redesign` or `build` |
| Image CDN or format not available | Infra decision |
| Third-party script blocking | Negotiate alternative with team |

→ See `guides/BOTTLENECK-GUIDE.md` for common bottlenecks and fixes.
→ See `guides/METRICS-GUIDE.md` for performance budgets and measurement.

## Pitfalls

- **Optimizing before profiling** — Measuring is not optional. The bottleneck is never where you guess.
- **Premature code splitting** — Splitting every import adds network overhead. Split routes, not components.
- **Image over-optimization** — Aggressive compression creates artifacts. Balance size vs quality.
- **Ignoring mobile network** — 3G is real. Test on slow networks.

## QA Gates

- [ ] Profiling data exists (not speculative fixes)
- [ ] Images are lazy-loaded below fold
- [ ] Images use responsive sizes (`srcset`)
- [ ] Animations use `transform` and `opacity` only
- [ ] No layout thrashing in scroll/resize handlers
- [ ] Route-level code splitting in place
- [ ] Critical JS bundle < 500KB
- [ ] Lighthouse performance score ≥ 90 (or improvement confirmed)

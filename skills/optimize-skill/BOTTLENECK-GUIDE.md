# Optimize Skill — Bottleneck Guide

## Common Bottlenecks

| Bottleneck | Symptom | Fix |
|---|---|---|
| Large bundle | Slow first load | Code-split by route, tree-shake, dynamic imports |
| Expensive re-renders | UI jank on state change | Memoize, virtualize lists, reduce state updates |
| Layout thrashing | Stuttering animations | Use `transform` and `opacity` only, avoid `top/left/width/height` |
| Unoptimized images | LCP >2.5s | WebP/AVIF, srcset, lazy load below fold, responsive sizes |
| Render-blocking CSS/JS | Slow FCP | Inline critical CSS, defer non-critical JS, preload fonts |
| Font loading | Flash of invisible text (FOIT) | `font-display: swap`, preload, subset fonts |
| Memory leaks | Slows over time | Cleanup event listeners, clear intervals, weak refs |

## Measurement Tools

- **Lighthouse** — First pass: LCP, FID, CLS, bundle size
- **Chrome DevTools Performance** — Frame timing, layout thrashing, long tasks
- **Chrome DevTools Coverage** — Unused CSS/JS
- **Bundle analyzer** — Webpack/Vite bundle composition
- **Network tab** — Waterfall, render blocking, cache status

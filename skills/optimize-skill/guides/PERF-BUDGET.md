# Optimize — Performance Budget Guide

**Set a budget, measure, ship. Repeat.**

## The Budget Table

| Resource | Budget | Who sets | How to measure |
|---|---|---|---|
| **LCP** | < 2.5s | Lighthouse / CrUX | `PerformanceObserver` for `largest-contentful-paint` |
| **TBT** | < 200ms | Lighthouse | Lighthouse lab data |
| **CLS** | < 0.1 | Lighthouse / CrUX | `PerformanceObserver` for `layout-shift` |
| **FID** | < 100ms | CrUX (RUM) | `PerformanceObserver` for `first-input` |
| **INP** | < 200ms | CrUX | `PerformanceObserver` for `event` + `duration` |
| **JS bundle (critical)** | < 300KB gzip | Build tool | `source-map-explorer` or `webpack-bundle-analyzer` |
| **CSS bundle** | < 50KB gzip | Build tool | Bundle analyzer |
| **Images per page** | < 500KB total | Manual audit | DevTools Network tab |
| **Web fonts** | < 100KB total | Manual audit | Self-hosted, subset, woff2 |
| **Total page weight** | < 1MB | Manual audit | DevTools Network tab |
| **Time to Interactive** | < 3.5s | Lighthouse | Lighthouse |

## Critical Path Checklist

Every page should have:

- [ ] **Critical CSS inlined** — Above-the-fold styles in `<head>`. Under 14KB (one TCP round-trip).
- [ ] **Non-critical CSS deferred** — `media="print"` swap trick or `rel="preload"` + `onload`
- [ ] **Fonts self-hosted** — No Google Fonts request in critical path. Subset to Latin if possible.
- [ ] **Fonts `font-display: swap`** — Text visible in fallback font immediately, no FOIT.
- [ ] **Above-the-fold images loaded** — `<img>` with `fetchpriority="high"` on hero image.
- [ ] **Below-the-fold images lazy** — `loading="lazy"` on all images below 1000px from top.
- [ ] **Preconnect to origins** — `<link rel="preconnect" href="https://api.example.com">` for API calls.
- [ ] **Preload hero image** — `<link rel="preload" as="image" href="hero.webp">`.

## Common Wins (Ordered by Impact)

| Win | Impact | Effort | When |
|---|---|---|---|
| Remove unused JS | Very high | Low | Prune dead code, dynamic imports |
| Optimize images (webp/avif, resize) | Very high | Low | Use `<picture>` with avif source |
| Lazy-load below-fold images | High | Low | Add `loading="lazy"` |
| Inline critical CSS | High | Medium | Use build tool plugin |
| Code-split routes | High | Medium | Dynamic `import()` per route |
| Tree-shake icons | Medium | Low | Import only used icons |
| Preload hero image | Medium | Low | One `<link>` tag |
| Preconnect to API origins | Medium | Low | One `<link>` tag |
| Debounce search inputs | Medium | Low | 300ms debounce |
| Compress JSON responses | Medium | Low | Enable gzip/brotli on server |
| Reduce web font weight | Medium | Medium | Use variable fonts or subset |
| Remove unused CSS | Medium | Low | PurgeCSS in build |
| Avoid layout shifts | Medium | Medium | Explicit image dimensions, font swap |
| Move third-party scripts | Low | Medium | Load after interactive (`requestIdleCallback`) |

## Measurement Script

```js
// Bookmarklet — paste into console on any page:
const metrics = {};

new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'largest-contentful-paint') {
      metrics.LCP = entry.startTime;
    }
    if (entry.entryType === 'layout-shift' && !entry.hadRecentInput) {
      metrics.CLS = (metrics.CLS || 0) + entry.value;
    }
  }
}).observe({type: 'largest-contentful-paint', buffered: true});
PerformanceObserver && new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'layout-shift') metrics.CLS = (metrics.CLS || 0) + entry.value;
  }
}).observe({type: 'layout-shift', buffered: true});

setTimeout(() => {
  console.table(metrics);
  if (metrics.LCP < 2500) console.log('✓ LCP good');
  if ((metrics.CLS || 0) < 0.1) console.log('✓ CLS good');
}, 5000);
```

## Web Vitals CLI

```bash
# Using Lighthouse CI
npx lighthouse https://yoursite.com --view --preset=desktop
npx lighthouse https://yoursite.com --view --preset=perf

# Using PSI (PageSpeed Insights)
npx psi https://yoursite.com --strategy=mobile

# Bundle analysis
npx vite-bundle-analyzer   # Vite
npx source-map-explorer build/**/*.js  # Webpack / CRA
```

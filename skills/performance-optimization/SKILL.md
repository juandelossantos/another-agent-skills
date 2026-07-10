---
name: performance-optimization
description: "Optimize application performance beyond the frontend: Core Web Vitals, load times, server response, database queries, caching, profiling. Do NOT use for frontend-only bundle optimization."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-engineers
  workflow: profile-optimize
---

# Performance Optimization

**Measure first, optimize only what matters.**

Complementary to `optimize-skill`. Where optimize-skill focuses on frontend design performance (bundle size, animation compositing, layout thrashing), performance-optimization covers the broader system: Core Web Vitals, server response times, database queries, caching strategy, and profiling methodology.

## When to Use

- Performance budgets are being exceeded
- Core Web Vitals need improvement
- Load times or Time-to-Interactive are too slow
- Profiling reveals backend or infrastructure bottlenecks
- After a major dependency upgrade or framework migration (regression risk)
- Preparing for a traffic event (launch, sale, campaign)

## Output Contract

Optimized system code — modified source files (any stack), in-place, with profiled baseline captured, single bottleneck identified and fixed per cycle, re-measured improvement confirmed, no regression on other metrics, caching strategy documented and applied.

## When NOT to Use

- Frontend design performance (use optimize-skill)
- Premature optimization without measurements

## Profiling Workflow

### Phase 1: Measure — Capture Baseline

Run profiling tools before any change. Record every metric so you can compare after optimization.

| Layer | What to Measure | How (use whatever your stack has) |
|---|---|---|
| Frontend | LCP, TBT, CLS, TTFB | Browser DevTools Performance tab, Lighthouse, or your RUM provider |
| Server | p50/p99 latency, req/s, error rate | Your load testing tool or APM provider |
| Database | Query time, rows examined, sequential scans | `EXPLAIN ANALYZE` (built into all SQL databases) |
| Caching | Cache hit ratio, TTL adherence | `curl -I` or your CDN/cache provider analytics |

### Phase 2: Identify — Find the Bottleneck

Compare each metric against the target. The largest gap is your priority.

| Metric | Green (Good) | Yellow (Needs Improvement) | Red (Poor) |
|---|---|---|---|---|
| LCP (Largest Contentful Paint) | ≤ 2500ms | 2500ms–4000ms | > 4000ms |
| INP (Interaction to Next Paint) | ≤ 200ms | 200ms–500ms | > 500ms |
| CLS (Cumulative Layout Shift) | ≤ 0.1 | 0.1–0.25 | > 0.25 |
| TBT (Total Blocking Time) | ≤ 200ms | 200ms–500ms | > 500ms |
| TTFB (Time to First Byte) | ≤ 800ms | 800ms–1800ms | > 1800ms |
| Server p99 latency | ≤ 200ms | 200ms–1s | > 1s |
| Database query time | ≤ 10ms | 10ms–100ms | > 100ms |

> All Core Web Vitals thresholds measured at the **75th percentile** per web.dev guidelines.

### Phase 3: Optimize — Apply Targeted Fix

**Frontend:** Compress images, defer non-critical JS, preload key resources. See `optimize-skill` for detailed frontend patterns.

**Server:** Enable compression (gzip/brotli), add keep-alive, upgrade to HTTP/2, tune worker processes.

**Database:** Add missing indexes, fix N+1 queries, optimize slow queries with `EXPLAIN ANALYZE`, add query caching.

**Caching:** Apply the appropriate cache layer from the decision tree in `guides/CACHING-STRATEGIES.md`.

### Phase 4: Verify — Re-measure and Compare

Run the same tools from Phase 1. Compare before/after. If the gap is closed, done. If not, return to Phase 2.

## Caching Decision Tree

See `guides/CACHING-STRATEGIES.md` for a complete decision matrix covering browser cache, CDN, application cache, and database cache with TTL guidance and invalidation strategies.

## Profiling Protocol

See `guides/PROFILING-WORKFLOW.md` for detailed step-by-step profiling instructions including tool installation, baseline capture templates, and result interpretation.

## Anti-Patterns

1. **Premature optimization** — Fixing performance without measurements. Always profile first.
2. **Single-layer focus** — Only optimizing the frontend while the bottleneck is the database.
3. **Cache-everything** — Caching without invalidation strategy creates stale data.
4. **N+1 ignorance** — Adding indexes without fixing query patterns in code.
5. **One-shot optimization** — Optimizing once without verifying the result.

## Verification

- [ ] Baseline captured with specific metric values, not vague observations
- [ ] Single bottleneck identified before any fix is applied
- [ ] Fix targets the specific metric that exceeds the threshold
- [ ] Re-measurement confirms improvement (same tool, same conditions)
- [ ] Regression check: other metrics did not degrade
- [ ] `guides/PROFILING-WORKFLOW.md` consulted for tool-specific steps
- [ ] `guides/CACHING-STRATEGIES.md` consulted for caching decisions

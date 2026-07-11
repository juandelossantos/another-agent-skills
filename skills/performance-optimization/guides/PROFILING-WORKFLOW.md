# Profiling Workflow

> **Sources:** Core Web Vitals thresholds from web.dev (Google, 2026). Performance profiling methodology adapted from the universal "measure → identify → optimize → verify" cycle. The project is stack-agnostic — use the profiling tools available in your stack, not prescribed ones.

## The Universal Measurement Cycle

Performance optimization follows four phases regardless of stack or tooling:

```
MEASURE → IDENTIFY → OPTIMIZE → VERIFY
```

Each phase has a specific output. Do not skip phases.

## Phase 1: Measure — Capture Baseline

### What to Measure

| Layer | What to Measure | Why |
|---|---|---|
| Frontend | LCP, FID/TBT, CLS, TTFB | User-perceived loading, interactivity, stability |
| Server | Latency (p50/p99), throughput (req/s), error rate | Capacity and responsiveness |
| Database | Query execution time, rows examined, sequential scans | Data access efficiency |
| Caching | Hit ratio, TTL adherence, stale served | Effectiveness of cache strategy |

### How to Measure (Stack-Specific)

Use whatever tooling your project already has or your team already uses:

- **Browser DevTools** (Performance tab, Network tab, Lighthouse) — works in any browser, no install needed
- **Built-in framework tools** (Next.js Analytics, Django Debug Toolbar, Rails Mini Profiler)
- **Your monitoring provider** (Datadog, New Relic, Grafana, Sentry) — if you already have observability, use it
- **CLI tools if needed** — load testers like `hey`, `wrk`, `autocannon`, or `ab` (Apache Bench); database profilers like `EXPLAIN ANALYZE` are built into SQL databases

The right tool is the one you already have installed and know how to interpret. If you have none, browser DevTools + `EXPLAIN ANALYZE` covers 80% of cases.

### Baseline Template

| Date | Layer | Metric | Current Value | Target | Tool Used |
|---|---|---|---|---|---|
| YYYY-MM-DD | Frontend | LCP | 4.2s | ≤ 2500ms | Chrome DevTools |
| YYYY-MM-DD | Server | p99 latency | 1.2s | ≤ 200ms | Load tester |
| YYYY-MM-DD | Database | query time | 450ms | ≤ 10ms | EXPLAIN ANALYZE |

Record this table before any optimization. Without a baseline, you cannot measure improvement.

## Phase 2: Identify — Find the Bottleneck

Compare each metric against the Core Web Vitals thresholds (see SKILL.md table). The metric with the largest gap is your highest-priority bottleneck.

### Diagnostic Heuristics

**Frontend:**
- **LCP > 2500ms**: Slowest-largest-element problem. Common causes: large images, slow server response, render-blocking resources.
- **INP > 200ms**: Interaction latency. Common causes: long tasks (>50ms), heavy JavaScript, third-party scripts blocking main thread.
- **CLS > 0.1**: Layout instability. Common causes: images without dimensions, late-loading ads or embeds, dynamic content injection.
- **TTFB > 800ms**: Server delay. Common causes: cold starts, slow database queries, CDN miss.

**Server:**
- **p99 >> p50**: Latency variance. Suggests garbage collection pauses, connection pool exhaustion, or intermittent slow queries.
- **Error rate > 1%**: Application errors or timeouts. Check logs for upstream dependency failures.
- **Throughput flat under load**: Server saturated. Check CPU, memory, connection limits.

**Database:**
- **Seq Scan on large table**: Missing index. Check query `WHERE` clauses against existing indexes.
- **Rows examined >> rows returned**: Low selectivity. Index choice or query structure needs review.
- **N+1**: ORM loading related entities in a loop. Enable eager loading or batch queries.

## Phase 3: Optimize — Apply Targeted Fix

See SKILL.md for per-layer optimization strategies.

## Phase 4: Verify — Re-measure and Compare

Run the same measurement tools from Phase 1 under the same conditions. Compare every metric. The optimization is effective only when the specific metric crosses from red/yellow into green.

If the metric did not improve, return to Phase 2. If it improved but another metric degraded, you have a trade-off to document.

## References

- Core Web Vitals thresholds: web.dev/vitals (Google, 2026) — defines LCP ≤2500ms, INP ≤200ms, CLS ≤0.1 at 75th percentile
- Lighthouse performance scoring: web.dev/performance-scoring (Google, 2026)
- METR study on developer productivity: Becker et al., arXiv:2507.09089 (2025) — "measure before optimizing" is a direct application of their finding that developers overestimate their speed

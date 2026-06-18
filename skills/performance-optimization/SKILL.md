---
name: performance-optimization
description: >
  Optimize application performance beyond the frontend. Covers Core Web Vitals,
  load times, server response, database queries, caching, and profiling.
  Complements optimize-skill: optimize-skill handles frontend design performance
  (bundle, animations, reflows); this covers system/infrastructure performance.
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

## When NOT to Use

- Frontend design performance (use optimize-skill)
- Premature optimization without measurements

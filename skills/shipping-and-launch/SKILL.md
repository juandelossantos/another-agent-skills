---
name: shipping-and-launch
description: Prepares production launches. Use when preparing to deploy to production. Use when you need a pre-launch checklist, when setting up monitoring, when planning a staged rollout, or when you need a rollback strategy.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: ship
---

# Shipping and Launch

Ship with confidence. Deploy safely: monitoring in place, rollback plan ready, clear success criteria. Every launch should be reversible, observable, and incremental.

## When to Use

- Deploying a feature to production for the first time
- Releasing a significant change to users
- Migrating data or infrastructure
- Any deployment that carries risk (all of them)

## Pre-Launch Checklist

### Code Quality
- [ ] All tests pass (unit, integration, e2e)
- [ ] Build succeeds with no warnings
- [ ] Lint and type checking pass
- [ ] Code reviewed and approved
- [ ] Error handling covers expected failure modes

### Security
- [ ] No secrets in code or version control
- [ ] Input validation on all user-facing endpoints
- [ ] Auth and authorization checks in place
- [ ] Security headers configured (CSP, HSTS, etc.)
- [ ] CORS configured to specific origins (not wildcard)

### Performance
- [ ] Core Web Vitals within "Good" thresholds
- [ ] No N+1 queries in critical paths
- [ ] Bundle size within budget
- [ ] Caching configured for static assets

### Infrastructure
- [ ] Environment variables set in production
- [ ] Database migrations applied
- [ ] Logging and error reporting configured
- [ ] Health check endpoint exists and responds

## Feature Flags

Ship behind feature flags to decouple deployment from release:

```
1. DEPLOY with flag OFF     → Code in production but inactive
2. ENABLE for team/beta     → Internal testing in production
3. GRADUAL ROLLOUT          → 5% → 25% → 50% → 100%
4. MONITOR at each stage    → Watch error rates, performance
5. CLEAN UP                 → Remove flag after full rollout
```

**Rules:** Every flag has an owner and expiration. Don't nest flags. Test both states in CI.

## Staged Rollout

```
1. DEPLOY to staging → full test suite + manual smoke test
2. DEPLOY to production (flag OFF) → verify health check
3. ENABLE for team → 24-hour monitoring window
4. CANARY (5%) → compare metrics vs baseline, 24-48h
5. GRADUAL (25% → 50% → 100%) → same monitoring each step
6. FULL rollout → monitor 1 week → clean up flag
```

### Rollout Thresholds

| Metric | Advance | Hold | Roll back |
|--------|---------|------|-----------|
| Error rate | Within 10% of baseline | 10-100% above | >2x baseline |
| P95 latency | Within 20% of baseline | 20-50% above | >50% above |
| Client JS errors | No new types | New at <0.1% sessions | New at >0.1% sessions |

### When to Roll Back

Roll back immediately if: error rate >2x baseline, P95 latency >50% increase, user-reported spikes, data integrity issues, or security vulnerability discovered.

## Monitoring

```
Application: error rate, response time (p50/p95/p99), request volume, active users
Infrastructure: CPU/memory, DB connection pool, disk, network latency
Client: Core Web Vitals (LCP, INP, CLS), JS errors, API error rates
```

## Post-Launch Verification (First Hour)

1. Health endpoint returns 200
2. Error monitoring: no new error types
3. Latency dashboard: no regression
4. Critical user flow works manually
5. Logs flowing and readable
6. Rollback mechanism ready

## Rollback Plan

Every deployment needs one before it happens:

- **Trigger:** Error rate >2x, P95 >[X]ms, user reports, data issues
- **Steps:** Disable flag OR `git revert <commit> && git push` → verify → notify team
- **Timing:** Flag <1min, redeploy <5min, DB rollback <15min

## TOOL_GAP: When You Can't Verify Deployment

Inspired by Sub-Zero Skill. After deployment, verification requires real-world access:

| Verdict | Meaning | Action |
|---|---|---|
| ✅ PASS | Health check 200, metrics normal | Proceed to next stage |
| ❌ FAIL | Health check fails, errors spike | Roll back per plan |
| ⚠️ TOOL_GAP | Can't reach production (no access, no network) | **STOP. Report "deploy status unknown." Never fake a win.** |

**Examples:**
- "Deploy succeeded" but can't reach health endpoint → TOOL_GAP
- "Metrics look good" but monitoring dashboard unavailable → TOOL_GAP
- "Users can access" but no real-user monitoring → TOOL_GAP

**Rule:** If you can't verify against the real world, say so. The absence of errors is not evidence of success.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It works in staging, it'll work in production" | Production has different data, traffic, edge cases. Monitor. |
| "We don't need feature flags" | Every feature benefits from a kill switch. |
| "Monitoring is overhead" | Not having it means discovering problems from user complaints. |
| "Rolling back is admitting failure" | Shipping broken features is the failure. |

## Red Flags

- Deploying without a rollback plan
- No monitoring or error reporting in production
- Big-bang releases (no staging, no canary)
- Feature flags with no expiration or owner
- "It's Friday afternoon, let's ship it"

## Verification

Before deploying:
- [ ] Pre-launch checklist completed
- [ ] Rollback plan documented
- [ ] Monitoring dashboards set up

After deploying:
- [ ] Health check returns 200
- [ ] Error rate is normal
- [ ] Critical user flow works
- [ ] TOOL_GAP check: can you actually verify the real world?

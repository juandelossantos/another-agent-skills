# Deployment & Monitoring Guide

This guide contains Phase 5 Deployment Orchestration and Phase 6 Monitoring for `fullstack-shipping`.

## Phase 5 — Deployment Orchestration

### 5A: Environment Strategy

| Strategy | Best For | Avoid When |
|---|---|---|
| **Preview per PR** | Teams doing PR reviews, design sign-off | Solo dev, cost-sensitive (build minutes) |
| **Staging + Production** | Most projects | Literally never — always have staging |
| **Production only** | Prototypes, internal tools, low-risk | User-facing products, e-commerce, regulated |

**Critical:** Never deploy to production without staging. Staging verifies migrations and breaking changes.

### 5B: Database Migrations

- **Always run migrations before code deploy** (backward-compatible)
- **Never run destructive migrations** (drop column, rename table) without multi-step plan
- **Have a rollback script** for every migration
- **Test migrations on staging** with production-like data volume

### 5C: Secrets Management

- **Never commit secrets.** Use env vars, Doppler, Vault, or platform secret management.
- **Different secrets per environment** (never reuse production DB URL in staging)
- **Rotate secrets** after team member departures or suspected leaks

### 5D: Rollback Strategy

| Method | Speed | Risk | Best For |
|---|---|---|---|
| **Instant platform rollback** (Vercel/Railway) | Seconds | Low | Platform-native deploys |
| **Git revert + redeploy** | Minutes | Low | Code issues, no DB changes |
| **Database migration rollback** | Minutes-Hours | High | Data migrations (test first!) |
| **Blue-green deployment** | Seconds | Medium | Enterprise, zero-downtime required |

**Rule:** If you can't rollback in under 5 minutes, you can't ship with confidence.

## Phase 6 — Monitoring & Alerting

**"Production" means "we don't know if it's working unless we watch it."**

### 6A: What to Monitor

| Category | Tool Examples | What to Track |
|---|---|---|
| **Errors** | Sentry, Rollbar, LogRocket | Uncaught exceptions, API 500s, failed builds |
| **Performance** | OpenTelemetry, Datadog, Vercel Analytics | LCP, FCP, TTFB, API response times |
| **Uptime** | UptimeRobot, Pingdom, Better Uptime | HTTP 200 checks every minute from multiple regions |
| **Business** | Custom dashboards | Signups, conversions, revenue — if it drops, something broke |

### 6B: Alerting Rules

- **Page/SMS:** Site down, payment failures, security incidents
- **Slack/Email:** Build failures, error rate spikes, performance degradation
- **Dashboard:** Daily review of trends, capacity planning

**Never alert on:** "CPU is high" without context. "CPU is high AND response times are degrading" is actionable.

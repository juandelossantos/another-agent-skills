---
name: fullstack-shipping
description: >
  End-to-end build, test, and deploy workflows with production-grade discipline.
  Covers CI/CD pipelines, testing strategy, deployment orchestration, monitoring,
  and launch checklists. Use when preparing to deploy, setting up CI/CD, or
  shipping any non-trivial project. Triggers on: "deploy", "ship", "launch",
  "CI/CD", "build pipeline", "testing strategy", "production", "release",
  "go live", "monitoring", "rollback", "staging".
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: engineers
  workflow: build-test-deploy-monitor
---

# Fullstack Shipping

**Shipping is not the end. Shipping is the beginning of responsibility.**

This skill turns "it works on my machine" into "it works in production, and we
know when it breaks." It forces the agent to think about the entire delivery
pipeline — not just the code — before any commit reaches production.

## When to Use

**MANDATORY** when:
- Preparing to deploy any project to production or staging
- Setting up CI/CD pipelines for the first time
- Adding testing infrastructure to an existing project
- Planning a release or launch
- Configuring monitoring, alerting, or rollback strategies
- The user says "go live", "ship it", "deploy to production"

**Triggered automatically by:**
- `frontend-web` or `frontend-mobile` Phase 7 (QA gates before delivery)
- `backend-api-mastery` Phase 7 (documentation & versioning before release)
- `spec-driven-development` Phase 8 (implement gate before deployment)

**When NOT to use:**
- Local development or prototyping without production intent
- Hotfixes where CI/CD is already established and the fix is trivial
- Documentation-only changes with no code impact

---

## Core Process

### Phase 0 — Context Assessment

1. **Check existing infrastructure:**
   - Does `DEPLOYMENT.md` or `SHIP.md` exist? Read it.
   - Does `.github/workflows/` or CI config exist? Analyze current setup.
   - Does `SPEC.md` have a Testing Strategy or Boundaries section?

2. **Determine shipping maturity:**
   - **Greenfield:** No CI/CD, no tests, no monitoring → Full setup required.
   - **Brownfield:** Some setup exists → Audit gaps, extend where needed.
   - **Established:** CI/CD exists → Verify, optimize, or add new checks.

3. **Check health status:**
   - Verify `HEALTH-CHECK.md` is recent. Critical issues must be resolved before shipping.

---

### Phase 1 — Shipping Discovery (MANDATORY)

**NO PIPELINE IS DESIGNED UNTIL THIS PHASE IS COMPLETE.**

**Assumptions:** Surface deploy target, team size, rollback strategy, monitoring.

**Discover (8 questions):** Environment (Vercel/AWS/etc), Stages (staging+prod?), Team size, Rollback plan, DB migrations, Domains/SSL, Monitoring needs, Compliance.

**Extended (non-trivial):** Traffic/load, Geography/CDN, Budget, Secrets management.

**Confirm:** "Is this correct? Shall we design the pipeline?" Only proceed after explicit yes.

---

### Phase 2 — Research (MANDATORY for greenfield)

**Research current best practices for [current year]. Never use outdated knowledge.**

1. **CI/CD platforms:**
   - "GitHub Actions vs GitLab CI vs CircleCI [current year]"
   - "Vercel CI vs Netlify CI [current year]"
   - "Self-hosted CI [current year] security"

2. **Testing in CI:**
   - "Vitest in GitHub Actions [current year]"
   - "Playwright E2E CI setup [current year]"
   - "Contract testing in CI [current year]"

3. **Deployment patterns:**
   - "Blue-green deployment [current year]"
   - "Canary releases [current year]"
   - "Database migrations zero-downtime [current year]"

4. **Monitoring:**
   - "OpenTelemetry vs vendor monitoring [current year]"
   - "Sentry vs Rollbar vs LogRocket [current year]"
   - "Uptime monitoring [current year] free tiers"

---

### Phase 3 — CI/CD Pipeline Design

**Generate 2-3 pipeline strategy options. Never default to GitHub Actions without justification.**

→ **See `CICD-GUIDE.md` for the full 3 options and critical challenges.**

---

### Phase 4 — Testing in Pipeline

| Trigger | Tests | Gate |
|---|---|---|
| Every PR | Lint, TypeCheck, Unit | Block merge on fail |
| Merge to `main` | Unit + Integration | Block deploy on fail |
| Push to staging | + E2E (smoke) | Manual approval for prod |
| Tag release | Full E2E + visual regression | Requires green staging |

Tests: Unit (Vitest), Integration (API+DB+auth), E2E (Playwright critical flows), Contract (Zod/OpenAPI), Visual (Chromatic/Playwright screenshots).

---

### Phase 5 — Deployment Orchestration

→ **Ver `DEPLOY-GUIDE.md` para estrategias de entorno, migraciones, secrets y rollback.**

---

### Phase 6 — Monitoring & Alerting

**"Production" means "we don't know if it's working unless we watch it."**

→ **Ver `DEPLOY-GUIDE.md` para categorías de monitoreo y reglas de alertas.**

---

### Phase 7 — Launch Checklist (MANDATORY)

**NO LAUNCH WITHOUT THIS CHECKLIST COMPLETE.**

→ **Ver `LAUNCH-CHECKLIST-GUIDE.md` para el checklist completo de Pre-Launch, Launch Day y Post-Launch.**

---

### Phase 8 — Lock & Document

**Create `DEPLOYMENT.md`** with: Pipeline overview (CI/CD flow), Environments table (preview/staging/prod with URL+branch+trigger), Testing stages, DB migrations, Secrets, Rollback procedure, Monitoring, Launch checklist.

---

## Examples

### Example 1: Solo Dev Landing Page

User: "Ship my landing page to production."

Agent:
1. Phase 1: Discover — Vercel, no staging needed (low risk), solo dev, no DB.
2. Phase 2: Research — Vercel deploy from Git is simplest.
3. Phase 3: Option A (Platform-native) — Connect GitHub repo to Vercel, auto-deploy `main`.
4. Phase 4: Tests in CI — Lint + build check on PR. Optional: Lighthouse CI.
5. Phase 5: Production only (no staging, low risk).
6. Phase 6: UptimeRobot free tier for monitoring.
7. Phase 7: Run launch checklist.
8. Phase 8: Create minimal `DEPLOYMENT.md`.

### Example 2: E-Commerce Platform

User: "We're launching our e-commerce platform next week."

Agent:
1. Phase 1: Discover — AWS, needs staging + production, team of 4, Stripe integration, PostgreSQL, rollback critical.
2. Phase 2: Research — "AWS ECS blue-green deployment [current year]", "Stripe webhook testing in CI [current year]".
3. Phase 3: Option C (Full control) — GitHub Actions → Docker → ECR → ECS with blue-green.
4. Phase 4: Full test matrix — unit, integration, Stripe webhook simulation, E2E purchase flow.
5. Phase 5: Staging mirrors production (same DB version, same secrets structure). Migrations tested on staging.
6. Phase 6: Sentry for errors, Datadog for metrics, PagerDuty for alerts.
7. Phase 7: Full launch checklist, 48-hour monitoring plan.
8. Phase 8: Create comprehensive `DEPLOYMENT.md` with runbooks.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll deploy manually, it's faster." | Manual deploys are not reproducible, not auditable, and prone to human error. |
| "We don't need staging, we'll test in production." | Testing in production is not testing — it's experimenting with users. Staging catches failures before they hurt revenue. |
| "CI/CD is overkill for a small project." | A 20-minute CI/CD setup prevents "why isn't this working in production?" debugging at 2 AM. |
| "I test locally, CI is redundant." | CI runs in a clean environment. Local tests depend on your machine's state. |
| "Monitoring is expensive, we'll add it later." | You can't fix what you can't see. Free tiers of Sentry + UptimeRobot catch 90% of issues. |
| "Rollback is just redeploying the previous commit." | If the previous commit has a database migration, redeploying code without rolling back the DB breaks everything. |
| "Launch checklists are bureaucracy." | Checklists prevent launches where the domain isn't configured or the database isn't migrated. |

---

## Red Flags

- The agent deploys to production without any CI/CD pipeline.
- The agent skips tests in the deployment process.
- The agent deploys database migrations without a rollback plan.
- The agent does not configure any monitoring or alerting.
- The agent suggests testing in production instead of staging.
- The agent commits secrets to the repository.
- The agent deploys during high-traffic hours without a reason.
- The agent does not document the deployment process.

---

## Verification

Before declaring "shipped", confirm:
- [ ] Phase 1: Discovery complete with 8+ questions answered.
- [ ] Phase 2: Research completed with current year sources.
- [ ] Phase 3: CI/CD strategy chosen with 2-3 options evaluated.
- [ ] Phase 4: Testing strategy defined for PR, merge, staging, and production.
- [ ] Phase 5: Deployment orchestration includes environments, migrations, secrets, rollback.
- [ ] Phase 6: Monitoring tools installed with actionable alerting rules.
- [ ] Phase 7: Launch checklist (pre, during, post) completed.
- [ ] Phase 8: `DEPLOYMENT.md` created with pipeline, environments, tests, rollback, monitoring.
- [ ] `SPEC.md` updated with Deployment & Testing Strategy sections.

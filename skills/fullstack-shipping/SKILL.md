---
name: fullstack-shipping
description: >
  End-to-end build, test, and deploy workflows with production-grade discipline.
  Covers CI/CD pipelines, testing strategy, deployment orchestration, monitoring,
  and launch checklists. Use when preparing to deploy, setting up CI/CD, or
  shipping any non-trivial project. Triggers on: "deploy", "ship", "launch",
  "CI/CD", "build pipeline", "testing strategy", "production", "release",
  "go live", "monitoring", "rollback", "staging".
license: MIT
compatibility: opencode
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

#### Step 1: Surface Assumptions

```
SHIPPING ASSUMPTIONS:
1. This project will be deployed to [platform: Vercel/AWS/Railway/self-hosted]
2. The team will have [N] people reviewing deployments
3. Rollback strategy is [manual/automated/not planned]
4. Monitoring will be [comprehensive/basic/none]
→ Correct me now or I'll proceed with these.
```

#### Step 2: Shipping Interview (8 Questions)

Ask in the user's detected language:

1. **Environment**: Where are you deploying? (Vercel, Netlify, AWS, GCP, Railway, Fly, self-hosted, multiple?)
2. **Stages**: Do you need staging, preview, and production? Or just production?
3. **Team size**: How many people will deploy? Solo or team?
4. **Rollback**: If production breaks, what's the rollback plan? (instant rollback, manual redeploy, database migrations can't rollback)
5. **Database**: Does deployment include database migrations? Can they be rolled back?
6. **Domains**: Custom domain? SSL/TLS handled automatically or manually?
7. **Monitoring**: Do you need uptime monitoring, error tracking, performance metrics?
8. **Compliance**: Any requirements for audit trails, deployment approvals, or SOC2?

#### Step 3: Extended Discovery (if non-trivial)

9. **Traffic**: Expected load at launch? Spike handling (marketing launch, viral)?
10. **Geography**: Global users or regional? CDN needed?
11. **Budget**: Cost constraints for hosting, monitoring, CI minutes?
12. **Secrets**: How are environment variables and API keys managed?

#### Step 4: Confirm & Lock

Summarize. Ask: **"¿Es esto correcto? ¿Diseñamos el pipeline? / Is this correct? Shall we design the pipeline?"**

Only after explicit confirmation, proceed.

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

→ **Ver `CICD-GUIDE.md` para las 3 opciones completas y critical challenges.**

---

### Phase 4 — Testing Strategy in Pipeline

**Define what runs at each stage:**

| Stage | Triggers | Tests | Gates |
|---|---|---|---|
| **PR Open/Update** | Every PR | Lint, TypeCheck, Unit tests | Block merge if fail |
| **PR Merge to `main`** | Merge | Unit + Integration | Block deploy if fail |
| **Staging Deploy** | Push to `staging` | Unit + Integration + E2E (smoke) | Manual approval for prod |
| **Production Deploy** | Tag release | Full E2E suite + visual regression | Requires green staging |

**Test types to include:**
- **Unit:** Vitest/Jest (components, utilities, business logic)
- **Integration:** API endpoints, database queries, auth flows
- **E2E:** Playwright (critical user flows: signup → purchase → logout)
- **Contract:** Zod/OpenAPI validation (API doesn't break consumers)
- **Visual:** Storybook + Chromatic or Playwright screenshots (UI doesn't drift)

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

**Create `DEPLOYMENT.md` or `SHIP.md`:**

```markdown
# Deployment & Shipping

## Pipeline Overview
[Diagram or description of CI/CD flow]

## Environments
| Environment | URL | Branch | Deploy Trigger |
|---|---|---|---|
| Preview | `*.vercel.app` | PR branch | Auto on PR |
| Staging | `staging.example.com` | `staging` | Auto on push |
| Production | `example.com` | `main` | Tag release |

## Testing in CI
| Stage | Tests | Command |
|---|---|---|
| PR | Lint + Unit | `npm run test:unit` |
| Merge | Unit + Integration | `npm run test:integration` |
| Staging | E2E Smoke | `npx playwright test --grep smoke` |
| Production | Full E2E | `npx playwright test` |

## Deployment Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Rollback
- **Code rollback:** [Command or process]
- **Database rollback:** [Script or process]
- **Estimated time to rollback:** [N minutes]

## Monitoring
| Tool | Purpose | Alert Channel |
|---|---|---|
| Sentry | Error tracking | Slack #alerts |
| UptimeRobot | Uptime | SMS + Email |
| Vercel Analytics | Performance | Dashboard |

## Launch History
| Date | Version | Notes |
|---|---|---|
| YYYY-MM-DD | v1.0.0 | Initial launch |
```

**Update `SPEC.md`:** Add or update Deployment & Testing Strategy sections.

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

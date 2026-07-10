---
name: fullstack-shipping
description: "Build, test, and deploy with production-grade CI/CD, testing, orchestration, and monitoring. Triggers on: deploy, ship, launch, pipeline, production. Do NOT use for local prototyping."
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

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Shipping pipeline + deployment plan | `DEPLOYMENT.md` + CI/CD config (YAML) + monitoring config | Root (`DEPLOYMENT.md`) + `.github/workflows/` + monitoring provider | All 8 phases complete (context, discovery, research, CI/CD, testing, orchestration, monitoring, launch checklist), CI/CD pipeline designed with 2-3 options evaluated, testing strategy defined for PR/merge/staging/prod, deployment orchestration includes environments/migrations/secrets/rollback, monitoring tools installed with actionable alerting rules, pre/during/post launch checklist completed, DEPLOYMENT.md created with pipeline overview, environments table, testing stages, rollback procedure, and monitoring |

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

**Research current best practices for [current year].** Never use outdated knowledge. Search for CI/CD platform comparisons, testing in CI setups, deployment patterns (blue-green, canary, zero-downtime migrations), and monitoring solutions.

---

### Phase 3 — CI/CD Pipeline Design

**Generate 2-3 pipeline strategy options. Never default to GitHub Actions without justification.**

→ **See `guides/CICD-GUIDE.md` for the full 3 options and critical challenges.**

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

→ **Ver `guides/DEPLOY-GUIDE.md` para estrategias de entorno, migraciones, secrets y rollback.**

---

### Phase 6 — Monitoring & Alerting

**"Production" means "we don't know if it's working unless we watch it."**

→ **Ver `guides/DEPLOY-GUIDE.md` para categorías de monitoreo y reglas de alertas.**

---

### Phase 7 — Launch Checklist (MANDATORY)

**NO LAUNCH WITHOUT THIS CHECKLIST COMPLETE.**

→ **Ver `guides/LAUNCH-CHECKLIST-GUIDE.md` para el checklist completo de Pre-Launch, Launch Day y Post-Launch.**

---

### Phase 8 — Lock & Document

**Create `DEPLOYMENT.md`** with: Pipeline overview (CI/CD flow), Environments table (preview/staging/prod with URL+branch+trigger), Testing stages, DB migrations, Secrets, Rollback procedure, Monitoring, Launch checklist.

---

## Examples

**Solo landing page:** Vercel, no staging, production deploy from Git. Lint + build on PR. UptimeRobot free monitoring. Minimal `DEPLOYMENT.md`.

**E-commerce platform:** AWS staging+production, team of 4, GitHub Actions → ECS with blue-green. Full test matrix (unit, integration, Stripe simulation, E2E purchase). Sentry + Datadog + PagerDuty. Comprehensive `DEPLOYMENT.md` with runbooks.

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

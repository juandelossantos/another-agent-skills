---
name: ci-cd-and-automation
description: "Automate CI/CD pipeline setup, quality gates, and deployment. Use when configuring test runners or build pipelines. Do NOT use for one-time manual deployments."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: automate-deploy
---

# CI/CD and Automation

**Automated quality gates on every change.**

Focused on CI/CD pipeline setup and automation. For the complete end-to-end shipping lifecycle (deploy, monitor, rollback, launch checklist), use `fullstack-shipping`.

> **Sources:** Google SRE Workbook (sre.google/workbook) — release engineering principles, CI/CD as virtuous cycle, canarying and environment promotion. GitHub Actions documentation (docs.github.com/en/actions) — workflow design, job dependencies, environment protection rules. Google SRE — Testing for Reliability (sre.google/resources) — CI/CD for bug prevention.

## Relationship

`ci-cd-and-automation` (this skill — pipeline automation)
`fullstack-shipping` (end-to-end: deploy + monitoring + rollback + launch)

## When to Use

- Setting up or modifying CI/CD pipelines
- Configuring automated quality gates
- Automating build and deployment processes
- Adding test runners to CI

## When NOT to Use

- Full deployment strategy with monitoring and rollback (use fullstack-shipping)
- Pre-deployment launch checklist

## Pipeline Design

Every pipeline follows a stage structure. Each stage gates progression to the next:

```
Source → Lint → Test → Build → Deploy (staging) → Smoke → Deploy (production)
```

**Key design rules:**
- Stages run in dependency order (test waits for build)
- Parallel where possible (lint + test can run concurrently)
- Each stage has a clear pass/fail condition
- Failed stages block downstream stages
- Manual approval gates for production deployment

See `guides/PIPELINE-TEMPLATES.md` for stage configuration patterns.

## Quality Gates

Quality gates are the conditions that must pass before a stage succeeds. Every change goes through these gates before reaching production:

| Gate | What It Checks | Blocking? |
|---|---|---|
| Lint | Code style, formatting, anti-patterns | Yes |
| Unit tests | Individual function correctness | Yes |
| Integration tests | Service interaction correctness | Yes |
| Build | Compilation succeeds | Yes |
| Security scan | Vulnerabilities, secrets exposure | Yes |
| Performance check | Benchmarks within threshold | Warning |

Gates are not suggestions. If a gate fails, the pipeline stops. See `guides/QUALITY-GATES.md` for configuration patterns.

## Deployment Strategies

| Strategy | How It Works | Best For |
|---|---|---|
| Blue-green | Two identical environments, switch traffic | Zero-downtime deploys |
| Canary | Gradual traffic shift (1% → 10% → 100%) | Risk reduction |
| Rolling | Replace instances one by one | Stateless services |
| Recreate | Shut down old, start new | Simplicity |

Choose based on your risk tolerance and infrastructure. Blue-green is safest. Recreate is simplest.

## Secret Management

Never hardcode secrets in pipeline configuration. Use your CI provider's secret store:

- GitHub Actions: repository secrets, environment secrets
- GitLab CI: CI/CD variables, masked variables
- Any provider: external secret store (Vault, AWS Secrets Manager)

**Rules:**
- Secrets are injected at runtime, never stored in code
- Masked in logs (automatic in most CI providers)
- Rotated on a schedule or after compromise
- Scoped to the environment that needs them

## Rollback

Every deployment must have a rollback plan defined before execution:

1. **Detect** — monitoring alerts on error rate or latency
2. **Decide** — if p95 latency > 500ms for 2 minutes, roll back
3. **Execute** — revert to previous version (automated, under 5 minutes)
4. **Verify** — confirm rollback succeeded and metrics recovered

The rollback should be tested, not assumed. Run a rollback drill before the first production deploy.

## Anti-Patterns

1. Skip tests in CI — "I'll test later" means never.
2. Manual deployment to production — every deploy should go through the pipeline.
3. No rollback plan — a deploy without a rollback is a gamble.
4. Secrets in code — committing credentials because "it's a private repo."
5. Pipeline as an afterthought — adding CI after the project is shipped.
6. Ignoring failed gates — merging despite CI failures.

## Verification

- [ ] Pipeline defined with all required stages (lint, test, build, deploy)
- [ ] Quality gates configured and blocking
- [ ] Deployment strategy chosen and documented
- [ ] Secrets managed through CI provider's secure store
- [ ] Rollback plan defined and tested
- [ ] No secrets in version control

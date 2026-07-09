# Pipeline Templates

> **Sources:** GitHub Actions documentation (docs.github.com/en/actions) — workflow syntax, job dependencies, environment rules. Google SRE Workbook (sre.google/workbook) — release engineering, environment promotion. GitLab CI documentation — pipeline templates and stage design.

## Universal Pipeline Concept

Every CI/CD pipeline follows the same logical flow regardless of which platform you use:

```text
[Source] → [Verify] → [Build] → [Stage] → [Production]
```

This guide describes the concepts. Adapt the syntax to your CI provider.

## Stage Definitions

| Stage | Purpose | Example Gates |
|---|---|---|
| Source | Check out code, install dependencies | Dependency resolution |
| Verify | Run linting, unit tests, type checks | Lint passes, tests pass |
| Build | Compile, package, containerize | Build succeeds, image created |
| Stage | Deploy to staging or preview environment | Integration tests pass |
| Production | Deploy to production with approval | Manual approval, smoke tests |

## Environment Promotion

```text
Commit → CI (verify + build) → Staging (integration tests) → Production (approval)
       ↑                    ↑                        ↑
   Every commit       On CI pass            On manual approval
```

Each environment has stricter gates. Production requires human approval.

## Job Dependencies

Jobs within a stage can run in parallel. Cross-stage dependencies must be explicit:

```yaml
# Concept — adapt to your CI provider
jobs:
  lint:
  test:
    needs: lint          # waits for lint
  build:
    needs: [lint, test]  # waits for both
  deploy-staging:
    needs: build
  deploy-production:
    needs: deploy-staging
    environment: production
    approval: manual
```

## Environment Separation

```text
Development ──→ Staging ──→ Production
    │               │            │
  No gates     Auto-deploy    Manual approval
  Per commit   On main push   Tagged release only
```

## Caching Strategy

Cache dependencies between runs to speed up pipelines:

| What to Cache | Key | When to Invalidate |
|---|---|---|
| Package manager cache | Lockfile hash | On dependency change |
| Build output | Source hash | On source change |
| Test fixtures | Data version | On test data change |

## Notifications

Pipeline failures should notify the team immediately:

- CI pass → no notification (silence is success)
- CI fail → notify author + channel
- Deploy started → notify channel
- Deploy succeeded → notify channel
- Deploy failed → notify author + channel + on-call

## Anti-Patterns

1. Monolithic pipeline — one giant job instead of stages with dependencies.
2. No caching — reinstalling dependencies every run.
3. No environment separation — testing and production sharing variables.
4. Silent failures — pipeline fails but nobody notices.
5. Flaky tests in blocking gates — unreliable tests that block deploys.

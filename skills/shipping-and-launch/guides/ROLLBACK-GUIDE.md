# Shipping — Rollback Guide

## When to Roll Back

| Signal | Action |
|---|---|
| Error rate >5% above baseline | Roll back immediately |
| P0 bug affecting core flow | Roll back immediately |
| P1 bug with no workaround | Roll back within 1 hour |
| Performance regression >20% | Roll back or hotfix within 2 hours |
| Data integrity issue | Roll back + restore from backup |

## Rollback Procedure

1. **Stop the rollout** — Pause any progressive rollouts immediately
2. **Revert the code** — `git revert <sha>` or deploy previous working version
3. **Roll back database** — Run the down migration (must exist)
4. **Verify** — Confirm the previous version serves correctly
5. **Communicate** — Notify stakeholders: what, when, impact, next steps
6. **Post-mortem** — Document root cause, detection time, fix time, prevention

## Rollback Types

| Type | Speed | Risk | When |
|---|---|---|---|
| Code revert | Fast | Low | No DB migration issues |
| DB migration rollback | Medium | Medium | Migration failed or caused data issues |
| Full infrastructure rollback | Slow | Low | Environment-level failure |
| Feature flag | Instant | None | Feature is toggled |

# Migration Strategies

> **Sources:** Strangler Fig pattern (Martin Fowler, martinfowler.com) — incremental application migration by routing traffic. OpenAPI Specification (openapis.org) — backward compatibility and versioning. Google SRE Workbook (sre.google/workbook) — rollback procedures during migration.

## Strategy Decision Tree

```
Is the system critical (downtime = revenue loss)?
├── YES → Can you run old + new simultaneously?
│   ├── YES → Parallel run (lowest risk)
│   └── NO → Strangler Fig (gradual traffic shift)
└── NO → Is the replacement a drop-in?
    ├── YES → Big Bang (fastest, moderate risk)
    └── NO → Phased rollout (users migrate in groups)
```

## Parallel Run

Both systems run at the same time. Users access either one. Traffic is gradually shifted.

```text
Week 1: Old handles 100%, New handles 0% (validation only)
Week 2: Old handles 75%, New handles 25%
Week 3: Old handles 50%, New handles 50%
Week 4: Old handles 25%, New handles 75%
Week 5: Old handles 0%, New handles 100% (old is read-only)
Week 6: Old is shut down
```

**Pros:** Lowest risk, instant rollback (switch traffic back).
**Cons:** Double infrastructure cost during transition.

## Strangler Fig Pattern

Route traffic incrementally from the old system to the new one, piece by piece.

```text
1. Identify a bounded piece of functionality to replace
2. Build the replacement alongside the old system
3. Route traffic for that piece to the new system
4. Remove the old code for that piece
5. Repeat until the old system is empty
```

**Pros:** Incremental, each piece is independently verifiable.
**Cons:** Requires clean module boundaries. Takes longer.

## Big Bang

Switch all traffic from the old system to the new at a single point in time.

```text
T-2 weeks: Freeze changes to old system
T-1 week: Final testing in staging
T-0: Maintenance window. Switch traffic. Monitor.
T+1 hour: Roll back if error rate > 1%
T+1 week: Old system is decommissioned
```

**Pros:** Fastest path. Simple conceptually.
**Cons:** Highest risk. One rollback is all or nothing.

## Phased Rollout

Migrate users in groups based on criteria (tenant, region, plan tier).

```text
Phase 1: Internal users (verify functionality)
Phase 2: Beta customers (opt-in)
Phase 3: 10% of traffic
Phase 4: 50% of traffic
Phase 5: 100% of traffic
```

**Pros:** Risk is contained per-phase. Learn from early phases.
**Cons:** Longer overall timeline. Multiple rollback plans needed.

## Rollback During Migration

Every migration strategy needs a rollback plan executed before migration starts:

| Trigger | Action | Timeline |
|---|---|---|
| Error rate > 1% | Switch traffic back to old system | Under 5 minutes |
| Latency > 2x baseline | Redirect to old system | Under 5 minutes |
| Data inconsistency detected | Stop migration, restore from backup | Under 30 minutes |
| User-reported critical bug | Pause migration, fix or roll back | Under 1 hour |

## Anti-Patterns

1. No rollback plan — "we won't need it" means "we didn't prepare."
2. Migrating everything at once — strangler fig exists for a reason.
3. No validation — assuming the new system works without proving it.
4. Forgetting data migration — moving the code but leaving the data behind.
5. Skipping the parallel run — going straight to big bang without validating.

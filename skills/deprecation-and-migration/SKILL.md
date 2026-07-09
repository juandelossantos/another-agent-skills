---
name: deprecation-and-migration
description: "Manage deprecation and migration of old systems, APIs, and features. Covers sunset strategies, backward compatibility, timelines. Do NOT use for new feature development."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: deprecate-migrate
---

# Deprecation and Migration

**Remove old systems safely. Migrate users without breaking trust.**

The only skill that covers the full lifecycle of retiring functionality: deciding what to sunset, planning migration paths, maintaining backward compatibility during transition, and communicating changes to users.

> **Sources:** OpenAPI Specification (openapis.org) — deprecation marking, backward compatibility rules, versioning scheme. Semantic Versioning 2.0 (semver.org) — breaking change rules. Strangler Fig pattern (Martin Fowler) — incremental migration. Google SRE Workbook (sre.google/workbook) — sunset procedures.

## When to Use

- Removing or replacing an existing API endpoint
- Migrating users from one implementation to another
- Deciding whether to maintain or sunset existing code
- Planning backward-compatible transitions

## When NOT to Use

- Building new features (use feature implementation skills)
- Deployment (use shipping-and-launch)

## Deprecation Lifecycle

```
Announce → Deprecate → Support Window → Sunset
```

| Phase | Duration | What Happens |
|---|---|---|
| Announce | Before deprecation release | Publish changelog, migration guide, deprecation timeline |
| Deprecate | From release | Mark feature as deprecated, warn users on access |
| Support window | 6-12 months | Old version still works, users migrate on their schedule |
| Sunset | After window | Remove feature, return 410 Gone or redirect to replacement |

The support window must be long enough for all known users to migrate. One year is standard for public APIs. Internal systems can use shorter windows (3-6 months).

## Migration Strategies

| Strategy | How It Works | Risk | Best For |
|---|---|---|---|
| Parallel run | Old and new systems run simultaneously | Low | Critical systems, gradual cutover |
| Strangler Fig | Route traffic incrementally from old to new | Medium | Large monoliths, gradual replacement |
| Big Bang | Switch all traffic at once | High | Simple replacements, feature flags |
| Phased rollout | Migrate users in groups | Medium | Multi-tenant systems |

See `guides/MIGRATION-STRATEGIES.md` for decision trees and detailed implementation patterns.

## Backward Compatibility

**Additive changes are always backward compatible.** Removing or changing behavior requires a deprecation window.

| Change Type | Compatible? | Version Bump |
|---|---|---|
| Adding an optional field | Yes | MINOR |
| Adding a new endpoint | Yes | MINOR |
| Removing a field | No — breaking | MAJOR |
| Changing a field type | No — breaking | MAJOR |
| Adding a required field | No — breaking | MAJOR |
| Changing endpoint URL | No — breaking | MAJOR |

## Communication

Every deprecation needs a written notice sent before the change. See `guides/DEPRECATION-COMMUNICATION.md` for templates covering deprecation notices, migration guides, and sunset announcements.

## Anti-Patterns

1. Silent removal — deleting a feature without warning. Users discover it's gone.
2. No migration path — removing the old system without telling users what replaces it.
3. Too short a window — deprecating on Friday and removing on Monday.
4. No rollback plan — the new system has issues and the old system is already gone.
5. Deprecation without replacement — removing a feature with no alternative.
6. Forcing migration — breaking existing users instead of giving them time.

## Verification

- [ ] Deprecation lifecycle defined with timeline
- [ ] Migration strategy chosen and documented
- [ ] Backward compatibility rules followed (breaking = MAJOR version)
- [ ] Deprecation notice published before support window starts
- [ ] Migration guide provided with clear before/after examples
- [ ] Rollback plan in place if migration fails
- [ ] Old system officially sunset after window expires

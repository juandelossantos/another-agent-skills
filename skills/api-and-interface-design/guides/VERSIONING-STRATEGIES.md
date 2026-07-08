# Versioning Strategies

> **Sources:** Semantic Versioning 2.0 (semver.org) — formal MAJOR.MINOR.PATCH rules. OpenAPI Specification (openapis.org) — version field in API metadata. Stripe API versioning (stripe.com/docs/api/versioning) — date-based versioning in production use. Google API Improvement Proposals (google.aip.dev) — versioning guidance for resource-oriented APIs.

## Three Approaches

| Strategy | How It Works | Best For |
|---|---|---|
| URL versioning | Version in URL path `/v1/orders` | REST APIs |
| Header versioning | Version in Accept or custom header | Backward compatibility |
| Parameter versioning | Version as query param | Simple transitions |

Recommendation: URL versioning for MAJOR breaking changes. Header versioning for non-breaking extensions. Never use parameter versioning — it pollutes caches and analytics.

## URL Versioning

```text
GET /api/v1/orders → [{ id, status, total }]
GET /api/v2/orders → [{ id, status, subtotal, tax, total }]
```

Explicit, cache-friendly, easy to route. Every consumer updates URL on major version.

## Header Versioning

```text
GET /api/orders
Accept: application/vnd.api+json;version=1
```

Same URL, different representations. Less explicit but supports gradual migration.

## Date-Based Versioning

Stripe uses date-based versions. Each version is a snapshot of the API at that date:

```text
Stripe-Version: 2024-11-20
```

Old versions continue working for existing consumers. New consumers get the latest.

## Breaking Change Decision Tree

```
Is the change backward compatible?
├── YES → Is it a bug fix?
│   ├── YES → PATCH version
│   └── NO → MINOR version
└── NO → MAJOR version
    Must: keep old version running, notify consumers
```

## Deprecation Lifecycle

```
Announce → Deprecate → Support Window → Remove
```

| Phase | Duration | Action |
|---|---|---|
| Announce | Before release | Publish changelog, migration guide |
| Deprecate | From release | Add Deprecation header |
| Support window | 6-12 months | Old version still serves |
| Remove | After window | 410 Gone or route to migration guide |

## Anti-Patterns

1. No versioning — clients break on every deploy.
2. Too many versions — supporting v1 through v7 simultaneously.
3. Breaking changes in minor — removing a field in a 1.4 release.
4. No deprecation window — removing v1 that was working yesterday.
5. Internal version mirroring — API version matching internal app version.

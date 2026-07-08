---
name: api-and-interface-design
description: "Design stable APIs and module boundaries with clear contracts. Use when designing REST/GraphQL endpoints or defining type contracts between modules. Do NOT use for full backend API implementation."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: design-contract
---

# API and Interface Design

**Stable interfaces with clear contracts between modules.**

This skill covers API and interface design at the architectural level: module boundaries, type contracts, frontend-backend interfaces. For deep backend implementation, use `backend-api-mastery`.

> **Sources:** OpenAPI Specification 3.x (openapis.org) — machine-readable HTTP API contracts. Semantic Versioning 2.0 (semver.org) — breaking change rules. Google API Design Guide (google.aip.dev) — resource-oriented design. GraphQL SDL (graphql.org/learn/schema) — schema definition language. Stripe API versioning (stripe.com/docs/api/versioning) — date-based versioning in practice.

## Relationship

```
api-and-interface-design (this skill — boundaries and contracts)
├── backend-api-mastery (deep backend: DB, auth, validation)
└── frontend-web / frontend-mobile (frontend API clients)
```

## When to Use

- Designing API contracts between frontend and backend
- Defining module boundaries in a codebase
- Creating type interfaces shared across packages
- Establishing communication protocols

## When NOT to Use

- Deep backend implementation (use backend-api-mastery)
- Frontend-specific work (use frontend-web, etc.)
- Database schema design

## Protocol Selection

Choose the protocol that fits your communication pattern:

| Protocol | Best For | Contract Format |
|---|---|---|
| REST (OpenAPI) | CRUD, resource-oriented | OpenAPI 3.x |
| GraphQL | Flexible queries, multiple clients | GraphQL Schema |
| gRPC | Service-to-service, high performance | Protobuf |
| WebSocket | Real-time, bidirectional | Custom message types |

See `guides/CONTRACT-TEMPLATES.md` for templates of each protocol.

## Contract-First Design

Every interface must have a machine-readable contract. Without one, there is no source of truth.

**Workflow:**
1. Define the contract (OpenAPI, GraphQL schema, Protobuf)
2. Generate client and server stubs from the contract
3. Implement server against the contract
4. Run contract tests to verify compliance

The contract is the agreement. If it changes, both sides must agree.

See `guides/CONTRACT-TEMPLATES.md` for protocol-specific contract examples.

## Versioning

API versions follow Semantic Versioning 2.0:

| Change | Version Bump |
|---|---|
| Bug fix (backward compatible) | PATCH (1.0.0 → 1.0.1) |
| New feature (backward compatible) | MINOR (1.0.0 → 1.1.0) |
| Breaking change | MAJOR (1.0.0 → 2.0.0) |

**Breaking:** removing/renaming a field, changing a field type, adding a required field, changing endpoint URL or HTTP method, changing error format.

**Not breaking:** adding an optional field, adding a new endpoint, extending an enum (if clients handle unknown values).

See `guides/VERSIONING-STRATEGIES.md` for implementation patterns.

## Module Boundaries

Within a codebase, module boundaries are interfaces. Enforce them with dependency inversion (modules depend on abstractions, not implementations), shared type definitions (OpenAPI-generated types, Protobuf), and package isolation.

If two modules share internal types, they are not separate modules.

## Anti-Patterns

1. No contract — the API is whatever the backend returns. No source of truth.
2. Breaking changes in minor version — a 1.y.z change that breaks clients.
3. Leaky abstractions — internal database schema in the API response.
4. Chatty APIs — requiring 10 calls to do one thing.
5. Version sprawl — maintaining 5+ versions simultaneously.

## Verification

- [ ] Protocol chosen based on communication pattern
- [ ] Machine-readable contract exists
- [ ] Contract-first workflow followed
- [ ] Versioning strategy documented
- [ ] Breaking changes bump MAJOR version
- [ ] Deprecation notice published before removal
- [ ] Module boundaries enforced by dependency inversion

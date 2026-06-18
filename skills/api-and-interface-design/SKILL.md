---
name: api-and-interface-design
description: >
  Design stable APIs and module boundaries with clear contracts. Use when designing
  REST/GraphQL endpoints, defining type contracts between modules, or establishing
  boundaries between frontend and backend. For deep backend API work, use
  backend-api-mastery instead.
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

This skill covers API and interface design at the architectural level: module boundaries, type contracts, frontend-backend interfaces. For deep backend implementation (database, auth, validation), use `backend-api-mastery`.

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

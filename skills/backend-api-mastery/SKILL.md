---
name: backend-api-mastery
description: >
  Design production-grade APIs with intentional architecture decisions before any
  endpoint is written. Covers protocol choice (REST/GraphQL/tRPC), database design,
  auth strategy, error handling, validation, testing, and documentation. Use when
  building or modifying any API layer, backend service, or data persistence layer.
  Triggers on: "API", "backend", "database", "auth", "endpoint", "REST",
  "GraphQL", "Prisma", "Drizzle", "tRPC", "server", "create API", "design API".
license: MIT
compatibility: opencode
metadata:
  audience: backend-engineers
  workflow: research-design-document
  foundation: engineering-fundamentals
---

# Backend API Mastery

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
backend-specific implementation to the universal philosophy.

**No endpoint is written until the API contract is designed, justified, and locked.**

## When to Use

**MANDATORY** when:
- Building any API layer (REST, GraphQL, tRPC, WebSocket, gRPC)
- Adding a database or persistence layer to a project
- Implementing authentication or authorization
- Designing error handling, validation, or rate limiting
- Creating data models, schemas, or migrations

**Triggered automatically by:**
- `spec-driven-development` (if SPEC.md indicates backend needs)
- `architecture-analysis` (if non-trivial backend is chosen)
- `frontend-web` or `frontend-mobile` (if frontend needs a backend to persist data)

**When NOT to use:**
- The project is frontend-only with no persistence (static site, landing page)
- The backend is already designed and documented in `API-DESIGN.md`
- The task is purely operational (fix a bug in existing API, add one field)

### Stack Detection

Before applying any backend-specific instruction, check for `STACK_CONFIG.md` in the project root.

**If `STACK_CONFIG.md` exists:**
- Read it. Adapt all examples, ORM choices, and tooling to the chosen backend stack.
- Protocol decisions (REST vs GraphQL vs tRPC) are framework-agnostic.
- Auth patterns (JWT vs sessions) are framework-agnostic.
- Database decisions (SQL vs NoSQL) are framework-agnostic.

**If no `STACK_CONFIG.md` exists:**
- Default to Node.js + TypeScript + Express/Fastify + Prisma + PostgreSQL.
- Ask the user: "¿Quieres usar Node.js/Express/Prisma (default) o prefieres Python/FastAPI, Go, Rust, etc.?"

**Adaptation examples:**
- Node/Express → Python/FastAPI: Decorators instead of middleware. Pydantic instead of Zod.
- Node/Express → Go: Structs instead of classes. No ORM, raw SQL or GORM.
- Node/Express → Rust: Actix or Axum. Diesel or SQLx for ORM.

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Domain Discovery
→ See `engineering-fundamentals` Phase 1. Then `DISCOVERY-GUIDE.md` for backend-specific checklist (10 questions: data/consumers/volume/auth/protocol/DB/ORM/integrations → 15 for non-trivial).

---

### Phase 2 — Research (MANDATORY for non-trivial)

**Do not propose protocols, ORMs, or auth strategies without current research.**

1. **Search for current best practices:**
   - "REST API best practices [current year]"
   - "GraphQL vs REST vs tRPC [current year]"
   - "Prisma vs Drizzle [current year] performance"
   - "JWT vs session authentication [current year] security"
   
   **Always use the current year.** Never hardcode a specific year.

2. **Check official documentation:** Latest stable versions, known limitations, migration paths.

3. **Find benchmarks:** ORM performance, auth library security audits, database query patterns.

4. **Present findings concisely** to user before proceeding.

---

### Phase 3 — Protocol Decision

Read `PROTOCOL-GUIDE.md` in this skill directory for the **complete protocol decision matrix**.

**Summary:** Generate 2-3 options (REST, GraphQL, tRPC, WebSocket). Never default to REST without justification. Include honest pros AND cons for each. Present to user for selection.

| Protocol | Best For | Avoid When |
|---|---|---|
| **REST** | Standard HTTP, caching, simple CRUD, public APIs | Complex nested queries, real-time needs |
| **GraphQL** | Multiple consumers, mobile apps, public APIs with exploration | Simple CRUD, caching complexity unacceptable |
| **tRPC** | Fullstack TypeScript, end-to-end type safety | Non-TypeScript consumers, public API for third parties |
| **WebSocket/SSE** | Real-time updates, chat, live dashboards | Standard request/response is sufficient |

---

### Phase 4 — Database Design

**Type:** PostgreSQL (complex/relational/transactions), MySQL (simple relational), SQLite (prototype/edge), MongoDB (flexible schema/rapid iteration).

**ORM:** Prisma (DX/type safety), Drizzle (performance/edge), TypeORM (legacy only).

**Schema:**

1. Identify core entities from discovery answers
2. Define relationships (1:1, 1:N, N:M)
3. Choose primary keys (auto-increment vs UUID vs ULID)
4. Plan indexes for common query patterns
5. Consider soft deletes vs hard deletes
6. Plan for migrations (additive only? destructive changes?)

Document in `API-DESIGN.md` → Section "Data Model"

**Critical Challenge:**
- User wants MongoDB for relational data → "MongoDB is document-oriented. If your data has relationships, you'll end up implementing joins in application code. PostgreSQL handles this natively."
- User wants raw SQL "for performance" → "Prisma is ~10% slower than raw SQL for most queries. Unless you're building high-frequency trading, that 10% is worth the type safety and DX. You can always drop to raw SQL for specific hot paths."

---

### Phase 5 — Auth & Security

Read `AUTH-GUIDE.md` in this skill directory for the **complete auth strategy matrix**.

**Summary:** Choose auth strategy (Session/Cookie, JWT, OAuth, API Keys). Implement validation with Zod. Apply security checklist (HTTPS, CORS, input validation, SQL injection prevention, XSS prevention, rate limiting, secrets management, security headers).

| Strategy | Best For | Avoid When |
|---|---|---|
| **Session + Cookie** | Traditional web apps, same-domain | Mobile apps, cross-domain |
| **JWT (short-lived + refresh)** | SPAs, mobile apps, stateless APIs | Long-lived tokens, revocation critical |
| **OAuth 2.0 / OIDC** | Third-party login, SSO | Simple internal app |
| **API Keys** | Service-to-service, IoT | User-facing auth |

---

### Phase 6 — Error Handling & Testing

**Errors:** Use structured `{ error: { code, message, details, requestId } }`. Correct HTTP codes (200/201/204/400/401/403/404/409/422/429/500).

**Testing:** See `TESTING-GUIDE.md`. Unit (Vitest) for services. Integration (Vitest + test DB) for endpoints. Contract (Zod/OpenAPI) for shapes. E2E (Playwright) for flows. Always separate test DB.

---

### Phase 7 — Documentation & Versioning

#### 7A: Documentation

- **OpenAPI/Swagger** for REST APIs (generate from Zod or code)
- **GraphQL introspection** for GraphQL APIs
- **tRPC router types** serve as documentation for tRPC

**Versioning:** URL versioning (`/v1/`) for public APIs. Header versioning for internal. No versioning for CI/CD-only internal apps. Deprecate in V(N), remove in V(N+2). Return `Deprecation` header + sunset date.

---

### Phase 8 — Lock & Document

**After documenting, log metrics:**
```
LOG METRIC: discovery
- project: [detect from git remote or directory name]
- skill_used: backend-api-mastery
- duration_minutes: [time from Phase 1 start to now]
- questions_asked: [count]
- user_confirms: [count]
- research_queries: [count from Phase 2]
```

**All decisions must be durable. Another engineer should be able to build the API from these documents.**

1. **Create/Update `API-DESIGN.md`** with all sections (Overview, Protocol Decision, Data Model, Authentication, Endpoints/Schema, Error Handling, Testing Strategy, Security Checklist, Versioning).

2. **Update `SPEC.md`** with API Design Decisions section referencing `API-DESIGN.md`.

---

## Examples

See guides for full walkthroughs: `DISCOVERY-GUIDE.md` (simple CRUD blog API), `PROTOCOL-GUIDE.md` (e-commerce with GraphQL + Stripe).

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Express with no ORM." | Raw SQL = error-prone. ORM prevents injection + enables refactoring. |
| "JWT is modern, so better." | JWT insecure for sessions. Server-side sessions are more revocable. |
| "GraphQL > REST." | GraphQL for complex multi-consumer queries. REST for simple CRUD. |
| "I'll build my own auth." | Auth is security-critical. Use NextAuth, Clerk, Supabase Auth. |
| "400 and 422 are the same." | 400 = malformed. 422 = valid syntax, invalid semantics. Fix helps clients debug. |

---

## Red Flags

- The agent defaults to Express + MongoDB without justification.
- The agent proposes JWT for traditional web apps without discussing sessions.
- The agent designs auth from scratch instead of using established libraries.
- The agent omits input validation or rate limiting.
- The agent uses 200 OK for errors or mixes up 401/403.
- The agent skips API documentation.
- The agent uses 2025 or any hardcoded year in research queries (must use [current year]).

---

## Verification

Before proceeding to implementation, confirm:
- [ ] Phase 1: Discovery complete with 10+ questions answered. **(Verify in `DISCOVERY-GUIDE.md`)**
- [ ] Phase 2: Research completed with current year sources.
- [ ] Phase 3: Protocol chosen with 2-3 options evaluated. **(Verify in `PROTOCOL-GUIDE.md`)**
- [ ] Phase 4: Database type, ORM, and schema designed.
- [ ] Phase 5: Auth strategy justified and security checklist complete. **(Verify in `AUTH-GUIDE.md`)**
- [ ] Phase 6: Error format defined and testing strategy documented. **(Verify in `TESTING-GUIDE.md`)**
- [ ] Phase 7: Documentation strategy (OpenAPI/GraphQL/tRPC types) chosen.
- [ ] Phase 8: `API-DESIGN.md` created with all sections.
- [ ] `SPEC.md` updated with API Design Decisions.

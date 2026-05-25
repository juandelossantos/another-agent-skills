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
→ See `engineering-fundamentals` Phase 1 for universal discovery.

Read `DISCOVERY-GUIDE.md` in this skill directory for the **complete backend discovery checklist** (assumptions, 10 questions, extended discovery, confirmation).

**Summary:** Surface assumptions about API consumers, auth, traffic. Ask 10 questions (data, consumers, volume, auth, protocol, database, ORM, integrations). Extend to 15 for non-trivial (compliance, caching, queues, multi-tenancy, rate limiting). Confirm before proceeding.

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

#### 4A: Database Type

| Type | Best For | Avoid When |
|---|---|---|
| **PostgreSQL** | Relational data, complex queries, JSON support, transactions | Simple key-value, schema-less needs, extreme write throughput |
| **MySQL** | Simple relational, existing MySQL ecosystem | Complex JSON operations, advanced PostgreSQL features |
| **SQLite** | Prototyping, embedded, single-user, serverless edge | Multi-user concurrency, high write volume |
| **MongoDB** | Flexible schema, document-oriented, rapid iteration | Complex transactions, heavy joins, strict consistency |

#### 4B: ORM Decision

| ORM | Best For | Avoid When |
|---|---|---|
| **Prisma** | DX-first, migrations, type safety, team productivity | Performance-critical raw SQL, complex query optimization |
| **Drizzle** | Performance, SQL-like syntax, lightweight, edge-compatible | Need mature ecosystem, complex migrations |
| **TypeORM** | Existing TypeORM codebase, decorators, active record | New projects (Prisma/Drizzle are more modern) |

#### 4C: Schema Design

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
| **Session + Cookie** | Traditional web apps, server-rendered, same-domain | Mobile apps, third-party API consumers, cross-domain |
| **JWT (short-lived + refresh)** | SPAs, mobile apps, stateless APIs | Long-lived tokens needed, token revocation critical |
| **OAuth 2.0 / OIDC** | Third-party login (Google, GitHub), SSO | Simple internal app, no external identity providers |
| **API Keys** | Service-to-service, IoT, simple integrations | User-facing auth, high security requirements |

---

### Phase 6 — Error Handling & Testing

#### 6A: Error Design

Use structured, consistent error responses:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [{ "field": "email", "message": "Invalid email format" }],
    "requestId": "req_12345"
  }
}
```

**HTTP Status Codes (use correctly):** 200 OK, 201 Created, 204 No Content, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable Entity, 429 Too Many Requests, 500 Internal Server Error.

#### 6B: Testing Strategy

Read `TESTING-GUIDE.md` in this skill directory for the **complete testing strategy**.

**Summary:** Unit (Vitest/Jest) for services/utilities. Integration (Vitest + test DB) for endpoints/queries. Contract (Zod/OpenAPI) for request/response shapes. E2E (Playwright) for critical flows. Always use separate test database.

| Level | Tool | Coverage |
|---|---|---|
| **Unit** | Vitest/Jest | Service functions, utilities, validation logic |
| **Integration** | Vitest + test DB | API endpoints, database queries, auth flows |
| **Contract** | Zod/OpenAPI | Request/response shape validation |
| **E2E** | Playwright | Critical user flows through the API |

---

### Phase 7 — Documentation & Versioning

#### 7A: Documentation

- **OpenAPI/Swagger** for REST APIs (generate from Zod or code)
- **GraphQL introspection** for GraphQL APIs
- **tRPC router types** serve as documentation for tRPC

#### 7B: Versioning Strategy

| Strategy | Best For | Avoid When |
|---|---|---|
| **URL versioning** (`/v1/`, `/v2/`) | Public APIs, clear breaks | Internal APIs, rapid iteration |
| **Header versioning** | Clean URLs, internal APIs | Public APIs (confusing for consumers) |
| **No versioning** | Internal only, CI/CD deploys together | Public APIs, long-lived consumers |

#### 7C: Deprecation

- Deprecate in V(N), remove in V(N+2)
- Return `Deprecation` header with sunset date
- Document migration path

---

### Phase 8 — Lock & Document

**All decisions must be durable. Another engineer should be able to build the API from these documents.**

1. **Create/Update `API-DESIGN.md`** with all sections (Overview, Protocol Decision, Data Model, Authentication, Endpoints/Schema, Error Handling, Testing Strategy, Security Checklist, Versioning).

2. **Update `SPEC.md`** with API Design Decisions section referencing `API-DESIGN.md`.

---

## Examples

### Example 1: Simple CRUD API

User: "I need a simple API for my blog posts."

Agent:
1. Phase 1: Discover → one consumer (web app), no auth needed for read, admin auth for write, low volume. **Read `DISCOVERY-GUIDE.md`**.
2. Phase 2: Research → "REST best practices [current year]", "Prisma vs Drizzle [current year]".
3. Phase 3: Protocol → Recommend REST. **Read `PROTOCOL-GUIDE.md`**.
4. Phase 4: Database → SQLite for simplicity, PostgreSQL if deploying. User picks PostgreSQL + Prisma.
5. Phase 5: Auth → NextAuth with sessions. **Read `AUTH-GUIDE.md`**.
6. Phase 6: Error handling + testing plan. **Read `TESTING-GUIDE.md`**.
7. Phase 7: OpenAPI documentation.
8. Phase 8: Create `API-DESIGN.md`.

### Example 2: Complex E-commerce API

User: "I need an API for my e-commerce platform with payment integration."

Agent:
1. Phase 1: Discover → web + mobile consumers, PCI-DSS compliance, Stripe integration, 1000+ orders/day. **Read `DISCOVERY-GUIDE.md`**.
2. Phase 2: Research → "GraphQL e-commerce [current year]", "Stripe webhook security [current year]".
3. Phase 3: Protocol → Recommend GraphQL. **Read `PROTOCOL-GUIDE.md`**.
4. Phase 4: Database → PostgreSQL (transactions critical) + Prisma.
5. Phase 5: Auth → OAuth 2.0 + JWT short-lived + refresh tokens. Rate limiting critical. **Read `AUTH-GUIDE.md`**.
6. Phase 6: Comprehensive testing. **Read `TESTING-GUIDE.md`**.
7. Phase 7: OpenAPI for public endpoints, GraphQL introspection for internal.
8. Phase 8: Create `API-DESIGN.md`.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just use Express with no ORM." | Raw SQL is error-prone and untypeable. An ORM prevents SQL injection and enables refactoring. |
| "JWT is modern, so it's better." | JWT is stateless but insecure for sessions. For web apps, server-side sessions are more secure and revocable. |
| "GraphQL is better than REST." | GraphQL is better for specific problems (multiple consumers, complex queries). For simple CRUD, it's overkill. |
| "I'll build my own auth system." | Auth is security-critical. Use battle-tested libraries (NextAuth, Clerk, Supabase Auth). |
| "No need for rate limiting yet." | Rate limiting is easier to add from the start than retrofit. A simple loop in the frontend can DDoS your API. |
| "I'll document the API after it's built." | Documentation-first (OpenAPI) generates typesafe clients and catches breaking changes early. |
| "SQLite is fine for production." | SQLite is brilliant for prototyping and edge computing. For multi-user web apps with concurrent writes, use PostgreSQL. |
| "400 and 422 are the same thing." | 400 = malformed request. 422 = syntactically correct but semantically invalid. Using them correctly helps clients debug. |

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

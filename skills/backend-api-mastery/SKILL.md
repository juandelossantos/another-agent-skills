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
---

# Backend API Mastery

**No endpoint is written until the API contract is designed, justified, and
locked.**

This skill prevents the most common backend trap: jumping straight to code
without answering fundamental questions about data, consumers, auth, and scale.
It forces the agent to design the API as a product, not as an afterthought.

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

### Stack Detection (NEW)

Before applying any backend-specific instruction, check for `STACK_CONFIG.md` in the project root.

**If `STACK_CONFIG.md` exists:**
- Read it. Adapt all examples, ORM choices, and tooling to the chosen backend stack.
- Protocol decisions (REST vs GraphQL vs tRPC) are framework-agnostic.
- Auth patterns (JWT vs sessions) are framework-agnostic.
- Database decisions (SQL vs NoSQL) are framework-agnostic.

**If no `STACK_CONFIG.md` exists:**
- Default to Node.js + TypeScript + Express/Fastify + Prisma + PostgreSQL (as documented below).
- Ask the user: "¿Quieres usar Node.js/Express/Prisma (default) o prefieres Python/FastAPI, Go, Rust, etc.?"

**Adaptation examples:**
- Node/Express → Python/FastAPI: Decorators instead of middleware. Pydantic instead of Zod.
- Node/Express → Go: Structs instead of classes. No ORM, raw SQL or GORM.
- Node/Express → Rust: Actix or Axum. Diesel or SQLx for ORM.

---

## Core Process

### Phase 0 — Context Assessment

1. **Check existing documentation:**
   - Does `SPEC.md` exist? Read its Architecture Decisions and Tech Stack sections.
   - Does `architecture/ARCHITECTURE.md` exist? Respect its backend decisions.
   - Does `API-DESIGN.md` exist? If yes and task is within its scope, build within it.

2. **Assess scope:**
   - **Simple:** Single model CRUD, no auth, internal use only → Lightweight design.
   - **Non-trivial:** Multiple models, auth, public API, third-party consumers → Full design.
   - **Complex:** Microservices, event-driven, high scale, regulated → Extended analysis.

3. **Check health status:**
   - If existing codebase → Verify `HEALTH-CHECK.md` exists and is recent.
   - If critical issues → Fix foundation before adding API layer.

---

### Phase 1 — Domain Discovery (MANDATORY)

**NO DESIGN DECISIONS ARE MADE UNTIL THIS PHASE IS COMPLETE.**

#### Step 1: Surface Assumptions

List at least 4 assumptions about the backend:

```
BACKEND ASSUMPTIONS:
1. This API will serve [internal only / public / third-party developers]
2. The primary consumers are [web app / mobile / IoT / other APIs]
3. Auth will be [none / basic session / JWT / OAuth / API keys]
4. Peak traffic will be [N requests/second]
→ Correct me now or I'll proceed with these.
```

#### Step 2: Backend Discovery Interview (10 Questions)

Ask in the user's detected language. Do not proceed until answered:

1. **Data**: What data must persist? (users, transactions, logs, media, events, time-series)
2. **Consumers**: Who consumes this API? (your web app, mobile apps, third-party devs, IoT devices)
3. **Public vs Private**: Is this API only for your frontend, or will third-party developers use it?
4. **Volume**: Peak requests per second? Expected data growth per month?
5. **Auth**: Do you need authentication? What user types? (public, authenticated, admin, roles)
6. **Real-time**: Need WebSockets, Server-Sent Events, or pure request/response?
7. **Protocol**: REST, GraphQL, tRPC, or undecided?
8. **Database preference**: PostgreSQL, MySQL, MongoDB, SQLite, or undecided?
9. **ORM**: Prisma, Drizzle, TypeORM, raw SQL, or undecided?
10. **Integrations**: Does it connect to external systems? (payments, emails, notifications, third-party APIs)

#### Step 3: Extended Technical Discovery (if non-trivial)

11. **Compliance**: Any regulatory requirements? (GDPR, HIPAA, SOC2, PCI-DSS)
12. **Caching**: Need Redis, CDN, or application-level caching?
13. **Queue/Background jobs**: Need job queues? (email sending, image processing, reports)
14. **Multi-tenancy**: One DB per tenant, schema per tenant, or shared tables?
15. **Rate limiting**: Any expectations? (requests per minute/hour/day per user)

#### Step 4: Confirm & Lock

Summarize technical context. Ask: **"¿Es esto correcto? ¿Procedemos al diseño? / Is this correct? Shall we design?"**

Only after explicit confirmation, proceed to Phase 2.

---

### Phase 2 — Research (MANDATORY for non-trivial)

**Do not propose protocols, ORMs, or auth strategies without current research.**

1. **Search for current best practices:**
   - "REST API best practices [current year]"
   - "GraphQL vs REST vs tRPC [current year]"
   - "Prisma vs Drizzle [current year] performance"
   - "JWT vs session authentication [current year] security"
   
   **Always use the current year.** Never hardcode a specific year.

2. **Check official documentation:**
   - Latest stable versions of candidate technologies
   - Known limitations or breaking changes
   - Migration paths (if user has existing code)

3. **Find benchmarks:**
   - ORM performance comparisons
   - Auth library security audits
   - Database query patterns for the user's specific data model

4. **Present findings concisely:**
   ```
   RESEARCH FINDINGS:
   - [Technology A]: Dominant in [domain], excellent for [strength].
     Limitation: [specific weakness for this context].
   - [Technology B]: Rising adoption, great for [strength].
     Limitation: [specific weakness].
   → Any of this context change your thinking?
   ```

---

### Phase 3 — Protocol Decision

**Generate exactly 2-3 protocol options. Never default to REST without justification.**

| Protocol | Best For | Avoid When |
|---|---|---|
| **REST** | Standard HTTP, caching, simple CRUD, public APIs | Complex nested queries, real-time needs, tight frontend coupling |
| **GraphQL** | Multiple consumers with different data needs, mobile apps, public APIs with exploration | Simple CRUD, caching complexity unacceptable, team unfamiliar |
| **tRPC** | Fullstack TypeScript monorepo, end-to-end type safety, no API documentation overhead | Non-TypeScript consumers, public API for third parties, multi-platform |
| **WebSocket/SSE** | Real-time updates, chat, live dashboards | Standard request/response is sufficient |

**Example options:**

- **Option A — REST + OpenAPI**
  - Stack: Express/Fastify + Zod + OpenAPI/Swagger
  - Pros: Universally understood, excellent caching, easy public documentation
  - Contras: Over-fetching/under-fetching, versioning overhead, manual type sync with frontend
  - Ideal for: Public APIs, third-party developers, simple data shapes

- **Option B — GraphQL**
  - Stack: Apollo Server/Yoga + Pothos/TypeGraphQL + Codegen
  - Pros: Precise data fetching, single endpoint, self-documenting
  - Contras: Query complexity attacks, caching harder, learning curve for team
  - Ideal for: Multiple consumers (web + mobile + third-party), complex data relationships

- **Option C — tRPC**
  - Stack: tRPC + Fastify/Next.js + Zod
  - Pros: End-to-end type safety, no manual API documentation, tight frontend coupling
  - Contras: Only TypeScript consumers, tight coupling means frontend/backend can't evolve independently
  - Ideal for: Fullstack TypeScript, internal APIs, rapid iteration

**Critical Challenge:**
- User wants GraphQL for a simple CRUD app with one consumer → "GraphQL adds complexity you don't need. tRPC gives you type safety with less overhead for a single TypeScript frontend. REST is simpler still. What's your priority: type safety or simplicity?"
- User wants tRPC for a public API → "tRPC is brilliant for internal TypeScript teams but useless for non-TypeScript consumers or public APIs. For public APIs, REST or GraphQL are the only viable options."

---

### Phase 4 — Database Design

#### 4A: Database Type

| Type | Best For | Avoid When |
|---|---|---|
| **PostgreSQL** | Relational data, complex queries, JSON support, transactions | Simple key-value, schema-less needs, extreme write throughput |
| **MySQL** | Simple relational, existing MySQL ecosystem, LAMP stacks | Complex JSON operations, advanced PostgreSQL features needed |
| **SQLite** | Prototyping, embedded, single-user, serverless edge | Multi-user concurrency, high write volume, network access |
| **MongoDB** | Flexible schema, document-oriented, rapid iteration | Complex transactions, heavy joins, strict data consistency |

#### 4B: ORM Decision

| ORM | Best For | Avoid When |
|---|---|---|
| **Prisma** | DX-first, migrations, type safety, team productivity | Performance-critical raw SQL, complex query optimization |
| **Drizzle** | Performance, SQL-like syntax, lightweight, edge-compatible | Need mature ecosystem, complex migrations, Prisma's client features |
| **TypeORM** | Existing TypeORM codebase, decorators, active record | New projects (Prisma/Drizzle are more modern) |

**Critical Challenge:**
- User wants MongoDB for relational data → "MongoDB is document-oriented. If your data has relationships (users → orders → products), you'll end up implementing joins in application code. PostgreSQL handles this natively with better consistency."
- User wants raw SQL "for performance" → "Prisma is ~10% slower than raw SQL for most queries. Unless you're building a high-frequency trading system, that 10% is worth the type safety and DX. You can always drop to raw SQL for specific hot paths."

#### 4C: Schema Design

1. Identify core entities from discovery answers
2. Define relationships (1:1, 1:N, N:M)
3. Choose primary keys (auto-increment vs UUID vs ULID)
4. Plan indexes for common query patterns
5. Consider soft deletes vs hard deletes
6. Plan for migrations (additive only? destructive changes?)

Document in `API-DESIGN.md` → Section "Data Model"

---

### Phase 5 — Auth & Security

#### 5A: Auth Strategy

| Strategy | Best For | Avoid When |
|---|---|---|
| **Session + Cookie** | Traditional web apps, server-rendered, same-domain | Mobile apps, third-party API consumers, cross-domain |
| **JWT (short-lived + refresh)** | SPAs, mobile apps, stateless APIs | Long-lived tokens needed, token revocation critical |
| **OAuth 2.0 / OIDC** | Third-party login (Google, GitHub), SSO | Simple internal app, no external identity providers |
| **API Keys** | Service-to-service, IoT, simple integrations | User-facing auth, high security requirements |

**Critical Challenge:**
- User wants JWT for long-lived sessions → "JWTs can't be revoked individually without a blacklist, which defeats the purpose of statelessness. For long sessions with logout capability, server-side sessions are more secure."
- User wants to build their own auth → "Auth is security-critical and easy to get wrong. Use NextAuth, Clerk, Auth0, or Supabase Auth. Building your own is a liability unless you're a security company."

#### 5B: Validation & Input Sanitization

- **Always use Zod** (or similar) for runtime validation of all inputs
- Never trust client data — validate at API boundary
- Sanitize outputs to prevent XSS (even in JSON APIs)

#### 5C: Rate Limiting

- **Always implement** for public APIs
- Use Redis or in-memory for distributed setups
- Different limits for authenticated vs anonymous users

#### 5D: Security Checklist

- [ ] HTTPS only (HSTS headers)
- [ ] CORS properly configured (not `*` in production)
- [ ] Input validation on every endpoint
- [ ] SQL injection prevention (ORM or parameterized queries)
- [ ] XSS prevention (sanitize outputs)
- [ ] Rate limiting implemented
- [ ] Secrets not in code (`.env` + `.env.example`)
- [ ] Security headers (Helmet or equivalent)

---

### Phase 6 — Error Handling & Testing

#### 6A: Error Design

Use structured, consistent error responses:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ],
    "requestId": "req_12345"
  }
}
```

**HTTP Status Codes (use correctly):**
- 200 OK — GET success
- 201 Created — POST success
- 204 No Content — DELETE success
- 400 Bad Request — Client input error
- 401 Unauthorized — Not authenticated
- 403 Forbidden — Authenticated but not authorized
- 404 Not Found — Resource doesn't exist
- 409 Conflict — Business logic conflict
- 422 Unprocessable Entity — Validation failed
- 429 Too Many Requests — Rate limited
- 500 Internal Server Error — Server bug (log, don't expose details)

#### 6B: Testing Strategy

| Level | Tool | Coverage |
|---|---|---|
| **Unit** | Vitest/Jest | Service functions, utilities, validation logic |
| **Integration** | Vitest + test DB | API endpoints, database queries, auth flows |
| **Contract** | Zod/OpenAPI | Request/response shape validation |
| **E2E** | Playwright | Critical user flows through the API |

**Test database:** Always use a separate test database or Docker container. Never test against production or development databases.

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

1. **Create/Update `API-DESIGN.md`:**
   ```markdown
   # API Design

   ## Overview
   [Protocol, purpose, consumers]

   ## Protocol Decision
   - Chosen: [REST/GraphQL/tRPC] because [justification]
   - Rejected: [alternatives] because [reasons]

   ## Data Model
   [Entity Relationship Diagram or table definitions]

   ## Authentication
   - Strategy: [session/JWT/OAuth/API keys]
   - Authorization: [roles/permissions/ABAC]

   ## Endpoints / Schema
   [For REST: endpoint table with methods, auth, validation]
   [For GraphQL: type definitions]
   [For tRPC: router structure]

   ## Error Handling
   [Error format, status codes, common error scenarios]

   ## Testing Strategy
   [Unit, integration, E2E coverage plan]

   ## Security Checklist
   [Rate limits, CORS, validation, secrets]

   ## Versioning
   [Strategy, current version, deprecation policy]
   ```

2. **Update `SPEC.md`:**
   - Add API Design Decisions section
   - Reference `API-DESIGN.md`

---

## Examples

### Example 1: Simple CRUD API

User: "I need a simple API for my blog posts."

Agent:
1. Phase 1: Discover — one consumer (web app), no auth needed for read, admin auth for write, low volume.
2. Phase 2: Research — "REST best practices [current year]", "Prisma vs Drizzle [current year]".
3. Phase 3: Protocol — Recommend REST (simple, cacheable, public reads). User accepts.
4. Phase 4: Database — SQLite for simplicity (prototyping), PostgreSQL if they plan to deploy. User picks PostgreSQL. Prisma for DX.
5. Phase 5: Auth — NextAuth with sessions for admin write operations.
6. Phase 6: Error handling + testing plan.
7. Phase 7: OpenAPI documentation.
8. Phase 8: Create `API-DESIGN.md`.

### Example 2: Complex E-commerce API

User: "I need an API for my e-commerce platform with payment integration."

Agent:
1. Phase 1: Discover — web + mobile consumers, PCI-DSS compliance needed, Stripe integration, 1000+ orders/day expected.
2. Phase 2: Research — "GraphQL e-commerce [current year]", "Prisma performance [current year]", "Stripe webhook security [current year]".
3. Phase 3: Protocol — Recommend GraphQL (web + mobile with different data needs). User accepts.
4. Phase 4: Database — PostgreSQL (transactions critical). Prisma (mature ecosystem, excellent migration support).
5. Phase 5: Auth — OAuth 2.0 + JWT short-lived + refresh tokens. Rate limiting critical (Stripe webhooks, public endpoints).
6. Phase 6: Comprehensive testing (unit, integration, Stripe webhook simulation, E2E purchase flow).
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
- [ ] Phase 1: Discovery complete with 10+ questions answered.
- [ ] Phase 2: Research completed with current year sources.
- [ ] Phase 3: Protocol chosen with 2-3 options evaluated.
- [ ] Phase 4: Database type, ORM, and schema designed.
- [ ] Phase 5: Auth strategy justified and security checklist complete.
- [ ] Phase 6: Error format defined and testing strategy documented.
- [ ] Phase 7: Documentation strategy (OpenAPI/GraphQL/tRPC types) chosen.
- [ ] Phase 8: `API-DESIGN.md` created with all sections.
- [ ] `SPEC.md` updated with API Design Decisions.

---
name: backend-api-mastery
description: Design production-grade APIs: protocol, database, auth, error handling, validation, testing, docs. Triggers: API, backend, endpoint. Do NOT use for frontend-only projects.
  "GraphQL", "Prisma", "Drizzle", "tRPC", "server", "create API", "design API".
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
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
- Ask the user for their preferred stack and adapt patterns accordingly (middleware→decorators, Zod→Pydantic, etc.).

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Domain Discovery
→ See `engineering-fundamentals` Phase 1. Then `guides/DISCOVERY-GUIDE.md` for backend-specific checklist (10 questions: data/consumers/volume/auth/protocol/DB/ORM/integrations → 15 for non-trivial).

---

### Phase 2 — Research (MANDATORY for non-trivial)

**Do not propose protocols, ORMs, or auth strategies without current research.** Search for best practices with `[current year]`, check official documentation for latest versions and known limitations, and find benchmarks. Present findings concisely before proceeding.

---

### Phase 3 — Protocol Decision

Read `guides/PROTOCOL-GUIDE.md` in this skill directory for the **complete protocol decision matrix**.

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

**Critical Challenge:** MongoDB for relational data → explain document vs relational tradeoffs. Raw SQL "for performance" → ORM adds ~10% overhead for significant type safety and DX; drop to raw SQL for hot paths only.

---

### Phase 5 — Auth & Security

Read `guides/AUTH-GUIDE.md` in this skill directory for the **complete auth strategy matrix**.

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

**Testing:** See `guides/TESTING-GUIDE.md`. Unit (Vitest) for services. Integration (Vitest + test DB) for endpoints. Contract (Zod/OpenAPI) for shapes. E2E (browser testing tools) for flows. Always separate test DB.

---

### Phase 7 — Documentation & Versioning

#### 7A: Documentation

- **OpenAPI/Swagger** for REST APIs (generate from Zod or code)
- **GraphQL introspection** for GraphQL APIs
- **tRPC router types** serve as documentation for tRPC

**Versioning:** URL versioning (`/v1/`) for public APIs. Header versioning for internal. No versioning for CI/CD-only internal apps. Deprecate in V(N), remove in V(N+2). Return `Deprecation` header + sunset date.

---

### Phase 8 — Lock & Document

**Log metrics:** `LOG METRIC: discovery — project, skill_used, duration_minutes, questions_asked, user_confirms, research_queries`

**All decisions must be durable.** Create/Update `API-DESIGN.md` (Overview, Protocol Decision, Data Model, Authentication, Endpoints, Error Handling, Testing, Security, Versioning). Update `SPEC.md` referencing `API-DESIGN.md`.

---

## Examples

See guides for full walkthroughs: `guides/DISCOVERY-GUIDE.md` (simple CRUD blog API), `guides/PROTOCOL-GUIDE.md` (e-commerce with GraphQL + Stripe).

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
- [ ] Phase 1: Discovery complete with 10+ questions answered. **(Verify in `guides/DISCOVERY-GUIDE.md`)**
- [ ] Phase 2: Research completed with current year sources.
- [ ] Phase 3: Protocol chosen with 2-3 options evaluated. **(Verify in `guides/PROTOCOL-GUIDE.md`)**
- [ ] Phase 4: Database type, ORM, and schema designed.
- [ ] Phase 5: Auth strategy justified and security checklist complete. **(Verify in `guides/AUTH-GUIDE.md`)**
- [ ] Phase 6: Error format defined and testing strategy documented. **(Verify in `guides/TESTING-GUIDE.md`)**
- [ ] Phase 7: Documentation strategy (OpenAPI/GraphQL/tRPC types) chosen.
- [ ] Phase 8: `API-DESIGN.md` created with all sections.
- [ ] `SPEC.md` updated with API Design Decisions.

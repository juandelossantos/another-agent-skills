# Protocol Decision Guide

This guide contains the complete Phase 3 Protocol Decision for `backend-api-mastery`.

## Phase 3 — Protocol Decision

**Generate exactly 2-3 protocol options. Never default to REST without justification.**

### Protocol Comparison

| Protocol | Best For | Avoid When |
|---|---|---|
| **REST** | Standard HTTP, caching, simple CRUD, public APIs | Complex nested queries, real-time needs, tight frontend coupling |
| **GraphQL** | Multiple consumers with different data needs, mobile apps, public APIs with exploration | Simple CRUD, caching complexity unacceptable, team unfamiliar |
| **tRPC** | Fullstack TypeScript monorepo, end-to-end type safety, no API documentation overhead | Non-TypeScript consumers, public API for third parties, multi-platform |
| **WebSocket/SSE** | Real-time updates, chat, live dashboards | Standard request/response is sufficient |

### Example Options

**Option A — REST + OpenAPI**
- Stack: Express/Fastify + Zod + OpenAPI/Swagger
- Pros: Universally understood, excellent caching, easy public documentation
- Contras: Over-fetching/under-fetching, versioning overhead, manual type sync with frontend
- Ideal for: Public APIs, third-party developers, simple data shapes

**Option B — GraphQL**
- Stack: Apollo Server/Yoga + Pothos/TypeGraphQL + Codegen
- Pros: Precise data fetching, single endpoint, self-documenting
- Contras: Query complexity attacks, caching harder, learning curve for team
- Ideal for: Multiple consumers (web + mobile + third-party), complex data relationships

**Option C — tRPC**
- Stack: tRPC + Fastify/Next.js + Zod
- Pros: End-to-end type safety, no manual API documentation, tight frontend coupling
- Contras: Only TypeScript consumers, tight coupling means frontend/backend can't evolve independently
- Ideal for: Fullstack TypeScript, internal APIs, rapid iteration

### Critical Challenge

- User wants GraphQL for simple CRUD with one consumer → "GraphQL adds complexity you don't need. tRPC gives you type safety with less overhead for a single TypeScript frontend. REST is simpler still. What's your priority: type safety or simplicity?"
- User wants tRPC for a public API → "tRPC is brilliant for internal TypeScript teams but useless for non-TypeScript consumers or public APIs. For public APIs, REST or GraphQL are the only viable options."

### Research Requirements

Before proposing protocols, perform web research:
1. "REST API best practices [current year]"
2. "GraphQL vs REST vs tRPC [current year]"
3. Check official documentation for latest versions
4. Find benchmarks for the user's specific data model

**Always use current year. Never hardcode a specific year.**

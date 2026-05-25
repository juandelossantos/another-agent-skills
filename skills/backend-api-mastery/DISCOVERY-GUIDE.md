# Backend Discovery Guide

This guide contains the complete Phase 1 Domain Discovery for `backend-api-mastery`.

## Phase 1 — Domain Discovery (MANDATORY)

**NO DESIGN DECISIONS ARE MADE UNTIL THIS PHASE IS COMPLETE.**

### Step 1: Surface Assumptions

List at least 4 assumptions about the backend:

```
BACKEND ASSUMPTIONS:
1. This API will serve [internal only / public / third-party developers]
2. The primary consumers are [web app / mobile / IoT / other APIs]
3. Auth will be [none / basic session / JWT / OAuth / API keys]
4. Peak traffic will be [N requests/second]
→ Correct me now or I'll proceed with these.
```

### Step 2: Backend Discovery Interview (10 Questions)

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

### Step 3: Extended Technical Discovery (if non-trivial)

11. **Compliance**: Any regulatory requirements? (GDPR, HIPAA, SOC2, PCI-DSS)
12. **Caching**: Need Redis, CDN, or application-level caching?
13. **Queue/Background jobs**: Need job queues? (email sending, image processing, reports)
14. **Multi-tenancy**: One DB per tenant, schema per tenant, or shared tables?
15. **Rate limiting**: Any expectations? (requests per minute/hour/day per user)

### Step 4: Confirm & Lock

Summarize technical context. Ask: **"Is this correct? Shall we design?"**

Only after explicit confirmation, proceed to Phase 2.

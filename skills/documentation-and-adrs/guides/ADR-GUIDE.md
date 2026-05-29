# Architecture Decision Records

ADRs capture the reasoning behind significant technical decisions.

## When to Write an ADR

- Choosing a framework, library, or major dependency
- Designing a data model or database schema
- Selecting an authentication strategy
- Deciding on an API architecture (REST vs GraphQL vs tRPC)
- Any decision that would be expensive to reverse

## ADR Template

Store ADRs in `docs/decisions/` with sequential numbering:

```markdown
# ADR-001: Use PostgreSQL for primary database

## Status
Accepted | Superseded by ADR-XXX | Deprecated

## Date
2025-01-15

## Context
We need a primary database for the task management application. Key requirements:
- Relational data model (users, tasks, teams with relationships)
- ACID transactions for task state changes
- Support for full-text search on task content

## Decision
Use PostgreSQL with Prisma ORM.

## Alternatives Considered

### MongoDB
- Pros: Flexible schema, easy to start with
- Cons: Our data is inherently relational
- Rejected: Relational data in document store leads to complex joins

### SQLite
- Pros: Zero configuration, embedded
- Cons: Limited concurrent write support
- Rejected: Not suitable for multi-user production

## Consequences
- Prisma provides type-safe database access
- Team needs PostgreSQL knowledge (standard skill)
```

## ADR Lifecycle

```
PROPOSED → ACCEPTED → (SUPERSEDED or DEPRECATED)
```

**Don't delete old ADRs.** They capture historical context. When a decision changes, write a new ADR that references and supersedes the old one.

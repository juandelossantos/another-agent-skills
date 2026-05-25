# Critical Challenge Guide

Phase 4 challenge patterns for `architecture-analysis`.

## Challenge Patterns

| Situation | Challenge |
|---|---|
| Microservices for <5 devs | "Microservices multiply ops complexity. With 3 devs, modular monolith gives separation without ops overhead. Extract services later when you have a team to own them." |
| Kubernetes for MVP | "K8s has steep learning curve. For MVP, Railway/Fly/Vercel abstract infrastructure so you focus on product. Migrate to K8s when traffic justifies it." |
| NoSQL "because faster" | "NoSQL is faster for specific access patterns but slower for relational queries. If data has relationships (users → orders → products), PostgreSQL with indexing is often faster and more consistent. What are your query patterns?" |
| Stack they already know | "Familiarity speeds dev, but if that stack doesn't fit the problem (e.g., Electron for simple website), you'll fight the tool. Evaluate fit, not just familiarity." |
| No preference | "That's fine. Based on your answers, I recommend Option [X]. Here's why..." |

## Presentation Format

```
CRITICAL OBSERVATIONS:

1. You mentioned [preference]. Based on scale ([N] users, [M] devs),
   this might be [over-engineering/under-engineering/mismatch] because [reason].
   Consider [alternative] instead.

2. [Trade-off]: Option A optimizes for [X] but sacrifices [Y].
   Given your priorities, [which matters more?]

3. [Risk]: Biggest risk with your preferred approach is [specific risk].
   Mitigation: [specific approach], but requires [cost].

→ Please respond to each. Answers determine recommendation.
```

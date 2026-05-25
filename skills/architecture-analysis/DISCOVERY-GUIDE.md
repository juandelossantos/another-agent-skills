# Architecture Discovery Guide

Phase 1 discovery for `architecture-analysis`.

## Step 1: Surface Assumptions

List 4+ technical assumptions. Present for confirmation:

```
TECHNICAL ASSUMPTIONS:
1. Project serves [N] concurrent users at launch
2. Team has [X] developers with [Y] experience
3. Deployment target: [cloud/VPS/self-hosted]
4. Budget/timeline allows: [learning curve/setup time]
→ Correct me now or I proceed.
```

## Step 2: Architecture Interview (6 Questions)

Ask in user's language. Don't proceed until answered:

1. **Scale**: Users/concurrent at launch? In 12 months?
2. **Team**: Devs? Strongest language/framework?
3. **Ops**: Who handles deploy, monitoring, incidents?
4. **Data**: Persisted data? Relational, document, time-series, blob?
5. **Latency**: Real-time (ms), interactive (<1s), batch (minutes+)?
6. **Constraints**: Hard constraints? (Client mandates .NET, AWS required, on-premise)

## Step 3: Confirm & Lock

Summarize context. Ask: **"¿Es esto correcto? ¿Procedemos? / Correct? Shall we analyze?"**

Only after explicit confirmation, proceed to Phase 2.

## Complexity Assessment

- **Simple**: Single-page, no backend, no auth → Lightweight recommendation.
- **Non-trivial**: Multi-page, data persistence, auth, API → Full analysis.
- **Complex**: Multi-team, high scale, regulated, distributed → Extended analysis with trade-off matrix.

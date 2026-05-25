---
name: architecture-analysis
description: >
  Evaluate architecture options with critical thinking before any build decision.
  Proposes 2-3 justified alternatives, challenges user assumptions, and locks
  decisions into specs. Use when choosing a stack, pattern, or structural approach
  for non-trivial projects. Triggers on: "what stack", "architecture", "MVC or",
  "which framework", "how to structure", "backend choice", "microservices",
  "monolith", "pattern", "should I use", "evaluate options".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: evaluate-challenge-lock
---

# Architecture Analysis

**No code is scaffolded until architecture is decided and documented.**

This skill prevents framework hype, cargo-culting, and resume-driven development.
It forces the agent to evaluate options honestly, challenge the user when
appropriate, and lock the decision into a durable record before any file is created.

## When to Use

**MANDATORY** when:
- Starting a non-trivial project (multi-page, multi-module, or with backend needs)
- Choosing between frameworks, stacks, or architectural patterns
- The user says "I want to use X" without clear justification
- Evaluating microservices vs monolith, SSR vs CSR, REST vs GraphQL, etc.
- Any decision that will be expensive to reverse later

**When NOT to use:**
- The stack is already locked in `SPEC.md` and the task is purely implementation
- One-off component tweaks within an existing architecture
- Projects explicitly tagged as "toy"/"learning" where speed > correctness

---

## Core Process

### Phase 0 — Context Assessment

**Before proposing options, understand constraints.**

1. **Check for existing decisions:**
   - Does `SPEC.md` exist? Read its Architecture Decisions section.
   - Does `architecture/ARCHITECTURE.md` exist? Do not contradict it without explicit approval.

2. **Assess complexity:**
   - **Simple:** Single-page, no backend, no auth → Skip to lightweight recommendation.
   - **Non-trivial:** Multi-page, needs data persistence, user auth, or API → Full analysis.
   - **Complex:** Multi-team, high scale, regulated, or distributed → Extended analysis with trade-off matrix.

3. **Check health status:**
   - If existing codebase → Verify `HEALTH-CHECK.md` exists and is recent.
   - If critical issues found → Recommend fixing foundation before adding architecture.

---

### Phase 1 — Discovery (MANDATORY)

**NO OPTIONS ARE GENERATED UNTIL THIS PHASE IS COMPLETE.**

#### Step 1: Surface Assumptions

List at least 4 technical assumptions. Present for confirmation:

```
TECHNICAL ASSUMPTIONS:
1. This project will serve [N] concurrent users at launch
2. The team has [X] developers with [Y] experience level
3. Deployment target is [cloud/VPS/self-hosted/unknown]
4. The budget/timeline allows for [learning curve/setup time]
→ Correct me now or I'll proceed with these.
```

#### Step 2: Architecture Interview (6 Questions)

Ask in the user's detected language. Do not proceed until answered:

1. **Scale**: How many users/concurrent connections at launch? In 12 months?
2. **Team**: How many developers? What's their strongest language/framework?
3. **Ops**: Who handles deployment, monitoring, and incident response?
4. **Data**: What data must persist? Relational, document, time-series, or blob?
5. **Latency**: Real-time (ms), interactive (<1s), or batch (minutes+)?
6. **Constraints**: Any hard constraints? (Client mandates .NET, already paying for AWS, must be on-premise)

#### Step 3: Confirm & Lock

Summarize technical context. Ask: **"¿Es esto correcto? ¿Procedemos al análisis? / Is this correct? Shall we analyze options?"**

Only after explicit confirmation, proceed to Phase 2.

---

### Phase 2 — Candidate Research

**Do not invent options from memory. Research before proposing.**

1. **Identify candidate technologies** for this specific context:
   - Search for "best [type] framework [current year] [scale]"
   - Check official docs for latest stable versions
   
   **Always use the current year.** Never hardcode a specific year.
   - Verify maintenance status (last commit, open issues, release cadence)

2. **Find benchmarks or case studies:**
   - Performance comparisons under similar load
   - Migration stories (especially from technologies the user currently uses)
   - Known limitations that affect this use case

3. **Present findings concisely:**
   ```
   RESEARCH FINDINGS:
   - [Technology A]: Dominant in [domain], excellent for [strength].
     Limitation: [specific weakness for this context].
   - [Technology B]: Rising adoption, great for [strength].
     Limitation: [specific weakness].
   → Any of this context change your thinking?
   ```

---

### Phase 3 — Generate Options

**Generate exactly 2 or 3 options. Never one (creates false certainty). Never four+ (analysis paralysis).**

Each option MUST include:

| Field | Description |
|---|---|
| **Name** | Short, memorable label |
| **Stack** | Concrete tools with versions |
| **Pattern** | MVC, MVVM, Clean Architecture, Hexagonal, Serverless, Modular Monolith |
| **Pros** | 3 genuine advantages FOR THIS PROJECT |
| **Contras** | 3 genuine disadvantages (be honest, even if it kills the sale) |
| **Ideal for** | The scenario where this is the clear winner |
| **Main risk** | The biggest thing that could go wrong |

**Example options for a SaaS B2B dashboard:**

- **Option A — Next.js Fullstack (Vercel)**
  - Stack: Next.js 16 + PostgreSQL + Prisma + NextAuth + Vercel
  - Pattern: MVC with Server Components
  - Pros: Fastest to MVP, SSR/SEO native, one codebase, Vercel handles ops
  - Contras: Vendor lock-in Vercel, backend tightly coupled to frontend, harder to extract API later
  - Ideal for: Small team, speed-to-market critical, no dedicated DevOps
  - Main risk: Hitting Vercel limits (execution time, DB connections) at scale

- **Option B — Decoupled SPA + API**
  - Stack: React + Vite + Express/Fastify + PostgreSQL + tRPC/REST + Docker + Railway/Fly
  - Pattern: Clean Architecture / Hexagonal (API), Feature-based (Frontend)
  - Pros: Frontend/backend evolve independently, easier testing, portable deployment
  - Contras: More setup, CORS/auth complexity, need someone who understands both stacks
  - Ideal for: Team >3 devs, likely mobile app in future, need API for integrations
  - Main risk: Frontend-backend sync overhead slows iteration early on

- **Option C — Serverless Edge**
  - Stack: Next.js + Cloudflare Workers + D1/Drizzle + Clerk + Cloudflare Pages
  - Pattern: Serverless / Edge-first
  - Pros: Auto-scaling, global edge latency, pay-per-use cost model
  - Contras: Vendor lock-in Cloudflare, cold starts, debugging distributed traces is harder
  - Ideal for: Global user base, variable traffic, strong technical team
  - Main risk: Debugging and local development experience is worse than traditional

---

### Phase 4 — Critical Challenge (MANDATORY)

**This is where senior engineering happens. Do not blindly accept the user's preference.**

Analyze the user's stated preference (if any) against the options:

| Situation | Challenge |
|---|---|
| User wants microservices for <5 devs | "Microservices multiply operational complexity. With 3 developers, a modular monolith gives you separation without the ops overhead. You can extract services later when you have a team to own them." |
| User wants Kubernetes for an MVP | "Kubernetes is powerful but has a steep learning curve. For an MVP, Railway, Fly, or Vercel abstract the infrastructure so you can focus on product. Migrate to K8s when you have traffic that justifies it." |
| User wants NoSQL "because it's faster" | "NoSQL is faster for specific access patterns but slower for relational queries. If your data has relationships (users → orders → products), PostgreSQL with proper indexing is often faster and more consistent. What are your query patterns?" |
| User wants the stack they already know | "Familiarity speeds development, but if that stack doesn't fit the problem (e.g., Electron for a simple website), you'll fight the tool. Let's evaluate fit, not just familiarity." |
| User has no preference | "That's fine. Based on your answers, I recommend Option [X]. Here's why..." |

**Presentation format:**
```
CRITICAL OBSERVATIONS:

1. You mentioned [preference]. Based on your scale ([N] users, [M] devs),
   this might be [over-engineering/under-engineering/mismatch] because [reason].
   Consider [alternative] instead.

2. [Trade-off]: Option A optimizes for [X] but sacrifices [Y].
   Given your priorities, [which matters more?]

3. [Risk]: The biggest risk with your preferred approach is [specific risk].
   Mitigation: [specific approach], but it requires [cost].

→ Please respond to each. Your answers will determine the recommendation.
```

---

### Phase 5 — Recommendation & Lock

**Present ONE recommendation with honest confidence level.**

```
RECOMMENDATION:

Based on [specific user answers], I recommend:
→ Option [X]: [Name]

Justification:
- [Reason 1 tied to user context]
- [Reason 2 tied to user context]
- [Trade-off accepted: we sacrifice X because Y matters more for this project]

Confidence: HIGH / MEDIUM / LOW
- HIGH: Clear match between project needs and option strengths
- MEDIUM: Good match, but one significant risk to monitor
- LOW: All options have serious trade-offs for this context

If you choose this, the next step is documenting the decision in SPEC.md
and creating the architecture folder.

→ Do you accept this recommendation? Reply "yes" or ask for changes.
```

**If user rejects:** Go back to Phase 3. Adjust options based on feedback. Do not cycle more than twice — if still undecided, force a decision: "We need to lock a decision to proceed. Which option feels least wrong?"

---

### Phase 6 — Document Decision

**Architecture without documentation is fiction.**

1. **Update `SPEC.md`** — Add/ensure Architecture Decisions section:
   ```markdown
   ## Architecture Decisions

   - **Chosen:** [Option X] — [Name]
   - **Date:** YYYY-MM-DD
   - **Rationale:** [2-3 sentences referencing user answers]
   - **Rejected:**
     - [Option Y] — [why it was worse for this context]
     - [Option Z] — [why it was worse for this context]
   - **Trade-offs accepted:** [What we knowingly sacrificed]
   - **Confidence:** HIGH/MEDIUM/LOW
   - **Review trigger:** Revisit when [specific condition: team size >X, users >Y, etc.]
   ```

2. **Create `architecture/ARCHITECTURE.md`**:
   ```markdown
   # Architecture Overview

   ## Executive Summary
   [One paragraph: what we're building, why this architecture fits]

   ## Stack & Versions
   - Frontend: [...]
   - Backend: [...]
   - Database: [...]
   - Auth: [...]
   - Hosting: [...]
   - Testing: [...]

   ## Architectural Pattern
   [MVC / Hexagonal / Serverless / etc.]
   [Brief explanation of how it applies to this project]

   ## High-Level Structure
   ```
   [Directory tree or component diagram]
   ```

   ## Key Decisions
   | Decision | Rationale | Date |
   |---|---|---|
   | [Decision 1] | [Why] | YYYY-MM-DD |

   ## Risks & Mitigations
   | Risk | Likelihood | Impact | Mitigation |
   |---|---|---|---|
   | [Risk 1] | High/Med/Low | High/Med/Low | [Action] |

   ## Migration Path
   [If we need to change architecture later, what does that look like?]
   ```

---

## Examples

### Example 1: User Wants Microservices

User: "I want to build my MVP with microservices."

Agent:
1. Phase 1: Discover team = 2 devs, scale = 0 users (pre-launch), timeline = 2 months.
2. Phase 2: Research microservices overhead vs monolith speed.
3. Phase 3: Generate options:
   - A: Microservices (Docker + Kubernetes + separate repos)
   - B: Modular Monolith (Next.js + feature-based folders)
   - C: Serverless functions (Vercel/Netlify functions)
4. Phase 4: Challenge — "With 2 devs and a 2-month timeline, microservices means spending 40% of your time on infrastructure instead of product. A modular monolith lets you separate concerns now and extract services later when you have the team."
5. User: "But I read microservices are best practice."
6. Agent: "Best practice depends on context. For Google, yes. For a 2-person MVP, no. The best practice for your context is speed of iteration."
7. Phase 5: Recommend Option B. User accepts.
8. Phase 6: Document in SPEC.md + create architecture/ARCHITECTURE.md.

### Example 2: User Has No Preference

User: "I need a backend for my React app. What should I use?"

Agent:
1. Phase 1: Discover: real-time chat needed, 1 dev, knows JavaScript, timeline 1 month.
2. Phase 2: Research: Socket.io vs Server-Sent Events vs WebSockets raw.
3. Phase 3: Options:
   - A: Express + Socket.io (simple, battle-tested)
   - B: Fastify + native WS (faster, more manual work)
   - C: Firebase Realtime (zero backend code, vendor lock-in)
4. Phase 4: Challenge — "For 1 dev and 1 month, Firebase gets you to market fastest. But you'll pay forever and migration is painful. Express + Socket.io gives you ownership with moderate setup. What's your priority: speed or ownership?"
5. User: "Speed first, but I want to own it eventually."
6. Phase 5: Recommend A (Express + Socket.io) with migration path to B documented.
7. Phase 6: Document decision.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "The user already chose a stack, just go with it." | Senior engineers challenge bad decisions. The user may not know the trade-offs. |
| "Microservices are modern, so they're better." | Modern != appropriate. Context determines correctness. |
| "I know React best, so I'll recommend it." | Familiarity bias harms the user. Recommend what fits, not what you know. |
| "This is just an MVP, architecture doesn't matter." | MVPs become production. Decisions made "for speed" often become permanent. |
| "Kubernetes is the industry standard." | Industry standard for Google ≠ standard for a 3-person startup. |
| "The user didn't ask for options, they asked for implementation." | If the foundation is rotten, implementation is wasted effort. |
| "I've seen this pattern work before." | Patterns work in specific contexts. Verify this context matches. |

---

## Red Flags

- The agent recommends a stack without asking about scale, team, or constraints.
- The agent presents only one option.
- The agent agrees with the user's choice without analyzing trade-offs.
- The agent uses "best practice" without qualifying for what context.
- Architecture decisions are made without being documented in SPEC.md.
- The agent skips discovery and jumps to "just use Next.js."
- The agent recommends a technology they've heard of but haven't researched.

---

## Verification

Before proceeding to build, confirm:
- [ ] At least 2 options were generated with honest pros AND cons.
- [ ] The user's context (scale, team, constraints) was discovered.
- [ ] Critical challenge occurred — the agent questioned at least one assumption.
- [ ] A single option was recommended with justification tied to user context.
- [ ] The user explicitly accepted the recommendation.
- [ ] `SPEC.md` contains an Architecture Decisions section.
- [ ] `architecture/ARCHITECTURE.md` exists with stack, pattern, structure, and risks.

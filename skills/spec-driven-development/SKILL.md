---
name: spec-driven-development
description: >
  Creates comprehensive specifications before coding through research, critical
  analysis, and user alignment. Use when starting a new project, feature, or
  significant change. Use when requirements are unclear, ambiguous, or exist only
  as a vague idea. Use for existing projects that lack documentation. Triggers on:
  "spec", "specification", "design doc", "requirements", "let's plan this",
  "what are we building", "document this", or any project kickoff.
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: research-discover-specify-plan
---

# Spec-Driven Development (Extended)

**No specification, no code.** This skill forces clarity through research,
critical questioning, and documented decisions. It does not blindly transcribe
user requests — it challenges assumptions, surfaces trade-offs, and proposes
better alternatives when appropriate.

## When to Use

**MANDATORY** for:
- Starting any new project or feature
- Requirements that are ambiguous, incomplete, or one sentence long
- Changes touching more than 3 files or crossing module boundaries
- Any architectural or technology decision
- Tasks estimated at more than 30 minutes of implementation
- Existing codebases with no `SPEC.md`

**When NOT to use:** Single-line fixes, typo corrections, or truly trivial
changes where requirements are self-evident.

---

## Core Process

### Phase 0 — Context Assessment

**Before anything else, understand where we are.**

1. **Check for existing code:**
   - If `package.json`, source files, or any code exists → Check `HEALTH-CHECK.md`.
   - If no `HEALTH-CHECK.md` or it's >7 days old → **Invoke `project-health-check`** first.
   - Do NOT proceed until health check decision is made (Fix/Proceed/Ignore).

2. **Check for existing specs:**
   - If `SPEC.md` exists → Read it. Determine if this request is an extension,
     modification, or unrelated new work.
   - If `SPEC.md` exists and covers this work → Ask user if they want to update it.
   - If no `SPEC.md` → This is a greenfield spec. Continue.

3. **Assess complexity:**
   - **Simple:** Single component, single page, single endpoint → Can skip Phase 1 (Research) but NOT Phase 2 (Discovery).
   - **Non-trivial:** Multi-page, needs backend, has user auth, handles data → Full process required.
   - **Complex:** Multi-team, microservices, high scale → Requires `architecture-analysis` before spec.

---

### Phase 1 — Domain Research (Recommended for Non-Trivial)

**NOBLIND CODING. Research before specifying.**

If complexity is non-trivial or higher, perform **web research**:

1. **Search for domain best practices:**
   - "Best practices for [type of product] [current year]"
   - "Common pitfalls in [domain/industry] [current year]"
   - "Architecture patterns for [scale/type] [current year]"
   
   **Always use the current year.** Never hardcode a specific year.

2. **Search for technology documentation:**
   - Latest stable versions of candidate technologies
   - Official getting-started guides
   - Known limitations or breaking changes

3. **Search for case studies or benchmarks:**
   - Similar projects and their technology choices
   - Performance benchmarks for candidate stacks
   - Community adoption and maintenance status

**Present findings to user:**

```
RESEARCH FINDINGS:

1. [Technology/Pattern]: Projects like yours typically use [X] because [reason].
   However, [Y] is gaining traction for [advantage].

2. [Domain Insight]: [Specific insight about the user's domain].
   This suggests we should prioritize [consideration].

3. [Risk]: [Common pitfall] affects 60% of similar projects.
   Mitigation: [specific approach].

→ Does this context match your understanding? Any of this change your thinking?
```

**Critical thinking rule:** Do not present research as "the way." Present it as
"context for our decision." The user may have constraints you don't know about.

---

### Phase 2 — Deep Discovery (MANDATORY)

**NO SPEC IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

This is the original discovery gate, enhanced with critical analysis.

#### Step 1: Surface Assumptions

List at least 5 assumptions. Present them for confirmation:

```
ASSUMPTIONS I'M MAKING:
1. [Assumption about product type]
2. [Assumption about users/audience]
3. [Assumption about tech constraints]
4. [Assumption about data/storage]
5. [Assumption about timeline/scope]
→ Correct me now or I'll proceed with these.
```

#### Step 2: Discovery Interview (Minimum 6 Questions)

Ask these in the user's detected language. Do not proceed until answered:

1. **Objective**: What problem does this solve? Who is the user? What does success look like?
2. **Scope**: Is this an MVP or complete product? What features are MUST vs. NICE vs. OUT?
3. **Context**: Where and how will this be used? (Device, environment, offline needs)
4. **Constraints**: Any hard constraints? (Budget, timeline, compliance, existing systems)
5. **Stack preference**: Any existing technology? Anything you hate or love?
6. **Success metrics**: How will we know this is done? (Numbers, user actions, performance targets)

#### Step 3: Critical Challenge (NEW — This is where we differ from obedient agents)

**Analyze the user's answers critically. Look for:**

- **Over-engineering:** "I need microservices" for a 2-user MVP → Challenge: "Microservices add operational complexity. For an MVP, a monolith deploys faster and is easier to iterate. Would a modular monolith work?"
- **Under-engineering:** "Just store everything in localStorage" for sensitive data → Challenge: "localStorage is readable by any script on the page and has no encryption. For [data type], this is a security risk. Can we use IndexedDB with encryption or a lightweight backend?"
- **XY Problem:** User asks for X but actually needs Y → Challenge: "You asked for [specific implementation]. I'm wondering if what you actually need is [underlying need]. Would [alternative] solve it better?"
- **Scope creep:** "And also..." → Challenge: "That's 3 features. For an MVP, I recommend focusing on [most critical] first. The others can be Phase 2. Does that work?"
- **Missing context:** "I want it fast" → Challenge: "Fast to develop or fast to run? We can optimize for one but it trades off with the other. Which matters more for launch?"

**Presentation format:**
```
CRITICAL OBSERVATIONS:

1. [Observation about potential issue] → Suggestion: [better approach]
2. [Observation about trade-off] → Question: [what does user prioritize?]
3. [Observation about missing info] → Need: [specific detail]

→ Please respond to each. Your answers will go into the spec.
```

#### Step 4: Confirm & Lock Discovery

Summarize EVERYTHING: research + discovery + critical analysis + resolutions.

```
SPEC FOUNDATION — CONFIRM THIS IS CORRECT:

We're building: [one sentence]
For: [audience]
That solves: [problem]
Using: [high-level approach, if decided]
Success means: [metrics]

Key decisions made:
- [Decision 1 with rationale]
- [Decision 2 with rationale]
- [Trade-off accepted: X over Y because Z]

→ Is this correct? Reply "yes" or correct me.
```

Only after explicit "yes/sí/perfecto/adelante", proceed to Phase 3.

---

### Phase 3 — Architecture Decision Gate

**If non-trivial or complex:**

```
Before I write the full specification, we need to lock in our architecture.
The spec depends on these decisions:

- Frontend framework and rendering strategy
- Backend approach (if any)
- Data layer and persistence
- Authentication strategy
- Deployment target

Let me invoke architecture-analysis to evaluate options for your specific case.
```

1. **Invoke `architecture-analysis`** skill.
2. Wait for architecture decision to be documented.
3. Verify `SPEC.md` will have an Architecture Decisions section.

**If simple:** Note in spec: "Simple project, standard stack per visual-frontend-mastery."

---

### Phase 4 — Write SPEC.md

**The spec is the contract. It must be complete enough that another engineer
could build it without talking to you.**

Use this enhanced template:

```markdown
# Spec: [Project/Feature Name]

## Objective
[What + why + who. 2-3 sentences max. Include user story if helpful.]

## Research Context
[What we learned from Phase 1 research. Link to sources if specific.]
- Domain insight: [...]
- Technology context: [...]
- Risks identified: [...]

## Architecture Decisions
[From architecture-analysis, or "Simple project, standard stack"]
- Chosen: [stack/pattern] because [justification]
- Rejected: [alternative] because [reason]
- Trade-offs accepted: [...]

## Tech Stack
[Framework, language, key dependencies with LOCKED versions]
- Frontend: [...]
- Backend (if applicable): [...]
- Database: [...]
- Auth: [...]
- Hosting: [...]
- Testing: [...]

## Commands
[Full executable commands with flags]
```bash
# Development
npm run dev

# Testing
npm test -- --coverage

# Build
npm run build

# Lint
npm run lint
```

## Project Structure
```
src/
├── app/               → Next.js App Router
├── components/        → Reusable UI components
├── lib/               → Utilities, helpers
├── hooks/             → Custom React hooks
└── types/             → Shared TypeScript types

public/               → Static assets

tests/
├── unit/              → Component tests
├── integration/       → API/module tests
└── e2e/               → Playwright tests

docs/                 → Documentation
design/               → Design assets and lock
architecture/         → Architecture docs
```

## Code Style
```typescript
// Example of expected code quality
export function Button({ variant = 'primary', children }: ButtonProps) {
  // Use CSS custom properties, not hardcoded values
  return <button className={`btn btn-${variant}`}>{children}</button>;
}
```

- Naming: PascalCase components, camelCase functions, kebab-case files
- Types: Strict TypeScript, no `any`
- Comments: Why, not what. No commented-out code.

## Testing Strategy
- **Unit:** Vitest for components and utilities
- **Integration:** API routes, database queries
- **E2E:** Playwright for critical user flows
- **Coverage:** Minimum 70% for new code

## Boundaries
- **Always:** Run tests before commits, follow token system, validate inputs
- **Ask first:** Add dependencies, change CI/CD, modify database schema
- **Never:** Commit secrets, skip types, use generic AI-slop patterns

## Success Criteria
[Specific, testable conditions. No vague language.]
- [ ] Criterion 1: [measurable condition]
- [ ] Criterion 2: [measurable condition]
- [ ] Criterion 3: [measurable condition]

## Open Questions
[Anything unresolved that needs human input before or during build]
- [ ] Question 1
- [ ] Question 2

## Related Documents
- `HEALTH-CHECK.md` — Project health status
- `DESIGN.md` — Visual design system (if applicable)
- `ARCHITECTURE.md` — Detailed architecture (if complex)
```

**Rules for writing:**
- Write in the user's detected language (Spanish/English).
- Include the research context section — it proves critical thinking happened.
- If architecture-analysis was invoked, reference its output.
- Success criteria MUST be testable. "Faster" → "LCP < 2.5s on 4G".
- Save to `SPEC.md` in project root.

---

### Phase 5 — Plan

With validated spec, generate implementation plan:

1. Identify major components and dependencies
2. Determine order (what must be built first)
3. Note risks and mitigations
4. Identify parallel vs. sequential work
5. Define verification checkpoints

The plan should be reviewable: user must be able to say "yes, that's right" or
"no, change X."

---

### Phase 6 — Tasks

Break plan into discrete, implementable tasks:

- Completable in a single focused session
- Explicit acceptance criteria
- Verification step (test, build, manual check)
- Ordered by dependency
- No task changes more than ~5 files

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm]
  - Files: [Which files will be touched]
```

---

### Phase 7 — Environment Audit Gate

**Before implementing, verify tools:**

```
Before we build, let's verify your development environment has everything needed.
```

1. **Check for `docs/DEV-ENVIRONMENT.md`:**
   - If exists and recent → Read it.
   - If missing or outdated → **Invoke `dev-environment-audit`**.

2. **Verify critical tools are available:**
   - Node.js >= 20.9
   - Package manager (npm/pnpm/yarn)
   - Git
   - If testing required: Vitest/Playwright installed

3. **If gaps found:**
   - Present to user with installation commands
   - Get confirmation before installing anything

---

### Phase 8 — Implement Gate (MANDATORY FINAL CONFIRMATION)

**THIS IS A FULL STOP BEFORE ANY CODE.**

```
We are ready to build. Before I write any code, confirm:

✅ SPEC.md — Complete and approved
✅ PLAN — Technical approach reviewed
✅ TASKS — Broken into implementable chunks
✅ ARCHITECTURE — Decisions documented (if non-trivial)
✅ ENVIRONMENT — Tools verified and available

→ Are we building this? Reply "yes" or "let's go" to begin implementation.
```

**Valid responses:** "yes", "sí", "adelante", "let's go", "proceed", "vamos"
**Invalid responses:** "ok", "sure", "mmhm" → Ask again with explicit confirmation.

Only after explicit confirmation, invoke `incremental-implementation` and `test-driven-development`.

---

## Keeping the Spec Alive

The spec is a living document:

- **Update when decisions change** — Discover data model needs changing? Update spec first.
- **Update when scope changes** — Features added or cut? Reflect in spec.
- **Commit the spec** — Belongs in version control alongside code.
- **Reference in PRs** — Link back to spec sections each PR implements.
- **Revisit during retrospectives** — Did the spec match reality? What was wrong?

---

## Integration with Other Skills

| Skill | When Invoked | Why |
|---|---|---|
| `project-health-check` | Phase 0, if existing code | Audit before building on unknown foundations |
| `architecture-analysis` | Phase 3, if non-trivial | Make informed stack/pattern decisions |
| `dev-environment-audit` | Phase 7, before build | Ensure tools are ready |
| `planning-and-task-breakdown` | Phase 5-6 | Break spec into concrete tasks |
| `visual-frontend-mastery` | BUILD phase, if UI work | Design tokens, anti-slop, animation |
| `incremental-implementation` | After Phase 8 | Build tasks one at a time |
| `test-driven-development` | After Phase 8 | Prove code works as specified |

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "This is simple, I don't need a spec." | Simple tasks don't need *long* specs, but they need acceptance criteria. A two-line spec prevents ambiguity. |
| "The user is impatient, I'll skip research." | Research takes minutes. Rebuilding due to bad assumptions takes hours. |
| "I'll write the spec after I code it." | That's documentation, not specification. The spec's value is forcing clarity BEFORE code. |
| "The spec will slow us down." | A 20-minute spec prevents hours of rework. Waterfall in 20 minutes beats debugging in 20 hours. |
| "Requirements will change anyway." | That's why the spec is a living document. An outdated spec is still better than no spec. |
| "The user knows what they want." | Even clear requests have implicit assumptions. The spec surfaces those assumptions. |
| "I should just do what the user asked." | Senior engineers challenge requests when they see better alternatives. The user hired expertise, not obedience. |
| "I already have a good idea of the architecture." | Ideas aren't decisions. Documented decisions with trade-offs are what teams can align on. |

---

## Red Flags

Watch for these signals that this skill is being violated:
- Code is written before any written requirements exist.
- The agent asks "should I just start building?" before clarifying what "done" means.
- Features are implemented that were never mentioned in any spec or task list.
- Architectural decisions are made without documenting trade-offs.
- The spec is skipped because "it's obvious what to build."
- The agent blindly accepts user requests without challenging assumptions.
- Research phase is skipped for non-trivial projects.
- The implement gate (Phase 8) is bypassed with vague user responses.

---

## Verification

Before proceeding to implementation, confirm:

- [ ] Phase 0: Context assessed (health check if existing project)
- [ ] Phase 1: Research completed (if non-trivial)
- [ ] Phase 2: Discovery complete with critical challenges documented
- [ ] Phase 3: Architecture decided (if non-trivial)
- [ ] Phase 4: SPEC.md written with all 10 sections
- [ ] Phase 5: Implementation plan reviewed by user
- [ ] Phase 6: Tasks broken into chunks with acceptance criteria
- [ ] Phase 7: Environment verified
- [ ] Phase 8: Explicit "yes" obtained from user to begin coding
- [ ] The human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] The spec is saved to a file in the repository

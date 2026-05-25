---
name: spec-driven-development
description: >
  Creates comprehensive specifications before coding through research, critical
  analysis, and user alignment. Use when starting a new project, feature, or
  significant change. Triggers on: "spec", "specification", "design doc",
  "requirements", "let's plan this", "what are we building", "document this".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: research-discover-specify-plan
  foundation: engineering-fundamentals
---

# Spec-Driven Development

**Built on `engineering-fundamentals`.** Read that skill first.

**No specification, no code.** Forces clarity through research, critical questioning, and documented decisions. Challenges assumptions, surfaces trade-offs, proposes better alternatives.

## When to Use

**MANDATORY** for:
- Starting any new project or feature
- Ambiguous, incomplete, or one-sentence requirements
- Changes touching > 3 files or crossing module boundaries
- Any architectural or technology decision
- Tasks estimated at > 30 minutes
- Existing codebases with no `SPEC.md`

**When NOT to use:** Single-line fixes, typo corrections, truly trivial changes.

---

## Core Process

### Phase 0 — Context Assessment

**Before anything else, understand where we are.**

1. **Check for existing code:**
   - If `package.json`, source files, or any code exists → Check `HEALTH-CHECK.md`.
   - If no `HEALTH-CHECK.md` or it's >7 days old → **Invoke `project-health-check`** first.
   - Do NOT proceed until health check decision is made (Fix/Proceed/Ignore).

2. **Check for existing specs:**
   - If `SPEC.md` exists → Read it. Determine if extension, modification, or new work.
   - If `SPEC.md` covers this work → Ask user if they want to update it.
   - If no `SPEC.md` → Greenfield spec. Continue.

3. **Assess complexity:**
   - **Simple:** Single component/page/endpoint → Skip Phase 1 (Research) but NOT Phase 2 (Discovery).
   - **Non-trivial:** Multi-page, needs backend, auth, data → Full process required.
   - **Complex:** Multi-team, microservices, high scale → Requires `architecture-analysis` before spec.

---

### Phase 1 — Domain Research (Recommended for Non-Trivial)

**NOBLIND CODING. Research before specifying.**

If complexity is non-trivial or higher, perform web research:

1. **Search domain best practices:**
   - "Best practices for [type of product] [current year]"
   - "Common pitfalls in [domain/industry] [current year]"
   - "Architecture patterns for [scale/type] [current year]"
   
   **Always use current year.** Never hardcode a specific year.

2. **Search technology documentation:** Latest stable versions, known limitations, breaking changes.

3. **Search case studies or benchmarks:** Similar projects, performance benchmarks, community adoption.

**Present findings:**
```
RESEARCH FINDINGS:

1. [Technology/Pattern]: Projects like yours typically use [X] because [reason].
   However, [Y] is gaining traction for [advantage].

2. [Domain Insight]: [Specific insight about user's domain].
   This suggests we should prioritize [consideration].

3. [Risk]: [Common pitfall] affects 60% of similar projects.
   Mitigation: [specific approach].

→ Does this context match your understanding? Any of this change your thinking?
```

**Critical thinking rule:** Present research as "context for our decision," not "the way." User may have unknown constraints.

---

### Phase 2 — Deep Discovery (MANDATORY)

**NO SPEC IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

Read `DISCOVERY-GUIDE.md` for complete discovery process.

**Summary:**
1. **Surface Assumptions** — List 5+. Present for confirmation.
2. **Discovery Interview** — Ask 6 questions (objective, scope, context, constraints, stack, success metrics).
3. **Critical Challenge** — Analyze answers critically. Challenge over-engineering, under-engineering, XY problems, scope creep, missing context.
4. **Confirm & Lock** — Summarize everything. Ask for explicit "yes" before proceeding.

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

**If simple:** Note in spec: "Simple project, standard stack per frontend-web."

---

### Phase 4 — Write SPEC.md

**The spec is the contract.**

Read `SPEC-TEMPLATE-GUIDE.md` for the **complete SPEC.md template** with all 10 sections.

**Summary of sections:**
1. Objective (What + why + who)
2. Research Context (What we learned from Phase 1)
3. Architecture Decisions (Chosen/rejected/trade-offs)
4. Tech Stack (Locked versions)
5. Commands (Executable commands with flags)
6. Project Structure (Folder tree)
7. Code Style (Naming, types, comments)
8. Testing Strategy (Unit, integration, E2E, coverage)
9. Acceptance Criteria (Specific, testable)
10. Boundaries (What is NOT included)

**Writing rules:**
- Write in user's detected language.
- Include research context section — proves critical thinking happened.
- If architecture-analysis invoked, reference its output.
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

The plan should be reviewable: user must be able to say "yes, that's right" or "no, change X."

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

2. **Verify critical tools:**
   - Node.js >= 20.9
   - Package manager (npm/pnpm/yarn)
   - Git
   - If testing required: Vitest/Playwright installed

3. **If gaps found:** Present to user with installation commands. Get confirmation before installing.

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

**After implement gate passes, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory name]
- gate_name: spec-implement
- result: pass
- checks_passed: 5/5
```

**After entire spec process completes, log:**
```
LOG METRIC: discovery
- project: [detect from git remote or directory name]
- skill_used: spec-driven-development
- duration_minutes: [total time from Phase 1 to Phase 8]
- questions_asked: [count]
- user_confirms: [count]
- research_queries: [count from Phase 1]
```

---

## Keeping the Spec Alive

The spec is a living document:
- **Update when decisions change** — Update spec first, then code.
- **Update when scope changes** — Features added or cut? Reflect in spec.
- **Commit the spec** — Belongs in version control alongside code.
- **Reference in PRs** — Link back to spec sections each PR implements.
- **Revisit during retrospectives** — Did the spec match reality? What was wrong?

---

## Integration with Other Skills

| Skill | When Invoked | Why |
|---|---|---|
| `engineering-fundamentals` | Implicitly, by all skills | Universal philosophy |
| `project-health-check` | Phase 0, if existing code | Audit before building |
| `architecture-analysis` | Phase 3, if non-trivial | Informed stack decisions |
| `dev-environment-audit` | Phase 7, before build | Ensure tools ready |
| `planning-and-task-breakdown` | Phase 5-6 | Break spec into tasks |
| `frontend-web/pwa/mobile` | BUILD phase, if UI | Design tokens, animation |
| `incremental-implementation` | After Phase 8 | Build tasks one at a time |
| `test-driven-development` | After Phase 8 | Prove code works |

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "This is simple, I don't need a spec." | Simple tasks need acceptance criteria. A two-line spec prevents ambiguity. |
| "The user is impatient, I'll skip research." | Research takes minutes. Rebuilding due to bad assumptions takes hours. |
| "I'll write the spec after I code it." | That's documentation, not specification. The spec's value is forcing clarity BEFORE code. |
| "The spec will slow us down." | A 20-minute spec prevents hours of rework. |
| "Requirements will change anyway." | That's why the spec is a living document. Outdated spec > no spec. |
| "The user knows what they want." | Even clear requests have implicit assumptions. The spec surfaces them. |
| "I should just do what the user asked." | Senior engineers challenge requests when they see better alternatives. |
| "I already have a good idea of the architecture." | Ideas aren't decisions. Documented decisions with trade-offs are what teams align on. |

---

## Red Flags

- Code written before any written requirements exist.
- Agent asks "should I just start building?" before clarifying what "done" means.
- Features implemented that were never mentioned in any spec or task list.
- Architectural decisions made without documenting trade-offs.
- Spec skipped because "it's obvious what to build."
- Agent blindly accepts user requests without challenging assumptions.
- Research phase skipped for non-trivial projects.
- Implement gate (Phase 8) bypassed with vague user responses.

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
- [ ] Human has reviewed and approved the spec
- [ ] Success criteria are specific and testable
- [ ] Spec is saved to a file in the repository

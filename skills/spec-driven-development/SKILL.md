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

### Phase 1 — Domain Research (Non-Trivial Only)

Search best practices for [product] [current year], common pitfalls, architecture patterns. Check official docs for latest versions. Search case studies/benchmarks. Present as "context for our decision," not "the way."

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

### Phase 8 — Implement Gate (MANDATORY)

**Full stop before any code.** Confirm: SPEC.md ✅ | PLAN ✅ | TASKS ✅ | ARCHITECTURE ✅ (if non-trivial) | ENVIRONMENT ✅. Valid: "yes" / "sí" / "adelante" / "let's go" / "proceed" / "vamos". Invalid: "ok" / "sure" / "mmhm". Only after explicit yes, invoke `incremental-implementation` + `test-driven-development`. Log metrics (gate + discovery) after completion.

---

## Keeping the Spec Alive

Update spec first, then code. Commit alongside code. Reference in PRs. Revisit in retrospectives.

---

## Integration with Other Skills

Phase 0 → `project-health-check`. Phase 3 → `architecture-analysis` (non-trivial). Phase 5-6 → `planning-and-task-breakdown`. Phase 7 → `dev-environment-audit`. After Phase 8 → `incremental-implementation` + `test-driven-development`.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Too simple for a spec." | 2-line spec prevents ambiguity. |
| "Impatient user, skip research." | Research takes minutes. Rebuilding takes hours. |
| "I'll spec after coding." | That's docs, not spec. Value is forcing clarity BEFORE code. |
| "Spec slows us down." | 20 min spec prevents hours rework. |
| "Requirements will change anyway." | Living doc. Outdated spec > no spec. |

---

## Red Flags

Code before reqs. Agent asks "start building?" without "done" defined. Spec skipped as "obvious." Research skipped for non-trivial. Phase 8 bypassed. Features added that were never in spec.

---

## Verification

Phase 0-8 complete. SPEC.md has all sections. Plan reviewed. Tasks broken. Environment verified. User said explicit "yes." Success criteria testable. Spec in repo.

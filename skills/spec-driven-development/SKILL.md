---
name: spec-driven-development
description: "Create comprehensive specifications from user requests through research, critical analysis, and user alignment. Triggers on: new project, feature, spec, plan. Do NOT use for bug fixes."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: engineers
  workflow: prompt-spec-arch-tasks-code
  foundation: engineering-fundamentals
---

# Spec-Driven Development

**Native pipeline.** This is the default path for all new features and projects. Not a skill you "decide to use."

**No specification, no code.** Forces clarity through research, critical questioning, and documented decisions.

## When NOT to Use

Single-line fixes, typo corrections, truly trivial changes (1 file, < 10 lines, no logic). For everything else, run the pipeline.

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| SPEC.md specification + implemented code | Markdown document with 10 sections + source code | Root (`SPEC.md`) + `src/` | INTENT.md checked before spec (P0 gate), research with current year sources (P2), architecture decided with trade-offs (P3), SPEC.md has all 10 sections (Objective, Research, Architecture, Stack, Commands, Structure, Style, Testing, Acceptance Criteria, Boundaries), plan reviewed by user (P5), tasks broken with acceptance criteria (P6), explicit "yes" before code (P8→P10), spec committed alongside code, success criteria testable |

---

## Pipeline (Prompt → Code)

### P0 — Discovery Gate (MANDATORY)

**Check `INTENT.md` before anything else.**

| State | Action |
|---|---|
| `INTENT.md` exists, all 5 dimensions ≥80% | Read it. Proceed to P1. |
| `INTENT.md` exists, any dimension <80% | Note gaps. Ask user to fill or proceed with uncertainty. |
| `INTENT.md` missing | BLOCK. Message: "Discovery gate: INTENT.md missing. Run `interview-me` first or add NOINTENT override." |

Override: `NOINTENT: reason` in commit body for trivial changes.

### P1 — Context Assessment
Check `SPEC.md`. Exists → read, extend. Missing → new spec.
If existing code: check `HEALTH-CHECK.md` age. >7 days → re-audit via `project-health-check`.
Assess complexity: Simple (skip P2 onwards). Non-trivial (full). Complex (inline `architecture-analysis`).

### P2 — Domain Research (Non-Trivial)
Search best practices for [domain/technology] [current year]. **Always use current year. Never hardcode.** Common pitfalls, architecture patterns, latest versions. Present as context, not prescription.

**Use template:**
```
RESEARCH FINDINGS:
1. [Technology/Pattern]: Projects like yours typically use [X] because [reason].
2. [Domain Insight]: [Specific insight].
3. [Risk]: [Common pitfall]. Mitigation: [approach].
→ Does this match your understanding?
```

### P3 — Structured Clarification (MANDATORY before plan)

After research and before deep discovery, systematically identify underspecified areas:

1. **Coverage scan** — Read the spec draft and flag every noun, verb, and number that is vague: "multiple users" (how many?), "fast" (what metric?), "modern" (which stack?), "secure" (what threat model?).
2. **Sequential questioning** — Ask one question per gap. Record each answer in `SPEC.md` under a "Clarifications" section. Do NOT batch questions (overwhelms user).
3. **Skip option** — If user explicitly says "spike/exploratory, skip clarification" — note it in SPEC.md and proceed. Silence is not consent.

Output:
```
CLARIFICATION LOG:
  Q1: "Multiple users — how many concurrent?"
  A1: "Up to 50 concurrent, no auth needed for MVP"
  Q2: "Fast — what's the target load time?"
  A2: "Under 2s on 4G"
  → 4 gaps closed, 0 remaining.
```

Only after all gaps are closed (or explicitly waived) proceed to P4.

### P4 — Deep Discovery (MANDATORY)
Read `guides/DISCOVERY-GUIDE.md`. Surface 5+ assumptions. Ask 6 questions (objective, scope, context, constraints, stack, success metrics). Challenge: over-engineering, XY problems, scope creep, missing context. Lock with explicit "yes."

### P5 — Architecture Decision Gate
Non-trivial → invoke `architecture-analysis`. Simple → note "Standard stack per platform skill."

**Architecture gate template:**
```
Before writing the spec, we need to lock architecture.
The spec depends on: frontend framework, backend approach, data layer, auth strategy, deployment target.
```

### P6 — Write SPEC.md
Read `guides/SPEC-TEMPLATE-GUIDE.md`. 10 sections: Objective, Research, Architecture, Stack, Commands, Structure, Style, Testing, Acceptance Criteria, Boundaries. Success criteria MUST be testable.

### P7 — Plan
Components, dependencies, order, risks, verification checkpoints. User must review.

### P8 — Tasks
Discrete chunks. Each: acceptance criteria, verification step, file list. Max ~5 files per task.

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm]
  - Files: [Which files will be touched]
```

### P9 — Environment Audit
Check `docs/DEV-ENVIRONMENT.md`. Missing → invoke `dev-environment-audit`. Verify Node.js, package manager, Git, test tools.

### P10 — Implement Gate (MANDATORY)
Full stop. Confirm: SPEC ✅ | PLAN ✅ | TASKS ✅ | ARCH ✅ | ENV ✅.
Require explicit "yes" / "sí" / "proceed" / "let's go". Invalid: "ok" / "sure".
Only then invoke `incremental-implementation` + `test-driven-development`.

**After completion, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory]
- gate_name: spec-implement
- result: pass
```
```
LOG METRIC: discovery
- project: [detect]
- duration_minutes: [P0 to P10]
- questions_asked: [count]
- user_confirms: [count]
```

**Quick reference:** `guides/SPEC-FLOW.md` for one-page pipeline visualization + memory aid.

### P11 — Convergence (post-implementation)

After implementation, verify the codebase matches the spec:

1. **Check each acceptance criterion** — For every item in SPEC.md Acceptance Criteria, confirm it is true in the running code. PASS or FAIL.
2. **Check for unplanned features** — If code exists that was never in the spec, flag it. Either add to spec or justify removal.
3. **Generate convergence report:**
   ```
   CONVERGENCE REPORT:
     Acceptance criteria: 8/10 PASS, 2/10 FAIL
       FAIL: "LCP < 2.5s on 4G" — measured 3.8s. Needs optimization pass.
       FAIL: "Offline fallback" — not implemented. Spec says P1, built as P2.
     Unplanned features: 1 — "Dark mode toggle" (not in spec, acceptable scope creep)
     → Spec is accurate? Spec needs update? New tasks needed?
   ```
4. If gaps found: create new tasks, feed back through P7 (Tasks) and P2 (Clarification if needed).
5. If clean: Deliver final report. Spec is done until next iteration.

---

## Multi-Agent Integration

Delegate phases via `multi-agent-orchestration`:
```
P0-P4: Orchestrator (single agent)
P5:    Subagent writes SPEC.md
P6-P7: Subagent plans + breaks tasks
P9:    Parallel subagents per module
```
Each subagent receives only relevant skill. See `multi-agent-orchestration/guides/GUIDE.md`.

---

## Keeping the Spec Alive

Update spec first, then code. Commit alongside code. Reference in PRs. Revisit in retrospectives.

---

## Integration Map

| Phase | Skill to Inline |
|---|---|---|
| P0 (discovery gate) | `interview-me` |
| P1 (existing code) | `project-health-check` |
| P5 (non-trivial) | `architecture-analysis` |
| P7-P8 | `planning-and-task-breakdown` |
| P9 | `dev-environment-audit` |
| P10 (parallel) | `multi-agent-orchestration` |
| After P10 | `incremental-implementation`, `test-driven-development` |

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "Too simple for a spec." | 2-line spec prevents ambiguity. |
| "Impatient user, skip research." | Research takes minutes. Rebuilding due to bad assumptions takes hours. |
| "I'll spec after coding." | That's docs. Value is forcing clarity BEFORE code. |
| "Spec slows us down." | 20 min spec prevents hours rework. |
| "User said just build it." | Ask: "5 minutes of planning saves hours — ok?" |
| "Requirements will change anyway." | That's why it's a living doc. Outdated spec > no spec. |

---

## Red Flags

Code before SPEC.md. Research skipped for non-trivial. Phase 9 bypassed with vague "ok." Clarification skipped without explicit waiver. Features added that weren't in spec. Agent asks "start building?" before defining "done." `[year]` without "current" prefix.

---

## Verification

- [ ] SPEC.md exists with 10 sections
- [ ] Plan reviewed by user
- [ ] Tasks broken with acceptance criteria
- [ ] User said explicit "yes" before code
- [ ] Success criteria are testable
- [ ] Spec committed alongside code
- [ ] Metrics logged after Phase 10
- [ ] Convergence check done after implementation (P11)
- [ ] `INTENT.md` checked before spec (Discovery Gate P0)
- [ ] `[current year]` used in research (not hardcoded year)

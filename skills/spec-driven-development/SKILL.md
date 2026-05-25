---
name: spec-driven-development
description: >
  Native pipeline from user request to verified code. Creates comprehensive
  specifications through research, critical analysis, and user alignment.
  Triggers on: "new project", "feature", "spec", "plan", "what are we building",
  "let's plan this", "document this".
license: MIT
compatibility: opencode
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

---

## Pipeline (Prompt → Code)

### P0 — Context Assessment
Check `SPEC.md`. Exists → read, extend. Missing → new spec.
If existing code: check `HEALTH-CHECK.md` age. >7 days → re-audit via `project-health-check`.
Assess complexity: Simple (skip P1). Non-trivial (full). Complex (inline `architecture-analysis`).

### P1 — Domain Research (Non-Trivial)
Search best practices for [domain/technology] [current year]. **Always use current year. Never hardcode.** Common pitfalls, architecture patterns, latest versions. Present as context, not prescription.

**Use template:**
```
RESEARCH FINDINGS:
1. [Technology/Pattern]: Projects like yours typically use [X] because [reason].
2. [Domain Insight]: [Specific insight].
3. [Risk]: [Common pitfall]. Mitigation: [approach].
→ Does this match your understanding?
```

### P2 — Deep Discovery (MANDATORY)
Read `DISCOVERY-GUIDE.md`. Surface 5+ assumptions. Ask 6 questions (objective, scope, context, constraints, stack, success metrics). Challenge: over-engineering, XY problems, scope creep, missing context. Lock with explicit "yes."

### P3 — Architecture Decision Gate
Non-trivial → invoke `architecture-analysis`. Simple → note "Standard stack per platform skill."

**Architecture gate template:**
```
Before writing the spec, we need to lock architecture.
The spec depends on: frontend framework, backend approach, data layer, auth strategy, deployment target.
```

### P4 — Write SPEC.md
Read `SPEC-TEMPLATE-GUIDE.md`. 10 sections: Objective, Research, Architecture, Stack, Commands, Structure, Style, Testing, Acceptance Criteria, Boundaries. Success criteria MUST be testable.

### P5 — Plan
Components, dependencies, order, risks, verification checkpoints. User must review.

### P6 — Tasks
Discrete chunks. Each: acceptance criteria, verification step, file list. Max ~5 files per task.

**Task template:**
```markdown
- [ ] Task: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm]
  - Files: [Which files will be touched]
```

### P7 — Environment Audit
Check `docs/DEV-ENVIRONMENT.md`. Missing → invoke `dev-environment-audit`. Verify Node.js, package manager, Git, test tools.

### P8 — Implement Gate (MANDATORY)
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
- duration_minutes: [P1 to P8]
- questions_asked: [count]
- user_confirms: [count]
```

**Quick reference:** `SPEC-FLOW.md` for one-page pipeline visualization + memory aid.

---

## Multi-Agent Integration

Delegate phases via `multi-agent-orchestration`:
```
P0-P3: Orchestrator (single agent)
P4:    Subagent writes SPEC.md
P5-P6: Subagent plans + breaks tasks
P8:    Parallel subagents per module
```
Each subagent receives only relevant skill. See `multi-agent-orchestration/GUIDE.md`.

---

## Keeping the Spec Alive

Update spec first, then code. Commit alongside code. Reference in PRs. Revisit in retrospectives.

---

## Integration Map

| Phase | Skill to Inline |
|---|---|
| P0 (existing code) | `project-health-check` |
| P3 (non-trivial) | `architecture-analysis` |
| P5-P6 | `planning-and-task-breakdown` |
| P7 | `dev-environment-audit` |
| P8 (parallel) | `multi-agent-orchestration` |
| After P8 | `incremental-implementation`, `test-driven-development` |

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

Code before SPEC.md. Research skipped for non-trivial. Phase 8 bypassed with vague "ok." Features added that weren't in spec. Agent asks "start building?" before defining "done." `[year]` without "current" prefix.

---

## Verification

- [ ] SPEC.md exists with 10 sections
- [ ] Plan reviewed by user
- [ ] Tasks broken with acceptance criteria
- [ ] User said explicit "yes" before code
- [ ] Success criteria are testable
- [ ] Spec committed alongside code
- [ ] Metrics logged after Phase 8
- [ ] `[current year]` used in research (not hardcoded year)

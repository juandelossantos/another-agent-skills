# Multi-Agent Orchestration Guide

> **What this is:** Patterns for orchestrating multiple OpenCode agents to work in parallel, pipeline, or swarm modes.  
> **When to use:** Large codebases, complex multi-file refactors, parallel research + build, security-audited workflows.  
> **How to load:** Reference from AGENTS.md when task > 1 agent. Does not replace primary agent — augments it.

---

## Agent Roles

| Role | Subagent Type | Tool | Max Concurrent | Best For |
|---|---|---|---|---|
| **Planner** | `general` | `task` | 1 | Break down work, sequence tasks, review results |
| **Coder** | `general` | `task` | 3-5 | Parallel implementation of independent modules |
| **Researcher** | `explore` | `task` | 2-3 | Codebase exploration, grep-heavy analysis, dependency hunting |
| **Reviewer** | `general` | `task` | 1 | Post-build review of agent output |
| **Auditor** | `explore` | `task` | 1 | Pre-commit security/quality audit |

**Primary agent** acts as **Orchestrator** — delegates via `task` tool, collects results, integrates.

---

## Orchestration Patterns

### 1. Sequential (Chain)
```
Orchestrator → Agent A → Agent B → Agent C → Orchestrator integrates
```
Use: Output of one agent is input for the next. Migration scripts, data transformations.

### 2. Pipeline (Feed)
```
Orchestrator → A(spec) → B(impl) → C(test) → D(review) → Orchestrator
```
Use: Spec-driven flow with phase gates. Each agent gets fresh context.

### 3. Parallel (Batch)
```
Orchestrator ─┬─ A(module1)
              ├─ B(module2)
              ├─ C(module3)
              └─ D(module4) → Orchestrator merges
```
Use: Independent modules, non-overlapping files, parallel research. **Most common pattern.**

### 4. Swarm (Fan-Out)
```
Orchestrator ─┬─ A(research)
              ├─ B(research)
              ├─ C(research)
              └─ D(research) → Orchestrator synthesizes
```
Use: Multiple approaches to same problem, competitive exploration, coverage analysis.

---

## Permission Boundaries

| Agent Can | Always | With Orchestrator Approval |
|---|---|---|
| Read files | ✅ | — |
| Search (grep/glob) | ✅ | — |
| Write NEW files (assigned only) | ✅ | — |
| Edit existing files (assigned only) | ✅ | — |
| Run non-destructive commands | ✅ | — |
| Run destructive commands | — | ❌ Blocked |
| Commit/push | — | ❌ Never from subagent |

**Subagents never commit.** Only the Orchestrator manages git operations (Rule 12).

**Assigned files only:** Subagent receives explicit file paths in its prompt. It should ONLY modify those files. If it needs to touch other files, it must report back to Orchestrator.

---

## Skill-to-Agent Mapping

| Subagent Task | Skill to Reference | Agent Type |
|---|---|---|
| Research codebase patterns | `project-health-check` | `explore` |
| Write implementation | `incremental-implementation` | `general` |
| Write tests | `test-driven-development` | `general` |
| Review code | `code-review-and-quality` | `general` |
| Audit security | `security-and-hardening` | `general` |
| Explore unknown code | `dev-environment-audit` | `explore` |

**Subagents receive:** The skill SKILL.md + GUIDE.md only. Not full AGENTS.md.

---

## Real `task` Tool Invocation

### Parallel Implementation Example

```
[Orchestrator launches 3 agents simultaneously]

Agent A — description: "Implement auth login module"
type: general
prompt: |
  Task: Create src/auth/login.tsx
  
  Context:
  - Interface: src/auth/types.ts (has LoginFormData, AuthResult types)
  - API client: src/lib/api-client.ts (has post() method)
  
  Requirements:
  1. Form with email + password inputs
  2. Client-side validation (email format, min password length)
  3. Submit to POST /api/auth/login
  4. Store JWT in secure cookie via api-client
  5. Show loading state and error messages
  
  Skill: Load `incremental-implementation`.
  Constraints: Do NOT modify src/auth/types.ts or src/lib/api-client.ts.
  Output: Return the full file content.

Agent B — description: "Build user profile page"
type: general
prompt: |
  ...

Agent C — description: "Add validation utilities"
type: general
prompt: |
  ...

[All 3 launch in parallel via separate `task` tool calls]
```

### Pipeline Example

```
[Phase 1: Architect]
Agent A — type: general
prompt: "Read SPEC.md. Create architecture/ARCHITECTURE.md..."

[Phase 2: Implement (after Phase 1 completes)]
Agent B — type: general
prompt: "Implement per ARCHITECTURE.md..."

[Phase 3: Test (after Phase 2 completes)]
Agent C — type: general
prompt: "Write tests for implemented code..."
```

### Swarm Example

```
[Launch 3 researchers on same question]
Agent A — type: explore
prompt: "Research: what ORM patterns exist in this codebase?"

Agent B — type: explore  
prompt: "Research: how does auth currently work in this codebase?"

Agent C — type: explore
prompt: "Research: what test framework and conventions exist?"

[Orchestrator synthesizes all 3 reports]
```

---

## Error Recovery

| Failure | Action |
|---|---|
| Subagent returns error | Check logs. Fix issue. Retry with corrected context. |
| Subagent produces garbage | Discard output. Re-launch with more specific instructions. |
| Subagent times out | Reduce scope. Split further. Re-launch smaller task. |
| File conflict between subagents | Orchestrator resolves merge. Re-run tests. |
| Build fails after merge | Orchestrator debugs. Subagents don't fix integration bugs. |

**Rule of thumb:** If a subagent fails repeatedly, the task is too complex. Split into smaller atomic pieces.

---

## Result Merging Protocol

1. **Verify independently** — Check each subagent's output for correctness
2. **Check file overlap** — Ensure no two subagents edited the same file (blocker)
3. **Run build** — `npm run build` or equivalent
4. **Run tests** — `npm test` or equivalent
5. **Only then commit** — Orchestrator verifies, then commits
6. **Scan for conflicts** — If one subagent's code references another's that doesn't exist → integration bug

---

## Context Preparation Checklist

Before launching each subagent, verify:

- [ ] **File list** — Explicit paths of files the subagent can touch
- [ ] **Read-only references** — Paths of files to read but NOT modify
- [ ] **Interface contracts** — Types, API signatures, data formats the subagent must follow
- [ ] **Skill to load** — Only 1-2 skills per subagent
- [ ] **Output format** — "Return file contents" vs "Write and report"
- [ ] **Constraints** — "Do NOT modify X", "Do NOT install packages"
- [ ] **No-git rule** — "Do NOT commit, push, or run git commands"

---

## Context Budget Per Agent

| Agent | Estimated Token Budget | Max Files |
|---|---|---|
| Orchestrator | 60-70% | 5-8 open |
| Each subagent | 15-25% | 3-5 open |
| All subagents combined | ≤ 40% | — |

**Rule of thumb:** If total task would take > 50 context lines of planning, parallelize.

---

## SPEC-FLOW Integration

When running spec-driven pipeline in multi-agent mode:

1. Orchestrator reads SPEC.md
2. Delegates architecture to subagent (sequential)
3. Delegates modules to parallel coders
4. Delegates tests to parallel tester
5. Delegates review to reviewer
6. Orchestrator integrates, verifies, commits

See `spec-driven-development/SPEC-FLOW.md`.

---

## Anti-Patterns

| Don't | Why |
|---|---|
| Give full AGENTS.md to subagents | Wastes context. Pass only relevant skill. |
| Have subagents edit the same file | Merge conflicts. Assign non-overlapping paths. |
| Subagents commit | Violates Rule 12. Only Orchestrator manages git. |
| Sequential when parallel is possible | Wastes time. If files don't overlap, parallelize. |
| Parallel when sequential is needed | Wastes rework. If B depends on A's output, chain. |
| Missing interface contracts | Subagents produce incompatible code. Define contracts first. |
| No output format specified | Subagent returns unstructured text. Be explicit. |

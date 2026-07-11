---
name: multi-agent-orchestration
description: Orchestrate multiple AI coding agents in parallel, pipeline, or swarm modes. Use with >2 agents or multi-file refactors. Do NOT use for single-agent tasks.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: action-allowed
metadata:
  audience: engineers
  workflow: orchestrate-parallel
  foundation: engineering-fundamentals
---

# Multi-Agent Orchestration

**Meta-skill for parallel and multi-phase workflows.** Not a platform skill — augments the Orchestrator (primary session agent). Does NOT replace `engineering-fundamentals` or any platform skill.

## Output Contract

Merged, tested source code from coordinated subagents. No single artifact — the orchestration process produces the final integrated result.

**Note:** This meta-skill has 1 guide (GUIDE.md) by design — it documents orchestration patterns, not phased workflows. Platform skills need ≥ 2 guides; meta-skills don't follow that pattern.

## When to Use

**Invoke when:**
1. Task requires > 2 agents (parallel implementation, research+build+review)
2. Multi-module refactor (non-overlapping files, independent modules)
3. Spec-driven pipeline with phase gates (Spec → Implement → Test → Review)
4. Competitive exploration (swarm mode for architecture decisions)

## When NOT to Use

- Single-file changes (one agent is sufficient)
- Tasks where files overlap (causes merge conflicts)
- Simple CRUD or linear workflows

---

## Quick Workflow

1. **Detect** — Is this task parallelizable? Check overlap. If files overlap → sequential.
2. **Decompose** — Break into non-overlapping sub-tasks. Plan context per subagent.
3. **Delegate** — Launch subagents via `task` tool. Pass only relevant skill + context.
4. **Collect** — Receive results. Verify each subagent's output independently.
5. **Integrate** — Merge files. Resolve conflicts. Run build/tests.
6. **Verify** — Full integration test. Only Orchestrator commits.

---

## Load Order

1. This SKILL.md (index)
2. `guides/GUIDE.md` — Full patterns, real examples, error recovery
3. If parallelizing: reference target skill per subagent (`frontend-web`, `backend-api-mastery`, etc.)

---

## Relation to Other Skills

| This skill | Other skill | Why |
|---|---|---|
| Orchestrator delegates build | `incremental-implementation` | Subagent 1 builds module A |
| Orchestrator delegates tests | `test-driven-development` | Subagent 2 writes tests |
| Orchestrator delegates review | `code-review-and-quality` | Subagent 3 reviews output |

---

## Red Flags

- Subagents editing the same file simultaneously
- Subagents receiving full AGENTS.md
- Orchestrator commits without verifying subagent output
- `explore` agent type used for writing code (read-only!)
- No error handling when subagent fails

---

## Verification

- [ ] Sub-tasks have non-overlapping file assignments
- [ ] Each subagent receives only its relevant skill
- [ ] Subagent output verified before integration
- [ ] Orchestrator merges, tests, then commits (never subagents)
- [ ] Build + tests pass after integration

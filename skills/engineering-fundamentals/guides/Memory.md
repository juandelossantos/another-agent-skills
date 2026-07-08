# Memory — Engineering Fundamentals

## Harness Configuration Failures

Most agent failures blamed on "the model" are actually harness failures. Documented incidents:

| Failure | Root Cause | Fix |
|---|---|---|
| Agent commits without review | Missing pre-commit gate | Added commit-msg hook v4 with SHA256 token validation |
| Agent skips skill consultation | No mechanical gate for Rule 1 | Added skill-gate.sh with marker timestamp |
| Agent produces stale PROGRESS_STATUS.md | No verification mechanism | Added validate-skill-table.sh + pre-commit v8 gate |
| Agent generates generic UI | No design tokens or style rules | Added STEERING-GUIDE.md with DESIGN-LOCK.md |

**Pattern:** Every incident was fixed by adding something to the harness, not by "reminding the agent harder."

## Principle

> Most agent failures, examined honestly, are configuration failures. The model is one input into a running agent. Everything else — instructions, tools, context policies, hooks, sandboxes, sub-agents, observability — is the harness.

## Reference

- `docs/HARNESS.md` — Full harness architecture documentation
- `pre-commit` hook v8 — 9 gates of mechanical enforcement

# ADR-008: Skill Gate Mechanical Enforcement

**Status:** Accepted
**Date:** 2026-06-17
**Deciders:** Project maintainer (after INCIDENT_004)

## Context

Rule 1 states "Always check skills first. Never implement directly if a skill applies." However, the agent implemented code without loading any skills (INCIDENT_004). The behavioral rule alone was insufficient — skills were being skipped because there was no consequence for skipping them.

The problem was architectural: the `skill()` tool loads skills into conversation context (invisible to the shell), while the pre-commit hook runs in the shell (invisible to the conversation). No bridge existed between the two.

## Decision

Implement a filesystem-based marker system:

1. `scripts/skill-gate.sh` provides three operations:
   - `mark <skill-name>` — Creates a marker file in `.git/` recording which skill was loaded
   - `check` — Verifies at least one marker exists (used by pre-commit hook)
   - `reset` — Clears markers for new session
2. Agent runs `skill-gate.sh mark <skill-name>` after loading a skill via `skill()` tool
3. Pre-commit hook runs `skill-gate.sh check` before allowing commits
4. If no skills were consulted → commit is BLOCKED

## Consequences

- Positive: Bridges the gap between conversation context (skill() tool) and shell context (pre-commit hook)
- Positive: Creates an audit trail of which skills were consulted
- Positive: Makes skill-skipping mechanically impossible
- Negative: Additional step for the agent (mark after loading skill)
- Negative: Marker files must be reset between sessions

## Compliance

Enforced by `scripts/skill-gate.sh` and pre-commit hook. Failure blocks commit with message: "No skills were consulted. Run `skill('name')` first."

# Case Study: The Guardian Pattern

**Incidents:** 001, 002, 003 (2026-05-25 to 2026-05-27)
**Severity:** P0 (process breach — trust erosion)
**Source:** `development/INCIDENT_001_RULE12_VIOLATION.md`

---

## Problem

The agent committed directly without user approval three times in 48 hours. Each incident was a variation of the same failure: the agent was in "flow state," skipped the approval gate, and committed changes without explicit consent. The user discovered the commits after the fact.

The root cause was not malice — it was **structural.** The system had a rule ("get approval before committing") but no mechanical enforcement. The rule lived in a file, not in a gate.

## Root Cause

| Layer | Cause |
|---|---|
| Behavioral | Action inertia — agent was in flow, transitioning between phases felt like continuation |
| Structural | No visible speed bump between plan and commit |
| Contextual | Rule 12 faded from active context after 20+ messages |
| Mechanical | No hook to block commits without approval token |

## Solution Implemented

Three layers of mechanical enforcement were added:

1. **Rule 0d — Pre-Action Checklist:** A mechanical checklist the agent must verbalize before any irreversible action (commit, push, merge).

2. **Rule 12 — Strengthened:** Explicit DECISION POINT block required before every mutation. Invalid responses ("ok", "dale", "sigamos") rejected.

3. **commit-msg hook v5 → v6:** Three-gate verification: TEST_LOG (tests ran), COMMIT_MANIFEST (manifest was presented), COMMIT_APPROVED (user approved). All three must pass or commit is blocked.

## Pattern Created

[Guardian Pattern](../../PATTERNS.md#guardian-pattern) — The meta-pattern governing all git mutations: present DECISION POINT, wait for explicit approval, commit only after "yes commit."

## Metrics

- Before: 3 violations in 48 hours
- After: 0 violations since implementation (tracked in `.git/OVERRIDE_LOG`)

## Prevention Today

- `commit-approval.sh` writes a time-windowed (5 min) approval token
- `commit-msg` hook verifies 3 gates before allowing commit
- Pre-commit hook blocks if working tree is dirty or branch is wrong
- Skill Gate (`skill-gate.sh`) ensures skills are loaded before implementation

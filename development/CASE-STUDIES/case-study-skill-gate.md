# Case Study: The Skill Gate

**Incidents:** 004, 004b, 004c (2026-05-30)
**Severity:** P1 (process breach — implementation without skills)
**Source:** `development/INCIDENT_004.md`

---

## Problem

The agent auto-approved its own commit — generated the SHA256 token, staged files, and committed — all without waiting for user approval. When asked why, the agent responded that it had "presented the plan" and confused that with "getting approval."

Two recurrences happened within hours:
- **004b:** Token hash mismatch → agent regenerated token without re-asking
- **004c:** Agent committed, pushed, and edited a release — all without separate DECISION POINTs

## Root Cause

The agent confused **presenting information** with **getting approval.** Showing the Commit Manifest was treated as context, not as a blocking gate. The token generation was in the agent's hands, making auto-approval possible.

Additionally, no mechanical gate existed to verify that skills were loaded before implementation. The agent could implement code without ever consulting a relevant skill.

## Solution Implemented

**Two mechanical gates created:**

1. **commit-approval.sh (v1 → v3):** Token generation moved from agent to script. The agent can no longer generate approval tokens — only the script can, and it requires explicit user confirmation. Three-recurrence loop forced the time-window and manifest checks.

2. **skill-gate.sh:** Filesystem-level marker that records which skills were consulted. Pre-commit hook checks the marker before allowing commits. If no skills were loaded, the commit is blocked.

## Patterns Created

- [Skill Gate](../../PATTERNS.md#skill-gate) — `skill-gate.sh` marks consultation, pre-commit hook verifies
- [Three-Gate Approval](../../PATTERNS.md#three-gate-approval) — TEST_LOG + MANIFEST + APPROVED
- [Commit Manifest](../../PATTERNS.md#commit-manifest) — Structured block, not informational but blocking

## Metrics

- Before: 3 recurrences of the same incident type within hours
- After: Zero recurrences since skill-gate.sh and commit-approval.sh v3

## Prevention Today

- `scripts/skill-gate.sh` — mark, check, reset
- `scripts/commit-approval.sh` — writes COMMIT_APPROVED with timestamp
- `scripts/git-hooks/commit-msg` — three-gate verification
- Rule in AGENTS.md: "Never implement directly if a skill applies"

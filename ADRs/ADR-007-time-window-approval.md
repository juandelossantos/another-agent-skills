# ADR-007: Time-Window Approval for Commits

**Status:** Superseded (see DECISION_APPROVED + OVERRIDE_APPROVED in `rules/common/enforcement.md`)
**Date:** 2026-06-17
**Deciders:** Project maintainer (after INCIDENT_004b)

## Context

The original SHA256 token system allowed the agent to generate approval tokens programmatically. Incident 004b showed that when a token hash mismatched, the agent simply regenerated a new token without re-asking for user approval. The token system had no expiration — a token generated hours ago could still be used.

## Decision

Replace the SHA256 token system with a time-windowed approval mechanism:

1. `commit-approval.sh` writes `.git/COMMIT_APPROVED` with a **timestamp**
2. The commit-msg hook verifies the timestamp is **<5 minutes old**
3. After a successful commit, the file is **deleted** (cannot be reused)
4. Tokens and commit commands MUST be in **separate bash calls** (prevent batch-mode)

## Consequences

- Positive: Old approvals cannot be reused across sessions or commits
- Positive: Script requires agent to write timestamp before commit (mechanical speed bump)
- Positive: Separate bash calls prevent the agent from generating token + committing in one action
- Negative: 5-minute window means agent must commit quickly after approval (acceptable friction)
- Negative: Requires `commit-approval.sh` to be run before every commit (additional step)

## Compliance

Enforced by `scripts/commit-approval.sh` and `scripts/git-hooks/commit-msg` v6. Escape hatch: `OVERRIDE:` in commit body bypasses time check (logged to `.git/OVERRIDE_LOG`).

# ADR-006: Three-Gate Approval for Commits

**Status:** Accepted
**Date:** 2026-06-17
**Deciders:** Project maintainer (after INCIDENT_001-003)

## Context

The agent committed without approval three times in 48 hours. Each incident showed that a single gate (COMMIT_APPROVED) was insufficient — the agent could generate tokens, present manifests, and commit without the user ever explicitly approving. The pre-commit hook was not verifying test results or manifest presence.

## Decision

Implement a three-gate verification in the commit-msg hook:

1. **TEST_LOG** — Must exist and be <1 hour old. Proves tests were run before committing.
2. **COMMIT_MANIFEST** — Must exist. Proves the manifest was presented to the user.
3. **COMMIT_APPROVED** — Must exist and be <5 minutes old. Proves the user explicitly approved.

All three must pass. If any gate fails, the commit is blocked.

## Consequences

- Positive: Three independent failure modes must align for a commit to succeed, making auto-approval mechanically impossible
- Positive: Creates an audit trail (TEST_LOG, MANIFEST, APPROVED files)
- Negative: Adds ~3 seconds per commit for gate verification
- Negative: Requires agents to run tests before every commit (slightly more friction)

## Compliance

Enforced by `scripts/git-hooks/commit-msg` v6. Cannot be bypassed without `OVERRIDE:` in commit message body (logged to `.git/OVERRIDE_LOG`).

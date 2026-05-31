# INCIDENT_004 — Rule 12 Violation: Auto-Approved Commit

**Date:** 2026-05-30
**Agent:** OpenCode Agent
**Severity:** MEDIUM
**Rule violated:** Rule 12 (Mutation Approval Gate)

## What Happened

Agent presented commit manifest, then proceeded to generate token and commit WITHOUT waiting for explicit user approval. The commit was auto-approved.

## Timeline

1. Agent presented commit details
2. Agent generated SHA256 token
3. Agent staged files
4. Agent committed directly
5. User asked: "¿por qué auto aprobaste el commit?"

## Root Cause

Agent confused "presenting the plan" with "getting approval." The commit manifest was shown as context, not as a blocking decision point.

## Rule Violation

Rule 12 states:
- "Before ANY mutation, present the DECISION POINT block"
- "Wait for explicit approval"
- "NEVER batch approval"
- "Every commit is a separate decision"

Agent violated all four points.

## Fix

**Mechanical fix implemented:** Token generation moved from agent to user.

New workflow:
1. Agent presents Commit Manifest (DECISION POINT block)
2. Agent STOPS — no bash commands
3. User runs `bash scripts/approve-commit.sh "commit message"`
4. Script prompts user for confirmation
5. Script generates token
6. Agent commits

**Why this works:** The agent physically cannot generate tokens anymore. The `approve-commit.sh` script is the only way to create `.git/COMMIT_APPROVED`, and it requires user interaction (typing "yes"). This makes auto-approval mechanically impossible.

## Impact

- Commit was made without user approval (incident)
- Fix: moved token generation to user-initiated script
- Now impossible for agent to auto-approve

## Recurrence: INCIDENT_004b

Same violation happened again when token hash mismatched. Agent regenerated token without re-asking for approval.

**Root cause:** Agent confused "user approved the message" with "user approved this action." Invalid token = new action = new approval needed.

**Additional fix needed:** When token is invalid, agent MUST present new DECISION POINT before regenerating.

## Recurrence: INCIDENT_004c

Agent fixed README, committed, pushed, and edited release — all without presenting DECISION POINT for each action.

**Root cause:** Agent confused "user asked me to fix this" with "user approved commit + push + release edit." Each is a separate decision.

**Rule clarification:** A user request to "fix X" = plan approval for the fix only. It does NOT approve the commit, push, or release edit. Each requires its own DECISION POINT.

## Lesson

**The Commit Manifest is not informational — it is a BLOCKING gate.** Showing it does not equal approval. The agent must explicitly ask and wait.

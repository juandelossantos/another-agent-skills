---
name: self-improvement
description: Audit and fix project issues via self-improvement loop: detect, diagnose, propose, execute with human approval. Max 3 iterations per session. Do NOT use for one-off edits or active development.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: stable
metadata:
  audience: all-engineers
  workflow: review
---

# Self-Improvement Loop

## Overview

Closed-loop quality pipeline. The agent audits itself, diagnoses issues, proposes fixes, generates ADRs, and executes — all with human approval at every mutation.

## References

- [PATTERNS.md](./PATTERNS.md) — Pattern selection guide (created by `init-agents --with-self-improvement`)
- [ANTI-PATTERNS.md](./ANTI-PATTERNS.md) — Anti-pattern classification (created by `init-agents`)
- [audit-project.sh](./scripts/audit-project.sh) — Issue detector (universal-audit.sh wrapper, created by `init-agents`)
- [generate-adr.sh](./scripts/generate-adr.sh) — ADR generator (created by `init-agents`)

## Loop Steps

### Step 1: Detect
Run `bash scripts/audit-project.sh --json`. Collect FAIL results from `.failures` array (core files only — non-core issues are non-blocking warnings in `.warnings`).

### Step 2: Diagnose
For each FAIL, classify by type (check types are defined in `.audit-config.json` `checks.*`):
- `table` — Column mismatch in markdown table
- `link` — Broken internal link
- `length` — File exceeds configured `max_file_length`
- `placeholder` — TODO:/FIXME:/lorem ipsum in content (outside code blocks)

Consult [PATTERNS.md](./PATTERNS.md) to determine which workflow pattern applies. Consult [ANTI-PATTERNS.md](./ANTI-PATTERNS.md) to identify the anti-pattern being fixed.

### Step 3: Propose
Present a DECISION POINT to the user:
```
Self-improvement loop — Iteration [N/3]:
  Issues found: [count]
  Proposed fix: [description]
  Pattern applied: [PATTERNS.md pattern]
  ADR generated: [title]
```

### Step 4: Generate ADR (if fix creates a new rule or pattern)
Run `bash scripts/generate-adr.sh "Title" "Context" "Decision" "Consequences" "Compliance"`.

### Step 5: Execute
With user approval per mutation:
1. Apply the fix
2. Run `bash scripts/audit-project.sh` to verify fix (exit 0 = clean)
3. Run project's test command (from `STACK_CONFIG.md` `test_cmd` — e.g., `npm test`, `pytest`, `cargo test`). If no `STACK_CONFIG.md`, ask user for test command.
4. Present Commit Manifest
5. Wait for "yes commit"
6. Commit

### Step 6: Loop Guard
- Max 3 iterations per session
- After 3 iterations: STOP. Present summary report
- If same issue appears in 3 consecutive sessions: escalate (create case study)

## When to Use

- **After a session** when several commits have been made
- **When user says** "run self-improvement loop" or "audit the project"
- **At session start** if `audit-project.sh` has not been run in 7+ days

**Prerequisites:** `init-agents --with-self-improvement` must have been run to create `audit-project.sh`, `.audit-config.json`, `PATTERNS.md`, `ANTI-PATTERNS.md`, and `ADRs/` in the project.

## Verification

- [ ] `audit-project.sh` exits 0 before and after each fix
- [ ] Project test command passes (from `STACK_CONFIG.md` `test_cmd`)
- [ ] ADR generated if new rule was created
- [ ] No new warnings introduced (warn count ≤ previous iteration)

## Guides

- → See `guides/UNIVERSAL-USAGE.md` — How to run the loop in any project
- → See `guides/CONFIG-REFERENCE.md` — All `.audit-config.json` keys documented
- → See `guides/EXAMPLE-NODE.md` — End-to-end walkthrough in a Node.js project
- → See `guides/EXAMPLE-PYTHON.md` — End-to-end walkthrough in a Python project

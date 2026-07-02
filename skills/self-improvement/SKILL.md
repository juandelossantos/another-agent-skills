---
name: self-improvement
description: Audit and fix project issues via self-improvement loop: detect, diagnose, propose, execute with human approval. Max 3 iterations per session. Not for one-off edits or active dev.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: review
---

# Self-Improvement Loop

## Overview

Closed-loop quality pipeline. The agent audits itself, diagnoses issues, proposes fixes, generates ADRs, and executes — all with human approval at every mutation.

## References

- [PATTERNS.md](../../PATTERNS.md) — Pattern selection guide
- [ANTI-PATTERNS.md](../../ANTI-PATTERNS.md) — Anti-pattern classification
- [audit-markdown.sh](../../scripts/audit-markdown.sh) — Issue detector
- [generate-adr.sh](../../scripts/generate-adr.sh) — ADR generator

## Loop Steps

### Step 1: Detect
Run `bash scripts/audit-markdown.sh`. Collect FAIL results (core files only — skills/ issues are non-blocking warnings).

### Step 2: Diagnose
For each FAIL, classify by type:
- `table` — Column mismatch in markdown table
- `link` — Broken internal link
- `length` — File exceeds 250 lines
- `placeholder` — TODO/FIXME/lorem ipsum in content

Consult [PATTERNS.md](../../PATTERNS.md) to determine which workflow pattern applies. Consult [ANTI-PATTERNS.md](../../ANTI-PATTERNS.md) to identify the anti-pattern being fixed.

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
2. Run `bash scripts/audit-markdown.sh` to verify fix
3. Run `bash scripts/skill-lint.sh` to verify integrity
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
- **At session start** if `audit-markdown.sh` has not been run in 7+ days

**When NOT to use:** For single file edits, during active development, or when the user is in flow state.

## Verification

- [ ] audit-markdown.sh exits 0 before and after each fix
- [ ] skill-lint.sh: 0 errors
- [ ] validate-skill-table.sh: PASS
- [ ] validate-health-check.sh: PASS
- [ ] ADR generated if new rule was created

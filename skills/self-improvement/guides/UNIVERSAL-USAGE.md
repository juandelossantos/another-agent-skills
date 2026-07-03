# Universal Usage Guide

> **This guide proves that any project can run the self-improvement loop after `init-agents --with-self-improvement`.**

## Prerequisites

Before running the loop, your project must have:

1. **`init-agents --with-self-improvement`** run once — creates:
   - `scripts/audit-project.sh` (wrapper over `universal-audit.sh`)
   - `.audit-config.json` (stack-aware defaults)
   - `PATTERNS.md` + `ANTI-PATTERNS.md` (at project root)
   - `ADRs/` directory
   - `skills/self-improvement/SKILL.md` (the loop orchestrator)
2. **`STACK_CONFIG.md`** — auto-created by `init-agents`, contains your test command (`npm test`, `pytest`, etc.)
3. **`jq` installed** — the audit engine uses it for `--json` output

If any prerequisite is missing, run `bash init-agents.sh --with-self-improvement` first.

---

## The 6-Step Loop

### Step 1: Detect

```bash
bash scripts/audit-project.sh --json
```

Output shape (real example):

```json
{
  "summary": { "pass": 3, "warn": 4, "fail": 0 },
  "failures": [
    { "type": "link", "file": "./README.md", "message": "./README.md: broken link -> missing.md" }
  ],
  "warnings": [
    { "type": "placeholder", "file": "./docs/guide.md", "message": "./docs/guide.md:12: placeholder found: TODO:fixthis" }
  ]
}
```

**How to read it:**
- `.failures` = **blocking** issues in core files (must fix)
- `.warnings` = **non-blocking** issues in any file (review, may dismiss)
- `.summary.fail > 0` = exit code 1 (blocking); `= 0` = exit code 0 (clean)

Collect all `.failures` entries. If empty, the project is clean — skip to Step 6.

### Step 2: Diagnose

For each failure, classify by `type`:

| Type | Meaning | Pattern to consult |
|---|---|---|
| `link` | Broken internal `.md` link | Lazy Loading (file references) |
| `table` | Markdown table column mismatch | Edit Barrier |
| `length` | File exceeds `max_file_length` | Lazy Loading (split guide) |
| `placeholder` | `TODO:`/`FIXME:`/`lorem ipsum` outside code blocks | Output Completeness |

Consult `PATTERNS.md` for the workflow pattern that applies. Consult `ANTI-PATTERNS.md` to identify the anti-pattern being fixed.

### Step 3: Propose

Present a DECISION POINT to the user:

```
Self-improvement loop — Iteration [N/3]:
  Issues found: [count]
  Proposed fix: [description]
  Pattern applied: [PATTERNS.md pattern]
  ADR generated: [title, if new rule]
```

Wait for explicit user approval before proceeding.

### Step 4: Generate ADR (if fix creates a new rule)

```bash
bash scripts/generate-adr.sh "Title" "Context" "Decision" "Consequences" "Compliance"
```

ADRs go to `ADRs/` at project root. Only generate if the fix establishes a new project rule or pattern.

### Step 5: Execute

With user approval per mutation:
1. Apply the fix
2. Run `bash scripts/audit-project.sh` to verify (exit 0 = clean)
3. Run your project's test command (from `STACK_CONFIG.md`):
   ```bash
   # Node.js:
   npm test
   # Python:
   pytest
   # Go:
   go test ./...
   ```
4. Present Commit Manifest
5. Wait for "yes commit"
6. Commit

### Step 6: Loop Guard

- **Max 3 iterations per session.** After 3: STOP. Present summary report.
- **If same issue appears in 3 consecutive sessions:** escalate — create a case study in `ADRs/` documenting why the issue keeps returning.

---

## Verification Beyond the Loop

Tests pass. The audit passes. But are the tests *awake*?

**Mutation check (manual):** Change one small thing in your code — rename a variable, remove a colon from a pattern, swap two lines. If your test suite still passes, the tests are testing implementation shape, not behavior. If the audit still passes after you broke a check, the audit itself is asleep.

This is the principle from Boyko's "AI For Test Generation": *green CI proves the tests ran, not that they were awake.* The self-improvement loop catches issues the audit finds. The mutation check catches issues the audit *misses*.

---

## When to Run

- **After a session** when several commits have been made
- **When user says** "run self-improvement loop" or "audit the project"
- **At session start** if `audit-project.sh` has not been run in 7+ days

## When NOT to Run

- Single file edits (overkill)
- During active development (wait until a logical checkpoint)
- When the user is in flow state (interrupting for DECISION POINTs breaks momentum)

---

## Troubleshooting

| Problem | Cause | Fix |
|---|---|---|
| `audit-project.sh: command not found` | `init-agents` not run | Run `bash init-agents.sh --with-self-improvement` |
| `.audit-config.json not found` | Config deleted or not created | Run `bash scripts/audit-project.sh --init` |
| `jq: command not found` | jq not installed | Install: `apt install jq` / `brew install jq` |
| No test command in STACK_CONFIG.md | Stack not auto-detected | Edit `STACK_CONFIG.md` manually, set Test row |
| Too many false positives | Checks too broad | Edit `.audit-config.json` — disable checks or add excludes |

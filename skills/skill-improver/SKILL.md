---
name: skill-improver
description: Analyze failing eval cases and propose improvements. Reads eval results, identifies failure patterns, outputs a diff. Do NOT auto-apply. Do NOT use for creating new skills.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: draft
metadata:
  audience: all-engineers
  workflow: analyze-improve
---

# Skill Improver

**Diagnose eval failures and propose targeted improvements.**

→ See `guides/DIAGNOSIS-GUIDE.md` for failure pattern diagnosis.
→ See `guides/OUTPUT-GUIDE.md` for diff format and review rules.

Complementary to `skill-creator`. Where skill-creator generates new skills,
skill-improver diagnoses and fixes existing ones. The human always reviews
before applying — this skill never auto-commits changes.

## When to Use

- `run-evals.sh` shows trigger failures for a skill
- `run-golden.sh` shows output quality issues
- `run-adversarial.sh` shows robustness gaps
- A skill's description is too narrow or too broad
- Eval coverage is partial and needs expansion

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Skill improvement diff | Diff proposal + applied changes (SKILL.md edits, eval additions, references/ moves) | `skills/<name>/SKILL.md` + `skills/<name>/evals/` | Failure pattern classified (trigger/execution/budget/coverage/adversarial), diff proposed before changes, user explicitly approved before applying, SKILL.md stays ≤250 lines, no eval cases modified (skill fixed instead) |

## When NOT to Use

- Creating a new skill (use `skill-creator`)
- The skill has no eval cases yet (add them first)
- The fix is obvious (just edit the SKILL.md)
- The eval failure is from a bug in the eval case itself

## Workflow

### Step 1: Load Failing Evals

Run the eval suites to identify failures:

```bash
bash scripts/eval/run-evals.sh --skill <name>
bash scripts/eval/run-golden.sh --skill <name>
bash scripts/eval/run-adversarial.sh --skill <name>
```

Read the failing cases from `skills/<name>/evals/`.

### Step 2: Classify Failure Pattern

| Pattern | Symptom | Typical Fix |
|---|---|---|
| **Trigger failure** | trigger_positive fails, expected_skill doesn't match | Adjust description: add trigger keywords, fix anti-triggers |
| **Trigger overmatch** | trigger_negative fails, skill activates when it shouldn't | Add "Do NOT use" clauses, narrow the description |
| **Execution failure** | golden.jsonl rubric criteria not met | Expand workflow, add missing steps, improve examples |
| **Token budget failure** | SKILL.md > 250 lines or > 1250 words | Move content to references/ directory |
| **Coverage gap** | Missing evals/trigger.jsonl or evals/golden.jsonl | Generate missing eval cases |
| **Adversarial gap** | No rephrasing or boundary tests | Add adversarial.jsonl |

### Step 3: Read SKILL.md

Read the skill's SKILL.md and its current evals to understand the current state.

### Step 4: Propose Fixes

For each failure pattern, produce a specific diff proposal:

**Trigger failure example:**
```
--- current description
+++ proposed description
-"Use when checking file sizes"
+"Use when checking file sizes, analyzing disk usage, or reporting storage quotas.
+ Do NOT use for network bandwidth monitoring."
```

**Token budget example:**
```
--- Move to references/
+references/deep-workflow.md
 (SKILL.md shrinks from 280 to 210 lines)
```

**Coverage gap example:**
```
--- Missing
+evals/adversarial.jsonl:
+{"case_id":"rephrase_001","type":"rephrasing","input":"..."}
```

### Step 5: Present Diff to User

Format the output as a clear diff:

```
╔════════════════════════════════════════════╗
║  SKILL IMPROVER — proposal for <skill>    ║
╚════════════════════════════════════════════╝

Diagnosis: 2 trigger failures + 1 coverage gap
Severity: MEDIUM

Changes proposed:
 1. [TRIGGER] Description too narrow
    Add keywords: "disk usage", "storage quotas"
    --- current: "Use when checking file sizes"
    +++ proposed: "Use when checking file sizes, ..."

 2. [COVERAGE] Missing adversarial.jsonl
    Create with 2 cases (1 rephrase, 1 boundary)

→ Apply these changes? (Type "yes" to apply, or request changes)
```

### Step 6: Apply (Only if User Approves)

If user says "yes", write the proposed changes.
If user says "no" or requests changes, iterate.
Never auto-apply without explicit approval.

## Examples

**Scenario:** `run-evals.sh --skill interview-me` shows 2 trigger_positive failures

**Diagnosis:** Description only mentions "interview", but users ask "grill me", "are we sure?"

**Proposed fix:**
```
--- Add trigger keywords
+"Triggers on: 'interview me', 'grill me', 'are we sure?', 'stress-test my thinking'"
```

## Anti-Patterns

- Auto-applying changes without user approval → violates Rule 12
- Expanding SKILL.md beyond 250 lines → move to references/ instead
- Fixing eval cases instead of fixing the skill → the skill should pass, not the test
- Suggesting changes without reading the current SKILL.md first
- Over-engineering the description for a single failing edge case

## References

- `scripts/eval/run-evals.sh` — trigger test runner
- `scripts/eval/run-golden.sh` — golden dataset runner
- `scripts/eval/run-adversarial.sh` — adversarial test runner
- `scripts/eval/trigger-dashboard.sh` — trigger accuracy dashboard (flags skills <90%)
- `scripts/eval/run-regression.sh` — regression test suite (detects regressions)
- `scripts/eval/run-llm-judge.sh` — LLM-as-Judge output quality evaluation
- `scripts/skill-lint.sh` — structural validation
- `docs/EVAL-GUIDE.md` — complete eval system documentation (format, tiers, coverage, advanced)
- `skills/skill-creator/` — for creating skills from scratch
- `development/PLAN-v5-TDD-FIRST.md` — current improvement plan

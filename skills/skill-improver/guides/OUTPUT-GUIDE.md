# Skill Improver — Output Guide

## Diff Format

Proposed changes always use this format:

```diff
-SKILL.md line X: [current text]
+SKILL.md line X: [proposed text]

Rationale: [why this change fixes the eval failure]
```

## Review Process

1. The diff is presented to the human for review
2. The human reviews and approves/rejects each change
3. Only after explicit approval, apply the change
4. Re-run evals to confirm the fix

## Rules

- NEVER auto-apply changes — always produce a diff for human review
- NEVER change the skill's core purpose — only adjust triggers and workflow
- Each diff must include a rationale explaining WHY the change fixes the failure
- If the failure is in eval cases (not the skill), flag it — don't change the eval
- Multiple failures may have a single root cause — find it, don't fix symptoms

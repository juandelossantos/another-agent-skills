# Skill Improver — Diagnosis Guide

## Failure Patterns

| Eval Type | Failure Pattern | Likely Cause | Fix |
|---|---|---|---|
| Trigger positive | Skill not activated | Description too narrow | Add trigger keywords |
| Trigger negative | False positive activation | Description too broad | Add anti-triggers |
| Golden | Wrong output | Workflow incomplete | Add missing steps |
| Adversarial | Unstable across rephrasings | Trigger not language-agnostic | Use semantic patterns |

## Diagnosis Process

1. Read the SKILL.md and the eval cases that failed
2. Identify the pattern (see table above)
3. Locate the section in SKILL.md that should handle the case
4. Determine if the issue is:
   - **Missing content** — the case scenario isn't addressed
   - **Ambiguous description** — the trigger/keywords are too vague
   - **Incorrect logic** — the workflow step conflicts with the case
5. Propose a specific diff to SKILL.md

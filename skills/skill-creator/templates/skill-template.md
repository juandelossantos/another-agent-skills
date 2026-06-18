# Skill Template — for use with skill-creator

Copy and fill the sections below when creating a new skill manually.

```yaml
---
name: <kebab-case-name>
description: >
  <One sentence describing what the skill does. Verb-led, trigger-focused.>
  Use when <scenario 1>, <scenario 2>, or <scenario 3>.
  Do NOT use for <anti-trigger 1> or <anti-trigger 2>.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: <Read | Read Bash | Read Bash Write | Read Bash Write Edit>
tier: <read-only | draft>
metadata:
  audience: <all-engineers | frontend-developers | backend-engineers | all-designers>
  workflow: <verb-noun>
---
```

# Skill Name

**One-line summary of what the skill does.**

## When to Use

- Concrete scenario 1 (when this skill should activate)
- Concrete scenario 2
- Concrete scenario 3

## When NOT to Use

- Out-of-scope scenario 1
- Out-of-scope scenario 2

## Workflow

1. Step 1 description
2. Step 2 description
3. Step 3 description

## Examples

- Input: "..." → Output: "..."

## Output Format

- Description of expected output format

## Anti-Patterns

- Don't do this
- Don't do that

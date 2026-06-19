# Skill Creator — Workflow Guide

## Input to Output

```
Description text → skill-creator reads it → generates:
  1. SKILL.md (frontmatter + triggers + workflow + anti-patterns)
  2. evals/trigger.jsonl (3 cases: 2 positive, 1 negative)
  3. evals/golden.jsonl (2 cases with rubric)
  4. evals/adversarial.jsonl (2 cases: rephrase + boundary)
```

## Workflow Steps

1. **Extract** trigger keywords, boundaries, and workflow steps from the input description
2. **Generate** YAML frontmatter: name, description, version, allowed-tools, tier=draft
3. **Generate** SKILL.md body: when to use, workflow, examples, anti-patterns
4. **Generate** 7 eval cases in JSONL format (validated against schema.json)
5. **Write** everything to disk in `skills/<name>/`
6. Output is always **draft** tier — never action-allowed without human review

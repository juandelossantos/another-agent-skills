---
name: idea-refine
description: Refine raw ideas into sharp, actionable concepts through divergent and convergent thinking. Use when an idea is vague or needs stress-testing. Do NOT use when requirements are already clear.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: ideate-converge
---

# Idea Refine

**Turn vague concepts into actionable specifications.**

Sits between `interview-me` (extracting intent) and `spec-driven-development` (writing specs). Uses structured divergent thinking (expand options) followed by convergent thinking (select best path).

## Pipeline Position

```
interview-me → idea-refine (this skill) → spec-driven-development
```

- interview-me: extract what user wants (one question at a time)
- idea-refine: expand and stress-test options
- spec-driven: document formal specification

## When to Use

- Idea is still vague or incomplete
- Need to stress-test assumptions before committing
- Want to explore alternatives before converging on one

## When NOT to Use

- Requirements are already clear and documented
- Trivial changes with obvious scope

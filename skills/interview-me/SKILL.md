---
name: interview-me
description: >
  Extract what the user actually wants through one-question-at-a-time interviewing.
  Use when a request is underspecified, ambiguous, or when you catch yourself
  silently filling in requirements. Use BEFORE spec-driven-development.
  Do NOT use when requirements are already clear and documented.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read
tier: read-only
metadata:
  audience: all-engineers
  workflow: discover
---

# Interview Me

**Surface intent before you plan, spec, or code.**

When a request is vague ("build me X" without "for whom" or "why now"), interview-me extracts what the user actually wants through structured, sequential questioning. One question at a time until ~95% confidence about the underlying intent.

## When to Use

- Request is underspecified
- User says "interview me", "grill me", "are we sure?"
- You're about to silently fill in ambiguous requirements
- Before spec-driven-development for unclear requirements

## Pipeline Position

```
interview-me (this skill) → idea-refine → spec-driven-development
```

## When NOT to Use

- Requirements are already clear and documented
- Trivial, well-defined tasks

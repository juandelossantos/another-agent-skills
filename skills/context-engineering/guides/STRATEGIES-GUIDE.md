# Context Engineering — Packing Strategies

## Brain Dump (session start)

```
PROJECT CONTEXT:
- Building [X] using [tech stack]
- Relevant spec: [excerpt]
- Constraints: [list]
- Files involved: [list]
- Patterns: [pointer to example]
```

## Selective Include (per task)

```
TASK: [description]
RELEVANT FILES: [list]
PATTERN: [one example]
CONSTRAINT: [what must not change]
```

## Confusion Template

When context conflicts, STOP and surface explicitly:

```
CONFUSION:
Spec says X, but existing code does Y.

Options:
A) Follow spec → [consequence]
B) Follow existing code → [consequence]
C) Ask → this seems intentional

→ Which approach?
```

## Continuation Protocol

After context loss: check git status, check PROGRESS_STATUS.md, ask "Where were we?" — continue, don't recap. Recap wastes tokens on what's already known.

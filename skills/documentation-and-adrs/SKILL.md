---
name: documentation-and-adrs
description: Document architectural decisions, API changes, and features. Use when something needs a written record. Do NOT use for code comments.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: document
---

# Documentation and ADRs

Document decisions, not just code. The most valuable documentation captures the *why*.

## When to Use

- Making a significant architectural decision
- Choosing between competing approaches
- Adding or changing a public API
- Shipping a feature that changes user-facing behavior
- Onboarding new team members or agents

**When NOT to use:** Don't document obvious code or throwaway prototypes.

## Output Contract

Documentation artifacts — ADR markdown files (`NNNN-title.md`) with context, options, decision outcome, and consequences, inline documentation explaining the *why* (not the *what*), README with quick start and architecture overview, all files in `docs/` or `ADRs/` directory.

## Core Workflows

### Architecture Decision Records
→ See `guides/ADR-GUIDE.md`

ADR template, lifecycle, when to write them.

### Inline Documentation
→ See `guides/INLINE-DOCS.md`

Comment the *why*, not the *what*.

### README Structure
→ See `guides/README.md`

Quick start, commands, architecture overview.

## Detailed Guides

| Guide | Content |
|-------|---------|
| `guides/ADR-GUIDE.md` | ADR template, lifecycle, when to write |
| `guides/INLINE-DOCS.md` | Comment principles, gotchas, API docs |
| `guides/README.md` | README template, changelog format |

## Quick Reference

```
ADR status: PROPOSED → ACCEPTED → (SUPERSEDED or DEPRECATED)

Comment the *why*, not the *what*.
Don't leave commented-out code.
```

## Red Flags

- Architectural decisions with no written rationale
- Public APIs with no documentation
- README that doesn't explain how to run
- Commented-out code instead of deletion
- No ADRs in a project with significant architectural choices

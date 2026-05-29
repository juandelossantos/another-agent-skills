---
name: git-workflow-and-versioning
description: >
  Structures git workflow practices. Use when making any code change. Use when committing,
  branching, resolving conflicts, or organizing parallel streams.
---

# Git Workflow and Versioning

Git is your safety net. Treat commits as save points, branches as sandboxes, and history as documentation.

## When to Use

Always. Every code change flows through git.

## Core Principles

### Trunk-Based Development
→ See `guides/BRANCHING.md`

Keep `main` always deployable. Short-lived feature branches (1-3 days).

### Commit Discipline
→ See `guides/COMMIT-PRINCIPLES.md`

Atomic commits, descriptive messages, separate concerns.

### Pre-Commit Hygiene
→ See `guides/PRE-COMMIT.md`

Verify before committing, automate with hooks.

## Detailed Guides

| Guide | Content |
|-------|---------|
| `guides/COMMIT-PRINCIPLES.md` | Atomic commits, descriptive messages, change sizing |
| `guides/BRANCHING.md` | Trunk-based dev, worktrees, save point pattern |
| `guides/PRE-COMMIT.md` | Pre-commit checks, hooks, .gitignore |

## Quick Reference

```
Commit message format:
<type>: <short description>

Types: feat, fix, refactor, test, docs, chore
```

```
Before commit:
1. git diff --staged
2. Check for secrets
3. npm test
4. npm run lint
5. npx tsc --noEmit
```

## Red Flags

- Large uncommitted changes accumulating
- Commit messages like "fix", "update", "misc"
- Formatting mixed with behavior changes
- No `.gitignore`
- Committing node_modules/, .env, or build artifacts
- Long-lived branches diverging from main

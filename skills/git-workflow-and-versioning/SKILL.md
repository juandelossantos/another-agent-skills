---
name: git-workflow-and-versioning
description: "Manage git workflow practices: branching, committing, resolving conflicts, parallel streams. Use when making any code change. Do NOT use for repository initialization."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: engineers
  workflow: version-control
---

# Git Workflow and Versioning

Git is your safety net. Treat commits as save points, branches as sandboxes, and history as documentation.

## When to Activate

- Making any code change (every change flows through git)
- Committing, pushing, merging, or rebasing
- Resolving merge conflicts
- Organizing parallel work streams
- Setting up a new project's git workflow

## When NOT to Use

- Repository initialization or `.gitignore` setup (use `git-init-and-versioning`)
- Deployment or release branching and tagging (use `fullstack-shipping`)
- Code review or PR approval decisions (use `code-review-and-quality`)

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Git commits + branch history | Git repository commits + branch structure | The repository itself | Commits follow Conventional Commits format (`type(scope): description`), every commit is atomic (one logical change), commit message describes WHAT and WHY, tests + lint + typecheck pass before commit, branch is up to date with main before merge, no secrets or sensitive data in diff, branch naming follows `type/scope-description` pattern |

## Decision Tree: Rebase or Merge?

```
What are you doing?
├── Updating feature branch with latest main → REBASE
│   ├── Keeps history linear
│   ├── Replays your commits on top of main
│   └── Use: git rebase main (on your feature branch)
│
├── Finishing a feature branch → MERGE (squash)
│   ├── Combines all feature commits into one
│   ├── Clean history on main
│   └── Use: git merge --squash feature-branch
│
├── Integrating a long-lived branch → MERGE (no-squash)
│   ├── Preserves branch history
│   ├── Shows when work diverged and converged
│   └── Use: git merge long-lived-branch
│
├── Pulling remote changes → REBASE (preferred)
│   ├── git pull --rebase (linear history)
│   └── Avoid: git pull (creates merge commit)
│
└── Conflicts during rebase → RESOLVE, then continue
    ├── Fix conflicts in files
    ├── git add <resolved-files>
    ├── git rebase --continue
    └── If stuck: git rebase --abort (back to before rebase)
```

## Core Workflows

### Trunk-Based Development
→ See `guides/BRANCHING.md`

Keep `main` always deployable. Short-lived feature branches (1-3 days).

### Commit Discipline
→ See `guides/COMMIT-PRINCIPLES.md`

Atomic commits, descriptive messages, separate concerns.

### Pre-Commit Hygiene
→ See `guides/PRE-COMMIT.md`

Verify before committing, automate with hooks.

## Quick Reference

**Commit message format:**
```
<type>(<scope>): <short description>

Types: feat, fix, refactor, test, docs, chore
Scope: optional, e.g., auth, api, ui
```

**Before every commit:**
```bash
git diff --staged          # What am I committing?
git diff --staged --stat   # How big is the change?
<test-command>             # Do tests pass? (from STACK_CONFIG.md)
<lint-command>             # Is code clean? (from STACK_CONFIG.md)
<typecheck-command>        # Are types correct? (from STACK_CONFIG.md)
```

**Commands come from `STACK_CONFIG.md`** — created by `init-agents` when the project starts. If missing, detect your stack:
| Stack | Test | Lint | Type check |
|---|---|---|---|
| Node/TypeScript | `npm test` | `npm run lint` | `npx tsc --noEmit` |
| Rust | `cargo test` | `cargo clippy` | `cargo check` |
| Python | `pytest` | `ruff check` | `mypy .` |
| Go | `go test ./...` | `golangci-lint run` | `go vet ./...` |
| Ruby | `bundle exec rspec` | `rubocop` | `solargraph check` |

**Branch naming:**
```
feat/<ticket>-<short-description>
fix/<ticket>-<short-description>
refactor/<area>-<what-changed>
```

## Conflict Resolution

```
Merge conflict detected:
├── Read both versions carefully
├── Understand INTENT of each change
├── Keep the change that serves the goal
├── If both are needed, combine intentionally
├── Test after resolving
└── git add <resolved-files> && git merge --continue
```

**Never:** Accept one side blindly. Always understand before resolving.

## Stash Workflow

```bash
# Save current work temporarily
git stash push -m "WIP: auth refactor"

# List stashes
git stash list

# Restore most recent stash
git stash pop

# Restore specific stash
git stash apply stash@{2}

# Delete stash after applying
git stash drop stash@{0}
```

**Use stash for:** Context switching, pulling urgent fixes, switching branches mid-work.

## Git Bisect (for regression bugs)

```bash
git bisect start
git bisect bad              # Current commit is broken
git bisect good <known-good> # This commit was working
git bisect run npm test     # Automated binary search
```

Git finds the exact commit that introduced the bug. Much faster than manual search.

## Integration

| Skill | When to use with git |
|---|---|
| `git-init-and-versioning` | Setting up a new project's git workflow |
| `code-review-and-quality` | Review before merge |
| `debugging-and-error-recovery` | Use bisect to find regression |
| `incremental-implementation` | Each increment = one commit |
| `fullstack-shipping` | Release branching and tagging |

## Red Flags

- Large uncommitted changes accumulating (>200 lines)
- Commit messages like "fix", "update", "misc"
- Formatting mixed with behavior changes
- No `.gitignore`
- Committing node_modules/, .env, or build artifacts
- Long-lived branches diverging from main (>3 days)
- Force-pushing to shared branches
- Commits that mix unrelated changes

## Verification

- [ ] Every commit is atomic (one logical change)
- [ ] Commit message describes WHAT and WHY
- [ ] Tests pass before commit
- [ ] No secrets or sensitive data in diff
- [ ] Branch is up to date with main before merge

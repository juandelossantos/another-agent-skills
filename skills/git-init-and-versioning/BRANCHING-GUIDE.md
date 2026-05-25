# Branching Strategy Guide

This guide contains the complete Phase 5 Branching Strategy Configuration for `git-init-and-versioning`.

## Phase 5 — Branching Strategy Configuration

**Decide and document the branching model.**

```
BRANCHING STRATEGY:

For this project, I recommend:

Option A — Trunk-Based Development (Recommended)
- main is always deployable
- Short-lived feature branches (1-3 days)
- Merge via Pull Request with review
→ Best for: Most projects, fast iteration, CI/CD friendly

Option B — GitFlow
- main (production), develop (integration)
- feature/*, release/*, hotfix/* branches
→ Best for: Enterprise, scheduled releases, QA teams

Option C — Simple Feature Branches
- main is production
- feature/* branches, merge when done
→ Best for: Solo devs, simple projects

Which strategy fits your team and release cadence?
```

**Document in `SETUP.md`:**
```markdown
## Git Workflow

**Strategy:** [Trunk-based / GitFlow / Feature Branches]

**Branch naming:**
- `feature/short-description`
- `fix/short-description`
- `chore/short-description`

**Commit format:**
```
<type>: <short description>

<body explaining why, not what>
```

**Pre-commit checks:**
- Tests pass
- Linting passes
- Type checking passes
- No secrets in diff
```

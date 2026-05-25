# Development Guide

## Folder: `development/`

All internal refinement work goes here. This folder is git-ignored.

### What goes in `development/`

| Type | Examples |
|---|---|
| **Analysis & Audits** | `AUDIT_WEB_CENTRISM.md`, performance audits, architecture reviews |
| **Reviews** | `REVIEW_v2.md`, code quality reviews, self-review checklists |
| **Simulations** | `SIMULATION.md`, test scenarios, user flow simulations |
| **Roadmaps & Planning** | `ROADMAP_TO_10.md`, milestone plans, feature backlogs |
| **Session Context** | `SESSION_CONTEXT.md`, conversation continuity, decision logs |
| **Experiments** | `TOKEN_OPTIMIZATION.md`, compression tests, pattern drafts |
| **Refinement** | Iterative improvements, draft skills, WIP guides |

### What stays in root / `skills/` / `ADRs/`

| Type | Location |
|---|---|
| Product documentation | `README.md`, `AGENTS.md`, `STACK_CONFIG_TEMPLATE.md` |
| Skills | `skills/<name>/SKILL.md` + guides |
| Architectural decisions | `ADRs/*.md` |
| Installer | `install.sh` |
| License | `LICENSE` |

### Why this convention

End users clone this repo to install skills via `install.sh`. Internal refinement artifacts (audits, reviews, simulations) are valuable to maintainers but create noise for users. By keeping them in `development/`:

1. **Clean repo for users** — Only product files visible
2. **Single `.gitignore` rule** — `development/` covers everything
3. **Flexible for maintainers** — Create any file inside, no `.gitignore` edits needed
4. **Explicit intent** — When you see `development/`, you know it's internal work

### How to use

When creating a new analysis, review, or draft:

```bash
# Correct: file goes in development/
touch development/my-analysis.md

# Wrong: file in root will be committed and visible to users
touch my-analysis.md
```

When working with an agent in this repo, **the agent reads Rule 10 in AGENTS.md** and knows to place refinement artifacts in `development/`.

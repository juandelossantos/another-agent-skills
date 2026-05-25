# Repository Structure Guide

This guide contains the complete Phase 1 Repository Structure Decision for `git-init-and-versioning`.

## Phase 1 — Repository Structure Decision (MANDATORY)

**NO FILES ARE CREATED UNTIL THIS DECISION IS MADE.**

Ask the user explicitly:

```
REPOSITORY STRUCTURE DECISION:

We need to decide how to organize version control for this project.

Option A — Single Repository (Mono-repo)
├── frontend/
├── backend/
├── shared/
└── package.json (workspace root)
→ Best for: Fullstack projects, tight coupling, shared types/utils

Option B — Separate Repositories (Multi-repo)
repo-frontend/
repo-backend/
→ Best for: Independent teams, different deployment cycles, open-source backend

Option C — Frontend-only Repository
→ Best for: Static sites, landing pages, no backend

Which structure fits your project?
→ Reply A, B, or C (or describe your preference)
```

**Critical Challenge:**
- User wants separate repos for a solo project → "Separate repos add overhead in syncing types, deploying coordinated changes, and managing CI across repositories. For a solo dev or small team, a mono-repo is usually faster. Are you planning to open-source the backend independently?"
- User wants mono-repo for clearly separated services → "Mono-repos are great for shared code, but if your frontend and backend deploy independently with different teams, separate repos reduce coupling. Do you often deploy them together?"

**Lock the decision** and document it in `SETUP.md` or `README.md`.

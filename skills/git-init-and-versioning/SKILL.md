---
name: git-init-and-versioning
description: >
  Initialize and configure Git repositories before any code is written.
  Decides mono-repo vs multi-repo, creates .gitignore and .env.example,
  sets branching strategy, and configures pre-commit auto-review gates.
  Use once per project before BUILD phase. Triggers on: "git init",
  "setup repo", "create repository", "version control", "git setup",
  "mono repo", "multi repo", "env variables", "secrets management".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: init-configure-guard
---

# Git Init & Versioning

**A project without version control is a project without history, safety, or collaboration.**

This skill runs once per project, immediately after contracts (SPEC.md, DESIGN.md, API-DESIGN.md) are locked and before any code is written. It establishes the foundation for clean, auditable, and safe version control.

## When to Use

**MANDATORY** once per project:
- After SPEC.md and DESIGN.md exist but before BUILD phase begins
- When the user says "start the project", "setup repo", "git init"
- Before `npm install`, `create-next-app`, or any tool that generates files

**When NOT to use:**
- The project already has a Git repository with `.gitignore` and `.env.example`
- The task is purely committing changes in an existing repo (use `git-workflow-and-versioning`)

---

## Core Process

### Phase 0 — Detect Current State

1. **Check for `.git/` directory:**
   - Exists → Read `git remote -v`, list branches, check `.gitignore`
   - Missing → This project has never been versioned

2. **Check for `.gitignore`:**
   - Exists → Audit it against the stack (see Phase 3)
   - Missing → Must be created

3. **Check for `.env.example`:**
   - Exists → Verify it documents required variables without secrets
   - Missing → Must be created

4. **Check for `README.md`:**
   - Exists → Verify it has setup instructions
   - Missing → Create minimal README

---

### Phase 1 — Repository Structure Decision (MANDATORY)

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

---

### Phase 2 — Initialize Repository

1. **If no `.git/` exists:**
   ```bash
   git init
   git branch -M main
   ```

2. **Configure basic Git settings:**
   ```bash
   git config user.name "[detected or asked]"
   git config user.email "[detected or asked]"
   ```

3. **Add remote (if user has a GitHub/GitLab URL):**
   ```bash
   git remote add origin [user-provided-url]
   ```

4. **Verify:**
   ```bash
   git status
   git log --oneline
   ```

---

### Phase 3 — Create `.gitignore`

**Generate a `.gitignore` tailored to the tech stack from `SPEC.md`.**

Read `GITIGNORE-TEMPLATES.md` in this skill directory for complete templates by stack (Node.js, Python, Rust, Go).

**Summary of rules:**
- `.env` and `.env.*` are ALWAYS ignored. No exceptions.
- Build outputs are ALWAYS ignored.
- IDE-specific files are ALWAYS ignored (except shared `.vscode/extensions.json`).
- Package manager lockfiles (`package-lock.json`, `yarn.lock`, `Cargo.lock`) are COMMITTED unless user explicitly requests otherwise.

**If no SPEC.md exists, ask the user for their stack before proceeding.**

---

### Phase 4 — Create `.env.example`

**Document every environment variable the project needs. NEVER include real values or secrets.**

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Auth
NEXTAUTH_SECRET=generate_with_openssl_rand_base64_32
NEXTAUTH_URL=http://localhost:3000
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# API Keys (external services)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# App Config
NODE_ENV=development
PORT=3000
```

**Rules:**
- Include a comment explaining each variable.
- Use placeholder values that clearly indicate they are fake (`...`, `your_value_here`, `generate_with...`).
- Mark required variables as `# REQUIRED`.
- If a variable has a default, document it.

**Presentation to user:**
```
I've created .env.example with the environment variables this project needs.
→ Review it and add any variables I might have missed.
→ Copy it to .env and fill in real values: cp .env.example .env
```

---

### Phase 5 — Branching Strategy Configuration

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

---

### Phase 6 — Pre-Commit Auto-Review Gate

**THIS IS THE CRITICAL ADDITION.**

During BUILD phase, before every `git commit`, the agent MUST run a self-review. This gate prevents "commit now, fix later."

**Create `.github/PRE_COMMIT_CHECKLIST.md` (or `docs/PRE_COMMIT_CHECKLIST.md`)** from the template in `PRE_COMMIT_CHECKLIST.md` in this skill directory.

**In SKILL.md, instruct the agent:**
> "During BUILD phase, read `.github/PRE_COMMIT_CHECKLIST.md` (or `docs/PRE_COMMIT_CHECKLIST.md`) before every commit. Run through the checklist. Only commit if all checks pass."

**After pre-commit review, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory name]
- gate_name: pre-commit-checklist
- result: pass/fail
- checks_passed: [N]/6
```

---

### Phase 7 — First Commit

**The first commit should include the project contracts, not generated boilerplate.**

```bash
# Stage contracts and configuration
git add SPEC.md DESIGN.md API-DESIGN.md .gitignore .env.example README.md SETUP.md
git commit -m "chore: initialize project with contracts and configuration

- Add SPEC.md with project scope and acceptance criteria
- Add DESIGN.md with visual design system
- Add API-DESIGN.md with backend architecture (if applicable)
- Add .gitignore for [stack]
- Add .env.example documenting required environment variables
- Add README.md with setup instructions
- Configure [trunk-based/feature branch/gitflow] workflow"
```

**Rules for first commit:**
- Must NOT include `node_modules/`, `.next/`, build outputs, or `.env`
- SHOULD include all human-written contracts and configs
- SHOULD NOT include generated code (create-next-app output can come in next commit)

---

### Phase 8 — Document

**Create `SETUP.md` (or update `README.md`):**

```markdown
# Project Setup

## Quick Start

```bash
# 1. Clone
git clone [remote-url]
cd [project-name]

# 2. Install dependencies
npm install

# 3. Environment
cp .env.example .env
# Edit .env with your values

# 4. Run
npm run dev
```

## Git Workflow
- Strategy: [Trunk-based / GitFlow / Feature branches]
- Branch from: `main`
- Merge via: Pull Request
- Pre-commit checks: See `.github/PRE_COMMIT_CHECKLIST.md`

## Environment Variables
See `.env.example` for all required variables.

## Useful Commands
```bash
npm run dev       # Start development
npm run build     # Production build
npm test          # Run tests
npm run lint      # Check linting
```
```

---

## Examples

### Example 1: New Fullstack Project

Context: SPEC.md exists, Next.js + PostgreSQL chosen.

Agent:
1. Phase 0: No `.git/`, no `.gitignore`, no `.env.example`.
2. Phase 1: User chooses Option A (mono-repo).
3. Phase 2: `git init`, configure user.name/email.
4. Phase 3: Create `.gitignore` from Node.js template in `GITIGNORE-TEMPLATES.md`.
5. Phase 4: Create `.env.example` with DATABASE_URL, NEXTAUTH_SECRET, etc.
6. Phase 5: User chooses trunk-based development.
7. Phase 6: Create `.github/PRE_COMMIT_CHECKLIST.md` from template.
8. Phase 7: First commit with SPEC.md, DESIGN.md, .gitignore, .env.example, README.md.
9. Phase 8: Create `SETUP.md`.

### Example 2: Existing Project Without Version Control

Context: Project has code but never had Git.

Agent:
1. Phase 0: No `.git/`. Code exists but no `.gitignore`.
2. Phase 1: User chooses single repo (existing code is frontend-only).
3. Phase 2: `git init`.
4. Phase 3: Create `.gitignore` — audit existing files to ensure no secrets or node_modules are staged.
5. Phase 4: Create `.env.example` from any `.env` found (but DO NOT commit `.env`).
6. Phase 5-8: Standard flow.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll set up Git later." | Without Git, you can't revert mistakes, review changes, or collaborate. Set it up BEFORE writing code. |
| ".gitignore is optional." | Without `.gitignore`, you will accidentally commit `node_modules/`, `.env`, or build outputs. It's not optional. |
| "I'll remember the env variables." | `.env.example` is documentation. Future you (and teammates) will need it. |
| "The user already has a repo." | Verify it. Many "repos" are just `git init` with no `.gitignore` or structure. |
| "I don't need to ask about repo structure." | Assuming mono-repo for a project that should be multi-repo (or vice versa) creates migration pain later. |
| "I'll do a giant first commit with everything." | First commit should be contracts and config. Generated code (create-next-app) should be a separate commit for clean history. |
| "Auto-review slows me down." | A 2-minute review prevents debugging for hours. "Commit now, fix later" means "commit now, debug at 2 AM." |

---

## Red Flags

- The agent writes code before initializing Git.
- `.gitignore` is missing or doesn't cover the stack.
- `.env` is committed to the repository.
- The first commit includes `node_modules/` or build outputs.
- No `.env.example` exists.
- The agent assumes mono-repo without asking.
- The agent doesn't document the branching strategy.
- During BUILD, the agent commits without running the pre-commit checklist.
- During BUILD, the agent commits without showing the user the diff and waiting for explicit approval.
- The agent batches multiple unrelated changes in a single commit approval request.

---

## Verification

Before proceeding to BUILD, confirm:
- [ ] `.git/` directory exists and is initialized.
- [ ] `.gitignore` exists and covers the project's stack.
- [ ] `.env` is ignored and `.env.example` exists.
- [ ] Repository structure (mono/multi/single) is decided and documented.
- [ ] Branching strategy is decided and documented.
- [ ] Pre-commit checklist exists at `.github/PRE_COMMIT_CHECKLIST.md` or `docs/PRE_COMMIT_CHECKLIST.md`.
- [ ] First commit includes contracts (SPEC.md, DESIGN.md) and config, NOT generated code.
- [ ] `SETUP.md` or `README.md` documents setup instructions.
- [ ] Remote is configured (if user provided URL).

---

## Integration with Build Phase

**During BUILD (`incremental-implementation` + `test-driven-development`):**

Before every `git commit`, follow this **mandatory 3-step gate**:

### Step 1 — Run Pre-Commit Checklist

1. **Read** `.github/PRE_COMMIT_CHECKLIST.md` (or `docs/PRE_COMMIT_CHECKLIST.md`).
2. **Run** the 6-axis review (correctness, readability, architecture, security, performance, git hygiene).
3. **If any fail:** Fix the issue. Do not proceed to Step 2 until fixed.

### Step 2 — Present Commit for Approval (BLOCKING)

**DO NOT execute `git commit` until the user explicitly approves.**

Present the commit like this:

```
═══════════════════════════════════════════
📝 COMMIT READY FOR REVIEW
═══════════════════════════════════════════

📁 Files changed:
- src/components/Hero.tsx        (added hero section)
- src/app/globals.css            (added design tokens)
- public/images/hero.jpg         (added hero image)

📊 Pre-commit checklist:
✅ Correctness: Tests pass, matches acceptance criteria
✅ Readability: Descriptive names, no nested ternaries
✅ Architecture: Follows component pattern
✅ Security: No secrets, inputs validated
✅ Performance: transform/opacity only, lazy loading
✅ Git Hygiene: One logical change, no .env committed

📝 Commit message:
feat: add Hero section with Playfair display and warm cream background

- Implements hero with H1, subtitle, CTA button
- Uses design tokens from globals.css
- Adds Reveal animation on scroll
- Responsive: 375px mobile → 1280px desktop

═══════════════════════════════════════════
→ Approve? Reply "yes", "sí", or "commit" to proceed.
→ Changes needed? Reply "edit" or describe what to fix.
→ Skip this commit? Reply "skip" (not recommended).
═══════════════════════════════════════════
```

**Valid user responses:**
- `"yes"`, `"sí"`, `"commit"`, `"adelante"`, `"proceed"` → Execute `git commit`
- `"edit"`, `"change"`, `"fix"` + description → Go back to Step 1, make changes
- `"skip"` → Do not commit, continue to next task (document the skip)

**Invalid responses (do not accept):**
- `"ok"`, `"mmhm"` → Ask again with explicit "yes/commit" or "edit"
- Silence → Re-prompt with the approval request

### Step 3 — Execute Commit

Only after explicit approval:

```bash
git add [files]
git commit -m "[descriptive message]"
```

**After commit completes, log metrics:**
```
LOG METRIC: commit
- project: [detect from git remote or directory name]
- files_changed: [count]
- additions: [count]
- deletions: [count]
- pre_commit_passed: true/false
- user_approved: true/false (false if skipped)
- commit_message_category: feat/fix/chore/docs/refactor
```

**Rules:**
- Show the exact files being committed.
- Show the exact commit message.
- Never batch multiple logical changes in one approval request.
- If 5+ files changed, summarize them grouped by purpose.

---

## Philosophy: Time Invested Upfront = Time Saved Later

**Why this skill enforces 45+ minutes of planning before writing code:**

| Phase | Time Invested | Time Saved Later |
|---|---|---|
| SPEC + Discovery | 15-20 min | Prevents "this isn't what I wanted" rework |
| Architecture Decision | 10-15 min | Prevents "we need to rewrite everything" migrations |
| Design Lock | 10-15 min | Prevents "it looks different than we agreed" visual drift |
| Git Setup + Pre-commit | 5-10 min | Prevents "I committed .env" or "node_modules in repo" disasters |
| **Total upfront** | **45-60 min** | **Saves 5-15 hours of debugging, refactoring, and miscommunication** |

**Anti-rationalization:**

| Excuse | Why It's Wrong |
|---|---|
| "This is taking too long, just code it." | 45 minutes of clarity prevents 5 hours of "that's not what I meant." |
| "The user is impatient." | The user will be more impatient when the result doesn't match expectations. |
| "I already know what they want." | You have 1% confidence. The skill forces 95% confidence through explicit confirmation. |
| "We'll fix it in the next iteration." | Technical debt compounds. Decisions made without specs become permanent by default. |

**The goal of these skills is not speed. The goal is precision.**
Speed without precision is wasted effort.

**This bridges `git-init-and-versioning` (setup) with `code-review-and-quality` (execution).**

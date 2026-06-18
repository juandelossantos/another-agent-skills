---
name: git-init-and-versioning
description: >
  Initialize and configure Git repositories before any code is written.
  Decides mono-repo vs multi-repo, creates .gitignore and .env.example,
  sets branching strategy, and configures pre-commit auto-review gates.
  Use once per project before BUILD phase. Triggers on: "git init",
  "setup repo", "create repository", "version control", "git setup",
  "mono repo", "multi repo", "env variables", "secrets management".
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash Write Edit
tier: action-allowed
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

→ **Ver `REPO-STRUCTURE-GUIDE.md` para el cuestionario completo y casos de uso.**

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

→ **See `BRANCHING-GUIDE.md` for the 3 options and documentation format.**

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

Create `SETUP.md` with: quick start, git workflow, env vars, useful commands.

---

### Phase 9 (Optional) — Release Automation

**If the user asks for versioning, releases, or changelogs.**

→ See `RELEASE-GUIDE.md` for setup: VERSION file, RELEASE-NOTES.md, release.sh script.

---

## Examples

See `REPO-STRUCTURE-GUIDE.md` for walkthroughs or `RELEASE-GUIDE.md` for release automation.

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll set up Git later." | Without Git, no revert, review, or collaboration. |
| ".gitignore is optional." | You'll commit node_modules, .env, or build outputs. |
| "The user already has a repo." | Verify. Many are just `git init` with no structure. |
| "Auto-review slows me down." | 2 min review prevents hours debugging. |
| "I'll remember the env variables." | `.env.example` is documentation. Future you needs it. |

---

## Red Flags

Code before Git init. Missing .gitignore. .env committed. First commit has node_modules. No .env.example. Assumes mono-repo. No branching documented. Commits without pre-commit checklist.

---

## Verification

Before BUILD: .git/ exists | .gitignore covers stack | .env ignored + .env.example | Repo structure decided | Branching documented | Pre-commit checklist exists | First commit = contracts+config, NOT generated code | Setup docs exist | Remote configured (if URL provided).

See `BUILD-INTEGRATION-GUIDE.md` for pre-commit gate. **Goal:** Precision over speed. ~45 min upfront saves 5-15h.

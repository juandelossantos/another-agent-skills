---
name: dev-environment-audit
description: >
  Audit the development environment (MCPs, CLI tools, runtimes) and ensure the
  project has the right tooling before any code is written. Proposes installations
  with justification, never blind setup. Use when starting a project, when the user
  asks "what do I need", "setup environment", "install tools", or before build phase.
  Triggers on: "setup", "environment", "tools", "MCPs", "what do I need to install",
  "prepare workspace", "dev tools", "prerequisites".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: audit-gap-install-document
---

# Dev Environment Audit

**The right tools make good code possible. The wrong tools make it painful.**

This skill audits the agent's own capabilities (MCPs), the user's CLI tools
(node, git, docker), and the project's runtime requirements. It then proposes
a precise set of installations with justification — never "install everything
just in case."

## When to Use

**MANDATORY** when:
- Starting any new project (after spec, before build)
- The user asks "what do I need to install" or "setup my environment"
- Before the build phase if `docs/DEV-ENVIRONMENT.md` is missing or outdated
- When a project requires testing, deployment, or design tools that may not be present

**Invoked automatically by:**
- `spec-driven-development` Phase 7 (before implementation gate)
- `shipping-and-launch` (if deployment tools are missing)
- `frontend-web` or `frontend-mobile` (if design or testing MCPs are absent)

**When NOT to use:**
- The project has a fresh `DEV-ENVIRONMENT.md` (< 7 days old) with all tools verified
- The task is purely documentation or design with no build step

---

## Core Process

### Phase 0 — Context Assessment

1. **Check for `docs/DEV-ENVIRONMENT.md`:**
   - Exists and < 7 days old → Read it. Verify tools listed are still available.
   - Exists but > 7 days old → Read it, then re-audit.
   - Missing → Full audit required.

2. **Determine project type from context:**
   - Read `SPEC.md` → Look at Tech Stack and Testing Strategy sections.
   - If no `SPEC.md` → Infer from conversation (frontend, backend, fullstack, mobile, etc.)

3. **Assess complexity:**
   - **Simple:** Single-page, no backend → Lightweight audit (core tools only)
   - **Non-trivial:** Multi-page, needs backend, tests, CI → Full audit
   - **Complex:** Multi-platform, enterprise, regulated → Extended audit with security/compliance tools

---

### Phase 1 — Discovery (MANDATORY if no SPEC.md)

If the project type is unclear, ask the user:

1. **Project type**: Is this a web app, API, mobile app, desktop app, or CLI tool?
2. **Testing needs**: Do you need unit tests, integration tests, E2E tests, or visual regression?
3. **Design workflow**: Will you need to pull designs from Figma, Penpot, or similar?
4. **Deployment target**: Are you deploying to Vercel, AWS, GCP, self-hosted, or undecided?
5. **Team tools**: Do you need GitHub Actions, documentation generators, or collaboration tools?

Only after confirmation, proceed to Phase 2.

---

### Phase 2 — Audit Installed Tools

**Check three categories:**

#### 2A: MCP Servers (Agent Capabilities)

Read `~/.config/opencode/opencode.json` to detect installed MCPs.

**Common MCPs to check for:**
- `playwright` — Browser testing, E2E automation
- `context7` — Documentation context retrieval
- `serena` — (If applicable to user's setup)
- `figma` / `penpot` — Design system integration
- `github` / `gitlab` — Repository and CI management
- `gitbook` / `notion` — Documentation access

**Record:** Which are present, which are missing, which are enabled/disabled.

#### 2B: CLI Tools (User Machine)

Check availability of:
- **Runtime:** `node` (and version), `npm`/`pnpm`/`yarn`, `python`, `go`, `rust`
- **Version Control:** `git`, `gh` (GitHub CLI)
- **Containerization:** `docker`, `docker-compose`
- **Cloud CLIs:** `vercel`, `aws`, `gcloud`, `flyctl`, `railway`
- **Database:** `psql`, `mysql`, `mongosh` (if applicable)
- **Testing:** `vitest`, `jest`, `playwright` (global install or npx)
- **Lint/Format:** `eslint`, `prettier`, `biome`
- **Build:** `tsc`, `vite`, `webpack`

**How to check:** Attempt to run `--version` or equivalent. Record: installed version, or "NOT FOUND".

#### 2C: Project-Specific Tools

Check the project directory for:
- `package.json` scripts (what commands does the project expect?)
- `Dockerfile` or `docker-compose.yml` (needs Docker?)
- `.github/workflows/` (needs `gh` CLI or GitHub Actions knowledge?)
- `prisma/schema.prisma` (needs Prisma CLI?)
- `supabase/config.toml` (needs Supabase CLI?)

---

### Phase 3 — Gap Analysis

**Compare installed tools against the "Ideal Set" for this project type.**

#### Ideal Sets by Project Type

| Project Type | Core Tools | Testing | Design | Deploy | Optional |
|---|---|---|---|---|---|
| **Frontend Web** | Node 20+, npm/pnpm, Git | Playwright MCP, Vitest | Figma/Penpot MCP | Vercel CLI | GitHub Actions MCP |
| **Backend API** | Node/Python/Go, Docker | Vitest/Jest, Postman/Bruno | — | Railway/Fly/AWS CLI | Database MCP |
| **Fullstack** | All frontend + backend tools | Playwright + Vitest | Figma/Penpot MCP | Vercel + Railway | GitHub Actions MCP |
| **Mobile (RN)** | Node, Expo CLI, Git | Maestro/Jest | Figma MCP | EAS CLI | — |
| **Desktop** | Node/Rust, Tauri/Electron CLI | Playwright | Figma MCP | — | — |
| **Documentation** | Node/Git | — | — | GitBook/Notion MCP | — |

**For each missing tool, determine priority:**
- **BLOCKING** — Cannot proceed without this (e.g., no Node.js for a Node project)
- **HIGH** — Strongly recommended for this project type (e.g., no Playwright for a web app)
- **MEDIUM** — Useful but workarounds exist (e.g., no Figma MCP, can use manual design export)
- **LOW** — Nice to have (e.g., advanced linting tools)

---

### Phase 4 — Recommend & Install (BLOCKING)

**Present findings to user. Do not install anything without explicit confirmation.**

```
🔧 DEV ENVIRONMENT AUDIT

Project type: [Frontend Web / Backend API / Fullstack / etc.]

INSTALLED ✅:
- Node.js 20.11 ✅
- Git 2.43 ✅
- pnpm 8.15 ✅
- Playwright MCP ✅

MISSING ❌:
🔴 BLOCKING:
- Docker (project has Dockerfile, needed for local DB)

🟠 HIGH:
- Figma MCP (design workflow — can work around with manual export)
- Vercel CLI (deployment target is Vercel per SPEC.md)

🟡 MEDIUM:
- GitHub Actions MCP (CI/CD visibility)

RECOMMENDED ACTIONS:
1. Install Docker Desktop (required for local development)
2. Configure Figma MCP for design token sync
3. Install Vercel CLI for preview deployments

→ Which of these do you want to install now?
→ Reply with numbers (e.g., "1, 2") or "all" or "none".
```

**Installation rules:**
- Only install what the user explicitly approves.
- If user says "none", document the decision and proceed with workarounds.
- If BLOCKING tools are missing and user refuses to install, **warn strongly**:
  ```
  ⚠️  Docker is marked BLOCKING because your project includes a Dockerfile
  and likely needs a local database. Without it, you won't be able to run
  the full development environment locally. Proceeding without it means
  some features won't be testable.
  ```
- Provide exact commands for installation:
  ```bash
  # Docker (macOS)
  brew install --cask docker
  
  # Vercel CLI
  npm i -g vercel
  
  # Figma MCP (if available)
  # [Provide specific MCP install command from opencode docs]
  ```

---

### Phase 5 — Document

**Create or update `docs/DEV-ENVIRONMENT.md`:**

```markdown
# Dev Environment

**Project:** [Name]
**Audited:** YYYY-MM-DD by OpenCode Agent
**Type:** [Frontend / Backend / Fullstack / etc.]

## Required Tools

| Tool | Version | Status | Notes |
|---|---|---|---|
| Node.js | 20.11+ | ✅ Installed | |
| pnpm | 8.15+ | ✅ Installed | |
| Docker | 24.x | ❌ Missing | User declined — using remote DB for now |
| Git | 2.43 | ✅ Installed | |

## MCP Servers

| MCP | Status | Purpose |
|---|---|---|
| Playwright | ✅ Enabled | E2E testing |
| Figma | ❌ Not installed | Design sync (manual workaround) |
| GitHub | ✅ Enabled | PR checks |

## Installed by This Audit

| Date | Tool | Command Used | Approved By |
|---|---|---|---|
| YYYY-MM-DD | Vercel CLI | `npm i -g vercel` | User |

## Workarounds

- **No Docker:** Using Supabase Cloud instead of local Docker container.
- **No Figma MCP:** Exporting designs manually from Figma and saving to `design/approved/`.

## Next Audit

**Due:** YYYY-MM-DD (7 days from now or after significant tool changes)
```

**Rules:**
- Document what was installed AND what was missing.
- Record workarounds for missing tools — don't pretend they don't exist.
- Set a "next audit" date (7 days or after major tool changes).

---

## Examples

### Example 1: New Fullstack Project

Context: SPEC.md indicates Next.js + PostgreSQL + Prisma + Vercel.

Agent:
1. Phase 0: No `DEV-ENVIRONMENT.md` exists.
2. Phase 1: Not needed — type is clear from SPEC.md.
3. Phase 2:
   - MCPs: Playwright ✅, Figma ❌, GitHub ✅
   - CLI: Node 20.11 ✅, pnpm 8.15 ✅, Git 2.43 ✅, Docker ❌, Vercel CLI ❌
   - Project: `prisma/schema.prisma` exists, `.github/workflows/` exists
4. Phase 3:
   - BLOCKING: Docker (needed for local PostgreSQL via docker-compose)
   - HIGH: Vercel CLI (deployment target), Figma MCP (design system)
   - MEDIUM: GitHub Actions MCP (CI visibility)
5. Phase 4: Present to user. User approves Docker + Vercel CLI. Declines Figma MCP.
6. Phase 5: Create `docs/DEV-ENVIRONMENT.md` with all tools, workarounds, and next audit date.

### Example 2: Existing Project Return

Context: Project has `DEV-ENVIRONMENT.md` dated 10 days ago.

Agent:
1. Phase 0: File exists but >7 days old.
2. Read existing doc. Note last installed tools.
3. Re-audit: Check if tools from last audit are still present.
4. Discover: User installed Docker since last audit (not recorded).
5. Update doc with new tool and reset audit date.

### Example 3: User Declines Blocking Tool

Context: Project needs Docker (has `docker-compose.yml`), user says "I don't want Docker."

Agent:
1. Phase 4: Present Docker as BLOCKING.
2. User: "No Docker, too heavy."
3. Agent: "Understood. Without Docker, you won't be able to run the local database.
   Workarounds: (1) Use a cloud PostgreSQL instance (Supabase, Neon), or
   (2) Install PostgreSQL directly via `brew install postgresql`.
   Which workaround works for you?"
4. User: "I'll use Supabase."
5. Phase 5: Document: "No Docker → Using Supabase Cloud for PostgreSQL."

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just install everything to be safe." | Bloat slows machines and confuses the user. Install only what the project needs. |
| "The user didn't ask for an audit." | Missing tools cause cryptic errors later. Proactive audit prevents "why doesn't this work?" |
| "They probably already have Docker." | Assume nothing. Check. Many developers avoid Docker until they need it. |
| "MCPs are optional extras." | MCPs like Playwright unlock testing superpowers. Without them, the agent is blind. |
| "I'll install tools silently." | Never install without consent. The user owns their machine. |
| "If it's missing, they'll figure it out." | "Figuring it out" wastes hours. A 2-minute audit saves debugging time. |

---

## Red Flags

- The agent assumes tools exist without checking.
- The agent installs software without user confirmation.
- The agent skips the audit because "it's probably fine."
- The agent does not document missing tools or workarounds.
- The agent recommends tools unrelated to the project type (e.g., suggesting Kubernetes for a landing page).
- The agent does not create or update `docs/DEV-ENVIRONMENT.md`.

---

## Verification

Before proceeding to build, confirm:
- [ ] `docs/DEV-ENVIRONMENT.md` exists and is dated.
- [ ] All BLOCKING tools are either installed or have an approved workaround.
- [ ] User explicitly approved every installation performed.
- [ ] MCP status (installed/enabled/missing) is documented.
- [ ] CLI tool versions are recorded (or "NOT FOUND" noted).
- [ ] Workarounds for missing tools are described.
- [ ] Next audit date is set (7 days or after major changes).

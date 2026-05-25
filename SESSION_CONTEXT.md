# Session Context — another-agent-skills

> **INSTRUCTION FOR NEXT AGENT:** Read this file immediately upon starting a new session in this repository. It contains the current state, decisions made, and next steps. Do NOT start coding or editing without reading this first.

---

## Project Overview

This is our **personal** agent skills repository (`another-agent-skills`), NOT the original `addyosmani/agent-skills` repo. We forked the concept but this is our own maintained collection.

**Repository:** https://github.com/juandelossantos/another-agent-skills
**Purpose:** Curated, opinionated agent skills for OpenCode with a focus on intentional frontend design and disciplined engineering workflows.

---

## What We've Built So Far

### 1. Infrastructure
- ✅ Global skills setup via `install.sh`
- ✅ Auto-update daily from `addyosmani/agent-skills` remote
- ✅ Symlinks 23 official skills + our custom skills
- ✅ Shell aliases: `init-agents`, `update-global-skills`
- ✅ `~/.zshrc` configured with auto-update logic
- ✅ `~/.config/opencode/opencode.json` with skill permissions

### 2. Custom Skills

#### `visual-frontend-mastery`
**Location:** `skills/visual-frontend-mastery/SKILL.md` (+ 3 guides)
**Current version:** SKILL.md 302 lines (refactored). Guides split into focused files.

**Key features:**
- Language detection (Spanish/English/Other)
- **Discovery Gate** → `DISCOVERY-GUIDE.md` (complete questions EN/ES, extended, visual)
- Contracts: SPEC.md, DESIGN.md (visual-only), **Design Asset Lock** (`design/DESIGN-LOCK.md`)
- Anti-AI-slop rules (no Inter, no Tailwind generics, no generic layouts)
- Stack lock-in: Next.js 16, Tailwind v4, shadcn/ui, Framer Motion
- **Animation System** → `ANIMATION-GUIDE.md` (Reveal, CSS scroll, WAAPI, reduced motion)
- QA gates: 12 checks before delivery
- **Examples & Troubleshooting** → `EXAMPLES.md`

#### `project-health-check`
**Location:** `skills/project-health-check/SKILL.md`
**Status:** ✅ Complete

**Key features:**
- Mandatory audit before any new work on existing codebases
- 6 audit categories: Stack/Versions, Structure, Code Quality, Config, Dependencies, Agent Compliance
- Generates `HEALTH-CHECK.md` artifact
- **BLOCKING user decision gate:** Fix First / Proceed with Caution / Ignore
- Recursive: Re-audits every 7 days or after any gap >3 days

#### `spec-driven-development` (Overrides Official)
**Location:** `skills/spec-driven-development/SKILL.md`
**Status:** ✅ Complete — 481 lines

**Key features:**
- Phase 0: Context assessment (triggers `project-health-check` if existing code)
- Phase 1: Domain research via web search
- Phase 2: Deep discovery with **critical challenge**
- Phase 3: Architecture decision gate (triggers `architecture-analysis`)
- Phase 7: Environment audit gate
- Phase 8: **Implement gate** — explicit "yes" required

#### `git-init-and-versioning`
**Location:** `skills/git-init-and-versioning/SKILL.md`
**Status:** ✅ Complete — 399 lines + 2 guides

**Key features:**
- Phase 0: Detect current Git state (exists `.git/`? `.gitignore`? `.env.example`?)
- Phase 1: Repository structure decision (mono-repo vs multi-repo vs single) with critical challenge
- Phase 2: Initialize repository (`git init`, configure user, add remote)
- Phase 3: Create `.gitignore` from stack-specific templates
- Phase 4: Create `.env.example` with documented variables (no secrets)
- Phase 5: Branching strategy configuration (trunk-based vs GitFlow vs feature branches)
- Phase 6: Pre-commit auto-review gate — creates `.github/PRE_COMMIT_CHECKLIST.md` with 6-axis review
- Phase 7: First commit includes contracts (SPEC.md, DESIGN.md), NOT generated code
- Phase 8: Document in `SETUP.md`
- **Integration with BUILD:** Agent MUST run pre-commit checklist before every commit

#### `architecture-analysis`
**Location:** `skills/architecture-analysis/SKILL.md`
**Status:** ✅ Complete — 362 lines

**Key features:**
- Phase 1: Discovery (scale, team, ops, data, latency, constraints)
- Phase 2: Research (documentation, benchmarks, maintenance status)
- Phase 3: Generate exactly 2-3 options with honest pros AND cons
- Phase 4: **Critical Challenge** — questions user assumptions
- Phase 5: Recommendation with confidence level
- Phase 6: Document in `SPEC.md` + `architecture/ARCHITECTURE.md`

#### `dev-environment-audit`
**Location:** `skills/dev-environment-audit/SKILL.md`
**Status:** ✅ Complete — 335 lines

**Key features:**
- Phase 1: Discovery (project type, testing needs, design workflow, deploy target)
- Phase 2: Audit MCPs (reading `opencode.json`), CLI tools (`node`, `git`, `docker`), project-specific tools (`package.json`, `Dockerfile`)
- Phase 3: Gap Analysis against "Ideal Set" per project type (Frontend, Backend, Fullstack, Mobile, Desktop)
- Phase 4: **BLOCKING install gate** — presents findings with priority (BLOCKING/HIGH/MEDIUM/LOW), user must explicitly approve each installation
- Phase 5: Document in `docs/DEV-ENVIRONMENT.md` with workarounds for declined tools
- Recursive audit every 7 days

#### `backend-api-mastery`
**Location:** `skills/backend-api-mastery/SKILL.md`
**Status:** ✅ Complete — 447 lines

**Key features:**
- Phase 1: Discovery (10 questions: data, consumers, public/private, volume, auth, real-time, protocol, DB, ORM, integrations)
- Phase 2: Research (protocols, ORMs, auth patterns — **always [current year]**)
- Phase 3: Protocol Decision (REST vs GraphQL vs tRPC vs WebSocket) with 2-3 options
- Phase 4: Database Design (type, ORM, schema) with critical challenges
- Phase 5: Auth & Security (strategy, validation, rate limiting, security checklist)
- Phase 6: Error Handling & Testing (structured errors, HTTP codes, unit/integration/E2E)
- Phase 7: Documentation & Versioning (OpenAPI, deprecation strategy)
- Phase 8: Lock in `API-DESIGN.md` + update `SPEC.md`

#### `fullstack-shipping`
**Location:** `skills/fullstack-shipping/SKILL.md`
**Status:** ✅ Complete — 416 lines

**Key features:**
- Phase 1: Shipping Discovery (8 questions: environment, stages, team, rollback, database, domains, monitoring, compliance)
- Phase 2: Research (CI/CD platforms, testing in CI, deployment patterns, monitoring tools — **always [current year]**)
- Phase 3: CI/CD Pipeline Design (Platform-native vs GitHub Actions vs Full Control Docker) with 2-3 options
- Phase 4: Testing Strategy in Pipeline (PR, merge, staging, production gates)
- Phase 5: Deployment Orchestration (environments, DB migrations, secrets, rollback strategies)
- Phase 6: Monitoring & Alerting (errors, performance, uptime, business metrics)
- Phase 7: Launch Checklist (pre-launch, launch day, post-launch 48h)
- Phase 8: Lock in `DEPLOYMENT.md` + update `SPEC.md`

## Immediate Next Steps (Priority Order)

1. **Test ALL skills in a real project**
   - Create a test project with `init-agents`
   - Verify `project-health-check` blocks on existing code with A/B/C
   - Verify `spec-driven-development` does web research + critical challenge + implement gate
   - Verify `git-init-and-versioning` initializes repo, creates `.gitignore`, `.env.example`, and pre-commit checklist
   - Verify `architecture-analysis` proposes 2-3 options with honest trade-offs
   - Verify `dev-environment-audit` detects MCPs/CLIs and proposes installations
   - Verify `backend-api-mastery` designs protocol, DB, auth with critical challenges
   - Verify `visual-frontend-mastery` creates design lock and follows tokens

2. **Documentation**
   - Update `README.md` with concrete usage examples for each skill
   - Add `CONTRIBUTING.md` for future collaborators
   - Create `CHANGELOG.md` tracking skill versions

3. **CI/CD**
   - Add GitHub Actions to validate `SKILL.md` frontmatter
   - Validate skill names match directory names
   - Check line count < 500 for all custom skills
   - Validate all guides referenced in SKILL.md actually exist

4. **Future skills (post-MVP)**
   - `mobile-react-native` — React Native patterns, Expo
   - `security-and-hardening` — Advanced security audits, penetration testing prep
   - `performance-optimization` — Core Web Vitals, load testing, optimization workflows

---

## File Structure

```
another-agent-skills/
├── AGENTS.md                          # Universal skill-driven execution rules
├── README.md                          # Project overview and quick start
├── install.sh                         # Global installer for OpenCode skills
├── LICENSE                            # MIT
├── .gitignore
├── SESSION_CONTEXT.md                 # <-- YOU ARE HERE
├── skills/
│   ├── visual-frontend-mastery/
│   │   ├── SKILL.md                   # Anti-AI-slop frontend skill (302 lines)
│   │   ├── DISCOVERY-GUIDE.md         # Phase 1 complete questions
│   │   ├── ANIMATION-GUIDE.md         # Phase 5 animation patterns
│   │   └── EXAMPLES.md                # Walkthroughs & troubleshooting
│   ├── project-health-check/
│   │   └── SKILL.md                   # Audit existing codebases
│   ├── spec-driven-development/
│   │   └── SKILL.md                   # Research-backed spec writing (overrides official)
│   ├── git-init-and-versioning/
│   │   ├── SKILL.md                   # Initialize repo, .gitignore, .env.example, branching
│   │   ├── GITIGNORE-TEMPLATES.md     # Templates by stack (Node, Python, Rust, Go)
│   │   └── PRE_COMMIT_CHECKLIST.md    # 6-axis review before each commit
│   ├── architecture-analysis/
│   │   └── SKILL.md                   # Evaluate stack/pattern options with trade-offs
│   ├── dev-environment-audit/
│   │   └── SKILL.md                   # Audit MCPs, CLI tools, propose installations
│   ├── backend-api-mastery/
│   │   └── SKILL.md                   # Design production APIs (protocol, DB, auth, testing)
│   └── fullstack-shipping/
│       └── SKILL.md                   # CI/CD, deployment, monitoring, launch checklists
└── scripts/                           # (empty, reserved for future)
```

---

## Global Installation Status

The following are installed on this machine and should persist:
- `~/.config/opencode/skills/` — 24 skills (23 official + visual-frontend-mastery)
- `~/.config/opencode/.agent-skills-remote/` — Clone of official repo (auto-updated daily)
- `~/.zshrc` — Aliases and auto-update logic
- `~/.config/opencode/opencode.json` — Plugin and skill permissions

---

## How to Resume Work

1. Open a new session in `/home/juandelossantos/dev/personal/another-agent-skills`
2. Read this file (`SESSION_CONTEXT.md`)
3. Check git status: `git status`
4. Verify remote: `git remote -v` (should point to `juandelossantos/another-agent-skills`)
5. Pick the next task from "Immediate Next Steps" above
6. Run `source ~/.zshrc` if aliases are not loaded

---

## User Preferences (Learned)

- Wants skills to be **global** across all projects
- Wants **bilingual** support (Spanish/English)
- Wants **strict discovery** before coding (no assumptions)
- Stack preference: React/Next.js/Tailwind/TypeScript/TanStack
- Values **anti-AI-slop** design (intentional, not generic)
- Wants **restorable** setup (repo + install.sh = full recovery)

---

Last updated: 2026-05-24
Session: Critical fixes applied — AGENTS.md lifecycle, Turbo Mode philosophy, Stack Agnosticism. Current score: 9.0/10

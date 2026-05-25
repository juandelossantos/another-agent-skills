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
**Location:** `skills/visual-frontend-mastery/SKILL.md`
**Current version:** Includes Phase 0 (Language Detection), Phase 1 (Discovery Gate), Phase 2 (Contracts + Design Asset Lock), Phase 3-7 (Stack, Anti-Slop, Animation, Build, QA)

**Key features:**
- Language detection (Spanish/English/Other)
- Mandatory Discovery Gate with 5+ questions
- Extended discovery for logic/data/security/scalability
- Anti-AI-slop rules (no Inter, no Tailwind generics, no generic layouts)
- Stack lock-in: Next.js 16, Tailwind v4, shadcn/ui, Framer Motion
- Animation system: Framer Motion, CSS `animation-timeline`, WAAPI
- `prefers-reduced-motion` mandatory
- **Design Asset Lock:** `design/DESIGN-LOCK.md` + `design/approved/` for visual persistence
- QA gates: 12 checks before delivery

#### `spec-driven-development` (Overrides Official)
**Location:** `skills/spec-driven-development/SKILL.md`
**Status:** ✅ Complete — Replaces official version with extended capabilities

**Key features:**
- **Phase 0:** Context assessment (triggers `project-health-check` if existing code)
- **Phase 1:** Domain research via web search (best practices, benchmarks, docs)
- **Phase 2:** Deep discovery with **critical challenge** — agent questions user assumptions, proposes alternatives, identifies XY problems
- **Phase 3:** Architecture decision gate (triggers `architecture-analysis` if non-trivial)
- **Phase 4:** Enhanced SPEC.md template with Research Context + Architecture Decisions sections
- **Phase 7:** Environment audit gate (triggers `dev-environment-audit`)
- **Phase 8:** **Implement gate** — explicit "yes" required before any code
- Anti-rationalization: "The user knows what they want" → NO, senior engineers challenge when they see better alternatives

#### `project-health-check`
**Location:** `skills/project-health-check/SKILL.md`
**Status:** ✅ Complete

**Key features:**
- Mandatory audit before any new work on existing codebases
- 6 audit categories: Stack/Versions, Structure, Code Quality, Config, Dependencies, Agent Compliance
- Generates `HEALTH-CHECK.md` artifact
- **BLOCKING user decision gate:** Fix First / Proceed with Caution / Ignore
- Recursive: Re-audits every 7 days or after any gap >3 days
- Remediation planning with `planning-and-task-breakdown` integration

### 3. Universal AGENTS.md
- ✅ Created at repo root
- ✅ Used by `init-agents` alias to bootstrap any project
- ✅ Enforces skill-driven execution model
- ✅ Anti-rationalization rules

### 4. Badminton Scorer Test App
- ✅ Built in `/tmp/test-badminton-scorer` (deleted after testing)
- ✅ Verified: spec-driven → design → build → test → QA workflow works
- ✅ 12/12 tests passed
- ✅ Build successful
- ⚠️ **Issue discovered:** Agent sometimes ignores skills and jumps to coding

---

## Current Issues & Decisions

### Issue 1: Agent Compliance
**Problem:** OpenCode agent sometimes ignores `AGENTS.md` and skills, jumping straight to implementation.
**Status:** Mitigated but not fully solved.
**Next step:** Need to test if stronger `AGENTS.md` language helps. May need to open an issue with OpenCode team about skill tool compliance.

### Issue 2: Repo Confusion
**Problem:** We accidentally worked in `agent-skills` (original clone) instead of `another-agent-skills` (our repo).
**Status:** FIXED. All commits are now in `another-agent-skills`.
**Prevention:** Always verify `pwd` and `git remote -v` before any git operation.

### Issue 3: Skill Line Count
**Problem:** `visual-frontend-mastery` is now ~540 lines (exceeded 500-line limit).
**Status:** ⚠️ OVER LIMIT. Need to split extended discovery questions or design asset lock details into a reference file.
**Decision:** Keep as-is for now. Split Phase 1 extended discovery into `skills/visual-frontend-mastery/EXTENDED-DISCOVERY.md` if it grows further.

---

## Immediate Next Steps (Priority Order)

1. **Test `project-health-check` skill**
   - Open a project with existing code
   - Verify it blocks and presents A/B/C options
   - Verify `HEALTH-CHECK.md` is generated
   - Test recursive behavior (return after 7 days)

2. **Test `spec-driven-development` (rewritten)**
   - Start a new project
   - Verify Phase 1 research (if non-trivial)
   - Verify Phase 2 critical challenge (questions that push back)
   - Verify Phase 8 implement gate (explicit "yes" required)
   - Check `SPEC.md` includes Research Context + Architecture Decisions sections

3. **Create `architecture-analysis` skill**
   - Stack selection with 2-3 justified options
   - Pattern recommendations (MVC, Hexagonal, Serverless, etc.)
   - Critical analysis: challenge user choices, explain trade-offs
   - Lock decision in `SPEC.md` + `architecture/ARCHITECTURE.md`

4. **Create `dev-environment-audit` skill**
   - Detect installed MCPs and CLI tools
   - Compare against "ideal set" per project type
   - Propose installations with user confirmation
   - Document in `docs/DEV-ENVIRONMENT.md`

5. **Split `visual-frontend-mastery` if needed**
   - If it grows past 600 lines, extract Phase 1 extended discovery to separate file

6. **Documentation**
   - Update `README.md` with new skill descriptions and examples
   - Add a `CONTRIBUTING.md`
   - Create `CHANGELOG.md`

7. **CI/CD**
   - Add GitHub Actions to validate `SKILL.md` frontmatter
   - Validate skill names match directory names
   - Check line count < 500 (currently failing for visual-frontend-mastery)

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
│   └── visual-frontend-mastery/
│       └── SKILL.md                   # Custom frontend skill
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

Last updated: 2026-05-23
Session: Visual Frontend Mastery creation + testing + GitHub setup

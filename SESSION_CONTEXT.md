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

### Issue 3: Skill Line Count — RESOLVED
**Problem:** `visual-frontend-mastery` was ~545 lines (exceeded 500-line limit).
**Status:** ✅ FIXED. Split into SKILL.md (302 lines) + 3 guides.

---

## Immediate Next Steps (Priority Order)

1. **Test existing skills in a real project**
   - Create a test project with `init-agents`
   - Verify `project-health-check` blocks on existing code
   - Verify `spec-driven-development` does research + critical challenge
   - Verify `architecture-analysis` proposes 2-3 options with honest trade-offs
   - Verify `visual-frontend-mastery` creates design lock and follows tokens

2. **Create `dev-environment-audit` skill**
   - Detect installed MCPs and CLI tools
   - Compare against "ideal set" per project type
   - Propose installations with user confirmation
   - Document in `docs/DEV-ENVIRONMENT.md`

3. **Documentation**
   - Update `README.md` with concrete usage examples for each skill
   - Add `CONTRIBUTING.md` for future collaborators
   - Create `CHANGELOG.md` tracking skill versions

4. **CI/CD**
   - Add GitHub Actions to validate `SKILL.md` frontmatter
   - Validate skill names match directory names
   - Check line count < 500 for all custom skills
   - Validate all guides referenced in SKILL.md actually exist

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
│   └── architecture-analysis/
│       └── SKILL.md                   # Evaluate stack/pattern options with trade-offs
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
Session: architecture-analysis skill creation + visual-frontend-mastery refactor

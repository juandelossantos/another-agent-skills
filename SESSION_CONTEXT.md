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

### Issue 3: Skill Line Count — RESOLVED
**Problem:** `visual-frontend-mastery` was ~545 lines (exceeded 500-line limit).
**Status:** ✅ FIXED. Split into SKILL.md (302 lines) + 3 guides: DISCOVERY-GUIDE.md, ANIMATION-GUIDE.md, EXAMPLES.md.

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

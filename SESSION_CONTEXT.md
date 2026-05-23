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

### 2. Custom Skill: `visual-frontend-mastery`
**Location:** `skills/visual-frontend-mastery/SKILL.md`
**Current version:** Includes Phase 0 (Language Detection), Phase 1 (Discovery Gate), Phase 2 (Contracts), Phase 3-7 (Stack, Anti-Slop, Animation, Build, QA)

**Key features:**
- Language detection (Spanish/English/Other)
- Mandatory Discovery Gate with 5+ questions
- Extended discovery for logic/data/security/scalability
- Anti-AI-slop rules (no Inter, no Tailwind generics, no generic layouts)
- Stack lock-in: Next.js 16, Tailwind v4, shadcn/ui, Framer Motion
- Animation system: Framer Motion, CSS `animation-timeline`, WAAPI
- `prefers-reduced-motion` mandatory
- QA gates: 10 checks before delivery

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
**Problem:** `visual-frontend-mastery` is ~430 lines.
**Status:** Under the 500-line limit but approaching it.
**Decision:** Keep it as-is for now. If it grows beyond 500 lines, split extended discovery questions into a reference file.

---

## Immediate Next Steps (Priority Order)

1. **Test the fixed setup**
   - Open a new session in `another-agent-skills`
   - Verify `init-agents` works
   - Test that `visual-frontend-mastery` properly asks discovery questions before coding
   - If it still jumps to code, investigate OpenCode's system prompt behavior

2. **Add more skills**
   Consider creating:
   - `backend-api-mastery` — REST/GraphQL, Prisma, tRPC, error handling
   - `fullstack-shipping` — End-to-end build, test, deploy workflows
   - `mobile-react-native` — React Native patterns, Expo

3. **Documentation**
   - Update `README.md` with usage examples
   - Add a `CONTRIBUTING.md` for future collaborators
   - Create a `CHANGELOG.md`

4. **CI/CD**
   - Add GitHub Actions to validate `SKILL.md` frontmatter
   - Validate skill names match directory names
   - Check line count < 500

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

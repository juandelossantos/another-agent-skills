# Another Agent Skills

**Production-grade agent skills for OpenCode (and any AI coding agent).**

A curated, opinionated collection of **14 custom skills** that turn AI assistants into disciplined senior engineers and intentional visual designers. Covers the full development lifecycle: **web, PWA, mobile, desktop, API, CI/CD, architecture, quality, and environment** — with stack-agnostic principles and concrete implementations for any modern framework.

**37 skills total** (14 custom + 23 official from `addyosmani/agent-skills`).

---

## What's Included

| Skill | What It Does | Trigger |
|---|---|---|
| `engineering-fundamentals` | Universal philosophy: discovery, contracts, anti-slop, quality gates | Implicitly applied by all skills |
| `frontend-web` | Production-grade web UIs with locked stack and anti-AI-slop rules | Any web frontend/visual task |
| `frontend-pwa` | Installable, offline-first web apps for all devices with native migration path | PWA, offline, installable, hybrid |
| `frontend-mobile` | Native mobile apps with platform compliance (iOS HIG, Android Material 3) | Mobile app, React Native, Flutter |
| `frontend-desktop` | Cross-platform desktop apps with native OS integration | Tauri, Electron, desktop app |
| `user-onboarding` | Capture user preferences once, persist across all projects in `~/.config/opencode/user-profile.json` | First session, "my preferences" |
| `project-health-check` | Audit existing codebases before new work. Blocks until user decides | Existing projects, returning after gap |
| `spec-driven-development` | **(Overrides official)** Research-backed specs with critical thinking | New projects, features, ambiguous requirements |
| `git-init-and-versioning` | Git repo, mono/multi-repo, .gitignore, .env.example, branching, pre-commit gates | After specs locked, before code |
| `architecture-analysis` | Evaluate 2-3 architecture options with honest trade-offs. Challenge assumptions | Stack/pattern decisions |
| `dev-environment-audit` | Audit MCPs, CLI tools, runtimes. Propose installations with justification | Project start, before build |
| `backend-api-mastery` | Production APIs: protocol, database, auth, error handling, testing, docs | API work, backend services |
| `fullstack-shipping` | CI/CD, deployment, monitoring, rollback, launch checklists | Deploy, ship, launch |
| `project-metrics` | Empirical quality logging: build pass rate, rework, coverage, discovery time | Background, "show metrics" |

**Stack coverage:** React/Next.js, Vue, Svelte, Angular, React Native, Flutter, Tauri, Electron, Node.js, Python, Go, Rust, PostgreSQL, MongoDB, SQLite, and more.

**Every skill uses lazy loading:** SKILL.md is an index (~200 lines) + guides load on-demand per phase. Saves agent context, improves precision.

---

## Quick Start (One Command)

```bash
# 1. Clone this repository
git clone https://github.com/YOUR_USERNAME/another-agent-skills.git
cd another-agent-skills

# 2. Run the installer
bash install.sh

# 3. Reload your shell
source ~/.zshrc
```

That's it. OpenCode will now see **37 skills** globally (14 custom + 23 official).

---

## ⚠️ Start Every New Project With `init-agents`

**This step is mandatory.** Before you ask the agent to do anything in a new project, run:

```bash
init-agents
```

This copies `AGENTS.md` into your current directory, which tells OpenCode to:

1. **Use skills** — Without `AGENTS.md`, the agent may ignore skills and jump straight to coding.
2. **Follow the lifecycle** — DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP.
3. **Respect anti-rationalization rules** — Prevents the agent from skipping steps with excuses like "this is too small for a skill."

### When to use it

| Situation | Use `init-agents`? |
|---|---|
| New project | ✅ **Always** — First step before any work |
| Existing project without `AGENTS.md` | ✅ Yes — Activates skill-driven mode |
| Project already has `AGENTS.md` | ❌ No — Already initialized |

> **Note:** If `init-agents` is not found, run `source ~/.zshrc` first to load the alias.

---

## What the Installer Does

| Step | Action | Result |
|---|---|---|
| 1 | Clones `addyosmani/agent-skills` (23 official skills) | `~/.config/opencode/.agent-skills-remote/` |
| 2 | Symlinks official skills | `~/.config/opencode/skills/` |
| 3 | Copies 14 custom skills from this repo | All custom skills available globally |
| 4 | Adds aliases to `~/.zshrc` | `init-agents`, `update-global-skills` |
| 5 | Enables daily auto-update | Skills stay current automatically |

**Verification:** After install, `install.sh` checks all 14 custom skills are present and reports any missing.

---

## Available Aliases

| Alias | Usage |
|---|---|
| `init-agents` | In any project: copies `AGENTS.md` to initialize agent rules |
| `update-global-skills` | Manually pulls latest changes from remote skill repos |

---

## Daily Auto-Update

Every time you open a terminal, the script checks if your global skills were updated today. If not, it silently runs `git pull` in the background. Your skills are always fresh.

---

## Restoring on a New Machine

Lost your laptop? Switching to a new one? No problem:

```bash
git clone https://github.com/YOUR_USERNAME/another-agent-skills.git
cd another-agent-skills
bash install.sh
source ~/.zshrc
```

All skills restored in under a minute.

---

## Customizing Your Skills

1. Edit any `SKILL.md` inside `skills/` in this repo.
2. Re-run the installer:
   ```bash
   bash install.sh
   ```
3. Changes are pushed to your global OpenCode skills directory instantly.

**For maintainers:** All internal refinement work (audits, reviews, simulations, roadmaps) goes in `development/` — see `DEVELOPMENT.md`.

---

## Directory Structure

```
another-agent-skills/
├── README.md                          # This file
├── DEVELOPMENT.md                     # Guide for maintainers: development/ convention
├── install.sh                         # One-command global installer
├── AGENTS.md                          # Universal skill-driven execution rules (11 rules)
├── LICENSE                            # MIT
├── skills/                            # 14 custom skills (SKILL.md + lazy-loaded guides)
│   ├── engineering-fundamentals/      # Foundation: discovery, contracts, anti-slop, gates
│   ├── project-metrics/               # Background quality logging
│   ├── frontend-web/                  # Web: Next.js, React, Tailwind, Framer Motion
│   ├── frontend-pwa/                  # PWA: offline-first, installable, Capacitor migration
│   ├── frontend-mobile/               # Mobile: React Native, Flutter, iOS HIG, Material 3
│   ├── frontend-desktop/              # Desktop: Tauri v2, Electron, native OS integration
│   ├── project-health-check/          # Audit existing codebases
│   ├── spec-driven-development/       # Research-backed spec writing
│   ├── user-onboarding/               # Persistent user preferences
│   ├── git-init-and-versioning/       # Git setup, branching, pre-commit gates
│   ├── architecture-analysis/         # Stack/pattern decisions with trade-offs
│   ├── dev-environment-audit/         # MCPs, CLI tools, runtime verification
│   ├── backend-api-mastery/           # API design: protocol, DB, auth, testing
│   └── fullstack-shipping/            # CI/CD, deployment, monitoring, launch checklists
└── development/                       # Internal: audits, reviews, simulations (git-ignored)
```

**Lazy loading pattern:** Each skill's `SKILL.md` is an index (~200 lines max). Detailed guides (`*-GUIDE.md`) load on-demand as the agent reaches each phase. This keeps initial context small and precise.

---

## Requirements

- **Git**
- **Bash**
- **Zsh** (for aliases and auto-update)
- **OpenCode** installed

---

## Philosophy

- **Skills over prompts.** Structured workflows beat vague instructions.
- **Anti-rationalization.** Every skill includes common excuses agents use to skip steps — and why they're wrong.
- **Stack lock-in.** No "use whatever version." Locked, modern, proven stacks only.
- **Framework-agnostic patterns, stack-specific examples.** Core concepts work everywhere; code snippets adapt to your chosen stack.
- **Lazy loading.** Skills load as indices (~200 lines) + guides on-demand. Saves context, improves precision.
- **Token optimization.** Caveman-inspired compression applied to all skills (-30-55% per skill) without losing correctness.

---

## Contributing

1. Fork the repo
2. Add or improve a skill in `skills/`
3. Follow lazy loading: SKILL.md as index, detailed content in `*-GUIDE.md`
4. Follow token optimization: drop filler, imperative voice, no duplication
5. Test with `bash install.sh`
6. Open a PR

**Development artifacts:** All analysis, review, simulation, and refinement files go in `development/` (git-ignored). See `DEVELOPMENT.md`.

---

## Credits & Acknowledgments

This project builds on the work of many people and communities:

- **Addy Osmani** — [`addyosmani/agent-skills`](https://github.com/addyosmani/agent-skills) (23 official skills). The foundation and standard we extend.
- **Julius Brussee** — [`caveman`](https://github.com/JuliusBrussee/caveman) (64.4k ⭐). Inspiration for our token optimization approach.
- **OpenCode Team** — For the skill framework and invocation system.
- **Vercel / Next.js Team** — Modern web stack standards.
- **Tauri / Electron Teams** — Cross-platform desktop tooling.
- **Capacitor / Ionic Team** — Web-to-native bridge technology.

---

## License

MIT © 2026

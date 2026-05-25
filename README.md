# Another Agent Skills

**Production-grade agent skills for OpenCode (and any AI coding agent).**

A curated, opinionated collection of skills that turn AI assistants into disciplined senior engineers and intentional visual designers. Designed for **JavaScript/TypeScript, React, Next.js, React Native, Flutter, and TanStack** stacks across web, mobile, and desktop platforms.

---

## What's Included

| Skill | What It Does | Trigger |
|---|---|---|
| `engineering-fundamentals` | Universal philosophy for all platform skills: discovery, contracts, anti-slop, quality gates | Implicitly applied by all skills |
| `frontend-web` | Build distinctive, animated, production-grade web UIs with a locked modern stack and anti-AI-slop rules | Any web frontend/visual task |
| `frontend-pwa` | Build installable, offline-first web apps designed for all devices and future native distribution via Capacitor/Ionic | PWA, offline app, installable, Capacitor, hybrid |
| `frontend-mobile` | Build production-grade mobile apps with native design tokens, animations, and platform compliance | Any mobile app/React Native/Flutter task |
| `frontend-desktop` | Build cross-platform desktop apps with native OS integration (menus, tray, shortcuts, file dialogs) | Tauri, Electron, desktop app |
| `user-onboarding` | Capture user preferences once (stack, design, workflow) and persist across all projects in `~/.config/opencode/user-profile.json` | First session, "my preferences", "remember my stack" |
| `project-health-check` | Audit existing codebases for compliance before any new work. Blocks until user decides: fix, proceed with caution, or ignore | Existing projects, returning after gap, explicit audits |
| `spec-driven-development` | **(Overrides official)** Research-backed specs with critical thinking, user challenge, and architecture integration. Never blind obedience | New projects, features, ambiguous requirements |
| `git-init-and-versioning` | Initialize Git repo, decide mono/multi-repo, create .gitignore and .env.example, set branching strategy, configure pre-commit auto-review gates | After specs locked, before any code written |
| `architecture-analysis` | Evaluate 2-3 architecture options with honest trade-offs. Challenge user assumptions. Lock decisions in spec + ARCHITECTURE.md | Non-trivial projects requiring stack/pattern decisions |
| `dev-environment-audit` | Audit MCPs, CLI tools, runtimes. Propose installations with justification. Document in DEV-ENVIRONMENT.md | Any project start, before build, environment setup |
| `backend-api-mastery` | Design production APIs with protocol choice, database design, auth, error handling, testing, documentation. Lock in API-DESIGN.md | API work, backend services, database design |
| `fullstack-shipping` | End-to-end CI/CD, testing, deployment, monitoring, rollback, launch checklists. Lock in DEPLOYMENT.md | Deploy, ship, launch, production readiness |
| `project-metrics` | Log empirical quality metrics automatically: build pass rate, rework rate, coverage, discovery time. Quality report on demand. | Background logging, "show metrics", "quality report" |

This repo also bootstraps the **23 official skills** from `addyosmani/agent-skills` globally on your machine (37 total).

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
| 1 | Clones `addyosmani/agent-skills` | `~/.config/opencode/.agent-skills-remote/` |
| 2 | Symlinks all 23 official skills | `~/.config/opencode/skills/` |
| 3 | Copies custom skills from this repo | `frontend-web`, `frontend-mobile`, etc. available globally |
| 4 | Adds aliases to `~/.zshrc` | `init-agents`, `update-global-skills` |
| 5 | Enables daily auto-update | Skills stay current automatically |

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

---

## Directory Structure

```
another-agent-skills/
├── README.md                          # This file
├── install.sh                         # One-command global installer
├── AGENTS.md                          # Universal skill-driven execution rules
├── LICENSE                            # MIT
├── skills/
│   ├── engineering-fundamentals/
│   │   └── SKILL.md                   # Universal philosophy: discovery, contracts, anti-slop, quality gates
│   ├── project-metrics/
│   │   └── SKILL.md                   # Automatic quality logging: builds, commits, gates, coverage (background)
│   ├── frontend-web/
│   │   ├── SKILL.md                   # Web frontend implementation (built on fundamentals)
│   │   ├── DISCOVERY-GUIDE.md         # Web-specific discovery questions
│   │   ├── ANIMATION-GUIDE.md         # Web animation patterns (Framer Motion)
│   │   └── EXAMPLES.md                # Web walkthroughs & troubleshooting
│   ├── frontend-pwa/
│   │   ├── SKILL.md                   # PWA / hybrid app implementation (built on fundamentals)
│   │   ├── DISCOVERY-GUIDE.md         # PWA-specific discovery
│   │   └── EXAMPLES.md                # PWA walkthroughs
│   ├── frontend-mobile/
│   │   ├── SKILL.md                   # Mobile frontend implementation (built on fundamentals)
│   │   ├── DISCOVERY-GUIDE.md         # Mobile-specific discovery questions
│   │   ├── ANIMATION-GUIDE.md         # Mobile animation patterns (Reanimated)
│   │   └── EXAMPLES.md                # Mobile walkthroughs & troubleshooting
│   ├── frontend-desktop/
│   │   ├── SKILL.md                   # Desktop app implementation (Tauri v2 / Electron)
│   │   ├── DISCOVERY-GUIDE.md         # Desktop-specific discovery (OS, APIs, distribution)
│   │   ├── PLATFORM-GUIDE.md          # Native OS integration (menus, tray, dialogs)
│   │   └── EXAMPLES.md                # Desktop walkthroughs & troubleshooting
│   ├── project-health-check/
│   │   └── SKILL.md                   # Audit existing codebases
│   ├── spec-driven-development/
│   │   └── SKILL.md                   # Research-backed spec writing (overrides official)
│   ├── user-onboarding/
│   │   └── SKILL.md                   # Capture user preferences globally
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
```

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
- **Framework-agnostic patterns, stack-specific examples.** Core concepts work everywhere; code snippets target React/Next.js/TanStack.

---

## Contributing

1. Fork the repo
2. Add or improve a skill in `skills/`
3. Test with `bash install.sh`
4. Open a PR

---

## License

MIT © 2026

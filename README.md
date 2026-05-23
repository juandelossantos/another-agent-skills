# Another Agent Skills

**Production-grade agent skills for OpenCode (and any AI coding agent).**

A curated, opinionated collection of skills that turn AI assistants into disciplined senior engineers and intentional visual designers. Designed for **JavaScript/TypeScript, React, Next.js, and TanStack** stacks.

---

## What's Included

| Skill | What It Does | Trigger |
|---|---|---|
| `visual-frontend-mastery` | Build distinctive, animated, production-grade UIs with a locked modern stack and anti-AI-slop rules | Any frontend/visual task |
| *(Coming soon)* `backend-api-mastery` | REST/GraphQL design, Prisma, tRPC, error handling | API work |
| *(Coming soon)* `fullstack-shipping` | End-to-end build, test, and deploy workflows | Fullstack projects |

This repo also bootstraps the **23 official skills** from `addyosmani/agent-skills` globally on your machine.

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

That's it. OpenCode will now see **24 skills** globally.

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
| 3 | Copies custom skills from this repo | `visual-frontend-mastery` available globally |
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
├── LICENSE                            # MIT
├── skills/
│   └── visual-frontend-mastery/
│       └── SKILL.md                   # Anti-AI-slop frontend skill
└── scripts/
    └── validate-skills.sh             # (Optional) CI validation
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

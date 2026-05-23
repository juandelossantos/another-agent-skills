# OpenCode Global Skills Setup

Bootstrap your OpenCode environment with production-grade agent skills on any machine.

## What This Does

This installer configures your system so that OpenCode automatically discovers and uses:

- **23 skills** from `addyosmani/agent-skills` (research, spec-driven, TDD, code review, shipping, etc.)
- **1 custom skill**: `visual-frontend-mastery` (intentional UI design, animations, anti-AI-slop rules)
- **Auto-update**: skills refresh daily from the remote repo
- **Shell aliases**: quick commands to initialize projects and update skills

## Quick Start

```bash
# 1. Clone this repository (or your fork)
git clone https://github.com/addyosmani/agent-skills.git
cd agent-skills

# 2. Run the installer
bash setup/install.sh

# 3. Reload your shell
source ~/.zshrc
```

Done. OpenCode will now see all skills globally.

## What Gets Installed

| Path | Purpose |
|---|---|
| `~/.config/opencode/.agent-skills-remote/` | Clone of the official agent-skills repo (auto-updated daily) |
| `~/.config/opencode/skills/` | Symlinks to all remote skills + your custom `visual-frontend-mastery` |
| `~/.zshrc` | Aliases `init-agents`, `update-global-skills`, and daily auto-update logic |

## Aliases

| Alias | What it does |
|---|---|
| `init-agents` | Copies `AGENTS.md` from the remote repo into your current project directory |
| `update-global-skills` | Manually pulls the latest changes from the remote agent-skills repo |

## Daily Auto-Update

Every time you open a terminal, the script checks if the remote repo was updated today. If not, it runs `git pull` silently in the background. This ensures your skills are always current without manual intervention.

## Updating the Custom Skill

If you edit `setup/opencode/visual-frontend-mastery/SKILL.md` in this repo, re-run the installer to push the changes to your global OpenCode skills directory:

```bash
bash setup/install.sh
```

## Restoring on a New Machine

If you lose your local setup or switch computers:

```bash
git clone https://github.com/addyosmani/agent-skills.git
cd agent-skills
bash setup/install.sh
source ~/.zshrc
```

All 24 skills will be back in under a minute.

## Troubleshooting

| Problem | Fix |
|---|---|
| `git not found` | Install Git first (`brew install git`, `apt install git`, etc.) |
| Skills not showing in OpenCode | Restart OpenCode or run `ls ~/.config/opencode/skills/` |
| `init-agents` not found | Run `source ~/.zshrc` to load the new aliases |
| Conflicts in `.zshrc` | The installer creates a backup (`~/.zshrc.backup.YYYYMMDD...`) before modifying |

## Structure

```
setup/
├── install.sh                           # Main installer script
├── opencode/
│   └── visual-frontend-mastery/
│       └── SKILL.md                     # Your custom skill
└── README.md                            # This file
```

# Another Agent Skills 👷

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Version: v1.1.0](https://img.shields.io/badge/version-1.1.0-blue.svg)](./RELEASE-NOTES.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Status: Production](https://img.shields.io/badge/status-production-green.svg)](./PROGRESS_STATUS.md)

**Production-grade agent skills that turn AI coding assistants into disciplined senior engineers.**
**No bloat. No shortcuts. Just process.**

Define → Plan → Build → Verify → Review → Ship. Every time.

> Designed for [**OpenCode**](https://opencode.ai) first. Portable to Claude Code, Cursor, and any agent via [`docs/AGENT-ADAPTERS.md`](./docs/AGENT-ADAPTERS.md).

---

## 📦 Latest Features

- **Release automation** — `scripts/release.sh` handles semver bumps, changelogs, git tags, and optional auto-push. Supports `-m` and `-y` for CI/agent usage.
- **Versioned releases** — `VERSION` + [`RELEASE-NOTES.md`](./RELEASE-NOTES.md) + [GitHub Releases](https://github.com/juandelossantos/another-agent-skills/releases) track every change.
- **Auto-update** — `init-agents` checks for updates daily. You choose when to pull.
- **5 specialized frontend skills** — `industrial-brutalist-ui`, `minimalist-ui`, `soft-premium-ui`, `output-skill`, `redesign-skill` for targeted design directions.
- **Design Core Extraction** — Three Dials System (Variance / Motion / Density) shared across all platforms via `engineering-fundamentals`.

---

## Quick Start

### Linux / macOS

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh          # Installs 45 skills globally
init-agents              # In any project: activates skill-driven mode
```

### Windows (PowerShell)

```powershell
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
.\install.ps1            # Installs 45 skills globally
init-agents              # In any project: activates skill-driven mode
```

**That's it.** Your AI agent now has 22 custom skills + 23 upstream skills.
The installer detects your shell (Zsh, Bash, Fish, PowerShell) and configures it automatically.

Run `init-agents` in every new project — it merges AGENTS.md without overwriting existing rules, and creates `.sessionrc`.

> **Safety:** Backs up before replacing. `init-agents` merges — never overwrites.
> **Auto-update:** Skills stay current with daily background pull.
> **Agent adapters:** `bash install.sh --agent claude` or `.\install.ps1 -Agent claude`

---

## Commands

After installation, these commands are available in your terminal:

| Command | What It Does |
|---|---|
| `init-agents` | Activates skill-driven mode in any project. Merges rules without overwriting. |
| `update-global-skills` | Pulls latest skills from upstream (`addyosmani/agent-skills`). |
| `bash install.sh` | Full installer: 45 skills, shell config, global scripts. |
| `bash uninstall.sh` | Removes shell config, scripts, and installed skills. |

These are **project commands** you run in your terminal. They are NOT skills — skills are what the agent loads automatically when it detects a matching task.

---

## What Makes This Different

Most agent skill frameworks give you a library of prompts. This one gives you an engineering discipline.

**Context budget engineering** — Other frameworks load all rules eagerly into your agent's limited context. We lazy-load: SKILL.md is a ~200-line index; detailed guides load only when needed. Result: 589 lines always-loaded instead of 1,500+.

**Mutation approval gate** — No other framework prevents an agent from committing to prod without asking. Ours does. Every git mutation requires your explicit "yes". Enterprise-ready safety.

**Behavioral guardrails** — Other frameworks assume agents follow instructions. We built a 25-entry anti-rationalization table because they won't always. Plus pre-action checklist and automatic context eviction at 70% usage.

**Unified lifecycle, not silos** — 45 skills from 3 sources (addyosmani lifecycle, taste-skill design, and custom safety) wired into a single spec→plan→build→verify→review→ship pipeline. Every skill follows the same lazy-loading pattern.

**Versioned and auto-updating** — VERSION file, RELEASE-NOTES, daily update checks. You choose when to pull. No other skill framework versions itself.

> "Build a landing page" → loads `frontend-web` → discovery → design lock → spec → implementation.
> "Fix a bug" → loads `debugging-and-error-recovery` → repro test → root cause → fix → verify.
> Every task has a defined process. No guessing.

---

## Skills at a Glance

| Skill | When | What It Does |
|---|---|---|
| `engineering-fundamentals` | Implicit | Discovery, contracts, anti-slop, quality gates |
| `frontend-web` | Web/UI task | Next.js, React, Tailwind, Framer Motion |
| `frontend-pwa` | Offline/hybrid | Installable, offline-first, Capacitor migration |
| `frontend-mobile` | Mobile app | React Native, Flutter, iOS/Android compliance |
| `frontend-desktop` | Desktop app | Tauri v2, Electron, native OS integration |
| `backend-api-mastery` | API/backend | REST/GraphQL, DB, auth, testing, docs |
| `spec-driven-development` | New features | Research-backed specs with critical thinking |
| `architecture-analysis` | Stack decisions | 2-3 options evaluated with trade-offs |
| `git-init-and-versioning` | Project setup | Git init, .gitignore, branching, pre-commit gates |
| `fullstack-shipping` | Deploy/go-live | CI/CD, monitoring, rollback, launch checklist |
| `project-health-check` | Existing code | Full codebase audit before new work |
| `dev-environment-audit` | Before build | MCPs, CLI tools, runtime verification |
| `user-onboarding` | First session | 30 preferences asked once, persisted forever |
| `project-metrics` | Background | Build pass rate, rework, coverage logging |
| `multi-agent-orchestration` | >2 agents | Parallel/pipeline/swarm patterns with `task` tool |
| `cli-tools` | Build a CLI | Teaches agent to build CLIs (arg parsing, exit codes, colors, progress) |
| `industrial-brutalist-ui` | Hard/industrial design | Swiss type, sharp contrast, experimental layout |
| `minimalist-ui` | Clean/product UI | Editorial design (Notion/Linear), restrained palette |
| `soft-premium-ui` | Polished/premium | Soft contrast, whitespace, spring motion |
| `output-skill` | Truncated output | Full output enforcement, no placeholder comments |
| `redesign-skill` | Existing codebase | UI audit first, then fix structure and styling |

**Stack agnostic:** React/Next.js, Vue, Svelte, React Native, Flutter, Tauri, Electron, Node.js, Python, Go, Rust, PostgreSQL, MongoDB, SQLite — any modern framework.

---

## How to Use

### New Project

```bash
init-agents          # Creates AGENTS.md + .sessionrc with purpose
# Then start working. The agent loads the matching skill automatically.
```

### Existing Project

```bash
init-agents          # Merges skills into existing AGENTS.md or CLAUDE.md — never overwrites
```

### Other AI Agents (Claude Code, Cursor)

```bash
# Linux / macOS
bash install.sh --agent claude    # Creates CLAUDE.md
bash install.sh --agent cursor    # Creates .cursorrules
```

```powershell
# Windows
.\install.ps1 -Agent claude       # Creates CLAUDE.md
.\install.ps1 -Agent cursor       # Creates .cursorrules
```

See [`docs/AGENT-ADAPTERS.md`](./docs/AGENT-ADAPTERS.md) for full instructions.

---

## Documentation Map

| File | What It Is |
|---|---|
| [`AGENTS.md`](./AGENTS.md) | Core rules: context persistence, intent mapping, lifecycle, mutation approval |
| [`AGENTS-EXTENDED.md`](./AGENTS-EXTENDED.md) | Full anti-rationalization table, Commit Manifest Protocol, project-type matrix |
| [`EXAMPLES.md`](./EXAMPLES.md) | Before/after skill usage demonstrations |
| [`docs/EXAMPLES.md`](./docs/EXAMPLES.md) | Full 366-line before/after reference |
| [`PROGRESS_STATUS.md`](./PROGRESS_STATUS.md) | Project state, roadmap, and phased completion |
| [`RELEASE-NOTES.md`](./RELEASE-NOTES.md) | Changelog and version history (current: v1.1.0) |
| [`HEALTH-CHECK.md`](./HEALTH-CHECK.md) | Project health audit (23/24 passes, 0 criticals) |
| [`DEVELOPMENT.md`](./DEVELOPMENT.md) | Maintainer conventions and artifact rules |
| [`STACK_CONFIG_TEMPLATE.md`](./STACK_CONFIG_TEMPLATE.md) | Stack-agnostic configuration template |
| [ADRs/](./ADRs/) | Architecture Decision Records |
| [`install.sh`](./install.sh) | Cross-shell installer (Linux/macOS) |
| [`install.ps1`](./install.ps1) | PowerShell installer (Windows) |
| [`uninstall.sh`](./uninstall.sh) | Clean uninstaller (Linux/macOS) |
| [`uninstall.ps1`](./uninstall.ps1) | Clean uninstaller (Windows) |
| `skills/<name>/SKILL.md` | Individual skill index (all ≤ 250 lines) |
| `skills/<name>/*-GUIDE.md` | Phase-specific guides (loaded on-demand) |

**Every skill follows the same pattern:** SKILL.md as index + guides per phase. Lazy loading keeps initial context under 600 lines.

---

## Contributing

Pull requests are welcome. Whether it's a new skill, a guide improvement, or a bug fix — the bar is quality, not complexity.

**Quick start for contributors:**

1. Fork the repo.
2. Add or improve a skill in `skills/`.
3. Follow lazy loading: SKILL.md as index, `*-GUIDE.md` for details.
4. Keep it tight: no filler, no duplication, imperative voice.
5. Test with `bash install.sh`.
6. Open a PR.

**Guides and conventions:** [`DEVELOPMENT.md`](./DEVELOPMENT.md) covers the artifact convention (`development/` is git-ignored), skill templates, and review process.

**Blocked on something?** [Open an issue](https://github.com/juandelossantos/another-agent-skills/issues) — I prioritize by demand.

---

## Uninstall

```bash
# Linux / macOS — removes shell config, scripts, skills, remote repo
bash uninstall.sh

# Windows
.\uninstall.ps1
```

Does not remove your user profile (`~/.config/opencode/user-profile.json`) or this repository.

## Requirements

- **Git** + **Bash** (Linux/macOS) or **PowerShell** (Windows)
- **OpenCode** recommended. Adapters available for Claude Code and Cursor.

---

## Credits

Built on the shoulders of:
- **Addy Osmani** — [`agent-skills`](https://github.com/addyosmani/agent-skills) (23 upstream skills)
- **Leonxlnx** — [`taste-skill`](https://github.com/Leonxlnx/taste-skill) — design taste and anti-slop frontend
- **Julius Brussee** — [`caveman`](https://github.com/JuliusBrussee/caveman) — token optimization inspiration
- **Andrej Karpathy** — Behavioral observations on LLM coding failures
- **OpenCode team** — Native skill framework and invocation system

---

## License

MIT © 2026

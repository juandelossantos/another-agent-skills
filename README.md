# Another Agent Skills

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Status: Production](https://img.shields.io/badge/status-production-green.svg)](./PROGRESS_STATUS.md)

**Production-grade agent skills that turn AI coding assistants into disciplined senior engineers.**

Define → Plan → Build → Verify → Review → Ship. Every time. Without the bloat.

> Designed for [**OpenCode**](https://opencode.ai) first. Portable to Claude Code, Cursor, and any agent via [`docs/AGENT-ADAPTERS.md`](./docs/AGENT-ADAPTERS.md).

---

## Quick Start

### Linux / macOS

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh          # Installs 38 skills globally
init-agents              # In any project: activates skill-driven mode
```

### Windows (PowerShell)

```powershell
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
.\install.ps1            # Installs 38 skills globally
init-agents              # In any project: activates skill-driven mode
```

**That's it.** Your AI agent now has 15 custom skills + 23 upstream skills.
The installer detects your shell (Zsh, Bash, Fish, PowerShell) and configures it automatically.

Run `init-agents` in every new project — it merges AGENTS.md without overwriting existing rules, and creates `.sessionrc`.

> **Safety:** Backs up before replacing. `init-agents` merges — never overwrites.
> **Auto-update:** Skills stay current with daily background pull.
> **Agent adapters:** `bash install.sh --agent claude` or `.\install.ps1 -Agent claude`

---

## What Makes This Different

Most agent skills are encyclopedias — 500+ lines dumped into context before the agent understands the task. These skills do the opposite:

- **Think Before Coding** — Skills force discovery, specs, and contracts before any code. Silent assumptions → costly rewrites.
- **Lazy Loading** — SKILL.md is an index (~200 lines). Detailed guides load only when needed. Agent context stays lean.
- **Mutation Approval Gate** — No git commit, push, or merge without your explicit "yes". Configurable per preference.
- **Behavioral Guardrails** — Anti-rationalization, pre-action checklists, context eviction. The agent follows rules, not shortcuts.

> "Build a landing page" → loads `frontend-web` skill → discovery → design lock → spec → implementation.
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
| [`HEALTH-CHECK.md`](./HEALTH-CHECK.md) | Project health audit (22/24 passes, 0 criticals) |
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
- **Julius Brussee** — [`caveman`](https://github.com/JuliusBrussee/caveman) — token optimization inspiration
- **Andrej Karpathy** — Behavioral observations on LLM coding failures
- **OpenCode team** — Native skill framework and invocation system

---

## License

MIT © 2026

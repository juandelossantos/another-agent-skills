---
title: "Getting started"
description: "Install Another Agent Skills, run init-agents, and see the local gate block a commit that has no matching test."
lang: "en"
order: 2
section: "start"
tldr: "Install with git clone or the pinned curl bootstrap (or npm); run init-agents in any project; the installer detects your agent and stack and wires the matching skills and hooks."
---

## Prerequisites

- **Git** on `PATH`.
- **Bash** on Linux and macOS, or **PowerShell** on Windows (Git Bash is the recommended Windows path).
- An agent: **OpenCode** is the default, or any compatible agent such as Claude Code, Cursor, Codex, Gemini CLI, or Kiro.

## Install the framework

The installer places the skills globally, once per machine. Any project can use them without duplicating the files.

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh
```

Windows (PowerShell):

```powershell
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
.\install.ps1
```

Or use the pinned release bootstrap, which downloads the tagged release, verifies its checksum, and links the `aas` CLI:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

The npm wrapper ships no payload of its own:

```bash
npx @juandelossantos/another-agent-skills install
```

## Initialize a project

Run `init-agents` inside the project. It merges `AGENTS.md` without overwriting your rules, links the framework files, detects your stack, and installs the hooks that apply to the current repository shape.

```bash
cd your-project
init-agents
```

For a brand new project:

```bash
mkdir my-project && cd my-project
git init
init-agents
```

## What happens in an existing project

1. Detects an existing `AGENTS.md`, `CLAUDE.md`, or `.cursorrules`.
2. Backs up the existing file.
3. Merges the framework rules, preserving yours.
4. Detects your stack and creates `STACK_CONFIG.md` if it is missing.
5. Installs hooks and backs up any existing hooks.
6. Prints a "Next steps" summary.

## Stack detection

`init-agents` detects your stack from lockfiles and config files, then writes `STACK_CONFIG.md` with your real commands (test, lint, build, dev). Every skill reads from that file.

| Stack | Detects from |
|---|---|
| Node.js | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb` |
| Rust | `Cargo.lock`, `Cargo.toml` |
| Python | `poetry.lock`, `Pipfile.lock`, `pyproject.toml` |
| Go | `go.sum`, `go.mod` |
| Ruby | `Gemfile.lock`, `Gemfile` |
| Dart | `pubspec.lock`, `pubspec.yaml` |

## Verify enforcement

Make a code change with no matching test and watch the local gate block the commit:

```bash
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

The same check runs remotely as the required `gates` status. See [Enforcement](../enforcement/).

## Troubleshooting

| Issue | Solution |
|---|---|
| `init-agents: command not found` | Reload your shell config, for example `source ~/.zshrc`. |
| `STACK_CONFIG.md not found` | Run `init-agents` in the project. |
| Pre-commit hook not firing | Re-run `bash scripts/init-agents.sh`. |
| "No commit approval found" | The agent must present a DECISION POINT, get an explicit approval, then run `bash scripts/commit-approval.sh "message"`. |

## Migrating or repairing

If you inherited a project that already used the framework, or you changed machines, repair without losing data:

```bash
aas doctor
init-agents --dry-run
init-agents --repair
```

> A teammate who clones your project without the framework is not blocked: the project still runs. The remote `gates` check enforces the rules for everyone on the repository.

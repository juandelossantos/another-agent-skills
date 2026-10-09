---
title: "Agents"
description: "Compatibility matrix and setup per agent: OpenCode, Claude Code, Cursor, Kiro, and any agent that uses git."
lang: "en"
order: 20
section: "reference"
tldr: "Git hooks work everywhere. Skills load automatically for OpenCode and Claude Code, and the installer detects the agent and wires the matching skills and hooks."
---

## What works where

| Feature | OpenCode | Claude Code | Cursor | Kiro | Any git agent |
|---|---|---|---|---|---|
| Git hooks | Auto | Auto | Auto | Auto | Auto |
| Manifest gate | Auto | Auto | Auto | Auto | Auto |
| `SOUL.md` / `AGENTS.md` | Auto | Manual | Manual | Manual | Manual |
| `SKILL.md` concepts | Auto | Auto | Manual | Manual | Manual |
| Stack detection | Auto | Auto | Auto | Auto | Auto |

## Setup per agent

### OpenCode (default)

No extra setup. Skills load automatically via the skill tool.

```bash
bash install.sh
cd your-project
init-agents
```

### Claude Code

Full parity: the 58 skills install to `~/.claude/skills/` (auto-discovered in every project) and the enforcement hooks wire themselves into `.claude/settings.json`. To also load `SOUL.md` and `AGENTS.md` rules, copy the key principles into your `CLAUDE.md`; that part stays manual.

```bash
bash install.sh --agent claude
```

### Cursor

Creates `.cursor-plugin/agent-discipline/` with hooks. Append `SOUL.md` and `AGENTS.md` to `.cursorrules`.

```bash
bash install.sh --agent cursor
```

### Kiro

Creates `.kiro/hooks/agent-discipline.json` with the pre-flight, commit approval, and edit guard hooks.

```bash
bash install.sh --agent kiro
```

### Any git-based agent

Copy the git hooks into the project. They work with any agent that uses git.

```bash
cp scripts/git-hooks/pre-commit .git/hooks/pre-commit
cp scripts/git-hooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg
cp scripts/commit-approval.sh scripts/
```

## Portable principles

The core principles are agent-agnostic. Adopt them anywhere.

| Principle | How to use it |
|---|---|
| TOOL_GAP | When tools cannot verify, report "ship status unknown." Never fake success. |
| Severity labels | Classify findings: blocking, important, nit, suggestion, learning, praise. |
| Error path design | Every tool call, gate, and loop needs a failure path, designed at build time. |
| Continuation over recap | After context loss, resume. Ask "Where were we?" instead of re-explaining. |
| Drift detection | Check docs against reality regularly: stats, versions, features, commands, links. |
| Manifest gate | Require a written summary of what changed before commit approval. |

> Any agent that reads `AGENTS.md` is supported. The installer detects the agent and wires the matching skills and hooks.

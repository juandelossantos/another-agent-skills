---
title: "Move to another machine"
description: "Recreate your setup on a new computer: install the same framework version, run aas install in the project, confirm with aas doctor, and the project works without reconfiguring it."
lang: "en"
order: 7
section: "tutorials"
tldr: "The framework installs once per machine. On a new computer install the same version, run aas install in the project to re-wire the local hooks, then aas doctor to confirm. The project's committed config is unchanged."
---

## What you will do

Your project lives in git; the framework lives on the machine. On a new computer you reinstall the framework once, re-wire the project's local hooks, and confirm the environment. Nothing in the repository changes.

**You will end with:** the same project on the new machine, with the same version, the same rules, and the same enforcement.

## Before you start

- The project already uses the framework (it has `.aas/config`, `AGENTS.md`, and `STACK_CONFIG.md` committed).
- Git and your agent of choice installed on the new machine.

## 1. Install the same version on the new machine

Use the pinned release so the version matches what the project pins:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

To pin an exact version:

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash -s -- --version v6.2.0
```

> npm and Homebrew are **coming soon**. Use the pinned `curl` bootstrap or `git clone` today.

## 2. Activate the framework in the project

```bash
git clone https://github.com/OWNER/REPO.git
cd REPO
aas install --agents auto
```

`aas install` runs the project install: it re-wires the per-agent skills and hooks, and re-merges `AGENTS.md` without touching your rules. This is the step that recreates the **local** hooks (`.git/hooks/`) that are not stored in git.

## 3. Confirm the environment

```bash
aas doctor
```

## What you should see

```text
[aas] aas 6.2.0
[aas] source: /home/you/.local/share/another-agent-skills/6.2.0
[aas] install root: /home/you/.local/share/another-agent-skills
agents=opencode
agent:opencode=1.0.0
opencode=1.0.0
agent-discipline=dual-contract
```

The project is ready. The committed files (`.aas/config`, `AGENTS.md`, `STACK_CONFIG.md`, `.github/workflows/gates.yml`) are unchanged; only the machine-level install and the local hooks were recreated.

## If the versions differ

If the installed framework differs from the project's pinned version, you get a **non-blocking** advisory:

```text
[aas] advisory: project pins v6.2.0, framework v6.3.0 is installed — run "aas upgrade" then "init-agents --repair" (non-blocking)
```

Run `aas upgrade` to move forward, then `init-agents --repair` to migrate the project. See [Migrate a legacy project](../migrate-a-legacy-project/).

## If it does not work

| Symptom | Fix |
|---|---|
| `aas: command not found` | The bootstrap links `aas` in `$HOME/.local/bin`; add it to `PATH` and reload your shell. |
| Hooks do not fire after cloning | Run `aas install` (or `init-agents`) inside the project — the local hooks are not committed. |
| The agent does not load the skills | Run `aas doctor` and check the `agents=` and `agent-discipline=` lines. |

## Next

- [Distribution and upgrades](../distribution/) documents every channel and `aas upgrade`.
- [FAQ](../faq/) answers the common questions about installing once versus per project.

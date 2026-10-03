---
title: "Migrate a legacy project"
description: "Inherited a project that used an older Another Agent Skills layout? Run aas doctor, preview with init-agents --dry-run, then migrate with --repair without losing the team's AGENTS.md."
lang: "en"
order: 6
section: "tutorials"
tldr: "For a legacy project run aas doctor, then init-agents --dry-run to preview, then init-agents --repair. The repair removes absolute or broken framework symlinks and materializes agent config files; your team's AGENTS.md and custom files are preserved."
---

## What you will do

A project that used an older framework layout may hold absolute symlinks that broke when the framework moved, or a config file symlinked where it should be a real file. You will diagnose it, preview the migration, and repair it without losing your team's `AGENTS.md`.

**You will end with:** a portable project that pins the current framework version, with your rules intact and a backup of the original config.

## Before you start

- The framework installed once on your machine (see [Your first gated commit](first-gated-commit/)).
- The project with `AGENTS.md`, `STACK_CONFIG.md`, or framework symlinks from an older setup.

## 1. Diagnose the environment

```bash
cd legacy-project
aas doctor
```

## What you should see

`aas doctor` prints the installed version, the install root, the detected agents and their versions, and the `agent-discipline` plugin state:

```text
[aas] aas 6.2.0
[aas] source: /home/you/.local/share/another-agent-skills/6.2.0
[aas] install root: /home/you/.local/share/another-agent-skills
agents=opencode,claude
agent:opencode=1.0.0
agent:claude=2.0.0
opencode=1.0.0
agent-discipline=dual-contract
```

If the project has framework artifacts but no version marker, `init-agents` also warns:

```text
[init-agents] Legacy AAS project detected (AGENTS.md marker) with no version marker.
[init-agents]   Next: 'bash scripts/init-agents.sh --dry-run' then 'bash scripts/init-agents.sh --repair'
```

## 2. Preview the migration (no writes)

```bash
init-agents --dry-run
```

The dry run prints exactly what would change and mutates nothing. Read it before you run the real thing.

## What you should see

```text
[init-agents] DRY RUN — no changes will be made.
[init-agents] plan: back up AGENTS.md and append the AAS rules footer
[init-agents] plan: install portable hook shims (.git/hooks/pre-commit, commit-msg)
[init-agents] plan: write .aas/config (version 6.2.0)
[init-agents] plan: copy scripts/aas-resolve.sh → .aas/aas-resolve.sh
[init-agents] plan: create STACK_CONFIG.md
[init-agents] Dry run complete — nothing changed.
```

If it says `leave AGENTS.md (AAS rules already present)`, your rules are already merged and the migration will not touch them.

## 3. Migrate with --repair

```bash
init-agents --repair
```

The repair is non-destructive. It removes **absolute or broken** framework symlinks, then the normal (idempotent) install recreates the portable form. Agent config files that are symlinks are **materialized** into the project rather than deleted.

## What you should see

```text
[init-agents] Repairing legacy project (non-destructive)...
[init-agents] Removed absolute symlink rules/common → /old/path/rules/common
[init-agents] Removed broken symlink scripts/tdd-gate.sh
[init-agents] Materialized AGENTS.md from its symlink target
...
[init-agents] PROJECT UPDATED — RULES MERGED
    ✓ AGENTS.md — skill-driven rules merged
    ✓ .aas/config — pins the framework version
    ✓ .git/hooks/commit-msg — portable shim → $AAS_DIR
```

Your team's `AGENTS.md` content is merged, never replaced: the installer backs up the existing file and appends the framework rules footer.

## If it does not work

| Symptom | Fix |
|---|---|
| A custom hook blocks the install | Re-run with `init-agents --repair --force` to allow replacing custom hooks. |
| Version drift advisory appears | It is **non-blocking**. Run `aas upgrade`, then `init-agents --repair`. |
| Your rules are missing | Check the backup the installer created next to `AGENTS.md`; the merge is additive. |

## Next

- [Move to another machine](move-to-another-machine/) for the same portability story across computers.
- [Distribution and upgrades](../distribution/) documents `aas upgrade` and the drift advisory.

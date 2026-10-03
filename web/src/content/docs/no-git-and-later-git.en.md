---
title: "Start without git, add it later"
description: "Use Another Agent Skills in a folder with no git, then grow the enforcement as layers appear: git init, re-run init-agents for L1, add a GitHub remote, re-run again for L2."
lang: "en"
order: 5
section: "tutorials"
tldr: "init-agents installs each layer conditionally: hooks only when .git exists, and the gates workflow only when a GitHub remote exists. The rule is to re-run init-agents after git init and after adding the remote."
---

## What you will do

You do not need git to start. The framework works in a plain folder, then grows its enforcement as you add a repository and a remote. The key rule: **re-run `init-agents` after `git init` and after adding the remote.**

**You will end with:** the same folder upgraded from convention-only, to L1 hooks, to the L2 workflow, without reinstalling anything.

## Before you start

- The framework installed once on your machine (see [Your first gated commit](first-gated-commit/)).
- An agent that reads `AGENTS.md`.

## 1. Start with no git (convention only)

```bash
mkdir scratch && cd scratch
init-agents
```

`init-agents` merges `AGENTS.md` and writes `STACK_CONFIG.md`, but it cannot install hooks: there is no `.git` directory. Enforcement is **convention-only** — the rules and skills guide the agent, and nothing blocks a commit because there are no commits.

## What you should see

```text
[init-agents] No git repository — skipping remote gate workflow (.github/workflows/gates.yml).

  ENFORCEMENT — convention-only (no git repository):
    No git repository: enforcement is convention-only. Run `git init`
    and re-run init-agents to enable local hooks; add a GitHub remote
    for remote enforcement.
```

## 2. Add git, re-run for L1

```bash
git init
init-agents
```

Now `.git` exists, so the installer writes the portable hook shims.

```text
  INSTALLED:
    ✓ .git/hooks/pre-commit — portable shim → $AAS_DIR
    ✓ .git/hooks/commit-msg — portable shim → $AAS_DIR

  ENFORCEMENT — local only (L1 hooks active):
    Local git only: L1 (hooks) is active. Remote enforcement (L2) needs
    a GitHub remote — `git remote add origin …` then re-run init-agents.
```

## 3. Add a GitHub remote, re-run for L2

```bash
git remote add origin https://github.com/OWNER/REPO.git
init-agents
```

Now the project can use the remote workflow, so the installer writes it:

```text
  INSTALLED:
    ✓ .github/workflows/gates.yml — remote gate (required check)

  REMOTE ENFORCEMENT (L2 — the authority):
    Local hooks are fast feedback; they are writable. The required
    'gates' status check is what actually decides. Turn it on with:
      bash scripts/setup-branch-protection.sh --dry-run   # preview
      bash scripts/setup-branch-protection.sh             # apply
```

Commit and push the workflow, then finish with [Wire the remote enforcement](wire-remote-enforcement/).

## The re-run rule

| Workflow | What you get | How to enable more |
|---|---|---|
| No git | Convention only (rules, skills, `AGENTS.md`) | `git init`, re-run `init-agents` |
| Local git | L1 hooks only | Add a GitHub remote, re-run `init-agents` |
| Git + GitHub | Full L1 + L2 + L3 | See [Wire the remote enforcement](wire-remote-enforcement/) |
| Git later | Grows as layers appear | Re-run `init-agents` after each layer |

The re-run is safe and idempotent: it never duplicates its own entries and never overwrites your `AGENTS.md` rules.

## Next

- [Migrate a legacy project](migrate-a-legacy-project/) if you inherited a folder that already used the framework.
- [Branch protection](../branch-protection/) has the full table of git/GitHub flows.

---
title: "Enforcement (L1/L2/L3)"
description: "The three enforcement layers: L1 local hooks, L2 the required remote gates check, and L3 CODEOWNERS review. A code change with no matching test is blocked."
lang: "en"
order: 12
section: "concepts"
tldr: "L1 is fast local feedback, L2 is the remote authority, L3 protects the gate config. A code change with no matching test is blocked, locally and remotely."
---

## The three layers

Most frameworks stop at rules in a file, and a rule in a file is a suggestion. Enforcement is a mechanism: a change that breaks the process cannot reach `main`. Three layers answer three different questions.

### L1: Local feedback

Fails fast, informs, and leaves a trace. Ergonomics for a cooperative agent. **Not security.**

### L2: Remote authority

GitHub branch protection plus a required status check. Nothing reaches `main` without passing the `gates` check. The committer cannot skip it.

### L3: Config integrity

`CODEOWNERS` plus required code-owner review. Another owner must approve changes to the gate configuration. GitHub only.

## The rule: no code without a test

The `commit-msg` hook (v6) runs a single TDD gate. A code file staged for commit must have a matching test file staged in the same commit. Name-pairing is checked, and at least one staged test must be new.

There is no override mechanism. Pre-commit Gate 0 blocks until the decision token is fresh, but that is a prompt, not the approval authority.

> **Why a hook is not a gate.** The hooks directory is writable by whoever is committing, including an agent. A single `git config` command silences every hook at once. That is why L1 is feedback, not authority. If the gate that decides can be edited by the change it judges, it is not a gate.

## A blocked commit

This is real output, not a mock. The commit stops before it exists.

```text
$ git commit -m "feat: add checkout"
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/checkout.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

The same check runs remotely as the required `gates` status, so it cannot be bypassed by the committer.

## The gates at a glance

| Layer | Where it lives | What it guarantees |
|---|---|---|
| L1 | Working tree, `.git/hooks` | Fast feedback and a visible decision point. Not security. |
| L2 | GitHub branch protection | Nothing reaches `main` without passing the required `gates` check. |
| L3 | `CODEOWNERS` | Changes to the gate config need another owner's approval. |

## What the local hooks check

The pre-commit hook runs a sequence of gates before every commit: a branch check, staged changes, remote sync, HTML integrity, override escalation, the skill gate, build verification, anti-slop, debug tracking, SPEC enforcement, progress status, skill lint, and the test runner. The `commit-msg` hook then runs the TDD gate.

A green hook is feedback, not approval. Anything a reader could mistake for approval either moves remote or gets labelled L1.

## Turn it on

The setup script detects the repository shape and picks a safe profile. Preview first, then apply.

1. Preview the exact payload without writing anything:

```bash
bash scripts/setup-branch-protection.sh --dry-run
```

2. Apply it. The script auto-detects solo versus team and refuses a configuration that could lock you out:

```bash
bash scripts/setup-branch-protection.sh
```

3. Verify that the remote authority is live:

```bash
gh api repos/OWNER/REPO/branches/main/protection
```

4. After `git init` or adding a remote, re-run the installer so the missing layers install:

```bash
init-agents
```

## Honest limitations

These gates create friction, not guarantees. L1 hooks can be bypassed by editing the hook or changing the hooks path. On a solo repository the admin can still bypass the remote rules by design, so the gates remain mandatory for everyone without admin rights. The human stays in the loop, and the human stays alert.

See [Branch protection](/another-agent-skills/docs/branch-protection/) for the solo and team profiles, and the lockout guard that keeps a sole maintainer from being locked out.

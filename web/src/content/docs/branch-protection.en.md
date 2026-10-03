---
title: "Branch protection"
description: "How the remote enforcement layer works: GitHub branch protection, the required gates check, CODEOWNERS, and the solo and team profiles."
lang: "en"
order: 22
section: "reference"
tldr: "Local gates are fast feedback; remote gates are authority. If the gate that decides can be edited by the change it judges, it is not a gate."
---

## The three layers

| Layer | Where it lives | What it guarantees | Nature |
|---|---|---|---|
| L1: Local feedback | `.git/hooks/*` | Fails fast, informs, makes the decision point visible | Ergonomics for a cooperative agent. Not security. |
| L2: Remote authority | GitHub branch protection plus required status checks | Nothing reaches `main` without passing the real gates | Real enforcement for anyone without admin. A solo admin can still bypass. |
| L3: Config integrity | `CODEOWNERS` plus required code-owner review | Another code owner must approve changes to the gate config | Closes the "CI is forgeable" hole only while code-owner review is enforced |

The guiding principle: design for the cooperative agent, enforce for the adversarial one. L1 is primary for cooperation; L2 and L3 are the backstop.

## Why local hooks are not enough

`.git/hooks/` is writable by whoever is committing, including an agent. Two bypasses require no `--no-verify` at all:

- `git config core.hooksPath /some/empty/dir` silences every hook at once.
- Editing or deleting `.git/hooks/pre-commit` or `.git/hooks/commit-msg`.

Hooks also live outside version control, so they drift from the repo and are re-installed per clone. They are excellent for fast feedback and for making the process visible; they cannot be the authority.

## Without GitHub

L2 and L3 are GitHub-only. Branch protection and the required `gates` status check are GitHub features, and `CODEOWNERS` enforcement depends on GitHub's code-owner review. Without a GitHub remote you still have L1 only.

| Workflow | Enforcement available | Steps |
|---|---|---|
| No git | Convention only (rules, skills, `AGENTS.md`) | Run `git init` and re-run `init-agents` to get L1 |
| Local git | L1 hooks only, no L2 or L3 | Add a GitHub remote, re-run `init-agents`, then run the setup script |
| Git and GitHub | Full L1, L2, and L3 | See "Running it" |
| Git later | Grows as layers appear | Re-run `init-agents` after `git init` and after adding the remote |

The re-run rule matters because `init-agents` installs each layer conditionally: local hooks only when `.git` exists, and the `gates` workflow only when a GitHub remote exists.

## Solo versus team

GitHub does not let you approve your own pull request. That makes a "require 1 approval" rule impossible to satisfy when you are the only human who can push. The setup script detects the repository shape and picks one of two profiles.

| Profile | Chosen when | Strict | Approvals | Code-owner review | Enforce admins |
|---|---|---|---|---|---|
| Solo | Owner is a user and at most one human with push | Off | 0 | Off | Off |
| Team | Anything else (organization, or more than one human) | On | 1 | On | On |

Both profiles still require a pull request and the `gates` status check, require conversation resolution, and disable force pushes and deletions.

> **Solo caveat:** the solo profile leaves `enforce_admins` off, so the admin can still bypass the required PR and the `gates` check. The gates remain mandatory for everyone without admin rights. If you want the gates to bind you too, you need a second human with push access.

## The lockout guard

If fewer than two humans have push access, the script forces the solo profile even when you explicitly pass `--mode team`. Requiring an approval that no one can give would lock you out of `main`, so the script refuses to emit that configuration and prints a warning. It also caps an over-large `--approvals N`: with N humans who can push, at most N minus 1 approvals are ever reachable.

## Running it

Prerequisites: the `gh` CLI authenticated with admin rights on the repository, and `jq` on `PATH`.

```bash
# Preview the exact payload without calling the API (safe, no writes):
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --dry-run

# Auto-detect the profile and apply to main of the current repo:
bash scripts/setup-branch-protection.sh

# Force a profile explicitly:
bash scripts/setup-branch-protection.sh --mode solo
bash scripts/setup-branch-protection.sh --mode team
```

| Flag | Effect |
|---|---|
| `--mode auto\|solo\|team` | `auto` detects the shape; `solo` and `team` force a profile. |
| `--approvals N` | Required approving reviews, capped at GitHub's maximum of 6. |
| `--code-owner-reviews` / `--no-code-owner-reviews` | Require or drop code-owner review. |
| `--strict` | Require the branch to be up to date before merging. |
| `--enforce-admins` | Apply the rules to admins too. |
| `--force-lockout-risk` | Allow a config that can lock out a sole maintainer. |
| `--dry-run` | Print the detected mode and payload; make no API writes. |

The script is idempotent: it reads the current protection first and, if the desired state is already in place, reports it and exits without writing. Verify afterwards:

```bash
gh api repos/OWNER/REPO/branches/main/protection --jq '.required_status_checks.contexts'
# -> ["gates"]
```

> The workflow is read-only (`permissions: contents: read`) and never pushes or commits. Every command it runs is a script in the repository, so "it passed locally" and "it passed in CI" mean the same thing.

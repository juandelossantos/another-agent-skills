# Branch Protection — Remote Enforcement

> Local gates are fast feedback. Remote gates are authority.
> If the gate that *decides* can be edited by the change it judges, it is not a gate.

This document explains the three enforcement layers used by Another Agent Skills,
why local hooks alone are not enforcement, and how to turn on the remote layer
with `scripts/setup-branch-protection.sh`.

## The three layers

| Layer | Where it lives | What it guarantees | Nature |
|---|---|---|---|
| **L1 — Local feedback** | `.git/hooks/*` | Fails fast, informs, leaves a trace, makes the decision point visible | Ergonomics for a cooperative agent. **Not security.** |
| **L2 — Remote authority** | GitHub branch protection + required status checks | Nothing reaches `main` without passing the real gates | Real enforcement. Requires that the agent cannot push/merge directly. |
| **L3 — Config integrity** | `CODEOWNERS` + required code-owner review | The agent cannot edit its own rules in the same PR that violates them | Closes the "CI is forgeable if the agent edits the workflow" hole. |

The guiding principle: **design for the cooperative agent, enforce for the
adversarial one.** L1 is primary for cooperation; L2 + L3 are the backstop.

## Why local hooks are not enough

`.git/hooks/` is writable by whoever is committing — including an agent. Two
bypasses require no `--no-verify` at all:

- `git config core.hooksPath /some/empty/dir` — silences every hook at once.
- Editing or deleting `.git/hooks/pre-commit` / `.git/hooks/commit-msg`.

Hooks also live outside version control, so they drift from the repo and are
re-installed per clone. They are excellent for *fast feedback* and for making the
process visible; they cannot be the authority.

## Solo vs team: you cannot approve your own PR

The single most important fact about branch protection is this:

> **GitHub does not let you approve your own pull request.**

That makes a "require 1 approval" rule **impossible to satisfy on a repository
where you are the only human who can push**. The script therefore auto-detects
the repository shape and picks one of two profiles.

It asks GitHub two questions:

```bash
# 1. Is the owner a User or an Organization?
gh api repos/OWNER/REPO --jq '.owner.type'

# 2. How many humans have push/admin access?
gh api --paginate 'repos/OWNER/REPO/collaborators?per_page=100' \
  --jq '[.[] | select(.permissions.push or .permissions.admin)] | length'
```

(The script excludes `[bot]` logins — a bot cannot approve anything, so counting
it as a second "human" would be wrong and could produce a locked-out config.)

| Profile | Chosen when | `strict` | approvals | code-owner review | `enforce_admins` |
|---|---|---|---|---|---|
| **solo** | owner is a `User` **and** ≤ 1 human with push | `false` | `0` | off | off |
| **team** | anything else (Organization, or > 1 human) | `true` | `1` | on | on |

Both profiles still require a **pull request** and the **`gates` status check**,
require **conversation resolution**, and disable **force pushes** and
**deletions**. The difference is only whether a second human's approval is
required.

- The **solo** profile keeps a sole maintainer unblocked: PRs and the gates are
  still mandatory, but the author can merge their own PR (no approval to give,
  and admins are not bound so the owner can still merge).
- The **team** profile is full enforcement: stale approvals are dismissed,
  a code owner must review, and `enforce_admins` is on so nobody — agent
  included — can route around the rules.

## The lockout guard (mandatory)

If **fewer than two humans have push access**, the script **forces the solo
profile** — even when you explicitly pass `--mode team`. Requiring an approval
that no one can give would lock you out of `main`, so the script refuses to
emit that configuration and prints a warning explaining why:

```
WARNING: lockout guard engaged.
  Only 1 human(s) have push access to OWNER/REPO; at most 0 approval(s) can
  ever be satisfied (GitHub does not let you approve your own pull request).
  Forcing the solo-safe profile: approvals=0, code-owner-review=off,
  enforce-admins=off.
  Override with --force-lockout-risk only if you understand the risk.
```

The guard also caps an over-large `--approvals N`: with N humans who can push,
at most N−1 approvals are ever reachable, so a request for more is reduced to
that ceiling. This is the same rule as "you cannot approve your own PR", applied
generally.

### When to use `--force-lockout-risk`

Only when you genuinely have a second reviewer who can approve **and** the API
under-counted your collaborators (for example, the reviewer has access through a
team that the collaborators endpoint does not surface, or you are configuring
the repo ahead of adding the reviewer).

```bash
bash scripts/setup-branch-protection.sh --mode team --force-lockout-risk
```

This prints a loud warning and applies the requested (possibly unsafe) config.
If you are the only admin account and you use this flag, you can lock yourself
out of `main`. If that happens, an organization owner can remove the rule from
the repository's settings page, then re-run the script without the flag.

## Running it

Prerequisites:

- the [`gh`](https://cli.github.com/) CLI, authenticated (`gh auth login`) as an
  account with **admin** rights on the repository;
- [`jq`](https://jqlang.github.io/jq/) on `PATH`.

```bash
# Preview the exact payload without calling the API (safe, no writes):
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --dry-run

# Auto-detect the profile and apply to main of the current repo:
bash scripts/setup-branch-protection.sh

# Force a profile explicitly:
bash scripts/setup-branch-protection.sh --mode solo
bash scripts/setup-branch-protection.sh --mode team

# Override individual settings (flags win over the profile):
bash scripts/setup-branch-protection.sh --approvals 2 --strict \
  --code-owner-reviews --enforce-admins

# Or target explicitly:
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --branch main
```

| Flag | Effect |
|---|---|
| `--mode auto\|solo\|team` | `auto` (default) detects the shape; `solo`/`team` force a profile. |
| `--approvals N` | Required approving reviews. |
| `--code-owner-reviews` | Require review from Code Owners. |
| `--strict` | Require the branch to be up to date before merging. |
| `--enforce-admins` | Apply the rules to admins too (no admin bypass). |
| `--force-lockout-risk` | Allow a config that can lock out a sole maintainer (loud warning). |
| `--repo OWNER/REPO` | Target repository (default: derived from `gh repo view`). |
| `--branch BRANCH` | Branch to protect (default: `main`). |
| `--dry-run` | Print the detected mode + payload; make no API writes. |

Flags override the profile, **but the lockout guard still applies** unless
`--force-lockout-risk` is passed.

Before applying, the script prints the detected shape (owner type, number of
humans with push access), the detected/requested/final mode, and the exact JSON
payload. It is **idempotent**: it reads the current protection first and, if the
desired state is already in place, reports it and exits without writing.
Re-running it is safe and always converges to the same state.

Verify afterwards:

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --jq '.required_status_checks.contexts'
# → ["gates"]
```

A `404 Branch not protected` before running is expected; a `200` after means the
authority layer is live.

## Operational notes

- **`enforce_admins: true` (team profile) also binds the human owner.** That is
  deliberate: if the agent runs with the owner's credentials, admin bypass would
  defeat the whole model. The solo profile leaves it off so a sole maintainer
  can always merge their own work. A maintainer who genuinely needs an emergency
  merge on a team repo can temporarily disable the rule in repository settings,
  then re-run the script.
- **Detection failure is safe.** If `gh` cannot reach the API (offline, or no
  admin rights), the script assumes the solo profile and says so. It never
  guesses *toward* a config that could lock you out.
- **The workflow is read-only.** `.github/workflows/gates.yml` declares
  `permissions: contents: read` and never pushes or commits; it only runs gates.
- **CI is reproducible locally.** Every command in `gates.yml` is a script in
  this repo (`scripts/tdd-gate.sh`, `tests/run-all.sh`,
  `scripts/skill-lint.sh`, `scripts/validate-skill-table.sh`), so "it passed
  locally" and "it passed in CI" mean the same thing.

## Related

- `.github/workflows/gates.yml` — the `gates` job / required check.
- `scripts/setup-branch-protection.sh` — L2 configuration (this doc).
- `CODEOWNERS` — L3 protection of the gate configuration.
- `PLAN.md` — Phase 8: Remote Enforcement.

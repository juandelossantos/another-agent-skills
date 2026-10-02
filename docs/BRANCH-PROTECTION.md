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

## What the remote layer enforces

`scripts/setup-branch-protection.sh` configures `main` so that a merge requires:

- a **pull request** (no direct pushes);
- the **`gates` status check** — the job defined in `.github/workflows/gates.yml`
  (TDD gate, full test suite, skill lint, skill-table validation, shell syntax);
- **review from Code Owners** (see `CODEOWNERS` — `.github/workflows/`,
  `scripts/git-hooks/`, `scripts/tdd-gate.sh`, `scripts/edit-guard.sh`,
  `scripts/*gate*`);
- **dismissal of stale approvals** when new commits are pushed;
- **conversation resolution** before merging.

And it disables:

- **force pushes** to `main`;
- **branch deletions**;
- **admin bypass** (`enforce_admins: true`) — otherwise the account the agent
  runs as could route around its own gates.

## Running it

Prerequisites:

- the [`gh`](https://cli.github.com/) CLI, authenticated (`gh auth login`) as an
  account with **admin** rights on the repository;
- [`jq`](https://jqlang.github.io/jq/) on `PATH`.

```bash
# Preview the exact payload without calling the API (safe, no network):
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --dry-run

# Apply to main of the current repo:
bash scripts/setup-branch-protection.sh

# Or target explicitly:
bash scripts/setup-branch-protection.sh --repo OWNER/REPO --branch main
```

The script is **idempotent**: it reads the current protection first and, if the
desired state is already in place, reports it and exits without writing. Re-running
it is safe and always converges to the same state.

Verify afterwards:

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --jq '.required_status_checks.contexts'
# → ["gates"]
```

A `404 Branch not protected` before running is expected; a `200` after means the
authority layer is live.

## Operational notes

- **`enforce_admins: true` also binds the human owner.** That is deliberate: if
  the agent runs with the owner's credentials, admin bypass would defeat the
  whole model. A maintainer who genuinely needs an emergency merge can
  temporarily disable the rule in repository settings, then re-run the script.
- **Required review count is 1.** On a single-maintainer repository, requiring a
  review means the author cannot approve their own PR. Adjust
  `required_approving_review_count` in the script if your workflow differs.
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

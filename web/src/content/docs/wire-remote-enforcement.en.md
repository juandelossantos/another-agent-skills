---
title: "Wire the remote enforcement"
description: "Turn L1 feedback into L2 authority: commit the gates workflow, open a pull request so the gates check reports, preview branch protection with --dry-run, apply it, and verify."
lang: "en"
order: 4
section: "tutorials"
tldr: "Commit .github/workflows/gates.yml, open a PR so the gates check reports at least once, preview branch protection with --dry-run, apply it, then verify the required contexts include gates. L2 and L3 require GitHub."
---

## What you will do

Local hooks are fast feedback, not authority: the committer can repoint or edit `.git/hooks`. The remote `gates` check is what actually decides. This tutorial turns it on for a repository that already has a GitHub remote.

**You will end with:** `main` protected, a required `gates` status check, and a verification command that proves it.

## Before you start

- A project that already ran `init-agents` and has a **GitHub remote**.
- The `gh` CLI authenticated with **admin** rights on the repository.
- `jq` on `PATH`.

If your project is not on GitHub yet, do [Start without git, add it later](no-git-and-later-git/) first.

## 1. Commit the gates workflow

`init-agents` writes `.github/workflows/gates.yml` only when the project has a GitHub remote. Its job is named `gates`. Commit it on a branch:

```bash
git checkout -b ci/arm-gates
git add .github/workflows/gates.yml
git commit -m "ci: arm the remote gates check"
git push -u origin ci/arm-gates
```

## 2. Open a pull request so the check reports

GitHub only offers a status check as "required" **after it has run at least once**. Open a PR:

```bash
gh pr create --fill --base main
```

Wait for the `gates` check to finish. It runs your `STACK_CONFIG.md` commands plus the project audit, and it is read-only (`contents: read`) — it never pushes or commits.

## 3. Preview branch protection (no writes)

```bash
bash scripts/setup-branch-protection.sh --dry-run
```

The script detects whether the repository is solo (one human with push) or a team, prints the exact payload, and makes **no API calls**.

## 4. Apply it

```bash
bash scripts/setup-branch-protection.sh
```

The script is idempotent: if the desired state is already in place it reports that and exits without writing. It also refuses a configuration that could lock out a sole maintainer.

## 5. Verify

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --jq '.required_status_checks.contexts'
```

## What you should see

```text
["gates"]
```

Direct pushes to `main` are now rejected and no pull request can merge until `gates` passes, regardless of what the local hooks do.

## Solo versus team

| Profile | Chosen when | Approvals | Code-owner review |
|---|---|---|---|
| Solo | Owner is a user and at most one human with push | 0 | Off |
| Team | Organization, or more than one human | 1 | On |

> **Solo caveat:** the solo profile leaves `enforce_admins` off, so the admin can still bypass the rules. The gates stay mandatory for everyone without admin rights. If you want them to bind you too, you need a second human with push access.

## Honest limitations

L2 and L3 are **GitHub-only**. Branch protection and the required status check are GitHub features, and `CODEOWNERS` enforcement depends on GitHub's code-owner review. Without a GitHub remote you still have L1.

## Next

- [Branch protection](../branch-protection/) has the full L1/L2/L3 model, the solo/team profiles, and the lockout guard.
- [Remote enforcement evidence](../enforcement/) records what was actually verified, including the bypass demo.

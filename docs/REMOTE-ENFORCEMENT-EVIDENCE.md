# Remote Enforcement — Evidence

> Companion to [`BRANCH-PROTECTION.md`](BRANCH-PROTECTION.md).
> Verifier: `tests/test-remote-enforcement.sh` (static + live + bypass demo).

This records what was actually verified about the three enforcement layers, not
what we intended. It is the evidence for **Phase 8 / P8.7**.

## What the model claims

| Layer | Control | Claim |
|---|---|---|
| **L1** | `.git/hooks/*` | Fast feedback. **Bypassable** — it is advisory. |
| **L2** | Branch protection + required `gates` check | The authority. Cannot be skipped by the committer. |
| **L3** | `CODEOWNERS` | Protects the gate config from being edited in the PR it judges. |

The single testable assertion: **bypassing L1 does not bypass L2.**

## What the verifier checks

Run `bash tests/test-remote-enforcement.sh`. It has three groups.

### 1. Static — the controls exist

- `.github/workflows/gates.yml` exists, its job is named **`gates`** (the required
  check), it is **read-only** (`contents: read`, never pushes/commits), and it
  runs the real gates (`scripts/tdd-gate.sh`, `tests/run-all.sh`).
- `CODEOWNERS` protects `.github/workflows/` and the gate scripts.

### 2. Live — branch protection is active (read-only)

Via `gh api repos/<slug>/branches/main/protection`:

| Setting | Expected |
|---|---|
| `required_status_checks.contexts` | contains `gates` |
| `required_pull_request_reviews` | present (a PR is required) |
| `allow_force_pushes.enabled` | `false` |
| `allow_deletions.enabled` | `false` |

Skipped automatically when `gh` is unavailable or unauthenticated.

### 3. Bypass demo — L1 fails open, L2 does not

In a throwaway repo with the real hooks installed:

1. A code change with **no matching test** is **blocked** by the local hook (L1 active).
2. `git config core.hooksPath <empty>` — the **same commit succeeds** (L1 bypassed).
3. `bash scripts/tdd-gate.sh` — the exact command `gates.yml` runs — **still fails**
   on that change. The bypass is local only.

## Observed results

- **2026-10-02** — all 15 assertions pass on `main`. Live protection on
  `juandelossantos/another-agent-skills@main`: `gates` required, PR required,
  force-push disabled, deletions disabled (solo profile, 0 approvals — see the
  lockout guard in `BRANCH-PROTECTION.md`).
- Historical: PR #41's first CI run had a failing check and
  `mergeStateStatus: UNSTABLE` — a red required check blocks merge.

## Honest limitations

- **Scenario "edit `gates.yml` without review → blocked" needs the team profile.**
  It relies on *"Require review from Code Owners"*, which the solo profile turns
  **off** (a sole owner cannot approve their own PR — that would be a lockout).
  On a solo repo, L3 is *configured* (CODEOWNERS) but not *enforced* until a
  second human with push access exists. This is documented, not hidden.
- **Direct-push rejection is verified at the config level**, not by actually
  attempting a push: `required_pull_request_reviews` present + `allow_force_pushes`
  false is exactly the condition under which GitHub rejects a direct push to
  `main`. A live attempt would be a deliberate violation of our own rules.
- **A real bug surfaced here.** The bypass demo exposed that `pre-commit` failed
  in any project **without `tests/task/`** (`set -o pipefail` + `find` on a
  missing directory) — i.e. every fresh `init-agents` project. Fixed with a
  directory guard; regression test: `tests/test-pre-commit-no-task-dir.sh`.

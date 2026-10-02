# Git Hooks — Another Agent Skills

> These hooks are **L1 — fast local feedback**, not authority. See
> [Local vs remote](#local-vs-remote-l1-is-feedback-l2-is-authority) below and the
> full model in [`docs/BRANCH-PROTECTION.md`](../../docs/BRANCH-PROTECTION.md).

## commit-msg: TDD Only (v6)

**Purpose:** Enforces TDD — blocks commits without corresponding test files.

**Design:** Single-gate hook. All other approval checks removed. The user running `git commit` IS the approval.

**Flow:**
1. Agent stages files and presents commit manifest in chat
2. User runs: `git commit -m "message"`
3. Hook validates TDD pairing (code change → test change)
4. Commit proceeds if TDD gate passes

## pre-commit: Pre-Flight + Quality Gates (v11)

**Purpose:** 15 gates running before every commit — Gate 0 (DECISION_APPROVED), Branch, Staged, Remote, HTML integrity, Override escalation, Skill Gate, Build Verification, Anti-Slop, Debug 3-Strikes, SPEC Enforcement, Progress Status, Skill Lint, Eval, Test Runner.

**Installation per project:**
```bash
init-agents   # copies hooks into .git/hooks/
```

## Local vs remote: L1 is feedback, L2 is authority

`.git/hooks/` is writable by whoever is committing — including an agent — so it
cannot be the thing that *decides*. Two bypasses need no `--no-verify` at all:

- `git config core.hooksPath /some/empty/dir` — silences every hook at once.
- Editing or deleting `.git/hooks/pre-commit` / `.git/hooks/commit-msg`.

What actually decides is the **remote layer**: the required **`gates`** status
check enforced by branch protection. `git commit --no-verify` skips these local
hooks — but it does not bypass the remote gate: a pull request still cannot
merge into `main` until the required `gates` check passes. Skipping the local
hooks only costs you the fast feedback.

| Layer | Where | Role |
|---|---|---|
| **L1** | `.git/hooks/*` (this dir) | Fast feedback. Not security. |
| **L2** | GitHub branch protection + required `gates` check | The authority. |
| **L3** | `CODEOWNERS` + code-owner review | Protects the gate config. |

Full model: [`docs/BRANCH-PROTECTION.md`](../../docs/BRANCH-PROTECTION.md) ·
enable L2 with `bash scripts/setup-branch-protection.sh`.

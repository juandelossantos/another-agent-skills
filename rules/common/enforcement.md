# Enforcement Rules

> Mechanical enforcement — pre-action checklist, mutation approval, PR review gate.

---

## Rule 0d: Pre-Action Checklist + Branch Interview (MECHANICAL)

**Before ANY edit, creation, or deletion of files — MANDATORY: run pre-flight, then interview the user about branch strategy.**

### Step 1 — Run Pre-Flight

This repo: `bash scripts/pre-flight.sh`
Any repo: `git status && git fetch --dry-run && git branch --show-current`

### Step 2 — Present State & Ask

After pre-flight, PRESENT the state and ASK the user about branch intent:

```
Git state: [branch] [clean/dirty] [up-to-date/behind] [upstream]
→ "You're on [branch]. Stay here, create a feature branch, or switch?"
```

**Decision matrix:**

| Pre-flight result | Agent action |
|---|---|
| Clean + correct branch + up to date | Ask: "Stay on [branch] or create feature branch?" |
| Dirty working tree | Ask: "Commit, stash, or discard changes?" |
| Behind remote | Ask: "Run pull --rebase now?" |
| Wrong branch | Ask: "Switch to [target] or create new branch?" |
| Detached HEAD | Ask: "Create branch from here or checkout main?" |

No assumptions. Always ask. The user knows where they want to be.

### Step 3 — Edit Guard (BLOCKING for every edit)

Run `bash scripts/edit-guard.sh` before and after every file edit. See AGENTS-EXTENDED.md for full preflight/verify/check protocol.

**Design gate:** `bash scripts/design-gate.sh` (BLOCKING if change touches design or visual assets)

### Step 4 — Edit-to-Commit Barrier (BLOCKING)

After completing edits, the agent MUST STOP before any git add/commit. No commit without a Commit Manifest. See AGENTS-EXTENDED.md for full Commit Manifest Protocol, hash-bound token generation, and batch-mode prevention rules.

---

## Rule 12: Mutation Approval Gate (ABSOLUTE)

**No git operation that mutates the repository without explicit user approval.**

### Guardian Pattern — MANDATORY DECISION POINT

Before ANY mutation, present the DECISION POINT block (see AGENTS-EXTENDED.md for template). Wait for explicit "yes" / "sí" / "commit" / "proceed". **Invalid:** "ok", "mmhm", "sigamos", "dale", "continue", silence, emoji reactions.

### Rules:
- **NEVER batch approval.** Previous approval does not transfer. Every mutation is a separate decision.
- **Commit and push are SEPARATE decisions.** Commit manifest approves commit only. After commit, ask about push.
- **All git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.

### MECHANICAL ENFORCEMENT:

A pre-commit git hook blocks `git commit` unless a `.git/COMMIT_APPROVED` token exists with the SHA256 hash of the exact commit message. See AGENTS-EXTENDED.md for full Commit Manifest Protocol, hash-bound token generation, session-level lock, and user override details.

---

## Rule 12b: PR Review Gate (MECHANICAL)

Before any PR merge: run `bash scripts/pr-review-checklist.sh <PR_NUMBER>`. FAIL → fix. WARN → review manually. PASS → proceed. See AGENTS-EXTENDED.md for full checklist contents.

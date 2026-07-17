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

After completing edits, the agent MUST STOP and present the decision point. No commit without explicit user approval. See Rule 12 below for the full commit flow.

---

## Rule 12: Mutation Approval Gate (ABSOLUTE)

**No git operation that mutates the repository without explicit user approval.**

### Core Rule: Agent Stages, User Commits

The agent NEVER runs `git commit`. The correct flow:

1. Agent stages files with `git add <files>`
2. Agent presents the DECISION POINT to the user
3. User explicitly approves
4. Agent writes `.git/DECISION_APPROVED` with timestamp
5. User runs `git commit` themselves

### Guardian Pattern — MANDATORY DECISION POINT

Before ANY mutation, present the DECISION POINT block. Wait for explicit "yes" / "sí" / "commit" / "proceed". **Invalid:** "ok", "mmhm", "sigamos", "dale", "continue", silence, emoji reactions.

Decision point must include:
- Files staged (list)
- Commit message
- What changed and why
- Test results (TDD gate status)

```
DECISION POINT
  Staged: src/button.tsx, src/button.test.tsx
  Message: feat: add accessible button component
  Changes: 3 files, +120 lines, -0 lines
  TDD gate: PASS (test files match code files)
  → Approve commit? (y/n)
```

### Commit Flow

```
1. Agent: git add <files>
2. Agent: presents DECISION POINT
3. User: "yes" / "commit"
4. Agent: echo "$(date -Iseconds)" > .git/DECISION_APPROVED
5. User: git commit -m "feat: message"
6. Pre-commit hook: checks .git/DECISION_APPROVED exists and is <10 min old
   → If missing or stale: WARN (yellow, doesn't block)
   → The user running git commit IS the approval. The token is evidence the
     presentation step happened before the commit.
```

### Override Flow

When the agent needs to bypass the TDD gate (e.g., doc-only changes, urgent fixes without tests):

```
1. Agent: presents DECISION POINT with override justification
2. Agent: "OVERRIDE needed: <reason>. Approve? (y/n)"
3. User: "yes"
4. Agent: echo "OVERRIDE: <reason> | $(date -Iseconds)" > .git/OVERRIDE_APPROVED
5. User: git commit -m "message" -m "OVERRIDE: <reason>"
6. Commit-msg hook: OVERRIDE in body requires .git/OVERRIDE_APPROVED
   → If token exists and fresh (<10 min): PASS (green)
   → If token missing or stale: BLOCK (red) — OVERRIDE text alone is forgeable
```

**The OVERRIDE text in the commit body alone is NOT sufficient.** The token is the mechanical proof.

### Rules:
- **NEVER batch approval.** Previous approval does not transfer. Every mutation is a separate decision.
- **Commit and push are SEPARATE decisions.** Plan approval ≠ commit approval ≠ push approval.
- **All git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.
- **Plan and commit are ALWAYS separate decisions.** Present the plan first → get approval → execute. Then present the commit → get approval → user commits.
- **"yes commit" = agent writes DECISION_APPROVED, user commits.** Agent never runs git commit.
- **"yes push" = push approval.** When user types "yes push" in chat, agent pushes.

### Mechanical Enforcement

| Hook | Check | Behavior | What It Catches |
|---|---|---|---|
| Pre-commit (`scripts/project-pre-commit`) | `.git/DECISION_APPROVED` exists and <10min | WARN (yellow) if missing or stale | Agent skipping the presentation step |
| Commit-msg (`scripts/git-hooks/commit-msg`) | OVERRIDE in body + `.git/OVERRIDE_APPROVED` exists and <10min | BLOCK (red) if missing or stale | Agent forging OVERRIDE without approval |

Both tokens live in `.git/` which is inherently local (never tracked by git). Never committed.

### Tokens

| Token | File | Written By | Validated By | Blocks? |
|---|---|---|---|---|
| Decision token | `.git/DECISION_APPROVED` | Agent (after user says "yes") | Pre-commit hook | No (warns) |
| Override token | `.git/OVERRIDE_APPROVED` | Agent (after user approves override) | Commit-msg hook | Yes (blocks) |

The decision token is a warn because the user running git commit IS the approval. The override token is a block because OVERRIDE text alone is trivially forgeable by any agent in any commit message.

See AGENTS-EXTENDED.md for full DECISION POINT templates and examples.

---

## Rule 12b: PR Review Gate (MECHANICAL)

Before any PR merge: run `bash scripts/pr-review-checklist.sh <PR_NUMBER>`.

| Exit | Action |
|---|---|
| **PASS (0)** | PR is clean. Proceed to merge. No human review required unless the changes are security-sensitive or architectural. |
| **WARN (2)** | Non-blocking issues (e.g., no GitHub reviews, size warnings). Review manually. If no functional issues, proceed to merge. |
| **FAIL (1)** | Blocking issues found. Fix before merge. Run checklist again after fix. |

**Self-review rule:** The agent that created the PR CAN run the checklist and merge if PASS. The checklist IS the review. The agent does NOT need a separate human approval on GitHub to merge — the PR review gate IS the approval gate. The only exception is if the PR changes a rule file (`rules/`), a script with enforcement logic (`scripts/git-hooks/`), or SKILL.md files — these require a human GitHub review before merge.

**Post-merge:** Delete branch. Update RELEASE-NOTES.md if not already updated. Update HEALTH-CHECK.md if version changed.

See AGENTS-EXTENDED.md for full checklist contents.

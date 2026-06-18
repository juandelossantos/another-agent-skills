# Git Hooks — Another Agent Skills

## commit-msg: Time-Window Approval (v5)

**Purpose:** Mechanical enforcement of Rule 12. Blocks `git commit` unless
`.git/COMMIT_APPROVED` exists. Checks: file exists? <5 min old? message matches?

**Flow:**
1. Agent presents DECISION POINT → User says "yes commit" in chat
2. Agent runs `bash scripts/commit-approval.sh "message"`
3. Agent runs `git commit` → Hook verifies freshness → Commit proceeds
4. File deleted after commit (next commit needs fresh approval)

## pre-commit: Pre-Flight + Integrity Gates (v8)

**Purpose:** Runs 9 checks before every commit: branch, staged, remote sync, HTML integrity, skill gate, build verification, anti-slop, debug tracking, PROGRESS_STATUS validation.

**Installation per project:**
```bash
init-agents   # copies hooks into .git/hooks/
```

**Bypass (intentional violation):**
```bash
git commit --no-verify
```

**Remove permanently:**
```bash
rm .git/hooks/pre-commit .git/hooks/commit-msg
```

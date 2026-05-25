# Git Hooks — Another Agent Skills

## pre-commit: Mutation Approval Gate

**Purpose:** Mechanical enforcement of Rule 12. Blocks `git commit` unless
`.git/COMMIT_APPROVED` token exists.

**Flow:**
1. Agent presents Commit Manifest → User says "yes"
2. Agent creates `.git/COMMIT_APPROVED`
3. Agent runs `git commit` → Hook consumes token → Commit proceeds
4. Next commit requires new token

**Installation per project:**
```bash
init-agents   # copies this hook into .git/hooks/pre-commit
```

**Bypass (intentional violation):**
```bash
git commit --no-verify
```

**Remove permanently:**
```bash
rm .git/hooks/pre-commit
```

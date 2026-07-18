# Git Hooks — Another Agent Skills

## commit-msg: TDD Only (v6)

**Purpose:** Enforces TDD — blocks commits without corresponding test files.

**Design:** Single-gate hook. All other approval checks removed. The user running `git commit` IS the approval.

**Flow:**
1. Agent stages files and presents commit manifest in chat
2. User runs: `git commit -m "message"`
3. Hook validates TDD pairing (code change → test change)
4. Commit proceeds if TDD gate passes

## pre-commit: Pre-Flight + Quality Gates (v11)

**Purpose:** 14 gates running before every commit — Branch, Staged, Remote, HTML integrity, Override escalation, Skill Gate, Build Verification, Anti-Slop, Debug 3-Strikes, SPEC Enforcement, Progress Status, Skill Lint, Eval, Test Runner.

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

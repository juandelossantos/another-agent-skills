# Verify Enforcement

Enforcement you have not seen fire is a claim, not a fact. This guide is the
proof step: produce the evidence that the gate actually blocks a bad commit.

## The proof (do this every time)

```bash
# 1. Make a code change with NO matching test
printf 'export const x = 1\n' >> src/throwaway.js

# 2. Stage and try to commit
git add src/throwaway.js
git commit -m "feat: untested change"
```

Expected — the commit is **blocked**:

```text
[commit-msg v6] scanning staged files
[commit-msg v6] code changed: src/throwaway.js
[commit-msg v6] matching test: none
✗ BLOCKED: every code change needs a matching test.
```

Capture that output. If you cannot produce a blocked commit, the gate is **not
active** — go back to `WIRE-THE-GATES.md` (usually a `core.hooksPath` mismatch).

## TOOL_GAP: when you cannot verify

If the environment cannot reach the world — no network, no git, no test runner —
the honest verdict is **"ship status unknown"**, never "looks fine".

| Verdict | Meaning | Action |
|---|---|---|
| ✅ PASS | The blocked commit was observed | Proceed |
| ❌ FAIL | The commit went through (no gate) | Fix, re-verify |
| ⚠️ TOOL_GAP | Cannot run git/tests here | Report "unverified" and stop |

## Checklist

- [ ] `core.hooksPath` resolved; the hook lives in the directory git reads.
- [ ] An untested code change is **blocked** (transcript pasted).
- [ ] The remote `gates` check is **required** on `main`.
- [ ] The gate config (workflow + hook scripts) is owned by a human (`CODEOWNERS`).

## Why this matters

A gate that silently passes is worse than no gate: it manufactures false
confidence. The proof is the deliverable. "Tests pass" means nothing without
running them; "the gate works" means nothing without a blocked commit.

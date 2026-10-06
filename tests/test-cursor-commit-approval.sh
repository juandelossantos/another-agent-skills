#!/usr/bin/env bash
# test-cursor-commit-approval.sh — the Cursor guardrail hook (philosophy A)
# denies git commit/push unconditionally and ignores everything else. It must
# not reference the retired `.git/COMMIT_APPROVED` token or the nonexistent
# `scripts/approve-commit.sh`.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/.cursor-plugin/agent-discipline/hooks/commit-approval.sh"

fail=0
check() { if [ "$1" = "0" ]; then echo "  ✓ $2"; else echo "  ✗ $2"; fail=1; fi; }

[ -f "$HOOK" ]; check $? "hook exists"

# Static: no dead token scheme, no reference to a nonexistent script.
! grep -q "COMMIT_APPROVED" "$HOOK"; check $? "no .git/COMMIT_APPROVED token reference"
! grep -q "approve-commit.sh" "$HOOK"; check $? "no nonexistent scripts/approve-commit.sh reference"

deny() {
  echo "$1" | bash "$HOOK" >/dev/null 2>&1
  [ $? -eq 2 ]; check $? "denies $2"
}
allow() {
  echo "$1" | bash "$HOOK" >/dev/null 2>&1
  [ $? -eq 0 ]; check $? "allows $2"
}

deny '{"command":"git commit -m x"}' "git commit"
deny '{"command":"git push origin main"}' "git push"
deny '{"command":"git -C /repo commit -m x"}' "git -C commit (flags-aware)"
deny '{"command":"git --git-dir=/repo/.git commit -m x"}' "git --git-dir= commit"
deny '{"command":"cd x && git commit -m x"}' "compound commit"
deny '{"command":"true; git push"}' "compound push"
deny '{"command":"FOO=bar git commit -m x"}' "env-var prefix"
deny '{"command":"sudo git commit -m x"}' "sudo prefix"
deny '{"tool_input":{"command":"git merge main"}}' "Claude-style payload"
# C1 — wrapper options must NEVER consume the `git` token as their value.
deny '{"command":"env -i git commit -m x"}' "C1 env -i commit"
deny '{"command":"sudo -n git commit -m x"}' "C1 sudo -n commit"
deny '{"command":"sudo -u root git commit -m x"}' "C1 sudo -u <value> commit"
deny '{"command":"env -u FOO git commit -m x"}' "C1 env -u <value> commit"
# C2 — wrappers / subshells / brace groups.
deny '{"command":"command git commit -m x"}' "C2 command commit"
deny '{"command":"nohup git commit -m x"}' "C2 nohup commit"
deny '{"command":"time git commit -m x"}' "C2 time commit"
deny '{"command":"xargs git commit -m x"}' "C2 xargs commit"
deny '{"command":"(git commit -m x)"}' "C2 subshell commit"
deny '{"command":"{ git commit -m x; }"}' "C2 brace group commit"
allow '{"command":"git status"}' "git status"
allow '{"command":"git commit-tree abc123"}' "git commit-tree (word boundary)"
allow '{"command":"ls -la"}' "non-git command"
# Over-strip guards.
allow '{"command":"env -i ls"}' "env -i non-git"
allow '{"command":"sudo -n ls"}' "sudo -n non-git"
allow '{"command":"command ls"}' "command non-git"
allow '{"command":"time ls -la"}' "time non-git"
allow '{"command":"env -i git status"}' "env -i git status"
# Rule 12b — a PR merge is a remote merge the agent must never run.
deny '{"command":"gh pr merge 42"}' "gh pr merge (Rule 12b)"
deny '{"command":"gh -R owner/repo pr merge 42"}' "gh pr merge flags-aware"
allow '{"command":"gh pr create --base main"}' "gh pr create (only merge is gated)"
allow '{"command":"gh pr view 42"}' "gh pr view"

# No bypass: a COMMIT_APPROVED file must NOT let a commit through.
TMP="$(mktemp -d)"
git -C "$TMP" init -q 2>/dev/null || true
echo "$(date -Iseconds)" > "$TMP/.git/COMMIT_APPROVED"
( cd "$TMP" && echo '{"command":"git commit -m x"}' | bash "$HOOK" >/dev/null 2>&1 ); [ $? -eq 2 ]; check $? "still denies with a COMMIT_APPROVED file present"
rm -rf "$TMP"

# jq missing at hook-run time must fail open WITH a visible warning.
NO_JQ_DIR="$(mktemp -d)"
for tool in bash cat grep sed date git dirname mktemp head tr; do
  t="$(command -v "$tool" 2>/dev/null)"
  [ -n "$t" ] && ln -sf "$t" "$NO_JQ_DIR/$tool"
done
WARNING="$(PATH="$NO_JQ_DIR" bash "$HOOK" 2>&1 <<<'{"command":"git commit -m x"}' >/dev/null)"
WARN_EXIT=$?
rm -rf "$NO_JQ_DIR"
[ "$WARN_EXIT" -eq 0 ]; check $? "fails open when jq is unavailable"
echo "$WARNING" | grep -q "jq not found"; check $? "prints a visible warning when jq is unavailable"

exit "$fail"

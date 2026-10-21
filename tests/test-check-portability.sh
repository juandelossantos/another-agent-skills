#!/usr/bin/env bash
# test-check-portability.sh — the portability guard is mechanical, and the repo
# passes it.
#
# macOS ships BSD userland: `grep -P` does not exist, `sed -i` needs a backup
# suffix, `date -d`/`readlink -f` are GNU-only. Inside `$( ... || true )` these
# fail *silently*, so a gate reads empty values and blocks forever — the Gate 11
# (`validate-health-check.sh`) failure that made a Mac unable to commit.
#
# Regression origin: `grep -oP` in validate-health-check.sh, generate-health-check.sh,
# init-agents.sh and four other runtime scripts.
set -uo pipefail

RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCANNER="$REPO_ROOT/scripts/check-portability.sh"

PASSED=0; FAILED=0; TOTAL=0
assert() {
  local name="$1" condition="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$condition"; then
    echo -e "  ${GREEN}✓${NC} $name"; PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"; FAILED=$((FAILED + 1))
  fi
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fixture() {  # name, body
  local dir="$TMP/$1"
  mkdir -p "$dir/scripts" "$dir/bin"
  printf '%s\n' '#!/usr/bin/env bash' "$2" > "$dir/scripts/candidate.sh"
  echo "$dir"
}

echo ""
echo "portability guard (GNU vs BSD userland)"
echo "───────────────────────────────────────"

echo ""
echo "Group 1 — the guard exists and the framework passes"
assert "check-portability.sh exists" "[ -f '$SCANNER' ]"
assert "check-portability.sh is executable" "[ -x '$SCANNER' ]"
assert "framework runtime scripts pass the guard" "bash '$SCANNER' --root '$REPO_ROOT' >/dev/null 2>&1"

echo ""
echo "Group 2 — GNU-only syntax is rejected"
D="$(fixture grepp 'echo hi | grep -oP x')"
assert "rejects grep -oP" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture grepP 'echo hi | grep -P x')"
assert "rejects grep -P" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture sedi 'sed -i "s/a/b/" file.txt')"
assert "rejects bare sed -i" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture dated 'date -d \"2026-01-01\" +%s')"
assert "rejects date -d" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture readlink 'readlink -f ./x')"
assert "rejects readlink -f" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture sortv 'printf \"1.10\\n1.9\\n\" | sort -V')"
assert "rejects sort -V" "! bash '$SCANNER' --root '$D' >/dev/null 2>&1"

echo ""
echo "Group 3 — portable forms and fallbacks are allowed"
D="$(fixture sedibak 'sed -i.bak \"s/a/b/\" file.txt; rm -f file.txt.bak')"
assert "allows sed -i.bak" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture fallback 'EPOCH=$(date -d \"\$TS\" +%s 2>/dev/null || date -j -f \"%Y-%m-%dT%H:%M:%S\" \"\$TS\" +%s 2>/dev/null || echo 0)')"
assert "allows a BSD fallback on the same line" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture oE \"echo hi | grep -oE '[0-9]+'\")"
assert "allows grep -oE" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

D="$(fixture comment '# grep -oP is GNU-only')"
assert "allows a comment that names the syntax" "bash '$SCANNER' --root '$D' >/dev/null 2>&1"

echo ""
echo "Group 4 — the fixes it protects"
GNU_HITS="$(grep -rnE 'grep -[a-zA-Z]*P|sed[[:space:]]+-i[[:space:]]' \
  "$REPO_ROOT/scripts" "$REPO_ROOT/bin" "$REPO_ROOT/install.sh" 2>/dev/null \
  | grep -v '/eval/' | grep -v 'check-portability.sh' \
  | grep -vE ':[0-9]+:[[:space:]]*#' | wc -l | tr -d ' ')"
assert "no grep -P / bare sed -i in runtime scripts" "[ '$GNU_HITS' = '0' ]"
assert "validate-health-check.sh parses without grep -P" "! grep 'grep -[a-zA-Z]*P' '$REPO_ROOT/scripts/validate-health-check.sh' | grep -vE '^[[:space:]]*#' | grep -q ."
assert "generate-health-check.sh parses without grep -P" "! grep -q 'grep -oP' '$REPO_ROOT/scripts/generate-health-check.sh'"

echo ""
echo "Results: ${GREEN}${PASSED} passed${NC}, ${RED}${FAILED} failed${NC}, ${TOTAL} total"
[ "$FAILED" -gt 0 ] && exit 1
exit 0

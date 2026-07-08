#!/usr/bin/env bash
# test-frontmatter.sh — Validates SKILL.md YAML frontmatter integrity
# Verifies no stray lines inside the YAML --- block
#
# Usage: bash tests/test-frontmatter.sh
# Exit: 0 if all pass, 1 if any fail

set -uo pipefail
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'; NC=$'\033[0m'
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON="/tmp/yaml-venv/bin/python3"
PASSED=0; FAILED=0; TOTAL=0

assert() {
  local name="$1"; local cond="$2"
  TOTAL=$((TOTAL + 1))
  if eval "$cond"; then
    echo -e "  ${GREEN}✓${NC} $name"
    PASSED=$((PASSED + 1))
  else
    echo -e "  ${RED}✗${NC} $name"
    FAILED=$((FAILED + 1))
  fi
}

echo -e "${YELLOW}Frontmatter Integrity Test Suite${NC}"
echo "─────────────────────────────────────────"

# ─── Test 1: cli-tools description has no stray trigger text ───
echo ""
echo "Test 1: cli-tools frontmatter"
DESC1=$($PYTHON -c "
import yaml
with open('$REPO_ROOT/skills/cli-tools/SKILL.md') as f:
    content = f.read()
parts = content.split('---', 2)
fm = yaml.safe_load(parts[1])
print(fm.get('description', ''))
")
assert "description does not contain stray trigger text" "echo '$DESC1' | grep -qv 'terminal app'"
assert "description cleanly ends with GUI applications" "echo '$DESC1' | grep -q 'GUI applications\.$'"

# ─── Test 2: source-driven-development description has no stray usage line ───
echo ""
echo "Test 2: source-driven-development frontmatter"
DESC2=$($PYTHON -c "
import yaml
with open('$REPO_ROOT/skills/source-driven-development/SKILL.md') as f:
    content = f.read()
parts = content.split('---', 2)
fm = yaml.safe_load(parts[1])
print(fm.get('description', ''))
")
assert "description does not contain general programming logic" "echo '$DESC2' | grep -qv 'general programming logic'"

# ─── Test 3: skill-creator description has no stray continuation line ───
echo ""
echo "Test 3: skill-creator frontmatter"
DESC3=$($PYTHON -c "
import yaml
with open('$REPO_ROOT/skills/skill-creator/SKILL.md') as f:
    content = f.read()
parts = content.split('---', 2)
fm = yaml.safe_load(parts[1])
print(fm.get('description', ''))
")
assert "description does not contain tool-improver or one-off tasks" "echo '$DESC3' | grep -qv 'skill-improver\|one-off tasks'"

# ─── Test 4: All 58 skills parse as valid YAML ───
echo ""
echo "Test 4: All 58 skills parse as valid YAML"
INVALID=$($PYTHON -c "
import yaml, os, glob
invalid = []
skills_dir = '$REPO_ROOT/skills'
for path in glob.glob(os.path.join(skills_dir, '*', 'SKILL.md')):
    with open(path) as f:
        content = f.read()
    parts = content.split('---', 2)
    if len(parts) < 3:
        invalid.append(os.path.basename(os.path.dirname(path)))
        continue
    try:
        yaml.safe_load(parts[1])
    except Exception as e:
        invalid.append(f'{os.path.basename(os.path.dirname(path))}: {e}')
if invalid:
    print('; '.join(invalid))
")
assert "0 invalid skills" "[ -z '$INVALID' ]"

# ─── Summary ───
echo ""
echo "─────────────────────────────────────────"
echo -e "Results: ${GREEN}$PASSED passed${NC}, ${RED}$FAILED failed${NC}, $TOTAL total"
echo ""
[ "$FAILED" -gt 0 ] && exit 1 || exit 0

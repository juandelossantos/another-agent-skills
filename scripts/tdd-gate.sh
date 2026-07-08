#!/usr/bin/env bash
# tdd-gate.sh — TDD Pre-Commit Gate (Phase 0)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Enforces that every code change is accompanied by a test.
# Language-agnostic, mechanical, binary pass/fail.
#
# Usage: bash scripts/tdd-gate.sh
# Env:   COMMIT_MSG (optional) — commit message body for OVERRIDE detection
# Exit:  0 = PASS/SKIP, 1 = BLOCK
#
# Spec: development/SPEC-TDD-GATE.md

set -uo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
GATE_LOG="${REPO_ROOT}/.git/TDD_GATE_LOG"

# Determine the repo root from current directory (for temp repo support)
REPO_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# ─── File Patterns ───

CODE_PATTERNS=(
  '*.js' '*.ts' '*.jsx' '*.tsx' '*.mjs' '*.cjs'
  '*.py' '*.rs' '*.go' '*.rb' '*.dart' '*.swift'
  '*.kt' '*.kts' '*.java' '*.c' '*.cpp' '*.h' '*.hpp'
  '*.sh' '*.bash'
)

TEST_PATTERNS=(
  '*.test.*' '*.spec.*'
  'test_*' '*_test.*' '*_spec.*'
  'tests/*' 'test/*'
)

# ─── Helpers ───

is_code_file() {
  local file="$1"
  for pattern in "${CODE_PATTERNS[@]}"; do
    # Convert glob to regex: * -> .* , anchor with ^ and $
    local regex="^${pattern//\*/.*}$"
    if [[ "$file" =~ $regex ]]; then
      return 0
    fi
  done
  return 1
}

is_test_file() {
  local file="$1"
  for pattern in "${TEST_PATTERNS[@]}"; do
    local regex="^${pattern//\*/.*}$"
    if [[ "$file" =~ $regex ]]; then
      return 0
    fi
  done
  return 1
}

has_override() {
  local msg="${COMMIT_MSG:-}"
  if [[ -z "$msg" ]]; then
    # Try to read from COMMIT_EDITMSG if in a git repo
    if [[ -f "${REPO_DIR}/.git/COMMIT_EDITMSG" ]]; then
      msg=$(cat "${REPO_DIR}/.git/COMMIT_EDITMSG")
    fi
  fi
  [[ "$msg" =~ OVERRIDE: ]]
}

log_gate() {
  local decision="$1"
  local code_files="$2"
  local test_files="$3"
  local override="$4"
  mkdir -p "$(dirname "$GATE_LOG")"
  cat > "$GATE_LOG" << EOF
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
decision=$decision
code_files=$code_files
test_files=$test_files
override=$override
EOF
}

# ─── Main ───

# Get staged files (added, copied, modified only — not deleted)
STAGED_FILES=$(git -C "$REPO_DIR" diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)

if [[ -z "$STAGED_FILES" ]]; then
  log_gate "SKIP" "none" "none" "no-staged-files"
  exit 0
fi

# Classify staged files
CODE_FILES=()
TEST_FILES=()

while IFS= read -r file; do
  if is_test_file "$file"; then
    TEST_FILES+=("$file")
  elif is_code_file "$file"; then
    CODE_FILES+=("$file")
  fi
done <<< "$STAGED_FILES"

# No code files staged → SKIP
if [[ ${#CODE_FILES[@]} -eq 0 ]]; then
  log_gate "SKIP" "none" "${TEST_FILES[*]:-none}" "no-code-files"
  exit 0
fi

# Check for OVERRIDE
if has_override; then
  log_gate "PASS" "${CODE_FILES[*]}" "${TEST_FILES[*]:-none}" "override-used"
  exit 0
fi

# Code files staged but no test files → BLOCK
if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  TDD GATE: Test companion required              ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  echo "Code files staged without test files:"
  for f in "${CODE_FILES[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Options:"
  echo "  1. Stage a test file: git add tests/<name>.test.js"
  echo "  2. Override (explain why): add OVERRIDE: reason to commit body"
  echo ""
  echo "Example: git commit -m \"fix: hotfix\" -m \"OVERRIDE: typo-only change\""
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "none" "no"
  exit 1
fi

# Code + test staged → PASS
log_gate "PASS" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "no"
exit 0

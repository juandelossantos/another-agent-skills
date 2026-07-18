#!/usr/bin/env bash
# tdd-gate.sh — TDD Pre-Commit Gate (Phase 0)
# Part of another-agent-skills (github.com/juandelossantos/another-agent-skills)
#
# Enforces that every code change is accompanied by a test.
# Language-agnostic, mechanical, binary pass/fail.
#
# Usage: bash scripts/tdd-gate.sh
# Env:   (no override mechanism — every change requires a test)
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
  '*.html' '*.htm'
  '*.json' '*.md' '*.markdown' '*.yaml' '*.yml'
  '*.css' '*.scss' '*.less'
  '*.toml' '*.xml' '*.svg' '*.txt' '*.csv'
)

TEST_PATTERNS=(
  '*.test.*' '*.spec.*'
  'test_*' '*_test.*' '*_spec.*'
  'tests/*' 'test/*'
)

SKIP_PATTERNS=(
  '*.lock' '*.sum' '*lock*'
  '*.png' '*.jpg' '*.jpeg' '*.gif' '*.ico'
  '*.woff' '*.woff2' '*.ttf' '*.eot'
  '*.mp4' '*.webm' '*.ogg'
  '*.zip' '*.tar' '*.gz' '*.bz2'
  '*.pdf' '*.doc' '*.docx'
  '*.o' '*.class' '*.pyc'
  '.gitignore' '.env*'
  'SKILL.md'
)

# ─── Helpers ───

is_code_file() {
  local file="$1"
  local filepath="${REPO_DIR}/${file}"

  # Skip known non-code patterns (binaries, lock files, etc.)
  for pattern in "${SKIP_PATTERNS[@]}"; do
    local regex="^${pattern//\*/.*}$"
    if [[ "$file" =~ $regex ]]; then
      return 1
    fi
  done

  # Check extension-based patterns
  for pattern in "${CODE_PATTERNS[@]}"; do
    # Convert glob to regex: * -> .* , anchor with ^ and $
    local regex="^${pattern//\*/.*}$"
    if [[ "$file" =~ $regex ]]; then
      return 0
    fi
  done

  # Check if file is in scripts/git-hooks/ directory (extensionless shell scripts)
  if [[ "$file" =~ ^scripts/git-hooks/ ]]; then
    return 0
  fi

  # Check if file has a shebang (#!/usr/bin/env bash, #!/bin/bash, #!/bin/sh, etc.)
  if [[ -f "$filepath" ]]; then
    local first_line
    first_line=$(head -1 "$filepath" 2>/dev/null || true)
    if [[ "$first_line" =~ ^\#\!/(usr/bin/env\ )?(bin/|usr/bin/)?(bash|sh|zsh|dash|ksh|fish|python|python3|ruby|node|perl|php)(\ |$) ]]; then
      return 0
    fi
  fi

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

# Extract code file stem (basename without extension) for name-pairing
get_code_stem() {
  local file="$1"
  local basename
  basename=$(basename "$file")
  # Strip extension
  local stem="${basename%.*}"
  # Remove trailing numbers or version suffixes often used in scripts
  echo "$stem"
}

# Extract test file stem by stripping test prefixes/suffixes
get_test_stem() {
  local file="$1"
  local basename
  basename=$(basename "$file")
  local stem="${basename%.*}"
  # Strip common test markers
  stem="${stem#test-}"
  stem="${stem#test_}"
  stem="${stem%-test}"
  stem="${stem%_test}"
  stem="${stem#Test}"
  stem="${stem#spec-}"
  stem="${stem#spec_}"
  stem="${stem%-spec}"
  stem="${stem%_spec}"
  stem="${stem#.test}"
  stem="${stem#.spec}"
  echo "$stem"
}

# Check if a test file name-matches a code file (pairing check)
name_matches_code() {
  local code_file="$1"
  local test_file="$2"
  local code_stem
  local test_stem
  local code_basename
  local test_basename

  code_stem=$(get_code_stem "$code_file")
  test_stem=$(get_test_stem "$test_file")
  code_basename=$(basename "$code_file")
  test_basename=$(basename "$test_file")

  # Exact stem match (with case-insensitive fallback)
  [[ "$test_stem" == "$code_stem" ]] && return 0

  # Test file basename contains code file basename (handles multi-word like "pre-commit")
  [[ "$test_basename" == *"$code_basename"* ]] && return 0

  # Test stem contains code stem (handles "test_pre_commit_gates" for "pre_commit")
  [[ "$test_stem" == *"$code_stem"* ]] && return 0

  # Case-insensitive stem match (handles DESIGN-MD-SCHEMA vs design-md-schema)
  [[ "${test_stem,,}" == "${code_stem,,}" ]] && return 0

  # Case-insensitive containment (handles "guide-refs" testing skill named "SKILL" or "DISCOVERY-GUIDE")
  [[ "${code_stem,,}" == *"${test_stem,,}"* ]] && return 0
  [[ "${test_stem,,}" == *"${code_stem,,}"* ]] && return 0

  return 1
}

# Check if a staged file is new (doesn't exist in HEAD)
is_new_file() {
  local file="$1"
  local repo_dir="${REPO_DIR:-.}"
  git -C "$repo_dir" ls-tree HEAD -- "$file" 2>/dev/null | grep -q . && return 1
  return 0
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
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "none" "no"
  exit 1
fi

# ─── Name-Pairing Check ───
# For each code file, at least one test file must name-match
MISMATCHED=()
for cfile in "${CODE_FILES[@]}"; do
  FOUND_MATCH=false
  for tfile in "${TEST_FILES[@]}"; do
    if name_matches_code "$cfile" "$tfile"; then
      FOUND_MATCH=true
      break
    fi
  done
  if ! $FOUND_MATCH; then
    MISMATCHED+=("$cfile")
  fi
done

if [[ ${#MISMATCHED[@]} -gt 0 ]]; then
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  TDD GATE: Name-pairing failed                  ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  echo "Code files without a name-matching test:"
  for f in "${MISMATCHED[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Staged test file(s):"
  for f in "${TEST_FILES[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Expected: test file name containing '$(get_code_stem "${MISMATCHED[0]}")'"
  echo ""
  echo "Options:"
  echo "  1. Stage a correctly-named test: git add tests/test_<code_name>.sh"
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "name-mismatch"
  exit 1
fi

# ─── New-Test Check ───
# At least one staged test file must be new (not in HEAD)
HAS_NEW_TEST=false
for tfile in "${TEST_FILES[@]}"; do
  if is_new_file "$tfile"; then
    HAS_NEW_TEST=true
    break
  fi
done

if ! $HAS_NEW_TEST; then
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  TDD GATE: New test file required               ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  echo "All staged test files already exist in HEAD."
  echo "Each change must include at least one new test file."
  echo ""
  echo "Staged tests (all pre-existing):"
  for f in "${TEST_FILES[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "Options:"
  echo "  1. Create and stage a new test file"
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "no-new-test"
  exit 1
fi

# ─── Staging-Order Check ───
# Verify that for new code files, the test was created BEFORE the code
# (TDD: test first, then code). Uses file mtime comparison.
ORDER_FAIL=false
for cfile in "${CODE_FILES[@]}"; do
  # Only check new code files (not in HEAD)
  if ! is_new_file "$cfile"; then
    continue
  fi
  CODE_MTIME=$(stat -c '%Y' "$cfile" 2>/dev/null || echo 0)
  [ "$CODE_MTIME" -eq 0 ] && continue
  for tfile in "${TEST_FILES[@]}"; do
    if name_matches_code "$cfile" "$tfile"; then
      TEST_MTIME=$(stat -c '%Y' "$tfile" 2>/dev/null || echo 0)
      [ "$TEST_MTIME" -eq 0 ] && continue
      if [ "$TEST_MTIME" -gt "$CODE_MTIME" ]; then
        echo "  - $tfile (mtime=$TEST_MTIME) is newer than $cfile (mtime=$CODE_MTIME)"
        echo "    Test was created/modified after code. TDD requires test first."
        ORDER_FAIL=true
      fi
      break
    fi
  done
done

if $ORDER_FAIL; then
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  TDD GATE: Staging-order violation              ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  echo "New code files were created before their matching tests."
  echo "TDD requires: write test first, see it fail, then write code."
  echo ""
  echo "Options:"
  echo "  1. Remove the code file, write the test first, then re-create code"
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "staging-order"
  exit 1
fi

# Code + matching new test staged → PASS
log_gate "PASS" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "no"
exit 0

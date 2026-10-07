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

# Without a git work tree there is nothing to gate. Skip cleanly and, crucially,
# do NOT create a stray .git/ directory (log_gate writes into $GATE_LOG).
if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "TDD gate: SKIP — not a git repository"
  exit 0
fi

# ─── File Patterns ───

# ── Phase 13 (S1): classify by TYPE, not by name ──
# code = has behavior to test (paired test). docs/config have their OWN
# validators (docs-honesty S2 / config-consistency S3) — they are NOT code.
CODE_PATTERNS=(
  '*.js' '*.ts' '*.jsx' '*.tsx' '*.mjs' '*.cjs'
  '*.py' '*.rs' '*.go' '*.rb' '*.dart' '*.swift'
  '*.kt' '*.kts' '*.java' '*.c' '*.cpp' '*.h' '*.hpp'
  '*.sh' '*.bash'
  '*.html' '*.htm'
  '*.css' '*.scss' '*.less'
)

# Documentation — verified by the docs-honesty validator (S2), not a paired test.
DOC_PATTERNS=( '*.md' '*.markdown' '*.txt' '*.adoc' )

# Config — verified by the config-consistency validator (S3).
CONFIG_PATTERNS=( '*.json' '*.yaml' '*.yml' '*.toml' '*.xml' '*.svg' '*.csv' )

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
  # The web project (Astro) is a separate build for the public site + docs. It
  # has its own test suite (web/tests: node:test + Playwright) run by its own CI,
  # not this gate — and the core CI must never build it. Skip it here.
  'web/*'
)

# ─── AAS-managed artifacts (installed/updated by init-agents) ───
# Framework files that the user is NOT expected to author, so they never require
# a paired test. The exemption is a UNIVERSAL DEFAULT in a consumer project; it
# is SKIPPED in the framework repo itself, where these paths are real source and
# must stay gated (is_framework_repo, below). Path-based: a new installed
# artifact must be added here — or to the project's .aas/tdd-ignore.
AAS_MANAGED_PATTERNS=(
  '.aas/*'
  '.husky/*'
  '.github/workflows/gates.yml'
  'rules/*'
  'skills/*'
  '.claude/skills/*'
  '.opencode/skills/*'
  '.agents/skills/*'
  'ADRs/*'
  'AGENTS.md' 'AGENTS-EXTENDED.md' 'CLAUDE.md' 'GEMINI.md'
  'SOUL.md' 'VERSION'
  'STACK_CONFIG.md' 'STACK_CONFIG_TEMPLATE.md'
  'HEALTH-CHECK.md' 'PATTERNS.md' 'ANTI-PATTERNS.md'
  '.sessionrc' '.audit-config.json'
)

# The framework repo itself — same signal as init-agents' is_framework_repo()
# (VERSION + scripts/git-hooks/pre-commit + SOUL.md). In a consumer project those
# first two are installed copies / absent, so this is false there.
is_framework_repo() {
  [ -f "${REPO_DIR}/VERSION" ] \
    && [ -f "${REPO_DIR}/scripts/git-hooks/pre-commit" ] \
    && [ -f "${REPO_DIR}/SOUL.md" ]
}
IS_FRAMEWORK_REPO=false
if is_framework_repo; then IS_FRAMEWORK_REPO=true; fi

# Glob (`*` plus literal `.`) → anchored ERE. Escapes `.` so `.aas/*` does not
# also match `Xaas/...` (the SKIP/CODE patterns below use a looser conversion).
aas_glob_to_regex() {
  local g="${1//./\\.}"
  printf '%s' "^${g//\*/.*}$"
}

# A portable AAS shim: `#!/bin/sh` + the framework delegation line. Detected by
# CONTENT so the framework's own scripts (real source, no delegation) stay gated
# — and, crucially, so init-agents.sh (which merely embeds the shim TEMPLATE,
# with `\$` escapes) is NOT mistaken for a shim.
is_aas_shim() {
  local filepath="$1"
  [ -f "$filepath" ] || return 1
  [ "$(head -1 "$filepath" 2>/dev/null)" = "#!/bin/sh" ] || return 1
  grep -q 'exec "$_AAS_ROOT/' "$filepath" 2>/dev/null
}

# Optional per-project exclusions: .aas/tdd-ignore (one glob per line; `#`
# comments). Read once, here, so is_code_file does not re-read it per file.
TDD_IGNORE_PATTERNS=()
if [ -f "${REPO_DIR}/.aas/tdd-ignore" ]; then
  while IFS= read -r _aas_pat; do
    [ -z "$_aas_pat" ] && continue
    case "$_aas_pat" in \#*) continue ;; esac
    TDD_IGNORE_PATTERNS+=("$_aas_pat")
  done < "${REPO_DIR}/.aas/tdd-ignore"
fi

# ─── Helpers ───

# Classify a staged file by TYPE (Phase 13 S1). Prints `code`, `docs`, `config`,
# or nothing (other / AAS-exempt). The AAS exemptions (PR #58) and `.aas/tdd-ignore`
# apply to EVERY type — a `rules/*.md` is not a docs file to verify either.
classify_file() {
  local file="$1"
  local filepath="${REPO_DIR}/${file}"
  local regex pattern

  # Skip known non-code patterns (binaries, lock files, etc.)
  for pattern in "${SKIP_PATTERNS[@]}"; do
    if [[ "$pattern" != *'*'* ]]; then
      [[ "$(basename "$file")" == "$pattern" ]] && return 0
    else
      # Anchored ERE (`.` escaped, so `*.o` matches object files only — NOT `a.go`
      # or `logo`; the old unescaped form silently skipped Go/`.so`/`.io` sources).
      regex="$(aas_glob_to_regex "$pattern")"
      [[ "$file" =~ $regex ]] && return 0
    fi
  done

  # ── AAS exemptions (apply to every type) ──
  # 1) Portable AAS shims (a consumer's scripts/*.sh delegates to the framework).
  is_aas_shim "$filepath" && return 0
  # 2) Per-project exclusions (.aas/tdd-ignore).
  if [ "${#TDD_IGNORE_PATTERNS[@]}" -gt 0 ]; then
    for pattern in "${TDD_IGNORE_PATTERNS[@]}"; do
      regex="$(aas_glob_to_regex "$pattern")"
      [[ "$file" =~ $regex ]] && return 0
    done
  fi
  # 3) AAS-managed artifacts — consumer projects only (see AAS_MANAGED_PATTERNS).
  if [ "$IS_FRAMEWORK_REPO" = false ]; then
    for pattern in "${AAS_MANAGED_PATTERNS[@]}"; do
      regex="$(aas_glob_to_regex "$pattern")"
      [[ "$file" =~ $regex ]] && return 0
    done
  fi

  # ── Type (docs/config before code, so a `.md` is never "code") ──
  for pattern in "${DOC_PATTERNS[@]}"; do
    regex="$(aas_glob_to_regex "$pattern")"
    [[ "$file" =~ $regex ]] && { echo docs; return 0; }
  done
  for pattern in "${CONFIG_PATTERNS[@]}"; do
    regex="$(aas_glob_to_regex "$pattern")"
    [[ "$file" =~ $regex ]] && { echo config; return 0; }
  done
  for pattern in "${CODE_PATTERNS[@]}"; do
    regex="$(aas_glob_to_regex "$pattern")"
    [[ "$file" =~ $regex ]] && { echo code; return 0; }
  done

  # Extensionless shell scripts: scripts/git-hooks/ or a shebang.
  [[ "$file" =~ ^scripts/git-hooks/ ]] && { echo code; return 0; }
  if [[ -f "$filepath" ]]; then
    local first_line
    first_line=$(head -1 "$filepath" 2>/dev/null || true)
    if [[ "$first_line" =~ ^\#\!/(usr/bin/env\ )?(bin/|usr/bin/)?(bash|sh|zsh|dash|ksh|fish|python|python3|ruby|node|perl|php)(\ |$) ]]; then
      echo code; return 0
    fi
  fi
  return 0
}

is_code_file() { [ "$(classify_file "$1")" = "code" ]; }

is_test_file() {
  local file="$1"
  for pattern in "${TEST_PATTERNS[@]}"; do
    local regex="$(aas_glob_to_regex "$pattern")"
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
  # Never create a .git/ dir when there is no git repo.
  if ! git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi
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

DOC_FILES=()
CONFIG_FILES=()

while IFS= read -r file; do
  if is_test_file "$file"; then
    TEST_FILES+=("$file")
  else
    case "$(classify_file "$file")" in
      code)   CODE_FILES+=("$file") ;;
      docs)   DOC_FILES+=("$file") ;;
      config) CONFIG_FILES+=("$file") ;;
    esac
  fi
done <<< "$STAGED_FILES"

# No code files staged → SKIP. docs/config are NOT code: their own validators
# (docs-honesty S2 / config-consistency S3) verify them; until then a non-blocking
# note — never a paired test.
if [[ ${#CODE_FILES[@]} -eq 0 ]]; then
  if [[ ${#DOC_FILES[@]} -gt 0 || ${#CONFIG_FILES[@]} -gt 0 ]]; then
    echo "TDD gate: docs/config staged — verified by their own validators (Phase 13 S2/S3); non-blocking for now."
  fi
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

# ─── Non-Empty Check (Phase 13 S1) ───
# A paired test must assert on behavior — not just exist. An empty `test-foo.sh`
# (or one that only sources/echoes) is the anti-pattern the TDD skill forbids.
ASSERTION_RE='assert|check|expect|should|it\(|test\(|\.toBe|\.toEqual|verify'
EMPTY_TESTS=()
for cfile in "${CODE_FILES[@]}"; do
  FOUND_REAL=false
  for tfile in "${TEST_FILES[@]}"; do
    if name_matches_code "$cfile" "$tfile"; then
      if grep -qE "$ASSERTION_RE" "${REPO_DIR}/${tfile}" 2>/dev/null \
         || grep -qF "$(basename "$cfile")" "${REPO_DIR}/${tfile}" 2>/dev/null; then
        FOUND_REAL=true
        break
      fi
    fi
  done
  $FOUND_REAL || EMPTY_TESTS+=("$cfile")
done

if [[ ${#EMPTY_TESTS[@]} -gt 0 ]]; then
  echo ""
  echo "╔══════════════════════════════════════════════════╗"
  echo "║  TDD GATE: Empty test (no assertion)            ║"
  echo "╚══════════════════════════════════════════════════╝"
  echo ""
  echo "Code files whose paired test asserts nothing:"
  for f in "${EMPTY_TESTS[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "A test must assert on behavior (assert/check/expect) or invoke the code."
  echo ""
  log_gate "BLOCK" "${CODE_FILES[*]}" "${TEST_FILES[*]}" "empty-test"
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
  CODE_MTIME=$(stat -c '%Y' "$cfile" 2>/dev/null || stat -f '%m' "$cfile" 2>/dev/null || echo 0)
  [ "$CODE_MTIME" -eq 0 ] && continue
  for tfile in "${TEST_FILES[@]}"; do
    if name_matches_code "$cfile" "$tfile"; then
      TEST_MTIME=$(stat -c '%Y' "$tfile" 2>/dev/null || stat -f '%m' "$tfile" 2>/dev/null || echo 0)
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

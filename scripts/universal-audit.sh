#!/usr/bin/env bash
# universal-audit.sh — Configurable markdown audit engine (v3.0.0 P1)
# Works in ANY project via .audit-config.json. Replaces the hardcoded logic
# of audit-markdown.sh, which becomes a thin wrapper (P1.3).
#
# Usage:
#   bash scripts/universal-audit.sh                  # use ./.audit-config.json (or defaults)
#   bash scripts/universal-audit.sh --config FILE    # use a specific config
#   bash scripts/universal-audit.sh --json           # machine-readable output
#   bash scripts/universal-audit.sh --init           # create .audit-config.json template
#
# Exit codes: 0 = PASS (no core failures), 1 = FAIL (core file had a blocking issue)
set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PASS=0; WARN=0; FAIL=0
JSON_MODE=0; INIT_MODE=0
CONFIG_FILE=""
RESULTS_TMP=""

usage() { echo "Usage: bash scripts/universal-audit.sh [--json|--init|--config FILE]"; exit 2; }

while [ $# -gt 0 ]; do
  case "$1" in
    --json)  JSON_MODE=1; shift ;;
    --init)  INIT_MODE=1; shift ;;
    --config) CONFIG_FILE="${2:-}"; [ -z "$CONFIG_FILE" ] && usage; shift 2 ;;
    *) usage ;;
  esac
done

REPO_ROOT=$(pwd)

# --- --init: write a commented config template ---
if [ "$INIT_MODE" -eq 1 ]; then
  if [ -f ".audit-config.json" ]; then
    echo -e "${YELLOW}⚠${NC} .audit-config.json already exists. Aborting --init." >&2
    exit 1
  fi
  cat > .audit-config.json <<'JSON'
{
  "project_name": "my-project",
  "include_patterns": ["**/*.md"],
  "exclude_patterns": ["node_modules/**", ".git/**", "dist/**", "build/**", "vendor/**"],
  "core_files": ["^README\\.md$", "^CONTRIBUTING\\.md$", "^CHANGELOG\\.md$"],
  "max_file_length": 250,
  "length_check_paths": ["src/**", "lib/**"],
  "checks": {
    "tables": true,
    "links": true,
    "placeholders": true,
    "file_length": true,
    "mermaid": true,
    "terminology": false
  },
  "terminology_rules": {
    "guardian": "Guardian"
  }
}
JSON
  echo -e "${GREEN}✓${NC} Created .audit-config.json (edit project_name/core_files as needed)"
  exit 0
fi

# --- load config (file > ./.audit-config.json > built-in defaults) ---
CONFIG_PATH="${CONFIG_FILE:-$REPO_ROOT/.audit-config.json}"
if [ -f "$CONFIG_PATH" ]; then
  PROJECT_NAME=$(jq -r '.project_name // "project"' "$CONFIG_PATH")
  MAX_LEN=$(jq -r '.max_file_length // 250' "$CONFIG_PATH")
  EN_LINKS=$(jq -r '.checks.links' "$CONFIG_PATH"); [ "$EN_LINKS" = "null" ] && EN_LINKS=true
  EN_TABLES=$(jq -r '.checks.tables' "$CONFIG_PATH"); [ "$EN_TABLES" = "null" ] && EN_TABLES=true
  EN_PLACE=$(jq -r '.checks.placeholders' "$CONFIG_PATH"); [ "$EN_PLACE" = "null" ] && EN_PLACE=true
  EN_LEN=$(jq -r '.checks.file_length' "$CONFIG_PATH"); [ "$EN_LEN" = "null" ] && EN_LEN=true
  EN_MERMAID=$(jq -r '.checks.mermaid' "$CONFIG_PATH"); [ "$EN_MERMAID" = "null" ] && EN_MERMAID=true
  EN_TERM=$(jq -r '.checks.terminology' "$CONFIG_PATH"); [ "$EN_TERM" = "null" ] && EN_TERM=false
  CORE_REGEX=$(jq -r '.core_files | join("|") // ""' "$CONFIG_PATH")
  LEN_PATHS=$(jq -r '.length_check_paths | join("|") // ""' "$CONFIG_PATH")
  EXCLUDES=$(jq -r '.exclude_patterns | join("\n") // ""' "$CONFIG_PATH")
  TERM_RULES=$(jq -r '.terminology_rules | to_entries | map("\(.key)\t\(.value)") | .[]' "$CONFIG_PATH" 2>/dev/null || echo "")
else
  PROJECT_NAME="project"; MAX_LEN=250
  EN_LINKS=true; EN_TABLES=true; EN_PLACE=true; EN_LEN=true; EN_MERMAID=true; EN_TERM=false
  CORE_REGEX=""; LEN_PATHS=""; EXCLUDES='.git/**
node_modules/**
development/**
.opencode/**'; TERM_RULES=""
fi

bool_true() { [ "$1" = "true" ] || [ "$1" = "1" ]; }

# --- results accumulator: temp file avoids the subshell counter bug ---
RESULTS_TMP=$(mktemp)
trap 'rm -f "$RESULTS_TMP"' EXIT
add_result() {
  # args: status(FAIL|WARN|PASS) type file message
  printf '%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" >> "$RESULTS_TMP"
}

# --- discover files: include **/*.md, apply excludes ---
discover_files() {
  local raw excl
  raw=$(find . -name "*.md" 2>/dev/null | sort)
  if [ -n "$EXCLUDES" ]; then
    while IFS= read -r excl; do
      [ -z "$excl" ] && continue
      local pat="${excl#./}"
      raw=$(echo "$raw" | grep -vE "^\.\/${pat//\*/.*}" || true)
    done <<EOF
$EXCLUDES
EOF
  fi
  echo "$raw"
}

MD_FILES=$(discover_files)

is_core() { [ -z "$CORE_REGEX" ] && return 1; local n="${1#./}"; echo "$n" | grep -qE "$CORE_REGEX"; }

# --- CHECK 1: table column consistency ---
check_tables() {
  bool_true "$EN_TABLES" || return 0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    awk '/^\|----/ { sep=$0; sepc=gsub(/\|/,"|",sep)
      if (prev ~ /^\|/ && prev !~ /^\|----/) { hc=gsub(/\|/,"|",prev)
        if (sepc!=hc) print FILENAME": table column mismatch (header="hc", separator="sepc")" } }
      { prev=$0 }' "$f" 2>/dev/null | while IFS= read -r issue; do
      add_result "FAIL" "table" "$f" "$issue"
    done
  done <<EOF
$MD_FILES
EOF
}

# --- CHECK 2: broken internal links ---
check_links() {
  bool_true "$EN_LINKS" || return 0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    local dir; dir=$(dirname "$f")
    while IFS= read -r link; do
      [ -z "$link" ] && continue
      local target; target=$(echo "$link" | sed 's/^.*](//; s/)$//; s/#.*$//')
      [ -z "$target" ] && continue
      echo "$target" | grep -qE '^https?://' && continue
      echo "$target" | grep -qE '^#' && continue
      local resolved
      if echo "$target" | grep -qE '^\.\.?/'; then resolved="$dir/$target"; else resolved="./$target"; fi
      if [ ! -f "$resolved" ] && [ ! -d "$resolved" ]; then
        add_result "FAIL" "link" "$f" "$f: broken link -> $target"
      fi
    done < <(grep -oE '\]\([^)]+\.md[^)]*\)' "$f" 2>/dev/null || true)
  done <<EOF
$MD_FILES
EOF
}

# --- CHECK 3: placeholder detection (skips fenced code blocks) ---
check_placeholders() {
  bool_true "$EN_PLACE" || return 0
  local pats="TODO:|FIXME:|XXX|coming soon|under construction|lorem ipsum"
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    # awk tracks fenced code blocks with fence-length awareness (CommonMark:
    # closing fence must be >= opening fence length; inner shorter fences are literal)
    awk -v pats="$pats" '
      /^```/ {
        match($0, /^`+/)
        fence_len = RLENGTH
        if (!in_block) { in_block = 1; open_len = fence_len }
        else if (fence_len >= open_len) { in_block = 0; open_len = 0 }
        next
      }
      !in_block && $0 ~ pats { printf "%d\t%s\n", NR, $0 }
    ' "$f" 2>/dev/null | while IFS=$'\t' read -r ln line; do
      [ -z "$ln" ] && continue
      local txt; txt=$(echo "$line" | tr -d '[:space:]' | head -c 60)
      add_result "WARN" "placeholder" "$f" "$f:$ln: placeholder found: $txt"
    done
  done <<EOF
$MD_FILES
EOF
}

# --- CHECK 4: file length compliance ---
check_length() {
  bool_true "$EN_LEN" || return 0
  [ -z "$LEN_PATHS" ] && return 0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    echo "$f" | grep -qE "$LEN_PATHS" || continue
    local lines; lines=$(wc -l < "$f")
    [ "$lines" -gt "$MAX_LEN" ] && add_result "FAIL" "length" "$f" "$f: $lines lines (max $MAX_LEN)"
  done <<EOF
$MD_FILES
EOF
}

# --- CHECK 5: mermaid (count only) ---
check_mermaid() {
  bool_true "$EN_MERMAID" || return 0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    local c; c=$(grep -c '```mermaid' "$f" 2>/dev/null || true)
    [ "$c" -gt 0 ] && add_result "PASS" "mermaid" "$f" "$f: $c diagram(s)"
  done <<EOF
$MD_FILES
EOF
}

# --- CHECK 6: consistent terminology ---
check_terminology() {
  bool_true "$EN_TERM" || return 0
  [ -z "$TERM_RULES" ] && return 0
  while IFS= read -r rule; do
    [ -z "$rule" ] && continue
    local bad good; bad=$(echo "$rule" | cut -f1); good=$(echo "$rule" | cut -f2)
    while IFS= read -r f; do
      [ -f "$f" ] || continue
      local n; n=$(grep -c "\\b${bad}\\b" "$f" 2>/dev/null || true)
      [ "$n" -gt 0 ] && add_result "WARN" "terminology" "$f" "$f: $n lowercase '$bad' (should be '$good')"
    done <<EOF
$MD_FILES
EOF
  done <<EOF
$TERM_RULES
EOF
}

# --- run all checks ---
check_tables
check_links
check_placeholders
check_length
check_mermaid
check_terminology

# --- tally, classifying FAIL on core files as blocking, non-core as WARN ---
while IFS=$'\t' read -r status type file msg; do
  if [ "$status" = "PASS" ]; then PASS=$((PASS + 1))
  elif [ "$status" = "WARN" ]; then WARN=$((WARN + 1))
  else
    if is_core "$file"; then FAIL=$((FAIL + 1)); else WARN=$((WARN + 1)); fi
  fi
done < "$RESULTS_TMP"

# --- JSON output ---
emit_json() {
  local ft wt
  ft=$(mktemp); wt=$(mktemp)
  while IFS=$'\t' read -r status type file msg; do
    case "$status" in
      FAIL) if is_core "$file"; then printf '%s\t%s\t%s\n' "$type" "$file" "$msg" >> "$ft"; else printf '%s\t%s\t%s\n' "$type" "$file" "$msg" >> "$wt"; fi ;;
      WARN) printf '%s\t%s\t%s\n' "$type" "$file" "$msg" >> "$wt" ;;
    esac
  done < "$RESULTS_TMP"
  local fails warns
  fails=$(jq -R 'split("\t") | {"type":.[0],"file":.[1],"message":.[2]}' "$ft" 2>/dev/null | jq -s '.')
  warns=$(jq -R 'split("\t") | {"type":.[0],"file":.[1],"message":.[2]}' "$wt" 2>/dev/null | jq -s '.')
  rm -f "$ft" "$wt"
  jq -n --argjson f "$fails" --argjson w "$warns" \
    --argjson p "$PASS" --argjson wn "$WARN" --argjson fl "$FAIL" \
    '{summary:{pass:$p,warn:$wn,fail:$fl},failures:$f,warnings:$w}'
}

if [ "$JSON_MODE" -eq 1 ]; then emit_json; else
  echo "╔══════════════════════════════════════════════════════════════╗"
  printf "║  MARKDOWN AUDIT — %-43s║\n" "$PROJECT_NAME"
  echo "╚══════════════════════════════════════════════════════════════╝"
  echo ""
  while IFS=$'\t' read -r status type file msg; do
    case "$status" in
      FAIL) if is_core "$file"; then echo -e "  ${RED}✗${NC} $msg"; else echo -e "  ${YELLOW}⚠${NC} $msg"; fi ;;
      WARN) echo -e "  ${YELLOW}⚠${NC} $msg" ;;
    esac
  done < "$RESULTS_TMP"
  echo ""
  echo -e "  ${GREEN}PASS:${NC} $PASS  ${YELLOW}WARN:${NC} $WARN  ${RED}FAIL:${NC} $FAIL"
  if [ "$FAIL" -gt 0 ]; then
    echo -e "  ${RED}❌ Fix core-file failures before proceeding.${NC}"
    exit 1
  else
    echo -e "  ${GREEN}✅ All checks passed.${NC}"
    exit 0
  fi
fi

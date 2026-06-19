#!/usr/bin/env bash
# sync-progress-table.sh — Auto-generate the skill table for PROGRESS_STATUS.md
# Usage:
#   bash scripts/sync-progress-table.sh --check   # Verify table is in sync
#   bash scripts/sync-progress-table.sh --apply   # Regenerate skill table
#
# Only replaces the skill inventory table (| `skill` | lines | guides | desc |)
# Preserves all other sections of PROGRESS_STATUS.md.

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
PROGRESS_FILE="PROGRESS_STATUS.md"
MODE="${1:---check}"

if [ ! -f "$PROGRESS_FILE" ]; then echo "FAIL: $PROGRESS_FILE not found"; exit 1; fi

# Generate table from disk
generate_table() {
  # Find the existing header line (### N Custom Skills)
  HEADER=$(grep -m1 "^### [0-9]* Custom Skills" "$PROGRESS_FILE" || echo "### $(ls -d skills/*/ 2>/dev/null | wc -l) Custom Skills")
  echo "$HEADER"
  echo ""
  echo "| Skill | Lines | Guides | Description |"
  echo "|---|---|---|---|"
  for skill_dir in skills/*/; do
    name=$(basename "$skill_dir")
    skill_file="${skill_dir}SKILL.md"
    [ -f "$skill_file" ] || continue
    lines=$(wc -l < "$skill_file")
    # Count guides
    guides=0
    root_guides=$(find "$skill_dir" -maxdepth 1 -type f \( -iname '*guide*' -o -iname '*checklist*' -o -iname '*examples*' -o -iname '*memory*' \) 2>/dev/null | wc -l)
    guides=$((guides + root_guides))
    if [ -d "${skill_dir}guides" ]; then
      sub_guides=$(find "${skill_dir}guides" -name "*.md" 2>/dev/null | wc -l)
      guides=$((guides + sub_guides))
    fi
    # Extract description (handle folded YAML: description: > followed by indented lines)
    desc=$(sed -n '/^description: >/,/^[a-z]/p' "$skill_file" | tail -n +2 | head -1 | sed 's/^ *//' || echo "")
    if [ -z "$desc" ]; then
      desc=$(grep -oP '(?<=^description: ").*(?=")' "$skill_file" | head -1 || echo "")
    fi
    desc=$(echo "$desc" | cut -c1-80)
    printf "| \`%s\` | %d | %d | %s |\n" "$name" "$lines" "$guides" "$desc"
  done | sort -t'`' -k2
}

TABLE=$(generate_table)

if [ "$MODE" == "--check" ]; then
  # Find the current table in PROGRESS_STATUS.md
  TABLE_START=$(grep -n "^### [0-9]* Custom Skills" "$PROGRESS_FILE" | cut -d: -f1)
  if [ -z "$TABLE_START" ]; then
    echo "FAIL: Could not find skill inventory section in $PROGRESS_FILE"
    exit 1
  fi
  TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^###" | head -1 | cut -d: -f1)
  [ -z "$TABLE_END" ] && TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^---" | head -1 | cut -d: -f1)
  TABLE_END=$((TABLE_START + TABLE_END - 1))

  CURRENT_TABLE=$(sed -n "${TABLE_START},${TABLE_END}p" "$PROGRESS_FILE")

  # Compare (skip whitespace differences)
  GENERATED_CLEAN=$(echo "$TABLE" | sed 's/^ *|/|/' | sed 's/| *$/|/')
  CURRENT_CLEAN=$(echo "$CURRENT_TABLE" | sed 's/^ *|/|/' | sed 's/| *$/|/')

  if [ "$GENERATED_CLEAN" != "$CURRENT_CLEAN" ]; then
    echo "FAIL: PROGRESS_STATUS.md skill table is out of sync with disk"
    echo "Run 'bash scripts/sync-progress-table.sh --apply' to update."
    exit 1
  fi
  echo "PASS: PROGRESS_STATUS.md skill table matches disk"
  exit 0

elif [ "$MODE" == "--apply" ]; then
  TABLE_START=$(grep -n "^### [0-9]* Custom Skills" "$PROGRESS_FILE" | cut -d: -f1)
  TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^###" | head -1 | cut -d: -f1)
  [ -z "$TABLE_END" ] && TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^---" | head -1 | cut -d: -f1)
  TABLE_END=$((TABLE_START + TABLE_END - 1))

  {
    head -n "$((TABLE_START - 1))" "$PROGRESS_FILE"
    echo ""
    echo "$TABLE"
    echo ""
    tail -n +"$((TABLE_END + 1))" "$PROGRESS_FILE"
  } > "${PROGRESS_FILE}.tmp"
  mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
  echo "PROGRESS_STATUS.md skill table updated."
  exit 0

else
  echo "Usage: $0 {--check|--apply}"
  exit 1
fi

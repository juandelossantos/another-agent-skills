#!/bin/sh
# validate-skill-table.sh — Verify PROGRESS_STATUS.md skill table matches disk state
# Only validates the skill inventory table, not refactoring/architecture tables.
# Exit codes: 0 = PASS, 1 = FAIL (mismatch found)

set -e

PROGRESS_FILE="PROGRESS_STATUS.md"
SKILLS_DIR="skills"
ERRORS=0

if [ ! -f "$PROGRESS_FILE" ]; then
  echo "FAIL: $PROGRESS_FILE not found"
  exit 1
fi

echo "=== Validating skill table: $PROGRESS_FILE vs $SKILLS_DIR/ ==="

# Find the skill inventory table: lines starting with "| `" between the
# "### 41 Custom Skills" header and the next "###" header
TABLE_START=$(grep -n "^### [0-9]* Custom Skills" "$PROGRESS_FILE" | cut -d: -f1)
TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^###" | head -1 | cut -d: -f1)
if [ -z "$TABLE_END" ]; then
  TABLE_END=$(sed -n "$((TABLE_START + 1)),\$p" "$PROGRESS_FILE" | grep -n "^---" | head -1 | cut -d: -f1)
fi

if [ -z "$TABLE_START" ]; then
  echo "FAIL: Could not find skill inventory section in $PROGRESS_FILE"
  exit 1
fi

TABLE_END=$((TABLE_START + TABLE_END - 1))

# Extract table data lines and store in temp file
TMP_FILE=$(mktemp)
sed -n "${TABLE_START},${TABLE_END}p" "$PROGRESS_FILE" | grep '^| `' > "$TMP_FILE"

# Get actual skill directories on disk
DISK_SKILLS=$(mktemp)
ls -d "$SKILLS_DIR"/*/ 2>/dev/null | sed 's|^skills/||; s|/$||' | sort > "$DISK_SKILLS"

# Build set of table skills
TABLE_SKILLS=$(mktemp)
sed 's/^| `\([^`]*\)`.*/\1/' "$TMP_FILE" | sort > "$TABLE_SKILLS"

# Check skills in table that don't exist on disk
while IFS= read -r skill; do
  [ -z "$skill" ] && continue
  if [ ! -d "$SKILLS_DIR/$skill" ]; then
    echo "FAIL: '$skill' is listed in $PROGRESS_FILE but has no directory in $SKILLS_DIR/"
    ERRORS=$((ERRORS + 1))
  fi
done < "$TABLE_SKILLS"

# Check skills on disk that are missing from table
while IFS= read -r skill; do
  [ -z "$skill" ] && continue
  if ! grep -qxF "$skill" "$TABLE_SKILLS"; then
    actual_lines=$(wc -l < "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null || echo 0)
    echo "FAIL: '$skill' ($actual_lines lines) exists in $SKILLS_DIR/ but is not listed in $PROGRESS_FILE"
    ERRORS=$((ERRORS + 1))
  fi
done < "$DISK_SKILLS"

# Verify line counts
while IFS= read -r line; do
  [ -z "$line" ] && continue
  skill=$(echo "$line" | sed 's/^| `\([^`]*\)`.*/\1/')
  claimed_lines=$(echo "$line" | sed 's/^| `[^`]*` | \([0-9]*\) .*/\1/')
  if [ -d "$SKILLS_DIR/$skill" ]; then
    actual_lines=$(wc -l < "$SKILLS_DIR/$skill/SKILL.md" 2>/dev/null || echo 0)
    if [ "$claimed_lines" != "$actual_lines" ] 2>/dev/null; then
      echo "FAIL: '$skill' claims $claimed_lines lines but SKILL.md has $actual_lines"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done < "$TMP_FILE"

TOTAL_SKILLS=$(wc -l < "$TABLE_SKILLS")
rm -f "$TMP_FILE" "$DISK_SKILLS" "$TABLE_SKILLS"

echo "---"
if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: All $TOTAL_SKILLS skills match disk state"
  exit 0
else
  echo "FAIL: $ERRORS error(s) found. Update $PROGRESS_FILE to match $SKILLS_DIR/"
  exit 1
fi

#!/usr/bin/env bash
# validate-release-notes.sh — Verify RELEASE-NOTES.md has detailed latest entry
# Called by pre-commit test chain. Fails if the latest release entry is too brief.
# Exit codes: 0 = PASS, 1 = FAIL

set -uo pipefail

RELEASE_FILE="RELEASE-NOTES.md"
ERRORS=0

if [ ! -f "$RELEASE_FILE" ]; then
  echo "FAIL: $RELEASE_FILE not found"
  exit 1
fi

VERSION=$(cat VERSION 2>/dev/null || echo "unknown")

# Find first version entry in RELEASE-NOTES.md
FIRST_HEADER=$(grep -n "^## " "$RELEASE_FILE" | head -1)
if [ -z "$FIRST_HEADER" ]; then
  echo "FAIL: No version entry found in $RELEASE_FILE"
  exit 1
fi

LINE_NUM=$(echo "$FIRST_HEADER" | cut -d: -f1)
VERSION_TAG=$(echo "$FIRST_HEADER" | grep -oP '\d+\.\d+\.\d+' || echo "")

# Check version match
if [ "$VERSION_TAG" != "$VERSION" ]; then
  echo "FAIL: RELEASE-NOTES.md first entry is v$VERSION_TAG but VERSION is $VERSION"
  ERRORS=$((ERRORS + 1))
fi

# Extract content of the first entry
NEXT_HEADER=$(tail -n +"$((LINE_NUM + 1))" "$RELEASE_FILE" | grep -n "^## " | head -1)
if [ -z "$NEXT_HEADER" ]; then
  NOTES=$(tail -n +"$((LINE_NUM))" "$RELEASE_FILE")
else
  NEXT_LINE=$((LINE_NUM + $(echo "$NEXT_HEADER" | cut -d: -f1)))
  NOTES=$(sed -n "${LINE_NUM},$((NEXT_LINE - 1))p" "$RELEASE_FILE")
fi

NOTE_WORDS=$(echo "$NOTES" | wc -w)
NOTE_LINES=$(echo "$NOTES" | wc -l)

if [ "$NOTE_WORDS" -lt 20 ] || [ "$NOTE_LINES" -lt 5 ]; then
  echo "FAIL: RELEASE-NOTES.md first entry is too brief ($NOTE_WORDS words, $NOTE_LINES lines)"
  echo "Each release entry needs at least 20 words and 5 lines of description."
  echo "Current entry:"
  echo "$NOTES" | head -5
  ERRORS=$((ERRORS + 1))
fi

echo "---"
if [ "$ERRORS" -eq 0 ]; then
  echo "PASS: RELEASE-NOTES.md (v$VERSION, $NOTE_WORDS words, $NOTE_LINES lines)"
  exit 0
else
  echo "FAIL: $ERRORS issue(s) found in $RELEASE_FILE"
  exit 1
fi

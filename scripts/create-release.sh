#!/usr/bin/env bash
# create-release.sh — Create GitHub Release from RELEASE-NOTES.md
# Usage: bash scripts/create-release.sh
#
# Reads the latest entry from RELEASE-NOTES.md and creates a GitHub release
# with that exact content. Tag name derived from the version header.
# Prevents one-line release notes — the content comes from the committed file.

set -uo pipefail

RELEASE_FILE="RELEASE-NOTES.md"

if [ ! -f "$RELEASE_FILE" ]; then
  echo "FAIL: $RELEASE_FILE not found"
  exit 1
fi

# Find the first version header (## X.Y.Z)
FIRST_HEADER=$(grep -n "^## " "$RELEASE_FILE" | head -1)
if [ -z "$FIRST_HEADER" ]; then
  echo "FAIL: No version header found in $RELEASE_FILE"
  exit 1
fi

LINE_NUM=$(echo "$FIRST_HEADER" | cut -d: -f1)
VERSION_TAG=$(echo "$FIRST_HEADER" | grep -oP 'v?\d+\.\d+\.\d+' || echo "")
TITLE=$(echo "$FIRST_HEADER" | sed 's/^## //')

if [ -z "$VERSION_TAG" ]; then
  echo "FAIL: Could not extract version from: $FIRST_HEADER"
  exit 1
fi

# Extract content from the first version entry to the next ## or EOF
NEXT_HEADER=$(tail -n +"$((LINE_NUM + 1))" "$RELEASE_FILE" | grep -n "^## " | head -1)
if [ -z "$NEXT_HEADER" ]; then
  # No next version — read to end
  NOTES=$(tail -n +"$((LINE_NUM))" "$RELEASE_FILE")
else
  NEXT_LINE=$((LINE_NUM + $(echo "$NEXT_HEADER" | cut -d: -f1)))
  NOTES=$(sed -n "${LINE_NUM},$((NEXT_LINE - 1))p" "$RELEASE_FILE")
fi

# Validate notes are not too short
NOTE_LINES=$(echo "$NOTES" | wc -l)
NOTE_WORDS=$(echo "$NOTES" | wc -w)
if [ "$NOTE_WORDS" -lt 20 ] || [ "$NOTE_LINES" -lt 5 ]; then
  echo "FAIL: Release notes too short ($NOTE_WORDS words, $NOTE_LINES lines)"
  echo "Update $RELEASE_FILE with detailed release notes first."
  echo ""
  echo "Current notes:"
  echo "$NOTES"
  exit 1
fi

echo "=== Creating release v${VERSION_TAG} ==="
echo "Title: $TITLE"
echo "Notes: $NOTE_WORDS words, $NOTE_LINES lines"
echo ""

# Create tag and release
git tag "v${VERSION_TAG}" 2>/dev/null || true
git push origin "v${VERSION_TAG}" 2>/dev/null || true

if gh release create "v${VERSION_TAG}" --title "$TITLE" --notes "$NOTES" 2>/dev/null; then
  echo "✅ Release v${VERSION_TAG} created."
elif gh release edit "v${VERSION_TAG}" --title "$TITLE" --notes "$NOTES" 2>/dev/null; then
  echo "✅ Release v${VERSION_TAG} updated."
else
  echo "FAIL: Could not create or update release v${VERSION_TAG}"
  exit 1
fi

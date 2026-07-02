#!/usr/bin/env bash
# generate-adr.sh — Generate a MADR-format ADR file
# Usage: bash scripts/generate-adr.sh "Title" "Context" "Decision" "Consequences" "Compliance"
# Output: ADRs/ADR-NNN-title.md
set -euo pipefail

TITLE="${1:-}"
CONTEXT="${2:-}"
DECISION="${3:-}"
CONSEQUENCES="${4:-}"
COMPLIANCE="${5:-}"

if [ -z "$TITLE" ]; then
  echo "Usage: bash scripts/generate-adr.sh \"Title\" \"Context\" \"Decision\" \"Consequences\" \"Compliance\""
  exit 1
fi

# Find next ADR number
ADRS_DIR="$(dirname "$0")/../ADRs"
mkdir -p "$ADRS_DIR"

LAST_NUM=$(ls "$ADRS_DIR"/ADR-*.md 2>/dev/null | grep -oP 'ADR-\K[0-9]+' | sort -n | tail -1)
LAST_NUM=${LAST_NUM:-0}
# Strip leading zeros
LAST_NUM=$((10#$LAST_NUM))
NEXT_NUM=$((LAST_NUM + 1))
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//' | head -c 40)
FILENAME="$ADRS_DIR/ADR-$(printf '%03d' $NEXT_NUM)-$SLUG.md"

cat > "$FILENAME" << ADR
# ADR-$(printf '%03d' $NEXT_NUM): $TITLE

**Status:** Proposed
**Date:** $(date +%Y-%m-%d)

## Context

$CONTEXT

## Decision

$DECISION

## Consequences

$CONSEQUENCES

## Compliance

$COMPLIANCE
ADR

echo "$FILENAME"

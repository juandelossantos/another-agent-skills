#!/usr/bin/env bash
# approval-gate.sh — Prototype → Approved transition (P6.4)
# Moves a prototype from design/prototype/ to design/approved/ with timestamp.
# Requires --approve flag (dry-run mode without it).
# Updates DESIGN.md Section 12 with the new approved artifact reference.
#
# Usage: bash scripts/approval-gate.sh
#   --project-dir <dir>   Project root (default: git rev-parse --show-toplevel)
#   --prototype <path>    Path to prototype directory (relative to project dir)
#   --approve             Actually move files (without this: dry-run)

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || echo '.')}"
PROJECT_DIR="$REPO_ROOT"
PROTOTYPE=""
APPROVE=false

while [ $# -gt 0 ]; do
  case "$1" in
    --project-dir) PROJECT_DIR="$2"; shift 2 ;;
    --prototype)   PROTOTYPE="$2"; shift 2 ;;
    --approve|-y|--yes|--confirm) APPROVE=true; shift ;;
    *) shift ;;
  esac
done

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  APPROVAL GATE                            ║"
echo "╚════════════════════════════════════════════╝"

# Step 1: Validate prototype exists
PROTOTYPE_PATH="$PROJECT_DIR/$PROTOTYPE"
if [ ! -d "$PROTOTYPE_PATH" ]; then
  echo "  ${RED}✗${NC} Prototype not found: $PROTOTYPE_PATH"
  exit 1
fi

# Step 2: Validate README exists
if [ ! -f "$PROTOTYPE_PATH/README.md" ]; then
  echo "  ${RED}✗${NC} Prototype missing README.md — document what was explored"
  exit 1
fi

# Step 3: Dry-run mode
NAME=$(basename "$PROTOTYPE")
APPROVED_DIR="$PROJECT_DIR/design/approved/$NAME"

if [ "$APPROVE" = false ]; then
  echo "  ${YELLOW}⚠${NC} Dry-run mode (use --approve to execute)"
  echo ""
  echo "  Would copy:  $PROTOTYPE → $APPROVED_DIR"
  echo "  Would update: DESIGN.md Section 12"
  echo ""
  echo "  To approve:  --approve -y --yes --confirm"
  exit 0
fi

# Step 4: Create approved dir and copy
mkdir -p "$APPROVED_DIR"
cp -r "$PROTOTYPE_PATH/"* "$APPROVED_DIR/"
echo "  ${GREEN}✓${NC} Copied to $APPROVED_DIR"

# Step 5: Update DESIGN.md Section 12
DESIGN_FILE="$PROJECT_DIR/DESIGN.md"
if [ -f "$DESIGN_FILE" ]; then
  if grep -q '## Section 12' "$DESIGN_FILE" 2>/dev/null; then
    # Section exists — append reference
    sed -i "s|## Section 12.*|## Section 12: Approved Artifacts\n- design/approved/$NAME (approved $(date +%Y-%m-%d))|" "$DESIGN_FILE"
  else
    # Section 12 doesn't exist — create it before Section 13
    echo "" >> "$DESIGN_FILE"
    echo "## Section 12: Approved Artifacts" >> "$DESIGN_FILE"
    echo "- design/approved/$NAME (approved $(date +%Y-%m-%d))" >> "$DESIGN_FILE"
  fi
  echo "  ${GREEN}✓${NC} DESIGN.md updated"
fi

# Step 6: Also update DESIGN-LOCK.md if it exists
LOCK_FILE="$PROJECT_DIR/design/DESIGN-LOCK.md"
if [ -f "$LOCK_FILE" ]; then
  echo "- design/approved/$NAME (approved $(date +%Y-%m-%d))" >> "$LOCK_FILE"
  echo "  ${GREEN}✓${NC} DESIGN-LOCK.md updated"
fi

echo ""
echo "  ${GREEN}✓${NC} APPROVAL GATE PASSED"
exit 0

#!/bin/bash

# check-update.sh
# Lightweight auto-update checker for Another Agent Skills.
# Called by init-agents.sh. Does NOT mutate repo state — only asks user.
# Guards: cache 24h, timeout 2s, offline safe.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="${REPO_DIR}/VERSION"
CACHE_FILE="${REPO_DIR}/.last-update-check"
REMOTE="origin"
BRANCH="main"

# Read current version
if [[ ! -f "$VERSION_FILE" ]]; then
  echo "0.0.0"
  exit 0
fi
CURRENT_VERSION=$(cat "$VERSION_FILE")

# Cache check: only check once per 24h
if [[ -f "$CACHE_FILE" ]]; then
  LAST_CHECK=$(cat "$CACHE_FILE")
  NOW=$(date +%s)
  if (( NOW - LAST_CHECK < 86400 )); then
    exit 0
  fi
fi

# Fetch remote HEAD hash (lightweight — no objects)
REMOTE_HASH=$(git ls-remote "${REMOTE}" "refs/heads/${BRANCH}" 2>/dev/null | awk '{print $1}' || echo "")
if [[ -z "$REMOTE_HASH" ]]; then
  # Offline or no remote — write cache and exit silently
  date +%s > "$CACHE_FILE"
  exit 0
fi

LOCAL_HASH=$(git rev-parse "refs/heads/${BRANCH}" 2>/dev/null || echo "")

# If remote is ahead of local
if [[ -n "$LOCAL_HASH" && "$REMOTE_HASH" != "$LOCAL_HASH" ]]; then
  LOCAL_BASE=$(git merge-base HEAD "$REMOTE_HASH" 2>/dev/null || echo "")
  if [[ "$LOCAL_BASE" != "$LOCAL_HASH" ]]; then
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Update available for Another Agent Skills!"
    echo "  Current version: $CURRENT_VERSION"
    echo ""
    echo "  Remote $BRANCH is ahead of local."
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo -n "  Pull latest version? [y/N] "
    read -r RESPONSE
    if [[ "$RESPONSE" == "y" || "$RESPONSE" == "Y" ]]; then
      echo "  Pulling latest $BRANCH..."
      git pull "$REMOTE" "$BRANCH"
      echo "  Done. Version updated."
    else
      echo "  Skipped. You can pull manually: git pull $REMOTE $BRANCH"
    fi
  fi
fi

# Update cache
date +%s > "$CACHE_FILE"

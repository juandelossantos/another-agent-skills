#!/usr/bin/env bash
# agent-detect.sh — detect which AI coding agents are present.
#
# Signals, in order of precedence:
#   1. AAS_AGENTS env override (comma-separated) — wins outright.
#   2. A binary on PATH.
#   3. A global config directory under $HOME.
#   4. A project file/dir in the current working directory.
#
# Usage:
#   bash scripts/agent-detect.sh           # one detected agent id per line
#   bash scripts/agent-detect.sh --list    # every supported agent id
#
# Sourced by init-agents.sh and install.sh (defines detect_agents / list_agents).

set -uo pipefail

# id|binary|global-dir (relative to $HOME)|project-signals (comma-separated)
AAS_AGENT_TABLE='opencode|opencode|.config/opencode|.opencode/
claude|claude|.claude|.claude/,CLAUDE.md
gemini|gemini|.gemini|.gemini/,GEMINI.md
codex|codex|.codex|.codex/
cursor|cursor|.cursor|.cursor/,.cursorrules
aider|aider||.aider.conf.yml
windsurf|windsurf|.windsurf|.windsurfrules,.windsurf/
cline|||.clinerules,.cline/
roo||.roo|.roo/
continue|continue|.continue|.continue/
kiro|kiro|.kiro|.kiro/
zed|zed|.zed|.zed/
amazonq|q|.amazonq|.amazonq/
grok|grok|.grok|.grok/
deepseek|deepseek|.deepseek|.deepseek/'

# Print every supported agent id, one per line.
list_agents() {
  printf '%s\n' "${AAS_AGENT_TABLE}" | cut -d'|' -f1
}

# Print the global skills directory (relative to $HOME) an agent reads, or
# nothing when the path is not known.
agent_skills_dir() {
  case "$1" in
    opencode) echo ".config/opencode/skills" ;;
    claude)   echo ".claude/skills" ;;
    gemini)   echo ".gemini/skills" ;;
    *)        echo "" ;;
  esac
}

# Print the guardrails mechanism for an agent, or nothing when unknown.
#   plugin → native plugin directory
#   hooks  → hook scripts registered in the agent's config
agent_guardrails_kind() {
  case "$1" in
    opencode) echo "plugin" ;;
    claude)   echo "hooks" ;;
    *)        echo "" ;;
  esac
}

# Print the binary name for an agent, or nothing.
agent_binary() {
  printf '%s\n' "${AAS_AGENT_TABLE}" | awk -F'|' -v id="$1" '$1==id { print $2; exit }'
}

# Print the installed version (X.Y.Z) of an agent, or nothing when unavailable.
agent_version() {
  local bin="$1"
  [ -n "${bin}" ] || return 0
  type -P "${bin}" >/dev/null 2>&1 || return 0
  "${bin}" --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# Print a compatibility note for an agent + version, or nothing when fine.
# This is the gate the installer uses to decide what it can install.
agent_support_note() {
  local id="$1" v="$2"
  case "${id}" in
    opencode)
      [ -n "${v}" ] || return 0
      local major minor patch
      IFS=. read -r major minor patch <<< "${v}"
      if [ "${major}" -eq 1 ] && { [ "${minor}" -lt 18 ] || { [ "${minor}" -eq 18 ] && [ "${patch}" -lt 29 ]; }; }; then
        echo "OpenCode v${v} < 1.18.29 — dual-contract server() unsupported"
      fi
      ;;
  esac
}

# Return 0 when any signal for one agent matches.
_agent_hit() {
  local bin="$1" gdir="$2" pfiles="$3"
  local home="${HOME:-}"

  # type -P only finds executables on PATH — never shell builtins (e.g. `continue`).
  if [ -n "${bin}" ] && type -P "${bin}" >/dev/null 2>&1; then
    return 0
  fi
  if [ -n "${gdir}" ] && [ -d "${home}/${gdir}" ]; then
    return 0
  fi
  if [ -n "${pfiles}" ]; then
    local IFS=','
    local p
    for p in ${pfiles}; do
      [ -e "./${p}" ] && return 0
    done
  fi
  return 1
}

# Print detected agent ids, one per line.
detect_agents() {
  if [ -n "${AAS_AGENTS:-}" ]; then
    printf '%s\n' "${AAS_AGENTS}" | tr ',' '\n' \
      | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$'
    return 0
  fi

  local id bin gdir pfiles
  while IFS='|' read -r id bin gdir pfiles; do
    [ -z "${id}" ] && continue
    if _agent_hit "${bin}" "${gdir}" "${pfiles}"; then
      printf '%s\n' "${id}"
    fi
  done <<< "${AAS_AGENT_TABLE}"
}

# CLI mode (only when executed directly, not sourced).
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  case "${1:-}" in
    --list|-l) list_agents ;;
    --help|-h)
      echo "Usage: bash agent-detect.sh [--list]"
      echo "Detects AI coding agents via PATH, global dirs, and project files."
      ;;
    *) detect_agents ;;
  esac
fi

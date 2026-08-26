#!/usr/bin/env bash
# _risky-commands.sh — Shared risky-command classification for the Claude
# Code hooks in this directory. Single source of truth so commit-approval.sh
# and pre-flight.sh can't silently drift out of sync (mirrors OpenCode's
# BLOCKED_COMMANDS/isRiskyCommand in .opencode/plugins/agent-discipline/src/lib.ts).
#
# Not a standalone hook — sourced by the other scripts in this directory.

# Commands that mutate git history/remote state and require an approval token.
# Deliberately excludes "git commit" — committing requires staged (dirty)
# changes, so gating it on a clean tree would block every normal commit.
is_git_mutation_command() {
  case "$1" in
    git\ commit*|git\ push*|git\ merge*|git\ rebase*|git\ reset*|git\ cherry-pick*|git\ revert*)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# Commands risky enough to check git/filesystem state before running.
# Includes "git commit" here too (state check, not the approval gate above),
# but the state check itself (in pre-flight.sh) only looks at *upstream*
# drift for commit, not working-tree cleanliness — see pre-flight.sh.
is_risky_command() {
  case "$1" in
    git\ commit*|git\ push*|git\ merge*|git\ rebase*|git\ reset*|git\ cherry-pick*|git\ revert*|rm\ -rf*|mv\ *)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# Commands where an unclean working tree is actually dangerous to run against
# (unlike "git commit", whose entire point is to commit staged/dirty changes).
is_dirty_tree_risky_command() {
  case "$1" in
    git\ push*|git\ merge*|git\ rebase*|git\ reset*|git\ cherry-pick*|git\ revert*|rm\ -rf*|mv\ *)
      return 0 ;;
    *)
      return 1 ;;
  esac
}

# Strip leading whitespace so an indented command (e.g. from a heredoc) still matches.
trim_leading_whitespace() {
  local s="$1"
  echo "${s#"${s%%[![:space:]]*}"}"
}

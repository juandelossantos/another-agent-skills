#!/usr/bin/env bash
# _risky-commands.sh — Shared risky-command classification for the Claude
# Code hooks in this directory. Single source of truth so commit-approval.sh
# and pre-flight.sh can't silently drift out of sync (mirrors OpenCode's
# BLOCKED_COMMANDS/isRiskyCommand in .opencode/plugins/agent-discipline/src/lib.ts).
#
# Not a standalone hook — sourced by the other scripts in this directory.
#
# Best-effort, not a hard security boundary: Claude Code's own hook docs say
# the same about the "if" matcher's command filter ("the filter is
# best-effort, use the permission system rather than a hook to enforce a hard
# allow or deny"). This matches every ";"/"&&"/"||"/"|"-separated segment of
# the command (so "cd x && git push" is still caught), strips a leading `env`
# invocation or bare NAME=value assignments, and requires a word boundary
# after the git subcommand name (so "git commit-tree" — real plumbing, not
# the gated porcelain command — isn't misclassified). It will not catch every
# possible obfuscation (aliases, `bash -c "..."`, etc.) — that's an
# unwinnable arms race for a shell-level filter, not the goal here.

_strip_env_prefix() {
  local seg="$1"
  if [[ "$seg" =~ ^env[[:space:]]+(.*)$ ]]; then
    seg="${BASH_REMATCH[1]}"
  fi
  while [[ "$seg" =~ ^[A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+(.*)$ ]]; do
    seg="${BASH_REMATCH[1]}"
  done
  echo "$seg"
}

# Strip leading whitespace so an indented command (e.g. from a heredoc) still matches.
trim_leading_whitespace() {
  local s="$1"
  echo "${s#"${s%%[![:space:]]*}"}"
}

_any_segment_matches() {
  local cmd="$1" pattern="$2" seg stripped
  while IFS= read -r seg; do
    stripped="$(_strip_env_prefix "$(trim_leading_whitespace "$seg")")"
    [[ "$stripped" =~ $pattern ]] && return 0
  done <<< "$(printf '%s\n' "$cmd" | sed -E 's/(&&|\|\||;|\|)/\n/g')"
  return 1
}

GIT_MUTATION_RE='^git[[:space:]]+(commit|push|merge|rebase|reset|cherry-pick|revert)([[:space:]]|$)'
RM_MV_RE='^rm[[:space:]]+-rf([[:space:]]|$)|^mv[[:space:]]+'
GIT_DIRTY_TREE_RE='^git[[:space:]]+(push|merge|rebase|reset|cherry-pick|revert)([[:space:]]|$)'

# Commands that mutate git history/remote state and require an approval token.
# Deliberately excludes "git commit" being gated on tree cleanliness (see
# is_dirty_tree_risky_command) — committing requires staged (dirty) changes.
is_git_mutation_command() {
  _any_segment_matches "$1" "$GIT_MUTATION_RE"
}

# Commands risky enough to check git/filesystem state before running.
is_risky_command() {
  _any_segment_matches "$1" "${GIT_MUTATION_RE}|${RM_MV_RE}"
}

# Commands where an unclean working tree is actually dangerous to run against
# (unlike "git commit", whose entire point is to commit staged/dirty changes).
is_dirty_tree_risky_command() {
  _any_segment_matches "$1" "${GIT_DIRTY_TREE_RE}|${RM_MV_RE}"
}

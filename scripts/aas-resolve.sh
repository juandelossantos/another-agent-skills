# aas-resolve.sh — resolve the Another Agent Skills framework root (Phase 9, P9.7).
#
# Sourced (POSIX sh; no bashisms beyond `[ ]`). Sets AAS_DIR to the framework
# root, or leaves it empty when no install is found. It never hardcodes a
# developer path. Resolution order:
#   1. $AAS_DIR, when it already points at a valid framework dir
#   2. $ANOTHER_AGENT_SKILLS_DIR
#   3. `aas --dir` (the installed CLI)
#   4. the per-OS install dir for the version pinned in .aas/config
#   5. the legacy global dir (~/.config/opencode)
#   6. the framework tree itself, when the resolver runs inside it
#
# The caller may set AAS_PROJECT_DIR to resolve for a project other than $PWD.
# A valid framework dir holds VERSION + scripts/git-hooks/.

_aas_resolve_is_framework_dir() {
    [ -n "${1:-}" ] || return 1
    [ -d "$1" ] || return 1
    [ -f "$1/VERSION" ] || return 1
    [ -d "$1/scripts/git-hooks" ] || return 1
    return 0
}

_aas_resolve_install_root() {
    if [ -n "${AAS_HOME:-}" ]; then
        printf '%s\n' "${AAS_HOME%/}"
        return 0
    fi
    if [ -n "${LOCALAPPDATA:-}" ]; then
        printf '%s\n' "${LOCALAPPDATA%/}/another-agent-skills"
        return 0
    fi
    if [ -n "${XDG_DATA_HOME:-}" ]; then
        printf '%s\n' "${XDG_DATA_HOME%/}/another-agent-skills"
        return 0
    fi
    [ -n "${HOME:-}" ] || return 1
    printf '%s\n' "${HOME%/}/.local/share/another-agent-skills"
}

_aas_resolve_project_version() {
    _aas_cfg="${1:-.}/.aas/config"
    [ -f "$_aas_cfg" ] || return 1
    sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$_aas_cfg" | head -1
}

# Walk up from SCRIPT_DIR (the dir of the caller) looking for a framework tree.
_aas_resolve_walk_up() {
    _aas_d="${SCRIPT_DIR:-}"
    [ -n "$_aas_d" ] || return 1
    while [ -n "$_aas_d" ] && [ "$_aas_d" != "/" ] && [ "$_aas_d" != "." ]; do
        if _aas_resolve_is_framework_dir "$_aas_d"; then
            printf '%s\n' "$_aas_d"
            return 0
        fi
        _aas_parent="$(dirname "$_aas_d")"
        [ "$_aas_parent" = "$_aas_d" ] && break
        _aas_d="$_aas_parent"
    done
    return 1
}

_aas_resolve() {
    _aas_cur="${AAS_DIR:-}"
    AAS_DIR=""

    # 1. an explicit AAS_DIR that is already a valid framework dir
    if _aas_resolve_is_framework_dir "$_aas_cur"; then
        AAS_DIR="${_aas_cur%/}"
        return 0
    fi

    # 2. the environment variable install.sh writes to shell rc files
    if _aas_resolve_is_framework_dir "${ANOTHER_AGENT_SKILLS_DIR:-}"; then
        AAS_DIR="${ANOTHER_AGENT_SKILLS_DIR%/}"
        return 0
    fi

    # 3. the installed CLI, when present
    if command -v aas >/dev/null 2>&1; then
        _aas_out="$(aas --dir 2>/dev/null || true)"
        if _aas_resolve_is_framework_dir "$_aas_out"; then
            AAS_DIR="${_aas_out%/}"
            return 0
        fi
    fi

    # 4. the per-OS install dir for the version this project pins
    _aas_ver="$(_aas_resolve_project_version "${AAS_PROJECT_DIR:-.}" 2>/dev/null || true)"
    if [ -n "$_aas_ver" ]; then
        _aas_root="$(_aas_resolve_install_root 2>/dev/null || true)"
        if [ -n "$_aas_root" ] && _aas_resolve_is_framework_dir "$_aas_root/$_aas_ver"; then
            AAS_DIR="$_aas_root/$_aas_ver"
            return 0
        fi
    fi

    # 5. the legacy global dir
    if [ -n "${HOME:-}" ] && _aas_resolve_is_framework_dir "${HOME%/}/.config/opencode"; then
        AAS_DIR="${HOME%/}/.config/opencode"
        return 0
    fi

    # 6. the framework tree the resolver is running inside
    _aas_src="$(_aas_resolve_walk_up 2>/dev/null || true)"
    if [ -n "$_aas_src" ]; then
        AAS_DIR="$_aas_src"
        return 0
    fi

    return 0
}

# Print a one-line, never-blocking drift advisory when the project pins a
# different framework version than the one installed. Returns 0 always.
_aas_resolve_drift_notice() {
    [ -n "${AAS_DIR:-}" ] || return 0
    [ -f "${AAS_DIR}/VERSION" ] || return 0
    _aas_installed="$(tr -d '[:space:]' < "${AAS_DIR}/VERSION" 2>/dev/null || true)"
    [ -n "$_aas_installed" ] || return 0
    _aas_pinned="$(_aas_resolve_project_version "${AAS_PROJECT_DIR:-.}" 2>/dev/null || true)"
    [ -n "$_aas_pinned" ] || return 0
    [ "$_aas_pinned" = "$_aas_installed" ] && return 0
    printf '[aas] advisory: project pins v%s, framework v%s is installed — run "aas upgrade" then "init-agents --repair" (non-blocking)\n' \
        "$_aas_pinned" "$_aas_installed" >&2
    return 0
}

_aas_resolve

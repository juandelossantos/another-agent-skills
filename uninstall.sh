#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Another Agent Skills — Uninstaller
# =============================================================================
# Cleanly removes all traces of another-agent-skills:
#   - Shell config blocks (zshrc, bashrc, config.fish)
#   - Global skills directory
#   - Remote repo clone
#   - Global scripts (~/.local/bin)
#
# Usage:
#   bash uninstall.sh
#   bash uninstall.sh --force       # Skip confirmation
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GLOBAL_SKILLS_DIR="${HOME}/.config/opencode/skills"
REMOTE_DIR="${HOME}/.config/opencode/.agent-skills-remote"
ZSHRC="${HOME}/.zshrc"
BASHRC="${HOME}/.bashrc"
FISH_CONFIG="${HOME}/.config/fish/config.fish"
LOCAL_BIN="${HOME}/.local/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ---------------------------------------------------------------------------
_remove_shell_block() {
    local file="$1"
    local name="$2"

    if [[ ! -f "${file}" ]]; then
        return 0
    fi

    if ! grep -q "# >>> another-agent-skills-config" "${file}"; then
        return 0
    fi

    local backup="${file}.uninstall.$(date +%Y%m%d%H%M%S)"
    cp "${file}" "${backup}"

    local tmpfile
    tmpfile="$(mktemp)"
    awk '/# >>> another-agent-skills-config/{found=1; next} /# <<< another-agent-skills-config/{found=0; next} !found{print}' "${file}" > "${tmpfile}"
    mv "${tmpfile}" "${file}"
    ok "Removed config block from ${name} (backup: $(basename "${backup}"))"
}

# ---------------------------------------------------------------------------
remove_shell_configs() {
    info "Removing shell configuration blocks..."
    _remove_shell_block "${ZSHRC}" ".zshrc"
    _remove_shell_block "${BASHRC}" ".bashrc"
    _remove_shell_block "${FISH_CONFIG}" "config.fish"
}

# ---------------------------------------------------------------------------
remove_global_scripts() {
    info "Removing global scripts..."
    for script in init-agents update-global-skills; do
        if [[ -f "${LOCAL_BIN}/${script}" ]]; then
            rm -f "${LOCAL_BIN}/${script}"
            ok "Removed ${LOCAL_BIN}/${script}"
        fi
    done
}

# ---------------------------------------------------------------------------
remove_skills() {
    info "Removing global skills..."
    if [[ -d "${GLOBAL_SKILLS_DIR}" ]]; then
        rm -rf "${GLOBAL_SKILLS_DIR}"
        ok "Removed ${GLOBAL_SKILLS_DIR}"
    else
        info "Skills directory not found. Skipping."
    fi
}

# ---------------------------------------------------------------------------
remove_remote_repo() {
    info "Removing remote skill repository..."
    if [[ -d "${REMOTE_DIR}" ]]; then
        rm -rf "${REMOTE_DIR}"
        ok "Removed ${REMOTE_DIR}"
    else
        info "Remote repository not found. Skipping."
    fi
}

# ---------------------------------------------------------------------------
summary() {
    echo ""
    echo "========================================"
    echo "  Uninstall Complete"
    echo "========================================"
    echo ""
    echo "Remaining files (manual cleanup if desired):"
    echo "  ${HOME}/.config/opencode/        (user profile, config)"
    echo "  ${SCRIPT_DIR}                    (repo clone)"
    echo ""
    echo "To also remove your user profile:"
    echo "  rm -f ~/.config/opencode/user-profile.json"
    echo ""
    echo "To reinstall:"
    echo "  cd ${SCRIPT_DIR} && bash install.sh"
}

# ---------------------------------------------------------------------------
main() {
    echo ""
    echo "Another Agent Skills — Uninstaller"
    echo "=================================="
    echo ""

    if [[ "${1:-}" != "--force" ]]; then
        echo "This will remove:"
        echo "  - Shell config blocks (.zshrc, .bashrc, config.fish)"
        echo "  - Global scripts (init-agents, update-global-skills)"
        echo "  - Global skills directory (~/.config/opencode/skills/)"
        echo "  - Remote repo clone (~/.config/opencode/.agent-skills-remote/)"
        echo ""
        echo "It will NOT remove:"
        echo "  - Your user profile (~/.config/opencode/user-profile.json)"
        echo "  - This repository (delete manually if desired)"
        echo ""
        read -r -p "Uninstall? [y/N] " reply
        if [[ "${reply}" != "y" && "${reply}" != "Y" && "${reply}" != "yes" && "${reply}" != "sí" ]]; then
            echo "Aborted."
            exit 0
        fi
        echo ""
    fi

    remove_shell_configs
    remove_global_scripts
    remove_skills
    remove_remote_repo
    summary
    ok "All done!"
}

main "$@"

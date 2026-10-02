#!/usr/bin/env bash
# bootstrap.sh — one-line, pinned, checksum-verified installer for
# Another Agent Skills (Phase 9, P9.2).
#
#   curl -fsSL <release>/bootstrap.sh | bash
#   bash bootstrap.sh --version v6.3.0
#   bash bootstrap.sh --dry-run
#   bash bootstrap.sh --uninstall
#
# Downloads a *pinned* release tarball (never a mutable branch), verifies its
# sha256 against the release's checksums.txt, extracts it to
# $AAS_HOME/<version>, and links $AAS_BIN_DIR/aas at it.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/aas.sh
source "${SCRIPT_DIR}/scripts/lib/aas.sh"

DRY_RUN=false
UNINSTALL=false
REQ_VERSION=""

usage() {
  cat <<'EOF'
Usage: bash bootstrap.sh [OPTIONS]

Options:
  --version vX.Y.Z   Install a specific pinned release (default: latest release)
  --dry-run          Print every action without writing anything
  --uninstall        Remove the install root and the aas symlink
  --help, -h         Show this help

Environment:
  AAS_HOME              install root (default: ~/.local/share/another-agent-skills)
  AAS_BIN_DIR           symlink dir (default: ~/.local/bin)
  AAS_RELEASE_BASE_URL  release base URL (default: GitHub Releases download URL)
  AAS_LATEST_VERSION    pin "latest" resolution (offline/tests)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --version)   REQ_VERSION="${2:-}"; shift 2 ;;
    --version=*) REQ_VERSION="${1#*=}"; shift ;;
    --dry-run)   DRY_RUN=true; shift ;;
    --uninstall) UNINSTALL=true; shift ;;
    --help|-h)   usage; exit 0 ;;
    *)           aas_error "unknown option: $1"; usage >&2; exit 2 ;;
  esac
done

# ── Uninstall (no version resolution / no network needed) ────────────────────
if [ "$UNINSTALL" = true ]; then
  if [ "$DRY_RUN" = true ]; then
    aas_info "[dry-run] would remove install root: ${AAS_HOME}"
    aas_info "[dry-run] would remove symlink: ${AAS_BIN_DIR}/aas"
    exit 0
  fi
  aas_info "Removing install root: ${AAS_HOME}"
  aas_uninstall
  aas_info "Removed symlink: ${AAS_BIN_DIR}/aas"
  exit 0
fi

# ── Resolve + validate the version (pinned) ──────────────────────────────────
if [ -n "$REQ_VERSION" ]; then
  VERSION="$(aas_normalize_version "$REQ_VERSION")"
  if ! aas_valid_version "$VERSION"; then
    aas_error "invalid --version '${REQ_VERSION}' (expected vX.Y.Z or X.Y.Z)"
    exit 2
  fi
else
  if ! VERSION="$(aas_resolve_latest_version)"; then
    exit 1
  fi
fi

ASSET="$(aas_asset_name "$VERSION")"
TARBALL_URL="$(aas_release_url "$VERSION" "$ASSET")"
CHECKSUMS_URL="$(aas_checksums_url "$VERSION")"
INSTALL_DIR="$(aas_install_dir "$VERSION")"

# ── Dry-run: print every action, mutate nothing ──────────────────────────────
if [ "$DRY_RUN" = true ]; then
  aas_info "bootstrap.sh — Another Agent Skills (dry-run)"
  aas_info "version:       ${VERSION}"
  aas_info "release base:  $(aas_release_base)"
  aas_info "tarball url:   ${TARBALL_URL}"
  aas_info "checksums url: ${CHECKSUMS_URL}"
  aas_info "install dir:   ${INSTALL_DIR}"
  aas_info "symlink:       ${AAS_BIN_DIR}/aas -> ${INSTALL_DIR}/bin/aas"
  aas_info "PATH:          ensure ${AAS_BIN_DIR} is on PATH"
  aas_info "[dry-run] no changes made"
  exit 0
fi

# ── Install ──────────────────────────────────────────────────────────────────
aas_info "Installing Another Agent Skills v${VERSION}..."
aas_install_release "$VERSION"
aas_info "Installed v${VERSION} -> ${INSTALL_DIR}"
aas_info "Linked ${AAS_BIN_DIR}/aas"

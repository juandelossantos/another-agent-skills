#!/usr/bin/env bash
# scripts/lib/aas.sh — shared distribution logic for Another Agent Skills.
#
# Sourced by bootstrap.sh (P9.2) and bin/aas (P9.3). Defines helpers only; it
# has no side effects on source. Both entrypoints set `set -euo pipefail`.
#
# Release layout (P9.1):
#   tag:      vX.Y.Z
#   assets:   another-agent-skills-vX.Y.Z.tar.gz + checksums.txt
#   base url: $AAS_RELEASE_BASE_URL/vX.Y.Z/<asset>
#   the tarball holds the repo source at its root (bin/aas, install.sh, ...).
#
# Overridable for tests / advanced use:
#   AAS_RELEASE_BASE_URL  release base (default: GitHub Releases download URL)
#   AAS_HOME              install root (default: ~/.local/share/another-agent-skills)
#   AAS_BIN_DIR           symlink dir (default: ~/.local/bin)
#   AAS_LATEST_VERSION    pin the "latest" resolution (tests / offline)
#   AAS_REPO_SLUG         owner/repo (default: juandelossantos/another-agent-skills)

: "${AAS_REPO_SLUG:=juandelossantos/another-agent-skills}"
: "${AAS_RELEASE_BASE_URL:=https://github.com/${AAS_REPO_SLUG}/releases/download}"
: "${AAS_HOME:=${XDG_DATA_HOME:-$HOME/.local/share}/another-agent-skills}"
: "${AAS_BIN_DIR:=$HOME/.local/bin}"
: "${AAS_LATEST_VERSION:=}"

aas_info()  { printf '[aas] %s\n' "$*"; }
aas_warn()  { printf '[aas][WARN] %s\n' "$*" >&2; }
aas_error() { printf '[aas][ERROR] %s\n' "$*" >&2; }

# ── Version helpers ──────────────────────────────────────────────────────────
aas_normalize_version() { printf '%s\n' "${1#v}"; }

aas_valid_version() {
  [[ "${1:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# ── Release URL helpers ──────────────────────────────────────────────────────
aas_asset_name() { printf 'another-agent-skills-v%s.tar.gz\n' "$1"; }

aas_release_base() { printf '%s\n' "${AAS_RELEASE_BASE_URL%/}"; }

aas_release_url() { # <version> <asset>
  printf '%s/v%s/%s\n' "$(aas_release_base)" "$1" "$2"
}

aas_checksums_url() { # <version>
  printf '%s/v%s/checksums.txt\n' "$(aas_release_base)" "$1"
}

aas_install_dir() { printf '%s/%s\n' "${AAS_HOME%/}" "$1"; }

# Refuse mutable refs outright: distribution is pinned to an immutable release.
aas_guard_url() {
  local url="${1:-}"
  case "$url" in
    */main/*|*/master/*|*refs/heads/*)
      aas_error "refusing to fetch from a mutable branch: ${url}"
      return 1
      ;;
  esac
  return 0
}

# ── Download / integrity ─────────────────────────────────────────────────────
# Supports http(s) via curl, and local paths / file:// URLs (used by tests, so
# the suite never touches the network).
aas_download() { # <url> <dest>
  local url="$1" dest="$2"
  aas_guard_url "$url" || return 1
  case "$url" in
    file://*) cp "${url#file://}" "$dest" ;;
    /*)       cp "$url" "$dest" ;;
    *)
      if ! command -v curl >/dev/null 2>&1; then
        aas_error "curl is required to download ${url}"
        return 1
      fi
      curl -fsSL "$url" -o "$dest"
      ;;
  esac
}

aas_sha256() { # <file>
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    aas_error "no sha256 tool available (need sha256sum or shasum)"
    return 1
  fi
}

# Fail closed: a missing entry or a mismatch aborts the install.
aas_verify_checksum() { # <tarball> <checksums-file> <asset-name>
  local tarball="$1" checksums="$2" asset="$3"
  local expected actual
  expected="$(awk -v a="$asset" '$2==a || $2=="./"a {print $1; exit}' "$checksums")"
  if [ -z "$expected" ]; then
    aas_error "checksums.txt has no entry for ${asset} — refusing to install"
    return 1
  fi
  actual="$(aas_sha256 "$tarball")" || return 1
  if [ "$expected" != "$actual" ]; then
    aas_error "checksum mismatch for ${asset}: expected ${expected}, got ${actual}"
    return 1
  fi
  return 0
}

# ── Latest-release resolution (pinned) ───────────────────────────────────────
aas_resolve_latest_version() {
  local tag="" v=""
  if [ -n "${AAS_LATEST_VERSION:-}" ]; then
    v="$(aas_normalize_version "$AAS_LATEST_VERSION")"
    if aas_valid_version "$v"; then printf '%s\n' "$v"; return 0; fi
    aas_error "AAS_LATEST_VERSION is not a valid version: ${AAS_LATEST_VERSION}"
    return 1
  fi

  # Prefer the GitHub CLI when present.
  if command -v gh >/dev/null 2>&1; then
    tag="$(gh api "repos/${AAS_REPO_SLUG}/releases/latest" --jq .tag_name 2>/dev/null || true)"
  fi
  # Fallback: follow the /releases/latest redirect to its tag URL.
  if [ -z "$tag" ] && command -v curl >/dev/null 2>&1; then
    local effective
    effective="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
      "https://github.com/${AAS_REPO_SLUG}/releases/latest" 2>/dev/null || true)"
    tag="${effective##*/}"
  fi

  v="$(aas_normalize_version "$tag")"
  if [ -z "$v" ] || ! aas_valid_version "$v"; then
    aas_error "could not resolve the latest release version — pass --version vX.Y.Z (or set AAS_LATEST_VERSION)"
    return 1
  fi
  printf '%s\n' "$v"
}

# ── Install / link / uninstall ───────────────────────────────────────────────
# Atomically replace the $AAS_BIN_DIR/aas symlink (rename, not unlink+symlink).
aas_link_bin() { # <version>
  local version="$1"
  local target="$AAS_HOME/$version/bin/aas"
  local link="$AAS_BIN_DIR/aas"
  local tmp="$AAS_BIN_DIR/.aas.tmp.$$"
  mkdir -p "$AAS_BIN_DIR"
  rm -f "$tmp"
  ln -s "$target" "$tmp"
  if mv -T "$tmp" "$link" 2>/dev/null; then
    :
  else
    rm -f "$link"
    mv "$tmp" "$link"
  fi
}

# Add $AAS_BIN_DIR to PATH in existing shell rc files (or ~/.profile).
aas_ensure_path() {
  local marker="# >>> another-agent-skills-path"
  local line="export PATH=\"${AAS_BIN_DIR}:\$PATH\""
  local files=() rc
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [ -e "$rc" ] && files+=("$rc")
  done
  if [ "${#files[@]}" -eq 0 ]; then
    files=("$HOME/.profile")
  fi
  local f
  for f in "${files[@]}"; do
    [ -e "$f" ] || : > "$f"
    if ! grep -qF "$marker" "$f" 2>/dev/null; then
      printf '\n%s\n%s\n# <<< another-agent-skills-path\n' "$marker" "$line" >> "$f"
    fi
  done
}

# Download + verify + extract a pinned release, then point the symlink at it.
# The version directory is materialized via a staging dir + rename so a partial
# download can never leave a broken install behind.
aas_install_release() { # <version>
  local version="$1"
  local asset tarball_url checksums_url install_dir
  asset="$(aas_asset_name "$version")"
  tarball_url="$(aas_release_url "$version" "$asset")"
  checksums_url="$(aas_checksums_url "$version")"
  install_dir="$(aas_install_dir "$version")"

  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/aas.XXXXXX")"

  if ! aas_download "$tarball_url" "$tmp/$asset"; then
    rm -rf "$tmp"; return 1
  fi
  if ! aas_download "$checksums_url" "$tmp/checksums.txt"; then
    rm -rf "$tmp"; return 1
  fi
  if ! aas_verify_checksum "$tmp/$asset" "$tmp/checksums.txt" "$asset"; then
    rm -rf "$tmp"; return 1
  fi

  local staging="$AAS_HOME/.staging.$version.$$"
  rm -rf "$staging"
  mkdir -p "$staging"
  if ! tar -xzf "$tmp/$asset" -C "$staging"; then
    aas_error "failed to extract ${asset}"
    rm -rf "$tmp" "$staging"; return 1
  fi
  if [ ! -f "$staging/bin/aas" ]; then
    aas_error "release tarball is missing bin/aas at its root"
    rm -rf "$tmp" "$staging"; return 1
  fi
  chmod +x "$staging/bin/aas"

  mkdir -p "$AAS_HOME"
  rm -rf "$install_dir"
  mv "$staging" "$install_dir"
  rm -rf "$tmp"

  aas_link_bin "$version"
  aas_ensure_path
  return 0
}

# Remove the symlink and the whole install root.
aas_uninstall() {
  local link="$AAS_BIN_DIR/aas"
  if [ -L "$link" ] || [ -e "$link" ]; then
    rm -f "$link"
  fi
  if [ -d "$AAS_HOME" ]; then
    rm -rf "$AAS_HOME"
  fi
}

# ── Agent selection (P9.4) ───────────────────────────────────────────────────
# Requires detect_agents / list_agents from scripts/agent-detect.sh.
aas_parse_agent_list() { # <comma-list> → normalized comma-list
  local list="$1" id normalized=""
  while IFS= read -r id; do
    id="$(printf '%s' "$id" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [ -z "$id" ] && continue
    if ! list_agents | grep -qx "$id"; then
      aas_error "unknown agent: ${id} (supported: $(list_agents | paste -sd, -))"
      return 1
    fi
    normalized="${normalized:+$normalized,}$id"
  done < <(printf '%s\n' "$list" | tr ',' '\n')
  printf '%s\n' "$normalized"
}

# Interactive multi-select. Only ever called when stdin is a TTY.
aas_prompt_agents() {
  local detected all choice
  detected="$(detect_agents | paste -sd, -)"
  all="$(list_agents | paste -sd, -)"
  printf '[aas] Detected agents: %s\n' "${detected:-none}" >&2
  printf '[aas] Select agents (comma list, "all", or Enter for detected) [%s]: ' "${detected:-none}" >&2
  read -r choice || choice=""
  case "$choice" in
    ""|auto) printf '%s\n' "$detected" ;;
    all)     printf '%s\n' "$all" ;;
    *)       aas_parse_agent_list "$choice" ;;
  esac
}

# Resolve a --agents mode to a comma-separated list.
#   auto (default) → TTY: prompt; non-TTY: detected agents (never blocks in CI)
#   all            → every supported agent
#   <comma-list>   → validated explicit list
aas_choose_agents() { # [mode]
  local mode="${1:-auto}"
  case "$mode" in
    ""|auto)
      if [ -t 0 ] && [ "${AAS_NO_PROMPT:-0}" != "1" ]; then
        aas_prompt_agents
      else
        detect_agents | paste -sd, -
      fi
      ;;
    all) list_agents | paste -sd, - ;;
    *)   aas_parse_agent_list "$mode" ;;
  esac
}

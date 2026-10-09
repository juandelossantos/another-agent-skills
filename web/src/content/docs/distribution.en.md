---
title: "Distribution and upgrades"
description: "How Another Agent Skills reaches users: git clone, the pinned curl bootstrap, the aas CLI, and the npm wrapper, plus how upgrades work."
lang: "en"
order: 21
section: "reference"
tldr: "Distribution is pinned to an immutable release, never a mutable branch. Every channel downloads the same tagged tarball and verifies its sha256 before extracting anything."
---

## Principle

Distribution is pinned to an immutable release, never a mutable branch. Every channel ultimately downloads the same tagged GitHub Release tarball and verifies its `sha256` against the release's `checksums.txt` before extracting anything. The release is built and attested by CI; the installers are thin.

## Channels

| Channel | Who it is for | What it does | Never |
|---|---|---|---|
| `git clone` | Contributors | Clone the repo and run `bash install.sh` | - |
| Pinned `curl` bootstrap | One-line install (Linux, macOS, Git Bash) | Downloads the pinned tarball, verifies the checksum, links the `aas` CLI | Fetches `main` |
| `aas` CLI | Day-to-day use after bootstrap | `install`, `upgrade`, `doctor`, `uninstall` | Fetches `main` |
| npm wrapper | Node-adjacent users | `npx @juandelossantos/another-agent-skills install` | Ships no payload |

## Install with the bootstrap

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

`bootstrap.sh --version vX.Y.Z` pins an exact release, `--dry-run` prints every action without writing anything, and `--uninstall` removes the install root and the `aas` symlink. The install root is `${XDG_DATA_HOME:-$HOME/.local/share}/another-agent-skills`, overridable with `AAS_HOME`.

## The aas CLI

```bash
aas install --agents auto     # activate in the current project
aas doctor                    # environment report (agents, plugin state)
aas upgrade                   # self-update from the latest pinned release
aas uninstall                 # remove the CLI, install root, and PATH entry
```

`--agents auto|all|<list>` selects which detected agents to install into. `auto` prompts only when stdin is a TTY, so CI never blocks.

## npm

```bash
npx @juandelossantos/another-agent-skills install
npx @juandelossantos/another-agent-skills install --version v6.3.2
```

The npm package contains only `cli.js` and a README. It downloads the release tarball and `checksums.txt`, verifies the sha256 with `node:crypto`, and delegates to the release's own `bootstrap.sh`, so install logic lives in exactly one place. It is published via OIDC trusted publishing (no stored token).

## Release automation

Pushing a `v*` tag triggers a workflow that builds the tarball plus `checksums.txt`, attests build provenance, and publishes the GitHub Release. A second workflow syncs the npm version from `VERSION`, skips if that version already exists, and publishes through OIDC Trusted Publishing with no stored token. Verify a release locally:

```bash
gh attestation verify dist/another-agent-skills-vX.Y.Z.tar.gz --repo juandelossantos/another-agent-skills
```

## Upgrades

```bash
aas upgrade    # self-update to the latest pinned release (atomic)
```

`aas upgrade` resolves the latest release and installs it atomically (staging directory plus rename), so a partial extraction can never leave a broken install. For a project that pins a framework version, a non-blocking drift advisory appears in `pre-commit` and `doctor` when the installed version differs from the project's `.aas/config`. Run `aas upgrade`, then `init-agents --repair` to migrate.

> The npm account must exist before a Trusted Publisher can be configured, so the first publish is a one-time manual step. After that, releases publish with a short-lived OIDC token.

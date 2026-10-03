# @juandelossantos/another-agent-skills

npm wrapper for [Another Agent Skills](https://github.com/juandelossantos/another-agent-skills).

This package is intentionally tiny and ships **no framework payload**. It only
contains `cli.js` (the wrapper) and this README. The framework itself arrives as
a pinned, checksum-verified GitHub Release tarball.

## Usage

```bash
# Install the pinned release into ~/.local/share/another-agent-skills
npx @juandelossantos/another-agent-skills install

# Pin a specific release
npx @juandelossantos/another-agent-skills install --version v6.3.0

# See what would happen without downloading or writing
npx @juandelossantos/another-agent-skills install --dry-run

# Print the wrapper/framework version
npx -p @juandelossantos/another-agent-skills aas-npm --version
```

The binary exposed by this package is `aas-npm` (to avoid colliding with the
`aas` CLI that the release installs into `~/.local/bin`).

## How it works

1. Resolves the pinned version (the version in this package's `package.json`,
   or `--version vX.Y.Z`). Never fetches from `main` or any mutable ref.
2. Downloads `another-agent-skills-vX.Y.Z.tar.gz` and `checksums.txt` from
   GitHub Releases.
3. Verifies the sha256 with `node:crypto`.
4. Extracts the tarball to a temp dir and delegates to the release's own
   `bootstrap.sh` (`--tarball … --checksums …`), so install logic lives in
   exactly one place.
5. Removes the temp dir.

Requirements: Node.js >= 18. `tar` and `bash` must be available on the system
(they are on Linux, macOS, and Git Bash on Windows).

## Publishing (maintainers)

Publishing uses npm **Trusted Publishing (OIDC)** from
`.github/workflows/npm-publish.yml`; no npm token is stored. The package must
exist on npm before a trusted publisher can be configured, so the first publish
is manual. See the workflow header for the one-time setup.

# Distribution & Upgrades

> How Another Agent Skills reaches users, how upgrades work, and the one-time
> manual steps a maintainer must complete for the npm channel.
>
> Phase 9 — Distribution & Upgrades. Spec: `PLAN.md`.

---

## Principle

**Distribution is pinned to an immutable release — never a mutable branch.**
Every channel ultimately downloads the same tagged GitHub Release tarball and
verifies its `sha256` against the release's `checksums.txt` before extracting
anything. The release is built and attested by CI; the installers are thin.

---

## Channels

| Channel | Who it's for | What it does | Never |
|---|---|---|---|
| **`git clone`** | Contributors, hacking on the framework | Clone the repo and run `bash install.sh` / `init-agents` | — |
| **Pinned `curl` bootstrap** | One-line install (Linux/macOS/Git Bash) | Downloads the pinned release tarball, verifies the checksum, extracts it, links the `aas` CLI | Fetches `main` |
| **`aas` CLI** | Day-to-day use after bootstrap | `install` / `upgrade` / `doctor` / `uninstall`; detects and installs per agent | Fetches `main` |
| **npm wrapper** | Node-adjacent users | `npx @juandelossantos/another-agent-skills install`; a tiny wrapper that downloads + verifies the same release | Ships no payload |

### 1. `git clone` (contributors)

```bash
git clone https://github.com/juandelossantos/another-agent-skills.git
cd another-agent-skills
bash install.sh
init-agents
```

### 2. Pinned `curl` bootstrap

```bash
curl -fsSL https://github.com/juandelossantos/another-agent-skills/releases/latest/download/bootstrap.sh | bash
```

The release publishes a stable-name, **self-contained** `bootstrap.sh` asset (the
`scripts/lib/aas.sh` distribution helper is inlined at build time), so the
one-liner works with no local checkout and no sibling files.

`bootstrap.sh --version vX.Y.Z` pins an exact release; `--dry-run` prints every
action without writing anything; `--uninstall` removes the install root and the
`aas` symlink. The install root is
`${XDG_DATA_HOME:-$HOME/.local/share}/another-agent-skills` (override with
`AAS_HOME`); the CLI symlink lives in `$HOME/.local/bin` (`AAS_BIN_DIR`).

### 3. `aas` CLI

```bash
aas install --agents auto     # activate in the current project
aas doctor                    # environment report (agents, plugin state)
aas upgrade                   # self-update from the latest pinned release
aas uninstall                 # remove the CLI, install root, and PATH entry
```

`--agents auto|all|<list>` selects which detected agents to install into
(`auto` prompts only when stdin is a TTY, so CI never blocks). `aas` resolves
its own real path, so it works through a symlink.

### 4. npm wrapper

```bash
npx @juandelossantos/another-agent-skills install
npx @juandelossantos/another-agent-skills install --version v6.3.0
npx @juandelossantos/another-agent-skills install --dry-run
```

The package is intentionally tiny: it contains only `cli.js` and a README. It
downloads `another-agent-skills-vX.Y.Z.tar.gz` + `checksums.txt`, verifies the
sha256 with `node:crypto`, extracts to a temp dir, and delegates to the
release's own `bootstrap.sh` — install logic lives in exactly one place.

> **Homebrew is not planned.** It was scoped in Phase 9 (P9.6) but dropped: it
> would add a separate `homebrew-tap` repo + a PAT secret, while `git clone`,
> the pinned `curl` bootstrap and npm already cover Linux/macOS/Windows.

---

## Release automation (what runs without a human)

```
push a v* tag
      │
      ▼
.github/workflows/release.yml
      ├─ scripts/build-release.sh        → another-agent-skills-vX.Y.Z.tar.gz
      │                                    + bootstrap.sh + checksums.txt
      ├─ actions/attest-build-provenance → build attestation (gh attestation verify)
      ├─ gh release create               → publishes the GitHub Release assets
      │
      ▼
GitHub Release published
      │
      ▼
.github/workflows/release.yml → publish-npm job (workflow_call)
      ├─ syncs npm/package.json version from VERSION
      ├─ skips if that version is already on npm (idempotent)
      └─ npm stage publish via OIDC Trusted Publishing (no stored token)
```

- **`release.yml`** — on every `v*` tag: build the tarball + `checksums.txt`,
  attest build provenance, publish the release. Asset naming is the single
  source of truth in `scripts/lib/aas.sh` (`aas_asset_name`).
- **npm publish is chained** from `release.yml` (a `publish-npm` job calling
  `npm-publish.yml` via `workflow_call`) — a release created by `GITHUB_TOKEN`
  does **not** trigger `release: published`, so the npm publish would otherwise
  never run. The npm trusted publisher is therefore configured for
  **`release.yml`** (npm validates the *calling* workflow under `workflow_call`).
- **`npm-publish.yml`** — syncs the npm package version from `VERSION`, **skips
  if the version already exists** (idempotent), and **stages** via OIDC
  (`npm stage publish`); a maintainer approves with 2FA before it is public.

Verify a release locally:

```bash
gh attestation verify dist/another-agent-skills-vX.Y.Z.tar.gz --repo juandelossantos/another-agent-skills
```

---

## Web (landing + docs) deployment

The public landing + docs live in `web/` (Astro) and ship through a **separate**
workflow — the core `gates` CI never builds them (the core stays build-free):

```
push to main (or manual dispatch)
      │
      ▼
.github/workflows/deploy-web.yml
      ├─ build   → npm ci + npm run build in web/ → upload web/dist
      ├─ deploy  → GitHub Pages (github-pages environment, actions/deploy-pages@v4)
      └─ verify  → curl the LIVE site (/ , /es/ , /docs/ , a tutorial,
                   sitemap-index.xml) and fail the run if any page is not HTTP 200
```

Pages must be set to **build from GitHub Actions**
(Settings → Pages → Build and deployment → Source: GitHub Actions). This repo
still uses `build_type: legacy` (source `main`, path `/`) — switching to the
Actions source **replaces the old root site** with `web/dist`.
`actions/configure-pages` runs with `enablement: true`, but that only creates a
Pages site when none exists; it does **not** migrate an already-enabled legacy
site, so the switch is a one-time maintainer step (see below).

> **Security-headers gap (F5):** GitHub Pages ignores `_headers`, so the deployed
> site has no CSP/HSTS. Decide a `<meta http-equiv="Content-Security-Policy">`
> or a CDN proxy (e.g. Cloudflare) before hardening headers.

See [`web/README.md`](../web/README.md) → "Deploy".

---

## One-time manual steps (maintainer)

These are **not code** and cannot be automated from the repo. They must be done
once by a human with the relevant account access.

### npm — first publish + Trusted Publisher

npm retired classic publish tokens; the recommended CI path is **Trusted
Publishing (OIDC)**. npm requires the package to **exist** before a trusted
publisher can be configured, so the **first publish is manual**.

> **Status (2026-10-07): the suspension lifted.** The npm account
> `juandelossantos` was temporarily **suspended (read-only)** after a recovery
> code was used (the CLI 2FA challenge failed — only a **passkey** was
> configured, and passkeys are browser-only). It is now unblocked: TOTP
> (`auth-and-writes`) is enabled and the first publish (**6.3.0**) is live.

1. Log in and enable **TOTP** (not a passkey — the passkey does not work for the
   npm CLI):

   ```bash
   npm login
   npm profile enable-2fa auth-and-writes
   ```

   Scan the QR code with an authenticator app and save the recovery codes.
2. **First publish** (creates the package on npm):

   ```bash
   cd npm
   npm publish --access public
   ```

3. Configure the **Trusted Publisher** on npmjs.com
   (package → Settings → Trusted Publisher → GitHub Actions):
   - Organization or user: `juandelossantos`
   - Repository: `another-agent-skills`
   - Workflow filename: `npm-publish.yml`
   - Environment: `npm-release`
   - Allowed actions: leave **"Allow npm publish" UNCHECKED**. Publishing is
     **staged** — the CI submits with `npm stage publish` and a maintainer
     approves with 2FA before the version goes live (npm's secure default).
4. Optionally create the GitHub **Environment** `npm-release` with required
   reviewers (see `docs/BRANCH-PROTECTION.md` for the solo-maintainer pattern).

After this, `npm-publish.yml` **stages** with a short-lived OIDC token — **no
stored npm token** — and provenance is generated automatically. The workflow
syncs the npm version from `VERSION` and skips if the version is already
published. A maintainer then approves the staged version with 2FA
(npmjs.com → **Staged Packages** → **Approve**); until then it is not public.
The first CI publish also **validates** the trusted-publisher configuration
(npm requires one publish to validate it).

> **Note:** the trusted publisher is configured with **Workflow filename
> `release.yml`** (not `npm-publish.yml`): the npm publish is chained via
> `workflow_call`, and npm validates the *calling* workflow's name.

### GitHub Pages — switch the source to GitHub Actions

The web deploy (`.github/workflows/deploy-web.yml`) requires Pages to build from
**GitHub Actions**:

1. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
2. That's it — the next push to `main` (or a manual `deploy-web` dispatch)
   builds `web/`, deploys it, and the `verify` job checks the live site.

This **replaces** the current legacy source (`main`, `/`). It cannot be done by
`actions/configure-pages` when a legacy site already exists, so it is a one-time
human step.

---

## Upgrades

```bash
aas upgrade    # self-update to the latest pinned release (atomic)
```

`aas upgrade` resolves the latest release, installs it atomically (staging dir +
rename — a partial extraction can never leave a broken install), and reports the
version before/after. For a project that pins a framework version, a
**non-blocking** drift advisory appears in `pre-commit`/`doctor` when the
installed version differs from the project's `.aas/config`; run `aas upgrade`
then `init-agents --repair` to migrate.

---

## See also

- `PLAN.md` — Phase 9 spec and task table.
- `README.md` — Quick Start and the pinned one-liner install.
- `.github/workflows/release.yml`, `.github/workflows/npm-publish.yml`.
- `.github/workflows/deploy-web.yml`, `web/README.md` — the Astro landing + docs deploy.
- `scripts/build-release.sh`, `scripts/lib/aas.sh`.
- `bootstrap.sh`, `bin/aas`, `npm/`.
- `docs/BRANCH-PROTECTION.md` — GitHub Environment / required-reviewer pattern.

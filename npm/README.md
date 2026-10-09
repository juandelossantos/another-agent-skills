# Another Agent Skills

> **Most skill libraries sell capability. We sell discipline you can verify.**

Turn AI coding agents into **disciplined senior engineers** — with mechanical
enforcement, not suggestions. 58 composable skills and 15 gates that make an
agent **Define → Plan → Build → Verify → Review → Ship**, every time.

This npm package is the **installer** for
[Another Agent Skills](https://github.com/juandelossantos/another-agent-skills).
It ships no framework payload: it downloads, verifies, and installs a **pinned
release**.

**Start with [`/gate`](https://github.com/juandelossantos/another-agent-skills/blob/main/skills/gate/SKILL.md)** — the entry-point skill wires the enforcement (local hooks, the TDD gate, the required CI check) into any repo and proves the first gate fires.

## Why

AI coding agents ship generic, sloppy, insecure output by default. They commit
without tests, push without review, and fail silently. The industry's answer has
been more prompts and bigger context windows. We took a different approach:
**mechanical enforcement** — rules that don't depend on memory, gates that don't
depend on attention, verification that doesn't depend on trust.

> *A rule that lives only in a file is a suggestion. A rule that lives in a checklist is a gate.*

We believe agents should be **accountable, not autonomous**: the agent suggests,
the human decides. Every mutation passes a DECISION POINT. A code change with no
matching test is blocked before it leaves your machine — and the same check runs
as a **required status on `main`**, so the committer cannot skip it.

## Install

```bash
npx @juandelossantos/another-agent-skills install
```

Then, in any project:

```bash
aas install --agents auto    # activate skill-driven mode in the current project
aas doctor                   # environment report
aas upgrade                  # self-update from the latest pinned release
```

## Usage

```bash
# Install the pinned release into ~/.local/share/another-agent-skills
npx @juandelossantos/another-agent-skills install

# Pin a specific release
npx @juandelossantos/another-agent-skills install --version v6.4.0

# See what would happen without downloading or writing anything
npx @juandelossantos/another-agent-skills install --dry-run

# Print the wrapper / framework version
npx -p @juandelossantos/another-agent-skills aas-npm --version
```

The binary exposed by this package is `aas-npm` (to avoid colliding with the
`aas` CLI that the release installs into `~/.local/bin`).

## How it works

The wrapper is intentionally tiny and ships **no framework payload** — only
`cli.js` and this README. The framework arrives as a pinned, checksum-verified
GitHub Release tarball:

1. Resolves the pinned version (this package's `package.json`, or
   `--version vX.Y.Z`). Never fetches from `main` or any mutable ref.
2. Downloads `another-agent-skills-vX.Y.Z.tar.gz` + `checksums.txt` from GitHub
   Releases.
3. Verifies the **sha256** with `node:crypto`.
4. Extracts to a temp dir and delegates to the release's own `bootstrap.sh`
   (`--tarball … --checksums …`), so install logic lives in exactly one place.
5. Removes the temp dir.

Requirements: Node.js >= 18, plus `tar` and `bash` on the system (present on
Linux, macOS, and Git Bash on Windows).

## What's inside the framework

- **58 skills + 153 guides**, lazy-loaded (~3,870 always-loaded tokens vs ~7,965
  eager). *We make the instruction manual thinner, not the agent dumber.*
- **Mechanical enforcement, three layers:** L1 local hooks (`.git/hooks/*`), L2 a
  **required remote `gates` status check** on `main`, L3 `CODEOWNERS` so a PR
  cannot edit its own rules. Pre-commit runs **15 gates**; commit-msg enforces
  the TDD gate with **no override**.
- **The Harness** (`Agent = Model + Harness`): instructions, tools, sandboxes,
  orchestration, guardrails, observability — each a first-class part of the
  system, not an afterthought.
- **Portable** across OpenCode, Claude Code, Cursor, Codex, Gemini CLI, GitHub
  Copilot, and any agent that reads `AGENTS.md`.

- **Website:** <https://juandelossantos.github.io/another-agent-skills/>
- **Source & docs:** <https://github.com/juandelossantos/another-agent-skills>
- **Architecture (the Harness):** <https://github.com/juandelossantos/another-agent-skills/blob/main/docs/HARNESS.md>

MIT licensed.

## Publishing (maintainers)

Publishing uses npm **Trusted Publishing (OIDC)** from
`.github/workflows/npm-publish.yml`; no npm token is stored. The package must
exist on npm before a trusted publisher can be configured, so the first publish
was manual. See the workflow header for the one-time setup.

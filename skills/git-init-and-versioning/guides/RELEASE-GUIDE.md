# Release Automation Guide

**Part of `git-init-and-versioning` skill. Run after Phase 8 (first commit).**

Use when the user says: "setup release process", "add versioning", "automate releases", "semver", "I want to tag versions", "create CHANGELOG", "release workflow".

## Why

A release system forces discipline: every change is tracked, every version is documented, and users know what they're getting. Without it, you have no history, no communication, and no safety net.

## Core Files

| File | Purpose |
|---|---|
| `VERSION` | Single line: the current semver (e.g., `1.0.0`). The source of truth. |
| `RELEASE-NOTES.md` | Chronological changelog. One `## X.Y.Z (YYYY-MM-DD)` section per release. |
| `scripts/release.sh` | CLI tool: bumps version, updates files, commits, tags. |

## Release Script Template

Copy the `release.sh` from **this skill's parent repo** as a starting template. It handles:

1. Reads `VERSION` → parses semver (MAJOR.MINOR.PATCH)
2. Bumps based on argument: `patch` (default), `minor`, `major`
3. Opens `$EDITOR` for release notes
4. Updates `VERSION`, `RELEASE-NOTES.md`, and version badge in `README.md`
5. Guards against dirty working tree (aborts if uncommitted changes)
6. Creates commit + annotated tag (`vX.Y.Z`)
7. Offers to push (separate decision)

Adapt as needed — the structure is universal. Language-agnostic.

## Workflow

```
bash scripts/release.sh          # patch bump (bug fixes)
bash scripts/release.sh minor    # minor bump (new features)
bash scripts/release.sh major    # major bump (breaking changes)
```

## Guardrails

- **Working tree must be clean** before release. Commit or stash first.
- **Release notes are mandatory** — even if brief.
- **Tag is annotated** (not lightweight): includes release notes.
- **Push is optional** — the script asks separately. You decide when to publish.
- **Rollback** if user aborts before commit: files are restored automatically.

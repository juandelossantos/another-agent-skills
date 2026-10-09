# Wire the Gates

How to install the three enforcement layers (L1 local, L2 remote, L3 config) in a
real project, regardless of stack.

## 1. Find where hooks actually run

Git reads hooks from `core.hooksPath` if set; otherwise `.git/hooks/`.

```bash
HPD=$(git config core.hooksPath)
echo "hooks dir: ${HPD:-.git/hooks}"
```

| Situation | Where to write hooks |
|---|---|
| Plain repo | `.git/hooks/pre-commit`, `.git/hooks/commit-msg` |
| husky | `.husky/pre-commit`, `.husky/commit-msg` (and `core.hooksPath=.husky`) |
| lefthook / other | the configured `core.hooksPath` |

**Failure mode:** writing to `.git/hooks/` while husky shadows it → **no gate runs**.
This is the most common "the gates don't work" bug. Always resolve `core.hooksPath` first.

## 2. Detect the stack (for the test command)

The gate needs to know how to run the project's tests:

| Marker file | Stack | Typical test command |
|---|---|---|
| `package.json` | Node | `npm test` |
| `pyproject.toml` / `setup.py` | Python | `pytest` |
| `Cargo.toml` | Rust | `cargo test` |
| `go.mod` | Go | `go test ./...` |
| `Gemfile` | Ruby | `bundle exec rspec` |
| `pubspec.yaml` | Dart/Flutter | `flutter test` |

`init-agents` writes this into `STACK_CONFIG.md` so the gates stay stack-agnostic.

## 3. L1 — local hooks

Install the framework hooks (via `init-agents`), then confirm they exist and are
executable. A code change with no name-paired test must be blocked **before it
leaves the machine**.

## 4. L2 — the remote authority

Local hooks are advisory: the agent can edit `.git/hooks/` or repoint
`core.hooksPath`. The **authority** is a required status check on `main`.

1. `init-agents` drops `.github/workflows/gates.yml`.
2. Open a PR so the `gates` check reports at least once.
3. `bash scripts/setup-branch-protection.sh --dry-run` → then apply.
4. Verify: `gh api repos/OWNER/REPO/branches/main/protection`.

L2 and L3 are **GitHub-only**. Without GitHub you still get skills, rules, and L1.

## 5. L3 — protect the config

`CODEOWNERS` marks `.github/workflows/`, `scripts/git-hooks/`, and `scripts/*gate*`
as human-owned, so a PR cannot edit the gate it is violating.

## Honest limits

These layers create friction, not guarantees. The hooks cannot force the agent to
present a decision, wait for approval, or interpret an ambiguous "yes" correctly.
The human stays in the loop. See the project's `docs/BRANCH-PROTECTION.md`.

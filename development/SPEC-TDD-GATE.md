# SPEC-TDD-GATE: Test Companion Pre-Commit Gate

> Version: 1.0.0
> Status: DRAFT
> Author: opencode
> Date: 2026-07-08
> Plan: PLAN-v5-TDD-FIRST Phase 0

## Summary

Enforce that every code change is accompanied by a test. Mechanical, language-agnostic, binary pass/fail.

## Decision Tree

```
Are there staged code files?
├── NO → SKIP (no gate)
└── YES → Are there staged test files?
    ├── YES → PASS
    └── NO → BLOCK + message
```

## File Patterns

### Code Files (trigger gate when staged)

| Language | Pattern |
|---|---|
| JavaScript/TypeScript | `*.js, *.ts, *.jsx, *.tsx, *.mjs, *.cjs` |
| Python | `*.py` |
| Rust | `*.rs` |
| Go | `*.go` |
| Ruby | `*.rb` |
| Dart/Flutter | `*.dart` |
| Swift | `*.swift` |
| Kotlin | `*.kt, *.kts` |
| Java | `*.java` |
| C/C++ | `*.c, *.cpp, *.h, *.hpp` |
| Shell | `*.sh, *.bash` |

### Test Files (satisfy gate)

| Pattern | Examples |
|---|---|
| `*.test.*` | `foo.test.js`, `bar.test.py` |
| `*.spec.*` | `foo.spec.ts`, `bar.spec.rb` |
| `test_*` | `test_foo.py`, `test_bar.go` |
| `*_test.*` | `foo_test.go`, `bar_test.rb` |
| `*_spec.*` | `foo_spec.rb` |
| Files in `tests/` or `test/` directory | `tests/foo.py`, `test/bar.go` |

## Behavior

### BLOCK (exit 1)

When code files are staged but NO test files are staged:

```
TDD GATE: Code files staged without test files.
Stage a test file or add OVERRIDE: <reason> to commit message body.
Code: foo.js | Tests needed: foo.test.js, test_foo.py, or tests/foo.py
```

### PASS (exit 0)

When NO code files are staged, or when test files ARE staged alongside code files.

### SKIP (exit 0)

Commit message body contains `OVERRIDE: <reason>`.
Override is logged but not blocked. Use sparingly.

## Edge Cases

| Scenario | Behavior |
|---|---|
| Merge commit | SKIP — merge commits are not code changes |
| Config-only (`*.json, *.yaml, *.yml, *.toml, *.lock`) | SKIP — not code files |
| Docs-only (`*.md, *.txt, *.adoc`) | SKIP — not code files |
| Hooks/scripts (`scripts/*`) | SKIP — not application code |
| CI config (`.github/workflows/*`) | SKIP — not application code |
| `.gitignore, .env.example` | SKIP — not code files |
| Staged + unstaged mix | Only STAGED files matter |
| Deleted files | SKIP — deletions are not new code |
| Binary files | SKIP — not code files |

## Block Message Format

```
╔══════════════════════════════════════════════════╗
║  TDD GATE: Test companion required              ║
╚══════════════════════════════════════════════════╝

Code files staged without test files:
  - src/foo.js → needs test_foo.js or tests/foo.js

Options:
  1. Stage a test file: git add tests/foo.js
  2. Override (explain why): add OVERRIDE: reason to commit body

Example: git commit -m "fix: hotfix" -m "OVERRIDE: typo-only change"
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | PASS or SKIP |
| 1 | BLOCK |

## Logging

Every gate run writes to `.git/TDD_GATE_LOG`:

```
timestamp=2026-07-08T02:49:00Z
decision=BLOCK|PASS|SKIP
code_files=foo.js,bar.ts
test_files=test_foo.js
override=none
```

## Verification

After implementation, verify:

1. `bash scripts/tdd-gate.sh` with code-only staged → exit 1
2. `bash scripts/tdd-gate.sh` with code+test staged → exit 0
3. `bash scripts/tdd-gate.sh` with no code staged → exit 0
4. `bash scripts/tdd-gate.sh` with OVERRIDE in message → exit 0
5. `bash tests/test-tdd-gate.sh` → all tests pass

---
name: test-driven-development
description: Write tests first with RED-GREEN-REFACTOR cycle. Use when implementing logic, fixing bugs, or proving code works. Do NOT use for exploratory prototyping.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: engineers
  workflow: test-first
---

# Test-Driven Development

Write a failing test before writing the code that makes it pass. For bug fixes, reproduce the bug with a test before attempting a fix. Tests are proof — "seems right" is not done.

## When to Activate

- Implementing any new logic or behavior
- Fixing any bug (the Prove-It Pattern)
- Modifying existing functionality
- Adding edge case handling
- User says "add tests" or "make sure it works"

## When NOT to Use

- Pure configuration changes, documentation updates, or static content changes

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Test files + tested source code | Test files (framework-agnostic) + modified source code | `tests/` or alongside source (any project structure) | Test-first (RED→GREEN→REFACTOR) for every behavior change, bug fixes include reproduction test before fix, all tests passing, test names describe behavior (not implementation), no skipped/disabled tests, no empty tests (assert on behavior, not just "no error") |

## Decision Tree: What Kind of Test?

```
What are you testing?
├── Single function, pure logic → Unit test
│   ├── Input/output, no side effects
│   ├── Fast, isolated, many cases
│   └── ~80% of your test suite
│
├── Multiple units working together → Integration test
│   ├── API endpoint + database
│   ├── Component + service layer
│   ├── ~15% of your test suite
│   └── Test real interactions, not mocks
│
├── User flow through the app → E2E test
│   ├── Click through a complete workflow
│   ├── Login → create item → see it in list
│   ├── ~5% of your test suite
│   └── Use sparingly — slow, brittle
│
└── Bug fix → Prove-It Pattern
    ├── Write test that reproduces the bug
    ├── Test fails (proves the bug exists)
    ├── Fix the bug
    ├── Test passes (proves the fix works)
    └── Add to regression suite
```

## Core Workflows

### TDD Cycle
→ See `guides/TDD-CYCLE.md`

RED (write failing test) → GREEN (minimal code to pass) → REFACTOR (clean up)

### Prove-It Pattern
→ See `guides/PROVE-IT.md`

For bug fixes: write test that reproduces the bug, then fix.

### Test Pyramid
→ See `guides/TEST-PYRAMID.md`

Unit tests (~80%) → Integration (~15%) → E2E (~5%)

### Writing Good Tests
→ See `guides/WRITING-TESTS.md`

State vs interactions, DAMP, AAA pattern, test naming.

### Anti-Patterns
→ See `guides/ANTI-PATTERNS.md`

Empty tests, testing implementation, over-mocking, test interdependence.

### Browser Testing
→ See `guides/BROWSER-TESTING.md`

DevTools workflow, security boundaries, when to use E2E vs integration.

## Quick Reference

**TDD Cycle:**
```
RED: Write test that fails
GREEN: Minimal code to pass
REFACTOR: Clean up, tests still pass
```

**Prove-It Pattern:**
```
Bug → Write failing test → Fix → Test passes → Full suite
```

**Empty Test Detection (from METR study):**
```
Test passes but doesn't prove anything?
├── Does it assert on behavior (not implementation)? → Good
├── Does it test the actual output? → Good
├── Does it only call the function and check "no error"? → EMPTY TEST — rewrite
└── Does it use mocks for everything? → Likely testing mocks, not code
```

## Framework Quick Start

| Framework | Run tests | Watch mode | Coverage |
|---|---|---|---|
| Jest/Vitest | `npm test` | `npm test -- --watch` | `npm test -- --coverage` |
| pytest | `pytest` | `pytest --looponfail` | `pytest --cov` |
| cargo test | `cargo test` | `cargo watch -x test` | `cargo tarpaulin` |
| Go | `go test ./...` | `go test -count=1 ./...` | `go test -cover` |

## Integration

| Skill | When to use with TDD |
|---|---|
| `debugging-and-error-recovery` | Write failing test to reproduce bug, then debug |
| `code-review-and-quality` | Review test quality alongside code quality |
| `incremental-implementation` | Each increment = one RED→GREEN→REFACTOR cycle |
| `doubt-driven-development` | Challenge test assumptions before writing |

## Verification

After completing any implementation:
- [ ] Every new behavior has a corresponding test
- [ ] All tests pass
- [ ] Bug fixes include a reproduction test
- [ ] Test names describe the behavior being verified
- [ ] No tests were skipped or disabled
- [ ] No empty tests (tests that pass without asserting anything real)

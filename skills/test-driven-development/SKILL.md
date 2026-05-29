---
name: test-driven-development
description: >
  Drives development with tests. Use when implementing any logic, fixing any bug,
  or changing any behavior. Use when you need to prove that code works, when a
  bug report arrives, or when you're about to modify existing functionality.
---

# Test-Driven Development

Write a failing test before writing the code that makes it pass. For bug fixes, reproduce the bug with a test before attempting a fix. Tests are proof — "seems right" is not done.

## When to Use

- Implementing any new logic or behavior
- Fixing any bug (the Prove-It Pattern)
- Modifying existing functionality
- Adding edge case handling

**When NOT to use:** Pure configuration changes, documentation updates, or static content changes.

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

## Detailed Guides

| Guide | Content |
|-------|---------|
| `guides/TDD-CYCLE.md` | RED→GREEN→REFACTOR loop, step by step |
| `guides/PROVE-IT.md` | Bug fixing pattern with reproduction tests |
| `guides/TEST-PYRAMID.md` | Test types, sizes, and resource constraints |
| `guides/WRITING-TESTS.md` | State vs interactions, DAMP, AAA pattern |
| `guides/ANTI-PATTERNS.md` | What to avoid, rationalizations, red flags |
| `guides/BROWSER-TESTING.md` | DevTools workflow, security boundaries |

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

## Verification

After completing any implementation:

- [ ] Every new behavior has a corresponding test
- [ ] All tests pass: `npm test`
- [ ] Bug fixes include a reproduction test
- [ ] Test names describe the behavior being verified
- [ ] No tests were skipped or disabled

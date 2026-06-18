---
name: browser-testing-with-devtools
description: >
  Test in real browsers via Chrome DevTools MCP. Use when you need to inspect the DOM,
  capture console errors, analyze network requests, profile performance, or verify
  visual output in a real browser. Complements test-driven-development for browser work.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: frontend-developers
  workflow: test-verify
---

# Browser Testing with DevTools

**Runtime verification in real browsers.**

Complementary to `test-driven-development`. While TDD covers the RED/GREEN/REFACTOR cycle at the unit/integration level, browser-testing-with-devtools handles real browser verification: DOM inspection, console errors, network requests, performance profiling, and visual output validation.

## When to Use

- Debugging browser-specific behavior
- Verifying visual output with real runtime data
- Capturing console errors or network request issues
- Profiling frontend performance

## When NOT to Use

- Unit or integration testing (use test-driven-development)
- Backend testing
- Static analysis or linting

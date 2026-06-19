---
name: browser-testing-with-devtools
description: Test interfaces in real browsers: inspect DOM, capture console errors, analyze network requests, verify visual output. Available tools vary by platform. Do NOT use for server-side testing.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: frontend-developers
  workflow: test-verify
---

# Browser Testing with DevTools

**Runtime verification in real browsers.**

Complementary to `test-driven-development`. While TDD covers RED/GREEN/REFACTOR
at the unit/integration level, this skill handles real browser verification.

## Available Approaches

The agent may have one or more of these browser testing capabilities.
Check with the agent or run `dev-environment-audit` to see what's available.

### Built-in Browser Tools (No Setup)

Some agent platforms provide native browser testing tools:
- Navigate to URLs
- Inspect the DOM (snapshots, accessibility tree)
- Click, type, hover on elements
- Capture screenshots
- Read console logs
- Analyze network requests
- Fill forms, select options

**Advantage:** Works immediately — no MCP server, no configuration.

### MCP-Based Browser Tools (Setup Required)

For deeper browser access, some agents support browser testing via MCP servers:
- Detailed performance profiling and tracing
- Code coverage analysis
- Chrome-specific debugging features

**Requires:** MCP server configuration. See `dev-environment-audit` for setup guidance.

## When to Use

- Debugging browser-specific behavior
- Verifying visual output with real runtime data
- Capturing console errors or network request issues
- Profiling frontend performance

## When NOT to Use

- Unit or integration testing (use test-driven-development)
- Backend testing
- Static analysis or linting
- Non-browser environments

## Workflow

1. Navigate to the page
2. Inspect the DOM (snapshot for accessibility tree)
3. Capture evidence: screenshot or console logs
4. Analyze network requests
5. Verify behavior through interaction (click, type, form fill)
6. Report findings or fix issues found

## Setup

If browser testing tools are not available, run `dev-environment-audit`
to identify what's needed and get installation guidance.

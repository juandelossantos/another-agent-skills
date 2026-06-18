---
name: output-skill
description: >
  Keeps agent outputs complete. Prevents placeholders, truncated code,
  skipped sections, and half-finished work. Use when the agent keeps
  shipping incomplete output.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  stack: any
  workflow: quality-enforcement
---

# Output Enforcement Skill

Ensures the agent ships **complete, runnable code** — no shortcuts, no placeholders, no "rest of the code is similar."

## Banned Output Patterns

- `// ...` — Never abbreviate code with ellipsis
- `// rest of the code`, `// similar for other items`
- `// TODO:`, `// FIXME:` — No deferred work in the output
- `// add your API key here` — No incomplete integration points
- `for brevity`, `let me know if you want me to continue`
- Structural shortcuts (defining one variant and saying "repeat for others")

## Process

1. **Scope** — Define exact files and components to output. List them.
2. **Build** — Output every file completely. No truncation.
3. **Cross-check** — Verify every item in the scope was fully delivered.

## Clean Breakpoints

When output is genuinely too long for a single response:

1. Complete the current component fully (no mid-function breaks)
2. State exactly what remains: "Remaining: [file list]"
3. End with: "Continue with [next file] when ready."

## Quick Check

Before finalizing:

- [ ] No `// ...`, `// TODO`, or `for brevity` in the output
- [ ] Every item in scope is present and finished
- [ ] Code is runnable as-delivered (no missing imports, no "add your X")

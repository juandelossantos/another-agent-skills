# Development Guide

## Folder: `development/`

All internal refinement work goes here. This folder is git-ignored.

### What goes in `development/`

| Type | Examples |
|---|---|
| **Analysis & Audits** | `AUDIT_WEB_CENTRISM.md`, performance audits, architecture reviews |
| **Reviews** | `REVIEW_v2.md`, code quality reviews, self-review checklists |
| **Simulations** | `SIMULATION.md`, test scenarios, user flow simulations |
| **Roadmaps & Planning** | `ROADMAP_TO_10.md`, milestone plans, feature backlogs |
| **Session Context** | `SESSION_CONTEXT.md`, conversation continuity, decision logs |
| **Experiments** | `TOKEN_OPTIMIZATION.md`, compression tests, pattern drafts |
| **Refinement** | Iterative improvements, draft skills, WIP guides |

### What stays in root / `skills/` / `ADRs/`

| Type | Location |
|---|---|
| Product documentation | `README.md`, `AGENTS.md`, `STACK_CONFIG_TEMPLATE.md` |
| Skills | `skills/<name>/SKILL.md` + guides |
| Architectural decisions | `ADRs/*.md` |
| Installer | `install.sh` |
| License | `LICENSE` |

### Why this convention

End users clone this repo to install skills via `install.sh`. Internal refinement artifacts (audits, reviews, simulations) are valuable to maintainers but create noise for users. By keeping them in `development/`:

1. **Clean repo for users** — Only product files visible
2. **Single `.gitignore` rule** — `development/` covers everything
3. **Flexible for maintainers** — Create any file inside, no `.gitignore` edits needed
4. **Explicit intent** — When you see `development/`, you know it's internal work

### How to use

When creating a new analysis, review, or draft:

```bash
# Correct: file goes in development/
touch development/my-analysis.md

# Wrong: file in root will be committed and visible to users
touch my-analysis.md
```

When working with an agent in this repo, **the agent reads Rule 10 in AGENTS.md** and knows to place refinement artifacts in `development/`.

## Testing

### Running Tests

```bash
# Run all test suites
bash tests/run-all.sh

# Run individual suites
bash tests/test-tdd-gate.sh          # TDD enforcement (14 tests)
bash tests/test-pre-commit-gates.sh  # Gate numbering (7 tests)
bash tests/test-pre-commit-gate-14.sh # Gate 14 behavioral (7 tests)
bash tests/test-sync-hooks.sh        # Hook sync (7 tests)
bash tests/init/run.sh               # init-agents features (7 tests)
bash tests/audit/run.sh              # Audit wrapper (3 tests)
bash tests/audit/universal.sh        # Audit engine (17 tests)
bash scripts/skill-lint.sh skills/   # Skill structure (Rule 6)
```

### Pre-Commit Gate 14

The pre-commit hook runs `bash tests/run-all.sh` automatically as Gate 14.
To bypass for pre-existing failures: `SKIP_TEST_RUNNER=true git commit`.

### TDD Gate Behavior

The commit-msg hook enforces two rules via `scripts/tdd-gate.sh`:

1. **Name-pairing**: each staged code file must have a staged test file whose name contains the code file's name (e.g., `foo.js` → `foo.test.js` or `tests/test_foo.py`)
2. **New-test**: at least one staged test file must be new (not in `HEAD`)

Use `OVERRIDE: reason` in the commit body to bypass.

### Playwright Browser Tests

```bash
cd tests/playwright
npm install                    # Installs @playwright/test
npx playwright install chromium  # Downloads Chromium browser
npx playwright test            # Runs the test suite
```

**Chrome DevTools MCP setup** — Add to your `.mcp.json` or agent config:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "--autoConnect"]
    }
  }
}
```

This gives the agent eyes into the browser: DOM inspection, console logs, network requests, screenshots, and performance traces.

## Syncing Git Hooks

After modifying hooks in `scripts/git-hooks/`, sync them to `.git/hooks/`:

```bash
bash scripts/init-agents.sh sync-hooks
```

This copies `pre-commit` and `commit-msg` from `scripts/git-hooks/` to `.git/hooks/`, backs up existing hooks, and makes them executable. Run this every time you modify hook source files.

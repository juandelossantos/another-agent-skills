---
name: cli-tools
description: "Build production-grade CLI tools with argument parsing, exit codes, colored output, progress, and error handling. Triggers: CLI, terminal, shell script. Do NOT use for GUI applications."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: engineers
  workflow: design-implement-document
---

# CLI Tools

**A CLI without standards is a script no one wants to run.**

This skill covers the patterns that separate professional CLI tools from ad-hoc scripts: predictable argument parsing, meaningful exit codes, colored output, progress indication, and proper error handling.

## When to Use

**MANDATORY when:**
- Building a new CLI tool or command
- Adding a CLI interface to an existing project or service
- Refactoring ad-hoc scripts into a proper CLI (argument parsing, exit codes, composability)
- Creating developer tooling: scaffolds, code generators, linters, formatters, migration tools
- Building a multi-command tool (git-style subcommands: `tool <noun> <verb>`)
- Implementing automation that needs reliable exit codes and piped output (CI/CD, scripts)

**User says:** "build a CLI", "terminal app", "command line tool", "make a tool that...", "create a command"

**When NOT to use:**
- GUI applications (desktop, web, mobile)
- Simple one-off shell scripts (use a shell script directly)
- Full-screen TUI applications (emacs, vim-style interactive interfaces)

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| CLI tool source code | CLI executable (language-agnostic, framework-independent) | `src/cli/` or project root | Standard argument parser used, exit codes (0=success, non-zero=error), stdout for data + stderr for logs/errors, `--help` + `--version` flags, `--quiet` suppresses non-essential output, colors auto-suppressed when non-TTY (`isatty`), `NO_COLOR` env var respected, `--json` flag for machine-readable output, config file at `~/.config/<tool>/` with `--config` override, SIGINT handler for clean shutdown, `--` separates options from positional args |

## Core Principles

### 1. Argument Parsing

**Use a standard parser.** Never parse `argv` manually.

| Language | Library |
|---|---|
| Node.js | `commander`, `yargs`, `clack` |
| Python | `click`, `typer`, `argparse` |
| Rust | `clap`, `structopt` |
| Go | `cobra`, `urfave/cli` |
| Bash | `getopt` (long options), `argbash` |

**Convention:**
- Flags before arguments (`tool --verbose build`)
- `--` separates options from positional args
- `-h` / `--help` shows usage
- `-v` / `--version` (unless `-v` is verbose)

### 2. Exit Codes

```
0   — Success
1   — General error
2   — Misuse (invalid args, wrong usage)
127 — Command not found
130 — Interrupted (Ctrl+C)
```

**Never exit 0 on failure.** Every error path returns a non-zero code.

### 3. Output Channels

| Stream | When |
|---|---|
| `stdout` | Command output (data, results, lists) |
| `stderr` | Logs, warnings, errors, progress |
| `/dev/null` | Hide when `--quiet` is set |

**Piped output must be clean.** When stdout is piped, strip colors and progress indicators automatically. Detect with: `!isatty(sys.stdout)`.

### 4. Progress Indication

- Tasks > 2s: show a spinner or progress bar
- Use libraries: `cli-spinners` (Node), `rich.progress` (Python), `indicatif` (Rust)
- Suppress when non-TTY or `--quiet`

### 5. Error Messages

```
❌ Error: File not found: /path/to/missing
   Hint: Check the path and try again. Use --help for options.
```

**Format:** `[context] Error: [what happened]` then optional hint on next line.

### 6. Configuration

- `~/.config/<tool>/config.{json,yaml,toml}` for user config
- `--config <path>` to override
- `.env` in project root for env vars
- `CLI_TOOL_*` env vars with clear prefix

## Language-Specific Patterns

→ See `guides/LANGUAGE-GUIDE.md` for code examples in Node.js (commander/clack), Python (click), Rust (clap), and Go (cobra).

## Anti-Patterns

→ See `guides/ANTI-SLOP-GUIDE.md` for CLI-specific anti-patterns and best practices.

## Verification

- [ ] Uses standard argument parser
- [ ] `--help` and `--version` work
- [ ] Exit codes: 0 = success, non-zero = error
- [ ] Errors go to stderr, results to stdout
- [ ] Colors suppressed when non-TTY
- [ ] `--quiet` silences non-essential output
- [ ] Config file with `--config` override
- [ ] README with install + usage + examples

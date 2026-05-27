---
name: cli-tools
description: >
  Build production-grade CLI tools with standard argument parsing, exit
  codes, colored output, progress indication, and error handling.
  Use when building any terminal-based tool or script. Triggers on:
  "CLI", "terminal", "command line", "cli tool", "shell script",
  "build a CLI", "terminal app".
license: MIT
compatibility: opencode
metadata:
  audience: engineers
  workflow: design-implement-document
---

# CLI Tools

**A CLI without standards is a script no one wants to run.**

This skill covers the patterns that separate professional CLI tools from ad-hoc scripts: predictable argument parsing, meaningful exit codes, colored output, progress indication, and proper error handling.

## When to Use

- Building a new CLI tool or command
- Adding a CLI interface to an existing project
- Refactoring ad-hoc scripts into a proper CLI
- User says: "build a CLI", "terminal app", "command line tool"

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

### Node.js (commander + clack)
```typescript
import { Command } from 'commander';
import { intro, outro, spinner, cancel, isCancel } from '@clack/prompts';

const program = new Command();
program
  .name('mycli')
  .description('Does useful things')
  .option('-d, --debug', 'verbose output')
  .argument('<input>', 'input file')
  .action(async (input, options) => {
    intro('mycli');
    const s = spinner();
    s.start('Processing');
    await process(input);
    s.stop('Done');
    outro('Complete');
  });

program.parse();
```

### Python (click)
```python
import click

@click.command()
@click.argument('input')
@click.option('--output', '-o', help='Output file')
@click.option('--verbose', '-v', is_flag=True, help='Verbose output')
def cli(input, output, verbose):
    """Process INPUT file."""
    click.echo(f'Processing {input}')

if __name__ == '__main__':
    cli()
```

### Rust (clap)
```rust
use clap::Parser;

#[derive(Parser)]
#[command(name = "mycli")]
struct Cli {
    input: String,
    #[arg(short, long)]
    output: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    println!("Processing {}", cli.input);
}
```

### Go (cobra)
```go
var rootCmd = &cobra.Command{
    Use:   "mycli",
    Short: "Does useful things",
    Run: func(cmd *cobra.Command, args []string) {
        fmt.Println("Processing")
    },
}

func main() {
    rootCmd.Execute()
}
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|---|---|
| Manual `argv` parsing | Breaks on quoted args, flags, edge cases |
| Exit 0 on error | Breaks CI pipelines, scripts |
| All output to stdout | Can't separate data from logs |
| Hardcoded paths | No `--config`, no env vars |
| No `--help` | User has to read source to use it |
| Silent failure | User doesn't know if it worked |
| Colors in piped output | Garbage in logs, files |

## Verification

- [ ] Uses standard argument parser
- [ ] `--help` and `--version` work
- [ ] Exit codes: 0 = success, non-zero = error
- [ ] Errors go to stderr, results to stdout
- [ ] Colors suppressed when non-TTY
- [ ] `--quiet` silences non-essential output
- [ ] Config file with `--config` override
- [ ] README with install + usage + examples

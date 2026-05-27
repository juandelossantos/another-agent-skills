# CLI Anti-Slop Guide

## Don'ts

| Anti-Pattern | Why It's Wrong |
|---|---|
| Manual `argv` parsing | Breaks on quoted args, flags, edge cases |
| Exit 0 on error | Breaks CI pipelines, scripts that check exit codes |
| All output to stdout | Can't separate data from logs when piping |
| Hardcoded paths | No `--config`, no env var override |
| No `--help` or incomplete help | User must read source to use the tool |
| Silent failure | User doesn't know if it worked or failed |
| Colors in piped output | Garbage in log files, CI output |
| Spinner in CI | Non-TTY output should be plain text |
| Magic numbers in exit codes | Use named constants or enum |

## Do's

- Detect TTY: `!isatty(sys.stdout)` before colors/progress
- `--quiet` suppresses all non-essential output
- `--json` flag for machine-readable output
- `SIGINT` handler for clean shutdown
- Progress bar only if task > 2 seconds

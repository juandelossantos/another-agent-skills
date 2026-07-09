# Output Checklist

> **Source:** Patterns compiled from common AI output failures: placeholder code, truncated responses, and scope gaps observed across code generation tools.

## Scope Accounting Template

Use before and after each output:

```
SCOPE (before writing):
  [ ] src/api/handler.ts — full REST handler
  [ ] src/types.ts — type updates only
  [ ] tests/handler.test.ts — unit tests

DELIVERED (after writing):
  [x] src/api/handler.ts — full, runnable
  [x] src/types.ts — complete
  [ ] tests/handler.test.ts — MISSING (not yet delivered)
```

If any file is not fully delivered, state: "Remaining: [file list]" before stopping.

## Self-Audit Commands

Run these against your own output before delivering:

```bash
# Check for truncation markers
grep -nE '// \.\.\.|/\* \.\.\. \*/|\.\.\.$' <output_files>

# Check for structural shortcuts
grep -nEi '(rest is similar|same for|repeat for|each item|for brevity)' <output_files>

# Check for deferred work
grep -nE '(TODO:|FIXME:|HACK:|XXX:|coming soon|placeholder)' <output_files>

# Check for incomplete integration
grep -nEi '(add your|your.*here|replace with|insert.*key)' <output_files>
```

Zero matches in all categories = deliver. Any match = fix before delivering.

## Truncation Decision Tree

```
Output too long for single response?
├── In the middle of a function?
│   ├── YES → Complete the function first. Never break mid-function.
│   └── NO  → Safe to stop at current file boundary.
├── State remaining scope: "Remaining: [files]"
└── End with: "Continue with [file] when ready."
```

## Pattern Reference by Language

| Language | Common Shortcut Patterns | Full Form |
|---|---|---|
| Python | `# ...` or `pass  # TODO` | Complete function body |
| JavaScript/TS | `// ...` or `/* ... */` | Complete implementation |
| Rust | `// ...` or `unimplemented!()` | Complete match arms |
| Go | `// ...` or `return nil, nil` | Complete error handling |
| Shell | `# ...` or `: # TODO` | Complete case branches |
| Any | `// similar for X, Y, Z` | Write each variant explicitly |

## Final Verification

- [ ] Scope declared, scope delivered
- [ ] Zero grep matches in all 4 categories
- [ ] No mid-function breaks
- [ ] Remaining scope stated if truncated
- [ ] Each file is independently runnable (no cross-file dangling refs)

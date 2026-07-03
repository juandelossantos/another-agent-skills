# Example: Node.js Project

> **This guide proves the full loop works in a Node.js project: detect → diagnose → propose → fix → `npm test` → ADR.**

## Prerequisites

```bash
# Your Node.js project
cd my-react-app
npm init -y

# Install the self-improvement loop
bash path/to/another-agent-skills/scripts/init-agents.sh --with-self-improvement

# Creates:
#   .audit-config.json      (excludes node_modules/, dist/, build/)
#   scripts/audit-project.sh
#   STACK_CONFIG.md         (test_cmd: npm test)
#   PATTERNS.md, ANTI-PATTERNS.md, ADRs/
#   skills/self-improvement/
```

---

## Iteration 1: A False Positive (Dismiss)

### Detect

```bash
bash scripts/audit-project.sh --json
```

```json
{
  "summary": { "pass": 5, "warn": 1, "fail": 0 },
  "failures": [],
  "warnings": [
    {
      "type": "placeholder",
      "file": "./docs/API.md",
      "message": "./docs/API.md:34: placeholder found: //TODO:adderrorhandling"
    }
  ]
}
```

### Diagnose

The warning is in `docs/API.md` line 34. You check the file:

```markdown
## Error Handling

All endpoints return standardized errors:
```
```javascript
// TODO: add error handling
app.use((err, req, res, next) => {
  res.status(500).json({ error: err.message });
});
```
```

The `TODO:` is **inside a fenced code block** — it's an *example* of bad code, not a real task marker. This is a false positive (the code-block exemption should have caught it, but the fence may have been malformed).

### Propose

```
Self-improvement loop — Iteration 1/3:
  Issues found: 1 (warning, non-blocking)
  Proposed fix: DISMISS — false positive. TODO: is inside a code block (example code).
  Pattern applied: N/A (no fix needed)
  ADR generated: N/A
```

### Execute

No fix applied. The warning is non-blocking (exit 0). Move to the next iteration.

---

## Iteration 2: A Real Issue (Fix)

### Detect

You add a new doc file and run the audit again:

```bash
bash scripts/audit-project.sh --json
```

```json
{
  "summary": { "pass": 5, "warn": 0, "fail": 1 },
  "failures": [
    {
      "type": "link",
      "file": "./README.md",
      "message": "./README.md: broken link -> docs/getting-started.md"
    }
  ],
  "warnings": []
}
```

### Diagnose

`README.md` is a **core file** (matched by `^README\.md$` in `.audit-config.json`). A broken link in a core file is a **blocking failure** (exit 1). You check the file:

```markdown
## Getting Started

See [Getting Started Guide](docs/getting-started.md) for setup instructions.
```

The file `docs/getting-started.md` doesn't exist — you renamed it to `docs/setup.md` last week but forgot to update the README link.

**Pattern:** Lazy Loading (file references must point to existing files).
**Anti-pattern:** Stale Reference (link targets changed without updating references).

### Propose

```
Self-improvement loop — Iteration 2/3:
  Issues found: 1 (blocking failure in core file)
  Proposed fix: Update README.md link: docs/getting-started.md → docs/setup.md
  Pattern applied: Lazy Loading (PATTERNS.md)
  ADR generated: N/A (not a new rule, just a stale link fix)
```

### Execute

User approves. You fix the link:

```markdown
See [Getting Started Guide](docs/setup.md) for setup instructions.
```

Verify:

```bash
# 1. Audit passes
bash scripts/audit-project.sh
# → exit 0, All checks passed

# 2. Tests pass
npm test
# → all tests pass

# 3. Commit
git add README.md
git commit -m "fix: update stale link to getting-started guide"
```

---

## Node.js-Specific Config

The `.audit-config.json` for a typical Node.js project:

```json
{
  "project_name": "my-react-app",
  "include_patterns": ["**/*.md"],
  "exclude_patterns": ["node_modules/**", ".git/**", "dist/**", "build/**", "coverage/**"],
  "core_files": ["^README\\.md$", "^CONTRIBUTING\\.md$", "^CHANGELOG\\.md$"],
  "max_file_length": 250,
  "length_check_paths": ["docs/"],
  "checks": {
    "tables": true,
    "links": true,
    "placeholders": true,
    "file_length": true,
    "mermaid": true,
    "terminology": false
  },
  "terminology_rules": {}
}
```

**Key excludes for Node:** `node_modules/` (dependencies), `dist/` + `build/` (build output), `coverage/` (test coverage reports).

---

## Summary

| Iteration | Issue | Type | Action | Why |
|---|---|---|---|---|
| 1 | `TODO:` in code block | False positive (WARN) | Dismiss | Code-block example, not a real marker |
| 2 | Broken link in README | Real issue (FAIL) | Fix + verify + commit | Core file, blocking |

The loop teaches you to **tell the difference** between false positives and real issues — dismissing the first, fixing the second.

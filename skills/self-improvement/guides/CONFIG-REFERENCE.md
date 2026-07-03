# Config Reference Guide

> **This guide proves that every `.audit-config.json` key is documented with its type, default, and example.**

## All 8 Keys

| Key | Type | Default | Description |
|---|---|---|---|
| `project_name` | string | `"project"` | Shown in the audit banner output. Helps identify which project is being audited. |
| `include_patterns` | string[] | `["**/*.md"]` | Glob patterns for file discovery. The engine scans all files matching these patterns. |
| `exclude_patterns` | string[] | `[".git/**", "node_modules/**", ...]` | Patterns to exclude from the scan. Use glob syntax (`**` for recursive). |
| `core_files` | string[] (regex) | `[]` | Regex patterns for **blocking** files. Issues in core files = FAIL (exit 1). Issues in non-core = WARN (exit 0). The engine strips `./` from paths before matching, so write `^AGENTS\.md$`, not `^\./AGENTS\.md$`. |
| `max_file_length` | number | `250` | Maximum line count before the `file_length` check fails. Applies only to files matching `length_check_paths`. |
| `length_check_paths` | string[] (regex) | `[]` | Paths to apply the length check. E.g., `["skills/"]` checks only files under `skills/`. Empty = no length checking. |
| `checks` | object | all `true` | Per-check enable/disable. See below. |
| `terminology_rules` | object | `{}` | Map of `{lowercase: Capitalized}` terms. The terminology check flags lowercase usage. E.g., `{"guardian": "Guardian"}`. |

## The `checks` Object

| Check | Key | What it does |
|---|---|---|
| Table column consistency | `checks.tables` | Flags markdown tables where header columns ≠ separator columns |
| Broken internal links | `checks.links` | Flags `[text](file.md)` where `file.md` doesn't exist. Resolves relative to the linking file's directory. Strips `#fragment` anchors. |
| Placeholder detection | `checks.placeholders` | Flags `TODO:`, `FIXME:`, `XXX`, `coming soon`, `under construction`, `lorem ipsum` **outside** fenced code blocks. TODOs inside ``` blocks are exempt (they're examples, not real markers). |
| File length | `checks.file_length` | Flags files exceeding `max_file_length` in paths matching `length_check_paths` |
| Mermaid diagrams | `checks.mermaid` | Counts `mermaid` code blocks (informational, non-blocking) |
| Terminology | `checks.terminology` | Flags lowercase terms that should be capitalized, per `terminology_rules` |

---

## Example: Node.js Project

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

## Example: Python Project

```json
{
  "project_name": "my-python-service",
  "include_patterns": ["**/*.md"],
  "exclude_patterns": ["__pycache__/**", ".venv/**", "*.egg-info/**", ".git/**"],
  "core_files": ["^README\\.md$", "^CONTRIBUTING\\.md$"],
  "max_file_length": 250,
  "length_check_paths": ["docs/"],
  "checks": {
    "tables": true,
    "links": true,
    "placeholders": true,
    "file_length": true,
    "mermaid": false,
    "terminology": false
  },
  "terminology_rules": {}
}
```

---

## How `core_files` Regex Works

The engine discovers files via `find . -name "*.md"`, producing paths like `./README.md`, `./docs/guide.md`. Before matching against `core_files`, the engine **strips the `./` prefix**:

```
./README.md  →  README.md  →  matched against ^README\.md$  →  core file
./docs/guide.md  →  docs/guide.md  →  not matched  →  non-core file
```

**Key:** write regex patterns against the path WITHOUT `./`. Use `^` and `$` anchors for exact matches.

---

## Creating a Config

### Via `--init` (template with defaults):

```bash
bash scripts/audit-project.sh --init
```

Creates `.audit-config.json` with all keys and sensible defaults. Edit `project_name` and `core_files` for your project.

### Via `init-agents --with-self-improvement` (stack-aware):

```bash
bash init-agents.sh --with-self-improvement
```

Auto-detects your stack (Node, Python, Go, Rust, etc.) and creates a config with appropriate `exclude_patterns` (e.g., Node → excludes `node_modules/`, Python → excludes `__pycache__/`).

---

## Disabling a Check

To disable a check, set its key to `false`:

```json
{
  "checks": {
    "links": false,
    "terminology": false
  }
}
```

The engine skips disabled checks entirely — no output, no warnings, no failures for that check type.

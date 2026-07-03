# Example: Python Project

> **This guide proves the full loop works in a Python project: detect → diagnose → propose → fix → `pytest` → ADR.**

## Prerequisites

```bash
# Your Python project
cd my-python-service
python -m venv .venv
source .venv/bin/activate
pip install pytest

# Create pyproject.toml (minimal)
cat > pyproject.toml << 'EOF'
[tool.pytest.ini_options]
testpaths = ["tests"]
EOF

# Install the self-improvement loop
bash path/to/another-agent-skills/scripts/init-agents.sh --with-self-improvement

# Creates:
#   .audit-config.json      (excludes __pycache__/, .venv/, *.egg-info/)
#   scripts/audit-project.sh
#   STACK_CONFIG.md         (test_cmd: pytest)
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
  "summary": { "pass": 3, "warn": 1, "fail": 0 },
  "failures": [],
  "warnings": [
    {
      "type": "placeholder",
      "file": "./docs/ARCHITECTURE.md",
      "message": "./docs/ARCHITECTURE.md:22: placeholder found: TODO:refactorauthmodule"
    }
  ]
}
```

### Diagnose

The warning is in `docs/ARCHITECTURE.md` line 22. You check the file:

```markdown
## Future Plans

We plan to address these items in Q3:

- TODO: refactor auth module to use dependency injection
- Add rate limiting to public endpoints
- Migrate from Flask to FastAPI
```

The `TODO:` is in a **future plans list** — it's a planning note, not a code task marker. The audit can't distinguish "planning TODO" from "code TODO" because both are outside code blocks. This is a known limitation documented in ADR-009.

### Propose

```
Self-improvement loop — Iteration 1/3:
  Issues found: 1 (warning, non-blocking)
  Proposed fix: DISMISS — false positive. TODO: in a planning list, not a code marker.
  Pattern applied: N/A (no fix needed)
  ADR generated: N/A
```

### Execute

No fix applied. The warning is non-blocking (exit 0). Move to the next iteration.

---

## Iteration 2: A Real Issue (Fix)

### Detect

You add a new contributor guide and run the audit:

```bash
bash scripts/audit-project.sh --json
```

```json
{
  "summary": { "pass": 3, "warn": 0, "fail": 1 },
  "failures": [
    {
      "type": "link",
      "file": "./README.md",
      "message": "./README.md: broken link -> CONTRIBUTING.md"
    }
  ],
  "warnings": []
}
```

### Diagnose

`README.md` is a **core file** (matched by `^README\.md$`). A broken link in a core file is **blocking** (exit 1). You check:

```markdown
## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
```

The file `CONTRIBUTING.md` doesn't exist yet — you linked it before creating it.

**Pattern:** Edit Barrier (references must point to existing files before shipping).
**Anti-pattern:** Forward Reference (linking to a file that doesn't exist yet).

### Propose

```
Self-improvement loop — Iteration 2/3:
  Issues found: 1 (blocking failure in core file)
  Proposed fix: Create CONTRIBUTING.md with minimal content (or remove the link)
  Pattern applied: Edit Barrier (PATTERNS.md)
  ADR generated: N/A (standard fix, not a new rule)
```

### Execute

User approves. You create `CONTRIBUTING.md`:

```markdown
# Contributing

## Setup

1. Clone the repo
2. `python -m venv .venv && source .venv/bin/activate`
3. `pip install -e ".[dev]"`

## Running Tests

```bash
pytest
```

## Code Style

Follow PEP 8. Use `ruff check` before committing.
```

Verify:

```bash
# 1. Audit passes
bash scripts/audit-project.sh
# → exit 0, All checks passed

# 2. Tests pass
pytest
# → 12 passed, 0 failed

# 3. Commit
git add CONTRIBUTING.md
git commit -m "docs: add CONTRIBUTING.md to fix broken README link"
```

---

## Python-Specific Config

The `.audit-config.json` for a typical Python project:

```json
{
  "project_name": "my-python-service",
  "include_patterns": ["**/*.md"],
  "exclude_patterns": ["__pycache__/**", ".venv/**", "*.egg-info/**", ".git/**", ".mypy_cache/**"],
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

**Key excludes for Python:** `__pycache__/` (bytecode cache), `.venv/` (virtual env), `*.egg-info/` (packaging metadata), `.mypy_cache/` (type checker cache).

---

## How `init-agents` Detects Python

When `init-agents.sh` runs in a Python project, it checks for:

| File | Detected as | Test command |
|---|---|---|
| `pyproject.toml` with `pytest` | Python + pytest | `pytest` |
| `pytest.ini` or `conftest.py` | Python + pytest | `pytest` |
| `setup.py` / `requirements.txt` (no pytest) | Python | `python -m pytest` |

The detected test command is written to `STACK_CONFIG.md` and used by the self-improvement loop in Step 5.

---

## Summary

| Iteration | Issue | Type | Action | Why |
|---|---|---|---|---|
| 1 | `TODO:` in planning list | False positive (WARN) | Dismiss | Planning note, not a code marker (ADR-009 limitation) |
| 2 | Broken link to missing CONTRIBUTING.md | Real issue (FAIL) | Fix + verify + commit | Core file, blocking |

The loop catches real issues while teaching you to dismiss false positives — the key skill for using any automated audit effectively.

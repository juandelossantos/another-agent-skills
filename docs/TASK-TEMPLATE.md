# Task Template

Every task in a plan must include: need evidence, pre-flight tests, acceptance criteria, and verification. This is not optional — a task without tests is a wish.

## Format

```markdown
#### Task <N>.<M>: [Verb] [Noun]

**Description:** What this task does and why it exists. Link to the problem it solves.

**Need evidence (RED):**
- `command that shows the problem` → expected current output

**Pre-flight tests (RED baseline):**
- [ ] `command` → expected output
- [ ] `command` → expected output

**Changes:**
| File | Change |
|---|---|
| `path/to/file` | What will be modified |

**Post-flight tests (GREEN):**
- [ ] `command` → expected output after fix
- [ ] `command` → expected output after fix

**Acceptance criteria:**
- [ ] Condition 1 — verifiable by command
- [ ] Condition 2 — verifiable by command
- [ ] No regressions: existing tests still pass
- [ ] Evidence captured in task log

**Verification evidence:**
Run all post-flight tests, capture output, confirm every criterion is met.
```

## Minimal Example

```markdown
#### Task 1.2: Upgrade Node.js to v22

**Description:** Current Node.js v18 is EOL. Upgrade to v22 for security patches and performance.

**Need evidence:**
- `node --version` → `v18.x`

**Pre-flight tests:**
- [ ] `npm test` → all pass (baseline)
- [ ] `git status` → clean working tree

**Changes:**
| File | Change |
|---|---|
| `.nvmrc` | `18` → `22` |
| `package.json` | `engines.node` update |

**Post-flight tests:**
- [ ] `node --version` → `v22.x`
- [ ] `npm test` → all pass (regression check)

**Acceptance criteria:**
- [ ] `node --version` returns v22.x
- [ ] `npm test` passes with no changes to source code
- [ ] `.nvmrc` and `package.json` engines field in sync
```

## Rules

- **Need evidence is mandatory.** If you can't show the problem with a command, you may not understand the task well enough.
- **Pre-flight tests establish the baseline.** Run them before any changes.
- **Post-flight tests prove the fix.** Run them after changes.
- **Acceptance criteria are binary.** Each is a yes/no question answerable by a command or inspection.
- **No regressions is always an acceptance criterion.** The task is not complete if existing tests break.
- **Evidence must be captured.** Task log, commit manifest, or development artifact. "It passed" is not evidence — the output is.

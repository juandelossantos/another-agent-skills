# Memory: debugging-and-error-recovery

Learning log from past debugging sessions. Updated after each significant debugging cycle.

## Format

Each entry records:
- **Date:** When the debugging happened
- **Type:** error, learning, observation
- **Pattern:** What was the root cause
- **Fix:** What resolved it
- **Prevention:** How to prevent it in the future

## Entries

### 2026-06-04 — Learning: TOOL_GAP importance

**Type:** learning
**Pattern:** Agent reported "tests pass" without running them
**Fix:** Added TOOL_GAP verdict (Rule 0h) — report "ship status unknown" when tools can't verify
**Prevention:** Always verify with actual tool execution, never infer from absence of errors

### 2026-06-04 — Learning: Continuation over recap

**Type:** learning
**Pattern:** Agent wasted tokens re-explaining everything after context loss
**Fix:** Added Continuation Over Recap (Rule 0i) — resume from last verified state
**Prevention:** Ask "Where were we?" instead of "Let me summarize"

### 2026-06-04 — Observation: Manifest gate effectiveness

**Type:** observation
**Pattern:** Task manifest creates friction but doesn't prevent empty manifests
**Fix:** Manifest must have minimum content (50+ chars, 4 fields)
**Prevention:** Agent discipline is the real enforcement, not the gate

### 2026-06-03 — Error: pre-commit hook stale COMMIT_EDITMSG

**Type:** error
**Pattern:** pre-commit hook reads old COMMIT_EDITMSG, hash never matches
**Fix:** Moved token validation to commit-msg hook (runs after message is written)
**Prevention:** Always validate tokens in hooks that run AFTER the relevant state is set

### 2026-06-03 — Learning: i18n data-i18n replaces textContent

**Type:** learning
**Pattern:** HTML tags in i18n values rendered as text
**Fix:** Use CSS classes for formatting, keep i18n values as plain text
**Prevention:** Never put HTML tags in i18n JSON values

## How to Update

After each debugging session, add an entry:

```markdown
### [DATE] — [Type]: [Title]

**Type:** error | learning | observation
**Pattern:** What was the root cause
**Fix:** What resolved it
**Prevention:** How to prevent it in the future
```

# Build Integration Guide

This guide contains the complete "Integration with Build Phase" section for `git-init-and-versioning`, used during BUILD phase of any project.

## Integration with Build Phase

**During BUILD (`incremental-implementation` + `test-driven-development`):**

Before every `git commit`, follow this **mandatory 3-step gate**:

### Step 0 — Read User Preference

1. **Check** `~/.config/opencode/user-profile.json` → `workflow.commit_approval`
   - **Missing or `"manual"`** (default): Strict gate. Explicit "yes/sí/commit" required.
   - **`"auto_present"`**: Present changes. Accept "ok/proceed" as approval.
   - **`"full_auto"`**: Present changes. Proceed after 5 seconds unless user objects.

### Step 1 — Run Pre-Commit Checklist

1. **Read** `.github/PRE_COMMIT_CHECKLIST.md` (or `docs/PRE_COMMIT_CHECKLIST.md`).
2. **Run** the 6-axis review (correctness, readability, architecture, security, performance, git hygiene).
3. **If any fail:** Fix the issue. Do not proceed to Step 2 until fixed.

### Step 2 — Present Commit for Approval (BLOCKING)

**DO NOT execute `git commit` until the user explicitly approves.**

Present the commit like this:

```
═══════════════════════════════════════════
📝 COMMIT READY FOR REVIEW
═══════════════════════════════════════════

📁 Files changed:
- src/components/Hero.tsx        (added hero section)
- src/app/globals.css            (added design tokens)
- public/images/hero.jpg         (added hero image)

📊 Pre-commit checklist:
✅ Correctness: Tests pass, matches acceptance criteria
✅ Readability: Descriptive names, no nested ternaries
✅ Architecture: Follows component pattern
✅ Security: No secrets, inputs validated
✅ Performance: transform/opacity only, lazy loading
✅ Git Hygiene: One logical change, no .env committed

📝 Commit message:
feat: add Hero section with Playfair display and warm cream background

- Implements hero with H1, subtitle, CTA button
- Uses design tokens from globals.css
- Adds Reveal animation on scroll
- Responsive: 375px mobile → 1280px desktop

═══════════════════════════════════════════
→ Approve? Reply "yes", "sí", or "commit" to proceed.
→ Changes needed? Reply "edit" or describe what to fix.
→ Skip this commit? Reply "skip" (not recommended).
═══════════════════════════════════════════
```

**Valid user responses (manual mode):**
- `"yes"`, `"sí"`, `"commit"`, `"proceed"` → Execute `git commit`

- `"skip"` → Do not commit, continue to next task (document the skip)

- `"yes"`, `"sí"`, `"commit"`, `"ok"`, `"proceed"` → Execute `git commit`
- `"edit"`, `"change"`, `"fix"` + description → Go back to Step 1, make changes
- `"skip"` → Do not commit

**Invalid responses (manual mode only):**
- `"ok"`, `"mmhm"` → Ask again with explicit "yes/commit" or "edit"
- Silence → Re-prompt with the approval request

**Full auto mode:**
- Present changes. Wait 5 seconds.
- If user objects ("wait", "stop", "no") → switch to manual for this commit.
- If no objection → proceed with commit.

### Step 3 — Execute Commit

Only after explicit approval:

```bash
git add [files]
git commit -m "[descriptive message]"
```

**After commit completes, log metrics:**
```
LOG METRIC: commit
- project: [detect from git remote or directory name]
- files_changed: [count]
- additions: [count]
- deletions: [count]
- pre_commit_passed: true/false
- user_approved: true/false (false if skipped)
- commit_message_category: feat/fix/chore/docs/refactor
```

**Rules:**
- Show the exact files being committed.
- Show the exact commit message.
- Never batch multiple logical changes in one approval request.
- If 5+ files changed, summarize them grouped by purpose.

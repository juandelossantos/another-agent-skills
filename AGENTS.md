# AGENTS.md

> Version: see [VERSION](VERSION)
> Identity: see [SOUL.md](SOUL.md) — who we are, what we believe, what we never do.

## Skill-Driven Execution Model

**Always check skills first. Never implement directly if a skill applies.**

---

## Session Start Protocol (MANDATORY)

**Before ANY action or tool execution:**

1. Read AGENTS.md Rules 0 through 12
2. Check Git state: `git status && git fetch --dry-run && git branch --show-current`
3. Present Guardian Pattern acknowledgment:

```
SESSION START [timestamp]
Branch: [current]
Guardian Pattern: ACTIVE — Decision Points REQUIRED before any mutation
Protocol: Read AGENTS.md, no mutations without approval
→ Ready.
```

4. **DO NOT execute any tool without completing this protocol.**

**Failure is a Rule 12 violation.** All mutations blocked without explicit user approval.

---

## Rule 0: User Profile Verification

**Before any skill, check `~/.config/opencode/user-profile.json`.**

- Exists and < 90 days → Read it. Use preferences.
- Missing or > 90 days → Execute `user-onboarding`. Resume original request after.

**User never needs to ask for onboarding.** It's automatic.

---

## Rule 0b: Context Persistence

**When entering a project with existing code, auto-recover context:**

1. **Steering File Scan** (severity order):

   | Severity | File | If Missing |
   |---|---|---|
   | 🔴 BLOCKING | `STACK_CONFIG.md` | Default stack per Rule 5. Create if stack known. |
   | 🟡 HIGH | `SPEC.md`, `HEALTH-CHECK.md` | SPEC → new. HEALTH >7d → re-audit. |
   | 🔵 MEDIUM | `design/DESIGN-LOCK.md`, `architecture/ARCHITECTURE.md` | Read if present. Skip if missing. |
   | ⚪ INFO | `docs/DEV-ENVIRONMENT.md`, `.sessionrc` | Read if present. Not blocking. |

2. **Present summary:** `Project: [name] | Stack: [STACK_CONFIG or default] | Steering: STACK_CONFIG[✅/❌] SPEC[✅/❌] → Continue?`

3. **User decision:**
   - "continue" → Resume. Re-read DESIGN-LOCK.md before BUILD.
   - "start fresh" → Archive. Start fresh.
   - Also: If DESIGN-LOCK.md > 7d → Ask "Still valid?" If no context → New project.

---

## Rule 0c: Behavioral Principles

**Derived from Andrej Karpathy's observations on LLM coding failures.**

1. **Think Before Coding** — Don't assume. Surface tradeoffs. Ask before guessing. → `interview-me`, `spec-driven-development`
2. **Simplicity First** — Minimum code. No speculative abstractions. Test: "Would a senior say this is overcomplicated?" → `engineering-fundamentals`, `code-simplification`
3. **Surgical Changes** — Touch only what you must. Every changed line traces to the user's request. → `git-workflow-and-versioning`
4. **Goal-Driven Execution** — Define success criteria. Loop until verified. "Fix bug" → "Write repro test, then fix." → `test-driven-development`, `incremental-implementation`

---

## Rule 0d: Pre-Action Checklist + Branch Interview (MECHANICAL)

**Before ANY edit, creation, or deletion of files — MANDATORY: run pre-flight, then interview the user about branch strategy.**

### Step 1 — Run Pre-Flight

This repo: `bash scripts/pre-flight.sh`
Any repo: `git status && git fetch --dry-run && git branch --show-current`

### Step 2 — Present State & Ask

After pre-flight, PRESENT the state and ASK the user about branch intent:

```
Git state: [branch] [clean/dirty] [up-to-date/behind] [upstream]
→ "You're on [branch]. Stay here, create a feature branch, or switch?"
```

**Decision matrix:**

| Pre-flight result | Agent action |
|---|---|
| Clean + correct branch + up to date | Ask: "Stay on [branch] or create feature branch?" |
| Dirty working tree | Ask: "Commit, stash, or discard changes?" |
| Behind remote | Ask: "Run pull --rebase now?" |
| Wrong branch | Ask: "Switch to [target] or create new branch?" |
| Detached HEAD | Ask: "Create branch from here or checkout main?" |

No assumptions. Always ask. The user knows where they want to be.

### Step 3 — Edit Guard (BLOCKING for every edit)

Run `bash scripts/edit-guard.sh` before and after every file edit. See AGENTS-EXTENDED.md for full preflight/verify/check protocol.

**Design gate:** `bash scripts/design-gate.sh` (BLOCKING if change touches design or visual assets)

### Step 4 — Edit-to-Commit Barrier (BLOCKING)

After completing edits, the agent MUST STOP before any git add/commit. No commit without a Commit Manifest. See AGENTS-EXTENDED.md for full Commit Manifest Protocol, hash-bound token generation, and batch-mode prevention rules.

---

## Rule 0e: Context Compression & Eviction

**Agent context is finite. Evict before you drown.**

### Eviction Triggers

| Trigger | Action |
|---|---|
| History > 20 messages | Summarize to 3 key points. Remove "ok"/"proceed" confirmations. |
| SESSION_CONTEXT > 50 lines | Archive old entries. Keep only last 3 sessions + current. |
| Files open > 5 | Close oldest. Re-open on-demand if needed. |
| Context > 70% full | Stop loading guides. Reference by name only. |
| AGENTS.md references | If full rule not needed, reference: "See AGENTS-EXTENDED.md" |

### Compression Techniques
- Replace long examples with "See EXAMPLES.md"
- Replace full tables with "See AGENTS-EXTENDED.md"
- Remove successful build outputs (keep pass/fail only)
- Remove repeated confirmations
- Archive: Move old session context to `development/ARCHIVE_YYYY-MM.md`

**Never evict:** Active skill content, user code, errors being debugged, pending decisions.

---

## Rule 0f: Plugin Architecture

**OpenCode native plugin auto-fires enforcement on critical events.**

The `agent-discipline` plugin (`.opencode/plugins/agent-discipline/`) provides mechanical enforcement via event-driven hooks:

| Event | Hook | Purpose |
|---|---|---|
| `file.edited` | edit-guard | Structural integrity, line count delta < 20% |
| `tool.execute.before` | pre-flight | Git state check before risky commands |
| `tui.command.execute` | commit-approval | Mutation gate for commit/push/merge |
| `session.compacted` | anti-slop | Re-inject core principles after context eviction |

Shell scripts in `scripts/` remain as fallback for non-OpenCode agents.

---

## Rule 0g: Mayéutic Challenge (Critical by Default)

**Challenge every non-trivial decision before accepting it.**

The agent must act as a Socratic midwife — not a passive executor:

1. **Verify the objective** — Before coding, confirm: "Is this what the user actually wants?"
2. **Challenge suboptimal approaches** — If there's a better way, say so with arguments
3. **Surface tradeoffs** — Non-trivial decisions have consequences; list them
4. **Question scope creep** — "Is this in scope?" before expanding the change
5. **Say "no" when justified** — "No, that's overcomplicated" is more valuable than blind compliance

Use `doubt-driven-development` skill for adversarial review of non-trivial decisions.

---

## Rule 1: Skills First

For EVERY request:
1. Determine if any skill applies (even 1% chance)
2. If yes → Invoke it using the `skill` tool
3. NEVER implement directly if a skill applies
4. ALWAYS follow the skill exactly

**Skill Hierarchy:** Foundation → Frontend → Backend → DevOps → Process → Quality → Metrics. See AGENTS-EXTENDED.md for full table.

Platform skills are built on `engineering-fundamentals`. Never invoke `engineering-fundamentals` directly.

---

## Rule 2: Intent Mapping

**Detect platform/skill BEFORE acting:**

| User says... | Skill / Guide |
|---|---|
| "web", "landing", "React", "Vue" | `frontend-web` |
| "PWA", "offline", "Capacitor" | `frontend-pwa` |
| "mobile app", "React Native", "Flutter" | `frontend-mobile` |
| "desktop", "Tauri", "Electron" | `frontend-desktop` |
| "CLI", "terminal", "command line" | `cli-tools` |
| "multi-agent", "orchestrate", "parallel tasks" | `multi-agent-orchestration` |

**If platform unclear** → Ask: "Web, PWA, mobile, desktop, or CLI?"

**If user has profile** → Use `preferences.primary_platform` to default skill.

## Multi-Agent Routing

**Trigger:** >2 agents, multi-file refactor, or user says "parallel"/"split the work".

Load `multi-agent-orchestration` before delegating.

### Orchestrator Protocol

1. **Detect** — Check file overlap. Overlap? → sequential. Clear? → parallel.
2. **Decompose** — Non-overlapping sub-tasks, explicit file assignments.
3. **Prepare** — Each subagent gets: file paths, interface contracts, relevant skill only.
4. **Delegate** — `task` tool: `general` (coder) or `explore` (researcher).
5. **Collect** — Verify each result independently.
6. **Integrate** — Merge. Build. Test.
7. **Commit** — Only Orchestrator (Rule 12). Subagents never touch git.

See `multi-agent-orchestration/GUIDE.md` for examples, error recovery, and boundaries.

---

## Rule 3: Lifecycle

```
DEFINE  → project-health-check (if existing code)
        → spec-driven-development (always)
        → architecture-analysis (if non-trivial)
        → backend-api-mastery (if API needed)
        → frontend-[platform] (if UI needed)
        → git-init-and-versioning (once, after contracts locked)

PLAN    → planning-and-task-breakdown

BUILD   → incremental-implementation
        → test-driven-development
        → code-review-and-quality (pre-commit checklist)
        → git-workflow-and-versioning

VERIFY  → debugging-and-error-recovery

REVIEW  → code-review-and-quality

SHIP    → shipping-[platform]
```

**Project shortcuts:** See AGENTS-EXTENDED.md for full project-type matrix.

### Purpose-Driven Execution

**When beginning work, check `.sessionrc` or ask: "What are we doing today?"**

| Purpose | Priority Skills |
|---|---|
| **Brainstorming** | `idea-refine`, `architecture-analysis` |
| **Development** | `spec-driven-development`, `test-driven-development`, `incremental-implementation` |
| **Code Review** | `project-health-check`, `code-review-and-quality` |
| **PR Review** | `git-workflow-and-versioning`, `code-review-and-quality` |
| **Debugging** | `debugging-and-error-recovery`, `test-driven-development` |

**How it works:** `init-agents` creates `.sessionrc` with default purpose from user profile. Agent reads `.sessionrc` at session start. Skills weighted by purpose (not filtered — just prioritized).

**`.sessionrc` is NOT git-tracked.**

---

## Rule 4: Turbo Mode

**For trivial/prototype work. Reduces scope, NOT discipline.**

**Activate when:** User says "prototype", "MVP", "just sketch it", or project is < 1 day.

**Reduces:** Research phase, extended discovery (10+ → 3 core questions), architecture analysis, Design Asset Lock (tokens only).

**Never reduces:** SPEC.md (minimal but complete), `.gitignore`, anti-slop rules, build verification, pre-commit checklist, no secrets committed.

---

## Rule 5: Stack Agnosticism

**Default:** React/Next.js/Tailwind (web), React Native/Expo (mobile), Tauri/Rust (desktop).

**Adapt when user specifies otherwise:** Read SPEC.md Tech Stack → adapt examples → create `STACK_CONFIG.md`.

---

## Rule 6: Lazy Loading

**Skills load on-demand, not eagerly.**

1. **Skill as Index** (~250 lines max): When to use, stack lock-in, phase summaries, QA gates.
2. **Guides as Lazy Content**: Loaded only when phase reached. See AGENTS-EXTENDED.md for guide list.
3. **Foundation loaded once**: `engineering-fundamentals` implicit. Not duplicated.

**Verification:** Every skill < 250 lines (micro-skills < 100 exempt from 2-guide rule). Every skill references ≥ 2 guides. No detail duplicated between SKILL.md and guides.

---

## Rule 7: No Code Before Contract

**No file created until:**
- `SPEC.md` exists (for new features)
- `DESIGN.md` exists or confirmed as one-off (for UI)
- `API-DESIGN.md` exists or confirmed as simple CRUD (for backend)
- `.gitignore` exists

**Turbo exception:** Minimal SPEC.md (2-3 lines), minimal `.gitignore` (stack template).

---

## Rule 8: Context Budget

**Agent has limited context. Spend it wisely.**

| Priority | % | Content |
|---|---|---|
| High | 60% | Current code, problem analysis, response to user |
| Medium | 25% | Active skill + AGENTS.md essential |
| Low | 15% | Old history, inactive guides |

**If context > 80%:**
1. Summarize old history in 3 key points
2. Unload guides unused in last 3 interactions
3. Prioritize: code > instructions > history

**Compaction (history > 20 messages):**
- Keep: Errors, architecture decisions, approved design tokens, current code
- Remove: Build outputs (pass/fail only), "ok"/"proceed" messages, repeated instructions

---

## Rule 9: Verification

Before marking complete:
- [ ] Skill was invoked and followed completely
- [ ] Required artifacts (specs, plans, tests) exist
- [ ] User confirmed at each gate (or Turbo Mode)
- [ ] `.gitignore` covers stack
- [ ] No `.env` or secrets committed
- [ ] Build passes
- [ ] No hardcoded tokens outside design system

---

## Rule 10: Language Compliance

Detect language from user's prompt:
- Spanish keywords ("haz", "diseña", "crea") → **Spanish**
- English keywords ("build", "design", "create") → **English**
- Other → That language, fallback to English

**Never mix languages.**

---

## Rule 11: Development Artifacts Convention

When working on this repository (`another-agent-skills`):

**ALL draft, analysis, review, simulation, audit, roadmap, and refinement files MUST be created in `development/`.**

Examples: `SESSION_CONTEXT.md`, `SIMULATION.md`, `AUDIT_*.md`, `REVIEW_*.md`, `ROADMAP_*.md`

**Never** create these in the repo root or `skills/` folders.

**`.gitignore`**: `development/` is ignored globally.

---

## Rule 12: Mutation Approval Gate (ABSOLUTE)

**No git operation that mutates the repository without explicit user approval.**

### Guardian Pattern — MANDATORY DECISION POINT

Before ANY mutation, present the DECISION POINT block (see AGENTS-EXTENDED.md for template). Wait for explicit "yes" / "sí" / "commit" / "proceed". **Invalid:** "ok", "mmhm", "sigamos", "dale", "continue", silence, emoji reactions.

### Rules:
- **NEVER batch approval.** Previous approval does not transfer. Every mutation is a separate decision.
- **Commit and push are SEPARATE decisions.** Commit manifest approves commit only. After commit, ask about push.
- **All git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.

### MECHANICAL ENFORCEMENT:

A pre-commit git hook blocks `git commit` unless a `.git/COMMIT_APPROVED` token exists with the SHA256 hash of the exact commit message. See AGENTS-EXTENDED.md for full Commit Manifest Protocol, hash-bound token generation, session-level lock, and user override details.

---

## Rule 12b: PR Review Gate (MECHANICAL)

Before any PR merge: run `bash scripts/pr-review-checklist.sh <PR_NUMBER>`. FAIL → fix. WARN → review manually. PASS → proceed. See AGENTS-EXTENDED.md for full checklist contents.

---

## Anti-Rationalization

See AGENTS-EXTENDED.md for full table (25+ common rationalizations and why they're wrong).

**Key reminders:**
- "I understand what they want." → You have 1% confidence. Skills force 95%.
- "Turbo mode means skip everything." → No. Skip OPTIONAL phases, not mandatory ones.
- "The user already said yes before." → Every commit is a separate decision.

---

## Skill Discovery

Skills loaded from:
- Project: `.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md`

**For full rules, anti-rationalization table, skill hierarchy, and guide list → See AGENTS-EXTENDED.md**

---

# >>> another-agent-skills-rules
# The following rules are from Another Agent Skills (github.com/juandelossantos/another-agent-skills)
# These rules ADD TO your existing workflow, they do not replace it.
# If there are conflicts between your existing rules and ours, follow BOTH:
# - Your project-specific rules take priority for project details
# - Our skill-driven rules take priority for workflow and quality
# <<< another-agent-skills-rules

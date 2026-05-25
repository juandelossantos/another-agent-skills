# AGENTS.md

## Skill-Driven Execution Model

**Always check skills first. Never implement directly if a skill applies.**

---

## Rule 0: User Profile Verification

**Before any skill, check `~/.config/opencode/user-profile.json`.**

- Exists and < 90 days → Read it. Use preferences.
- Missing or > 90 days → Execute `user-onboarding`. Resume original request after.

**User never needs to ask for onboarding.** It's automatic.

---

## Rule 0b: Context Persistence

**When entering a project with existing code, auto-recover context:**

1. Check for `design/DESIGN-LOCK.md`, `SPEC.md`, `architecture/ARCHITECTURE.md`, `API-DESIGN.md`, `HEALTH-CHECK.md`, `docs/DEV-ENVIRONMENT.md`
2. If found → Read them. Present summary: Proyecto, Estado, Stack, Fecha → "¿Continuamos?"
3. If user says "continuamos" → Resume from detected phase. Re-read DESIGN-LOCK.md before BUILD.
4. If user says "empecemos de nuevo" → Archive old context. Start fresh.
5. If DESIGN-LOCK.md > 7 days old → Ask: "¿Sigue vigente?"
6. If no context files → Treat as new project. Proceed normally.

**Never say "no recuerdo qué estábamos haciendo." Read the files.**

---

## Rule 0c: Behavioral Principles

**Derived from Andrej Karpathy's observations on LLM coding failures.**

1. **Think Before Coding** — Don't assume. Surface tradeoffs. Ask before guessing. → `interview-me`, `spec-driven-development`
2. **Simplicity First** — Minimum code. No speculative abstractions. Test: "Would a senior say this is overcomplicated?" → `engineering-fundamentals`, `code-simplification`
3. **Surgical Changes** — Touch only what you must. Every changed line traces to the user's request. → `git-workflow-and-versioning`
4. **Goal-Driven Execution** — Define success criteria. Loop until verified. "Fix bug" → "Write repro test, then fix." → `test-driven-development`, `incremental-implementation`

---

## Rule 0d: Pre-Action Checklist (MECHANICAL)

**Before ANY destructive or irreversible action, verbalize this checklist:**

```
STOP. Pre-action checklist:
□ Is this action reversible? If no → REQUIRE explicit approval
□ Does this action affect user data or repository state? If yes → REQUIRE explicit approval
□ Have I presented the full scope to the user? If no → STOP, present first
□ Is the user's last message an explicit "yes/sí/commit" for THIS specific action?
  - "sigamos" / "ok" / "dale" / "continue" / silence = NOT VALID for commits
  - Only "yes", "sí", "commit", "proceed" = VALID
□ Did I self-review if >50 lines changed? If no → STOP, review first
→ If ANY box unchecked: STOP. Ask user before proceeding.
```

**Irreversible actions:** git commit, push, merge, rebase, reset, cherry-pick, revert, file deletion, overwriting existing files, executing scripts that modify system state.

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

**Detect platform BEFORE invoking frontend skill:**

| User says... | Skill |
|---|---|
| "web", "landing", "React", "Vue" | `frontend-web` |
| "PWA", "offline", "Capacitor" | `frontend-pwa` |
| "mobile app", "React Native", "Flutter" | `frontend-mobile` |
| "desktop", "Tauri", "Electron" | `frontend-desktop` |
| "CLI", "terminal" | `cli-tools` |

**If platform unclear** → Ask: "¿Es para web, PWA, móvil, escritorio, o CLI?"

**If user has profile** → Use `preferences.primary_platform` to default skill.

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

1. **Skill as Index** (~200 lines max): When to use, stack lock-in, phase summaries, QA gates.
2. **Guides as Lazy Content**: Loaded only when phase reached. See AGENTS-EXTENDED.md for guide list.
3. **Foundation loaded once**: `engineering-fundamentals` implicit. Not duplicated.

**Verification:** Every skill < 250 lines. Every skill references ≥ 2 guides. No detail duplicated between SKILL.md and guides.

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

**MANDATORY for every mutation:**
1. Present what will change
2. Explain impact and risk
3. **MECHANICAL CHECK:** "Did the user say 'yes', 'sí', or 'commit' for THIS specific action?"
4. **Wait for explicit approval:** "yes", "sí", "commit", "proceed"
5. **Invalid responses:** "ok", "mmhm", "sigamos", "dale", "continue", silence, emoji reactions

**NEVER batch approval.** Previous approval does not transfer. Every commit is a separate decision.

**All git mutations require approval:** commit, push, merge, rebase, reset, cherry-pick, revert, branch -d, tag, stash pop, clean -fd, push --force.

**User override:** "Enable auto commit mode", "Don't ask me for commits", "I trust you with commits". See AGENTS-EXTENDED.md for override details.

---

## Anti-Rationalization

See AGENTS-EXTENDED.md for full table (15+ common rationalizations and why they're wrong).

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

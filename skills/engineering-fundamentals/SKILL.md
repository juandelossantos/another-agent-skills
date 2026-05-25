---
name: engineering-fundamentals
description: >
  Universal engineering philosophy and practices for all platform-specific skills.
  Defines the core disciplines: discovery before code, contracts before implementation,
  anti-slop rules, quality gates, and verification standards. All other skills
  (frontend-web, frontend-mobile, frontend-pwa, backend-api-mastery, etc.)
  MUST reference this skill as their foundation. Never invoke directly — it is the
  base layer for every platform-specific skill.
license: MIT
compatibility: opencode
metadata:
  audience: all-engineers
  type: foundation-skill
---

# Engineering Fundamentals

**No skill implements directly. This is the foundation all platform skills build upon.**

Every platform skill — web, mobile, desktop, IoT, CLI — shares the same philosophy.
This skill defines that philosophy. Platform skills add implementation specifics.

## When to Use

**This skill is NEVER invoked directly.** It is automatically applied by all platform skills.

Platform skills (frontend-web, frontend-mobile, backend-api-mastery, etc.) MUST:
1. Reference this skill's phases in their documentation
2. Apply these principles before adding platform-specific details
3. Never contradict these fundamentals without explicit justification

---

## Core Philosophy

### 1. Contracts Before Code

No file is created until:
- `SPEC.md` exists (what + why + boundaries)
- `DESIGN.md` exists (visual tokens, not architecture)
- `design/DESIGN-LOCK.md` exists (approved snapshot)
- `.gitignore` exists

### 2. Discovery Before Design

**NO CODE IS WRITTEN UNTIL ASSUMPTIONS ARE SURFACED AND CONFIRMED.**

Every project MUST:
- Surface at least 4 assumptions before proposing solutions
- Ask minimum 5 discovery questions (audience, purpose, scope, context, constraints)
- Extend to 10+ for non-trivial projects
- Confirm summary with user before proceeding

### 3. Anti-Slop Discipline

The default output of AI is generic. Our job is to prevent that.

**Intentionality over convenience:**
- Every color, font, and spacing must be justified by DESIGN.md
- Every animation must serve user experience, not decoration
- Every component must feel designed, not generated

**No shortcuts:**
- No "I'll add accessibility later"
- No "I'll use the default for now"
- No "I'll animate width/height just this once"

### 4. Gates Before Progress

Every phase ends with a gate. Do not proceed until:
- User explicitly confirms the previous phase
- All checklists pass
- Contracts are locked

---

## Universal Process

### Phase 0 — Language Detection

Detect the language of the user's request immediately. All subsequent communication MUST be in that same language.

**Detection rules:**
- Spanish keywords (*"haz"*, *"diseña"*, *"crea"*) → **Spanish**.
- English keywords (*"build"*, *"design"*, *"create"*) → **English**.
- Other languages → Respond in that language, fallback to English if uncertain.

**Never mix languages.** All questions, specs, and code comments must match the detected language.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

#### Step 1: Surface Assumptions

List at least 4 assumptions. Present for confirmation:

```
ASSUMPTIONS:
1. The primary user is [describe audience]
2. The core problem this solves is [one sentence]
3. The scale/scope is [MVP/Standard/Complex]
4. [Platform-specific assumption relevant to this domain]
→ Correct me now or I'll proceed with these.
```

#### Step 2: Discovery Questions (Minimum 5)

1. **Audience**: Who will use this?
2. **Purpose**: What must it do in one sentence?
3. **Scope**: How many features/screens? MVP or full product?
4. **Context**: New project or existing? Redesign or from scratch?
5. **Constraints**: Time, budget, team size, regulatory requirements?

#### Step 3: Extended Discovery (Non-Trivial)

6. **Data**: What data must persist? Where?
7. **Security**: Auth needed? What user types?
8. **Integrations**: External APIs, services, hardware?
9. **Offline**: Does it work without internet?
10. **Scalability**: Expected growth in 6-12 months?

#### Step 4: Confirm & Lock

Summarize. Ask: **"¿Es esto correcto? ¿Procedemos? / Is this correct? Shall we proceed?"**

Only after explicit confirmation, proceed to Phase 2.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If no `SPEC.md` exists and this is new work (not a one-off tweak), invoke `spec-driven-development`.

Must include: Objective, Scope, Tech stack (locked versions), Project structure, Acceptance criteria, Boundaries.

#### 2B: DESIGN.md (VISUAL ONLY)

**CRITICAL RULE:** DESIGN.md is for **visual identity and design tokens ONLY**.

**What goes in:** Colors, Typography, Spacing, Rounded corners, Elevation/shadows, Motion tokens, Component visual tokens, Visual Do's and Don'ts.

**What NEVER goes in:** Tech versions, folder structure, API routes, state management, auth, database schema, business logic.

**Paths:**
- **Path A** — DESIGN.md exists: Read it, extract tokens, build strictly within them.
- **Path B** — No DESIGN.md, user wants visual system: Generate with visual tokens only. Present for confirmation.
- **Path C** — No DESIGN.md, one-off task: Do the task. Mention once that a DESIGN.md improves consistency.

**AFTER DESIGN.md IS CONFIRMED — MANDATORY STOP:**

Do NOT write code yet. You have completed DEFINE, not BUILD.

1. Check if a `SPEC.md` exists. If not, invoke `spec-driven-development`.
2. Invoke `planning-and-task-breakdown` to produce a concrete implementation plan.
3. Only after the plan exists and is confirmed, proceed to BUILD.

#### 2C: Design Asset Lock (MANDATORY after visual approval)

Create a `design/` directory:

```
design/
├── DESIGN-LOCK.md          # Snapshot of all approved visual decisions
└── approved/               # Screenshots, previews, moodboards
```

`DESIGN-LOCK.md` must contain: Direction, Final Palette, Final Typography, Key Decisions, References.

**Rules:**
- DESIGN-LOCK.md is a SNAPSHOT. It never changes after approval unless explicitly requested.
- During BUILD, you MUST read `design/DESIGN-LOCK.md` before writing any code. Do not rely on memory.

#### 2D: Lifecycle Awareness

Respect `AGENTS.md` lifecycle mapping:
- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → Platform-specific skill + `incremental-implementation`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch`

---

### Phase 3 — Aesthetic Direction (Path B only)

Pick ONE direction. Do not blend.

| ID | Direction | Best For |
|---|---|---|
| ED | Editorial Serif | Media, personal brand, luxury |
| SM | Swiss Minimal | SaaS B2B, devtools, fintech |
| LDW | Luxury Dark Warm | Hospitality, jewelry, fashion |
| CB | Corporate Bold | Enterprise, education, legal |
| UE | Understated Elegance | Cafes, agencies, wellness, portfolio |
| NB | Neo-Brutalist | Startups, creative communities |
| PG | Playful Gradient | Consumer apps, edtech |
| RT | Retro Terminal | DevTools, technical docs |

---

### Phase 4 — Anti-Slop Principles

Non-negotiable rules to prevent the generic "AI look."

**Intentionality**
- NEVER use default/generic options without justification.
- ALWAYS choose with purpose: every color, font, spacing, and animation must have a reason.
- Timid palettes, safe fonts, and default layouts are forbidden.

**Tokens Over Hardcoding**
- NEVER use hardcoded values in components.
- ALWAYS use design tokens from DESIGN.md or a central theme system.
- If a value is used more than once, it must be a token.

**Performance**
- NEVER sacrifice performance for convenience.
- ALWAYS measure: 60fps for animations, fast load times, minimal bundle size.

**Accessibility**
- NEVER treat accessibility as a stretch goal.
- ALWAYS design for all users: contrast ratios, focus indicators, reduced motion.
- Accessibility is a gate, not an afterthought.

---

### Phase 5 — Quality Gates

Before declaring complete, verify:

1. **Contracts present** — SPEC.md and DESIGN.md exist and were read.
2. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
3. **No hardcoded tokens** — All colors, fonts, spacing come from the token system.
4. **Accessibility** — Contrast 4.5:1, focus indicators, reduced motion fallback.
5. **Build passes** — Compilation succeeds without errors.
6. **Visual consistency** — No design element deviates from DESIGN.md without explicit user approval.

---

### Phase 6 — Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just use the default for now." | Defaults are the #1 sign of AI-generated output. They violate the token system and create inconsistency. |
| "This is too small for a DESIGN.md." | Even one-off tasks benefit from 3 lines of tokens. It prevents slop. |
| "I'll add [quality] later." | Quality is not a stretch goal. It's a gate. Add it now. |
| "The user didn't ask for [best practice]." | Senior engineers apply best practices by default. The user hired expertise, not obedience. |
| "The user is eager, I'll start coding now." | DESIGN.md approval completes DEFINE, not BUILD. You MUST plan first. |
| "I remember the design, I don't need to look at the files." | Agent context can drift or reset. The `design/DESIGN-LOCK.md` is the ground truth. |
| "This is too small for a skill." | Skills exist precisely for structured thinking. |
| "I understand what they want." | You have 1% confidence. The discovery process forces 95% confidence. |

---

### Phase 7 — Red Flags

Watch for these signals that fundamentals are being violated:
- Code is written before any written requirements exist.
- The agent asks "should I just start building?" before clarifying what "done" means.
- Assumptions are never surfaced or confirmed.
- Contracts (SPEC.md, DESIGN.md) are skipped.
- Hardcoded values appear in the output.
- Accessibility is treated as optional.
- The agent does not read `design/DESIGN-LOCK.md` before writing code.
- Features are implemented that were never mentioned in any spec.

---

## Platform Skill Structure

Every platform skill MUST follow this template:

```markdown
# [Platform] Skill

**Built on `engineering-fundamentals`.** Read that skill first. This document
adds platform-specific implementation to the universal philosophy.

## When to Use
[Platform-specific triggers and exclusions]

### Stack Detection
[How to detect and adapt the user's chosen stack]

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1.
**Platform-specific questions:** [Add here]

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

### Phase 3 — Aesthetic Direction
→ See `engineering-fundamentals` Phase 3.

### Phase 4 — Anti-Slop Implementation
→ See `engineering-fundamentals` Phase 4 for principles.
**Platform-specific rules:** [Add here]

### Phase 5 — Build
[Platform-specific build instructions]

### Phase 6 — QA Gates
→ See `engineering-fundamentals` Phase 5 for universal gates.
**Platform-specific checks:** [Add here]

### Phase 7 — Verification
→ See `engineering-fundamentals` Phase 7.
```

---

## Verification

Evidence that a platform skill followed these fundamentals:
- `SPEC.md` exists with Objective, Scope, Tech stack, Acceptance criteria, Boundaries.
- `DESIGN.md` exists with visual tokens (colors, typography, spacing).
- `design/DESIGN-LOCK.md` exists and was read before coding.
- Discovery phase was completed before any code was written.
- User confirmed at each gate.
- No hardcoded design tokens in implementation files.
- Accessibility is present (contrast, focus, reduced motion).
- Build passes without errors.

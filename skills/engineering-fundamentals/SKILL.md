---
name: engineering-fundamentals
description: >
  Universal engineering philosophy for all platform skills. Defines discovery,
  contracts, anti-slop, quality gates. All platform skills (frontend-web,
  frontend-mobile, backend-api, etc.) reference this skill as their foundation.
  Never invoke directly.
license: MIT
compatibility: opencode
metadata:
  audience: all-engineers
  type: foundation-skill
---

# Engineering Fundamentals

**Foundation for all platform skills. Never invoke directly.**

Platform skills add implementation specifics to this philosophy.

## Core Philosophy

1. **Contracts Before Code** — No file until SPEC.md, DESIGN.md, DESIGN-LOCK.md, .gitignore exist.
2. **Discovery Before Design** — No code until assumptions surfaced and confirmed.
3. **Anti-Slop** — Default AI output is generic. Intentionality prevents that.
4. **Gates Before Progress** — Every phase ends with user confirmation.

## Universal Process

### Phase 0 — Language Detection

Detect user's language immediately. All communication in that language.

- Spanish ("haz", "diseña", "crea") → **Spanish**
- English ("build", "design", "create") → **English**
- Other → That language, fallback to English

**Never mix languages.** Questions, specs, code comments match detected language.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE UNTIL COMPLETE.**

**Step 1: Surface Assumptions**

```
ASSUMPTIONS:
1. Primary user: [describe audience]
2. Core problem: [one sentence]
3. Scale/scope: [MVP/Standard/Complex]
4. [Platform-specific assumption]
→ Correct me now or I proceed with these.
```

**Step 2: Discovery Questions (Minimum 5)**

1. **Audience**: Who will use this?
2. **Purpose**: What must it do in one sentence?
3. **Scope**: How many features? MVP or full product?
4. **Context**: New or existing? Redesign or from scratch?
5. **Constraints**: Time, budget, team, regulatory?

**Step 3: Extended Discovery (Non-Trivial)**

6. **Data**: What persists? Where?
7. **Security**: Auth needed? User types?
8. **Integrations**: External APIs, services, hardware?
9. **Offline**: Works without internet?
10. **Scalability**: Expected growth in 6-12 months?

**Step 4: Confirm & Lock**

Summarize. Ask: **"¿Es esto correcto? ¿Procedemos? / Is this correct? Shall we proceed?"**

Only after explicit confirmation, proceed to Phase 2.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If no SPEC.md exists and this is new work (not a one-off tweak), invoke `spec-driven-development`.

Must include: Objective, Scope, Tech stack (locked versions), Project structure, Acceptance criteria, Boundaries.

#### 2B: DESIGN.md (VISUAL ONLY)

**CRITICAL:** DESIGN.md is for **visual identity and tokens ONLY**.

**What goes in:** Colors, Typography, Spacing, Border radius, Elevation/shadows, Motion tokens, Component visual tokens, Do's and Don'ts.

**What NEVER goes in:** Tech versions, folder structure, API routes, state management, auth, DB schema, business logic.

**Paths:**
- **Path A** — DESIGN.md exists: Read it, extract tokens, build within them.
- **Path B** — No DESIGN.md, user wants visual system: Generate with visual tokens only. Present for confirmation.
- **Path C** — No DESIGN.md, one-off task: Do the task. Mention once that DESIGN.md improves consistency.

**AFTER DESIGN.md CONFIRMED — MANDATORY STOP:**

Do NOT write code yet. DEFINE is complete, not BUILD.

1. Check if SPEC.md exists. If not, invoke `spec-driven-development`.
2. Invoke `planning-and-task-breakdown` for implementation plan.
3. Only after plan exists and is confirmed, proceed to BUILD.

#### 2C: Design Asset Lock (MANDATORY after visual approval)

Create `design/` directory:

```
design/
├── DESIGN-LOCK.md          # Snapshot of approved visual decisions
└── approved/               # Screenshots, previews, moodboards
```

`DESIGN-LOCK.md` must contain: Direction, Final Palette, Final Typography, Key Decisions, References.

**Rules:**
- DESIGN-LOCK.md is a SNAPSHOT. Never changes after approval unless explicitly requested.
- During BUILD, MUST read `design/DESIGN-LOCK.md` before writing any code. Do not rely on memory.

#### 2D: Lifecycle Awareness

Respect `AGENTS.md` lifecycle:
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

**Intentionality**
- NEVER use defaults without justification.
- ALWAYS choose with purpose: every color, font, spacing, animation must have a reason.
- Timid palettes, safe fonts, default layouts = forbidden.

**Tokens Over Hardcoding**
- NEVER use hardcoded values in components.
- ALWAYS use design tokens from DESIGN.md or central theme.
- If used more than once, it must be a token.

**Performance**
- NEVER sacrifice performance for convenience.
- ALWAYS measure: 60fps animations, fast loads, minimal bundles.

**Accessibility**
- NEVER treat accessibility as optional.
- ALWAYS design for all users: contrast ratios, focus indicators, reduced motion.
- Accessibility is a gate, not an afterthought.

---

### Phase 5 — Quality Gates

Before declaring complete:

1. **Contracts present** — SPEC.md and DESIGN.md exist and were read.
2. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
3. **No hardcoded tokens** — All colors, fonts, spacing from token system.
4. **Accessibility** — Contrast 4.5:1, focus indicators, reduced motion fallback.
5. **Build passes** — Compilation succeeds without errors.
6. **Visual consistency** — No design element deviates from DESIGN.md without explicit approval.

---

### Phase 6 — Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just use the default for now." | Defaults are the #1 sign of AI-generated output. |
| "This is too small for a DESIGN.md." | Even one-off tasks benefit from 3 lines of tokens. |
| "I'll add [quality] later." | Quality is a gate, not an afterthought. |
| "The user didn't ask for [best practice]." | Senior engineers apply best practices by default. |
| "The user is eager, I'll start coding now." | DESIGN.md approval completes DEFINE, not BUILD. |
| "I remember the design, I don't need to look at files." | Agent context drifts. DESIGN-LOCK.md is ground truth. |
| "This is too small for a skill." | Skills exist for structured thinking. |
| "I understand what they want." | You have 1% confidence. Discovery forces 95%. |

---

### Phase 7 — Red Flags

- Code written before any written requirements exist.
- Agent asks "should I just start building?" before clarifying "done".
- Assumptions never surfaced or confirmed.
- Contracts (SPEC.md, DESIGN.md) skipped.
- Hardcoded values in output.
- Accessibility treated as optional.
- Agent does not read `design/DESIGN-LOCK.md` before writing code.
- Features implemented that were never mentioned in any spec.

---

## Platform Skill Template

Every platform skill MUST follow:

```markdown
# [Platform] Skill

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
platform-specific implementation.

## When to Use
[Platform-specific triggers and exclusions]

### Stack Detection
[Detect and adapt user's chosen stack]

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

- SPEC.md exists with Objective, Scope, Tech stack, Acceptance criteria, Boundaries.
- DESIGN.md exists with visual tokens (colors, typography, spacing).
- `design/DESIGN-LOCK.md` exists and was read before coding.
- Discovery phase completed before any code written.
- User confirmed at each gate.
- No hardcoded design tokens in implementation files.
- Accessibility present (contrast, focus, reduced motion).
- Build passes without errors.

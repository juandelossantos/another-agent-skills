---
name: engineering-fundamentals
description: "Define the universal engineering philosophy for all platform skills: discovery, contracts, anti-slop, quality gates. Never invoke directly. Do NOT use for platform-specific implementation."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash
tier: read-only
metadata:
  audience: all-engineers
  type: foundation-skill
---

# Engineering Fundamentals

**Foundation for all platform skills. Never invoke directly.**

Platform skills add implementation specifics to this philosophy.

## Output Contract

No artifact. Consumed implicitly by all platform skills as a foundation reference.

## When to Use

Loaded by all platform skills. Never invoke directly.

## When NOT to Use

- Platform-specific implementation (platform skills add details to this foundation)

## Core Philosophy

1. **Contracts Before Code** — No file until SPEC.md, DESIGN.md, DESIGN-LOCK.md, .gitignore exist.
2. **Discovery Before Design** — No code until assumptions surfaced and confirmed.
3. **Anti-Slop** — Default AI output is generic. Intentionality prevents that.
4. **Gates Before Progress** — Every phase ends with user confirmation.
5. **Behavioral Discipline** — See AGENTS.md Rule 0c. Think before coding. Simplicity first. Surgical changes. Goal-driven execution.
6. **Error Paths Are Main Paths** — See below. Every tool call, gate, loop, and session needs a failure path designed at build time, not patched post-incident.

## Pre-Flight: Repo State Check (Before ANY phase)

**MANDATORY.** Run before Phase 0 and before any file mutation.

Run `bash scripts/pre-flight.sh` and present state to user. Ask about branch intent before any action. See `references/PRE-FLIGHT-DETAIL.md` for full steps and state table.

---

## Universal Process

### Phase 0 — Language Detection

Spanish keywords → Spanish. English → English. Other → that language. Never mix.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE UNTIL COMPLETE.**

**Surface:** Audience, Core problem, Scale (MVP/Standard/Complex), Platform. **Discover (min 5):** Audience, Purpose, Scope, Context, Constraints. **Extended:** Data, Security, Integrations, Offline, Scalability.

**Confirm:** Summarize. Ask "Is this correct? Shall we proceed?" Only after explicit yes.

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If no SPEC.md exists and this is new work (not a one-off tweak), invoke `spec-driven-development`. Must include: Objective, Scope, Tech stack, Project structure, Acceptance criteria, Boundaries.

#### 2B: DESIGN.md — Visual Identity + Implementation Contract

DESIGN.md has two layers. See `guides/DESIGN-MD-SCHEMA.md` for the full 17-section template.

**Sections 1-12 (Visual Identity):** Colors, Typography, Spacing, Border radius, Elevation, Motion, Component states. Filled by direction skills. Blocks if missing required fields.

**Sections 13-17 (Implementation Contract):** CSS Architecture, Theme Implementation, Component Framework, Platform Responsiveness, Asset Pipeline. Filled by platform DESIGN-GUIDE.md. Warns if missing (platform-specific).

**What NEVER goes in (any section):** Business logic, API routes, database schema, auth implementation, folder structure — those belong in SPEC.md or ADRs.

| State | Action |
|---|---|
| DESIGN.md exists | Read it, extract tokens. Validate against `DESIGN-MD-SCHEMA.md`. Build within. |
| No DESIGN.md, wants visual system | Run discovery, pick direction skill, generate 12-section visual contract. Platform fills sections 13-17. |
| No DESIGN.md, one-off task | Do task, mention DESIGN.md once. |

**Do NOT write code yet.** Verify SPEC.md exists, invoke `planning-and-task-breakdown`. Only after plan is confirmed, proceed to BUILD.

#### 2C: Design Asset Lock (MANDATORY after visual approval)

Create `design/DESIGN-LOCK.md` (Direction, Palette, Typography, Decisions, References) + `design/approved/`. DESIGN-LOCK.md is a **snapshot** — never changes after approval. During BUILD, MUST re-read it before coding.

#### 2D: Lifecycle Awareness

Respect `AGENTS.md` lifecycle:
- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → Platform-specific skill + `incremental-implementation`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch`

---

### Phase 3 — Design Direction (Path B only)

Read `guides/DESIGN-CORE.md` for the universal Three Dials System (VARIANCE, MOTION, DENSITY), Brief Inference, color principles, and dark mode protocol.

Then apply the **platform-specific skill's DESIGN-GUIDE.md** for banned lists, font stacks, and tool-specific tokens.

Do not blend directions across platforms. Do not blend dial values.

---

### Phase 4 — Anti-Slop Principles

**Universal (read first):** See `guides/ANTI-SLOP-CORE.md` for the universal AI tell catalogue, content density rules, copy protocol, and UI state requirements.

**Platform-specific:** Then apply the platform skill's ANTI-SLOP-GUIDE.md for banned fonts, platform-specific layout tells, and stack-specific rules.

**Intentionality:** NO defaults without justification. Every choice has a reason.

**Tokens Over Hardcoding:** NO hardcoded values. All from DESIGN.md/theme. Used twice = must be a token.

**Performance:** NO convenience-over-performance tradeoffs. Measure: 60fps, fast loads, minimal bundles.

**Accessibility:** NOT optional. Always: 4.5:1 contrast, focus indicators, reduced motion. Accessibility is a gate.

---

### Phase 5 — Quality Gates

**Universal (run first):** See `guides/PRE-FLIGHT-CORE.md` for the universal pre-output checklist — color, content, motion, AI tells, accessibility, technical checks.

**Platform-specific:** Then run the platform skill's PRE-FLIGHT.md for build commands, layout verification, and native integration checks.

Before declaring complete:

1. **Contracts present** — SPEC.md and DESIGN.md exist and were read.
2. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
3. **No hardcoded tokens** — All colors, fonts, spacing from token system.
4. **Accessibility** — Contrast 4.5:1, focus indicators, reduced motion fallback.
5. **Build passes** — Compilation succeeds without errors.
6. **Visual consistency** — No design element deviates from DESIGN.md without explicit approval.

---

### Phase 5b — Error Path Design

Inspired by Harness Books: "Error paths are main paths." Every tool call, gate, loop, and session needs a failure path. See `references/ERROR-PATHS.md` for the full failure path matrix and anti-patterns.

---

### Phase 6 — Common Rationalizations

| Excuse | Reality |
|---|---|---|
| "Default for now." | #1 sign of AI slop. |
| "Too small for DESIGN.md." | Even 3 tokens help one-offs. |
| "Quality later." | Quality is a gate, not an afterthought. |
| "User didn't ask." | Senior engineers apply best practices by default. |
| "I remember design." | Context drifts. DESIGN-LOCK.md is ground truth. |
| "I know what they want." | 1% confidence. Discovery forces 95%. |

---

### Phase 7 — Red Flags

Code before requirements, assumptions unsurfaced, contracts skipped, hardcoded values, accessibility optional, DESIGN-LOCK.md stale, features not in spec.

---

## Platform Skill Template

Every platform skill follows `guides/PLATFORM-SKILL-TEMPLATE.md` — read it before creating.

---

---

### Phase 8 — Eval System Integration

All platform skills include eval files (trigger, golden, adversarial) to verify correct activation and output quality. The eval system follows Evaluation-Driven Development (EDD):

- **Trigger tests** — Does the skill fire when it should (and stay silent when it shouldn't)?
- **Golden tests** — Does the skill produce correct output against a rubric?
- **Adversarial tests** — Is the skill robust against rephrasing and edge cases?

→ See `docs/EVAL-GUIDE.md` for the complete eval system documentation.
→ Every generated skill must include eval cases (see `skill-creator`).

## Verification

SPEC.md with Objective/Scope/Stack/Acceptance/Boundaries. DESIGN.md with visual tokens. DESIGN-LOCK.md read before coding. Discovery done before code. User confirmed each gate. No hardcoded tokens. Accessibility (4.5:1 contrast, focus, reduced motion). Build passes. Eval cases present and passing.

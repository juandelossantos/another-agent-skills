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
2. If found → Read them. Present summary:
   ```
   📋 Contexto detectado:
   Proyecto: [Name from SPEC.md]
   Estado: [Phase: DEFINE/PLAN/BUILD/VERIFY/SHIP]
   Stack: [Locked stack]
   Última actualización: [Date]
   → ¿Continuamos donde lo dejamos?
   ```
3. If user says "continuamos" → Resume from detected phase. Re-read DESIGN-LOCK.md before BUILD.
4. If user says "empecemos de nuevo" → Archive old context (rename DESIGN-LOCK.md). Start fresh.
5. If DESIGN-LOCK.md > 7 days old → Ask: "¿Sigue vigente?"
6. If no context files → Treat as new project. Proceed normally.

**Never say "no recuerdo qué estábamos haciendo." Read the files.**

---

## Rule 1: Skills First

For EVERY request:
1. Determine if any skill applies (even 1% chance)
2. If yes → Invoke it using the `skill` tool
3. NEVER implement directly if a skill applies
4. ALWAYS follow the skill exactly

### Skill Hierarchy

| Layer | Skills | Purpose |
|---|---|---|
| **Foundation** | `engineering-fundamentals` | Discovery, contracts, anti-slop, gates |
| **Frontend** | `frontend-web`, `frontend-pwa`, `frontend-mobile` | Web, PWA, native mobile |
| **Backend** | `backend-api-mastery` | API, DB, auth |
| **DevOps** | `fullstack-shipping` | CI/CD, deploy |
| **Process** | `spec-driven-development`, `architecture-analysis` | Planning |
| **Quality** | `project-health-check`, `dev-environment-audit` | Auditing |
| **Metrics** | `project-metrics` | Quality logging (background) |

Platform skills are built on `engineering-fundamentals`. Never invoke `engineering-fundamentals` directly.

---

## Rule 2: Intent Mapping

**Detect platform BEFORE invoking frontend skill:**

| User says... | Platform | Skill |
|---|---|---|
| "web", "landing", "website", "Next.js", "React", "Vue" | Web | `frontend-web` |
| "PWA", "offline", "installable", "Capacitor", "Ionic", "hybrid" | Web → Native | `frontend-pwa` |
| "mobile app", "React Native", "Flutter", "iOS", "Android", "expo" | Mobile | `frontend-mobile` |
| "desktop", "Tauri", "Electron" | Desktop | `frontend-desktop` |
| "CLI", "command line", "terminal" | CLI | `cli-tools` |

**If platform unclear** → Ask: "¿Es para web, PWA, móvil, escritorio, o CLI?"

**If user has profile** → Use `preferences.primary_platform` + `preferences.mobile_approach` to default skill.

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

| Project | Required | Optional | Skipped |
|---|---|---|---|
| Landing page | spec, git-init, frontend-web | architecture (light) | backend-api |
| Web app | ALL | — | — |
| Mobile app | spec, git-init, frontend-mobile, backend (if API) | architecture (if complex) | — |
| API only | spec, git-init, architecture, backend, dev-env, shipping | — | frontend-* |
| Existing fix | health-check, spec, debugging | — | architecture, backend |
| Design system | spec, git-init, frontend, dev-env, shipping | architecture | backend-api |
| MVP/prototype | spec (turbo), git-init, frontend | — | architecture, backend (if no API) |

---

## Rule 4: Turbo Mode

**For trivial/prototype work. Reduces scope, NOT discipline.**

**Activate when:** User says "prototype", "MVP", "just sketch it", "prueba de concepto", or project is < 1 day, no persistence, single component.

**Reduces:** Research phase, extended discovery (10+ → 3 core questions), architecture analysis, Design Asset Lock (tokens only, no moodboard), dev-env audit (critical tools only).

**Never reduces:** SPEC.md (minimal but complete), `.gitignore`, `.env.example`, anti-slop rules, build verification, pre-commit checklist, no secrets committed.

**Anti-rationalization:**
| Excuse | Why Wrong |
|---|---|
| "Turbo = lazy" | No. It's scope calibration. A landing page needs less depth than e-commerce. |
| "Skip tests in Turbo" | No. Reduce test breadth, not test existence. Even a landing page gets a smoke test. |

---

## Rule 5: Stack Agnosticism

**Default:** React/Next.js/Tailwind (web), React Native/Expo (mobile), Tauri/Rust (desktop).

**Adapt when user specifies otherwise:**
1. Read `SPEC.md` Tech Stack
2. If Vue/Svelte/Angular/Python/Go/Rust/Flutter/SwiftUI:
   - Use `frontend-web/mobile` for principles. Adapt code examples.
   - Use `backend-api-mastery` for protocol/auth. Adapt ORM examples.
   - Use `architecture-analysis` for patterns (language-agnostic).
3. Create `STACK_CONFIG.md` documenting chosen stack.

---

## Rule 6: Lazy Loading

**Skills load on-demand, not eagerly.**

**How it works:**
1. **Skill as Index** (~200 lines max): When to use, stack lock-in, phase summaries, QA gates.
2. **Guides as Lazy Content**: Loaded only when phase reached.
   - `DISCOVERY-GUIDE.md` → Phase 1
   - `PROTOCOL-GUIDE.md` → Phase 3
   - `AUTH-GUIDE.md` → Phase 5
   - `ANIMATION-GUIDE.md` → Animation phase
   - `TESTING-GUIDE.md` → Testing phase
   - `EXAMPLES.md` → Troubleshooting
3. **Foundation loaded once**: `engineering-fundamentals` implicit. Not duplicated.

**Verification:**
- [ ] Every skill < 250 lines
- [ ] Every skill references ≥ 2 guides
- [ ] Guides exist as separate files
- [ ] No detail duplicated between SKILL.md and guides
- [ ] `engineering-fundamentals` not duplicated in platform skills

**Anti-rationalization:** "User needs to see everything." → NO. Agent loads guides on-demand. User never sees loading — only relevant instructions at the right time.

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

**Compaction rules (history > 20 messages):**
- Keep: Errors and solutions, architecture decisions, approved design tokens, current code
- Remove: Successful build outputs (keep pass/fail only), "ok"/"proceede"/"entendido" messages, repeated instructions

---

## Rule 9: Verification

Before marking any task complete:
- [ ] Applicable skill was invoked
- [ ] Skill workflow followed completely
- [ ] Required artifacts (specs, plans, tests) exist
- [ ] User confirmed at each gate (or Turbo Mode activated)
- [ ] `.gitignore` covers project's stack
- [ ] No `.env` or secrets committed
- [ ] Build passes (`npm run build` or equivalent)
- [ ] No hardcoded tokens outside design system

---

## Rule 10: Language Compliance

Detect language from user's prompt:
- Spanish keywords ("haz", "diseña", "crea") → **Spanish**
- English keywords ("build", "design", "create") → **English**
- Other → That language, fallback to English

**Never mix languages.** All questions, specs, and code comments match detected language.

---

## Rule 11: Development Artifacts Convention

When working on this repository (`another-agent-skills`):

**ALL draft, analysis, review, simulation, audit, roadmap, and refinement files MUST be created in `development/`.**

**Examples:**
- `development/SESSION_CONTEXT.md` — Session continuity
- `development/SIMULATION.md` — Test simulations
- `development/AUDIT_*.md` — Architecture audits
- `development/REVIEW_*.md` — Code/quality reviews
- `development/ROADMAP_*.md` — Planning documents
- `development/TOKEN_OPTIMIZATION.md` — Compression guides

**Never** create these files in the repo root or `skills/` folders.

**`.gitignore`**: `development/` is ignored globally. Files there stay local only.

---

## Anti-Rationalization (Universal)

| Wrong Thought | Why It's Wrong |
|---|---|
| "This is too small for a skill." | Skills exist for structured thinking. |
| "I can just quickly implement this." | Check skills first. |
| "I'll gather context first." | Invoke the skill. It tells you what context to gather. |
| "The user didn't ask for a spec." | The skill decides what the project needs. |
| "I understand what they want." | You have 1% confidence. The skill forces 95%. |
| "Turbo mode means skip everything." | No. Skip OPTIONAL phases, not mandatory ones. |
| "The user chose a different stack, I can't help." | Principles are universal. Examples are specific. |
| "I'll add [quality] later." | Quality is a gate, not an afterthought. Add it now. |
| "The user is impatient, I'll skip [phase]." | The user will be more impatient when the result doesn't match expectations. |
| "I remember the design, I don't need to read files again." | Agent context drifts. Files are ground truth. |

---

## Skill Discovery

Skills loaded from:
- Project: `.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`

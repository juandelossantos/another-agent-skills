# AGENTS.md

## Skill-Driven Execution Model (MANDATORY)

This project uses a **skill-driven workflow**. You MUST follow these rules for every request.

---

## Rule 0: User Profile Verification (NEW — Runs Before Everything)

**Before ANY other skill is invoked, verify the user has a profile:**

1. **Check for `~/.config/opencode/user-profile.json`**
   - Exists and < 90 days old → Read it. Use preferences to personalize all subsequent interactions.
   - Missing or > 90 days old → **Execute `user-onboarding`** before proceeding with the user's request.

2. **The user does NOT need to ask for onboarding.**
   - This is automatic. The agent detects missing/stale profile and runs it.
   - The user only sees: "Veo que es tu primera vez / tu perfil está desactualizado. Voy a hacerte unas preguntas rápidas para personalizar mi ayuda."

3. **After onboarding completes, resume the original user request** with the new profile loaded.

**Why this matters:** Without a profile, the agent asks "¿React o Vue?" in every project. With a profile, it says "Veo que prefieres Vue — ¿confirmas para este proyecto?"

---

## Rule 0b: Context Persistence (NEW — Runs on Every Session Start)

**When entering a directory with an existing project, auto-recover context before the user asks.**

1. **Check for project context files (in order):**
   ```
   Check for any of these files in the working directory:
   - design/DESIGN-LOCK.md        ← Visual decisions snapshot
   - SPEC.md                      ← Technical specification
   - architecture/ARCHITECTURE.md ← Architecture decisions
   - API-DESIGN.md               ← API contract (if backend)
   - HEALTH-CHECK.md             ← Last audit date
   - docs/DEV-ENVIRONMENT.md     ← Environment setup
   ```

2. **If context files exist:**
   - Read them. Extract: project name, current phase, last decisions, locked stack.
   - Present a **Context Summary** to the user BEFORE they make any new request:
     ```
     📋 Contexto detectado del proyecto:

     Proyecto: [Nombre extraído de SPEC.md]
     Estado: [Fase actual: DEFINE / PLAN / BUILD / VERIFY / SHIP]
     Stack: [Stack lock-in]
     Última actualización: [Fecha del DESIGN-LOCK.md o último commit]

     Decisiones clave:
     - [Dirección visual]: [Aesthetic ID]
     - [Stack]: [Framework + versión]
     - [Fase actual]: [Qué estábamos construyendo]

     → ¿Continuamos donde lo dejamos, o quieres cambiar algo?
     ```

3. **If user says "continuamos" / "sí" / "procede":**
   - Resume from the detected phase.
   - Re-read `design/DESIGN-LOCK.md` immediately before any BUILD action.
   - Do NOT re-run discovery unless user explicitly requests changes.

4. **If user says "empecemos de nuevo" / "olvidé todo" / "nuevo proyecto":**
   - Ask for confirmation: "¿Borro el contexto anterior y empezamos desde cero?"
   - If confirmed: Archive old context (rename `design/DESIGN-LOCK.md` to `design/DESIGN-LOCK-ARCHIVED-[date].md`).
   - Start fresh: Run `spec-driven-development` from Phase 0.

5. **If no context files exist:**
   - Treat as new project. Proceed with normal lifecycle (DEFINE → PLAN → BUILD).
   - Do NOT mention context persistence to the user.

**Critical rules:**
- Context recovery is SILENT if successful. The user only sees the summary.
- Never say "no recuerdo qué estábamos haciendo." The agent reads the files.
- If DESIGN-LOCK.md is > 7 days old, mention it: "El diseño fue aprobado hace [N] días. ¿Sigue vigente?"
- If HEALTH-CHECK.md is > 7 days old, re-run `project-health-check` before BUILD.

**Why this matters:** Multi-session projects are the norm, not the exception. Without context persistence, the user repeats decisions every session. With it, the agent says "Continuamos con el Hero que estábamos animando" instead of "¿Qué quieres construir?"

---

## Rule 1: Always Check Skills First

For EVERY user request:
1. Determine if any global skill applies (even 1% chance)
2. If a skill applies, you MUST invoke it using the `skill` tool
3. NEVER implement directly if a skill applies
4. ALWAYS follow the skill instructions exactly

### Skill Hierarchy

All platform-specific skills (frontend-web, frontend-pwa, frontend-mobile, backend-api-mastery, etc.) are **built on `engineering-fundamentals`**. When you invoke any platform skill, the fundamentals are implicitly applied. You do NOT need to invoke `engineering-fundamentals` separately.

| Layer | Skills | Purpose |
|---|---|---|
| **Foundation** | `engineering-fundamentals` | Universal philosophy: discovery, contracts, anti-slop, quality gates |
| **Frontend** | `frontend-web`, `frontend-pwa`, `frontend-mobile` | Web, installable web, and native mobile implementation |
| **Backend** | `backend-api-mastery` | API, database, auth design |
| **DevOps** | `fullstack-shipping` | CI/CD, deployment, monitoring |
| **Process** | `spec-driven-development`, `architecture-analysis` | Planning and decision-making |
| **Quality** | `project-health-check`, `dev-environment-audit` | Auditing and environment setup |

---

## Rule 2: Skill Discovery

Skills are loaded from:
- Project: `.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`

---

## Rule 3: Intent Mapping (Updated — Multi-Platform)

Map user intent to skills automatically. **Platform detection is mandatory.**

**Step 1: Detect Platform**
Before invoking any frontend skill, determine the target platform:

| User says... | Platform | Skill to invoke |
|---|---|---|
| "web", "landing page", "website", "Next.js", "React", "Vue", "site", "web app" (simple) | Web | `frontend-web` |
| "PWA", "offline app", "installable", "Capacitor", "Ionic", "hybrid app", "web app" (future native) | Web → Native bridge | `frontend-pwa` |
| "mobile app", "app móvil", "React Native", "Flutter", "iOS", "Android", "expo", "native app" | Mobile native | `frontend-mobile` |
| "desktop app", "desktop", "Tauri", "Electron", "Windows app", "Mac app" | Desktop | `frontend-desktop` |
| "CLI", "command line", "terminal", "tool" | CLI | `cli-tools` |

**If platform is unclear:** Ask: "¿Es para web, web app installable (PWA), app móvil nativa, escritorio, o CLI? / Is this for web, installable web app (PWA), native mobile, desktop, or CLI?"

**If user has a profile:** Read `user-profile.json` first. Use `preferences.primary_platform` + `preferences.mobile_approach` to default the correct skill.

**Step 2: Invoke Platform-Specific Skill**

| User says... | Skill to invoke |
|---|---|---|
| "first time", "setup my preferences", "remember my stack", "my defaults", "user profile" | `user-onboarding` |
| "git init", "setup repo", "create repository", "version control", "git setup", "mono repo", "multi repo" | `git-init-and-versioning` |
| "check project", "audit", "health check", "technical debt", "what needs fixing" | `project-health-check` |
| "plan", "break down", "organize" | `planning-and-task-breakdown` |
| "bug", "fix", "error", "broken", "not working" | `debugging-and-error-recovery` |
| "test", "testing", "TDD" | `test-driven-development` |
| "review", "check quality", "refactor" | `code-review-and-quality` |
| "deploy", "ship", "launch", "CI/CD", "build pipeline", "testing strategy", "production", "release", "go live", "monitoring", "rollback", "staging" | `fullstack-shipping` |
| "spec", "specification", "design doc", "requirements" | `spec-driven-development` |
| "architecture", "stack", "what framework", "MVC or", "microservices", "monolith", "pattern", "how to structure" | `architecture-analysis` |
| "security", "auth", "vulnerability", "harden" | `security-and-hardening` |
| "setup", "environment", "tools", "MCPs", "what do I need to install", "prepare workspace", "dev tools", "prerequisites" | `dev-environment-audit` |
| "API", "backend", "database", "auth", "endpoint", "REST", "GraphQL", "Prisma", "Drizzle", "tRPC", "server", "create API", "design API" | `backend-api-mastery` |

---

## Rule 4: Lifecycle Enforcement (Updated — Multi-Platform)

For any non-trivial work, follow this lifecycle:

```
DEFINE  → project-health-check (if existing code)
        → spec-driven-development (always)
        → architecture-analysis (if non-trivial)
        → backend-api-mastery (if API needed)
        → frontend-[platform] Discovery (if UI needed: web/mobile/desktop/cli)
        → git-init-and-versioning (once per project, after contracts locked)

PLAN    → planning-and-task-breakdown

BUILD   → incremental-implementation
        → test-driven-development
        → code-review-and-quality (via pre-commit checklist in git-init)
        → git-workflow-and-versioning (commits)

VERIFY  → debugging-and-error-recovery

REVIEW  → code-review-and-quality

SHIP    → shipping-[platform] (web/mobile/desktop/cli)
```

**Skill composition by project type:**

| Project Type | Platform | Required Skills | Optional Skills | Skipped |
|---|---|---|---|---|
| **Landing page** | Web | spec, git-init, frontend-web, shipping-web | architecture (light), dev-env | backend-api |
| **Web app** | Web | ALL skills | — | — |
| **Mobile app** | Mobile | spec, git-init, frontend-mobile, backend-api (if API), shipping-mobile | architecture (if complex) | — |
| **Desktop app** | Desktop | spec, git-init, frontend-desktop, shipping-desktop | architecture (if complex) | backend-api (if no API) |
| **API only** | — | spec, git-init, architecture, backend, dev-env, shipping | — | frontend-* |
| **Existing project fix** | Any | project-health-check, spec (if undocumented), debugging | — | architecture, backend, frontend (if UI untouched) |
| **Design system** | Any | spec, git-init, frontend-[platform], dev-env, shipping | architecture | backend-api |
| **MVP / prototype** | Any | spec (turbo), git-init, frontend-[platform] | — | architecture, backend-api (if no API) |

---

## Rule 5: Turbo Mode (NEW)

For trivial, explicitly prototype, or scope-limited work, use **Turbo Mode**:

**When to activate:**
- User explicitly says "prototype", "MVP", "just sketch it", "prueba de concepto"
- Project is < 1 day of work
- No persistence needed (no database, no auth)
- Single page/component
- User explicitly requests: "skip the questions and build"

**Critical distinction:** Turbo Mode does NOT sacrifice quality. It reduces **scope**, not **discipline**.

**What Turbo Mode reduces (scope):**
- Research phase (Phase 1 of spec-driven-development) — not needed for simple CRUD
- Extended discovery — 10+ questions → 3 core questions (objective, scope, constraints)
- Architecture analysis — assume standard stack (documented in SPEC.md)
- Design Asset Lock — minimal DESIGN.md (tokens only, no moodboard)
- Dev environment audit — check only critical tools (Node.js, Git)

**What Turbo Mode NEVER reduces (quality):**
- SPEC.md must still exist (minimal but complete)
- `.gitignore` and `.env.example` are still mandatory
- Anti-AI-slop rules still apply (no Inter, no generics)
- Build verification (`npm run build` must pass)
- Pre-commit checklist still runs (correctness, security, git hygiene)
- No secrets ever committed

**What Turbo Mode produces:**
- A smaller, simpler project with the same engineering discipline
- Fewer sections (e.g., Hero + CTA instead of Hero + Value Prop + Services + Testimonials + CTA)
- Standard stack instead of evaluated options
- Minimal tests instead of full coverage suite

**Anti-rationalization:**
| Excuse | Why It's Wrong |
|---|---|
| "Turbo mode is just lazy." | No. It's scope calibration. A landing page doesn't need the same depth as an e-commerce platform. |
| "Turbo mode means skip quality." | No. It means build a smaller house with the same foundation quality. |
| "The user said 'quick' but they actually want production." | If unclear, ask: "¿Es un prototipo para validar o producto final?" |
| "I'll skip tests in Turbo Mode." | No. Turbo Mode reduces test breadth, not test existence. Even a landing page gets a smoke test. |

---

## Rule 6: Stack Agnosticism (NEW)

Our skills default to **React/Next.js/TypeScript/Tailwind** for web, **React Native/Expo** for mobile, **Tauri/Rust** for desktop, but MUST adapt when the user specifies otherwise.

**How to adapt:**
1. Read `SPEC.md` Tech Stack section
2. If user chose Vue, Svelte, Angular, Python, Go, Rust, Flutter, SwiftUI, etc.:
   - Use `frontend-web` for web principles (anti-slop, tokens, animation) but adapt code examples
   - Use `frontend-mobile` for mobile principles (anti-slop, tokens, animation) but adapt code examples
   - Use `frontend-desktop` for desktop principles (anti-slop, tokens, animation) but adapt code examples
   - Use `backend-api-mastery` for protocol/auth decisions but adapt ORM/database examples
   - Use `architecture-analysis` for pattern decisions (applies to any language)
3. Create `STACK_CONFIG.md` in project root documenting the chosen stack

**Stack Config Template:**
```markdown
# Stack Configuration

**Chosen by user on YYYY-MM-DD:**
- Platform: [Web / Mobile / Desktop / CLI]
- Frontend: [React 19 / Vue 3 / React Native 0.76 / Flutter 3 / Tauri 2 / etc.]
- Backend: [FastAPI / Django / Express / etc.]
- Database: [PostgreSQL / MongoDB / SQLite]
- Styling: [Tailwind / CSS Modules / StyleSheet / ThemeData / etc.]
- Animation: [Framer Motion / Reanimated / Flutter Animated / etc.]

**Adaptations from default skills:**
- frontend-web: Using Vue Composition API instead of React hooks
- frontend-mobile: Using Flutter instead of React Native
- backend-api-mastery: Using FastAPI instead of Next.js API routes
- Architecture: Clean Architecture instead of MVC
```

---

## Rule 6b: Skill Lazy Loading (NEW)

Skills MUST be designed for on-demand loading, not eager loading.

**Why this matters:** When an agent invokes `skill:frontend-web`, it loads the entire SKILL.md into context. If every skill is 400+ lines, the agent loses thousands of tokens that could be used for code/analysis.

**How it works:**

1. **Skill as Index** (~200 lines max):
   - Contains: When to use, stack lock-in, summary of each phase, QA gates
   - References: Detailed guides with "Read `GUIDE-NAME.md` for complete implementation"
   - Does NOT contain: Full discovery questions, detailed protocol matrices, complete testing strategies

2. **Guides as Lazy Content** (loaded on-demand):
   - `DISCOVERY-GUIDE.md` — loaded only when Phase 1 is reached
   - `PROTOCOL-GUIDE.md` — loaded only when Phase 3 is reached
   - `AUTH-GUIDE.md` — loaded only when Phase 5 is reached
   - `ANIMATION-GUIDE.md` — loaded only when animation phase is reached
   - `TESTING-GUIDE.md` — loaded only when testing phase is reached
   - `EXAMPLES.md` — loaded only when troubleshooting

3. **Foundation loaded once**:
   - `engineering-fundamentals` is implicit for all skills
   - Not duplicated in every skill

**Verification:**
- [ ] Every skill is < 250 lines
- [ ] Every skill references at least 2 guides
- [ ] Guides exist as separate files
- [ ] No implementation detail duplicated between SKILL.md and guides
- [ ] `engineering-fundamentals` is not duplicated in platform skills

**Anti-rationalization:** "The user needs to see everything at once." → NO. The agent loads guides on-demand as phases are reached. Context is preserved. The user never sees the loading — they only see the relevant instructions at the right time.
- backend-api-mastery: Using FastAPI instead of Next.js API routes
- Architecture: Clean Architecture instead of MVC
```

---

## Rule 7: Anti-Rationalization

These thoughts are WRONG. Ignore them:

- "This is too small for a skill" → NO. Skills exist precisely for structured thinking.
- "I can just quickly implement this" → NO. Check skills first.
- "I'll gather context first" → NO. Invoke the skill. It will tell you what context to gather.
- "The user didn't ask for a spec" → NO. The skill decides what the project needs.
- "I understand what they want" → NO. You have 1% confidence. The skill forces 95% confidence.
- "Turbo mode means skip everything" → NO. It means skip OPTIONAL phases, not mandatory ones.
- "The user chose a different stack, I can't help" → NO. Principles are universal; examples are specific.

---

## Rule 8: Language Compliance

Detect the user's language from their prompt:
- Spanish prompt ("haz", "diseña", "crea") → Respond in Spanish
- English prompt ("build", "design", "create") → Respond in English
- Never mix languages.

---

## Rule 9: No Code Before Contract (Updated)

**UNIVERSAL RULE:** No file is created until:
- SPEC.md exists (for new features)
- For UI work: DESIGN.md exists or is confirmed as one-off
- For backend work: API-DESIGN.md exists or is confirmed as simple CRUD
- `.gitignore` exists (prevents accidental commits of secrets/build outputs)

**Exception (Turbo Mode):**
- Minimal SPEC.md (2-3 lines) sufficient
- Minimal `.gitignore` (Node.js/Python/Rust template) sufficient

---

## Rule 10: Verification

Before marking any task complete:
- [ ] The applicable skill was invoked
- [ ] The skill's workflow was followed completely
- [ ] Required artifacts (specs, plans, tests) exist
- [ ] User confirmed at each gate (or Turbo Mode was explicitly activated)
- [ ] `.gitignore` covers the project's stack
- [ ] No `.env` or secrets committed

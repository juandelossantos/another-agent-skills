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

## Rule 1: Always Check Skills First

For EVERY user request:
1. Determine if any global skill applies (even 1% chance)
2. If a skill applies, you MUST invoke it using the `skill` tool
3. NEVER implement directly if a skill applies
4. ALWAYS follow the skill instructions exactly

---

## Rule 2: Skill Discovery

Skills are loaded from:
- Project: `.opencode/skills/<name>/SKILL.md`
- Global: `~/.config/opencode/skills/<name>/SKILL.md`
- Claude-compatible: `.claude/skills/<name>/SKILL.md` or `~/.claude/skills/<name>/SKILL.md`

---

## Rule 3: Intent Mapping

Map user intent to skills automatically:

| User says... | Skill to invoke |
|---|---|
| "build", "create", "haz", "diseña", "crea", "desarrolla" + any web/UI/app | `visual-frontend-mastery` |
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

## Rule 4: Lifecycle Enforcement (Updated)

For any non-trivial work, follow this lifecycle:

```
DEFINE  → project-health-check (if existing code)
        → spec-driven-development (always)
        → architecture-analysis (if non-trivial)
        → backend-api-mastery (if API needed)
        → visual-frontend-mastery Discovery (if UI needed)
        → git-init-and-versioning (once per project, after contracts locked)

PLAN    → planning-and-task-breakdown

BUILD   → incremental-implementation
        → test-driven-development
        → code-review-and-quality (via pre-commit checklist in git-init)
        → git-workflow-and-versioning (commits)

VERIFY  → debugging-and-error-recovery

REVIEW  → code-review-and-quality

SHIP    → fullstack-shipping
```

**Skill composition by project type:**

| Project Type | Required Skills | Optional Skills | Skipped |
|---|---|---|---|
| **Landing page (simple)** | spec, git-init, visual, shipping | architecture (light), dev-env | backend-api |
| **Web app (fullstack)** | ALL 8 skills | — | — |
| **API only** | spec, git-init, architecture, backend, dev-env, shipping | — | visual |
| **Existing project fix** | project-health-check, spec (if undocumented), debugging | — | architecture, backend, visual (if UI untouched) |
| **Design system** | spec, git-init, visual, dev-env, shipping | architecture | backend-api |
| **MVP / prototype** | spec (turbo), git-init, visual | — | architecture, backend-api (if no API) |

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

Our skills default to **React/Next.js/TypeScript/Tailwind** but MUST adapt when the user specifies otherwise.

**How to adapt:**
1. Read `SPEC.md` Tech Stack section
2. If user chose Vue, Svelte, Angular, Python, Go, Rust, etc.:
   - Use `visual-frontend-mastery` for principles (anti-slop, tokens, animation) but adapt code examples
   - Use `backend-api-mastery` for protocol/auth decisions but adapt ORM/database examples
   - Use `architecture-analysis` for pattern decisions (applies to any language)
3. Create `STACK_CONFIG.md` in project root documenting the chosen stack

**Stack Config Template:**
```markdown
# Stack Configuration

**Chosen by user on YYYY-MM-DD:**
- Frontend: [Vue 3 / SvelteKit / Angular / etc.]
- Backend: [FastAPI / Django / Express / etc.]
- Database: [PostgreSQL / MongoDB / SQLite]
- Styling: [Tailwind / CSS Modules / Styled Components]
- Animation: [Framer Motion / GSAP / CSS animations]

**Adaptations from default skills:**
- visual-frontend-mastery: Using Vue Composition API instead of React hooks
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

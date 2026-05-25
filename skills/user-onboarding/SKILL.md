---
name: user-onboarding
description: >
  Capture user preferences once and persist them across all projects.
  Runs automatically on first interaction or when no user profile exists.
  Creates ~/.config/opencode/user-profile.json used by all skills to personalize
  discovery, recommendations, and defaults. Triggers on: first session, "setup my
  preferences", "remember my stack", "my defaults", "user profile".
license: MIT
compatibility: opencode
metadata:
  audience: all-users
  workflow: discover-persist-reuse
---

# User Onboarding

**Ask once. Remember forever.**

This skill eliminates repetitive discovery questions by capturing the user's
preferences, constraints, and context at the beginning of their relationship
with the agent. Every subsequent project reads `user-profile.json` and adapts
its defaults, suggestions, and questions accordingly.

## When to Use

**MANDATORY** when:
- This is the first session with a new user
- No `~/.config/opencode/user-profile.json` exists
- The user explicitly says "setup my preferences", "remember my stack", "configure defaults"

**Runs automatically** when:
- Any skill detects that `user-profile.json` is missing and asks a discovery question

**When NOT to use:**
- `user-profile.json` exists and is < 90 days old
- The user explicitly says "skip preferences, just build"
- Turbo Mode is activated and user-profile exists

---

## Core Process

### Phase 0 — Detect Profile

1. **Check for `~/.config/opencode/user-profile.json`:**
   - Exists and < 90 days old → Read it, skip to Phase 3 (Quick Verify)
   - Exists but > 90 days old → Read it, ask "¿Quieres actualizar tu perfil?"
   - Missing → Full onboarding required

2. **Check for stale preferences:**
   - If profile mentions technologies that are now outdated (e.g., Next.js 14 when current is 16), suggest update.

---

### Phase 1 — Discovery Interview (Full Onboarding)

**Ask these questions once. Store answers permanently.**

#### Section A: Identity & Context

1. **Name / Team**: ¿Cómo te llamas? ¿Trabajas solo o en equipo?
2. **Role**: ¿Eres desarrollador, diseñador, product manager, emprendedor?
3. **Industry**: ¿En qué industria trabajas? (tech, hospitality, fintech, healthcare, education, etc.)
4. **Experience level**: ¿Cuántos años de experiencia tienes programando? (0-1, 1-3, 3-5, 5-10, 10+)

#### Section B: Technical Preferences

5. **Primary language**: ¿Prefieres Spanish o English para comunicación conmigo?
6. **Frontend stack**: ¿Prefieres React, Vue, Svelte, Angular, o te da igual?
7. **Backend stack**: ¿Prefieres Node.js, Python, Go, Rust, o te da igual?
8. **CSS approach**: ¿Prefieres Tailwind, CSS Modules, Styled Components, SCSS?
9. **Database**: ¿Prefieres PostgreSQL, MySQL, MongoDB, SQLite, o te da igual?
10. **Deployment**: ¿Prefieres Vercel, Netlify, AWS, self-hosted, o te da igual?

#### Section C: Design Preferences

11. **Design aesthetic**: ¿Prefieres minimalista, moderno, clásico, juguetón, corporativo?
12. **Color preference**: ¿Prefieres oscuro, claro, o mixto (dark mode)?
13. **Typography**: ¿Te importa mucho la tipografía o prefieres que yo elija?
14. **Animation**: ¿Prefieres mucha animación, moderada, o casi ninguna?

#### Section D: Workflow Preferences

15. **Communication style**: ¿Prefieres que sea directo/conciso o detallado/explicativo?
16. **Decision style**: ¿Prefieres que proponga opciones y elijas, o que decida por ti con justificación?
17. **Code review**: ¿Quieres que revisemos cada commit juntos, o confías en el auto-review?
18. **Documentation**: ¿Prefieres mucha documentación o lo mínimo necesario?

#### Section E: Constraints & Context

19. **Budget**: ¿Proyectos personales, startup, o enterprise? (afecta recomendaciones de hosting/tools)
20. **Time pressure**: ¿Usualmente tienes deadlines ajustados o tiempo de sobra?
21. **Open source**: ¿Sueles open-sourcear proyectos? (afecta licencias y configuración)
22. **Accessibility priority**: ¿El accesibilidad es crítica, importante, o nice-to-have para ti?

---

### Phase 2 — Persist & Lock

**Save to `~/.config/opencode/user-profile.json`:**

```json
{
  "version": "1.0",
  "created_at": "2026-05-24",
  "updated_at": "2026-05-24",
  "identity": {
    "name": "Juan",
    "role": "developer",
    "industry": "fintech",
    "experience_years": "3-5",
    "team_size": "solo"
  },
  "preferences": {
    "language": "es",
    "frontend_stack": "react",
    "backend_stack": "nodejs",
    "css_approach": "tailwind",
    "database": "postgresql",
    "deployment": "vercel"
  },
  "design": {
    "aesthetic": "minimalist",
    "color_preference": "dark",
    "typography_care": "high",
    "animation_level": "moderate"
  },
  "workflow": {
    "communication_style": "detailed",
    "decision_style": "propose_options",
    "commit_review": "auto_review_with_approval",
    "documentation_level": "comprehensive"
  },
  "constraints": {
    "budget_context": "startup",
    "time_pressure": "moderate",
    "open_source": false,
    "accessibility_priority": "important"
  }
}
```

**Rules:**
- Never include secrets, API keys, or sensitive data.
- Update `updated_at` on any preference change.
- Version the schema for backward compatibility.

---

### Phase 3 — Quick Verify (if profile exists)

If `user-profile.json` exists and is recent:

```
PROFILE DETECTED:

Name: Juan | Role: Developer | Industry: Fintech
Stack: React + Node.js + PostgreSQL + Vercel
Design: Minimalista, dark mode, animación moderada
Communication: Detallado, propone opciones

→ ¿Siguen siendo correctas estas preferencias? (yes/sí)
→ ¿Quieres actualizar algo? (responde con el número de la sección)
```

---

## How Other Skills Use This Profile

### Example: `visual-frontend-mastery`

**Without profile:**
> "¿Qué stack prefieres? React, Vue, Svelte...?"

**With profile (React + Tailwind + dark mode + minimalist):**
> "Veo que prefieres React + Tailwind. Para este proyecto, sugiero dark mode minimalista. ¿Confirmas o quieres explorar otras opciones?"

### Example: `architecture-analysis`

**Without profile:**
> "¿Qué backend prefieres? Node, Python, Go...?"

**With profile (Node.js + PostgreSQL + Vercel):**
> "Basado en tu perfil (Node.js + PostgreSQL + Vercel), propongo:
> - Opción A: Next.js fullstack (Vercel, tu preferencia)
> - Opción B: Decoupled (Node + Express)
> - Opción C: Serverless (Cloudflare Workers)
> ¿Quieres revisar estas opciones o prefieres que profundice en una?"

### Example: `spec-driven-development`

**Without profile:**
> "¿Cuál es tu experiencia? ¿Qué industria?"

**With profile:**
> "Sé que eres developer en fintech con 3-5 años. Voy a asumir que necesitas compliance básico y seguridad robusta. ¿Correcto?"

---

## Updating Preferences

**User says:** *"Ahora uso Vue en lugar de React"*

**Agente:**
1. Update `user-profile.json` → `preferences.frontend_stack = "vue"`
2. Confirm: "He actualizado tu perfil. Ahora asumiré Vue para futuros proyectos."
3. Ask: "¿Quieres que adapte este proyecto actual a Vue, o solo aplica para futuros?"

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just ask every time." | Repetitive questions waste time and frustrate users. A saved profile makes every interaction faster. |
| "The user might change their mind." | That's why we have Quick Verify and easy updates. The profile is a default, not a prison. |
| "What if multiple people use the same machine?" | Support multiple profiles: `user-profile-juan.json`, `user-profile-maria.json`. Ask "¿Quién eres?" on first session. |
| "This is just bureaucracy." | 3 minutes of onboarding saves 10+ minutes of repeated questions per project. |

---

## Red Flags

- The agent asks "¿React o Vue?" when `user-profile.json` already specifies.
- The agent ignores the user's stated preference and defaults to its own.
- The profile contains secrets or API keys.
- The profile is never updated even after the user changes preferences.

---

## Verification

Before any skill runs discovery, confirm:
- [ ] Checked for `~/.config/opencode/user-profile.json`
- [ ] If exists: Used it to personalize defaults and skip redundant questions
- [ ] If missing: Ran full onboarding
- [ ] If outdated: Offered update
- [ ] Never stored secrets in the profile

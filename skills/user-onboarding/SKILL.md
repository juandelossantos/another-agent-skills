---
name: user-onboarding
description: >
  Capture user preferences once, persist across all projects.
  Creates ~/.config/opencode/user-profile.json used by all skills to personalize
  discovery, recommendations, and defaults. Triggers on: first session,
  "setup preferences", "remember my stack", "my defaults", "user profile".
license: MIT
compatibility: opencode
metadata:
  audience: all-users
  workflow: discover-persist-reuse
---

# User Onboarding

**Ask once. Remember forever.**

Captures user preferences, constraints, context. Eliminates repetitive discovery. Subsequent projects read `user-profile.json` and adapt defaults, suggestions, questions.

## When to Use

**AUTO-DETECTED — User never needs to ask.**

**Runs automatically when:**
- Any skill starts and no `~/.config/opencode/user-profile.json`
- `user-profile.json` > 90 days old
- User says "setup preferences", "remember stack", "configure defaults"

**Skip when:** Profile exists and < 90 days old. User says "skip" AND profile exists. Turbo Mode + profile exists.

**How it works:**
```
User: "Crea una landing page"
Agent: [checks profile] → NOT FOUND
Agent: "Primera vez. Preguntas rápidas para personalizar ayuda."
→ Runs user-onboarding → Saves profile → Resumes original request
```

---

## Core Process

### Phase 0 — Detect Profile

1. **Check `~/.config/opencode/user-profile.json`:**
   - <90 days → Read, skip to Phase 3 (Quick Verify)
   - >90 days → Read, ask "¿Actualizar perfil?"
   - Missing → Full onboarding

2. **Check stale preferences:** Mentioned technologies outdated (e.g., Next.js 14 when current is 16)? Suggest update.

---

### Phase 1 — Discovery Interview (Full Onboarding)

→ **See `ONBOARDING-QUESTIONS-GUIDE.md` for complete 27-question interview (5 sections: Identity, Technical, Design, Workflow, Constraints).**

Summary: 27 questions covering identity, technical preferences (platform, framework, stack), design taste, workflow style, constraints.

**Rules:**
- Ask once. Store permanently.
- Never include secrets, API keys, or sensitive data.
- Update `updated_at` on any change.
- Version schema for backward compatibility.

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
    "primary_platform": "web",
    "web_framework": "react",
    "mobile_approach": null,
    "desktop_framework": null,
    "backend_stack": "nodejs",
    "styling_approach": "tailwind",
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
    "context_persistence": true,
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

---

### Phase 3 — Quick Verify (if profile exists)

```
PROFILE DETECTED:

Name: Juan | Role: Developer | Industry: Fintech
Platform: Web (React) + Node.js + PostgreSQL + Vercel
Design: Minimalista, dark mode, animación moderada
Communication: Detallado, propone opciones

→ ¿Siguen siendo correctas? (yes/sí)
→ ¿Actualizar algo? (responde con número de sección)
```

---

## How Other Skills Use This Profile

→ **See `USAGE-EXAMPLES-GUIDE.md` for 5 skill-specific examples and preference update workflow.**

**Without profile:** "¿React o Vue? ¿Qué stack?"

**With profile:** "Veo que prefieres React + Tailwind. ¿Confirmas para este proyecto?"

---

## Common Rationalizations

| Excuse | Response |
|---|---|
| "Ask every time." | Repetitive questions waste time. Saved profile makes every interaction faster. |
| "User might change mind." | Quick Verify and easy updates exist. Profile is default, not prison. |
| "Multiple people, same machine." | Support multiple profiles: `user-profile-juan.json`, `user-profile-maria.json`. |
| "Just bureaucracy." | 3 minutes onboarding saves 10+ minutes repeated questions per project. |

---

## Red Flags

- Asks "¿React o Vue?" when profile already specifies.
- Ignores user preference, defaults to agent's own.
- Profile contains secrets or API keys.
- Profile never updated even after user changes preferences.

---

## Verification

Before any skill runs discovery:
- [ ] Checked `~/.config/opencode/user-profile.json`
- [ ] If exists: Used to personalize and skip redundant questions
- [ ] If missing: Ran full onboarding
- [ ] If outdated: Offered update
- [ ] Never stored secrets in profile

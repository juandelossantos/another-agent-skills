# Visual Frontend Mastery — Discovery Guide

This guide contains the complete Phase 1 Discovery Gate for `visual-frontend-mastery`.

Execute every step. Do not skip. Do not assume.

---

## Step 1: Surface Assumptions

List at least 5 assumptions you are making about the project. Present them to the user for confirmation or correction **in the detected language**:

**English example:**
```
ASSUMPTIONS I'M MAKING:
1. This is a web application (not native mobile)
2. The primary language is English
3. This is for desktop/mobile/both
4. No user authentication is needed
5. Data does not need to persist between sessions
→ Correct me now or I'll proceed with these.
```

**Spanish example:**
```
SUPOSICIONES QUE ESTOY HACIENDO:
1. Esta es una aplicación web (no móvil nativa)
2. El idioma principal es español
3. Es para escritorio/móvil/ambos
4. No se necesita autenticación de usuario
5. Los datos no necesitan persistir entre sesiones
→ Corrígeme ahora o procederé con estas.
```

---

## Step 2: Discovery Interview (Minimum 5 Questions)

Ask these questions **in the user's detected language**. Do not proceed until answered:

**English:**
1. **Audience**: Who will use this? (Age, tech-savviness, context)
2. **Purpose**: What problem does this solve in one sentence?
3. **Scope**: Is this an MVP or a complete product? What features are MUST vs. NICE?
4. **Context**: Where and how will this be used? (Phone on a court, office desktop...)
5. **Stack preference**: Any existing tech constraints? (React, Vue, vanilla...)

**Spanish:**
1. **Audiencia**: ¿Quién usará esto? (Edad, conocimiento técnico, contexto)
2. **Propósito**: ¿Qué problema resuelve esto en una oración?
3. **Alcance**: ¿Es un MVP o un producto completo? ¿Qué características son OBLIGATORIAS vs. OPCIONALES?
4. **Contexto**: ¿Dónde y cómo se usará? (Teléfono en una cancha, escritorio de oficina...)
5. **Preferencia de stack**: ¿Hay restricciones técnicas existentes? (React, Vue, vanilla...)

---

## Step 3: Extended Discovery (For non-trivial projects)

If the project involves logic, data, or user interactions, also ask:

6. **Data / Datos**: What data needs to be stored? Where? (localStorage, database, none)
7. **Security / Seguridad**: Any auth, private data, or compliance needs? (GDPR, accessibility laws)
8. **Scalability / Escalabilidad**: 10 users or 10,000? Single match or tournament management?
9. **Offline / Sin conexión**: Does it need to work without internet?
10. **Integration / Integración**: Does it connect to other systems? (APIs, payment, analytics)

---

## Step 4: Visual Direction (if applicable)

If the project has a visual component, ask:

11. **References / Referencias**: Any websites, apps, or styles you like?
12. **Mood / Tono**: Playful, serious, luxury, brutalist, minimalist?
13. **Brand / Marca**: Do you have existing colors, fonts, or a logo?

---

## Step 5: Confirm & Lock

Summarize everything in a concise paragraph. Ask: **"¿Es esto correcto? ¿Arrancamos? / Is this correct? Shall we proceed?"**

Only after explicit confirmation ("sí", "yes", "adelante", "perfecto", "vamos"), proceed to Step 6.

---

## Step 6: Write Discovery Artifact

Write `design/design-discovery.md` with the confirmed answers. This artifact is the source of truth for DESIGN.md — DESIGN.md is EXTRACTED from it, not guessed.

**Template:**

```markdown
# Design Discovery — [project name]

Approved: [date]

## Intent
[What was confirmed: page kind, audience, one-line purpose]

## Three Dials
- VARIANCE: [1-10]
- MOTION: [1-10]
- DENSITY: [1-10]

## Direction Skill
[brutalist | minimalist | premium | none]

## References
[URLs, screenshots, or "none provided"]

## Constraints
[Stack, theme, hard limits — from discovery answers]

## User Approval
"[user's exact confirmation]" — user at [timestamp]
```

After writing, present the file to the user. Only after explicit confirmation, proceed to Phase 2 (Contracts).

# Design Workflow

> Mapa del ecosistema de diseño: cómo las skills de diseño se relacionan, encadenan y ejecutan.
> **Actualizado para v6.0.0 — Phase 6: Design Skill Integrity.**

## Arquitectura

```
engineering-fundamentals/guides/DESIGN-CORE.md
  ↑ Universal: Brief Inference, Three Dials System, Color Principles, Dark Mode
  │
  ├── frontend-web/DESIGN-GUIDE.md       ← Web: CSS Grid, Tailwind, next/font
  ├── frontend-mobile/DESIGN-GUIDE.md    ← Mobile: React Native, Reanimated, expo-font
  ├── frontend-desktop/DESIGN-GUIDE.md   ← Desktop: Tauri, OS materials, system fonts
  └── frontend-pwa/DESIGN-GUIDE.md       ← PWA: Workbox, Capacitor, viewport units
```

**Regla:** `DESIGN-CORE.md` es la fuente única de verdad para diseño universal. Las platform-specific `DESIGN-GUIDE.md` solo añaden implementación. Nunca duplicar.

---

## Ciclo de Vida del Diseño

```
                ┌─────────────────┐
                │  BRIEF INFERENCE │  (DESIGN-CORE.md §1)
                │  6 señales →    │
                │  Design Read     │
                └────────┬────────┘
                         ↓
                ┌─────────────────┐
                │  THREE DIALS     │  (DESIGN-CORE.md §2)
                │  VAR MOT DEN     │
                │  preset o custom │
                └────────┬────────┘
                         ↓
           ┌──────────────────────────┐
           │  PLATFORM APPLICATION    │  (plataforma-specific DESIGN-GUIDE.md)
           │  - Dial → CSS / RN / etc │
           │  - Typography            │
           │  - Color tokens          │
           └────────┬─────────────────┘
                    ↓
     ┌──────────────┴──────────────┐
     │         BUILD               │
     │  (frontend-web, -mobile,    │
     │   -desktop, -pwa, etc.)     │
     └──────────────┬──────────────┘
                    ↓
     ┌──────────────┴──────────────┐
     │         REVIEW              │
     │  critique (design quality) │
     │  audit (technical quality)  │
     └──────────────┬──────────────┘
                    ↓
     ┌──────────────┴──────────────┐
     │         REFINE              │
     │  polish → typeset → layout  │
     │  → delight → distill        │
     └──────────────┬──────────────┘
                    ↓
     ┌──────────────┴──────────────┐
     │         HARDEN              │
     │  harden → onboard → clarify │
     └──────────────┬──────────────┘
                    ↓
     ┌──────────────┴──────────────┐
     │         SHIP                │
     └─────────────────────────────┘
```

---

## Skills de Diseño

### Universales (cross-platform)

| Skill | Fase | Qué hace | Depende de |
|---|---|---|---|
| `engineering-fundamentals/guides/DESIGN-CORE.md` | Brief + Dials | Brief Inference, Three Dials, Color, Dark Mode | — |
| `critique-skill` | Review | Scoring Nielsen + personas + slop detection + visual design pass (Phase 6) | DESIGN-CORE.md |
| `audit-skill` | Review | 5-dimension technical quality (a11y, perf, theming, responsive, anti-patterns) | — |
| `clarify-skill` | Harden | Reescritura de UX copy | — |
| `delight-skill` | Refine | Personalidad + micro-interactions | — |

### Platform-Specific

| Skill | Qué añade al diseño universal |
|---|---|
| `frontend-web/DESIGN-GUIDE.md` | CSS Grid, Tailwind spacing, Framer Motion, next/font, CSS custom properties |
| `frontend-mobile/DESIGN-GUIDE.md` | Reanimated, SafeAreaView, expo-font, platform HIG, touch targets |
| `frontend-desktop/DESIGN-GUIDE.md` | OS materials (Mica, Vibrancy), system fonts, window chrome |
| `frontend-pwa/DESIGN-GUIDE.md` | Container queries, touch targets, responsive matrix |

### Estéticas (aplican sobre cualquier plataforma)

| Skill | Cuándo usarla |
|---|---|
| `industrial-brutalist-ui` | Interfaces mecánicas, terminal aesthetics, Swiss print |
| `minimalist-ui` | Editorial product UI, Notion/Linear vibes |
| `soft-premium-ui` | Pulido, calmado, caro — spring motion, whitespace |

### Proceso

| Skill | Cuándo usarla |
|---|---|
| `redesign-skill` | Código existente que necesita upgrade visual |
| `spec-driven-development` | Nuevo feature — antes de cualquier diseño |
| `output-skill` | Cuando el agente trunca output o salta pasos |

---

## Flujo Típico por Escenario

### Nuevo Proyecto Web

```
1. spec-driven-development → SPEC.md
2. frontend-web → Phase 0b Brief Inference
3. frontend-web → Phase 3: DESIGN-CORE.md → Three Dials
4. frontend-web → Phase 3: DESIGN-GUIDE.md → typography, tokens
5. frontend-web → Phase 7: build
6. critique-skill → review + scoring
7. polish → refinements
8. fullstack-shipping → deploy
```

### Rediseño de App Existente

```
1. project-health-check → audit codebase
2. redesign-skill → scan diagnose fix
3. critique-skill → design review
4. distill-skill → simplify bloated UI
5. clarify-skill → fix UX copy
6. harden-skill → edge cases
7. polish → final pass
```

### Nueva App Mobile

```
1. spec-driven-development → SPEC.md
2. frontend-mobile → Phase 1 discovery
3. frontend-mobile → Phase 3: DESIGN-CORE.md → Three Dials
4. frontend-mobile → Phase 3: (platform DESIGN-GUIDE.md)
5. frontend-mobile → build
6. critique-skill → review
7. harden-skill → i18n, error states
8. onboard-skill → first-run
```

---

## Guías de Referencia Rápida

| Quiero... | Cargo |
|---|---|
| Definir dirección visual | `engineering-fundamentals/guides/DESIGN-CORE.md` Brief Inference + Three Dials |
| Elegir colores | `engineering-fundamentals/guides/DESIGN-CORE.md` §3 Universal Color Principles |
| Elegir tipografía web | `frontend-web/DESIGN-GUIDE.md` §2 Typography |
| Saber qué NO hacer | `engineering-fundamentals/guides/ANTI-SLOP-CORE.md` + `frontend-web/ANTI-SLOP-GUIDE.md` |
| Animar | `frontend-web/ANIMATION-GUIDE.md` (o platform-specific) |
| Preparar para producción | `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` |
| Revisar calidad diseño | `critique-skill` *(futuro)* |
| Revisar calidad técnica | `audit-skill` *(futuro)* |
| Simplificar UI | `distill-skill` *(futuro)* |
| Mejorar UX copy | `clarify-skill` *(futuro)* |
| Endurecer edge cases | `harden-skill` *(futuro)* |
| Diseñar onboarding | `onboard-skill` *(futuro)* |

---

---

## Phase 6 Updates (v6.0.0)

El flujo de diseño ahora está gobernado por gates mecánicos:

- **DESIGN-MD-SCHEMA.md** — Esquema universal de 17 secciones que aplica a todas las plataformas
- **design-gate.sh** — 3 modos: strict (bloquea violaciones verificables), audit (advierte), verify (pre-merge)
- **design-upgrade.sh** — Extracción automática de tokens desde codebases existentes (CSS vars, HTML, package.json)
- **token-validate.sh** — Detección de CSS drift contra tokens de DESIGN.md
- **approval-gate.sh** — Transición prototype→approved con timestamp explícito
- **Direction + Platform Wiring** — Skills de dirección (brutalist, minimalist, premium) componen con plataforma vía el schema
- **critique-skill** — Pass opcional de diseño visual con 5 dimensiones felt (color, tipografía, jerarquía, espacial, tono)

---

## Reglas de Oro

1. **DESIGN-CORE.md es la fuente única** — todo diseño universal vive ahí. Las platform guides solo implementan.
2. **Nunca duplicar** — si un concepto aplica a todas las plataformas, va en DESIGN-CORE.md. Si es específico de web/mobile/desktop, va en su DESIGN-GUIDE.md.
3. **Las skills cross-platform referencian DESIGN-CORE.md directamente**, no a frontend-web.
4. **Pre-flight antes de cualquier edición** — `bash scripts/pre-flight.sh` + preguntar al usuario.
5. **Feedback loop:** Brief → Build → Critique → Refine → Harden → Ship. No saltar pasos.

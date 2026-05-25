# Simulación: Creación de Landing Page para Cafetería

**Proyecto:** "Café del Alba" — Landing page para cafetería artesanal
**Usuario:** Emprendedor, primera web, no tiene referencias visuales claras
**Stack final:** Next.js 16 + Tailwind v4 + shadcn/ui + Framer Motion
**Duración simulada:** ~45 minutos de conversación con el agente

---

## Paso 0: Inicialización del Proyecto

**Usuario:** *"Quiero crear una landing page para mi cafetería"*

**Agente (detección de idioma: español):**
> "¡Perfecto! Voy a ayudarte a crear una landing page para tu cafetería. Primero necesito configurar el proyecto con nuestras reglas de trabajo."

**Agente ejecuta (mentalmente):**
```bash
init-agents
# Copia AGENTS.md al directorio del proyecto
```

**Agente:**
> "He inicializado el proyecto con nuestras reglas de ingeniería. Antes de escribir una sola línea de código, vamos a definir bien qué estamos construyendo."

---

## Paso 1: Spec-Driven Development (DEFINE)

**Agente invoca: `spec-driven-development`**

### Phase 1: Research (Web)

**Agente:**
> "Voy a investigar las mejores prácticas actuales para landing pages de cafeterías..."

**Búsquedas simuladas:**
- "Best practices coffee shop landing page [current year]"
- "Coffee shop website design trends [current year]"
- "Hospitality landing page conversion optimization"

**Hallazgos presentados:**
> "Según mi investigación, las landing pages de cafeterías más exitosas en [current year] tienen:
> - Fotografía de alta calidad del ambiente y productos
> - Menú visible y actualizable
> - Ubicación prominente con mapa
> - Reseñas/testimonios sociales
> - CTA claro (visitar, reservar, ordenar)
> - Diseño cálido y acogedor (tonos tierra, madera, iluminación suave)
>
> ¿Esto coincide con tu visión?"

### Phase 2: Discovery con Critical Challenge

**Agente:**
> "Voy a hacerte algunas preguntas para entender tu proyecto. No asumiré nada."
>
> **SUPOSICIONES QUE ESTOY HACIENDO:**
> 1. Esta es una cafetería física con ubicación real (no solo online)
> 2. El idioma principal es español
> 3. Necesitas que los clientes te encuentren y visiten
> 4. No necesitas sistema de pedidos online completo (solo info)
> 5. No tienes marca establecida (logo, colores definidos)
> → Corrígeme ahora o procederé con estas.

**Usuario:** *"Sí, es correcto. Es una cafetería física en Bogotá. No tengo logo ni colores definidos, me ayudas con eso."*

**Agente:**
> **Descubrimiento:**
> 1. **Audiencia:** ¿Quién visitará la web? (jóvenes, familias, ejecutivos, turistas)
> 2. **Propósito:** ¿Qué problema resuelve esta web? (atraer clientes, mostrar menú, reservas)
> 3. **Alcance:** ¿Es un MVP o producto completo? ¿Menú online, reservas, galería, contacto?
> 4. **Contexto:** ¿En Bogotá? ¿Es un barrio específico? ¿Cómo llegan los clientes?
> 5. **Stack:** ¿Alguna preferencia técnica? Si no, propongo Next.js + Tailwind.
> 6. **Datos:** ¿Menú que cambia frecuentemente? ¿Necesitas CMS o es estático?
> 7. **Marca:** ¿Tienes fotos del local? ¿Algún estilo que te guste?

**Usuario:**
> *"1. Jóvenes y ejecutivos de 25-40 años. 2. Atraer clientes nuevos y mostrar el menú. 3. MVP con menú, ubicación, galería y contacto. 4. En Chapinero, llegan caminando o en TransMilenio. 5. Me da igual, tú sabes. 6. El menú cambia cada temporada. 7. Tengo fotos del local. Me gustan las cafeterías tipo 'tertulia' con madera y luz cálida."*

**Agente (Critical Challenge):**
> **OBSERVACIONES CRÍTICAS:**
>
> 1. Dijiste "menú cambia cada temporada" — esto implica que necesitas poder actualizarlo sin tocar código. Propongo usar archivos JSON locales o un CMS ligero (Notion, Google Sheets, o Sanity). ¿Qué prefieres?
>
> 2. "Jóvenes y ejecutivos de 25-40" son audiencias distintas. Los jóvenes valoran estética Instagrammable. Los ejecutivos valoran rapidez y claridad. ¿Qué priorizas?
>
> 3. Dijiste "MVP con menú, ubicación, galería y contacto" — eso son 4 secciones más hero + footer = 6 secciones. Para un MVP, sugiero hero + menú + ubicación + contacto = 4 secciones. La galería puede ser fase 2. ¿Aceptas reducir alcance para lanzar más rápido?

**Usuario:**
> *"1. Archivos JSON locales está bien, no quiero pagar CMS todavía. 2. Priorizo a los jóvenes, pero que los ejecutivos no se confundan. 3. Vale, sin galería por ahora."*

**Agente:**
> **RESUMEN DE LA BASE DEL ESPECIFICACIÓN:**
> Construimos una landing page para "Café del Alba", cafetería en Chapinero, Bogotá. Audiencia: jóvenes 25-40 (prioridad) + ejecutivos. MVP: Hero, Menú (JSON), Ubicación, Contacto. Stack: Next.js 16 + Tailwind v4 + Framer Motion. Estética: cálida, madera, luz suave, tipo "tertulia". Menú actualizable vía JSON local.
>
> ¿Es esto correcto? ¿Procedemos?

**Usuario:** *"¡Sí, perfecto!"*

### Phase 3-5: Spec, Architecture, Environment

**Agente invoca:**
- `architecture-analysis` (lightweight — para landing page simple)
- `dev-environment-audit` (verifica Node, npm, Git)

**Agente crea `SPEC.md`:**
```markdown
# Spec: Café del Alba — Landing Page

## Objective
Landing page para cafetería artesanal en Chapinero, Bogotá. Atraer clientes jóvenes y ejecutivos, mostrar menú actualizable y ubicación.

## Tech Stack
- Next.js 16.1.1+
- React 19.2+
- TypeScript 5.7+
- Tailwind CSS v4
- Framer Motion 12+
- shadcn/ui (latest)
- lucide-react

## Commands
```bash
npm run dev       # Development
npm run build     # Production build
npm test          # Vitest unit tests
npm run lint      # ESLint + Prettier
```

## Project Structure
```
├── public/
│   └── images/
├── src/
│   ├── app/
│   │   ├── page.tsx
│   │   ├── layout.tsx
│   │   └── globals.css
│   ├── components/
│   │   ├── Navbar.tsx
│   │   ├── Hero.tsx
│   │   ├── Menu.tsx
│   │   ├── Location.tsx
│   │   ├── Contact.tsx
│   │   └── Footer.tsx
│   ├── data/
│   │   └── menu.json
│   └── lib/
│       └── utils.ts
├── tests/
│   └── e2e/
├── design/
│   ├── DESIGN-LOCK.md
│   └── approved/
├── .github/
│   └── PRE_COMMIT_CHECKLIST.md
└── docs/
    └── DEV-ENVIRONMENT.md
```

## Code Style
- PascalCase components
- CSS custom properties for tokens
- No hardcoded Tailwind generics

## Testing Strategy
- Unit: Vitest for utilities
- E2E: Playwright for critical flows
- Minimum 70% coverage

## Boundaries
- Always: Run tests before commit, use design tokens
- Ask first: Add dependencies, change design tokens, modify menu structure
- Never: Commit secrets, skip types, use generic AI patterns

## Success Criteria
- [ ] LCP < 2.5s
- [ ] Responsive (375px, 768px, 1280px)
- [ ] Menu editable via JSON without touching code
- [ ] WCAG AA accessible
- [ ] Build passes without errors

## Architecture Decisions
- Stack: Next.js static export (no backend needed)
- Data: JSON files in `/src/data/` for menu
- Deployment: Vercel (platform-native CI/CD)
```

---

## Paso 2: Git Init & Versioning

**Agente invoca: `git-init-and-versioning`**

**Agente:**
> "Antes de escribir código, configuramos el control de versiones."

### Phase 1: Repository Structure

**Agente:**
> "¿Qué estructura de repositorio prefieres?
>
> A — Un solo repositorio con todo el proyecto
> B — Repositorios separados (si hubiera backend)
> C — Solo frontend (este caso)
>
> Para una landing page simple, recomiendo C (un solo repo)."

**Usuario:** *"Dale, un solo repo."*

### Phase 2-3: Init + .gitignore

**Agente ejecuta:**
```bash
git init
git branch -M main
```

**Crea `.gitignore`:**
```gitignore
# Dependencies
node_modules/

# Build outputs
.next/
dist/

# Environment
.env
.env.local

# OS + IDE
.DS_Store
.idea/

# Testing
coverage/

# Logs
*.log
```

### Phase 4: .env.example

**Crea `.env.example`:**
```bash
# App Config
NODE_ENV=development
NEXT_PUBLIC_SITE_URL=http://localhost:3000

# Analytics (optional)
# NEXT_PUBLIC_GOOGLE_ANALYTICS_ID=
```

### Phase 5: Branching Strategy

**Agente:**
> "Recomiendo trunk-based development: `main` siempre deployable, feature branches cortos (1-3 días), merge via PR."

**Usuario:** *"Perfecto."*

### Phase 6: Pre-Commit Checklist

**Crea `.github/PRE_COMMIT_CHECKLIST.md`** (ver skill git-init-and-versioning para contenido completo)

### Phase 7: First Commit

```bash
git add SPEC.md .gitignore .env.example .github/PRE_COMMIT_CHECKLIST.md
git commit -m "chore: initialize project with contracts and configuration

- Add SPEC.md with project scope and acceptance criteria
- Add .gitignore for Node.js/Next.js
- Add .env.example documenting required variables
- Add pre-commit checklist for auto-review
- Configure trunk-based development workflow"
```

---

## Paso 3: Visual Frontend Mastery (DEFINE → BUILD transition)

**Agente invoca: `visual-frontend-mastery`**

### Phase 1: Discovery Gate

**Agente:**
> **Descubrimiento Visual:**
> 11. **Referencias:** ¿Alguna cafetería o web que te guste visualmente?
> 12. **Tono:** ¿Cálido y acogedor, moderno y minimalista, rústico, o lujoso?
> 13. **Marca:** ¿Tienes logo, colores, o fotos del local?

**Usuario:**
> *"11. Me gusta el estilo de las cafeterías de Melbourne, mucha madera, luz natural, verdes. 12. Cálido y acogedor, tipo tertulia. 13. Tengo fotos del local, no tengo logo."*

### Phase 2: Design.md + Design Asset Lock

**Agente:**
> "Basado en tus respuestas (hospitality + cálido + madera), selecciono 3 direcciones:
>
> **A — Understated Elegance (UE):** Elegante pero accesible, tonos tierra, serifas suaves.
> **B — Luxury Dark Warm (LDW):** Oscuro y cálido, madera oscura, dorados sutiles.
> **C — Playful Gradient (PG):** Colorido y juvenil, quizás no va con 'tertulia'.
>
> Recomiendo **A — Understated Elegance** porque combina la calidez que buscas con la sofisticación que atrae a ejecutivos."

**Usuario:** *"Me gusta la A."*

**Agente genera `DESIGN.md`:**
```markdown
---
name: Café del Alba
---

## Overview
Understated Elegance meets Colombian warmth. Tertulia-inspired coffee shop.

## Colors
- Primary: #3D2B1F (Dark coffee brown — headlines, nav)
- Secondary: #8B6914 (Golden amber — accents, CTAs)
- Tertiary: #6B8E23 (Olive green — natural touch)
- Background: #FDF8F0 (Warm cream — page background)
- Surface: #FFFFFF (Cards, sections)
- Text: #2C1810 (Dark roast — body text)

## Typography
- Display: Playfair Display (headlines, hero)
- Body: Inter (body text, UI)
- Scale: H1 3rem, H2 2rem, Body 1rem, Label 0.75rem

## Spacing
- Section padding: 96px vertical
- Container max-width: 1280px
- Grid gap: 24px

## Motion
- Entrance: Fade up, 0.6s, ease [0.22, 1, 0.36, 1]
- Hover: Scale 1.02, 0.2s
```

**Agente crea `design/DESIGN-LOCK.md`:**
```markdown
# Design Lock — APPROVED

## Direction
- Aesthetic ID: UE-L1
- Mood: Tertulia cálida, madera, luz natural
- Date approved: 2026-05-24

## Final Palette
- Primary: #3D2B1F (Dark coffee — headlines)
- Secondary: #8B6914 (Golden — CTAs)
- Tertiary: #6B8E23 (Olive — accents)
- Background: #FDF8F0 (Warm cream)

## Final Typography
- Display: Playfair Display, 400/700
- Body: Inter, 400/500

## Key Decisions
- "Madera y luz cálida" → warm cream background + dark brown text
- "Jóvenes prioridad" → Playfair Display (Instagrammable)
- "Ejecutivos no confundidos" → Inter body (legible), clear CTAs
- "Sin galería en MVP" → removed from scope
```

**Agente copia fotos a `design/approved/`

---

## Paso 4: Architecture Analysis (lightweight)

**Agente:**
> "Para una landing page estática sin backend, la arquitectura es simple:
> - Next.js App Router con static export
> - No backend, no API routes
> - JSON local para menú
> - Deploy en Vercel
>
> ¿Confirmas?"

**Usuario:** *"Sí."*

---

## Paso 5: Dev Environment Audit

**Agente invoca: `dev-environment-audit`**

**Agente:**
> "Verificando herramientas de desarrollo..."
>
> **INSTALADAS ✅:**
> - Node.js 20.11 ✅
> - npm 10.2 ✅
> - Git 2.43 ✅
>
> **FALTANTE:**
> 🟠 Vercel CLI (opcional, para deploy manual)
>
> ¿Instalamos Vercel CLI? No es obligatorio pero útil.

**Usuario:** *"Dale, instálalo."*

```bash
npm i -g vercel
```

**Crea `docs/DEV-ENVIRONMENT.md`**

---

## Paso 6: Implement Gate (SPEC.md locked)

**Agente (spec-driven-development Phase 8):**
> "Verificamos que todo está listo antes de codear:
>
> ✅ SPEC.md — Completo y aprobado
> ✅ Architecture — Next.js static, JSON data
> ✅ DESIGN.md — Aprobado con tokens
> ✅ DESIGN-LOCK.md — Creado con decisiones
> ✅ Git — Inicializado, .gitignore, .env.example
> ✅ Environment — Node, npm, Vercel CLI listos
> ✅ Plan — Tareas desglosadas
>
> **¿Estamos listos para construir?**"

**Usuario:** *"¡Vamos!"*

---

## Paso 7: Build with Tokens (Visual Frontend Mastery Phase 6)

**Agente:**
> "**LEYENDO DESIGN-LOCK.md:** Aprobado: UE-L1, warm cream #FDF8F0, Playfair + Inter..."

**Agente ejecuta:**
```bash
npx create-next-app@latest cafe-del-alba --typescript --tailwind --eslint --app --src-dir
```

**Aplica tokens a `src/app/globals.css`:**
```css
@theme {
  --color-primary: #3D2B1F;
  --color-secondary: #8B6914;
  --color-tertiary: #6B8E23;
  --color-background: #FDF8F0;
  --color-surface: #FFFFFF;
  --color-text: #2C1810;
}
```

**Crea componentes:**
- `Navbar.tsx` — Sticky, cambio de fondo en scroll
- `Hero.tsx` — H1 + subtítulo + CTA + imagen del local
- `Menu.tsx` — Cards de productos desde `menu.json`
- `Location.tsx` — Dirección + mapa embebido
- `Contact.tsx` — Formulario + horarios
- `Footer.tsx`

**Usa `Reveal` component de Framer Motion para cada sección**

---

## Paso 8: Pre-Commit Auto-Review (durante BUILD)

**Agente antes de cada commit:**

> "**Running Pre-Commit Checklist:**
> ✅ Correctness: Tests pasan, build exitoso
> ✅ Readability: Nombres descriptivos, sin anidamiento excesivo
> ✅ Architecture: Componentes reutilizables, sin duplicación
> ✅ Security: No secrets en código, inputs sanitizados
> ✅ Performance: Solo transform/opacity animations, lazy loading imágenes
> ✅ Git Hygiene: Un solo cambio lógico (componente Hero)
>
> **COMMIT APROBADO**"

```bash
git add src/components/Hero.tsx
git commit -m "feat: add Hero section with Playfair display and warm cream background

- Implements hero with H1, subtitle, CTA button
- Uses design tokens from globals.css
- Adds Reveal animation on scroll
- Responsive: 375px mobile → 1280px desktop"
```

**Repite para cada componente...**

---

## Paso 9: QA Gates (antes de deploy)

**Agente (Visual Frontend Mastery Phase 7):**

> "**QA Checklist:**
> 1. ✅ TypeScript — `npx tsc --noEmit` passes
> 2. ✅ Build — `npm run build` succeeds
> 3. ✅ No template residue — removido texto default de Next.js
> 4. ✅ No hardcoded colors — busqué `bg-blue-`, `text-gray-`, reemplacé con tokens
> 5. ✅ Responsive — verifiqué 375px, 768px, 1280px
> 6. ✅ Accessibility — contraste 4.5:1, focus indicators 2px, `prefers-reduced-motion`
> 7. ✅ Images — todas tienen `alt` descriptivo, hero tiene `priority`
> 8. ✅ SEO — `sitemap.ts`, `robots.ts`, metadata en layout
> 9. ✅ Reduced motion — CSS fallback en globals.css
> 10. ✅ Animation performance — solo `transform` y `opacity`
> 11. ✅ Design Lock present — leído antes de codear
> 12. ✅ Visual consistency — ningún color/font se desvió del DESIGN.md
>
> **TODOS LOS CHECKS PASAN**"

---

## Paso 10: Fullstack Shipping (Deploy)

**Agente invoca: `fullstack-shipping`**

### Phase 1: Shipping Discovery

**Agente:**
> "¿Dónde desplegamos?
>
> A — Vercel (recomendado, conecta con GitHub)
> B — Netlify
> C — Otro
>
> Recomiendo Vercel porque es la plataforma nativa de Next.js."

**Usuario:** *"Vercel está bien."*

### Phase 3: CI/CD Pipeline

**Agente:**
> "Configuro GitHub Actions + Vercel:
>
> **Pipeline:**
> - PR → Preview deployment automático
> - `main` → Production deployment
> - Tests en cada PR (lint, typecheck, build)
>
> **Opciones:**
> A — Vercel Git Integration (auto, zero config)
> B — GitHub Actions + Vercel CLI (más control)
>
> Recomiendo A para velocidad, B si necesitas steps custom."

**Usuario:** *"A, quiero algo rápido."*

### Phase 7: Launch Checklist

**Agente:**
> "**Pre-Launch Checklist:**
> ✅ Tests pasan en CI
> ✅ Build exitoso
> ✅ Staging verificado (preview URL)
> ✅ Secrets configurados (none needed for static)
> ✅ Dominio: `cafe-del-alba.vercel.app` (custom domain configurable)
> ✅ Monitoring: Vercel Analytics + UptimeRobot configurados
>
> **Deploy:**"

```bash
git push origin main
# Vercel auto-deploys from main branch
```

---

## Resultado Final

**Proyecto entregado:**
- ✅ Landing page funcional en `https://cafe-del-alba.vercel.app`
- ✅ Diseño coherente con tokens aprobados
- ✅ Menú editable via `src/data/menu.json`
- ✅ Responsive, accesible, animada
- ✅ SEO configurado
- ✅ Git history limpia con commits descriptivos
- ✅ Especificación documentada en `SPEC.md`
- ✅ Diseño documentado en `DESIGN.md` + `design/DESIGN-LOCK.md`
- ✅ Setup documentado en `SETUP.md`
- ✅ Pre-commit checklist para futuros cambios

**Archivos creados:**
```
cafe-del-alba/
├── .git/                          # Git initialized
├── .github/
│   └── PRE_COMMIT_CHECKLIST.md    # Auto-review gate
├── .gitignore                     # Node.js optimized
├── .env.example                   # Documented env vars
├── README.md                      # Project overview
├── SETUP.md                       # Setup instructions
├── SPEC.md                        # Specification
├── DESIGN.md                      # Visual tokens
├── design/
│   ├── DESIGN-LOCK.md             # Approved decisions
│   └── approved/
│       └── photos/                # Cafe photos
├── docs/
│   └── DEV-ENVIRONMENT.md         # Tools audit
├── src/
│   ├── app/
│   │   ├── page.tsx               # Landing page
│   │   ├── layout.tsx             # Root layout
│   │   └── globals.css            # Design tokens
│   ├── components/
│   │   ├── Navbar.tsx
│   │   ├── Hero.tsx
│   │   ├── Menu.tsx
│   │   ├── Location.tsx
│   │   ├── Contact.tsx
│   │   └── Footer.tsx
│   ├── data/
│   │   └── menu.json              # Editable menu
│   └── lib/
│       └── utils.ts
├── public/
│   └── images/
├── tests/
│   └── e2e/
└── package.json
```

---

## Skills Utilizados en esta Simulación

| Orden | Skill | Fase del Lifecycle |
|---|---|---|
| 1 | `init-agents` | Setup |
| 2 | `spec-driven-development` | DEFINE |
| 3 | `git-init-and-versioning` | DEFINE (post-spec) |
| 4 | `visual-frontend-mastery` | DEFINE → BUILD |
| 5 | `architecture-analysis` | DEFINE (lightweight) |
| 6 | `dev-environment-audit` | DEFINE (pre-build) |
| 7 | `incremental-implementation` + `test-driven-development` | BUILD |
| 8 | `code-review-and-quality` (via pre-commit checklist) | BUILD |
| 9 | `git-workflow-and-versioning` | BUILD (commits) |
| 10 | `fullstack-shipping` | SHIP |

**Tiempo estimado de conversación:** 45 minutos
**Tiempo estimado de implementación real:** 2-3 horas (con agente)

---

## Notas del Simulador

### Qué funcionó bien
- El critical challenge en spec-driven-development redujo alcance innecesario (galería)
- Design Asset Lock prevendrá pérdida de contexto visual en iteraciones futuras
- Pre-commit checklist obliga calidad en cada commit
- Git init antes de código previó commits de node_modules o .env

### Qué validar en test real
- Que el agente realmente lee DESIGN-LOCK.md antes de codear
- Que el pre-commit checklist no se salta bajo presión de tiempo
- Que la generación de .gitignore cubre create-next-app outputs
- Que el deploy a Vercel funciona con la pipeline propuesta

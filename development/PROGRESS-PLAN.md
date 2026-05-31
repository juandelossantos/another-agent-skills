# PROGRESS PLAN — Another Agent Skills v1.5.0

> Date: 2026-05-30
> Author: juandelossantos + opencode
> Status: Draft — Pending user approval
> Scope: 10 mejoras de disciplina + finalización de web + README upgrade

---

## 0. ANÁLISIS DEL ARTÍCULO: "Agentic AI Use Cases" (System Design Newsletter)

### Resumen del artículo

Neo Kim (System Design Newsletter #149) mapea 8 etapas del ciclo de vida del software y evalúa dónde los agentes de IA funcionan y dónde fallan:

| Etapa | ¿Agente funciona? | Por qué |
|---|---|---|
| **Plan** | Parcial | Agentes escriben specs rápido, pero no pueden decidir QUÉ construir (eso requiere contexto de negocio). |
| **Design** | NO | Agentes diseñan para el problema general, no para tu contexto específico. Duplican código (8x más duplicación post-AI según GitClear) y sobre-ingenian (Karpathy). |
| **Code** | SÍ | Es donde mejor funcionan. Cursor pasó de $100M a $1B ARR. 19% de devs usan Cursor, 10% Claude Code (Stack Overflow 2025). |
| **Test** | SÍ (con supervisión) | Tests se auto-validan (pass/fail). Pero agentes escriben tests vacíos que no prueban nada real. Meta migró a JIT tests por PR. |
| **Review** | Parcial | Agentes revisan cada PR inmediatamente (16.6% de aceptación vs 56.5% humanos). Útil como primera pasada, no como veredicto final. |
| **Deploy** | NO | Un deploy malo afecta a todos los usuarios a la vez. Requiere mano humana en el botón final. |
| **Operate** | Parcial | Agentes recopilan datos rápidamente (Datadog Bits AI SRE), pero el diagnóstico final es humano. Incidentes por cambio subieron 242% con más uso de AI (Faros AI). |
| **Maintain** | SÍ | Trabajo que se auto-califica. Refactor que pasa tests = refactor exitoso. Dependabot en millones de repos. |

**Key insight:** "Agents do well wherever a machine can tell them they're wrong." Fallan donde solo un humano puede juzgar si la decisión es correcta.

**Problema no resuelto:** Context loss entre herramientas. Cada agente empieza de cero. "Shared memory is the real problem under all eight stages, and nobody has fully solved it yet."

**Dato alarmante:** METR estudió 16 devs experimentados en 246 tareas reales. Con AI, terminaron 19% MÁS LENTOS pero se sintieron 20% MÁS RÁPIDOS. La percepción de velocidad no coincide con la realidad.

**3 controles antes de confiar en un agente:** sandbox, permisos scoped, audit log.

---

### ¿Afina nuestra filosofía?

**SÍ, profundamente.** El artículo confirma y amplifica principios que ya tenemos:

| Principio del artículo | Nuestra regla/acción existente | Alineación |
|---|---|---|
| "Agents do well where machines can check them" | **Rule 0c:** "Goal-Driven Execution — Loop until verified" | ✅ Exacto |
| "Spec-driven development" es el camino | **Skill `spec-driven-development`** — SPEC.md required before code | ✅ Ya lo hacemos |
| "Agents over-design and duplicate" | **Rule 0c:** "Simplicity First — No speculative abstractions" | ✅ Ya lo combatimos |
| "Context loss between tools" | **Rule 0e:** "Context Compression & Eviction" + **SOUL.md** (pendiente) | ⚠️ Parcial |
| "3 controls: sandbox, scoped permissions, audit log" | **Guardian Pattern + Pre-commit v6 + SHA256 tokens** | ✅ Tenemos esto |
| "Agents write empty tests" | **`test-driven-development`** skill (72 líneas — débil) | ⚠️ Necesitamos expandir |
| "Shared memory unsolved" | **Continuous Learning v2 (instinct system)** en ECC, nosotros no tenemos | ❌ Gap |
| "Don't trust agent's diagnosis" | **Rule 0g: Mayéutic Challenge** — agentes que cuestionan | ✅ Ya lo hacemos |
| "Maintenance is clearest YES" | No tenemos skill dedicada de maintenance | ❌ Gap menor |

### Lo que podemos aprender y agregar

1. **El artículo valida nuestro approach de "mechanical enforcement"** — Ellos dicen "sandbox, scoped permissions, audit log". Nosotros tenemos: Guardian Pattern (scoped), pre-commit hooks (sandbox), SHA256 tokens (audit). Somos la implementación más completa de esa recomendación.

2. **El gap de "shared memory" es real** — ECC tiene continuous learning v2. Nosotros no tenemos nada de esto. El artículo dice que es el problema #1 no resuelto. Podemos agregar un `SESSION_PATTERNS.md` que se auto-actualice al final de cada sesión.

3. **METR study should be a WARNING in our docs** — "Los agentes se sienten rápidos pero son lentos." Esto debería estar en nuestro README y en AGENTS.md como recordatorio de por qué existe el Guardian Pattern.

4. **El artículo refuerza que "maintenance" es donde más agentes pueden ayudar** — Podemos crear un skill `continuous-maintenance` para automatizar dependency updates, refactor limpio, docs sync.

---

## 1. ESTADO ACTUAL Y PENDIENTES

### Lo que está TERMINADO

| Componente | Estado | Notas |
|---|---|---|
| AGENTS.md (531 líneas, 13 reglas) | ✅ | Core governance completo |
| 31 skills custom + guides | ✅ | Funcionales, algunos necesitan expansión |
| 9-stage design review pipeline | ✅ | critique → delight |
| Pre-commit hook v6 | ✅ | 9 gates, SHA256 hash-bound |
| Native OpenCode plugin | ✅ | 4 hooks TypeScript |
| Design skins (3) | ✅ | industrial-brutalist, minimalist, soft-premium |
| Install scripts (bash + PowerShell) | ✅ | Funcionales |
| ADRs (4) + Incident docs (3) | ✅ | Documentación de decisiones |
| i18n (EN/ES) | ✅ | JSON files poblados |
| SEO (JSON-LD, OG, meta) | ✅ | Configurado |
| Hero + Pipeline sections | ✅ | HTML + CSS + JS |

### Lo que está PENDIENTE (de iteración anterior de web)

| Pendiente | Detalle | Esfuerzo | ¿Necesario? |
|---|---|---|---|
| **OG image PNG** | Solo tenemos SVG. Necesitamos PNG 1200×630 para redes sociales | 30min | SÍ — sin esto Twitter/LinkedIn muestran imagen rota |
| **6 doc pages** | QUICKSTART.md, PIPELINE.md, SKILLS-CATALOG.md, PROCESS.md, CONTRIBUTING.md, FAQ.md — ninguno existe | 4-6h | SÍ — crítico para nuevos usuarios |
| **GitHub Actions deploy** | NO existe `.github/workflows/`. La web no tiene deploy automático | 1-2h | SÍ — sin esto la web no es accesible |
| **Skills grid content** | `.skills__grid` vacío — JS no lo puebla | 2-3h | SÍ — la web se ve rota |
| **Quick Start content** | `.quickstart__steps` vacío | 1-2h | SÍ — lo mismo |
| **Why Different content** | `.why__content` vacío | 1-2h | SÍ — lo mismo |
| **FAQ content** | `.faq__list` vacío | 1h | SÍ — lo mismo |
| **HEALTH-CHECK.md desactualizado** | Dice "v1.2.0" pero estamos en v1.4.1 | 1h | SÍ — stats desactualizadas rompen confianza |

**Descartados (no necesarios):**
- ~~Self-host fonts~~ — Google Fonts funciona bien, ganancia marginal
- ~~Copy button micro-interaction~~ — funciona, polish puro

### Lo que FALTA nuevo (de análisis ECC + artículo)

| Gap | Detalle | Esfuerzo |
|---|---|---|
| **SOUL.md** | Documento de identidad portátil del agente | 1-2h |
| **Skills expandidas** | debugging (63→150+), TDD (72→150+), git-workflow (66→120+) | 11-16h |
| **Tests para scripts** | BATS tests para pre-flight, edit-guard, commit-approval, design-gate | 6-8h |
| **CI pipeline** | `.github/workflows/ci.yml` | 2-3h |
| **Runtime hook controls** | Env vars para niveles de strictness | 2-3h |
| **Selective install** | Perfiles de instalación | 4-6h |
| **Rules layered structure** | `rules/common/` + language-specific | 2-3h |
| **README upgrade** | Stats, comparison table, FAQ, install paths | 3-4h |

---

## 2. TIPO DE RELEASE

**Este es un release MINOR: v1.5.0**

Por qué:
- Agregamos funcionalidad (skills expandidas, SOUL.md, tests, CI, web completa)
- No rompemos compatibilidad existente
- El número de skills pasa de 31 a ~35+ (expansión de skills existentes + nuevos)
- No es un "fix" (eso sería patch)
- No es un "major" (no hay breaking changes en la API del agente)

**Release notes candidatas:**
```
v1.5.0 — Discipline Expansion + Public Website

Core:
- Added SOUL.md: portable agent identity document
- Expanded debugging-and-error-recovery: 63 → 150+ lines
- Expanded test-driven-development: 72 → 150+ lines
- Expanded git-workflow-and-versioning: 66 → 120+ lines
- Added runtime hook controls (SKILLS_HOOK_LEVEL env var)
- Added rules layered architecture (rules/common/ + language-specific)

Infrastructure:
- Added BATS tests for enforcement scripts
- Added CI pipeline (.github/workflows/ci.yml)
- Added selective install profiles (--profile discipline|frontend|full)
- Added stack analysis script with MCP and best practice recommendations

Website:
- Completed landing page with all sections populated
- Added 3 new sections: THE PROBLEM, HOW IT WORKS, COMPATIBLE AGENTS
- Added 6 documentation pages
- Added GitHub Actions deploy to GitHub Pages
- Added OG image for social sharing
- Added comparison table vs ECC / Taste Skill / Impeccable / Open Design

Docs:
- Re-audited HEALTH-CHECK.md (v1.5.0)
- Upgraded README with stats, install paths, FAQ
```

---

## 3. ESTRATEGIA DE BRANCHES

### Feature branches + squash merge

**Por qué NO main:**
- Son ~15 cambios distintos (10 mejoras + web + docs + infra)
- Si rompemos algo en la mejora #3, no debería afectar la mejora #7
- Main debe ser siempre "releaseable" — si alguien clona nuestro repo, main debe funcionar
- Nuestro propio pre-commit hook lo exige (Rule 0d)

**Por qué feature branches:**
- Cada mejora es independiente y testeable
- Podemos hacer PR de cada una y verificar que no rompe nada
- Si una mejora se complica, las demás no se bloquean
- Historial limpio: cada commit = una mejora concreta

### Estructura de branches

```
main (siempre estable, v1.5.0 released)
│
├── FASE 1 — Quick wins ✅ COMPLETADA
│   ├── feat/soul-md ✅
│   ├── feat/reaudit-healthcheck ✅
│   └── feat/rules-layered ✅
│
├── FASE 2 — Skills expandidas ✅ COMPLETADA
│   ├── feat/expand-debugging ✅ (89 lines + 2 guides)
│   ├── feat/expand-tdd ✅ (138 lines)
│   └── feat/expand-git-workflow ✅ (180 lines)
│
├── FASE 2.5 — STACK_CONFIG.md ✅ COMPLETADA
│   └── feat/stack-config ✅ (universal detection, 7 stacks + unknown)
│
├── FASE 3 — Project enforcement ✅ COMPLETADA
│   ├── feat/project-pre-commit-hook ✅ (lifecycle enforcement)
│   └── feat/secret-detection ✅ (integrated in hook)
│
├── FASE 4 — Universal Engineering Practices ✅ COMPLETADA
│   ├── feat/ci-template ✅ (universal, reads STACK_CONFIG.md)
│   ├── feat/runtime-hook-controls ✅ (SKILLS_HOOK_LEVEL, etc.)
│   └── feat/hook-test-template ✅ (BATS template)
│
├── FASE 5 — Stack Analysis ✅ COMPLETADA
│   └── feat/stack-analysis ✅ (category-based, not framework-based)
│
└── FASE 6 — Website + Docs ⏳ PRÓXIMA
    ├── feat/selective-install
    ├── feat/website-complete (skills grid, quick start, why different, FAQ)
    ├── feat/i18n-new-sections
    ├── feat/docs-pages (6 doc pages)
    ├── feat/readme-upgrade (ya parcialmente hecho en v1.5.0)
    └── feat/og-image-png
```

### Orden de ejecución (por dependencias)

```
FASE 1 — Quick wins ✅ COMPLETADA:
  ├── feat/soul-md ✅
  ├── feat/reaudit-healthcheck ✅
  └── feat/rules-layered ✅

FASE 2 — Skills expandidas ✅ COMPLETADA:
  ├── feat/expand-debugging ✅ (89 lines + 2 guides)
  ├── feat/expand-tdd ✅ (138 lines)
  └── feat/expand-git-workflow ✅ (180 lines)
  └── feat/expand-git-workflow ✅ (180 lines)

FASE 2.5 — STACK_CONFIG.md ⭐ NUEVA (depende de Fase 2, antes de Fase 3):
  └── feat/stack-config — init-agents crea STACK_CONFIG.md con comandos detectados

FASE 3 — Project-level enforcement ⭐ PRIORIDAD MÁXIMA (depende de Fase 2.5):
  ├── feat/project-pre-commit-hook — init-agents instala hook en el proyecto del usuario
  └── feat/secret-detection — grep for API keys, tokens, passwords

FASE 4 — Universal Engineering Practices (paralelizables, 1 semana):
  ├── feat/ci-template (3-4h) — init-agents instala CI que lee STACK_CONFIG.md
  ├── feat/runtime-hook-controls (2-3h) — env vars para tuning de hooks
  └── feat/hook-test-template (2-3h) — BATS template para usuario

FASE 5 — Stack Analysis (depende de Fase 2.5):
  └── feat/stack-analysis (3-4h)

FASE 6 — Website + Docs (1-2 semanas):
  ├── feat/selective-install (4-6h)
  ├── feat/website-complete (9-12h)
  ├── feat/i18n-new-sections (1h)
  ├── feat/docs-pages (4-6h)
  ├── feat/readme-upgrade (3-4h)
  └── feat/og-image-png (30min)
```
main (siempre estable)
│
├── FASE 1 — Quick wins ✅
│   ├── feat/soul-md ✅
│   ├── feat/reaudit-healthcheck ✅
│   └── feat/rules-layered ✅
│
├── FASE 2 — Skills expandidas ✅
│   ├── feat/expand-debugging ✅
│   ├── feat/expand-tdd ✅
│   └── feat/expand-git-workflow ✅
│
├── FASE 2.5 — STACK_CONFIG.md ✅
│   └── feat/stack-config ✅
│
├── FASE 3 — Project enforcement ✅
│   ├── feat/project-pre-commit-hook ✅
│   └── feat/secret-detection ✅
│
├── FASE 4 — Universal Engineering Practices
│   ├── feat/ci-template
│   ├── feat/runtime-hook-controls
│   └── feat/hook-test-template
│
├── FASE 5 — Stack Analysis
│   └── feat/stack-analysis
│
└── FASE 6 — Website + Docs
    ├── feat/selective-install
    ├── feat/website-complete
    ├── feat/i18n-new-sections
    ├── feat/docs-pages
    ├── feat/readme-upgrade
    └── feat/og-image-png
```

### Orden de ejecución (por dependencias)

```
FASE 1 — Quick wins ✅ COMPLETADA:
  ├── feat/soul-md ✅
  ├── feat/reaudit-healthcheck ✅
  └── feat/rules-layered ✅

FASE 2 — Skills expandidas (secuenciales, 1-2 semanas):
  ├── feat/expand-debugging (4-6h)
  ├── feat/expand-tdd (4-6h)
  └── feat/expand-git-workflow (3-4h)

FASE 4 — Universal Engineering Practices (paralelizables, 1 semana):
  ├── feat/ci-template (3-4h) — init-agents instala CI que lee STACK_CONFIG.md
  ├── feat/runtime-hook-controls (2-3h) — env vars para tuning de hooks
  └── feat/hook-test-template (2-3h) — BATS template para usuario

FASE 5 — Stack Analysis (depende de Fase 2.5):
  └── feat/stack-analysis (3-4h)

FASE 6 — Website + Docs + Final (1-2 semanas):
  ├── feat/selective-install (4-6h)
  ├── feat/website-complete — skills grid, quick start, why different, FAQ + nuevas secciones HTML (9-12h)
  ├── feat/i18n-new-sections (1h)
  ├── feat/docs-pages — 6 doc pages (4-6h)
  ├── feat/readme-upgrade (3-4h)
  └── feat/og-image-png (30min)
```

**Merge strategy:** Squash merge a main. Cada PR = un commit limpio en main. Tag v1.5.0 al final de Fase 4.

---

## 4. PLAN DETALLADO POR FASE

### FASE 1 — Quick Wins (1 semana)

#### 4.1. SOUL.md
- **Archivo nuevo:** `SOUL.md` en la raíz del repo
- **Contenido:** Identidad del agente — quién es, qué principios siguen, qué nunca hace
- **Referencia:** ECC SOUL.md (adaptar, no copiar)
- **Esfuerzo:** 1-2 horas
- **Impacto:** Alto — define la personalidad del agente en todas las sesiones

#### 4.2. Re-audit HEALTH-CHECK.md
- **Archivo:** `HEALTH-CHECK.md` (existente)
- **Acción:** Contar SKILL.md files reales, verificar que las stats coinciden con v1.4.1
- **Esfuerzo:** 1 hora
- **Impacto:** Bajo pero necesario para integridad documental

#### 4.3. Rules layered structure
- **Archivos nuevos:** `rules/common/coding-style.md`, `rules/common/git-workflow.md`, etc.
- **Acción:** Mover reglas genéricas de AGENTS.md a `rules/common/`. Mantener AGENTS.md como orquestador que referencia rules/.
- **Esfuerzo:** 2-3 horas
- **Impacto:** Alto — reduce monolito de AGENTS.md, escala para más lenguajes

### FASE 2 — Skills Expandidas (1-2 semanas)

#### 4.4. Expandir debugging-and-error-recovery
- **Archivo:** `skills/debugging-and-error-recovery/SKILL.md`
- **Acción:** De 63 a 150+ líneas. Agregar:
  - Decision tree: "Is it a build error? → check X. Runtime error? → check Y. Type error? → check Z."
  - Common root causes por plataforma (React, Node, Python, Go)
  - Escalation patterns (3-strikes rule integration)
  - 2-3 guides nuevos
- **Esfuerzo:** 4-6 horas
- **Impacto:** Crítico — debugging es la skill más invocada

#### 4.5. Expandir test-driven-development
- **Archivo:** `skills/test-driven-development/SKILL.md`
- **Acción:** De 72 a 150+ líneas. Agregar:
  - TDD workflow por framework (React, Next.js, Node, Python)
  - Mocking patterns
  - Test structure templates
  - Coverage thresholds por tipo de proyecto
  - "Empty test" detection (article insight — combatir tests que no prueban nada)
- **Esfuerzo:** 4-6 horas
- **Impacto:** Crítico — TDD es core del lifecycle

#### 4.6. Expandir git-workflow-and-versioning
- **Archivo:** `skills/git-workflow-and-versioning/SKILL.md`
- **Acción:** De 66 a 120+ líneas. Agregar:
  - Rebase vs merge decision matrix
  - Conflict resolution patterns
  - Stash workflows
  - Bisect para debugging
  - Branch naming conventions
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — git es central al workflow

### FASE 2.5 — STACK_CONFIG.md ⭐ NUEVA (3-4 horas)

**Por qué existe:** Las skills necesitan saber qué comandos usar en el proyecto del usuario. Sin `STACK_CONFIG.md`, las skills hardcodean `npm test` y fallan para Rust, Python, Go, etc. `STACK_CONFIG.md` es un contrato explícito que las skills leen y se adaptan.

#### 4.6a. Stack Detection en init-agents
- **Archivo modificado:** `scripts/init-agents.sh`
- **Acción:** Cuando init-agents corre, detecta el stack del proyecto:
  - Lee `package.json` → Node.js/TypeScript, extrae scripts (test, lint, build, dev)
  - Lee `Cargo.toml` → Rust
  - Lee `pyproject.toml` o `requirements.txt` → Python
  - Lee `go.mod` → Go
  - Lee `Gemfile` → Ruby
  - Lee `pubspec.yaml` → Dart/Flutter
- **Genera:** `STACK_CONFIG.md` con:
  - Stack detectado (framework, lenguaje, runtime)
  - Comandos de proyecto (test, lint, typecheck, build, dev)
  - Configuración de testing (framework, coverage tool)
  - Dependencias de lock file detectadas
- **Fallback:** Si no detecta nada → comandos genéricos + "Configure manually"
- **No instala nada** — solo detecta y documenta
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — hace que todas las skills sean universales
- **Dependencias:** Fase 2 completa (skills expandidas)

#### 4.6a-bis. Skills Reference STACK_CONFIG.md
- **Archivos modificados:** `skills/git-workflow-and-versioning/SKILL.md`, y futuras skills
- **Acción:** Reemplazar tablas hardcodeadas con referencia a `STACK_CONFIG.md`
- **Antes:** `npm test # Do tests pass?`
- **Después:** `<test-command> # From STACK_CONFIG.md`
- **Esfuerzo:** 1 hora (actualizar skills existentes)
- **Impacto:** Consistencia — todas las skills leen el mismo contrato

### FASE 3 — Project-level enforcement ⭐ PRIORIDAD MÁXIMA (4-6 horas)

**Por qué es la prioridad:** Nuestra SOUL.md dice "mechanical enforcement, not suggestions." Actualmente, cuando un usuario corre `init-agents`, le damos skills y rules pero NO le damos enforcement mecánico. El agente "recuerda" que debería correr tests, pero no hay hook que lo bloquee. Esto contradice nuestra propia filosofía.

#### 4.6b. Project Pre-Commit Hook
- **Archivo nuevo:** `scripts/project-pre-commit` (template para el proyecto del usuario)
- **Trigger:** `init-agents` lo instala como `.git/hooks/pre-commit` en el proyecto del usuario
- **Enforcement:**
  - Tests pasan antes de commit (detecta npm test, cargo test, pytest, go test, etc.)
  - Build funciona antes de commit (detecta npm run build, cargo build, etc.)
  - No hay secrets hardcodeados (grep for API keys, tokens, passwords)
  - No hay tokens de diseño fuera del design system
  - Design gate si hay cambios visuales (HTML, CSS, componentes)
- **Esfuerzo:** 4-6 horas
- **Impacto:** CRÍTICO — es lo que nos diferencia de ECC. Enforcement real, no sugerencias.

#### 4.6c. Secret Detection
- **Integrado en el project pre-commit hook**
- **Patterns:** API keys, tokens, passwords, connection strings, private keys
- **Acción:** Bloquea commit si detecta secrets. Sugiere usar .env + .gitignore.
- **Esfuerzo:** 1-2 horas (parte de 4.6b)
- **Impacto:** Alto — previene el error más común en seguridad.

### FASE 4 — Universal Engineering Practices (1 semana)

**Filosofía:** Estas no son "nuestras herramientas internas". Son engineering practices que cualquier proyecto necesita. `init-agents` las instala automáticamente.

#### 4.7. CI Template (universal)
- **Archivo nuevo:** `templates/ci.yml` (template para GitHub Actions)
- **Trigger:** `init-agents` copia a `.github/workflows/ci.yml` si no existe
- **Qué hace:** Lee `STACK_CONFIG.md` y ejecuta test/lint/build automáticamente
- **Stack-agnostic:** Funciona para Node, Rust, Python, Go, Ruby, Dart — cualquiera que tenga STACK_CONFIG.md
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — todo proyecto debería tener CI, y ours se adapta automáticamente al stack

#### 4.8. Runtime Hook Controls (universal)
- **Archivo modificado:** `scripts/project-pre-commit`
- **Acción:** Agregar env vars que el usuario puede configurar:
  - `SKILLS_HOOK_LEVEL=minimal|standard|strict` — controla qué checks corre
  - `SKILLS_DISABLED_HOOKS="tests,secrets"` — desactiva checks específicos
  - `SKILLS_TEST_TIMEOUT=60` — timeout para tests (evita que un test colgado bloquee commits)
- **Esfuerzo:** 2-3 horas
- **Impacto:** Medio — flexibilidad sin editar archivos

#### 4.9. Hook Test Template (universal)
- **Archivo nuevo:** `templates/tests/hooks.bats` (template BATS)
- **Trigger:** `init-agents` copia a `tests/hooks.bats` si el usuario quiere tests
- **Qué hace:** Valida que el hook del usuario funciona correctamente
- **Esfuerzo:** 2-3 horas
- **Impacto:** Medio — los usuarios pueden testear sus propios hooks

### FASE 5 — Stack Analysis (3-4 horas)

#### 4.9b. Stack Analysis Script
- **Archivo nuevo:** `scripts/stack-analysis.sh`
- **Acción:** Detecta framework, lenguaje, ORM, auth, testing del proyecto
- **Genera:** `STACK-ANALYSIS.md` con:
  - Stack detectado (framework, lenguaje, DB, auth, testing, deployment)
  - MCPs relevantes (Context7, Playwright, GitHub, Figma) con warning de costo de tokens
  - Skills nuestras que aplican al stack detectado
  - Best practices del ecosistema (investigación propia, no de autoskills)
  - Links a documentación oficial
- **Trigger:** Se ejecuta en `init-agents` (proyectos nuevos) y como `bash scripts/stack-analysis.sh` (proyectos existentes)
- **NO instala nada** — solo informa y sugiere. El usuario decide.
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — reduce fricción de adopción, muestra valor inmediato
- **Dependencias:** Fase 2 completa (skills expandidas para poder referenciarlas)
- **Licencia:** NO integra autoskills (CC BY-NC 4.0 conflict). Investigación propia únicamente.

### FASE 6 — Website + Docs + Final (1-2 semanas)

#### 4.10. Selective install
- **Archivos modificados:** `install.sh`
- **Acción:** Perfiles `--profile discipline`, `--profile frontend`, `--profile full`
- **Esfuerzo:** 4-6 horas
- **Impacto:** Alto — reduce fricción de adopción

#### 4.11. Website — Poblar secciones vacías
- **Archivos:** `js/main.js`, `js/animations.js`
- **Acciones:**
  - Poblar `.skills__grid` con todas las skills organizadas por categoría
  - Poblar `.quickstart__steps` con 3 pasos de instalación
  - Poblar `.why__content` con 4 pillars + comparison table vs ECC/Taste Skill/Impeccable/Open Design
  - Poblar `.faq__list` con 8 preguntas frecuentes
- **Esfuerzo:** 6-8 horas
- **Impacto:** Alto — la web actualmente se ve rota sin contenido

#### 4.12. Website — Nuevas secciones HTML
- **Archivos:** `index.html`, `css/style.css`
- **Acciones:**
  - Agregar sección "THE PROBLEM" (3 pain points)
  - Agregar sección "HOW IT WORKS" (3 pasos con código del DECISION POINT block)
  - Agregar sección "COMPATIBLE AGENTS" (logos: OpenCode, Claude Code, Cursor, Kiro)
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — completar la narrativa de la web
- **Nota:** La sección "WHAT MAKES US DIFFERENT" ya existe como `#why` y se puebla en 4.11. No duplicar.

#### 4.13. i18n — Traducir secciones nuevas
- **Archivos:** `i18n/en.json`, `i18n/es.json`
- **Acción:** Agregar keys para secciones nuevas (THE PROBLEM, HOW IT WORKS, COMPATIBLE AGENTS). Actualmente solo tenemos keys para hero, pipeline, skills, quickstart, why, faq.
- **Esfuerzo:** 1 hora
- **Impacto:** Medio — sin esto, toggle ES muestra texto en inglés

#### 4.14. Documentation pages
- **Archivos nuevos en `docs/`:**
  - `QUICKSTART.md` — 3 comandos para empezar
  - `PIPELINE.md` — Explicación del design review pipeline
  - `SKILLS-CATALOG.md` — Todas las skills con descripciones
  - `PROCESS.md` — Reglas de AGENTS.md, pre-commit gates
  - `CONTRIBUTING.md` — Cómo agregar/modificar skills
  - `FAQ.md` — Preguntas frecuentes
- **Esfuerzo:** 4-6 horas
- **Impacto:** Medio — documentación para nuevos usuarios

#### 4.15. README upgrade
- **Archivo:** `README.md`
- **Acción:** Reescribir con:
  - Stats pill: "54 skills · 9 design stages · 0 trust on agent"
  - Instalación en 1 comando
  - Comparison table (sin nosotros vs con nosotros)
  - Compatible agents
  - Lifecycle flow resumido
  - Link a la web
  - FAQ rápido
- **Esfuerzo:** 3-4 horas
- **Impacto:** Alto — primera impresión del repo

#### 4.16. GitHub Actions deploy
- **Archivo nuevo:** `.github/workflows/deploy.yml`
- **Acción:** Deploy automático a GitHub Pages en push a main
- **Esfuerzo:** 1-2 horas
- **Impacto:** Medio — la web se despliega automáticamente

#### 4.17. OG image PNG
- **Archivo nuevo:** `assets/og-image.png` (desde el SVG existente)
- **Acción:** Generar PNG 1200×630 para social sharing (Twitter, LinkedIn, Discord)
- **Esfuerzo:** 30 minutos
- **Impacto:** Medio — sin esto, compartir la web muestra imagen rota

---

## 5. PLAN WEB — Estructura final

### Secciones de la web

```
SECCIÓN 01: HERO (refinar existente)
  → Stats: "54 skills · 9 design stages · 0 trust on agent"
  → Terminal animation (ya existe)
  → Lifecycle flow (ya existe)

SECCIÓN 02: THE PROBLEM (nueva)
  → "AI agents ship generic, sloppy, insecure output by default."
  → 3 pain points: No design taste / No discipline / No enforcement
  → Quote: "The agent is a talented junior with no process."

SECCIÓN 03: THE LIFECYCLE (refinar existente)
  → DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP
  → Cada etapa con skill que se activa

SECCIÓN 04: DESIGN REVIEW PIPELINE (ya existe, mantener)
  → 9 tarjetas C-A-C-H-P-T-A-O-D

SECCIÓN 05: SKILLS CATALOG (llenar contenido)
  → Grid con skills por categoría
  → Filtros: Foundation / Frontend / Backend / Process / Quality / Design / DevOps

SECCIÓN 06: HOW IT WORKS (nueva)
  → 3 pasos: Clone → Agent reads AGENTS.md → Guardian Pattern activates
  → Código del DECISION POINT block

SECCIÓN 07: WHAT MAKES US DIFFERENT (llenar contenido)
  → 4 pillars: Mechanical Enforcement / Guardian Pattern / Mayéutic Challenge / Design Pipeline
  → Comparison table vs ECC / Taste Skill / Impeccable / Open Design

SECCIÓN 08: QUICK START (llenar contenido)
  → 3 paths: Local install / Manual copy / OpenCode plugin

SECCIÓN 09: COMPATIBLE AGENTS (nueva)
  → OpenCode, Claude Code, Cursor, Kiro

SECCIÓN 10: FAQ (llenar contenido)
  → 8 preguntas con respuestas

SECCIÓN 11: FOOTER (refinar)
  → Links a docs, GitHub, license
```

### Inspiración de cada web

| Sección | Fuente principal | Qué tomamos |
|---|---|---|
| Hero stats | ECC + Open Design | Stats pills prominentes |
| Problem section | Impeccable | "Your AI ships generic frontend by default" → adaptado |
| Skills grid | Taste Skill | Grid visual con iconos y filtros |
| How it works | ECC | 3 pasos con terminal |
| Different | Open Design | Comparison table method |
| FAQ | ECC | Preguntas reales de usuarios |
| Compatible agents | Taste Skill + Open Design | Logos de agentes soportados |

---

## 6. MEJORA DEL README

### Por qué

**README actual:** Solo tiene el contenido básico del repo. No tiene stats, instalación clara, comparison table, FAQ, ni compatible agents.

**Nuestro README propuesto debe tener:**
1. Tag line + stats pill ("54 skills · 9 design stages · 0 trust on agent")
2. Qué es (2-3 oraciones)
3. Instalación en 1 comando
4. Qué incluye (grid resumido)
5. Lifecycle flow visual
6. Comparison table (sin nosotros vs con nosotros)
7. Compatible agents
8. Quick start detallado
9. Link a la web completa
10. License

**No copiar:** El modelo de negocio de ECC (GitHub App, Pro $19/seat, Enterprise). Nosotros somos OSS puro.

---

## 7. ¿NECESITO MÁS INVESTIGACIÓN?

**NO.** Tengo todo lo necesario:

| Lo que sé | Fuente |
|---|---|
| Filosofía ECC | Análisis completo del repo + README |
| Filosofía Taste Skill | Web + skills analizados |
| Filosofía Impeccable | Web completa analizada |
| Filosofía Open Design | Web completa analizada |
| Tendencias agentic AI | Artículo System Design Newsletter |
| Nuestro estado actual | AGENTS.md, skills, scripts, website analizados |
| Nuestras debilidades | Comparación directa con ECC |
| Mejoras concretas | 10 items priorizados con esfuerzo/impacto |
| Pendientes de web | IMPLEMENTATION-PLAN.md + SESSION_CONTEXT.md |

**Lo que SÍ haría como paso opcional (no bloqueante):**
- Revisar 2-3 SKILL.md de ECC para comparar formato con los nuestros
- Ver cómo implementan selective install scripts
- Revisar el BATS test framework para escribir tests

Pero nada de esto bloquea el inicio. Podemos empezar Fase 1 HOY.

---

## 8. RESUMEN EJECUTIVO

| Pregunta | Respuesta |
|---|---|
| **¿El artículo afina nuestra filosofía?** | SÍ. Confirma enforcement mecánico, spec-driven, simplicity-first. Agrega "shared memory" como gap nuestro. |
| **¿Qué aprender del artículo?** | METR study como warning, "empty tests" como problema, shared memory como feature futura, maintenance como oportunidad. |
| **¿Es release o mejora?** | Minor release v1.5.0 — expande sin romper. |
| **¿Main o branches?** | Feature branches. Main siempre estable. Squash merge. |
| **¿Mejoramos README?** | SÍ. Stats, instalación, comparison table, FAQ. |
| **¿Más investigación?** | NO. Todo listo para empezar. |
| **¿Prioridad?** | Mejoras primero, web después (con contenido real). |
| **¿Había pendientes?** | SÍ — 8 items de web anterior integrados en Fase 4 (2 descartados: self-host fonts, copy button). |
| **¿Cuándo empezar?** | Fase 1 puede empezar HOY. |

---

## 9. PRÓXIMOS PASOS (Pending user approval)

1. Aprobar este plan
2. Crear branch `feat/soul-md` → escribir SOUL.md
3. Crear branch `feat/reaudit-healthcheck` → re-auditar
4. Crear branch `feat/rules-layered` → reestructurar rules
5. ... (siguientes branches según Fase 2-4)

**¿Aprobamos el plan y comenzamos Fase 1?**

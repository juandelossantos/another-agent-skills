# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **6.2.0** (Phase 7: OpenCode v1/v2, Multi-Agent & Guardrails released) |
| Next target | **v6.3.0** (finish Phase 8 remote enforcement → Phase 9 distribution) |
| Lint | 0 errors, 2 warnings |
| Health | 🟡 DEGRADED (2 skill-lint warnings) |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 53 suites passing (behavioral + task working set capped at 20) |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | **v4.0.0** | Foundation Repair & Critical Stubs |
| **QS** | **v4.1.0** | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |
| **4** | **v5.0.0** | Docs Honesty: 42 issues fixed across 6 groups, 86 files changed |
| **6** | **v6.0.0** | Design Skill Integrity: TDD enforcement (no override), 17-section DESIGN.md schema, 3-mode design-gate, token-validate CSS drift, approval-gate prototype→approved, design dir rules, design-upgrade.sh, direction+platform skill DESIGN.md wiring, critique-skill visual dimensions, prompt drift detection. 35+ commits, 80+ files changed. |
| **7** | **v6.2.0** | OpenCode v1/v2 & Multi-Agent: dual-contract plugin (`setup()` v2 + `server()` v1), multi-agent detection (15 agents) + version gating, per-agent skills/guardrails, **philosophy A** (agent never commits/pushes — no token bypass), global install hardening (`--plugin-only`/`--skills-only`/`--guardrails-only`). Merged to `main` via PR #35. |

---

## Phase 7: Cross-Platform Harness Parity (v7.0.0)

**Derived from:** deep analysis of [javierpa95/harness](https://github.com/javierpa95/harness)
**Focus fronts:** (A) Easy Dev Docs — clear, practical, discoverable docs
**Focus fronts:** (B) SEO — landing page + docs site optimization

### Task 7.1 — Claude Code `.claude/` Mirror

| Aspect | Scope |
|--------|-------|
| **What** | Create `.claude/` directory with agents/, commands/, skills/, settings.json mirroring `.opencode/` |
| **Files** | New: `.claude/agents/*.md` (8 agents), `.claude/commands/start.md`, `.claude/commands/end.md`, `.claude/settings.json`, `.claude/skills/handoff/SKILL.md` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` — add `.claude/` path in tables. Update `README.md` agent matrix: Claude Code → ✅ auto. Update `docs/agents.html` |
| **Docs (B)** | Add `CLAUDE.md` to landing page FAQ. Add structured data for Claude Code integration |
| **SEO** | New keywords: "Claude Code", "Anthropic agent", "Claude Code skills" — update meta keywords in all HTML. Add OG tags to `docs/agents.html` |
| **Gate** | pre-commit validates `.claude/` mirrors `.opencode/agents/` |
| **Tests** | adapter test: both `.claude/` and `.opencode/` agent counts match |

### Task 7.2 — Cursor `.cursor/` Mirror

| Aspect | Scope |
|--------|-------|
| **What** | Create `.cursor/rules/` (4 rules), `.cursor/instructions.md`. Update `.cursor-plugin/` to use `.cursor/` instead of symlinks |
| **Files** | New: `.cursor/rules/*.md`, `.cursor/instructions.md`. Updated: `.cursor-plugin/agent-discipline/` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` Cursor section. Update `docs/getting-started.html` Cursor tab. Update `QUICKSTART.md` |
| **Docs (B)** | Add "Cursor AI", "Cursor agent rules" keywords. Add `.cursor/rules/` path to `docs/agents.html` |
| **SEO** | New FAQ entry: "Does this work with Cursor?" — yes, with `.cursor/rules/`. Link from FAQ → `docs/agents.html#cursor` |
| **Gate** | pre-commit validates `.cursor/rules/` mirrors `.opencode/rules/` |
| **Tests** | adapter test: both directories parse correctly |

### Task 7.3 — Devin/Kiro Config Update

| Aspect | Scope |
|--------|-------|
| **What** | Update `.kiro/hooks/` to match current script paths. Add `.devin/config.md` |
| **Files** | `.kiro/hooks/agent-discipline.json`, new: `.devin/config.md` |
| **Docs (A)** | Update `docs/AGENT-ADAPTERS.md` Devin+Kiro. Add Devin setup to `docs/getting-started.html` |
| **Docs (B)** | New section in `docs/agents.html` for Devin Desktop workflow |
| **SEO** | Keywords: "Devin AI", "Devin Desktop", "Kiro agent" — meta keywords |
| **Gate** | verify `.kiro/hooks/agent-discipline.json` parses as valid JSON |
| **Tests** | install with `bash install.sh --agent kiro`, verify hooks load |

### Task 7.4 — Shared Memory System

| Aspect | Scope |
|--------|-------|
| **What** | Create `agent-memory/` (git-tracked) with per-agent MEMORY.md files |
| **Files** | New: `agent-memory/README.md`, `agent-memory/spec-writer/MEMORY.md`, `agent-memory/code-reviewer/MEMORY.md`, `agent-memory/docs-auditor/MEMORY.md` |
| **Docs (A)** | New `docs/memory.html` — how per-agent memory works. Update `docs/customization.html`, `docs/getting-started.html` |
| **Docs (B)** | "agent memory", "persistent context" keywords in meta. Link from landing page "How It Works" → `docs/memory.html` |
| **SEO** | Dedicated memory page with structured data. Value prop: "<1% of agent frameworks have persistent memory" |
| **Gate** | `agent-memory/README.md` exists and references all agent dirs |
| **Tests** | memory test: create entry, verify agent can read it |

### Task 7.5 — Shared Makefile Control Panel

| Aspect | Scope |
|--------|-------|
| **What** | Create `Makefile` with targets: `make help`, `make skills`, `make gates`, `make check`, `make memory`, `make hooks`, `make health`, `make docs` |
| **Files** | New: `Makefile`. Update: `README.md` commands table |
| **Docs (A)** | Add `make` commands table to `README.md`. "Quick Reference" card on `docs/index.html`. Update `docs/getting-started.html` |
| **Docs (B)** | Landing page "Quick Start": `make help` as first command. Terminal code blocks in `docs/quickstart-guide.html` |
| **SEO** | Low direct. Medium UX (lower bounce rate). `make` code blocks for rich snippets |
| **Gate** | `make help` exits 0 |
| **Tests** | run all targets, verify exit codes |

### Task 7.6 — Interactive `init.sh` Setup

| Aspect | Scope |
|--------|-------|
| **What** | Interactive script: asks project name, type, stack, design system → generates STACK_CONFIG.md, selects skills, installs hooks |
| **Files** | New: `init.sh`, `init.ps1`. Update: `install.sh` (optional delegation) |
| **Docs (A)** | Update `docs/getting-started.html` flow: Install → init.sh → init-agents. Walkthrough in `docs/quickstart-guide.html`. Update `QUICKSTART.md` |
| **Docs (B)** | Hero command: `bash init.sh` (more approachable). "Guided setup" as hero feature |
| **SEO** | "interactive setup", "project scaffolding" keywords. Step-by-step CLI output rich results |
| **Gate** | `bash init.sh --dry-run` exits 0 |
| **Tests** | pipe answers to init.sh, verify generated files exist |

### Task 7.7 — commitlint + Conventional Commits

| Aspect | Scope |
|--------|-------|
| **What** | Add `commitlint` + Husky for THIS repo. Custom `security` commit type. Update `commit-msg` hook to validate conventional commits + TDD |
| **Files** | New: `commitlint.config.js`. Update: `package.json`, `scripts/git-hooks/commit-msg` |
| **Docs (A)** | Update `docs/getting-started.html` commit section. Add conventional commits to `docs/quickstart-guide.html`. Update `CONTRIBUTING.md` |
| **Docs (B)** | Add commit format to `docs/rules.html`. Document `security` type in `docs/enforcement.html` |
| **SEO** | "conventional commits for AI agents" long-tail content depth |
| **Gate** | `npx commitlint --from HEAD~1 --to HEAD` passes |
| **Tests** | good message passes, bad message fails |

### Task 7.8 — Docs-Auditor Pre-Commit Gate

| Aspect | Scope |
|--------|-------|
| **What** | Pre-commit Gate 15: if source files changed, verify corresponding docs updated. Warn-only |
| **Files** | Update: `scripts/git-hooks/pre-commit` (add Gate 15). New: `scripts/verify-docs.sh` |
| **Docs (A)** | Update `docs/enforcement.html` gate list (15→16). Update `i18n/en.json` + `i18n/es.json`. Update `docs/quickstart-guide.html` |
| **Docs (B)** | Landing page hero: "15 gates" → "16 gates". Update `docs/index.html` "What's New". All gate count refs across landing, docs, i18n |
| **SEO** | Gate count increment = content refresh across all pages (recrawl signal). Update SoftwareApplication schema |
| **Gate** | pre-commit runs `scripts/verify-docs.sh`, warns on stale docs |
| **Tests** | update source without updating docs → warning fires |

### Task 7.9 — Dev Docs Clarity Overhaul

| Aspect | Scope |
|--------|-------|
| **What** | Full-text search on `docs/` via client-side JS indexing. 5 concept pages (Guardian Pattern, TDD Gate, Design Gate, Skill Gate, Context Engineering). JSON-LD structured data on ALL docs pages |
| **Files** | Update: `docs/js/docs.js`, `docs/index.html` (search). New: `docs/concepts/guardian-pattern.html`, `tdd-gate.html`, `design-gate.html`, `skill-gate.html`, `context-engineering.html`. ALL `docs/*.html` (structured data) |
| **Docs (A)** | Consistent H1 + meta desc on all pages. Concept pages link to skills, guides, rules. "Related" sections on major pages |
| **Docs (B)** | JSON-LD SearchAction for Sitelinks Search Box. Concept pages target distinct long-tail keywords. Bidirectional link graph: concept → skill → rule → enforcement |
| **SEO** | HIGH — 5 topic-cluster pages interlinking with 57 skill pages. TechArticle/HowTo/FAQ schemas for rich results. Topical authority for "AI agent enforcement" |
| **Gate** | Google Rich Results Test passes for every page. Each concept page has ≥3 internal links |
| **Tests** | batch validate all HTML with structured data linter. 5 search queries return expected results |

### Task 7.10 — SEO Infrastructure

| Aspect | Scope |
|--------|-------|
| **What** | Auto-generated sitemap with hreflang (EN/ES). Core Web Vitals (Lighthouse 90+ all pages). Internal link audit (zero broken links) |
| **Files** | Update: `sitemap.xml`, `robots.txt`, `css/style.css` (inline critical), all HTML (preload, lazy-load). New: `scripts/generate-sitemap.sh` |
| **Docs (A)** | Add hreflang `<link>` tags to all pages. "Related Skills" sections for discoverability |
| **Docs (B)** | Hreflang for bilingual SEO. CWV ranking signals. Hub pages (enforcement.html, lifecycle.html) link to all 57 skills for authority flow |
| **SEO** | HIGH — hreflang for bilingual indexation, CWV as ranking signal, dense internal link graph for topical authority. 70+ pages with zero broken links |
| **Gate** | Lighthouse 90+ all page types. Zero broken internal links. `scripts/generate-sitemap.sh` exits 0 |
| **Tests** | Lighthouse CI batch audit (fail if <85). Broken link auditor on all HTML. Sitemap validates against schema |

---

## Summary

| Metric | Current | Target v7.0.0 |
|---|---|---|
| Platforms | 1 (OpenCode full) | 4 (OpenCode + Claude + Cursor + Devin) |
| Attribution | In README only | Dedicated ATTRIBUTION.md + docs page |
| Memory | Session-only | Per-agent persistent MEMORY.md |
| Makefile | None | Full control panel (10+ targets) |
| Interactive setup | None | `init.sh` guided CLI |
| Docs search | None | Client-side full-text search |
| Concept pages | 0 | 5 standalone concept pages |
| Structured data | 1 page (landing) | All 14+ docs pages |
| Pre-commit gates | 15 | 16 (+ Docs-Auditor) |
| Lighthouse | ~85-95 | 90+ all pages |
| Internal links | Manual | Auto-audited, zero broken |
| Hreflang | None | All pages EN ↔ ES |
| Sitemap | Static | Auto-generated from git |

---

## Release Checklist v7.0.0

- [ ] All 4 platform adapters created and tested (7.1-7.3)
- [ ] Shared agent-memory/ with per-agent MEMORY.md (7.4)
- [ ] Makefile with 10+ targets passing (7.5)
- [ ] init.sh/init.ps1 interactive setup flow tested (7.6)
- [ ] commitlint + conventional commits for this repo (7.7)
- [ ] Docs-Auditor Gate 15 added to pre-commit (7.8)
- [ ] 5 concept pages created with bidirectional link graph (7.9)
- [ ] Structured data on ALL docs pages (7.9)
- [ ] Full-text search on docs/ (7.9)
- [ ] Sitemap auto-generated, hreflang added (7.10)
- [ ] Lighthouse 90+ on all page types (7.10)
- [ ] Zero broken internal links (7.10)
- [ ] i18n EN/ES updated across all new pages
- [ ] Version bumped to 7.0.0
- [ ] Release notes written

---

## Phase 7: OpenCode v1/v2 Plugin Compatibility (v6.2.0) — ✅ RELEASED

**Status:** ✅ **RELEASED as v6.2.0** (tag `v6.2.0`, merged to `main` via PR #35). P7.1–P7.9 done: dual-contract plugin, multi-agent detection + version gating, per-agent skills/guardrails, philosophy A, global install hardening. See `RELEASE-NOTES.md` (6.2.0).
**Branch:** `fix/opencode-v2-plugin-compat`
**Goal:** Todo plugin instalado por `init-agents.sh` / `install.sh` (especialmente `agent-discipline`) debe cargar y funcionar en OpenCode v1 (latest 1.x) **y** v2 (≥ 2.0.x).

**Why (evidencia del 2026-09-24, workspace club-team-chia-badminton):**

- OpenCode v2 rechaza los plugins con contrato v1 y **falla en silencio** para el usuario (solo un WARN en el log):

  ```
  level=WARN message="failed to load plugin" target=.../agent-discipline
  cause="PluginModule.LoadError: Plugin must export a default definition with an
  id and an effect or setup function. (cause: SchemaError(Missing key at ["default"])))"
  ```

- El loader v2 valida el `default export` contra el schema `{ id, effect | setup }` (Effect Schema). Los hooks v1 (`tool` map, `event`, `tool.execute.before/after`, `chat.message`, `experimental.session.compacting`) **no se ejecutan en v2** — el binario v2 no contiene ni una referencia a `experimental.session.compacting`.
- `init-agents.sh` / `install.sh` instalan hoy el plugin v1-style → todo usuario que ejecute `init-agents` sobre OpenCode v2 pierde agent-discipline (y cualquier plugin) sin darse cuenta.
- Doc oficial de migración: https://opencode.ai/v2/docs/build/plugins/migrate-v1
- Issue upstream confirmando el problema: anomalyco/opencode#42878

**Solución (patrón dual-contract):** un solo default export que atiende ambos loaders:

```ts
import { Plugin } from "@opencode/plugin"

export default {
  ...Plugin.define({
    id: "example",
    async setup(ctx) {
      // v2: registrar hooks por dominio
      await ctx.tool.hook("execute.before", (event) => { /* event.input, event.tool */ })
    },
  }),
  async server() {
    // v1 (object form, soportado en OpenCode 1.18.29+): devolver hooks v1
    return { "tool.execute.before": async (input, output) => { /* ... */ } }
  },
}
```

**Tabla de migración v1 → v2 (verificada en runtime 2.0.16):**

| v1 | v2 |
|---|---|
| `tool` map (`tool()` helper, args zod) | `ctx.tool.transform(editor.add({ name, description, input: JSONSchema, execute }))` — args zod → JSON Schema con `z.toJSONSchema` |
| `event` | `ctx.event.subscribe({ signal })` (for await; eventos usan `data`, no `properties`) |
| `tool.execute.before/after` | `ctx.tool.hook("execute.before"/"execute.after")` — evento v2: `{ tool, sessionID, agent, messageID, id, input }`; bloquear = `throw Error` |
| `chat.message` | `ctx.session.hook("prompt")` |
| `experimental.session.compacting` | `ctx.session.hook("compaction")` — inyectar en `event.system` |
| `directory` | `ctx.location.directory` (resolver por-ejecución si es multi-proyecto) |
| bloquear en `execute.before` | `throw new Error(...)` |

**Puerto de referencia ya validado en runtime v2.0.16** (recuperar de `~/.config/opencode/plugins/` y `.plugin-backups/`):
- `ars/index.js` — 7 tools + compaction + audit log, portados a v2 ✓
- `warp-notifications.js` — port v2 del plugin de Warp (upstream `@warp-dot-dev/opencode-warp` 0.1.7 sigue siendo v1-only) ✓
- `agent-discipline/index.js` — port v2 con enforcement (pre-flight, commit-approval con token, guardian, edit-guard pasivo, anti-slop) ✓

### Tasks

| Task | Descripción | Criterio de aceptación |
|---|---|---|
| **P7.1** 🔴 | Mover el port de `agent-discipline` al repo (fuente de verdad aquí), implementando el **dual-contract** (`setup()` v2 + `server()` v1 en un solo default export). Sincronizar con el port validado del workspace. | Plugin carga sin `failed to load plugin` en v1 y v2; `git commit` bloqueado sin token en ambas versiones |
| **P7.2** 🔴 | Actualizar `init-agents.sh` e `install.sh`: instalar solo plugins dual-contract; detectar versión de OpenCode (`opencode --version`) y avisar con error visible si se instala un plugin v1-only sobre v2 | Ejecutar `init-agents` sobre OpenCode v2 → plugins cargan; log sin WARNs de plugin |
| **P7.3** 🔴 | Documentar: matriz de compatibilidad en `docs/AGENT-ADAPTERS.md`, addendum en `ADRs/005-native-js-plugin-agent-discipline.md` (v1 object form deprecado, tabla de migración), nota en README | Docs reflejan el contrato dual y la tabla v1→v2 |
| **P7.4** 🔴 | Suite de pruebas: matriz opencode v1-latest × v2-latest × (plugin instala, carga, tools visibles, enforcement activo); assert: `grep "failed to load plugin" ~/.local/share/opencode/log/opencode.log` sin entradas nuevas | Test suite passing en ambas versiones |

**Need evidence (RED) actual:**
- `grep "failed to load plugin" ~/.local/share/opencode/log/opencode.log | grep agent-discipline` → 30+ entradas `SchemaError(Missing key at ["default"])` antes del port
- `opencode --version` → `opencode v2.0.16` (runtime actual: **v2.0.20**)

### P7 Addendum — Multi-agente, skills completas y guardrails (2026-09-30)

**Contexto nuevo:** el runtime actual es **OpenCode v2.0.20**. Además del bug de contrato v1→v2 (P7.1–P7.4), la revisión de `init-agents.sh` / `install.sh` / `docs/AGENT-ADAPTERS.md` detectó tres huecos que impiden *"usar todas las skills y los guardrails"* según el agente que se use:

1. **El plugin del repo sigue siendo v1-only.** `.opencode/plugins/agent-discipline/src/index.ts` exporta `register(plugin)` + `plugin.on(...)` (contrato v1) y `plugin.json` usa el formato `events`/`hooks` que OpenCode nunca cargó. El port v2 validado vive **solo** en `~/.config/opencode/plugins/agent-discipline/index.js` (fuera del repo, sin versionar) y además usa `.git/COMMIT_APPROVED` + lógica OVERRIDE — **desincronizado** con el diseño v6 (DECISION_APPROVED, TDD sin override).
2. **`init-agents.sh` no detecta el agente/TUI y no instala skills ni guardrails.** `detect_target()` solo mira 5 archivos (`AGENTS.md`, `CLAUDE.md`, `.cursorrules`, `.claude/CLAUDE.md`, `.opencode/AGENTS.md`); no detecta Gemini, Codex/GPT, Grok, DeepSeek, Aider, Windsurf, Cline/Roo, Continue, Kiro, Zed, Amazon Q. No instala las 57 skills (solo `self-improvement`), ni el plugin/hooks por agente, ni advierte de la versión de OpenCode.
3. **Docs sobre-implementan.** `docs/AGENT-ADAPTERS.md` documenta "Shell Scripts (All Other Agents)" y una sección "Adding a New Agent", pero `install.sh --agent` solo soporta `claude|cursor|kiro`, y `init-agents` no detecta nada. El propio `rules/common/behavioral.md` (Rule 0k) exige soporte para *OpenCode, Claude Code, Cursor, Devin y Gemini CLI* — ni Devin ni Gemini están cubiertos.

**Nota de alcance:** P7.2 se **amplía** en P7.5 (detección) y P7.7 (guardrails). P7.5–P7.9 no reemplazan P7.1–P7.4; los extienden con la dimensión multi-agente.

| Task | Prioridad | Descripción | Deliverable | Criterio de aceptación |
|---|---|---|---|---|
| P7.5 | 🔴 P0 | **Motor de detección de agente/TUI**, data-driven y extensible. Señales en orden: (1) flag `--agent <name>`; (2) env vars del runtime (`OPENCODE_*`, `CLAUDE_*`, `GEMINI_*`, `CODEX_*`/`OPENAI_*`, `CURSOR_*`, `AIDER_*`, `WINDSURF_*`, `KIRO_*`, `ZED_*`, `GROK_*`/`XAI_*`, `DEEPSEEK_*`); (3) dot-dirs/archivos del proyecto (`.opencode/`, `.claude/`, `.cursor/`, `.gemini/`, `.codex/`, `.aider*`, `.windsurf*`, `.cline*`/`.roo*`, `.continue/`, `.kiro/`, `.zed/`, `.amazonq/`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`); (4) instalaciones globales (`~/.config/opencode`, `~/.claude`, `~/.gemini`…); (5) binarios en PATH (`opencode`, `claude`, `cursor`, `gemini`, `codex`, `aider`, `windsurf`…). Soporta **multi-agente** (varios detectados, no solo el primero). Si es ambiguo → prompt (Rule 0c: preguntar, no adivinar) | `detect_agents()` que devuelve lista de perfiles + flags `--agent` / `--all-agents` / `--list-agents`; tabla de señales en `docs/AGENT-ADAPTERS.md` | Test con directorios fixture por agente: cada uno detecta su(s) agente(s) correctos; multi-agente devuelve todos; `--agent` fuerza; ambigüedad pide input |
| P7.6 | 🔴 P0 | **Instalar TODAS las skills** por agente detectado, en la ruta correcta. Hoy solo se copia `self-improvement` y solo se contemplan `.claude/` y `.opencode/`. Añadir mapa agente→ruta de skills (`.opencode/skills`, `.claude/skills`, `.gemini/…`, `.codex/…`, etc., fallback a `skills/`) y enlazar/copiar las 57 con idempotencia y sin pisar locales | `install_skills_for_agent()` + mapa de rutas; salida muestra "N skills instaladas por agente" | Proyecto nuevo con cada agente → sus 57 skills disponibles en la ruta que ese agente lee; re-run no duplica ni pisa |
| P7.7 | 🔴 P0 | **Instalar guardrails por agente** (unificado). OpenCode → plugin dual-contract (P7.1); Claude → `.claude-plugin/`; Cursor → `.cursor-plugin/`; Kiro → `.kiro/hooks/`; resto (Gemini, Codex/GPT, Grok, DeepSeek, Aider, Windsurf, Cline/Roo, Continue, Zed, Amazon Q) → rules-file correcto + hooks git + guardrails compatibles donde exista API de hooks. Añadir plantillas de rules-file por agente (hoy solo hay `CLAUDE.md` y `.cursorrules`). Detectar versión OpenCode (`opencode --version`) con **error visible** si se instala v1-only sobre v2 | `install_guardrails_for_agent()` + `templates/agents/<agent>.*` + chequeo de versión | Cada agente obtiene sus guardrails; en OpenCode v2 el plugin carga sin `failed to load plugin`; en v1 y v2 el commit sin token se bloquea |
| P7.8 | 🟠 P1 | **Reconciliar el port v2 con el diseño v6** y traerlo al repo como fuente de verdad. Reemplazar `.git/COMMIT_APPROVED`→`.git/DECISION_APPROVED`, eliminar la lógica OVERRIDE (v6 es sin override), alinear con el TDD gate, y añadir `server()` para el contrato v1 (dual-contract) | `src/index.ts` dual-contract en el repo + `plugin.json`/`package.json` coherentes; ADR-005 actualizado | El plugin del repo es la única fuente; carga en v1 y v2; semántica v6 (DECISION_APPROVED, sin override) verificada por test |
| P7.9 | 🟠 P1 | **Matriz de compatibilidad + docs + tests de instalación**. Extender P7.3/P7.4 con la dimensión multi-agente. Corregir `docs/AGENT-ADAPTERS.md` (sección OpenCode describe el contrato v1 obsoleto) y `AGENT_USAGE` de `install.sh` | `docs/AGENT-ADAPTERS.md` (matriz agente × skills × guardrails × versión), `tests/test-agent-detection.sh`, `tests/test-install-per-agent.sh` | Matriz completa; tests de detección e instalación pasan por agente; `AGENT_USAGE` lista todos los agentes |

**Need evidence (RED) nuevo:**
- `sed -n '1,11p' .opencode/plugins/agent-discipline/src/index.ts` → `export function register(plugin)` (contrato v1)
- `ls ~/.config/opencode/plugins/agent-discipline/index.js` → port v2 existe **solo fuera del repo**; `grep COMMIT_APPROVED` → token viejo (no v6)
- `grep -n "candidates=" scripts/init-agents.sh` → solo 5 configs, sin Gemini/Codex/Grok/DeepSeek/etc.
- `grep -rn "skill_dest_dir" scripts/init-agents.sh` → solo `self-improvement`; no instala las 57 skills
- `grep -n "claude|cursor|kiro" install.sh` → `--agent` solo soporta 3 agentes
- `opencode --version` → `opencode v2.0.20`

**Estado de preparación para arrancar P7 (readiness):**
- Runtime verificado: `opencode v2.0.20`.
- Port v2 validado disponible para recuperar: `~/.config/opencode/plugins/agent-discipline/index.js` (+ `src/`).
- Rama a crear: `fix/opencode-v2-plugin-compat` (no existe aún).
- Primer paso sugerido: **P7.8** (traer el port al repo y reconciliarlo con v6) → **P7.1** (dual-contract) → **P7.5/P7.6/P7.7** (init-agents multi-agente) → **P7.2/P7.3/P7.9** (docs/tests).
- Bloqueante de decisión: en P7.8 hay que decidir la semántica final del token (`.git/DECISION_APPROVED` escrito por el agente vs. no-forjable) — enlaza con P8.4.

**Progreso (2026-09-30):**
- ✅ Rama `fix/opencode-v2-plugin-compat` creada.
- ✅ **P7.1 + P7.8 completados** — `plugins/agent-discipline/index.js` es la fuente de verdad con **contrato dual** (`setup()` v2 + `server()` v1). Con **filosofía A** (P7.7) la semántica final es **deny incondicional**: ningún token (ni `.git/DECISION_APPROVED` ni OVERRIDE) desbloquea `git commit`/`push`; el usuario los corre (Rule 12). Se eliminaron los artefactos v1 muertos: `plugin.json` (formato `events`/`hooks` que OpenCode nunca cargó), `src/*.ts`, `tsconfig.json`, `dist/`.
- Verificado: `node --check` OK; el contrato dual expone `id` + `setup` + `server`; el clasificador segment-aware bloquea `git commit`/`push` incondicionalmente (también `cd x && git commit`, `FOO=bar git commit`, `env/sudo git commit`, `git -C dir commit`) y permite `git status`/`git commit-tree`. Suite completa en verde.
- Pendiente: P7.2 (install/init-agents instalan dual-contract + detectan versión), P7.5–P7.7 (multi-agente), P7.3/P7.9 (docs/tests). Validación de carga real en OpenCode v2.0.20 → P7.4.
- Nota: el plugin global en `~/.config/opencode/plugins/agent-discipline/` sigue con semántica vieja (`COMMIT_APPROVED` + OVERRIDE) → P7.2 debe reemplazarlo para evitar doble enforcement.
- ✅ **P7.2 completado** — `install.sh --plugin-only` reemplaza atómicamente el plugin global (borra artefactos v1: `plugin.json`, `src/`, `dist/`, `node_modules`), pone en cuarentena los `agent-discipline.backup.*` a `.plugin-backups/`, verifica que quede **una sola** instancia y detecta la versión de OpenCode (avisa si < 1.18.29). `init-agents.sh --check-env` reporta la versión y el estado del plugin (`legacy`/`dual-contract`). Esto cierra el doble enforcement confirmado en el log de OpenCode (dos `agent-discipline` cargados con el mismo `id`).
- ✅ **P7.5 (núcleo) completado** — `scripts/agent-detect.sh`: motor de detección multi-agente (binario en `PATH` + dir global bajo `$HOME` + archivos de proyecto + override `AAS_AGENTS`), con 15 agentes soportados. Wire en `init-agents.sh`: `--list-agents` y `--check-env` reporta `agents=`. Pendiente: P7.6/P7.7 (instalar skills/guardrails por agente) y P9.4 (selección interactiva TTY).
- ✅ **P7.6 completado** — `agent_skills_dir()` (mapa `agent→skills`: opencode `.config/opencode/skills`, claude `.claude/skills`, gemini `.gemini/skills`). `install.sh --skills-only` + `install_skills_for_detected_agents()`: enlaza (symlink) las 57 skills del repo desde el dir canónico de OpenCode hacia el dir de cada agente detectado (una sola fuente de verdad), idempotente, con backup solo si el contenido difiere. Wire en `main()`. Pendiente: P7.7 (guardrails por agente) y P9.4 (selección interactiva).
- ✅ **P7.7 completado — filosofía A (deny incondicional)** — el agente **nunca** corre `git commit`/`push`, sin bypass de token. Plugin de OpenCode (`index.js`) pasa de token-allow a **deny**; guardrail canónico de Claude (`.claude-plugin/agent-discipline/hooks/commit-approval.sh`) reescrito a deny; `agent_guardrails_kind()` + `install.sh --guardrails-only` instala guardrails por agente detectado (opencode → plugin; claude → hooks + registro en `~/.claude/settings.json`, idempotente con backup; resto → skip). Alinea con Rule 12 y cierra por diseño el agujero del token auto-emitido (P8.4).
- ✅ **P7.7b — coherencia del plugin** — el error `Duplicate plugin ID: agent-discipline` (plugin del repo auto-cargado + global, mismo `id`) se resolvió moviendo la fuente a `plugins/agent-discipline/` (fuera de `.opencode/plugins/`, que OpenCode auto-escanea). `install.sh`, tests y CODEOWNERS actualizados.
- ✅ **P7.3 completado** — `docs/AGENT-ADAPTERS.md` (matriz agente × skills × guardrails, contrato dual, filosofía A, ruta `plugins/agent-discipline/`), addendum en `ADRs/005-native-js-plugin-agent-discipline.md` (v1 object form deprecado, tabla de migración), y backlog **B3** (tdd-gate false-pass).

### Lección de revisión — el clasificador de comandos debe ser una única fuente de verdad

**Contexto:** la revisión final del PR (iteraciones C1/C2/C4) encontró que el
**clasificador de comandos** (qué constituye un `git commit`/`push`/…) estaba
**duplicado por adaptador** — una copia en el plugin de OpenCode
(`plugins/agent-discipline/index.js`), otra en el hook de Claude
(`.claude-plugin/agent-discipline/hooks/_risky-commands.sh`) y otra en el hook de
Cursor (`.cursor-plugin/agent-discipline/hooks/commit-approval.sh`) — cada una
con su propio `stripPrefixes` anclado a mano.

**Qué se rompió:** las copias **derivaron**. `env -i git commit` y
`sudo -n git commit` eran *bloqueados* por Claude pero *permitidos* por el plugin
de OpenCode y por Cursor, porque su regla genérica «pela el flag y su valor»
consumía el token `git` como valor de `-i`/`-n` (bug C1). Los wrappers
`command`/`nohup`/`time`/`xargs` y los subshells `(git commit)`/`{ git commit; }`
tenían el mismo destino (C2). Un clasificador que se copia y se ancla de memoria
es, por construcción, **bypasseable** en el adaptador que se olvidó de actualizar.

**Regla:** al tocar la clasificación, actualizar **todos** los adaptadores
(OpenCode v1+v2, Claude, Cursor) y añadir casos de paridad en los tests. Un
`stripPrefixes` sólo pela **wrappers conocidos** (`sudo`/`env`/`command`/`nohup`/
`time`/`nice`/`xargs`/`exec`) y sus opciones, y **nunca** consume el token `git`
como valor de un flag. La paridad v1/v2 está asertada en
`tests/test-agent-discipline-index.sh`.

---

## Phase 8: Remote Enforcement — Gate Integrity (v6.2.0) — 🔄 IN PROGRESS

**Status (2026-10-02):** ✅ **P8.1–P8.3 DONE and ACTIVE.** `.github/workflows/gates.yml` runs the real gates and is the required `gates` check; `scripts/setup-branch-protection.sh` (solo-safe + lockout guard + code-owner guard) applied branch protection to `main` (PR required, `gates` required, 0 approvals, no force-push/deletions, admin bypass allowed → no lockout); `CODEOWNERS` protects the gate config. ✅ **P8.4 closed by design** (philosophy A: the agent never commits/pushes — no self-issued token to close). ⬜ Remaining: **P8.5** (docs honesty), **P8.6** (ship remote layer via `init-agents`/`install`), **P8.7** (remote E2E).
**Branch:** `feat/phase8-remote-enforcement`
**Base:** `main`
**Goal:** El gate que *decide* debe vivir donde el agente no pueda escribirlo. Hoy todos los gates viven en `.git/hooks/` (escribible por el agente) y en scripts del propio repo. Esta fase añade la capa de autoridad remota (required status checks + branch protection), protege la configuración del gate, y cierra el agujero del token auto-emitido.

**Why (evidencia del 2026-09-30, este repo):**

- `gh api repos/:owner/:repo/branches/main/protection` → `404 Branch not protected`. No hay required status checks: nada bloquea un merge a `main` del lado remoto.
- `.github/workflows/ci.yml` existe pero solo ejecuta comandos de `STACK_CONFIG.md` (test/lint/build) y **no es required check**; no corre `tdd-gate.sh` ni los 15 gates.
- `docs/enforcement.html` (INCIDENT_004) afirma *"Added main branch protection"*. Lo que existe es el **Gate 1 local** (verifica rama). No es branch protection remota → doc falsa.
- `.git/hooks/` es escribible por el agente. `core.hooksPath` puede reapuntarse a un directorio vacío; el hook puede editarse. Ni uno ni otro disparan `--no-verify`.
- `.git/DECISION_APPROVED` lo escribe **el agente** según el flujo documentado → el "token de aprobación" es auto-emitido; no es enforcement contra un agente que se desvía.
- Bypass files activos: `SKIP_TEST_GATE` (Gate 14) y `SKIP_TEST_RUNNER`.
- `CODEOWNERS` existe (`* @juandelossantos`) pero sin branch protection no tiene efecto.

**Modelo de 3 capas (lo que esta fase formaliza):**

| Capa | Dónde vive | Qué garantiza | Naturaleza |
|---|---|---|---|
| L1 — Feedback local | `.git/hooks/*` | Falla rápido, informa, deja rastro (`APPROVAL_LOG`), hace visible el DECISION POINT | Ergonomía para agente cooperativo. **No es seguridad.** |
| L2 — Autoridad remota | Branch protection + required status checks | Nada entra a `main` sin pasar los gates | Enforcement real. Requiere que el agente no pueda pushear/mergear directo. |
| L3 — Integridad de la config | CODEOWNERS + review obligatoria sobre `ci.yml`, `gates.yml`, `scripts/*gate*`, `scripts/git-hooks/**`, `.github/workflows/**` | El agente no puede editar sus propias reglas en el mismo PR que las viola | Cierra el hueco "CI remoto es forjable si el agente edita el workflow". |

Principio rector: *se diseña para el agente cooperativo, se enforza para el adversarial. L1 es primario para el cooperativo; L2+L3 son el backstop.*

### Tasks

| Task | Prioridad | Descripción | Deliverable | Criterio de aceptación |
|---|---|---|---|---|
| P8.1 ✅ DONE | 🔴 P0 | Activar branch protection en `main` vía script idempotente | `scripts/setup-branch-protection.sh` (usa `gh api`) + `docs/BRANCH-PROTECTION.md` | `gh api .../branches/main/protection` → 200; push directo a `main` rechazado; merge sin check requerido bloqueado |
| P8.2 ✅ DONE | 🔴 P0 | Workflow de gates reales, separado del `ci.yml` genérico | `.github/workflows/gates.yml` que corre `tdd-gate.sh`, `tests/run-all.sh`, `skill-lint.sh`, `design-gate.sh --verify`, `token-validate.sh` | El workflow corre en PR; configurado como required status check; un PR con test faltante falla en CI (no solo en local) |
| P8.3 ✅ DONE | 🔴 P0 | Proteger la configuración del gate (L3) | CODEOWNERS extendido (`.github/workflows/`, `scripts/git-hooks/`, `scripts/*gate*`, `scripts/tdd-gate.sh`, `scripts/edit-guard.sh`) + "Require review from Code Owners" activado en P8.1 | Un PR que edite `gates.yml` o `tdd-gate.sh` sin review de `@juandelossantos` no puede mergear |
| P8.4 ✅ CLOSED | 🟠 P1 | Cerrar el agujero del token auto-emitido. Dos caminos (decisión de diseño): (a) mecanismo no forjable por el agente (approval fuera del alcance de escritura del agente / firmado / trailer de commit verificado), o (b) reclasificar honestamente en docs como "prompt de proceso, no enforcement" y renombrar | Decisión documentada en ADR nuevo + implementación o reclasificación de docs; `SKIP_TEST_GATE`/`SKIP_TEST_RUNNER` neutralizados (requieren token + log, o eliminados) | El flujo de aprobación no puede ser satisfecho por el agente sin acción humana verificable, **o** los docs dejan de llamarlo enforcement |
| P8.5 ⬜ PENDING | 🟠 P1 | Docs honesty: corregir afirmaciones falsas y documentar el modelo de 3 capas | `docs/enforcement.html` + `docs/i18n/*` (INCIDENT_004: "branch protection" → Gate 1 local), `scripts/git-hooks/README.md` (quitar `--no-verify` obsoleto), sección L1/L2/L3 en `docs/` | `grep -ri "branch protection" docs/` sin afirmaciones falsas; README de hooks refleja v6 real |
| P8.6 ⬜ PENDING | 🟠 P1 | Ship-to-users: `init-agents`/`install` generan la capa remota | Plantilla `.github/workflows/gates.yml` para proyectos + `setup-branch-protection.sh` copiado + checklist en `docs/AGENT-ADAPTERS.md` | Un proyecto nuevo con `init-agents` obtiene workflow remoto + instrucciones de branch protection; doc explica por qué local ≠ autoridad |
| P8.7 ⬜ PENDING | 🟡 P2 | Verificación end-to-end del enforcement remoto | Test `tests/test-remote-enforcement.sh` + documento de evidencia | Test prueba: (1) PR con gate roto → merge bloqueado; (2) push directo → rechazado; (3) edición de `gates.yml` sin review → bloqueada; (4) `core.hooksPath` a directorio vacío + commit → CI lo atrapa igual |

**Need evidence (RED) — histórico, pre-P8.1 (ya resuelto):**
- `gh api repos/:owner/:repo/branches/main/protection` → `404 Branch not protected`
- `grep -rn "main branch protection" docs/` → afirmación sin respaldo mecánico remoto
- `.git/hooks/` escribible; `git config core.hooksPath` → unset

**Progreso (2026-10-02):**
- ✅ **P8.1 — branch protection ACTIVE.** `scripts/setup-branch-protection.sh` (solo-safe + lockout guard + code-owner guard) aplicado a `main`. Verificado: `gh api repos/.../branches/main/protection` → required check `gates`, 0 approvals, code-owner reviews off (solo), `enforce_admins: false` (sin lockout). Documentado en `docs/BRANCH-PROTECTION.md`.
- ✅ **P8.2 — `.github/workflows/gates.yml`** corre `tdd-gate.sh`, `tests/run-all.sh`, `skill-lint.sh`, `validate-skill-table.sh` y syntax-check de scripts; es el **required status check** `gates`.
- ✅ **P8.3 — L3 config integrity.** `CODEOWNERS` protege `.github/workflows/`, `scripts/git-hooks/`, `scripts/*gate*`, `tdd-gate.sh`, `edit-guard.sh`; el code-owner guard evita el lockout de un owner único.
- ✅ **P8.4 — cerrado por diseño (filosofía A).** El agente nunca corre `git commit`/`push`; no hay token auto-emitido que cerrar (P7.7).
- ✅ **Test cadence** — `tests/` = behavioral (permanente); `tests/task/` = working set cap 20 (`scripts/test-cadence.conf`); checkpoint = push + review → archivar → reset (`docs/TEST-CADENCE.md`).
- ⬜ Pendiente: **P8.5** (docs honesty: `docs/enforcement.html` + i18n, `--no-verify` obsoleto), **P8.6** (plantilla remota en `init-agents`/`install`), **P8.7** (E2E remoto).

**Out of scope:** firmas criptográficas de commit, reemplazo de hooks locales, migración de `agent-discipline` a v2 (eso es Phase 7).

---

## Priorización de Pendientes (2026-09-30)

Orden propuesto, con justificación. "Prioridad" = urgencia × impacto × coste.

| # | Item | Origen | Prioridad | Por qué |
|---|---|---|---|---|
| 1 | Phase 7 — plugin dual-contract OpenCode v1/v2 + multi-agente (P7.1–P7.9) | PLAN | 🔴 P0 | Falla silenciosa que rompe a *todo* usuario en OpenCode v2; sin detección multi-agente ni instalación de skills/guardrails por agente. Es un bug de producto, no de proceso. |
| 2 | P8.1–P8.3 — branch protection + `gates.yml` + CODEOWNERS con dientes | Phase 8 | 🔴 P0 | Barato (horas) y cierra el hueco de autoridad. Independiente de P7 → paralelizable. |
| 3 | Housekeeping de tracking: `PROGRESS_STATUS.md` (5.0.0→6.0.0), headers de `PLAN.md`, conteo de gates 14/15 | drift | 🟠 P1 | El propio proyecto combate el drift de docs; esto es el mismo error. Coste mínimo. |
| 4 | P8.4 — token auto-emitido + bypass files | Phase 8 | 🟠 P1 | Decisión de diseño (mayéutica). Integridad del enforcement. |
| 5 | P8.5 — docs honesty (afirmaciones falsas) | Phase 8 | 🟠 P1 | Barato; evita que el agente siga un modelo inexistente. |
| 6 | P8.6 — ship-to-users (workflow + branch protection en init-agents) | Phase 8 | 🟠 P1 | El framework hoy promete gates locales y no la capa de autoridad. Mejora de producto. |
| 7 | Configurable test scoping (TDD gate universal) | Backlog | 🟠 P1 | Violación auto-declarada de Rule 0k (no universal); bloquea adopción en proyectos no-Node. Alineado con el core del producto. |
| 8 | P8.7 — verificación e2e remota | Phase 8 | 🟡 P2 | Prueba que lo anterior funciona; depende de P8.1–P8.3. |
| 9 | Polish 31 `## When NOT to Use` | Backlog | 🟡 P2 | Calidad de skills; bajo riesgo. |
| 10 | Troubleshooting guide | Backlog | 🟡 P2 | Soporte al usuario; no bloquea. |
| 11 | Self-host Google Fonts | Backlog | 🟢 P3 | Rendimiento/privacidad; cosmético. |
| 12 | New skill tracks (CLI, IoT, GameDev, Container) | Backlog | 🟢 P3 | Expansión; requiere validación de demanda. No urgente. |
| 13 | Framework self-hosting: hook source integrity (B1.1–B1.5) | Backlog | 🟠 P1 | `init-agents` degrada el v11 sin avisar en el repo del framework. Barato y protege la calidad del propio proyecto. |

**Regla de secuencia:** P7 primero (impacto usuario) → P8.1–P8.3 en paralelo (infra, barato) → P8.4–P8.6 → backlog alineado (test scoping) → cosmético.

**Actualización (2026-10-02):** ✅ P7 (v6.2.0) y P8.1–P8.3 están **hechos**; P8.4 cerrado por diseño. Siguiente: P8.5 → P8.6 → P8.7, luego backlog (test scoping) y Phase 10/11.

---

## Phase 9: Distribution & Upgrades (v6.3.0)

**Branch:** `feat/phase9-distribution`
**Goal:** Distribución universal sin clonar el repo, y actualización gestionada. Separar **canal** (cómo llega el código) de **experiencia** (detectar → seleccionar → instalar/actualizar por agente).

**Why:** Hoy el único canal es `git clone`; `install.sh` exige el repo local; `~/.claude/skills` y `~/.gemini/skills` existen en el sistema pero **no los gestiona nadie** (drift). El proto `check-update.sh` + auto-pull en el rc no es una solución de distribución.

**Modelo (canal vs experiencia):**

| Capa | Qué es | Decisión |
|---|---|---|
| Canal primario | Release versionado + bootstrap `curl` pineado | GitHub Releases (tarball + checksums + attestations) |
| Canal secundario | npm (wrapper sin payload) | `npx`/`-g` que descarga+verifica el mismo release |
| Canal contribuidores | `git clone` | Se mantiene |
| Experiencia | CLI `aas`: `install` / `upgrade` / `doctor` / `uninstall` | Detecta agentes → multi-select (solo TTY) → instala/actualiza cada uno |

Principio: **nunca** `curl` de `main` (mutable). Release pineado + verificación de integridad.

### Tasks

| Task | Prioridad | Descripción | Deliverable | Criterio de aceptación |
|---|---|---|---|---|
| P9.1 | 🔴 P0 | Releases versionados: workflow CI que en cada tag construye el tarball de fuentes y lo adjunta con `checksums.txt` + GitHub Artifact Attestations | `.github/workflows/release.yml` | `gh release download vX` trae tarball + checksums; `gh attestation verify` OK |
| P9.2 | 🔴 P0 | Bootstrap `curl` **pineado**: descarga el tarball del release a `~/.local/share/another-agent-skills/<version>`, verifica sha256, enlaza `~/.local/bin/aas`, añade PATH. Flags `--version`, `--dry-run`, `--uninstall` | `bootstrap.sh` + sección en README | Instalación en una línea sin git ni clone; checksum verificado; `--dry-run` no muta |
| P9.3 | 🔴 P0 | CLI `aas` con `install`/`upgrade`/`doctor`/`uninstall`. `upgrade` = self-update atómico desde el último release (reemplaza `check-update.sh` + auto-pull del rc) | `bin/aas` | `aas upgrade` actualiza atómico y reporta versión antes/después; `aas doctor` = `--check-env` |
| P9.4 | 🟠 P1 | Selección de agentes: `--agents auto\|all\|<lista>`; multi-select interactivo **solo si TTY**; en CI nunca bloquea (default no-interactivo). Reusa P7.5 | flags en `aas install` | TTY → prompt; no-TTY → usa detectado o `--agents`; nunca espera input en CI |
| P9.5 | 🟡 P2 | npm wrapper sin payload: descarga+verifica el mismo release; no añade Node al core | paquete `@scope/another-agent-skills` | `npx ... install` funciona en un proyecto sin clonar; el paquete no contiene el payload |
| P9.6 | 🟢 P3 | Homebrew tap (opcional): fórmula auto-generada apuntando al tarball del release | tap + fórmula | `brew install <tap>/another-agent-skills` |

**Need evidence (RED) actual:**
- `grep -n "git clone" install.sh README.md` → el canal documentado es clonar el repo
- `ls ~/.claude/skills/.another-agent-skills-manifest ~/.gemini/skills` → skills globales presentes pero sin gestor (drift)
- `grep -n "check-update.sh" scripts/install.sh install.sh` → proto de update, no distribución

**Out of scope:** binario compilado (no aplica: es shell+markdown, sin cross-compile), firmas PGP propias (las attestations cubren la integridad).

---

## Phase 10: Landing & Docs Refresh (v6.2.0)

**Branch:** `feat/phase10-landing`
**Goal:** Landing y documentación atractivas, útiles y al día (multi-agente, v6.1.0), con diseño de calidad y mensaje de marketing.

**Why:** La landing dice *"Designed for OpenCode"* pero el framework ya es **multi-agente**; no muestra el valor real (compat v1/v2, guardrails, filosofía A) ni un "What's new". Docs ES/EN desincronizadas.

**Bloque A — Value doc + sync (entra en v6.1.0)**
- A1 `RELEASE-NOTES.md` v6.1.0 · A2 `README`/`PROGRESS_STATUS` · A3 i18n ES/EN (`i18n/*.json`, `docs/i18n/*.json`) · A4 refs históricas (`rules/common/context.md`, `RELEASE-NOTES.md`).

**Bloque B — Landing redesign (skills de diseño + marketing)**
| # | Task | Detalle |
|---|---|---|
| B1 | Auditoría + IA de mensaje | `redesign-skill` (8 categorías) + `.agents/product-marketing.md` |
| B2 | **Investigación de inspiración award-winning** | Awwwards, Godly, Land-book, SiteInspire, Lapa Ninja → patrones de hero, proof, CTA, motion |
| B3 | Dirección visual | Decidir con el usuario: soft-premium / minimalist / industrial |
| B4 | Implementación | `frontend-web` + `frontend-ui-engineering`: hero (thesis + proof + CTA), "What's new", matriz multi-agente, comandos |
| B5 | Revisión | `critique-skill` + Playwright |
| B6 | i18n ES/EN | Sync de todo lo nuevo |

**Bloque C — Release v6.1.0 (Phase 7)**
- C1 `VERSION` → 6.1.0 + tag + GitHub Release (value: compat v1/v2, multi-agente, filosofía A).
- C2 push de `fix/opencode-v2-plugin-compat` + PR.

---

## Phase 11: Docs site — Astro + Starlight (v6.3.0)

**Goal:** Migrar el sitio de documentación a Astro + Starlight: SEO por idioma, búsqueda, sidebar y versionado, sirviendo en GitHub Pages.

**Principio de frontera (no erosionar):** el **core** (skills, rules, hooks, `install.sh`) se mantiene **sin build**. El build vive **solo en la capa de docs**; `install.sh` nunca debe requerir Node. El CI del core no corre el build de docs.

**Why:** el JSON-i18n funciona, pero el toggle client-side no indexa `/es/` (SEO) y 21 páginas a mano escalan mal. Astro es el estándar actual para docs en Pages y nos mantiene al día en la capa de presentación.

**Paso intermedio (barato, opcional):** rutas reales `/es/` en el sitio estático → arregla SEO sin build.

| # | Task | Criterio |
|---|---|---|
| P11.1 | Verificar con Context7 la guía oficial de Astro (i18n + GitHub Pages) **antes** de implementar | Fuentes citadas, no de memoria |
| P11.2 | Elegir Astro + Starlight (recomendado) vs Astro pelado | Decisión documentada (ADR) |
| P11.3 | Migrar 13 HTML + 8 MD a content collections; portar el diseño | Paridad de contenido |
| P11.4 | i18n por rutas (`/en/`, `/es/`) — reemplaza el toggle JSON client-side | Ambas indexables |
| P11.5 | Workflow de deploy a Pages, **separado** del CI del core | Core sin build |
| P11.6 | Reescribir tests de docs (Playwright, i18n, nav); build fuera del pre-commit del core | Suite verde; `install.sh` sin Node |

**Costo honesto:** migración real (21 páginas + diseño custom + reescritura de tests de docs). No es un fin de semana; va **después** de v6.1.0 y Phase 10.

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections
- **Configurable test scoping** — `tests/run-all.sh` runs all suites regardless of changed files. On non-Node projects (Arduino, Python, etc.) the TDD gate should detect available test runners, scope to changed files, and skip gracefully if nothing is compatible. Currently hardcoded to this project's structure — Rule 0k violation (not universal).

### Backlog detallado — Framework self-hosting: hook source integrity

**Problema:** `init-agents` (completo) instala `scripts/project-pre-commit` (genérico, 194 líneas) como pre-commit, **sobrescribiendo** el hook propio del framework `scripts/git-hooks/pre-commit` (v11, 586 líneas, 15 gates). En el repo del framework esto **degrada el enforcement en silencio**. `sync-hooks` reinstala el v11, pero nada le dice al usuario cuál usar ni avisa del overwrite.

**Por qué importa:** el repo del framework debería correr sus 15 gates (skill-lint, validación de progreso, eval, anti-slop, test count). Perderlos sin aviso es una regresión de calidad. Además, hay dos fuentes de pre-commit sin contrato claro — confunde a cualquiera.

| Task | Descripción | Criterio de aceptación |
|---|---|---|
| B1.1 | `init-agents` detecta que corre en el repo del framework (señales: `.opencode/plugins/agent-discipline/`, `scripts/git-hooks/pre-commit`, `SOUL.md`, `VERSION`) y usa el v11 — o pregunta | En el repo del framework, `init-agents` **no** degrada el pre-commit |
| B1.2 | Nunca sobrescribir un pre-commit existente sin aviso explícito + backup, indicando la fuente instalada | El output dice qué hook se instaló y desde qué archivo |
| B1.3 | Documentar los dos hooks (cuándo `init-agents` vs `sync-hooks`, trade-offs) en `scripts/git-hooks/README.md` y `docs/AGENT-ADAPTERS.md` | Docs explican la elección y el trade-off |
| B1.4 | Flag `--hook <lifecycle\|full>` (o `--pre-commit <source>`) para elegir explícitamente | El flag selecciona el hook correcto |
| B1.5 | Test: `init-agents` en fixture de repo-framework → v11 preservado; en fixture de proyecto → hook lifecycle | Ambos fixtures cubiertos |

**Evidencia (RED):** `bash scripts/init-agents.sh` en este repo reemplazó el v11 (586 líneas) por `project-pre-commit` (194 líneas) sin avisar; el v11 quedó solo en `.git/hooks/pre-commit.backup.*`.

### Backlog detallado — B2: limpieza del pre-commit v11 (drift post-v6)

**Problema:** `scripts/git-hooks/pre-commit` (v11) todavía contiene el mecanismo OVERRIDE que v6 eliminó: Gate 5 (`OVERRIDE_LOG`, escalación) y la línea 346 (`"To skip: Add OVERRIDE: reason before your commit msg"`). Además `scripts/git-hooks/README.md` dice "14 gates" (son 15) y documenta el bypass `git commit --no-verify`.

**Por qué importa:** es guía engañosa — el OVERRIDE ya no salta nada (commit-msg es TDD-only). Es el mismo patrón de "doc que promete enforcement inexistente" que venimos corrigiendo.

| Task | Descripción | Criterio de aceptación |
|---|---|---|
| B2.1 | Eliminar Gate 5 (override escalation) y `OVERRIDE_LOG` de `scripts/git-hooks/pre-commit` | Sin refs a OVERRIDE en el hook |
| B2.2 | Quitar la línea 346 (`"To skip: Add OVERRIDE…"`) | Sin guía de bypass obsoleta |
| B2.3 | Actualizar `scripts/git-hooks/README.md`: 15 gates, quitar `--no-verify` | README refleja el v11 real |

**Evidencia (RED):** `grep -n OVERRIDE scripts/git-hooks/pre-commit` → Gate 5 + línea 346; `grep -n "14 gates\|no-verify" scripts/git-hooks/README.md` → desactualizado.

### Backlog detallado — B3: TDD gate false-pass cuando no hay code files staged

**Problema:** `tdd-gate.sh` hace `SKIP` si no hay archivos de código staged (`code_files=none`). Si el agente olvida `git add` de las modificaciones (solo stagea un test nuevo), el gate pasa **en falso** y el commit queda incompleto. Ocurrió en el commit `56453c4` (movió el plugin pero no stageó `install.sh` → HEAD quedó roto hasta el commit de seguimiento `db0c711`).

| Task | Descripción | Criterio de aceptación |
|---|---|---|
| B3.1 | El gate compara las modificaciones **sin stagear** del working tree con el test staged; si hay code files modificados sin stagear que emparejen, avisa/bloquea | No se puede commitear dejando modificaciones de código sin stagear |
| B3.2 | `SKIP` por `no-code-files` solo si de verdad no hay code files modificados sin stagear | `code_files=none` deja de ser un falso PASS |

**Evidencia (RED):** `.git/TDD_GATE_LOG` de `56453c4` → `decision=SKIP code_files=none` mientras `install.sh` estaba modificado sin stagear.

# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **5.0.0** (Phase 6 design skills complete) → **6.0.0** |
| Lint | 0 errors, 0 warnings |
| Health | ✅ HEALTHY |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 15 suites passing (26 archived, 10 infrastructure active) |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | **v4.0.0** | Foundation Repair & Critical Stubs |
| **QS** | **v4.1.0** | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |
| **4** | **v5.0.0** | Docs Honesty: 42 issues fixed across 6 groups, 86 files changed |
| **Phase 6** | **v6.0.0** | Design Skill Integrity: TDD enforcement (no override), 17-section DESIGN.md schema, 3-mode design-gate, token-validate CSS drift, approval-gate prototype→approved, design dir rules, DISCOVERY-GUIDE.md, install.sh deprecated cleanup, design-upgrade.sh, direction+platform skill DESIGN.md wiring, critique-skill visual dimensions, prompt drift detection. 35+ commits, 80+ files changed. |

---

## Phase 6: Design Skill Integrity (v5.1.0)

**Branch:** `feat/phase6-design-skills`
**Goal:** Upgrade design/prototype skills to produce complete, verified, stack-aware design systems with mechanical gates. Direction skills (brutalist, minimalist, premium) wire into a universal 17-section DESIGN.md schema. Platform skills (web, mobile, desktop, PWA) fill stack-specific sections. Gates validate completeness, detect drift, and enforce transitions.

**Why:** Currently DESIGN.md has no enforced schema, direction skills don't integrate with platform skills, existing projects have no upgrade path, and token drift goes undetected. Additionally, Contra's Design Crit research (arXiv:2605.20731) shows that automated design critique is unreliable for aesthetic dimensions (best model achieves 54.3% vs 74.1% human agreement) — our gates must separate **checkable dimensions** (tokens, contrast, breakpoints) that can be automated from **felt dimensions** (color harmony, mood) that require human review.

**Value to user:**
- New projects: agent produces complete design system contracts with explicit user approval at every step
- Existing projects: `design-upgrade.sh` auto-extracts tokens from codebase, fills gaps with targeted questions
- All projects: gates block incomplete DESIGN.md, catch CSS drift, enforce prototype→production transitions
- Cross-platform: same 17-section schema works for web, mobile, desktop, PWA. Direction skills compose with any platform

**How user activates it:** Through the agent. Skills detect context automatically. `design-gate.sh` runs on every design-related commit. `design-upgrade.sh` activates when user says "improve design" or when `design-gate.sh` detects an incomplete DESIGN.md. No manual script execution needed.

**Completed so far:**
- **P0.1-P0.4**: Enforcement rules rewritten, DECISION_APPROVED check in pre-commit, OVERRIDE_APPROVED removed (replaced by unconditional TDD), token path documented
- **P0.5**: 43 stale COMMIT_APPROVED refs cleaned across 19 files, 15 past-phase tests archived
- **P0.6**: hooks synced, test plan verified
- **Override removal**: TDD bypass removed entirely — every change requires a matching test. No override mechanism exists. TDD gate enforces: code → matching new test → test-before-code (mtime). 20 test suites, 20 passing.
- **P6.1**: DESIGN-MD-SCHEMA.md (17-section contract) created, engineering-fundamentals Phase 2B updated, task-specific test suite with 16 tests
- **P6.2**: design-gate.sh upgraded to 3 modes (strict/audit/verify) with schema validation against DESIGN-MD-SCHEMA, checkable vs felt split, platform detection. Test count gate added to pre-commit (max 11 tests). Task test with 4 tests.

---

### P0 — Enforcement Fix: Agent Stages, User Commits

**Trigger:** I committed without approval on this branch. The agent should never run `git commit`. The correct flow: agent stages files (`git add`), presents the proposed commit to the user (files + message + reasoning), user reviews and runs the commit themselves.

**Audit findings (before starting):**

| Claim | Reality |
|---|---|
| "Pre-commit hook v11 (14 gates) is active" | **FALSE.** `scripts/git-hooks/pre-commit` (v11, 545 lines) is NOT installed. The active pre-commit is `scripts/project-pre-commit` (169 lines). |
| "enforcement.md Rule 12 reflects reality" | **FALSE.** It still describes an old COMMIT_APPROVED three-gate flow that was removed in commit-msg v4. The section must be rewritten, not amended. |
| "OVERRIDE is validated mechanically" | **FALSE.** `scripts/tdd-gate.sh` line 177: `[[ "$msg" =~ OVERRIDE: ]]` — pure regex. Any agent can forge OVERRIDE in the commit body. |
| "Stale references are limited" | **FALSE.** 43 references to COMMIT_APPROVED across 14 files found. The old flow is documented in enforcement.md, AGENTS-EXTENDED.md, GLOSSARY.md, HARNESS.md, PATTERNS.md, ADRs, HEALTH-CHECK.md, etc. |
| `scripts/git-hooks/pre-commit` (v11, 30147 bytes) | Not installed anywhere. Exists as source only. |

**Why 43 stale references matter:** If the old COMMIT_APPROVED flow is still documented anywhere, an agent reading those docs will follow the old flow instead of the new one. Every reference must be updated or the P0 enforcement will be undermined by conflicting documentation.

**What 100% confidence requires:**
1. Rewrite enforcement.md Rule 12 — not "add a line" but replace the outdated COMMIT_APPROVED section with the new DECISION_APPROVED + OVERRIDE_APPROVED flow
2. Add DECISION_APPROVED check to **the active pre-commit hook** (`scripts/project-pre-commit`) — warn if missing/stale, since the user running `git commit` IS the approval
3. Add OVERRIDE_APPROVED check to **the active commit-msg hook** (`scripts/git-hooks/commit-msg`) — BLOCK if OVERRIDE in body but no token, since OVERRIDE is trivially forgeable by regex
4. Add both tokens to `.gitignore`
5. Find and update all 43 stale COMMIT_APPROVED references across 14 files, organized by impact: enforcement docs first, then ADRs, glossaries, then release/history notes
6. Sync hooks + run test plan

**Active hooks (what actually runs):**

| Hook | Source File | What It Does |
|---|---|---|
| `.git/hooks/pre-commit` | `scripts/project-pre-commit` (169 lines) | Tests, build, secrets scan, design gate |
| `.git/hooks/commit-msg` | `scripts/git-hooks/commit-msg` (57 lines, v4) | TDD gate only |

**Token flow:**

| Agent Does | User Does |
|---|---|
| `git add <files>` (stages relevant files) | Reviews staged files |
| Presents: "Files staged \| message \| what changed \| why" | Approves or requests changes |
| Writes `.git/DECISION_APPROVED` after approval | Runs `git commit` |
| — | Pre-commit hook validates token exists and is fresh |

| Token | File | What It Proves |
|---|---|---|
| Decision token | `.git/DECISION_APPROVED` | Agent presented the staged files + message, user explicitly said "yes, commit this." Timestamp must be < 10 min old. |
| Override token | `.git/OVERRIDE_APPROVED` | Same as above, but override was justified and approved. Only checked when commit body contains OVERRIDE. |

**Decision token behavior:** WARN (not BLOCK) when missing. The user running `git commit` IS the approval — the token is evidence that the presentation step happened. If missing, the user sees a yellow warning that "no decision point was presented before this commit."

**Override token behavior:** BLOCK when OVERRIDE in body but no token. OVERRIDE bypasses the TDD gate — it requires mechanical proof that the user explicitly approved the bypass. Without the token, any agent can forge OVERRIDE silently.

**Flow examples:**

```
Correct flow:
  Agent: git add PLAN.md
  Agent: "Staged: PLAN.md. Approve? (y/n)"
  User: "yes"
  Agent: writes .git/DECISION_APPROVED
  User: git commit -m "message"
  → pre-commit: DECISION_APPROVED fresh → PASS ✓

Override flow:
  Agent: "OVERRIDE needed: no test for this doc-only. Approve? (y/n)"
  User: "yes"
  Agent: writes .git/OVERRIDE_APPROVED
  User: git commit -m "msg" -m "OVERRIDE: doc-only"
  → commit-msg: OVERRIDE in body + token fresh → PASS ✓
  → Without token: BLOCK ❌ (even with OVERRIDE in body)

Missing token (user commits directly):
  User: git commit -m "msg"
  → pre-commit: no DECISION_APPROVED → WARN ⚠ (no block)
```

Both tokens go in `.gitignore`. Local only.

| # | Task | Deliverable | Lines | File(s) | Gate |
|---|---|---|---|---|---|
| P0.1 | Rewrite `rules/common/enforcement.md` Rule 12 — replace old COMMIT_APPROVED section with new DECISION_APPROVED + OVERRIDE_APPROVED flow | Updated enforcement rules: agent stages and presents, user commits. Token validation described correctly. No references to commit-approval.sh or three-gate approval. | ~30 | `rules/common/enforcement.md` | — |
| P0.2 | Add DECISION_APPROVED check to active pre-commit hook (`scripts/project-pre-commit`) | New gate in project-pre-commit: if `.git/DECISION_APPROVED` missing or stale (>10min), warn but don't block. Checks before tests/ build/ secrets gates. | ~15 | `scripts/project-pre-commit` | pre-commit hook (warn) |
| P0.3 | Add OVERRIDE_APPROVED check to active commit-msg hook (`scripts/git-hooks/commit-msg`) | New gate in commit-msg v4+: if commit body contains OVERRIDE, require `.git/OVERRIDE_APPROVED` exists and is <10min old. BLOCK if missing or stale. Runs before TDD gate. | ~12 | `scripts/git-hooks/commit-msg` | commit-msg hook (block) |
| P0.4 | Document that tokens live in `.git/` (inherently local) — no `.gitignore` needed | `.gitignore` doesn't apply to `.git/` directory. Tokens are already untracked. Update enforcement.md to reflect this instead of claiming `.gitignore` coverage. | ~1 | `rules/common/enforcement.md` | — |
| P0.5 | Clean up all 43 stale COMMIT_APPROVED references across 14 files — organized by impact | **High impact** (agent reads these during design flow): `AGENTS-EXTENDED.md` (3 refs), `GLOSSARY.md` (2 refs), `PATTERNS.md` (1 ref), `HARNESS.md` (1 ref), `scripts/commit-approval.sh` (deprecate or update). **Medium impact** (reference/decision docs): `ADRs/ADR-006.md`, `ADR-007.md`, `ADR-005.md`. **Low impact** (historical release notes): `RELEASE-NOTES.md`, `HEALTH-CHECK.md`, `PROGRESS_STATUS.md`, `README.md`. | ~80 across 14 files | 14 files | All stale refs cleared |
| P0.6 | Sync hooks + run full test plan | `bash scripts/init-agents.sh sync-hooks` → installs updated hooks. Then verify all 6 test scenarios. | ~10 | — | All gates |

---

### P6.0 — Gates & Schema (Foundation)

| # | Task | Deliverable | Lines | Gate |
|---|---|---|---|---|
| P6.1 | Define 17-section DESIGN.md schema — universal template for all platforms, annotated with checkable vs felt dimensions | `engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md` — documents all 17 sections, which are universal vs platform-specific, required fields per section, and for each section whether it is **checkable** (can be verified mechanically: tokens, breakpoints, contrast) or **felt** (requires human review: color harmony, mood). This split is based on Contra Design Crit finding: designers agree >74% on checkable dimensions but <55% on felt ones, and no automated system can reliably judge the latter. | ~60 | — |
| P6.2 | Upgrade `design-gate.sh` — 3 modes (strict/audit/verify), split each mode into automated blocks + human review flags | Script upgrade: strict blocks on checkable violations (missing tokens, wrong contrast, no breakpoints), flags for human review on felt dimensions. Audit warns on both but doesn't block. Verify checks pre-merge that automated checks passed and felt flags were reviewed. Detects platform from codebase, calls platform validator if available. | ~50 | — |
| P6.3 | Create `token-validate.sh` — CSS drift detection against DESIGN.md tokens | New script: scans CSS for values not in DESIGN.md token schema. Reports drift percentage. Platform-specific scanners (web: CSS vars, mobile: StyleSheet, desktop: Tauri config) | ~40 | token-validate.sh |
| P6.4 | Create `approval-gate.sh` — prototype→approved transition | New script: requires explicit "APPROVED" with timestamp before moving from `design/prototype/` to `design/approved/` | ~25 | approval-gate.sh |
| P6.5 | Define `design/` directory rules + update `.gitignore` | Document all 4 directory roles (prototype, approved, archive, contract). Add `design/prototype/` to `.gitignore` for main branch | ~10 | .gitignore |

### P6.1 — Discovery & Extraction

| # | Task | Deliverable | Lines | Gate |
|---|---|---|---|---|
| P6.6 | Upgrade `visual-frontend-mastery` Phase 1 — Discovery produces `design/design-discovery.md` artifact | Discovery uses `interview-me` pattern (one question with guess+confidence). Produces structured artifact with: intent, audience, vibe, Three Dials, references, constraints, explicit user approval. DESIGN.md is EXTRACTED from this artifact, not guessed | ~40 | design-gate.sh --strict |
| P6.7 | Create `design-upgrade.sh` — auto-extract design system from existing codebase | Reads existing codebase: CSS vars (spacing, color, breakpoints, transitions), HTML (framework, font loading, icons, theme), package.json (framework detection). Detects platform automatically (web/mobile/desktop/PWA). Offers direction skill selection. Produces complete DESIGN.md with only 2-3 user questions for gaps | ~60 | design-gate.sh --audit |

### P6.2 — Direction & Platform Integration

| # | Task | Deliverable | Lines | Gate |
|---|---|---|---|---|
| P6.8 | Wire direction skills into DESIGN.md generation — each fills sections 1-12 | Add DESIGN.md OUTPUT section to `industrial-bratulist-ui`, `minimalist-ui`, `soft-premium-ui` SKILL.md — declares which sections they populate and with what constraints. Agent reads direction skill output, applies to DESIGN.md sections 1-12 before platform skill fills 13-17 | ~20 per skill | design-gate.sh validates direction constraints |
| P6.9 | Wire platform skills into DESIGN.md generation — each fills sections 13-17 | Add platform DESIGN.md sections table to each platform skill's DESIGN-GUIDE.md (.md (web, mobile, desktop, PWA) — declares what goes in sections 13-17. Agent reads platform guide, applies to DESIGN.md after direction | ~10 per platform | design-gate.sh delegates to platform validator |

### P6.3 — Upstream Integration & Verification

| # | Task | Deliverable | Lines | Gate |
|---|---|---|---|---|
| P6.10 | Wire `design-upgrade.sh` → `redesign-skill` flow | When user says "redesign", `design-upgrade.sh` runs first (fix contract), then `redesign-skill` (fix visuals). Document the flow in redesign-skill's When to Use | ~15 | Both gates pass |
| P6.11 | Upgrade `critique-skill` — add optional Visual Design pass with Contra's dimension taxonomy | Add 5 visual design dimensions (color harmony, typographic craft, visual hierarchy, spatial accuracy, mood/tone) as an optional pass. Score each 0-4 alongside existing Nielsen heuristics. These dimensions are **felt** — they flag for human review, not automated block. | ~30 | Critique pipeline |
| P6.12 | Add "prompt drift" detection to `token-validate.sh` / anti-pattern checks | Contra found 10% of AI-generated designs hallucinate elements not in the prompt. Add semantic check: output uses tokens/colors/components not in DESIGN.md or spec. Catches hallucinated content, not just token drift. | ~15 | token-validate.sh |
| P6.13 | Upgrade our own DESIGN.md as real-world test case | Run `design-upgrade.sh` against our project. Auto-extract from CSS/HTML. Fill 7 missing sections. User confirms. `design-gate.sh --verify` passes | ~30 (documentation) | design-gate.sh --verify |
| P6.14 | Verify all gates + full pipeline integration | `design-gate.sh --strict` passes on new project. `design-gate.sh --audit` warns on legacy. `token-validate.sh` catches drift. `approval-gate.sh` blocks without approval. End-to-end flow: discovery → DESIGN.md → build → gate passes | ~20 (tests) | All gates |

---

### Summary

| Metric | Value |
|---|---|
| Branch | `feat/phase6-design-skills` |
| Target version | **v6.0.0** |
| Base | `main` |
| New scripts | 2 (`token-validate.sh`, `approval-gate.sh`) |
| Upgraded scripts | 1 (`design-gate.sh` — automated block + human-flag split) |
| New script | 1 (`design-upgrade.sh`) |
| Upgraded skills | 2 (`visual-frontend-mastery`, `critique-skill`) |
| Direction skills updated | 3 (brutalist, minimalist, premium) |
| Platform skills updated | 4 (web, mobile, desktop, PWA) |
| New guides | 1 (`DESIGN-MD-SCHEMA.md` with checkable/felt annotation) |
| New gates | 3 (strict, approval, token, prompt-drift) |
| Research integrated | Contra Design Crit (arXiv:2605.20731) — checkable vs felt dimensions, designer agreement baselines, prompt-drift detection |
| Backward compatibility | Existing projects not broken. Upgrade is opt-in. |

---

---

## Release v6.0.0 — Phase 6: Design Skill Integrity

**Target:** Merge `feat/phase6-design-skills` → `main`, tag v6.0.0, publish release.

### Pre-Release Audit (15 files need fixes)

| # | File | Issue | Fix |
|---|---|---|---|
| 1 | `VERSION` | 5.0.0 | → 6.0.0 |
| 2 | `RELEASE-NOTES.md` | Missing v6.0.0 section | Add Phase 6 release notes |
| 3 | `README.md` | Badge v5.0.0, What's New, "current: v4.2.0" | Version + Phase 6 content |
| 4 | `index.html` | "14 gates" in FAQ a2/a5 | → 15 gates |
| 5 | `i18n/en.json` | "14 gates" in hero, FAQ | → 15 gates |
| 6 | `i18n/es.json` | Same as EN | Sync |
| 7 | `docs/index.html` | v4.2.0 everywhere, stale "superseded by v5.1.0" ref | → v6.0.0 |
| 8 | `docs/i18n/en.json` | What's New in v4.2.0 | → v6.0.0 Phase 6 |
| 9 | `docs/i18n/es.json` | Same as EN | Sync |
| 10 | `docs/enforcement.html` | "14 gates" ×4, "v4" → v6, missing Gate 0 | Update gate list |
| 11 | `docs/i18n/en.json` (enforcement) | "14 gates" ×2, "v4" → v6 | Update |
| 12 | `docs/quickstart-guide.html` | "14 gates" ×2, "Gate 14" → Gate 15 | Update |
| 13 | `docs/design-review.html` | No Phase 6 design gate pipeline reference | Add gate flow |
| 14 | `docs/DESIGN-WORKFLOW.md` | "futuro" skills now implemented | Mark current |
| 15 | `PLAN.md` (this file) | Needs release plan | Done |

### Release Steps

1. Fix all 15 files (TDD: each file + matching test → commit → archive → next)
2. Create the "What's New" content for v6.0.0 (Phase 6 highlights)
3. Run Playwright tests: `npx playwright test` in `tests/playwright/`
4. Run full test suite: `bash tests/run-all.sh`
5. Update `docs/index.html` version table: v4.2.0 → v6.0.0
6. Final commit: `git tag v6.0.0 && git push --tags`
7. Create GitHub Release with release notes

### What "What's New in v6.0.0" Should Cover

- **Design Flow Transformation** — 17-section DESIGN.md schema, 3-mode design-gate.sh (strict/audit/verify)
- **TDD Enforcement (no override)** — commit-msg v6 blocks code without matching tests. No bypass mechanism.
- **Gate 0: DECISION_APPROVED Block** — Pre-commit now BLOCKS if no decision token exists (upgraded from warn).
- **15 Gates Total** — 15 pre-commit gates (was 14) + 1 commit-msg gate.
- **design-upgrade.sh** — Auto-extract design tokens from existing codebases.
- **token-validate.sh** — CSS drift detection against DESIGN.md tokens.
- **43 stale refs cleaned** — All COMMIT_APPROVED references replaced with current flow.
- **Design direction + platform wiring** — Direction skills (brutalist, minimalist, premium) compose with platform skills through the schema.
- **critique-skill upgrade** — Optional visual design pass with 5 felt dimensions (color, typography, hierarchy, spatial, mood).

---

## Phase 7: OpenCode v1/v2 Plugin Compatibility (v6.1.0) — 🔴 PRIORIDAD INMEDIATA

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
- ✅ **P7.1 + P7.8 completados** — `.opencode/plugins/agent-discipline/index.js` es la fuente de verdad con **contrato dual** (`setup()` v2 + `server()` v1), reconciliado con v6: usa `.git/DECISION_APPROVED` (TTL 600s), sin OVERRIDE. Se eliminaron los artefactos v1 muertos: `plugin.json` (formato `events`/`hooks` que OpenCode nunca cargó), `src/*.ts`, `tsconfig.json`, `dist/`.
- Verificado: `node --check` OK; el contrato dual expone `id` + `setup` + `server`; el hook v1 bloquea `git commit` sin token, permite con token fresco, bloquea `git push` con árbol sucio, y permite comandos no-mutación. Suite completa: **15/15**.
- Pendiente: P7.2 (install/init-agents instalan dual-contract + detectan versión), P7.5–P7.7 (multi-agente), P7.3/P7.9 (docs/tests). Validación de carga real en OpenCode v2.0.20 → P7.4.
- Nota: el plugin global en `~/.config/opencode/plugins/agent-discipline/` sigue con semántica vieja (`COMMIT_APPROVED` + OVERRIDE) → P7.2 debe reemplazarlo para evitar doble enforcement.
- ✅ **P7.2 completado** — `install.sh --plugin-only` reemplaza atómicamente el plugin global (borra artefactos v1: `plugin.json`, `src/`, `dist/`, `node_modules`), pone en cuarentena los `agent-discipline.backup.*` a `.plugin-backups/`, verifica que quede **una sola** instancia y detecta la versión de OpenCode (avisa si < 1.18.29). `init-agents.sh --check-env` reporta la versión y el estado del plugin (`legacy`/`dual-contract`). Esto cierra el doble enforcement confirmado en el log de OpenCode (dos `agent-discipline` cargados con el mismo `id`).

---

## Phase 8: Remote Enforcement — Gate Integrity (v6.2.0)

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
| P8.1 | 🔴 P0 | Activar branch protection en `main` vía script idempotente | `scripts/setup-branch-protection.sh` (usa `gh api`) + `docs/BRANCH-PROTECTION.md` | `gh api .../branches/main/protection` → 200; push directo a `main` rechazado; merge sin check requerido bloqueado |
| P8.2 | 🔴 P0 | Workflow de gates reales, separado del `ci.yml` genérico | `.github/workflows/gates.yml` que corre `tdd-gate.sh`, `tests/run-all.sh`, `skill-lint.sh`, `design-gate.sh --verify`, `token-validate.sh` | El workflow corre en PR; configurado como required status check; un PR con test faltante falla en CI (no solo en local) |
| P8.3 | 🔴 P0 | Proteger la configuración del gate (L3) | CODEOWNERS extendido (`.github/workflows/`, `scripts/git-hooks/`, `scripts/*gate*`, `scripts/tdd-gate.sh`, `scripts/edit-guard.sh`) + "Require review from Code Owners" activado en P8.1 | Un PR que edite `gates.yml` o `tdd-gate.sh` sin review de `@juandelossantos` no puede mergear |
| P8.4 | 🟠 P1 | Cerrar el agujero del token auto-emitido. Dos caminos (decisión de diseño): (a) mecanismo no forjable por el agente (approval fuera del alcance de escritura del agente / firmado / trailer de commit verificado), o (b) reclasificar honestamente en docs como "prompt de proceso, no enforcement" y renombrar | Decisión documentada en ADR nuevo + implementación o reclasificación de docs; `SKIP_TEST_GATE`/`SKIP_TEST_RUNNER` neutralizados (requieren token + log, o eliminados) | El flujo de aprobación no puede ser satisfecho por el agente sin acción humana verificable, **o** los docs dejan de llamarlo enforcement |
| P8.5 | 🟠 P1 | Docs honesty: corregir afirmaciones falsas y documentar el modelo de 3 capas | `docs/enforcement.html` + `docs/i18n/*` (INCIDENT_004: "branch protection" → Gate 1 local), `scripts/git-hooks/README.md` (quitar `--no-verify` obsoleto), sección L1/L2/L3 en `docs/` | `grep -ri "branch protection" docs/` sin afirmaciones falsas; README de hooks refleja v6 real |
| P8.6 | 🟠 P1 | Ship-to-users: `init-agents`/`install` generan la capa remota | Plantilla `.github/workflows/gates.yml` para proyectos + `setup-branch-protection.sh` copiado + checklist en `docs/AGENT-ADAPTERS.md` | Un proyecto nuevo con `init-agents` obtiene workflow remoto + instrucciones de branch protection; doc explica por qué local ≠ autoridad |
| P8.7 | 🟡 P2 | Verificación end-to-end del enforcement remoto | Test `tests/test-remote-enforcement.sh` + documento de evidencia | Test prueba: (1) PR con gate roto → merge bloqueado; (2) push directo → rechazado; (3) edición de `gates.yml` sin review → bloqueada; (4) `core.hooksPath` a directorio vacío + commit → CI lo atrapa igual |

**Need evidence (RED) actual:**
- `gh api repos/:owner/:repo/branches/main/protection` → `404 Branch not protected`
- `grep -rn "main branch protection" docs/` → afirmación sin respaldo mecánico remoto
- `.git/hooks/` escribible; `git config core.hooksPath` → unset

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

**Regla de secuencia:** P7 primero (impacto usuario) → P8.1–P8.3 en paralelo (infra, barato) → P8.4–P8.6 → backlog alineado (test scoping) → cosmético.

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections
- **Configurable test scoping** — `tests/run-all.sh` runs all suites regardless of changed files. On non-Node projects (Arduino, Python, etc.) the TDD gate should detect available test runners, scope to changed files, and skip gracefully if nothing is compatible. Currently hardcoded to this project's structure — Rule 0k violation (not universal).

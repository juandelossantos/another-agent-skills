# Plan v5.0: TDD-First Quality Enforcement

> **Current version:** 4.1.0
> **Target version:** 5.0.0
> **Date:** 2026-07-10
> **Status:** Phases 0-2 ✅ — Phase QS ✅ — Phase 3 🔜 (19/56 tasks done) — Phase 4 🔜

---

## Phase 3: Output Contracts

**Branch:** `feat/output-contracts`
**Estimate:** ~1 commit per skill + 1 for lint check = 56 commits
**Process:** One commit per skill. Each commit reviewed individually.
**Progress:** 19/56 tasks done (3.0–3.18). Detailed tracking in `SESSION_STATE.md`.
**Guide improvements:** CONTRACT-TEMPLATES.md (+WebSocket, +module boundaries), VERSIONING-STRATEGIES.md (+breaking rules table, +edge cases).

### Why This Phase

Only 2 of 57 skills declare what they produce (customize-opencode, interview-me). For the other 55, the agent guesses. Each contract must name the specific artifact, format, location, and quality criteria — not generic boilerplate.

### Template

**Standard (>100 lines):** Table with Artifact, Format, Location, Quality Criteria
**Micro (<100 lines):** One-line prose
**Foundation:** "No artifact. [How consumed.]"

---

### Task 3.0: Add lint Check 16

**File:** `scripts/skill-lint.sh`
Scan every SKILL.md for `## Output Contract`. FAIL if missing.

---

### Tasks 3.1-3.55: One per skill

#### Foundation (no artifact)

| Task | Skill | Lines | Contract |
|---|---|---|---|
| 3.1 | engineering-fundamentals | 226 | `No artifact. Consumed implicitly by all platform skills.` |
| 3.2 | multi-agent-orchestration | 81 | `No artifact. Orchestration process only.` |

#### Development — Frontend

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.3 | frontend-web | 233 | Web component | TSX/CSS | src/components/ | Accessible, responsive, 0 lint |
| 3.4 | frontend-mobile | 240 | Mobile screen | TSX | src/screens/ | Platform-compliant gestures |
| 3.5 | frontend-desktop | 236 | Desktop window | TS/Rust | src/ | Native menus, tray, shortcuts |
| 3.6 | frontend-pwa | 196 | PWA build | JS/CSS/HTML | dist/ | Offline, installable |
| 3.7 | frontend-ui-engineering | 119 | UI component | TSX | src/components/ | Composable, accessible |
| 3.8 | adapt-skill | 129 | Responsive CSS | CSS | src/styles/ | All breakpoints, ≥44px touch |
| 3.9 | polish-skill | 136 | Polished CSS | CSS | src/styles/ | Token-compliant spacing |
| 3.10 | delight-skill | 149 | Micro-interaction | CSS/TS | src/components/ | 150-400ms, reduced-motion |
| 3.11 | optimize-skill | 139 | Optimized code | CSS/TS | src/ | Bundle size, 60fps |
| 3.12 | typeset-skill | 136 | Typography CSS | CSS | src/styles/ | Type ramp, line-height |
| 3.13 | industrial-brutalist-ui | 75 | *Micro:* Industrial UI code | — | — | — |
| 3.14 | minimalist-ui | 68 | *Micro:* Minimalist UI code | — | — | — |
| 3.15 | soft-premium-ui | 69 | *Micro:* Premium UI code | — | — | — |
| 3.16 | redesign-skill | 64 | *Micro:* Redesigned UI code | — | — | — |

#### Development — Backend

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.17 | backend-api-mastery | 195 | API handler | TS/Python/Go | src/api/ | REST/GraphQL, auth tested |
| 3.18 | api-and-interface-design | 108 | API contract | OpenAPI/GraphQL | api/ | Schema-validated |
| 3.19 | cli-tools | 108 | CLI command | TS/Python/Rust | src/cli/ | Args parsed, exit codes |

#### Development — Quality

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.20 | security-and-hardening | 31 | *Micro:* Hardened source code | — | — | — |
| 3.21 | performance-optimization | 99 | *Micro:* Optimized code | — | — | — |
| 3.22 | observability-and-instrumentation | 104 | Instrumented code | TS/Python | src/ | Logs + metrics + traces |
| 3.23 | code-simplification | 239 | Refactored source | — | — | Behavior unchanged |
| 3.24 | debugging-and-error-recovery | 90 | *Micro:* Bug fix + regression test | — | — | — |
| 3.25 | debugging-three-strikes | 66 | *Micro:* Strike log | — | — | — |
| 3.26 | deprecation-and-migration | 94 | *Micro:* Migration plan | — | — | — |
| 3.27 | source-driven-development | 91 | *Micro:* Doc-verified code | — | — | — |
| 3.28 | hard-skill | 149 | Hardened code | TS/CSS | src/ | WCAG, input validation |
| 3.29 | output-skill | 87 | *Micro:* Complete code | — | — | — |

#### Design Review

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.30 | critique-skill | 165 | Design review | Markdown | — | Nielsen scores, slop check |
| 3.31 | audit-skill | 150 | Audit report | Markdown | docs/audit/ | 5 dimensions scored P0-P3 |
| 3.32 | clarify-skill | 91 | *Micro:* Rewritten UX copy | — | — | — |
| 3.33 | code-review-and-quality | 136 | Review comments | Markdown/PR | PR thread | 5 axes covered |

#### Infrastructure/DevOps

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.34 | ci-cd-and-automation | 123 | Pipeline YAML | YAML | .github/ | Push/PR triggers, passes |
| 3.35 | shipping-and-launch | 163 | Launch checklist | Markdown | docs/ | Pre-flight, rollback plan |
| 3.36 | fullstack-shipping | 178 | Deployment docs | Markdown | docs/ | Steps testable |
| 3.37 | git-init-and-versioning | 243 | Repo config files | .gitignore | ./ | Initialized, env.example |
| 3.38 | git-workflow-and-versioning | 181 | Git commits | History | repo | Atomic messages |
| 3.39 | dev-environment-audit | 152 | Env report | Markdown | DEV-ENVIRONMENT.md | Tools listed |

#### Spec/Planning

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.40 | spec-driven-development | 215 | SPEC.md | Markdown | SPEC.md | 10 sections |
| 3.41 | planning-and-task-breakdown | 90 | *Micro:* Task breakdown | — | — | — |
| 3.42 | architecture-analysis | 220 | Architecture doc | Markdown | docs/ | Chosen + rejected options |
| 3.43 | interview-me | 108 | INTENT.md | Markdown | INTENT.md | ✅ Already has contract |
| 3.44 | idea-refine | 109 | Refined concept | Markdown | — | Divergent + convergent done |
| 3.45 | user-onboarding | 187 | User profile | JSON | user-profile.json | 30 preferences |
| 3.46 | context-engineering | 126 | Context config | Markdown | .opencode/ | Lazy-loaded |
| 3.47 | doubt-driven-development | 90 | *Micro:* Review findings | — | — | — |
| 3.48 | incremental-implementation | 89 | *Micro:* Committed code | — | — | — |

#### Testing

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.49 | test-driven-development | 138 | Test files | TS/Python | tests/ | All pass |
| 3.50 | browser-testing-with-devtools | 74 | *Micro:* Browser evidence | — | — | — |
| 3.51 | project-health-check | 211 | HEALTH-CHECK.md | Markdown | ./ | Matches linter |
| 3.52 | project-metrics | 151 | Metrics data | JSON | quality-metrics.json | Build pass, rework |

#### Meta

| Task | Skill | Lines | Artifact | Format | Location | Quality |
|---|---|---|---|---|---|---|
| 3.53 | documentation-and-adrs | 68 | *Micro:* ADR + README | — | — | — |
| 3.54 | skill-creator | 166 | SKILL.md + evals | Markdown/JSON | skills/ | Lint passes |
| 3.55 | skill-improver | 157 | Improvement diff | Diff | — | All checks pass |
| 3.56 | self-improvement | 88 | *Micro:* Fixes + ADRs | — | — | — |

Total: 56 commits. Each one small, each one reviewed.

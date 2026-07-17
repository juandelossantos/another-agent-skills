# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **5.0.0** (released 2026-07-13) |
| Lint | 0 errors, 0 warnings |
| Health | ✅ HEALTHY |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 29 suites passing |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | **v4.0.0** | Foundation Repair & Critical Stubs |
| **QS** | **v4.1.0** | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |
| **4** | **v5.0.0** | Docs Honesty: 42 issues fixed across 6 groups, 86 files changed |

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
| Target version | **v5.1.0** |
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

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections
- **Configurable test scoping** — `tests/run-all.sh` runs all suites regardless of changed files. On non-Node projects (Arduino, Python, etc.) the TDD gate should detect available test runners, scope to changed files, and skip gracefully if nothing is compatible. Currently hardcoded to this project's structure — Rule 0k violation (not universal).

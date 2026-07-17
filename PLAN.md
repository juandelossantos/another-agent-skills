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

**Why:** Currently DESIGN.md has no enforced schema, direction skills don't integrate with platform skills, existing projects have no upgrade path, and token drift goes undetected.

**Value to user:**
- New projects: agent produces complete design system contracts with explicit user approval at every step
- Existing projects: `design-upgrade.sh` auto-extracts tokens from codebase, fills gaps with targeted questions
- All projects: gates block incomplete DESIGN.md, catch CSS drift, enforce prototype→production transitions
- Cross-platform: same 17-section schema works for web, mobile, desktop, PWA. Direction skills compose with any platform

**How user activates it:** Through the agent. Skills detect context automatically. `design-gate.sh` runs on every design-related commit. `design-upgrade.sh` activates when user says "improve design" or when `design-gate.sh` detects an incomplete DESIGN.md. No manual script execution needed.

---

### P6.0 — Gates & Schema (Foundation)

| # | Task | Deliverable | Lines | Gate |
|---|---|---|---|---|
| P6.1 | Define 17-section DESIGN.md schema — universal template for all platforms | `engineering-fundamentals/guides/DESIGN-MD-SCHEMA.md` — documents all 17 sections, which are universal vs platform-specific, required fields per section | ~50 | — |
| P6.2 | Upgrade `design-gate.sh` — 3 modes (strict/audit/verify), validate 17 sections, detect platform and delegate | Script upgrade: strict blocks incomplete DESIGN.md on new projects, audit warns on existing, verify checks pre-merge. Detects platform from codebase, calls platform validator if available | ~40 | — |
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
| P6.11 | Upgrade our own DESIGN.md as real-world test case | Run `design-upgrade.sh` against our project. Auto-extract from CSS/HTML. Fill 7 missing sections. User confirms. `design-gate.sh --verify` passes | ~30 (documentation) | design-gate.sh --verify |
| P6.12 | Verify all gates + full pipeline integration | `design-gate.sh --strict` passes on new project. `design-gate.sh --audit` warns on legacy. `token-validate.sh` catches drift. `approval-gate.sh` blocks without approval. End-to-end flow: discovery → DESIGN.md → build → gate passes | ~20 (tests) | All gates |

---

### Summary

| Metric | Value |
|---|---|
| Branch | `feat/phase6-design-skills` |
| Target version | **v5.1.0** |
| Base | `main` |
| New scripts | 2 (`token-validate.sh`, `approval-gate.sh`) |
| Upgraded scripts | 1 (`design-gate.sh`) |
| New script | 1 (`design-upgrade.sh`) |
| Upgraded skills | 1 (`visual-frontend-mastery`) |
| Direction skills updated | 3 (brutalist, minimalist, premium) |
| Platform skills updated | 4 (web, mobile, desktop, PWA) |
| New guides | 1 (`DESIGN-MD-SCHEMA.md`) |
| New gates | 3 (strict, approval, token) |
| Total estimated lines | ~350 |
| Backward compatibility | Existing projects not broken. Upgrade is opt-in. |

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections

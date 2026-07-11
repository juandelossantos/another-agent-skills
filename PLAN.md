# Plan — Another Agent Skills

> **Source of truth** for project roadmap, phases, and status.

---

## Current Status

| Metric | Value |
|---|---|
| Version | **4.2.0** (released 2026-07-10) |
| Lint | 0 errors, 0 warnings |
| Health | ✅ HEALTHY |
| Skills | 57 with contracts, When to Use, When NOT to Use |
| Guides | 74 across all skills |
| Tests | 29 suites passing |

---

## Completed Phases

| Phase | Version | Deliverables |
|---|---|---|
| **0-2** | v4.0.0 | Foundation Repair & Critical Stubs |
| **QS** | v4.1.0 | Quick Start Guide, Spanish i18n, nav chain fix |
| **3** | **v4.2.0** | Output Contracts: 57/57, 0 warnings, pre-flight gate |

---

## Phase 4: Docs Honesty

**Goal:** Every doc surface reflects current state. No stale stats, versions, or references.

| # | Task | Acceptance |
|---|---|---|
| 4.1 | Sync PROGRESS_STATUS.md stats | Warning count = 0, Phase 3 complete |
| 4.2 | Fix "Previous releases" in docs sidebar | Shows v4.2.0 as latest |
| 4.3 | Verify i18n EN/ES consistency | All 57 refs match, no stale keys |
| 4.4 | Audit hook version references in docs | No "v7" references (commit-msg is v4) |
| 4.5 | Update HEALTH-CHECK.md recommendations | Reflects current state |
| 4.6 | Cross-reference check README, RELEASE-NOTES, PROGRESS_STATUS | All agree on version |

---

## Phase 5: Release v5.0.0

Version bump, final release notes, tag.

---

## Backlog

- Troubleshooting guide
- New skill tracks: CLI, IoT, GameDev, Container
- Self-host Google Fonts
- Polish 31 `## When NOT to Use` sections

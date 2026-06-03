# Remediation Plan — v1.6.0

**Date:** 2026-06-03
**Source:** HEALTH-CHECK.md audit
**Status:** In Progress

---

## Issues to Fix

| # | Issue | Priority | Status |
|---|---|---|---|
| 1 | README.md shows v1.5.0 (outdated) | Alta | Pending |
| 2 | PROGRESS_STATUS.md shows v11.1/10 (very outdated) | Alta | Pending |
| 3 | RELEASE-NOTES.md missing v1.6.0 entry | Alta | Pending |

---

## Fix 1: README.md

**What:** Update version badge from v1.5.0 to v1.6.0, update "What's New" section.

**Changes:**
- Line 4: Badge `v1.5.0` → `v1.6.0`
- Line 95: Section header `v1.5.0` → `v1.6.0`
- Lines 97-106: Update feature list with v1.6.0 additions

---

## Fix 2: PROGRESS_STATUS.md

**What:** Update version, metrics, and skill count to reflect v1.6.0 state.

**Changes:**
- Version: `11.1/10` → `1.6.0`
- Skill count: `15` → `38`
- Guide count: `39` → `46`

---

## Fix 3: RELEASE-NOTES.md

**What:** Add v1.6.0 entry at the top.

**Changes:**
- Add new section for v1.6.0 with commits since v1.5.0

---

## Verification

After fixes:
1. Run `bash scripts/skill-lint.sh` — should pass
2. Run `bash -n scripts/*.sh` — syntax check
3. Review changes visually

# Lazy Loading Pattern

**How skills should load content on-demand, not eagerly.**

## Problem

When an agent invokes `skill:frontend-web`, it loads the entire `SKILL.md` into context. If that skill is 500 lines, the agent loses 500 tokens of context that could be used for code/analysis.

If we have 12 custom skills × 300 lines average = 3,600 lines of instructions competing for context space with the actual task.

## Solution: Skill as Index + Guides as Lazy Content

### Pattern

```
skill-name/
├── SKILL.md              # Index: ~200 lines max
│   ├── "Phase 1 → See DISCOVERY-GUIDE.md"
│   ├── "Phase 5 → See AUTH-GUIDE.md"
│   └── Core process + stack lock-in + QA gates
├── DISCOVERY-GUIDE.md    # Loaded only when Phase 1 reached
├── AUTH-GUIDE.md         # Loaded only when Phase 5 reached
└── EXAMPLES.md           # Loaded only when troubleshooting needed
```

### Rules

1. **SKILL.md is an INDEX, not an encyclopedia**
   - Contains: When to use, stack lock-in, anti-slop rules specific to platform, QA gates
   - References: Detailed guides with "Read `GUIDE-NAME.md` for complete implementation"
   - Max 250 lines

2. **Guides contain IMPLEMENTATION DETAIL**
   - Loaded ONLY when the agent reaches that phase
   - Not loaded during skill invocation
   - Agent uses `read` tool to fetch them on-demand

3. **Foundation is loaded ONCE**
   - `engineering-fundamentals` is implicit for all skills
   - Not duplicated in every skill

## Example: Before vs After

### Before (Eager Loading — BAD)
```
# Backend API Mastery (466 lines)

## Phase 1 — Discovery (50 lines inline)
## Phase 2 — Research (60 lines inline)
## Phase 3 — Protocol Decision (80 lines inline)
## Phase 4 — Database Design (70 lines inline)
## Phase 5 — Auth Strategy (60 lines inline)
## Phase 6 — Error Handling (40 lines inline)
## Phase 7 — Testing (50 lines inline)
## Phase 8 — QA Gates (30 lines inline)
```

**Problem:** All 466 lines loaded when skill is invoked, even if user only needs Phase 1.

### After (Lazy Loading — GOOD)
```
# Backend API Mastery (200 lines)

## Phase 1 — Discovery
→ See `DISCOVERY-GUIDE.md` for complete backend discovery checklist.

## Phase 2 — Research
→ See `RESEARCH-GUIDE.md` for research methodology.

## Phase 3 — Protocol Decision
→ See `PROTOCOL-GUIDE.md` for REST/GraphQL/tRPC decision matrix.

## Phase 4 — Database Design
→ See `DATABASE-GUIDE.md` for schema design and migration strategy.

## Phase 5 — Auth Strategy
→ See `AUTH-GUIDE.md` for auth patterns and implementation.

## Phase 6 — Error Handling
[Minimal: 3 patterns, reference guide if needed]

## Phase 7 — Testing
→ See `TESTING-GUIDE.md` for test strategy.

## Phase 8 — QA Gates
[20 lines specific to backend]
```

**Benefit:** Only 200 lines loaded initially. Guides loaded on-demand as phases are reached.

## Verification

A skill follows lazy loading if:
- [ ] SKILL.md is < 250 lines
- [ ] SKILL.md references at least 2 guides with "Read `GUIDE.md` for complete..."
- [ ] Guides exist as separate files
- [ ] No implementation detail is duplicated between SKILL.md and guides
- [ ] engineering-fundamentals is not duplicated in SKILL.md

## Current Status

| Skill | Lines | Lazy Loading? | Guides |
|---|---|---|---|
| `engineering-fundamentals` | 180 | ✅ N/A (foundation) | None |
| `frontend-web` | ~200 | ✅ Yes | DISCOVERY, ANIMATION, EXAMPLES |
| `frontend-pwa` | ~200 | ✅ Yes | DISCOVERY, EXAMPLES |
| `frontend-mobile` | ~200 | ✅ Yes | DISCOVERY, ANIMATION, EXAMPLES |
| `backend-api-mastery` | ~200 | ✅ Yes | DISCOVERY, PROTOCOL, AUTH, TESTING |
| `spec-driven-development` | 329 | ✅ Yes | DISCOVERY-GUIDE, SPEC-TEMPLATE-GUIDE |
| `fullstack-shipping` | 307 | ✅ Yes | CICD-GUIDE, DEPLOY-GUIDE, LAUNCH-CHECKLIST-GUIDE |
| `git-init-and-versioning` | 356 | ✅ Yes | REPO-STRUCTURE-GUIDE, BRANCHING-GUIDE, BUILD-INTEGRATION-GUIDE |

### Refactored Example: backend-api-mastery

**Before:** 466 lines (all content inline)
**After:** ~200 lines (index) + 4 guides (~300 lines total)

```
backend-api-mastery/
├── SKILL.md              # ~200 lines: index with phase summaries
├── DISCOVERY-GUIDE.md    # Phase 1: complete discovery checklist
├── PROTOCOL-GUIDE.md     # Phase 3: REST/GraphQL/tRPC decision matrix
├── AUTH-GUIDE.md         # Phase 5: auth strategy + security checklist
└── TESTING-GUIDE.md      # Phase 6B: testing pyramid + error codes
```

**Impact:** Agent loads only 200 lines initially. Guides loaded on-demand as phases are reached.

## Goal

All skills < 250 lines, with detailed content in lazily-loaded guides.

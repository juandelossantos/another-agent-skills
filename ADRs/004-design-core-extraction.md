# ADR-004: Design Core Extraction — Universal Design Across Platforms

**Date:** 2026-05-26
**Status:** Accepted

## Context

Our `frontend-web` skill had a complete design system (Three Dials, anti-slop, pre-flight checks) while `frontend-mobile`, `frontend-desktop`, and `frontend-pwa` remained on the old 8-direction system. This created an uneven experience — web builds received rigorous design guidance while other platforms did not.

The Three Dials System (VARIANCE, MOTION, DENSITY) is inherently platform-agnostic: any UI has symmetry, motion, and density. The anti-slop tells (AI defaults, content density rules, copy protocol) are also universal. Only the implementation details differ per platform (animation libraries, font stacks, build commands).

## Decision

Extract the universal design core from `frontend-web` into `engineering-fundamentals/guides/`:

1. **`DESIGN-CORE.md`** — Three Dials System, Brief Inference, universal color principles (Lila Rule, Premium-Consumer Ban), dark mode protocol
2. **`ANTI-SLOP-CORE.md`** — Universal AI tell catalogue, content density, copy protocol, UI state requirements, emoji policy
3. **`PRE-FLIGHT-CORE.md`** — Universal pre-output checklist (color, content, motion, AI tells, accessibility, technical)

Each platform skill now:
- Phase 3 → reads `DESIGN-CORE.md` + platform-specific DESIGN-GUIDE.md
- Phase 5 → reads `ANTI-SLOP-CORE.md` + platform-specific ANTI-SLOP-GUIDE.md
- Phase 8 → reads `PRE-FLIGHT-CORE.md` + platform-specific PRE-FLIGHT.md

## Changes

- Created 3 CORE guides (345 total lines, lazy-loaded)
- Updated `engineering-fundamentals` Phase 3/4/5 to reference CORE guides
- Refactored `frontend-web` SKILL.md (−24 lines), guides reference CORE
- Migrated `frontend-mobile` to Three Dials System, created ANIMATION-GUIDE.md, DISCOVERY-GUIDE.md
- Migrated `frontend-desktop` to Three Dials System, created PLATFORM-GUIDE.md, DISCOVERY-GUIDE.md, EXAMPLES.md
- Migrated `frontend-pwa` to Three Dials System, created DISCOVERY-GUIDE.md

## Rationale

- Single source of truth for design philosophy — change once, propagate to all platforms
- Platform skills stay focused on platform-specific implementation
- Lazy-loaded — no context budget impact (only loaded when a platform skill is active)
- Easy to add future platforms (TV, watch, CLI) — they reference CORE + add their rules

## Consequences

- All platform skills now have consistent design guidance
- Future design system improvements go in CORE guides, not per-platform
- Existing projects using old 8-direction system need Phase 3 update
- Guides directory under engineering-fundamentals adds discoverability

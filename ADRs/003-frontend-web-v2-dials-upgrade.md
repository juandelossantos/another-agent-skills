# ADR-003: Frontend Web v2 — Three Dials System & Anti-Slop Upgrade

**Date:** 2026-05-26
**Status:** Accepted

## Context

Our `frontend-web` skill used 8 fixed aesthetic directions (ED, SM, LDW, CB, UE, NB, PG, RT) selected from engineering-fundamentals. This was rigid — the agent picked a direction and built within it, with limited anti-slop enforcement (~6 generic rules, 12 QA checks).

Analysis of Taste Skill (⭐21.9k) revealed a more parametric, research-backed approach with 3 dials, 85+ AI tells, and 54 mechanical pre-flight checks.

## Decision

Adopt the Three Dials System and create supporting guides:

1. **Replace 8 directions with 3 dials** (VARIANCE, MOTION, DENSITY) + vibe→dial inference
2. **Add Brief Inference Phase 0b** (read 6 signals, output Design Read, anti-default discipline)
3. **Add Design System Map Phase 3b** (10+ official systems mapped by brief type)
4. **Create DESIGN-GUIDE.md** (dial tech ref, typography, color, palettes, dark mode)
5. **Create ANTI-SLOP-GUIDE.md** (85+ AI tells, content density, copy protocol)
6. **Create PRE-FLIGHT.md** (54 mechanical checks with binary pass/fail)
7. **Update ANIMATION-GUIDE.md** (StickyStack, HorizontalPan, RevealStagger skeletons)
8. **Create IMAGE-STRATEGY.md** (gen-tool-first pipeline, logo-only rule)
9. **Create REDESIGN-GUIDE.md** (audit protocol for existing codebases)
10. **Create specialized style skills** (minimalist, soft-premium, brutalist, redesign, output)

## Rationale

- Dials are more flexible and precise than 8 fixed directions
- 85+ AI tells are grounded in observed LLM failure modes (supported by taste-skill research)
- 54 mechanical pre-flight checks are verifiable (not subjective)
- Brief inference prevents the agent from jumping to defaults
- All guide content is lazy-loaded, keeping the SKILL.md index at 254 lines

## Consequences

- Existing projects using the old 8-direction system will need DESIGN.md updates
- The engineering-fundamentals Phase 3 now points to platform-specific systems
- All frontend skills now have consistent anti-slop enforcement
- Health check metric: skills ≤ 250 lines still passes (index at 254, guides excluded)

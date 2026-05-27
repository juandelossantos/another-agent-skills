# Release Notes

## 1.1.0 (2026-05-26)

v1.1.0: Fix 9 audit issues, add RELEASE-GUIDE, add release.sh

- Remove broken cli-tools reference from AGENTS.md
- Fix executable permissions on pre-commit hook and uninstall.sh
- Remove orphan AGENTS.md.backup from root
- Add SKILL.md to debugging-three-strikes
- Add RELEASE-GUIDE.md to git-init-and-versioning (Phase 9)
- Update Rule 6: 250 lines max, micro-skills exempt from 2-guide rule
- Update HEALTH-CHECK.md AGENTS-EXTENDED line count
- Add scripts/release.sh with -m flag for non-interactive usage
- README: version badge updated automatically


## 1.0.0 (2026-05-26)

Initial versioned release of Another Agent Skills.

### Features
- **Design Core Extraction (ADR-004):** 3 shared CORE guides (DESIGN, ANTI-SLOP, PRE-FLIGHT)
  in `engineering-fundamentals/guides/`. All platforms (web, mobile, desktop, pwa)
  now share the same Three Dials design system.
- **Frontend Web v2:** Three Dials System replaces 8 fixed directions. Brief Inference (Phase 0b),
  Design System Map (Phase 3b). 85+ anti-slop tells, 54 pre-flight checks.
- **Frontend Mobile:** New Three Dials system. Animation guides (Reanimated + Gesture Handler),
  discovery guide for mobile.
- **Frontend Desktop:** Three Dials applied. Native Tauri integration guides (menus, system tray,
  file dialogs, global shortcuts), discovery guide, examples.
- **Frontend PWA:** Three Dials with cross-device constraints. Discovery guide.
- **5 specialized skills:** industrial-brutalist-ui, minimalist-ui, soft-premium-ui, output-skill,
  redesign-skill.
- **Auto-update system:** `VERSION`, `RELEASE-NOTES.md`, `scripts/check-update.sh` — checks for
  updates when entering projects. Asks before updating.

### ADRs
- ADR-003: Frontend Web v2 — Three Dials System
- ADR-004: Design Core Extraction

### Fixes
- HEALTH-CHECK.md metrics updated (skills, always-loaded, pre-flight count)
- SKILL.md line counts corrected (< 250 each)
- IMAGE-STRATEGY.md now referenced from SKILL.md
- .opencode/skills/ symlinks for discoverable skills
- Pre-action checklist: commit message visibility + git status/fetch check

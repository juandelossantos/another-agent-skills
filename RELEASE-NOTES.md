# Release Notes

## 1.0.0 (2026-05-26)

Initial release of Another Agent Skills con sistema de versionado.

### Features
- **Design Core Extraction (ADR-004):** 3 guías CORE compartidas (DESIGN, ANTI-SLOP, PRE-FLIGHT)
  en `engineering-fundamentals/guides/`. Todas las plataformas (web, mobile, desktop, pwa)
  ahora comparten el mismo sistema de diseño Three Dials.
- **Frontend Web v2:** Three Dials System reemplaza 8 direcciones fijas. Brief Inference (Phase 0b),
  Design System Map (Phase 3b). 85+ anti-slop tells, 54 pre-flight checks.
- **Frontend Mobile:** Nuevo sistema Three Dials. Guides de animación (Reanimated + Gesture Handler),
  discovery guide para mobile.
- **Frontend Desktop:** Three Dials aplicado. Guías de integración nativa Tauri (menús, system tray,
  file dialogs, global shortcuts), discovery guide, examples.
- **Frontend PWA:** Three Dials con constraints cross-device. Discovery guide.
- **5 specialized skills:** industrial-brutalist-ui, minimalist-ui, soft-premium-ui, output-skill,
  redesign-skill.
- **Auto-update system:** `VERSION`, `RELEASE-NOTES.md`, `scripts/check-update.sh` — revisa
  actualizaciones al entrar a proyectos. Pregunta antes de actualizar.

### ADRs
- ADR-003: Frontend Web v2 — Three Dials System
- ADR-004: Design Core Extraction

### Fixes
- HEALTH-CHECK.md metrics actualizadas (skills, always-loaded, pre-flight count)
- SKILL.md line counts corregidas (< 250 todas)
- IMAGE-STRATEGY.md ahora referenciado desde SKILL.md
- .opencode/skills/ symlinks para skills descubribles
- Pre-action checklist: commit message visibility + git status/fetch check

---
name: frontend-pwa
description: >
  Build installable, offline-first web apps for all devices with migration path to
  native via Capacitor. Built on engineering-fundamentals. Triggers on: "PWA",
  "offline", "installable", "Capacitor", "Ionic", "hybrid", "cross-platform".
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-capacitor
  workflow: design-driven-build
  foundation: engineering-fundamentals
---

# Frontend PWA

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
PWA-specific implementation.

## When to Use

- Web app with offline functionality
- Installable experience (add to homescreen)
- Cross-device (phone, tablet, foldable, TV, desktop)
- Future native distribution via Capacitor/Ionic

Do NOT use for:
- Simple marketing sites with no offline needs (use `frontend-web`)
- Pure native apps (use `frontend-mobile`)

### Context Persistence Check

Before starting work:
1. Check `design/DESIGN-LOCK.md`:
   - Exists and < 7 days → Read it. Extract direction, palette, typography, key decisions.
   - > 7 days → Read it, ask: "Still valid?"
   - Missing → Proceed with Phase 1.
2. Check `SPEC.md`:
   - Exists → Read it. Respect locked stack and boundaries.
   - Missing → If non-trivial, invoke `spec-driven-development`.
3. If context exists → Resume from detected phase. Do NOT re-run discovery unless user requests changes.

### Stack Detection

Check for `STACK_CONFIG.md`:
- **Exists** → Adapt examples to chosen stack.
- **Missing** → Default to Next.js 16 + Tailwind v4 + Workbox + Capacitor 6.

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for universal discovery.

**PWA-specific questions:**
1. **Offline**: Must work without internet? Which parts?
2. **Installable**: Installable from browser?
3. **Native migration**: Future App Store / Google Play?
4. **Devices**: Mobile only, or tablet, desktop, TV?
5. **Touch vs mouse**: Users touch or use mouse?
6. **Push notifications**: Needed?
7. **Background sync**: Sync when connection returns?

Read `DISCOVERY-GUIDE.md` for complete PWA checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**PWA-specific additions:**
- SPEC.md must include: Offline strategy, Install requirements, Device matrix, Native bridge needs.

---

### Phase 3 — Three Dials System

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System (VARIANCE, MOTION, DENSITY), vibe→dial inference, color principles, and dark mode protocol.

Apply dials with PWA constraints: MOTION uses web APIs (Framer Motion + CSS), DENSITY must work across 280px→3840px viewports, VARIANCE collapses at mobile breakpoints.

---

### Phase 4 — Stack Lock-in

| Tool | Minimum | Notes |
|---|---|---|
| Node.js | 20.9+ | |
| Next.js | 16.1.1+ | App Router |
| React | 19.2+ | |
| TypeScript | 5.7+ | |
| Tailwind CSS | v4 | `@theme` in CSS |
| Workbox | 7+ | Service worker generation |
| Capacitor | 6+ | Native bridge (optional, if migration planned) |
| Vite PWA | 0.20+ | If using Vite |

Optional: `next-pwa`, `@capacitor/core` + plugins.

---

### Phase 5 — Anti-Slop Rules (PWA)

→ See `engineering-fundamentals/guides/ANTI-SLOP-CORE.md` for universal AI tells, content density, copy protocol, and UI state requirements.

**PWA-specific:**
- **Touch:** No hover-only interactions. Targets ≥44px (iOS) / 48dp (Android). `@media (hover: hover)` for hover conditionally.
- **Viewport:** No `100vh` on mobile. Use `100dvh`.
- **Device agnostic:** Test 280px→3840px. Container queries for component layouts.
- **Offline-first:** Never assume internet. Cache critical assets. Show stale data while syncing.

---

### Phase 6 — Universal Responsive

→ **See `DEVICE-MATRIX-GUIDE.md` for device matrix, container queries, touch vs mouse patterns.**

---

### Phase 7 — PWA Architecture

→ **See `PWA-ARCHITECTURE-GUIDE.md` for service worker, manifest, offline pages, native migration path.**

---

### Phase 8 — Build with Tokens

1. Read `design/DESIGN-LOCK.md` and `design/approved/`
2. Apply tokens to `globals.css`
3. `manifest.json` / `manifest.ts`
4. Service worker registration
5. Capacitor config (if migration planned)
6. Viewport units: `dvh` where appropriate

---

### Phase 9 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates. Read `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` for universal checks first.

**After QA gates, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory]
- gate_name: frontend-pwa-qa
- result: pass/fail
- checks_passed: [N]/20
```

**PWA-specific checks (13-20):**

13. **Offline test** — Disable network. App loads, cached data visible.
14. **Install test** — Lighthouse PWA audit passes.
15. **Device matrix** — Tested 375px, 768px, 1024px, 1920px.
16. **Touch targets** — Interactive elements ≥44px / 48dp.
17. **No hover-only** — Every hover has touch equivalent.
18. **Viewport safe** — No `100vh` without `100dvh` fallback.
19. **Foldable** — Layout works on 280px, survives foldable transitions.
20. **Capacitor ready** — If migration planned, `npx cap sync` succeeds.

---

## Examples & Troubleshooting

→ Read `EXAMPLES.md`.

---

## Red Flags

- No service worker or manifest.
- `100vh` without `100dvh` fallback.
- Hover-only without touch alternatives.
- No offline page.
- No container queries.
- Untested on tablet/desktop.

---

## Verification

- `manifest.json` with `display: standalone`.
- Service worker registered.
- Offline page exists.
- No `100vh` without `100dvh`.
- Container queries used.
- Touch targets ≥44px.
- Hover guarded with `@media (hover: hover)`.
- Tested on ≥4 breakpoints.
- Capacitor config if migration planned.

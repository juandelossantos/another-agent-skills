---
name: frontend-pwa
description: >
  Build installable, offline-first web apps for all devices with migration path to
  native via Capacitor. Built on engineering-fundamentals. Use when the user wants
  a web app with offline functionality, installable experience, or future native
  distribution. Triggers on: "PWA", "offline app", "installable", "Capacitor",
  "Ionic", "hybrid app", "cross-platform web", "device agnostic".
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-capacitor
  workflow: design-driven-build
  foundation: engineering-fundamentals
---

# Frontend PWA

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
PWA-specific implementation to the universal philosophy.

## When to Use

Use when the user wants:
- A web app with offline functionality
- An installable experience (add to homescreen)
- Cross-device compatibility (phone, tablet, foldable, TV, desktop)
- Future native distribution via Capacitor or Ionic

Do NOT use for:
- Simple marketing sites with no offline needs (use `frontend-web`)
- Pure native apps with no web component (use `frontend-mobile`)

### Stack Detection

Before applying instructions, check for `STACK_CONFIG.md`.

**If exists:** Adapt to chosen stack (e.g., Vue + Vite + Capacitor).
**If missing:** Default to Next.js 16 + Tailwind v4 + Workbox + Capacitor 6.

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for the universal discovery process.

**PWA-specific questions (add to universal):**
1. **Offline**: ¿Funciona sin internet? ¿Qué partes?
2. **Installable**: ¿Instalable desde el navegador?
3. **Native migration**: ¿Futuro App Store / Google Play?
4. **Devices**: ¿Solo móvil, o tablet, desktop, TV?
5. **Touch vs mouse**: ¿Usuarios principales tocan o usan mouse?
6. **Push notifications**: ¿Necesitas notificaciones?
7. **Background sync**: ¿Sincronización cuando vuelva la conexión?

Read `DISCOVERY-GUIDE.md` in this skill directory for the complete PWA checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**PWA-specific contract additions:**
- SPEC.md must include: Offline strategy, Install requirements, Device matrix, Native bridge needs.

---

### Phase 3 — Aesthetic Direction
→ See `engineering-fundamentals` Phase 3.

Same 8 directions (ED, SM, LDW, CB, UE, NB, PG, RT). Pick ONE.

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

→ See `engineering-fundamentals` Phase 4 for universal principles.

**PWA-specific rules:**

**Touch Optimization**
- NEVER use hover-only interactions (tooltips, dropdowns on hover).
- ALWAYS provide touch alternatives (tap, long-press, swipe).
- Touch targets minimum 44px (iOS) / 48dp (Android).
- Use `@media (hover: hover)` to conditionally add hover effects.

**Viewport Safety**
- NEVER use `100vh` on mobile (breaks with browser UI chrome).
- ALWAYS use `100dvh`, `100svh`, or `100lvh`.

**Device Agnostic**
- NEVER design only for 375px and 1280px.
- ALWAYS test: 280px (foldable), 375px (phone), 768px (tablet), 1024px (tablet landscape), 1920px (desktop), 3840px (TV).
- Use **container queries** for component-level responsiveness.

**Offline-First**
- NEVER assume internet is always available.
- ALWAYS cache critical assets. Show cached data while syncing.

---

### Phase 6 — Universal Responsive Design

**Device Matrix (MANDATORY):**

| Device | Width | Approach |
|---|---|---|
| Foldable closed | 280-320px | Single column, essential only |
| Phone portrait | 375-428px | Mobile-first design |
| Phone landscape | 667-926px | Adjusted layout |
| Tablet portrait | 768-834px | Sidebar may appear |
| Tablet landscape | 1024-1366px | Full layout, multi-pane |
| Desktop | 1280-1920px | Full experience, hover available |
| TV / Big screen | 1920-3840px | Larger touch targets, simpler navigation |

**Container Queries (Preferred over Media Queries):**

```css
.card-container { container-type: inline-size; }
@container (min-width: 400px) {
  .card-grid { grid-template-columns: repeat(2, 1fr); }
}
```

**Touch vs Mouse:**

```css
@media (hover: hover) and (pointer: fine) {
  .button:hover { transform: scale(1.02); }
}
@media (pointer: coarse) {
  .button { min-height: 48px; }
}
```

---

### Phase 7 — PWA Architecture

**Service Worker:**
- Use Workbox or `next-pwa` to auto-generate.
- Cache strategy: `CacheFirst` for static, `NetworkFirst` for API.
- Background sync for offline mutations.

**Web App Manifest:**
```json
{
  "name": "Mi App",
  "short_name": "MiApp",
  "start_url": "/",
  "display": "standalone",
  "orientation": "portrait",
  "theme_color": "#0A0A0F",
  "background_color": "#0A0A0F",
  "icons": [...]
}
```

**Offline Pages:**
- Always have a fallback offline page.
- Show stale data with "syncing..." indicator.

---

### Phase 8 — Build with Tokens

1. **Read `design/DESIGN-LOCK.md`** and `design/approved/`
2. Apply tokens to `globals.css`
3. `manifest.json` / `manifest.ts` in `public/` or `app/`
4. Service worker registration
5. Capacitor config (if migration planned): `capacitor.config.ts`
6. All viewport units use `dvh` where appropriate

---

### Phase 9 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates.

**PWA-specific checks:**

13. **Offline test** — Disable network. App loads and shows cached data.
14. **Install test** — Lighthouse PWA audit passes.
15. **Device matrix** — Tested on 375px, 768px, 1024px, 1920px minimum.
16. **Touch targets** — All interactive elements >= 44px / 48dp.
17. **No hover-only** — Every hover has a touch equivalent.
18. **Viewport safe** — No `100vh` without `100dvh` fallback.
19. **Foldable** — Layout doesn't break on 280px or foldable transitions.
20. **Capacitor ready** — If migration planned, `npx cap sync` succeeds.

---

## Migration Path to Native (Optional)

If future App Store / Google Play:

1. **Now (Web PWA):** Build with offline support. Use Capacitor plugins where needed.
2. **Later (Native Wrapper):**
   ```bash
   npm install @capacitor/core @capacitor/cli
   npx cap init
   npx cap add ios && npx cap add android
   npx cap sync
   ```
3. **Progressive Enhancement:**
   ```typescript
   import { Capacitor } from '@capacitor/core';
   const isNative = Capacitor.isNativePlatform();
   // If native: use Capacitor plugins. If web: use Web APIs.
   ```

---

## Examples & Troubleshooting

Read `EXAMPLES.md` in this skill directory:
- New PWA walkthrough (15 steps)
- Adding offline support to existing web app
- Troubleshooting (service worker, install prompt, 100vh, hover)

---

## Red Flags (PWA-Specific)

- No service worker or manifest.
- `100vh` used without `100dvh` fallback.
- Hover-only interactions with no touch alternatives.
- No offline page or fallback.
- Container queries not used for component layouts.
- Not tested on tablet or desktop sizes.

---

## Verification

- `manifest.json` exists with `display: standalone`.
- Service worker registered (Workbox or `next-pwa`).
- Offline page / fallback exists.
- No `100vh` without `100dvh`.
- Container queries used for component layouts.
- Touch targets >= 44px.
- `@media (hover: hover)` guards around hover effects.
- Tested on minimum 4 breakpoints.
- Capacitor config exists if native migration planned.

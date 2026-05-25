---
name: frontend-pwa
description: >
  Build web apps designed to work everywhere — browsers, installable homescreens,
  and wrapped as native mobile apps. Covers Progressive Web Apps (PWA), offline-first
  architecture, responsive design for all devices (phones, tablets, foldables, TVs),
  touch optimization, and Capacitor/Ionic integration for native app distribution.
  Use when the user wants a web app that may become a mobile app, needs offline
  functionality, installable experience, or cross-device compatibility. Triggers on:
  "PWA", "offline app", "installable", "Capacitor", "Ionic", "hybrid app",
  "web app that works on mobile", "cross-platform web", "device agnostic".
license: MIT
compatibility: opencode
metadata:
  audience: frontend-developers
  stack: nextjs-react-tailwind-capacitor
  workflow: design-driven-build
---

# Frontend PWA (Progressive Web App)

Build web apps that **work everywhere** — browser, homescreen, and app store.
This skill enforces offline-first architecture, universal responsive design,
installable experience, and a migration path from web to native via Capacitor or Ionic.

## When to Use

Use this skill when:
- The user wants a web app with offline functionality
- The app may be distributed as a native mobile app in the future
- Cross-device compatibility is required (phone, tablet, foldable, TV, desktop)
- The user mentions PWA, Capacitor, Ionic, or "works like an app"
- Touch and mouse users must both have great experiences

Do NOT use for:
- Simple marketing sites with no offline needs (use `frontend-web`)
- Pure native apps with no web component (use `frontend-mobile`)
- Backend-only tasks

### Stack Detection

Before applying any instruction, check for `STACK_CONFIG.md`.

**If `STACK_CONFIG.md` exists:**
- Read it. Adapt to chosen stack (e.g., Vue + Vite + Capacitor instead of Next.js).
- Principles remain the same.

**If no `STACK_CONFIG.md` exists:**
- Default to Next.js 16 + React 19 + Tailwind v4 + Capacitor 6 (documented below).
- Ask: "¿Quieres usar Next.js + Capacitor (default) o prefieres otra combinación?"

---

## Core Process

### Phase 0 — Language Detection

Same as `frontend-web` and `frontend-mobile`. Detect language. Never mix.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

Read `DISCOVERY-GUIDE.md` in this skill directory.

**PWA-specific discovery questions (in addition to universal):**
1. **Offline needs**: ¿La app funciona sin internet? ¿Qué partes?
2. **Installable**: ¿Quieres que los usuarios la instalen desde el navegador?
3. **Native migration**: ¿Planeas publicarla en App Store / Google Play en el futuro?
4. **Device targets**: ¿Solo móvil, o también tablet, desktop, TV?
5. **Touch vs mouse**: ¿Usuarios principales tocan la pantalla o usan mouse?
6. **Push notifications**: ¿Necesitas notificaciones push?
7. **Background sync**: ¿Datos deben sincronizarse cuando vuelva la conexión?

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

Invoke `spec-driven-development` if no SPEC.md exists.

Must include: Offline strategy, Install requirements, Device matrix, Native bridge needs.

#### 2B: DESIGN.md

Visual tokens only. Same rules as `frontend-web`.

#### 2D: Design Asset Lock

Same as `frontend-web`.

---

### Phase 3 — Stack Lock-in

| Tool | Minimum | Notes |
|---|---|---|
| Node.js | 20.9+ | |
| Next.js | 16.1.1+ | App Router |
| React | 19.2+ | |
| TypeScript | 5.7+ | |
| Tailwind CSS | v4 | `@theme` in CSS |
| Workbox | 7+ | Service worker generation |
| Capacitor | 6+ | Native bridge (optional, if migration planned) |
| Vite PWA | 0.20+ | If using Vite instead of Next.js |

Optional: `next-pwa` (for Next.js PWA), `@capacitor/core` + plugins.

---

### Phase 4 — Anti-AI-Slop Rules (PWA Extended)

All rules from `frontend-web`, PLUS:

**Touch Optimization**
- NEVER use hover-only interactions (tooltips, dropdowns on hover).
- ALWAYS provide touch alternatives (tap, long-press, swipe).
- Touch targets minimum 44px (iOS) / 48dp (Android).
- Use `@media (hover: hover)` to conditionally add hover effects.

**Viewport Safety**
- NEVER use `100vh` on mobile (breaks with browser UI chrome).
- ALWAYS use `100dvh`, `100svh`, or `100lvh` (dynamic, small, large viewport).

**Device Agnostic**
- NEVER design only for 375px and 1280px.
- ALWAYS test: 280px (foldable closed), 375px (phone), 768px (tablet portrait), 1024px (tablet landscape), 1920px (desktop), 3840px (TV).
- Use **container queries** for component-level responsiveness, not just media queries.

**Offline-First**
- NEVER assume internet is always available.
- ALWAYS cache critical assets. Show cached data while syncing in background.
- Use service workers for asset caching (Workbox or `next-pwa`).

---

### Phase 5 — Universal Responsive Design

**Device Matrix (MANDATORY breakpoints):**

| Device | Width | Approach |
|---|---|---|
| Foldable closed | 280-320px | Single column, essential only |
| Phone portrait | 375-428px | Mobile-first design |
| Phone landscape | 667-926px | Adjusted layout, two columns where useful |
| Tablet portrait | 768-834px | Sidebar may appear, more content visible |
| Tablet landscape | 1024-1366px | Full layout, multi-pane possible |
| Desktop | 1280-1920px | Full experience, hover available |
| TV / Big screen | 1920-3840px | Larger touch targets, simpler navigation |

**Container Queries (Preferred over Media Queries):**

```css
/* ❌ Media query: tied to screen size */
@media (min-width: 768px) { .card-grid { grid-template-columns: 2fr 1fr; } }

/* ✅ Container query: tied to component container */
.card-container {
  container-type: inline-size;
}
@container (min-width: 400px) {
  .card-grid { grid-template-columns: repeat(2, 1fr); }
}
@container (min-width: 700px) {
  .card-grid { grid-template-columns: repeat(3, 1fr); }
}
```

**Touch vs Mouse:**

```css
/* Hover only on devices with mouse */
@media (hover: hover) and (pointer: fine) {
  .button:hover { transform: scale(1.02); }
  .card:hover { box-shadow: var(--shadow-lg); }
}

/* Touch-specific */
@media (pointer: coarse) {
  .button { min-height: 48px; }
  .card { /* No hover effects, use active states instead */ }
}
```

---

### Phase 6 — PWA Architecture

**Service Worker:**
- Use Workbox or `next-pwa` to auto-generate.
- Cache strategy: `CacheFirst` for static assets, `NetworkFirst` for API calls.
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
- Show stale data with "syncing..." indicator instead of blank screens.

---

### Phase 7 — Build with Tokens

Same as `frontend-web`, with additions:
- `manifest.json` / `manifest.ts` in `public/` or `app/`
- Service worker registration
- `next-pwa` or Workbox configuration
- Capacitor config (if migration planned): `capacitor.config.ts`
- All viewport units use `dvh`, `svh`, `lvh` where appropriate

---

### Phase 8 — QA Gates

All 12 checks from `frontend-web`, PLUS:

13. **Offline test** — Disable network. App still loads and shows cached data.
14. **Install test** — Chrome DevTools → Lighthouse → PWA audit passes.
15. **Device matrix** — Tested on 375px, 768px, 1024px, 1920px at minimum.
16. **Touch targets** — All interactive elements >= 44px (iOS) / 48dp (Android).
17. **No hover-only features** — Every hover has a touch equivalent.
18. **Viewport safe** — No `100vh` without `100dvh` fallback.
19. **Foldable** — Layout doesn't break on 280px or foldable transitions.
20. **Capacitor ready** — If migration planned, `npx cap init` + `npx cap sync` succeeds.

---

## Migration Path to Native (Optional)

If the user wants to publish in App Store / Google Play later:

1. **Now (Web PWA):**
   - Build as PWA with offline support
   - Use Capacitor plugins where needed (camera, GPS, etc.)
   - Keep web and native logic separate where possible

2. **Later (Native Wrapper):**
   - `npm install @capacitor/core @capacitor/cli`
   - `npx cap init`
   - `npx cap add ios` / `npx cap add android`
   - `npx cap sync`
   - Build native apps from same codebase

3. **Progressive Enhancement:**
   - Detect native platform: `Capacitor.isNativePlatform()`
   - If native: use Capacitor plugins
   - If web: use Web APIs

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "PWA is just a web app with a manifest." | A real PWA is offline-first, installable, and responsive to all devices. A manifest alone is not enough. |
| "I'll add offline support later." | Offline-first must be designed from the start. Retrofitting is 3x harder. |
| "My users only use iPhone." | iPhone users install PWAs too. And they rotate to landscape. Design for all. |
| "Hover works on iPad with mouse." | Most users touch. Hover is an enhancement, not a requirement. |
| "Container queries are too new." | Supported in all modern browsers since 2023. Use them. |
| "Capacitor is just a webview." | Yes, but it gives you native plugins, push notifications, and app store distribution. It's a bridge, not a crutch. |

---

## Verification

Evidence this skill was followed:
- `manifest.json` exists with `display: standalone`
- Service worker registered (Workbox or `next-pwa`)
- Offline page / fallback exists
- No `100vh` without `100dvh`
- Container queries used for component layouts
- Touch targets >= 44px
- `@media (hover: hover)` guards around hover effects
- Tested on minimum 4 breakpoints (phone, tablet, desktop, TV)
- Capacitor config exists if native migration planned

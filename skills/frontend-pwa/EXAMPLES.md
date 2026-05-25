# PWA Examples & Troubleshooting

This guide contains practical examples and common issues for `frontend-pwa`.

---

## Example 1: New PWA (15 Steps)

### Scenario
User: *"Crea una app de notas que funcione sin internet. Quiero instalarla en mi teléfono y que se vea como app nativa. A futuro quizás la publique en App Store."*

### Step-by-Step

1. **Detect platform:** PWA (hybrid, future native migration)
2. **Invoke `frontend-pwa`**
3. **Phase 1 — Discovery:**
   - Audience: Personal use, public consumers
   - Purpose: Take notes offline, sync when online
   - Offline: Fully offline with background sync
   - Installable: Yes, with custom install prompt
   - Devices: Phone + tablet
   - Input: Touch primary, keyboard for typing
   - Native features: None for MVP
   - Migration: Future possibility
   → User confirms

4. **Phase 2 — SPEC.md:**
   - Invoke `spec-driven-development`
   - Include: Offline strategy (IndexedDB + service worker), Background sync, Install prompt

5. **Phase 2 — DESIGN.md:**
   - Aesthetic: Swiss Minimal
   - Tokens: Light theme, clean typography
   → User confirms

6. **Design Asset Lock**

7. **PLAN phase:**
   - Screens: Notes list → Note detail → Settings
   - Offline: IndexedDB for notes, service worker for assets
   - Sync: Background sync when online

8. **Phase 3 — Stack:**
   - Next.js 16 + React 19 + Tailwind v4
   - Workbox for service worker
   - next-pwa for PWA config
   - Capacitor config prepared (for future migration)

9. **Phase 6 — Build:**
   - Theme tokens in CSS
   - `manifest.json` with `display: standalone`
   - Service worker with Workbox (cache-first for static, network-first for API)
   - IndexedDB via `idb` or `localforage`
   - Offline fallback page
   - Custom install button (only shows if `beforeinstallprompt` fires)
   - Container queries for responsive cards
   - Touch targets >= 48px

10. **QA Gates:**
    - TypeScript passes
    - `npm run build` succeeds
    - Lighthouse PWA audit: 100
    - Offline test: Disable network, app loads
    - Install test: Chrome DevTools → Application → Manifest → "Add to homescreen"
    - Device matrix: 375px, 768px, 1024px
    - Touch targets all >= 48px
    - No hover-only features
    - Container queries used

---

## Example 2: Adding Offline Support to Existing Web App

### Scenario
User: *"Mi app actual solo funciona online. Quiero que los usuarios puedan ver sus datos sin internet."*

### Solution

```typescript
// Service worker with Workbox
import { precacheAndRoute } from 'workbox-precaching';
import { NetworkFirst, CacheFirst } from 'workbox-strategies';
import { registerRoute } from 'workbox-routing';

// Precache static assets generated at build time
precacheAndRoute(self.__WB_MANIFEST);

// API calls: try network first, fallback to cache
registerRoute(
  ({ url }) => url.pathname.startsWith('/api/'),
  new NetworkFirst({
    cacheName: 'api-cache',
    plugins: [
      {
        cacheWillUpdate: async ({ response }) => {
          if (response.status === 200) return response;
          return null;
        },
      },
    ],
  })
);

// Static assets: cache first
registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst({ cacheName: 'image-cache' })
);
```

```tsx
// React component with offline awareness
import { useEffect, useState } from 'react';

function OfflineIndicator() {
  const [isOnline, setIsOnline] = useState(navigator.onLine);

  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  if (isOnline) return null;

  return (
    <div className="fixed top-0 left-0 right-0 bg-amber-500 text-white text-center py-2 z-50">
      Sin conexión. Los cambios se sincronizarán cuando vuelvas a estar online.
    </div>
  );
}
```

---

## Troubleshooting

### Issue: 100vh breaks on mobile Safari

**Symptoms:** Content hidden behind Safari bottom bar.

**Solution:**
```css
/* ❌ WRONG */
.hero { height: 100vh; }

/* ✅ CORRECT */
.hero { height: 100dvh; }
/* Or safer fallback */
.hero {
  height: 100vh; /* fallback */
  height: 100dvh; /* modern browsers */
}
```

---

### Issue: Hover effects don't work on touch devices

**Symptoms:** Tooltips, dropdowns, hover cards don't open on phones.

**Solution:**
```css
/* ❌ WRONG: hover-only */
.tooltip:hover .tooltip-content { display: block; }

/* ✅ CORRECT: hover for mouse, tap for touch */
.tooltip:hover .tooltip-content,
.tooltip:focus-within .tooltip-content,
.tooltip.active .tooltip-content { display: block; }
```

```tsx
// Or use feature detection
const supportsHover = window.matchMedia('(hover: hover)').matches;
```

---

### Issue: Service worker not updating

**Symptoms:** Users see old version after deployment.

**Solution:**
```typescript
// In your service worker registration
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').then((reg) => {
    reg.addEventListener('updatefound', () => {
      const newWorker = reg.installing;
      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
          // New version available
          if (confirm('New version available. Reload?')) {
            window.location.reload();
          }
        }
      });
    });
  });
}
```

---

### Issue: Install prompt not showing

**Symptoms:** `beforeinstallprompt` never fires.

**Common causes:**
- App is already installed
- Not served over HTTPS
- Manifest missing required fields (`short_name`, `icons`, `start_url`, `display`)
- User previously dismissed install prompt (Chrome remembers)

**Solution:**
```json
// manifest.json must have:
{
  "short_name": "MiApp",
  "name": "Mi App",
  "icons": [
    { "src": "/icon-192.png", "sizes": "192x192" },
    { "src": "/icon-512.png", "sizes": "512x512" }
  ],
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000"
}
```

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "PWA is just a website with a manifest." | A real PWA is offline-first, installable, and responsive. A manifest alone is decoration. |
| "I'll add offline support later." | Offline-first must be designed from the start. Retrofitting is 3x harder. |
| "My users only use iPhone." | iPhone users rotate to landscape. And they use iPad. Design for all. |
| "Container queries are too new." | Supported everywhere since 2023. They're the right tool for component layouts. |
| "100vh works fine on my laptop." | It breaks on mobile Safari, Android Chrome, and any browser with dynamic UI chrome. |
| "I'll use media queries for everything." | Media queries are screen-based. Container queries are component-based. Use both. |

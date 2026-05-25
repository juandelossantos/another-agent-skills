# PWA Architecture Guide

PWA technical implementation for `frontend-pwa`.

## Service Worker

- Use Workbox or `next-pwa` to auto-generate.
- Cache strategy: `CacheFirst` for static, `NetworkFirst` for API.
- Background sync for offline mutations.

## Web App Manifest

```json
{
  "name": "App Name",
  "short_name": "AppName",
  "start_url": "/",
  "display": "standalone",
  "orientation": "portrait",
  "theme_color": "#0A0A0F",
  "background_color": "#0A0A0F",
  "icons": [...]
}
```

## Offline Pages

- Always have fallback offline page.
- Show stale data with "syncing..." indicator.

## Migration Path to Native (Optional)

If future App Store / Google Play:

1. **Now:** Build PWA with offline support. Use Capacitor plugins.
2. **Later:**
   ```bash
   npm install @capacitor/core @capacitor/cli
   npx cap init
   npx cap add ios && npx cap add android
   npx cap sync
   ```
3. **Runtime detection:**
   ```typescript
   import { Capacitor } from '@capacitor/core';
   const isNative = Capacitor.isNativePlatform();
   // Native: Capacitor plugins. Web: Web APIs.
   ```

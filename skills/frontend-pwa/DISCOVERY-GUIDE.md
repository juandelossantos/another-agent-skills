# PWA Discovery Guide

This guide contains the complete Phase 1 Discovery Gate for `frontend-pwa`.

## Purpose

Before writing any PWA code, understand the user's device targets, offline needs, and native migration path. A PWA built for "just mobile" is very different from one built for "mobile + tablet + TV + desktop touch".

---

## Universal Discovery (Ask Every Project)

### 1. Audience
Who will use this app?
- **Internal team** → Focus on function, offline critical
- **Public consumers** → High polish, installable, onboarding
- **Enterprise/B2B** → Compliance, offline sync, admin

### 2. Purpose
What must the app DO in one sentence?
- "Track inventory offline and sync when online" → Offline-first data app
- "Booking appointments with notifications" → Installable + push
- "Content reader" → Cache articles, read offline

### 3. Scope
- **MVP (1-3 screens)** → Turbo mode possible
- **Standard (4-10 screens)** → Full discovery
- **Complex (10+ screens, sync, auth)** → Extended discovery

### 4. Context
- **New app** → Design from scratch
- **Existing website** → Audit first, then PWA-ify
- **Migration from native app** → Reverse-engineer features

---

## PWA-Specific Discovery

### 5. Offline Strategy
- **Fully offline** → Works with no connection (e.g., note taking, calculator)
- **Cached content** → Shows cached data, limited functionality offline
- **Online-only** → Graceful degradation, offline page only
- **Background sync** → Queue mutations, sync when online

### 6. Installable
- **Homescreen only** → Users add via browser menu
- **Prompt-driven** → Custom install button, guided install flow
- **App Store** → Will use Capacitor/Ionic to wrap later
- **Not installable** → Standard website (use `frontend-web` instead)

### 7. Device Targets
- **Phone only** → 375px-428px primary
- **Phone + Tablet** → Include 768px-1366px
- **All devices** → Add desktop (1280px+) and TV (1920px+)
- **Foldable** → Special handling for 280px-717px transitions

### 8. Input Methods
- **Touch primary** → No hover-dependent features
- **Mouse + Touch** → Both supported equally
- **Keyboard** → Accessibility, power users
- **Remote / Gamepad** → TV apps only

### 9. Native Features Needed
- **Push notifications** → Requires service worker + permission strategy
- **Camera** → Web APIs or Capacitor plugin
- **GPS** → Geolocation API or Capacitor
- **Biometric auth** → WebAuthn or Capacitor
- **Background sync** → Periodic sync API or Capacitor
- **File system** → File System Access API or Capacitor

### 10. Migration to Native
- **No plans** → Pure PWA, no Capacitor needed
- **Future possibility** → Design with Capacitor in mind
- **Immediate need** → Capacitor setup from day one

---

## Visual Direction (3 Questions)

### 11. References
"Show me 2-3 apps you love." (Screenshots or descriptions)

### 12. Mood
Pick 3 adjectives.

### 13. Brand Constraints
- Existing brand colors/fonts?
- Must match existing website?
- Logo/assets available?

---

## Confirmation Gate

```
DISCOVERY SUMMARY:
- Audience: [who]
- Purpose: [what it does]
- Offline: [fully offline / cached / online-only]
- Installable: [homescreen / prompt / app store / no]
- Devices: [phone / tablet / desktop / TV / foldable]
- Input: [touch / mouse / keyboard]
- Native features: [list]
- Migration: [none / future / immediate]
- Visual: [mood + references]

→ Is this correct? Shall we proceed to contracts (SPEC.md + DESIGN.md)?
```

**Do NOT proceed to Phase 2 until user confirms.**

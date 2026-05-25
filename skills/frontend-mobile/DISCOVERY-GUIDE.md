# Mobile Discovery Guide

This guide contains the complete Phase 1 Discovery Gate for `frontend-mobile`.

## Purpose

Before writing any mobile code, surface assumptions and gather context. This prevents the #1 mobile failure: building for the wrong platform, with the wrong features, for the wrong users.

---

## Universal Discovery (Ask Every Project)

### 1. Audience
Who will use this app?
- **Internal team** → Focus on function, less polish
- **Public consumers** → High polish, onboarding flows, crash-proof
- **Enterprise/B2B** → Compliance, admin features, support
- **Specific demographic** → Age, tech-savviness, accessibility needs

### 2. Purpose
What must the app DO in one sentence?
- "Book appointments" → Scheduling app
- "Track workouts" → Fitness tracker
- "Manage inventory" → B2B tool
- **Vague answers** → Drill down: "What problem does this solve?"

### 3. Scope
How many screens/features?
- **MVP (1-3 screens)** → Turbo mode possible
- **Standard (4-10 screens)** → Full discovery required
- **Complex (10+ screens, backend, auth)** → Extended discovery + architecture analysis

### 4. Context
- **New app** → Design from scratch
- **Existing app** → Audit first (`project-health-check`)
- **Redesign** → What stays, what changes, why now?

### 5. Platform
- **iOS only** → Follow Human Interface Guidelines strictly
- **Android only** → Follow Material Design 3 strictly
- **Both (iOS + Android)** → Cross-platform framework (React Native/Flutter) or native per platform

---

## Extended Discovery (Non-Trivial Projects)

### 6. Data & State
- What data must the app store locally?
- What needs to sync with a backend?
- Offline requirements?

### 7. Native Features
- Camera/Photos?
- GPS/Location?
- Push notifications?
- Biometric auth (Face ID/Touch ID)?
- Contacts/Calendar integration?
- Bluetooth/NFC?

### 8. Security & Compliance
- User authentication required?
- Data encryption (local or in transit)?
- Regulatory compliance (GDPR, HIPAA, SOC2)?

### 9. Navigation Pattern
- **Tabs** → Instagram-style bottom navigation
- **Stack** → Deep hierarchies (Settings → Account → Password)
- **Drawer** → Gmail-style hamburger menu
- **Custom** → Unique flows (onboarding wizard, game levels)

### 10. App Store Presence
- **Public App Store** → Review guidelines compliance, age ratings
- **Enterprise/Internal** → MDM distribution, no store required
- **TestFlight/Internal Testing** → Beta distribution only

---

## Visual Direction (3 Questions)

### 11. References
"Show me 2-3 apps you love the look of." (Screenshots, App Store links, or descriptions)

### 12. Mood
Pick 3 adjectives: playful, serious, luxury, friendly, technical, organic, futuristic, nostalgic...

### 13. Brand Constraints
- Existing brand colors/fonts?
- Must match website/web app?
- Logo/assets available?

---

## Mobile-Specific Questions

### 14. Platform Versions
- iOS minimum version? (e.g., iOS 15+)
- Android minimum SDK? (e.g., API 26+)

### 15. Device Considerations
- Tablets supported?
- Foldable devices?
- Orientation (portrait only, or landscape too)?

### 16. Performance Expectations
- Launch time target?
- App size budget?
- Animation smoothness (60fps mandatory)?

---

## Confirmation Gate

Before proceeding, summarize:

```
DISCOVERY SUMMARY:
- Audience: [who]
- Purpose: [what it does]
- Scope: [MVP/Standard/Complex]
- Platform: [iOS/Android/Both]
- Navigation: [Tabs/Stack/Drawer/Custom]
- Native features: [list]
- Visual direction: [mood + references]

→ Is this correct? Shall we proceed to contracts (SPEC.md + DESIGN.md)?
```

**Do NOT proceed to Phase 2 until user confirms.**

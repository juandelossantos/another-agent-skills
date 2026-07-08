---
name: frontend-mobile
description: "Build production-grade mobile apps with native design tokens and platform compliance. Triggers: mobile app, React Native, Flutter, iOS, Android. Do NOT use for web-only projects."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: mobile-developers
  stack: react-native-expo-flutter
  workflow: design-driven-build
  foundation: engineering-fundamentals
---

# Frontend Mobile

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
mobile-specific implementation.

## When to Use

Build, design, or redesign any **mobile app interface**.

Do NOT use for:
- Web-only tasks (use `frontend-web`)
- Installable web apps (use `frontend-pwa`)
- Backend-only tasks

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
- **Missing** → Default to React Native 0.76+ + Expo SDK 52+.

**Adaptation examples:**
- React Native → Flutter: Widgets instead of components. `StyleSheet` → `ThemeData`. JSX → Dart.
- React Native → SwiftUI: `.swift` files. `@State` instead of `useState`.
- React Native → Jetpack Compose: `@Composable` functions. Kotlin syntax.

---

## Core Process

### Phase 0 — Language Detection
→ See `engineering-fundamentals` Phase 0.

---

### Phase 1 — Discovery Gate
→ See `engineering-fundamentals` Phase 1 for universal discovery.

**Mobile-specific questions:**
1. **Platforms**: iOS only, Android only, or both?
2. **Navigation**: Tabs, stack, drawer, or custom?
3. **Offline**: Does the app work without internet?
4. **Push notifications**: Needed?
5. **Native features**: Camera, GPS, biometric auth, contacts?
6. **App Store**: Public store, enterprise, or internal distribution?

Read `guides/DISCOVERY-GUIDE.md` for complete mobile checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Mobile-specific additions:**
- SPEC.md must include: Platform targets (iOS min version, Android min SDK), App Store requirements.

---

### Phase 3 — Three Dials System

→ See `engineering-fundamentals/guides/DESIGN-CORE.md` for the universal Three Dials System (VARIANCE, MOTION, DENSITY), vibe→dial inference, color principles, and dark mode protocol.

Apply dials to mobile constraints: Reanimated for MOTION > 4, SafeArea-aware layouts for VARIANCE > 4, platform-native touch targets for DENSITY.

---

### Phase 4 — Stack Lock-in

| Tool | Minimum | Notes |
|---|---|---|
| React Native | 0.76+ | New Architecture (Fabric) enabled |
| Expo SDK | 52+ | EAS Build, Expo Router |
| TypeScript | 5.7+ | |
| React Navigation | 7+ | If not using Expo Router |
| Reanimated | 3.16+ | Primary animation engine |
| React Native Gesture Handler | 2.20+ | Gestures |
| lucide-react-native | latest | Icons |

Optional: `expo-camera`, `expo-location`, `@shopify/flash-list`.

Forbidden: `Animated` API (use Reanimated), inline styles, `any` type.

---

### Phase 5 — Anti-Slop Rules (Mobile)

→ See `engineering-fundamentals/guides/ANTI-SLOP-CORE.md` for universal AI tells, content density, copy protocol, and UI state requirements.

**Mobile-specific rules:**

**Typography**
- No system default fonts as display (San Francisco, Roboto).
- Pair distinctive display + refined body font.
- Use `expo-font` with `useFonts` hook.

**Color**
- No system default colors (`systemBlue`, `systemGray`).
- Use theme tokens from `DESIGN.md` or theme provider.

**Layout**
- No web patterns in mobile (hover states, tooltips on touch).
- Use platform conventions: iOS HIG, Android Material Design 3.
- Think in screens, not pages. Mobile-first: verify 375pt (iPhone SE).
- Respect SafeAreaView and avoid the notch/status bar.

**Motion**
- No animation of `width`, `height`, `top`, `left`, `margin`, `padding`.
- Only `transform` and `opacity` for 60fps.

**Native Feel**
- No default flat solid colors.
- Touch targets minimum 44pt (iOS) or 48dp (Android).

---

### Phase 6 — Animation System

Read `guides/ANIMATION-GUIDE.md`.

**Summary:**
- **Primary:** Reanimated `useAnimatedStyle` + `withSpring`.
- **Fallback:** React Native `Animated` API for simple cases.
- **Gestures:** React Native Gesture Handler for swipe, pinch, long-press.
- **Accessibility:** Every animation MUST respect `AccessibilityInfo` reduced motion.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 7 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography.
2. **Check `design/approved/`** — Screenshots, previews, moodboards.
3. **Cross-check with `DESIGN.md`** — Tokens must match locked system.

**Then build:**

4. Apply tokens to a theme provider (e.g., `ThemeProvider` or `StyleSheet.create` constants).
5. Use `expo-font` for fonts in the root component.
6. Build screens with canonical order:
   - Splash / Onboarding
   - Authentication (if needed)
   - Main App Shell (tabs, drawer, or stack)
   - Home / Dashboard
   - Feature Screens
   - Profile / Settings
7. Use Reanimated `useAnimatedStyle` for entrance animations.
8. Use `<Image>` from `expo-image` with `contentFit` and `accessibilityLabel`.
9. Ensure `SafeAreaView` wraps every screen.

---

### Phase 8 — QA Gates

→ See `engineering-fundamentals` Phase 5 for universal gates. Read `engineering-fundamentals/guides/PRE-FLIGHT-CORE.md` for universal checks first.

**After QA gates, log metrics:**
```
LOG METRIC: gate
- project: [detect from git remote or directory]
- gate_name: frontend-mobile-qa
- result: pass/fail
- checks_passed: [N]/12
```

**Mobile-specific checks:**

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `eas build --local` or `npx expo prebuild` succeeds.
3. **No template residue** — Remove default Expo text and assets.
4. **No hardcoded colors** — Search `color: '#`, replace with tokens.
5. **Responsive** — Check 375pt, 428pt, tablet sizes.
6. **Accessibility** — Contrast 4.5:1, `accessibilityLabel`, `AccessibilityInfo`.
7. **Images** — Every `<Image>` has `accessibilityLabel`. Cache policy configured.
8. **Reduced motion** — Respect `AccessibilityInfo.isReduceMotionEnabled()`.
9. **Animation performance** — Only `transform` and `opacity`. No layout thrashing.
10. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read.
11. **Visual consistency** — No color, font, or spacing deviates without approval.
12. **Platform compliance** — Follows iOS HIG and Android Material 3.

---

## Examples & Troubleshooting

Read `guides/EXAMPLES.md`:
- New mobile app walkthrough (15 steps)
- Adding animation to existing component
- Troubleshooting (Expo prebuild, fonts, SafeArea, gesture conflicts)

---

## Red Flags (Mobile-Specific)

- System default colors or generic palettes used.
- Display font is San Francisco, Roboto, or system default.
- Generic centered card grid with no native consideration.
- Animations use `width`, `height`, or `margin` transitions.
- No `AccessibilityInfo` reduced-motion check.
- Web patterns (hover, tooltips) suggested in a mobile app.
- Code generated before DESIGN.md confirmed or PLAN created.

---

## Verification

- `DESIGN.md` exists in project root.
- `design/DESIGN-LOCK.md` exists with approved decisions.
- Theme provider or `StyleSheet.create` contains tokens.
- `accessibilityLabel` on every interactive element.
- `AccessibilityInfo` reduced-motion check exists.
- Build passes (`eas build` or `expo prebuild`).
- No generic system color utilities.
- Animation code only touches `transform` and `opacity`.

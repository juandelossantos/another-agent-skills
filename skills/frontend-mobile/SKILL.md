---
name: frontend-mobile
description: >
  Build production-grade mobile apps with native design tokens and platform compliance.
  Built on engineering-fundamentals. Use when creating or modifying mobile apps,
  React Native/Flutter components, or when the user asks for mobile design, styling,
  animation, or frontend implementation. Triggers on: "mobile app", "app móvil",
  "React Native", "Flutter", "iOS", "Android", "expo", "native app".
license: MIT
compatibility: opencode
metadata:
  audience: mobile-developers
  stack: react-native-expo-flutter
  workflow: design-driven-build
  foundation: engineering-fundamentals
---

# Frontend Mobile

**Built on `engineering-fundamentals`.** Read that skill first. This document adds
mobile-specific implementation to the universal philosophy.

## When to Use

Use when the user asks to build, design, or redesign any **mobile app interface**:
- React Native, Flutter, Expo, iOS, Android
- Mobile components, styling, layout, visual polish
- Animations, transitions, gesture effects, micro-interactions

Do NOT use for:
- Web-only tasks (use `frontend-web`)
- Installable web apps (use `frontend-pwa`)
- Backend-only tasks

### Stack Detection

Before applying instructions, check for `STACK_CONFIG.md`.

**If exists:** Adapt to chosen stack.
**If missing:** Default to React Native 0.76+ + Expo SDK 52+.

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
→ See `engineering-fundamentals` Phase 1 for the universal discovery process.

**Mobile-specific questions (add to universal):**
1. **Platforms**: iOS only, Android only, or both?
2. **Navigation**: Tabs, stack, drawer, or custom?
3. **Offline**: Does the app work without internet?
4. **Push notifications**: Needed?
5. **Native features**: Camera, GPS, biometric auth, contacts?
6. **App Store**: Public store, enterprise, or internal distribution?

Read `DISCOVERY-GUIDE.md` in this skill directory for the complete mobile checklist.

---

### Phase 2 — Write Contracts
→ See `engineering-fundamentals` Phase 2.

**Mobile-specific contract additions:**
- SPEC.md must include: Platform targets (iOS min version, Android min SDK), App Store requirements.

---

### Phase 3 — Aesthetic Direction
→ See `engineering-fundamentals` Phase 3.

Same 8 directions (ED, SM, LDW, CB, UE, NB, PG, RT). Pick ONE.

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

→ See `engineering-fundamentals` Phase 4 for universal principles.

**Mobile-specific rules:**

**Typography**
- NEVER use system default fonts as display fonts (San Francisco, Roboto).
- ALWAYS pair a distinctive display font with a refined body font.
- Use `expo-font` with `useFonts` hook.

**Color**
- NEVER use system default colors (`systemBlue`, `systemGray`).
- ALWAYS use theme tokens from `DESIGN.md` or theme provider.

**Layout**
- NEVER use web patterns in mobile (hover states, tooltips on touch).
- ALWAYS use platform conventions: iOS HIG, Android Material Design 3.
- Think in screens, not pages. Mobile-first: verify 375pt (iPhone SE).
- Respect SafeAreaView and avoid the notch/status bar.

**Motion**
- NEVER animate `width`, `height`, `top`, `left`, `margin`, or `padding`.
- ALWAYS animate `transform` and `opacity` only for 60fps.

**Native Feel**
- NEVER default to flat solid colors.
- Touch targets minimum 44pt (iOS) or 48dp (Android).

---

### Phase 6 — Animation System

Read `ANIMATION-GUIDE.md` in this skill directory.

**Summary:**
- **Primary pattern:** Reanimated `useAnimatedStyle` + `withSpring`.
- **Fallback:** React Native `Animated` API for simple cases.
- **Gestures:** React Native Gesture Handler for swipe, pinch, long-press.
- **Accessibility:** Every animation MUST respect `AccessibilityInfo` reduced motion.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 7 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography.
2. **Check `design/approved/`** — Screenshots, previews, moodboards.
3. **Cross-check with `DESIGN.md`** — Tokens must match the locked system.

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

→ See `engineering-fundamentals` Phase 5 for universal gates.

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

Read `EXAMPLES.md` in this skill directory:
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

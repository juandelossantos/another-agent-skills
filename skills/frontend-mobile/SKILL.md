---
name: frontend-mobile
description: >
  Build production-grade mobile interfaces with intentional visual design,
  high-performance animations, and native discipline. Use when creating or
  modifying mobile apps, React Native/Flutter components, or when the user asks
  for mobile design, styling, animation, or frontend implementation. Triggers on:
  "mobile app", "app móvil", "React Native", "Flutter", "iOS app", "Android app",
  "native app", "expo", "mobile UI", "mobile frontend", or any visual mobile task.
license: MIT
compatibility: opencode
metadata:
  audience: mobile-developers
  stack: react-native-expo-flutter
  workflow: design-driven-build
---

# Frontend Mobile

Build mobile interfaces that feel **intentionally designed**, not AI-generated.
This skill enforces a visual contract (`DESIGN.md`), anti-slop rules, native
animation patterns, and a locked stack for consistency.

## When to Use

Use this skill when:
- The user asks to build, design, or redesign any mobile app interface
- The task involves mobile components, styling, layout, or visual polish
- Animations, transitions, gesture effects, or micro-interactions are requested
- The output risks looking generic (default components, system colors, flat designs)
- The user mentions React Native, Flutter, Expo, iOS, or Android

Do NOT use for:
- Web-only tasks (landing pages, web dashboards, browser-based apps)
- Backend-only tasks (APIs, DB schema, infrastructure)
- Desktop applications (use `frontend-desktop`)
- CLI or non-visual software

### Stack Detection (NEW)

Before applying any stack-specific instruction, check for `STACK_CONFIG.md` in the project root.

**If `STACK_CONFIG.md` exists:**
- Read it. Adapt all code examples, file paths, and tooling to the chosen stack.
- Principles (anti-slop, tokens, animation) remain the same.
- Examples below assume React Native (Expo), but you MUST translate to the user's stack.

**If no `STACK_CONFIG.md` exists:**
- Default to React Native 0.76+ + Expo SDK 52+ (as documented below).
- Ask the user: "¿Quieres usar React Native/Expo (default) o prefieres Flutter, SwiftUI, o Jetpack Compose?"

**Adaptation examples:**
- React Native → Flutter: Widgets instead of components. `StyleSheet` → `ThemeData`. JSX → Dart.
- React Native → SwiftUI: `.swift` files. `@State` instead of `useState`. Swift syntax.
- React Native → Jetpack Compose: `@Composable` functions. Kotlin syntax. Material Design 3.

---

## Core Process

### Phase 0 — Language Detection

Detect the language of the user's request immediately. All subsequent communication MUST be in that same language.

**Detection rules:**
- Spanish keywords (*"haz"*, *"diseña"*, *"crea"*, *"desarrolla"*) → **Spanish**.
- English keywords (*"build"*, *"design"*, *"create"*, *"make"*) → **English**.
- Other languages → Respond in that language, fallback to English if uncertain.

**Never mix languages.** All questions, specs, and code comments must match the detected language.

---

### Phase 1 — Discovery Gate (MANDATORY)

**NO CODE IS WRITTEN UNTIL THIS PHASE IS COMPLETE.**

Read `DISCOVERY-GUIDE.md` in this skill directory for the complete checklist.

**Summary:** Surface assumptions, ask minimum 5 discovery questions (audience, purpose, scope, context, stack), extend to 10 for non-trivial projects (data, security, offline, push notifications, deep linking), plus 3 visual direction questions (references, mood, brand). Confirm with user before proceeding.

**Mobile-specific discovery questions (in addition to universal):**
1. **Platforms**: iOS only, Android only, or both?
2. **Navigation**: Tabs, stack, drawer, or custom?
3. **Offline**: Does the app work without internet?
4. **Push notifications**: Needed?
5. **Native features**: Camera, GPS, biometric auth, contacts?
6. **App Store presence**: Public store, enterprise, or internal distribution?

---

### Phase 2 — Write Contracts

#### 2A: SPEC.md

If there is **no `SPEC.md`** and this is a **new feature or screen** (not a one-off component tweak), invoke `spec-driven-development` to write one.

The SPEC.md **must** include: Objective, Scope, Tech stack (locked versions), Project structure, Acceptance criteria, Boundaries, Platform targets (iOS min version, Android min SDK).

#### 2B: DESIGN.md (VISUAL ONLY — No Architecture)

Check for `DESIGN.md` in the project root.

**CRITICAL RULE:** `DESIGN.md` is for **visual identity and design tokens ONLY**. Never architecture, folder structure, navigation logic, state management, or API routes. Those belong in `SPEC.md`.

**What goes in:** Colors, Typography, Spacing, Border radius, Elevation/shadows, Motion tokens, Component visual tokens, Visual Do's and Don'ts.

**What NEVER goes in:** Tech versions, folder structure, navigation config, state management, auth, API routes, platform-specific code.

**Paths:**
- **Path A** — DESIGN.md exists: Read it, extract tokens, build strictly within them.
- **Path B** — No DESIGN.md, user wants visual system: Use Phase 1 answers to pick 1 of 8 directions below. Generate DESIGN.md with visual tokens only. Present for confirmation.
- **Path C** — No DESIGN.md, one-off task: Do the task. Mention once that a DESIGN.md improves consistency.

**AFTER DESIGN.md IS CONFIRMED — MANDATORY STOP:**

Do NOT write code yet. You have completed DEFINE, not BUILD.

1. Check if a `SPEC.md` exists. If not, invoke `spec-driven-development` to create one.
2. Invoke `planning-and-task-breakdown` to produce a concrete implementation plan.
3. Only after the plan exists and is confirmed, proceed to Phase 3 (Stack) and Phase 6 (Build).

#### 2D: Design Asset Lock (MANDATORY after visual approval)

Create a `design/` directory in the project root:

```
design/
├── DESIGN-LOCK.md          # Snapshot of all approved visual decisions
└── approved/
    ├── preview-final.png   # Approved preview (from simulator/device)
    ├── palette.png         # Approved palette screenshot
    ├── typography.png      # Approved font screenshot
    └── moodboard/            # Reference images
```

`DESIGN-LOCK.md` must contain: Direction (aesthetic ID + mood), Final Palette (all colors with HEX + usage), Final Typography (display + body fonts + scale), Key Decisions (every explicit user decision), References (links to approved assets).

**Rules:**
- DESIGN-LOCK.md is a SNAPSHOT. It never changes after approval unless the user explicitly requests a redesign.
- All screenshots, previews, and references from Phase 1/2 MUST be copied into `design/approved/`.
- During BUILD (Phase 6), you MUST read `design/DESIGN-LOCK.md` before writing any component. Do not rely on memory.

#### 2C: Lifecycle Awareness

Respect `AGENTS.md` lifecycle mapping:
- DEFINE → `spec-driven-development`
- PLAN → `planning-and-task-breakdown`
- BUILD → This skill + `incremental-implementation`
- VERIFY → `debugging-and-error-recovery`
- REVIEW → `code-review-and-quality`
- SHIP → `shipping-and-launch` (App Store / Google Play submission)

### Phase 2 — Choose Aesthetic Direction (Path B only)

Pick ONE direction. Do not blend.

| ID | Direction | Best For |
|---|---|---|
| ED | Editorial Serif | Media, personal brand, luxury |
| SM | Swiss Minimal | SaaS B2B, devtools, fintech |
| LDW | Luxury Dark Warm | Hospitality, jewelry, fashion |
| CB | Corporate Bold | Enterprise, education, legal |
| UE | Understated Elegance | Lifestyle, wellness, portfolio |
| NB | Neo-Brutalist | Startups, creative communities |
| PG | Playful Gradient | Consumer apps, edtech |
| RT | Retro Terminal | DevTools, technical docs |

---

### Phase 3 — Stack Lock-in (Non-Negotiable)

| Tool | Minimum | Notes |
|---|---|---|
| React Native | 0.76+ | New Architecture (Fabric) enabled |
| Expo SDK | 52+ | EAS Build, Expo Router, native modules |
| TypeScript | 5.7+ | |
| React Navigation | 7+ | If not using Expo Router |
| Reanimated | 3.16+ | Primary animation engine |
| React Native Gesture Handler | 2.20+ | Gestures |
| lucide-react-native | latest | Icons |

Optional add-ons (only if requested): `react-native-maps`, `expo-camera`, `expo-location`, `react-native-restart`, `@shopify/flash-list`.

Forbidden defaults: `Animated` API (use Reanimated instead), inline styles, `any` type, non-expo managed workflow unless requested.

---

### Phase 4 — Anti-AI-Slop Rules

Non-negotiable rules to prevent the generic "AI app look."

**Typography**
- NEVER use system default fonts as display fonts (San Francisco, Roboto, Inter).
- ALWAYS pair a distinctive display font with a refined body font.
- Use `expo-font` with `useFonts` hook and CSS variables or theme tokens.

**Color**
- NEVER use system default colors (`systemBlue`, `systemGray`, generic palettes).
- ALWAYS use theme tokens from `DESIGN.md` or theme provider.
- Commit to a dominant color with sharp accents. Timid palettes are forbidden.

**Layout**
- NEVER use generic centered card grids as the default.
- ALWAYS consider asymmetry, overlap, scrollable density, or native patterns.
- Think in screens, not pages. Mobile-first: verify 375px (iPhone SE) before 428px (iPhone Pro Max).
- Respect SafeAreaView and avoid the notch/status bar.

**Motion**
- NEVER animate `width`, `height`, `top`, `left`, `margin`, or `padding`.
- ALWAYS animate `transform` and `opacity` only for 60fps.
- Use `will-change` sparingly and remove after animation.

**Native Feel**
- NEVER use web patterns in mobile (hover states, tooltips on touch).
- ALWAYS use platform conventions: iOS Human Interface Guidelines, Android Material Design 3.
- Touch targets minimum 44pt (iOS) or 48dp (Android).

**Backgrounds**
- NEVER default to flat solid colors.
- ALWAYS consider: gradient meshes, subtle noise textures, geometric patterns, layered transparencies.

---

### Phase 5 — Animation System

Read `ANIMATION-GUIDE.md` in this skill directory for complete implementation details.

**Summary:**
- **Primary pattern:** Reanimated `useAnimatedStyle` + `withSpring`.
- **Fallback patterns:** React Native `Animated` API for simple cases.
- **Gestures:** React Native Gesture Handler for swipe, pinch, long-press.
- **Accessibility:** Every animation MUST respect `AccessibilityInfo` reduced motion.
- **Performance:** Only `transform` and `opacity` may be animated.

---

### Phase 6 — Build with Tokens

**BEFORE WRITING CODE:**

1. **Read `design/DESIGN-LOCK.md`** — Verify approved direction, palette, typography, key decisions.
2. **Check `design/approved/`** — Screenshots, previews, moodboards are ground truth.
3. **Cross-check with `DESIGN.md`** — Tokens in code must match the locked visual system.

**Then build:**

4. Apply tokens from `DESIGN.md` to a theme provider (e.g., `ThemeProvider` or `StyleSheet.create` constants).
5. Use `expo-font` for fonts in the root component.
6. Build screens with canonical order:
   - Splash / Onboarding
   - Authentication (if needed)
   - Main App Shell (tabs, drawer, or stack)
   - Home / Dashboard
   - Feature Screens
   - Profile / Settings
7. Use Reanimated `useAnimatedStyle` for entrance animations.
8. Use `<Image>` from `expo-image` with `contentFit` and descriptive `alt` / `accessibilityLabel`.
9. Ensure `SafeAreaView` wraps every screen.

---

### Phase 7 — QA Gates

Before declaring complete, verify:

1. **TypeScript** — `npx tsc --noEmit` passes.
2. **Build** — `eas build --local` or `npx expo prebuild` succeeds.
3. **No template residue** — Remove default Expo text and assets.
4. **No hardcoded colors** — Search `color: '#`, `backgroundColor: '#`. Replace with tokens.
5. **Responsive** — Check 375pt, 428pt, tablet sizes.
6. **Accessibility** — Contrast 4.5:1, focus indicators, `accessibilityLabel`, `AccessibilityInfo`.
7. **Images** — Every `<Image>` has `accessibilityLabel`. Cache policy configured.
8. **Reduced motion** — Respect `AccessibilityInfo.isReduceMotionEnabled()`.
9. **Animation performance** — Only `transform` and `opacity`. No layout thrashing.
10. **Design Lock present** — `design/DESIGN-LOCK.md` exists and was read before coding.
11. **Visual consistency** — No color, font, or spacing deviates from `DESIGN.md` without explicit user approval.
12. **Platform compliance** — Follows iOS HIG and Android Material 3 where applicable.

---

## Examples & Troubleshooting

Read `EXAMPLES.md` in this skill directory for:
- Detailed walkthrough of a new mobile app (15 steps)
- Adding animation to an existing component
- Troubleshooting table (Expo prebuild, fonts, SafeArea, gesture conflicts, build issues)

---

## Common Rationalizations

| Excuse | Why It's Wrong |
|---|---|
| "I'll just use the default system colors for now." | Hardcoded system colors violate the token system and create inconsistency. |
| "System fonts are a safe choice." | System fonts are the #1 sign of AI-generated UI. Use a distinctive font. |
| "This is too small for a DESIGN.md." | Even one-off tasks benefit from 3 lines of tokens. It prevents slop. |
| "I'll add accessibility later." | Accessibility is not a stretch goal. It's a gate. Add it now. |
| "I'll use React Native Animated API." | Reanimated is smoother and more performant. Use it first. |
| "The user didn't ask for animations." | Subtle entrance animations are standard for production-grade UI. Default to them. |
| "I'll animate width/height for this effect." | That drops frames. Use `scale` or `opacity` instead. |
| "This looks fine on my screen." | Check 375pt. iPhone SE is the rule, not the exception. |
| "The user is eager, I'll start coding now that DESIGN.md is approved." | DESIGN.md approval completes DEFINE, not BUILD. You MUST plan first. |
| "I remember the design, I don't need to look at the files again." | Agent context can drift or reset. The `design/DESIGN-LOCK.md` is the ground truth. |

---

## Red Flags

Watch for these signals that the skill is being violated:
- The output uses system default colors or generic palettes.
- The display font is San Francisco, Roboto, or system default.
- The layout is a generic centered card grid with no native consideration.
- Animations use `width`, `height`, or `margin` transitions.
- There is no `AccessibilityInfo` reduced-motion check.
- The agent generates code before confirming or creating a `DESIGN.md` (Path B).
- The agent writes code immediately after `DESIGN.md` is approved without creating a PLAN.
- The agent does not read `design/DESIGN-LOCK.md` before writing code.
- The agent suggests web patterns (hover, tooltips) in a mobile app.

---

## Verification

Evidence that this skill was followed:
- `DESIGN.md` exists in the project root (for Path A and B).
- `design/DESIGN-LOCK.md` exists and contains approved direction, palette, typography, and key decisions.
- `design/approved/` contains any previews, screenshots, or moodboards.
- Theme provider or `StyleSheet.create` contains tokens, not hardcoded hex values in components.
- `accessibilityLabel` is present on every interactive element.
- `AccessibilityInfo` reduced-motion check exists.
- Build passes (`eas build` or `expo prebuild`).
- No generic system color utilities in the final code.
- Animation code only touches `transform` and `opacity`.

# Web-Centrism Audit: another-agent-skills

**Date:** 2026-05-24
**Auditor:** another-agent-skills self-audit
**Scope:** All 9 custom skills
**Objective:** Identify web-specific assumptions that prevent the ecosystem from serving mobile, desktop, CLI, IoT, and other platforms.

---

## Executive Summary

| Skill | Web-Centrism Level | Universal % | Web-Specific % | Critical Issues |
|---|---|---|---|---|
| `visual-frontend-mastery` | 🔴 **EXTREME** | ~20% | ~80% | Stack lock-in, file paths, components, QA gates |
| `backend-api-mastery` | 🟡 **MODERATE** | ~70% | ~30% | Default stack, auth examples, consumer assumptions |
| `git-init-and-versioning` | 🟢 **LOW** | ~85% | ~15% | "Frontend-only" framing, web project structure examples |
| `fullstack-shipping` | 🟠 **HIGH** | ~40% | ~60% | Deployment targets, CI/CD examples, testing strategy |
| `spec-driven-development` | 🟢 **LOW** | ~90% | ~10% | Phase 0 checks `package.json` first |
| `project-health-check` | 🟠 **HIGH** | ~50% | ~50% | Version checks, Tailwind generics, web structure |
| `architecture-analysis` | 🟢 **LOW** | ~95% | ~5% | Almost framework-agnostic |
| `dev-environment-audit` | 🟡 **MODERATE** | ~75% | ~25% | Web deployment targets, web testing tools |
| `user-onboarding` | 🟢 **LOW** | ~95% | ~5% | "Frontend framework" question assumes web |

**Overall ecosystem web-centrism: ~55%** — The ecosystem is web-first, not web-capable.

---

## Detailed Findings by Skill

### 1. `visual-frontend-mastery` — EXTREME Web-Centrism

#### What's Universal (Principles)
- Visual identity and design tokens (colors, typography, spacing)
- Anti-AI-slop philosophy (avoid generic, be intentional)
- Animation principles (transform/opacity only, 60fps)
- Accessibility (contrast, focus, reduced motion)
- Design Asset Lock (snapshot approved decisions)
- Discovery Gate (ask before building)

#### What's Web-Specific (Examples/Implementation)
- **Stack lock-in:** Next.js 16, React 19, Tailwind v4, shadcn/ui, Framer Motion
- **File paths:** `src/app/globals.css`, `layout.tsx`, `next/font/google`
- **Components:** "Navbar", "Hero", "Value proposition", "Testimonials", "Footer" — these are WEB page sections
- **Animation engine:** Framer Motion `whileInView` — web-specific
- **Image component:** `<Image>` from Next.js — web-specific
- **Build QA:** `npm run build`, `tsc --noEmit` — web build tools
- **SEO:** `sitemap.ts`, `robots.ts`, `llms.txt` — web-specific
- **Responsive:** "Check 375px, 768px, 1280px" — web breakpoints, not native mobile
- **Font loading:** `next/font/google` with CSS variables — Next.js specific

#### Impact
If a user says "quiero una app móvil", this skill will:
1. Propose Next.js (wrong — needs React Native or Flutter)
2. Suggest `src/app/globals.css` (wrong — mobile uses StyleSheet or native theming)
3. Recommend Framer Motion (wrong — mobile uses Reanimated or native animations)
4. Talk about "Hero sections" and "Footers" (wrong — mobile uses screens, tabs, navigation)
5. QA with `npm run build` (wrong — mobile needs `expo build` or Xcode/Android Studio)

---

### 2. `backend-api-mastery` — MODERATE Web-Centrism

#### What's Universal
- Protocol decisions (REST vs GraphQL vs gRPC) — framework-agnostic
- Database design principles (relational vs document vs time-series)
- Auth patterns (JWT, sessions, OAuth, API keys) — conceptually universal
- Error handling, validation, rate limiting — universal
- API versioning, documentation — universal

#### What's Web-Specific
- **Default stack:** Node.js + Express + Prisma + PostgreSQL
- **Protocol examples:** tRPC (TypeScript-only, web-frontend-coupled)
- **Auth examples:** Assume cookie-based sessions (web) rather than token-based (mobile)
- **Consumers:** "your web app, mobile apps, third-party devs" — at least mentions mobile
- **Code examples:** Express middleware, Zod validation (Node.js specific)

#### Impact
If a user says "API para mi app móvil":
1. Defaults to Node/Express (could work, but not always optimal)
2. Proposes tRPC (wrong — mobile can't use tRPC easily)
3. Suggests cookie sessions (wrong — mobile uses tokens or native auth)

---

### 3. `git-init-and-versioning` — LOW Web-Centrism

#### What's Universal
- Repository initialization (`git init`)
- `.gitignore` creation
- `.env.example` documentation
- Branching strategies (trunk-based, GitFlow)
- Pre-commit checklists

#### What's Web-Specific
- **Repo structure examples:** `frontend/`, `backend/`, `shared/` — assumes web fullstack
- **"Frontend-only Repository"** — framing assumes web frontend
- **First commit includes:** SPEC.md, DESIGN.md — assumes web project needs DESIGN.md

#### Impact
Minimal. Works for any project type. Just examples are web-centric.

---

### 4. `fullstack-shipping` — HIGH Web-Centrism

#### What's Universal
- CI/CD pipeline principles (test before deploy, rollback strategies)
- Monitoring and alerting concepts
- Deployment stages (staging, production)
- Testing strategy (unit, integration, E2E)

#### What's Web-Specific
- **Deployment targets:** Vercel, Netlify, Railway, Fly (all web/serverless)
- **CI/CD examples:** GitHub Actions for web apps
- **Platform-Native CI/CD:** "Jamstack/Serverless apps"
- **Test tools:** Vitest/Jest (web unit tests), Playwright (browser E2E)
- **No mention of:** App Store deployment, Google Play, TestFlight, desktop installers, IoT OTA updates

#### Impact
If a user says "deploy my mobile app":
1. Suggests Vercel (wrong — mobile needs App Store/Google Play)
2. Proposes Playwright E2E (wrong — mobile needs Detox or Appium)
3. No mention of code signing, app review, beta testing via TestFlight

---

### 5. `spec-driven-development` — LOW Web-Centrism

#### What's Universal
- Research-driven specification
- Discovery questions
- Critical challenge
- Architecture decision gate
- Implement gate

#### What's Web-Specific
- **Phase 0:** Checks `package.json` first (web convention)
- **Assumes:** Web research for domain best practices

#### Impact
Minimal. The skill is mostly about process. Could work for any project type.

---

### 6. `project-health-check` — HIGH Web-Centrism

#### What's Universal
- Checking for documentation (README, SPEC)
- Code quality scanning
- Test presence
- Structure organization

#### What's Web-Specific
- **Stack checks:** Node.js >= 20.9, Next.js >= 16.1.1, React >= 19.2, Tailwind v4
- **Code quality:** "No `bg-blue-500`, `text-gray-700`" — Tailwind-specific
- **Fonts:** "No Inter, Roboto as display font" — web font assumption
- **Structure:** `src/` or `app/` organized — Next.js convention
- **Missing checks for:** Android (`build.gradle`), iOS (`Podfile`), Flutter (`pubspec.yaml`), Rust (`Cargo.toml`), Python (`pyproject.toml`)

#### Impact
If applied to a mobile project:
1. FAILS on "No Next.js" (wrong — mobile doesn't use Next.js)
2. FAILS on "No Tailwind" (wrong — mobile uses StyleSheet or SwiftUI)
3. Can't assess actual mobile health (native dependencies, bundle size, etc.)

---

### 7. `architecture-analysis` — LOW Web-Centrism

#### What's Universal
- Scale questions (users, connections, growth)
- Team assessment (size, experience)
- Data model decisions (relational, document, time-series)
- Latency requirements
- Constraints gathering

#### What's Web-Specific
- Almost nothing. The skill is genuinely framework-agnostic.

#### Impact
None. This skill works for web, mobile, desktop, CLI, IoT, anything.

---

### 8. `dev-environment-audit` — MODERATE Web-Centrism

#### What's Universal
- Checking installed MCPs
- Checking CLI tools (node, git, docker, python, go, rust)
- Asking project type (web, API, mobile, desktop, CLI)

#### What's Web-Specific
- **Deployment targets:** Vercel, Netlify, AWS (all web/cloud)
- **Testing tools:** Playwright (browser E2E)
- **Missing:** Xcode, Android Studio, Flutter SDK, CocoaPods, Gradle checks

#### Impact
If applied to mobile project:
1. Won't check for Xcode or Android Studio
2. Won't suggest Flutter SDK or React Native CLI
3. Deployment target options are all web

---

### 9. `user-onboarding` — LOW Web-Centrism

#### What's Universal
- Identity capture (name, role, industry)
- Workflow preferences
- Constraints (budget, timeline, accessibility)

#### What's Web-Specific
- **"Frontend framework"** question lists React, Vue, Svelte (all web)
- **Missing:** "Mobile framework" (React Native, Flutter, Swift), "Desktop framework" (Tauri, Electron, WPF)
- **"CSS approach"** question assumes web styling

#### Impact
User profile will be incomplete for non-web projects. Agent won't know mobile/desktop preferences.

---

## The Root Causes

### 1. **Example-Driven Bias**
Every skill was written with concrete examples. We wrote what we know: React, Next.js, Node.js, Tailwind. The examples became implicit defaults.

### 2. **Tooling Assumption**
We assumed the agent operates in a JavaScript/TypeScript ecosystem. Skills check `package.json` but not `Cargo.toml`, `pubspec.yaml`, `build.gradle`.

### 3. **Platform Blindness**
We conflated "frontend" with "web frontend". There's no distinction between:
- Web UI (Next.js, Tailwind)
- Mobile UI (React Native, Flutter, SwiftUI)
- Desktop UI (Tauri, Electron, WPF)
- CLI UI (ink, bubbletea, rich)

### 4. **Deployment Tunnel Vision**
Shipping = "deploy to Vercel/AWS". Not:
- Submit to App Store / Google Play
- Build desktop installers (.dmg, .msi, .AppImage)
- Distribute CLI binaries via Homebrew/scoop
- OTA updates for IoT firmware

---

## Universal vs Web-Specific Matrix

| Principle/Pattern | Universal? | Web-Specific Implementation |
|---|---|---|
| Design tokens (colors, typography) | ✅ YES | CSS custom properties → web |
| | | StyleSheet.create → React Native |
| | | ThemeData → Flutter |
| | | AssetCatalog → iOS |
| Animation (60fps, transform/opacity) | ✅ YES | Framer Motion → web |
| | | Reanimated → React Native |
| | | Animated API → Flutter |
| | | UIView.animate → iOS |
| Discovery Gate (ask before build) | ✅ YES | Same process, different questions |
| Anti-slop (be intentional) | ✅ YES | Same principle, different patterns |
| Accessibility (contrast, focus, motion) | ✅ YES | WCAG → web |
| | | AccessibilityInfo → React Native |
| | | AccessibilityTraits → iOS |
| Responsive/Multi-size | ✅ YES | CSS media queries → web |
| | | AutoLayout → iOS |
| | | Constraints → Flutter |
| Build verification | ✅ YES | `npm run build` → web |
| | | `expo build` → React Native |
| | | `flutter build` → Flutter |
| | | `xcodebuild` → iOS |
| | | `cargo build` → Rust CLI |
| Component structure | ✅ YES | React components → web |
| | | Widgets → Flutter |
| | | Views → iOS/Android |
| State management | ✅ YES | useState/useReducer → React |
| | | Provider/Riverpod → Flutter |
| | | @State/ObservableObject → SwiftUI |
| API consumption | ✅ YES | fetch/axios → web |
| | | URLSession → iOS |
| | | Retrofit/Volley → Android |
| | | Dio → Flutter |

---

## Recommendations

### Short-Term (Before 9.5/10)

1. **Rename `visual-frontend-mastery` → `frontend-mastery`**
   - Remove web-specific stack lock-in
   - Add platform detection: web, mobile, desktop, CLI
   - Create `frontend-mastery/guides/web-guide.md` (current content)
   - Create `frontend-mastery/guides/mobile-guide.md` (React Native, Flutter)
   - Create `frontend-mastery/guides/desktop-guide.md` (Tauri, Electron)
   - Keep universal principles in main SKILL.md

2. **Fix `project-health-check` stack detection**
   - Check for `package.json` OR `Cargo.toml` OR `pubspec.yaml` OR `build.gradle`
   - Version checks must match the detected stack
   - "No Tailwind generics" → "No hardcoded design tokens outside the system"

3. **Fix `fullstack-shipping` deployment targets**
   - Add mobile deployment (App Store, Google Play, TestFlight)
   - Add desktop deployment (installers, auto-updaters)
   - Add CLI distribution (Homebrew, cargo install, npm global)

4. **Update `user-onboarding`**
   - Split "Frontend framework" into "Web framework", "Mobile framework", "Desktop framework"
   - Add "Primary platform" question: Web / Mobile / Desktop / CLI / IoT

### Long-Term (Post-9.5/10)

1. **Create `mobile-react-native` skill**
2. **Create `mobile-flutter` skill**
3. **Create `desktop-tauri` skill**
4. **Create `cli-tools` skill**
5. **Refactor all skills to load platform-specific guides dynamically**

---

## Success Criteria

The ecosystem is no longer "web-centric" when:
- [ ] A user can say "quiero una app móvil" and the agent doesn't suggest Next.js
- [ ] A user can say "quiero una app de escritorio" and the agent suggests Tauri/Electron
- [ ] A user can say "quiero un CLI en Go" and the agent doesn't ask "¿React o Vue?"
- [ ] `project-health-check` correctly audits a Flutter project without failing on "No Next.js"
- [ ] `fullstack-shipping` includes App Store submission in the pipeline
- [ ] All skills have a "Platform Detection" section like `backend-api-mastery` has "Stack Detection"

---

## Next Steps

1. Decide on architecture: **Unified skills with platform guides** vs **Separate skills per platform**
2. Refactor `visual-frontend-mastery` first (most web-centric)
3. Update `AGENTS.md` lifecycle to include "Platform Selection" as a new phase
4. Test with a non-web project (e.g., "Crea un CLI en Python")

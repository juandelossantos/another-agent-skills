# Design Skills

This doc catalogs all design-related skills in the Another Agent Skills ecosystem. They fall into three tiers:

- **Platform skills** — Build UIs for a specific platform (web, mobile, desktop, PWA)
- **Direction skills** — Apply a specific design aesthetic or behavioral constraint
- **Review pipeline** — Audit, critique, and fix design quality across all platforms

All design skills are built on `engineering-fundamentals` and reference its Three Dials System (Variance, Motion, Density) and DESIGN-CORE guide.

---

## Platform Skills

| Skill | Platform | Default Stack | What It Builds |
|---|---|---|---|
| `frontend-web` | Browser | React/Next.js + Tailwind + Framer Motion | Websites, web apps, dashboards, landing pages |
| `frontend-pwa` | Browser (installable) | Next.js + Service Worker + Capacitor | Offline-first apps, hybrid mobile via Capacitor |
| `frontend-mobile` | Mobile OS | React Native + Expo | iOS and Android native apps |
| `frontend-desktop` | Desktop OS | Tauri v2 (Rust + Webview) | Native desktop apps (macOS, Windows, Linux) |

Each platform skill follows the same lifecycle:

```
Discovery → Design Lock → Spec → Build → Verify → Ship
```

They share the same design core (Three Dials) and differ only in platform-specific constraints and tooling.

### When to Use

| Trigger | Skill |
|---|---|
| "Build a landing page" | `frontend-web` |
| "I need an app that works offline" | `frontend-pwa` |
| "Build a mobile app for iOS/Android" | `frontend-mobile` |
| "Create a native desktop app" | `frontend-desktop` |

---

## Direction Skills

| Skill | Aesthetic | Key Traits |
|---|---|---|
| `industrial-brutalist-ui` | Raw, mechanical | Swiss typography, military terminal colors, rigid grids, analog degradation |
| `minimalist-ui` | Editorial, calm | Notion/Linear inspired, warm monochrome, typographic contrast, bento grids |
| `soft-premium-ui` | Polished, expensive | Double-bezel nesting, fluid island nav, button-in-button, spring motion |
| `output-skill` | Behavioral | Ensures complete agent output: no placeholders, skipped sections, or half-finished work |
| `redesign-skill` | Systematic | Scans existing UI, diagnoses 8 categories, fixes in priority order without breaking functionality |

Direction skills apply a specific visual language or behavioral constraint. They are additive — you use one direction as the design system for a platform skill.

### When to Use

| Trigger | Skill |
|---|---|
| "Make it look brutalist / industrial" | `industrial-brutalist-ui` |
| "Clean product UI like Notion" | `minimalist-ui` |
| "Premium, expensive feel" | `soft-premium-ui` |
| "Agent keeps outputting incomplete code" | `output-skill` |
| "Redesign this existing page" | `redesign-skill` |

---

## Design Review Pipeline

The pipeline turns subjective design feedback into a deterministic, measurable process. Run after the build phase, before shipping.

```
Critique → Audit → Clarify → Hard → Polish → Typeset → Adapt → Optimize → Delight
```

| Skill | Dimension | What It Does | Scoring |
|---|---|---|---|
| `critique-skill` | Design quality | Two-pass review (LLM + automated), Nielsen 10 heuristics, 4 persona tests, AI slop detection | 0-4 per heuristic |
| `audit-skill` | Technical quality | 5-dimension scan: accessibility (WCAG), performance, theming, responsive, anti-patterns | 0-4 per dimension, P0-P3 severity |
| `clarify-skill` | UX copy | Rewrites labels, errors, buttons, empty states, confirmations, tooltips. Voice-tuned per audience | 8 QA gates |
| `hard-skill` | Accessibility & robustness | Mechanical P0/P1 fixes: ARIA labels, keyboard nav, form validation, error/loading/empty states, confirmation dialogs | Traces to audit findings |
| `polish-skill` | Design details | Fixes spacing (token scale), alignment, border radius, shadows, token drift. No design decisions | Token compliance verified |
| `typeset-skill` | Typography | Applies type ramp, fixes line-height (heading 1.0-1.25 / body 1.5-1.7), letter-spacing, paragraph rhythm | 8 QA gates |
| `adapt-skill` | Responsive layout | Fixes breakpoint gaps, touch targets (≥44px / 48dp), viewport (100dvh), overflow, hover-only actions | 9 QA gates |
| `optimize-skill` | Performance | Bundle code-splitting, lazy loading, image optimization (WebP/AVIF + srcset), animation compositing, layout thrashing elimination | Lighthouse ≥90 |
| `delight-skill` | Micro-interactions | Hover/tap feedback, state transitions (150-400ms), loading skeletons, success/error animations, page enter stagger | 9 QA gates |

### Typical Flow

1. **Critique** evaluates design quality — heuristic scoring and persona tests
2. **Audit** scans technical quality — accessibility, performance, theming, responsive, anti-patterns
3. **Clarify** fixes confusing UX copy
4. **Hard** applies mechanical accessibility and robustness fixes
5. **Polish** fixes visual inconsistencies and token drift
6. **Typeset** corrects typography and reading rhythm
7. **Adapt** fixes responsive layout issues
8. **Optimize** addresses performance bottlenecks
9. **Delight** adds micro-interactions and feedback

Each skill is independent — run the ones you need, skip the ones you don't.

### When to Use

| Trigger | Start With |
|---|---|
| "Does this design hold up?" | `critique-skill` |
| "Is this production-ready?" | `audit-skill` |
| "The UX copy is confusing" | `clarify-skill` |
| "Make it accessible" | `audit-skill` → `hard-skill` |
| "Polish the visuals" | `audit-skill` → `polish-skill` + `typeset-skill` |
| "Fix mobile layout" | `adapt-skill` |
| "The page is slow" | `optimize-skill` |
| "Make it feel alive" | `delight-skill` |

---

## Ecosystem Map

```
engineering-fundamentals (foundation)
├── Platform skills
│   ├── frontend-web
│   ├── frontend-pwa
│   ├── frontend-mobile
│   └── frontend-desktop
├── Direction skills
│   ├── industrial-brutalist-ui
│   ├── minimalist-ui
│   ├── soft-premium-ui
│   ├── output-skill
│   └── redesign-skill
└── Design Review Pipeline
    ├── critique-skill
    ├── audit-skill
    ├── clarify-skill
    ├── hard-skill
    ├── polish-skill
    ├── typeset-skill
    ├── adapt-skill
    ├── optimize-skill
    └── delight-skill
```

All 21 design skills are cross-platform, stack-agnostic, and follow the lazy loading pattern (SKILL.md ≤ 250 lines, guides loaded on-demand).

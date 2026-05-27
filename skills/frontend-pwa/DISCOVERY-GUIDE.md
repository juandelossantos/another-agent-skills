# Frontend PWA — Discovery Guide

Execute every step. Do not skip. Do not assume.

---

## Step 1: Surface Assumptions

List at least 5 assumptions about the project. Present for confirmation **in detected language**:

1. **Offline scope**: Full app, critical path only, or none?
2. **Device matrix**: Mobile only, or tablet + desktop + foldable TV?
3. **Installability**: From browser, App Store via Capacitor, or both?
4. **Input method**: Touch, mouse, keyboard, or all?
5. **Push notifications**: Needed? Which provider?

## Step 2: Extended Discovery (Mandatory)

Ask at least 5:

1. **Service worker strategy**: Cache-first, network-first, stale-while-revalidate?
2. **Offline page**: Custom offline page or cached app shell?
3. **Background sync**: Queue actions and replay when online?
4. **Capacitor migration**: Planned for future App Store/Play Store?
5. **Device sensors**: Camera, GPS, accelerometer via web APIs?
6. **Authentication**: Offline-compatible tokens? Session persistence?
7. **Performance budget**: Max bundle size? LCP target?
8. **Accessibility**: Screen reader support, reduced motion, high contrast?
9. **Brand**: Existing colors, fonts, or start from scratch?
10. **Design inspiration**: References, moodboards, or style guide?

## Step 3: Confirm

Summarize findings. Ask: "Is this correct? Shall we proceed?" Only after explicit yes.

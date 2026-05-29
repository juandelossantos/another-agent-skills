# Delight — Motion Specification

**Timing, easing, and choreography for every interaction.**

## Timing Ranges

| Interaction | Duration | Why |
|---|---|---|
| Hover / tap feedback | 150ms | Instant enough to feel responsive, visible enough to confirm |
| Button press (elevation) | 100ms | Snappy — this is tactile feedback, not a transition |
| Tooltip show | 200ms (delay 300ms) | Don't show on accidental hover |
| Tooltip hide | 100ms (no delay) | Immediate dismissal |
| Dropdown expand | 200ms | Quick, enough to see direction |
| Dropdown collapse | 150ms | Faster on dismiss (user is done) |
| Modal overlay | 250ms | Visible enough to feel spatial |
| Page transition | 300–400ms | Too fast = jarring, too slow = sluggish |
| List item enter | 300ms (staggered 50ms) | Sequential build feels organized |
| Toast notification | 400ms in, 3000ms visible, 300ms out | Long enough to read, soon enough to not block |
| Skeleton pulse | 1.5s cycle | Subtle, not distracting |
| Scroll to element | 300ms | Fast navigation |
| Stagger delay (per item) | 30–80ms | Closer to entry = higher delay |

## Easing Curves

```css
:root {
  --ease-out: cubic-bezier(0.16, 1, 0.3, 1);        /* Standard exit — buttons, modals, dropdowns */
  --ease-in: cubic-bezier(0.4, 0, 0.68, 0.06);        /* Standard enter — avoid for most UI */
  --ease-in-out: cubic-bezier(0.65, 0, 0.35, 1);      /* Standard both — page transitions */
  --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);    /* Bouncy — celebrations, success states */
  --ease-linear: cubic-bezier(0, 0, 1, 1);              /* Linear — avoid for organic motion */
  --ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);          /* Material default — general purpose */
}
```

### When to use each

| Easing | Use for |
|---|---|
| `--ease-out` | Entering elements (appear from nothing). Fast start, slow end. |
| `--ease-in` | Exiting elements (fade/disappear). Never for enter. |
| `--ease-in-out` | Page transitions, shared element animation, enter + exit. |
| `--ease-spring` | Checkmarks, success states, badges, counters. Sparingly. |
| `--ease-smooth` | Hover states, color transitions, panel slides. |

## What NOT to Animate

- **Layout properties** (width, height, top, left, padding, margin) → triggers layout reflow and repaint. Use `transform` and `opacity` instead.
- **Box-shadow** → expensive to paint. Use a pseudo-element or filter: drop-shadow.
- **All elements at once** → stagger them.
- **Every color transition** → animate only the color that changes meaning (e.g., error red), not all colors.
- **Scroll-driven animations** that break `prefers-reduced-motion`.

## Stagger Pattern

```css
/* Children appear one by one */
.list-item {
  opacity: 0;
  transform: translateY(8px);
  animation: fadeSlideIn 300ms var(--ease-out) forwards;
}

@keyframes fadeSlideIn {
  to { opacity: 1; transform: translateY(0); }
}

/* Stagger: each child gets a delay */
.list-item:nth-child(1) { animation-delay: 0ms; }
.list-item:nth-child(2) { animation-delay: 50ms; }
.list-item:nth-child(3) { animation-delay: 100ms; }
/* ... or use JS for dynamic lists */
```

## Page Transition Pattern

```css
/* Page enter */
.page-enter {
  opacity: 0;
  transform: translateY(12px);
}
.page-enter-active {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 300ms var(--ease-out), transform 300ms var(--ease-out);
}

/* Page exit */
.page-exit {
  opacity: 1;
}
.page-exit-active {
  opacity: 0;
  transition: opacity 200ms var(--ease-in);
}
```

## prefers-reduced-motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }

  /* Keep these — they're functional, not decorative */
  .spinner { animation-duration: 1s !important; }
  .skeleton-pulse { animation-duration: 2s !important; }
  .loading-bar { animation-duration: 1.5s !important; }
}
```

## Interaction Feedback Matrix

| Trigger | Feedback | Timing | Easing |
|---|---|---|---|
| Button hover | Background color shift | 150ms | `--ease-smooth` |
| Button active/press | Scale 0.97 | 100ms | `--ease-out` |
| Link hover | Underline slide-in | 200ms | `--ease-out` |
| Card hover | Shadow elevate | 200ms | `--ease-smooth` |
| Input focus | Border color + glow | 200ms | `--ease-smooth` |
| Checkbox toggle | Checkmark scale-in | 200ms | `--ease-spring` |
| Switch toggle | Knob slide + bg color | 200ms | `--ease-out` |
| Modal open | Fade + scale 0.95→1 | 250ms | `--ease-out` |
| Modal close | Fade only | 200ms | `--ease-in` |
| Page transition | Cross-fade + slide | 350ms | `--ease-in-out` |
| Error shake | Translate 4px left-right | 300ms | `--ease-out` (3 oscillations) |
| Success checkmark | Scale 0→1 + bounce | 400ms | `--ease-spring` |
| Skeleton pulse | Opacity 0.2→1 cycle | 1.5s | `--ease-in-out` |

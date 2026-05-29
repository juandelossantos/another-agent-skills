# Audit Protocol Guide

**How to run a five-dimension technical audit on any component or page.**

## Before You Start

- [ ] Pick one component or page. Do not audit the whole app at once.
- [ ] Open the component in a browser or simulator.
- [ ] Have DevTools ready (Chrome DevTools for web, React DevTools for RN, Xcode Instruments for iOS).
- [ ] Set a timer: 15 minutes max per dimension.

## Dimension 1 — Accessibility

### Find all interactive elements

```js
// In browser console:
document.querySelectorAll('button, a, input, select, textarea, [role="button"], [tabindex]')
```

For each element found, check:

| Check | How |
|---|---|
| Keyboard reachable | Tab through. Can you reach every interactive element? |
| Visible focus | Is there a `:focus-visible` ring on every element? |
| Labeled | `aria-label`, `aria-labelledby`, or associated `<label>`? |
| Role correct | `<button>` not `<div onClick>`, `<nav>` not `<div>` |
| Skip links | First tab stop goes to "Skip to content"? |

### Check contrast

```js
// In browser console — check computed style on text elements:
getComputedStyle(element).color
getComputedStyle(element).backgroundColor
// Paste into: https://webaim.org/resources/contrastchecker/
// Pass: 4.5:1 for normal text, 3:1 for large text (18px+ bold or 24px+)
```

### Check reduced motion

```css
/* Add to DevTools and reload: */
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```

If layout breaks or content disappears → FAIL.

## Dimension 2 — Performance

### Measure LCP

```js
// In browser console before interaction:
new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log('LCP candidate:', entry.element, entry.startTime, 'ms');
  }
}).observe({type: 'largest-contentful-paint', buffered: true});
```

Pass: LCP < 2500ms.

### Check for layout thrashing

```js
// Look for this pattern in your codebase:
element.offsetHeight  // forces reflow
element.style.height = '100px'  // another reflow
// BAD: read + write interleaved
// GOOD: batch all reads, then all writes
```

### Check lazy loading

```js
// In browser console:
document.querySelectorAll('img:not([loading="lazy"])')
// If images below the fold are in the list → FAIL
```

### Check bundle

Open DevTools > Network tab. Reload. Check total JS transferred.
Pass: < 500KB critical path JS.

## Dimension 3 — Theming

### Scan for hardcoded colors

```bash
grep -rn '#[0-9a-fA-F]\{3,6\}\|rgba\|hsla' src/ --include='*.{tsx,jsx,ts,js,css}' | grep -v '\.test\.' | grep -v 'node_modules'
```

Every result should either be:
- A design token (`var(--color-primary)`)
- A CSS variable reference
- Documented as an intentional exception

### Check dark mode

Toggle dark mode. For each component:
- All text legible? (check contrast on dark bg)
- No light-mode-only colors leaked?
- Shadows still visible (not black on black)?

## Dimension 4 — Responsive

### Test at each breakpoint

| Width | What to check |
|---|---|
| 360px | Overflow, stacked layout, touch targets ≥44px |
| 768px | Split view, sticky overlaps |
| 1024px | Whitespace balance |
| 1440px+ | Line-length ≤ 80ch |

```js
// Simulate in DevTools: Ctrl+Shift+M (mobile toggle)
// Check each breakpoint manually.
```

### Check touch targets

```js
// In browser console on mobile viewport:
document.querySelectorAll('button, a, input, select').forEach(el => {
  const rect = el.getBoundingClientRect();
  if (rect.width < 44 || rect.height < 44) {
    console.warn('Touch target too small:', el, rect.width, 'x', rect.height);
  }
});
```

## Dimension 5 — Anti-Patterns

Run the 25-item anti-pattern scan from `critique-skill/ANTI-PATTERNS.md`.

Key red flags in audit context:

| Anti-pattern | How to detect |
|---|---|
| Three equal cards | Three siblings with identical structure and no visual hierarchy |
| The middle path | Everything is grey. No emphasis anywhere. |
| False specificity | Labels that describe the UI, not the data ("Name" instead of "Company name") |
| Ambiguous empty state | "No items" with no explanation or next action |

## After the Scan

1. Tag each finding P0-P3 (see SKILL.md severity table).
2. Sort: all P0 first, then P1, then P2, then P3.
3. Route P0-P1 to `hard-skill` or `clarify-skill` or `polish-skill`.
4. Route P2-P3 to backlog.
5. Re-audit after fixes.

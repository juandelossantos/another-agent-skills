# Device Matrix Guide

Universal responsive design for `frontend-pwa`.

## Device Matrix (MANDATORY)

| Device | Width | Approach |
|---|---|---|
| Foldable closed | 280-320px | Single column, essential only |
| Phone portrait | 375-428px | Mobile-first design |
| Phone landscape | 667-926px | Adjusted layout |
| Tablet portrait | 768-834px | Sidebar may appear |
| Tablet landscape | 1024-1366px | Full layout, multi-pane |
| Desktop | 1280-1920px | Full experience, hover available |
| TV / Big screen | 1920-3840px | Larger touch targets, simpler navigation |

**Test minimum: 375px, 768px, 1024px, 1920px.**

## Container Queries (Preferred)

```css
.card-container { container-type: inline-size; }
@container (min-width: 400px) {
  .card-grid { grid-template-columns: repeat(2, 1fr); }
}
```

## Touch vs Mouse

```css
@media (hover: hover) and (pointer: fine) {
  .button:hover { transform: scale(1.02); }
}
@media (pointer: coarse) {
  .button { min-height: 48px; }
}
```

## Viewport Safety

- No `100vh` on mobile (breaks with browser chrome).
- Use `100dvh`, `100svh`, or `100lvh`.

# Delight Skill — Implementation Guide

## Hover States

```css
.button {
  transition: transform 200ms ease, box-shadow 200ms ease;
}
.button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}
```

## Focus Indicators

```css
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
```

## Loading States

```css
@keyframes shimmer {
  0% { background-position: -200px 0; }
  100% { background-position: calc(200px + 100%) 0; }
}
.skeleton {
  background: linear-gradient(90deg, var(--bg-card) 25%, var(--bg) 50%, var(--bg-card) 75%);
  background-size: 200px 100%;
  animation: shimmer 1.5s infinite;
}
```

## Success Animations

Use `stroke-dasharray` + `stroke-dashoffset` for check mark drawing animation. Duration: 300-500ms. Combine with a scale bounce on the container.

## Reduced Motion

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

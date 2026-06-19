# Delight Skill — Animation Guide

## Performance Principles

- Animate only `transform` and `opacity` — triggers compositing only, no layout or paint
- Duration: 200-300ms for UI, 400-500ms for emphasis, 100ms for instant feedback
- Easing: `cubic-bezier(0.34, 1.56, 0.64, 1)` for spring-like motion. Avoid linear.
- Respect `prefers-reduced-motion`: replace animations with instant transitions

## Micro-Interaction Types

| Type | Trigger | Example | CSS |
|---|---|---|---|
| Hover | Mouse enter | Button lifts | `transform: translateY(-2px)` |
| Focus | Keyboard tab | Input glows | `box-shadow: 0 0 0 2px accent` |
| Active | Mouse down | Button presses | `transform: scale(0.97)` |
| Loading | Async start | Skeleton pulse | `@keyframes pulse { opacity }` |
| Success | Action complete | Check mark | `stroke-dashoffset` animation |
| Error | Validation fail | Shake input | `translateX` oscillation |
| Empty | No data | Gentle fade-in | `opacity: 0 → 1` over 300ms |

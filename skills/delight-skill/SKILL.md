---
name: delight-skill
description: >
  Add micro-interactions, transitions, hover states, and feedback
  animations. Turns static UIs into responsive, tactile interfaces.
  Use when a UX feels stiff, lifeless, or lacks feedback.
license: MIT
compatibility: opencode
metadata:
  audience: all-designers
  stack: any
  workflow: evaluate-delight
---

# Delight Skill

**Add micro-interactions so interfaces respond like physical things.**

Micro-interactions are the difference between a UI that feels alive and one that feels like a PDF. Every interaction should leave a trace.

## When to Use

- Interface feels stiff or lifeless
- No feedback on hover, tap, or action completion
- User says "make it feel more responsive"
- Transitions feel jarring or instant (no duration)
- Loading states are blank or flicker
- After functionality is complete, before polish

Do NOT use for:
- Performance optimization (use `optimize` — then `delight` on top)
- Structural changes (use `build` skills)
- Replacing missing states (use `harden` first)

## Process

### 1. Identify Touchpoints

Every user interaction is a delight opportunity:

| Interaction | Current state | Delight opportunity |
|---|---|---|
| Hover | Static | Scale, glow, shadow lift |
| Tap/click | Instant | Ripple, micro-bounce, color shift |
| State change | Abrupt | Smooth transition, morph |
| Loading | Spinner or blank | Skeleton, progress bar, shimmer |
| Success | Nothing | Checkmark, confetti, subtle pulse |
| Error | Red flash | Shake, gentle wiggle |
| Empty | Blank | Animated illustration, subtle float |
| Page enter | Instant | Fade in, slide, stagger children |

### 2. Fix by Category

#### Hover & Focus

| Before | After | Duration |
|---|---|---|
| No hover effect | `transform: scale(1.03)` + shadow lift | 150-200ms |
| Instant color swap | `background-color` transition | 200-300ms on button |
| No focus ring | `outline` with transition | 150ms |
| Card hover none | `translateY(-2px)` + subtle shadow | 200ms ease |

#### Tap & Click

| Before | After | Notes |
|---|---|---|
| Instant jump | `transform: scale(0.97)` on active | Returns on release |
| No feedback | Button darkens 10% on press | Apply to all interactive |
| Toggle instant | Swipe + morph animation | 250ms spring |

#### State Transitions

| Before | After | Duration |
|---|---|---|
| Content appears (pop in) | Fade + slide up 8px | 200-300ms |
| Content disappears | Fade + scale down | 150-200ms |
| Page enters instantly | Stagger children, fade up | 300ms total |
| Modal opens instantly | Scale from 0.95 + backdrop fade | 200ms |
| Tab switch instant | Slide content directionally | 200ms |

#### Loading & Feedback

| Before | After | Notes |
|---|---|---|
| Blank while loading | Skeleton screen (pulse animation) | Match shape |
| Spinner only | Progress bar with known duration | Or shimmer for unknown |
| Success no feedback | Checkmark draw animation | 300ms |
| Error no feedback | Shake input + highlight border | 300ms shake |
| Toast appears instantly | Slide in from top/right + fade | 250ms + 3s auto-dismiss |

### 3. Performance Rules

- Animate ONLY `transform` and `opacity` — never `width`, `height`, `top`, `left`
- Keep durations between 150ms-400ms (below 150ms is instant, above 400ms is slow)
- Use `will-change: transform` on animated elements
- Respect `prefers-reduced-motion` (use `harden` to add it)
- Avoid animating 10+ elements simultaneously

### 4. Output Format

```
/delight the product card

Fix 1: Hover state
  - Before: no hover effect
  - After: transform: scale(1.02), box-shadow: 0 4px 12px, transition: 200ms

Fix 2: Add to cart button
  - Before: text changes instantly
  - After: icon morphs from "+" to checkmark (200ms), button pulses green

Fix 3: Card enter animation
  - Before: all cards appear at once
  - After: stagger in by index, translateY(20px) → translateY(0), 250ms each

Fix 4: Loading skeleton
  - Before: loading text
  - After: card-shaped skeleton with shimmer animation
```

### 5. Escalation Rules

| Finding | Escalate to |
|---|---|
| Animation causes jank | `optimize` first, then reapply |
| Need complex gesture | Interaction design review |
| Animation contradicts brand | Design decision |

## Pitfalls

- **Over-delighting** — Not every pixel needs to animate. Animate interactions, not eye candy.
- **Accessibility first** — Always test with `prefers-reduced-motion`. Delight must degrade gracefully.
- **Duration drift** — Keep all micro-interactions within 150-400ms. Faster than conscious thought.
- **Animation without purpose** — Every animation should communicate: this changed, this is interactive, this is happening.

## QA Gates

- [ ] All interactive elements have hover/focus feedback
- [ ] All state changes have transitions (not instant)
- [ ] All durations within 150-400ms
- [ ] Only `transform` and `opacity` animated
- [ ] `prefers-reduced-motion` respected
- [ ] Loading states have animation (not blank)
- [ ] Success/error feedback is animated
- [ ] Page enters have subtle transition
- [ ] No animation for animation's sake

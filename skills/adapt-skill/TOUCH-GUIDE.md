# Adapt — Touch Target Guide

**Thumb-friendly design for real human hands.**

## The 44px Rule

```css
/* Minimum touch target for mobile */
.button, .link, .input, .select, .chip {
  min-height: 44px;
  min-width: 44px;
}
```

**This is non-negotiable.** WCAG 2.2 SC 2.5.8 requires 44px. Apple HIG requires 44pt. Material Design requires 48dp.

## Touch Target Map

| Element | Minimum | Recommended | Notes |
|---|---|---|---|
| Button (standalone) | 44×44 | 48×48 | Increase for primary actions |
| Button (icon-only) | 44×44 | 48×48 | Must have aria-label |
| Link (inline text) | — | 44×44 | If link is in a paragraph, keep text and increase tap area with padding |
| Input field | 44px height | 48px height | Width is contextual |
| Checkbox / Radio | 44×44 | 48×48 | Visual box can be 20px, tap area via padding |
| Slider thumb | 44×44 | 48×48 | Color contrast on thumb: ≥ 3:1 |
| Tab | 44×44 | 48×48 | Active tab must have visible indicator |
| Menu item | 44px height | 48px height | Full-width tap area |
| Dropdown trigger | 44×44 | 48×48 | Chevron icon must be in tap area |
| Bottom sheet handle | 32×44 | 44×44 | Draggable, not clickable — lower minimum acceptable |
| Close button (modal) | 44×44 | 48×48 | Positioned for easy thumb reach |
| Chip / Tag | 32×44 | 44×44 | Remove button within chip must be 44×44 |

## Thumb Zones

```
┌─────────────────────────────────────┐
│  🔴 [HARD]          Top corners     │  ← one-handed thumb can't reach
│  🟡 [STRETCH]   Top center/edges    │  ← thumb stretches
│  🟢 [EASY]      Bottom half         │  ← natural thumb arc
│  🟢 [EASY]      Center              │  ← either hand
│  🟡 [STRETCH]   Bottom corners (L)  │  ← right-handed: bottom-left is hard
│  🔴 [HARD]      Top-left corner     │  ← right-handed: unreachable
└─────────────────────────────────────┘
```

### Placement rules

| Action type | Zone | Reason |
|---|---|---|
| Primary call-to-action | 🟢 Bottom-center | Thumb natural rest zone |
| Back/navigation | 🟢 Bottom-left (LTR) | Thumb natural motion |
| Delete/destructive | 🟡 After confirmation | Never in easy accidental zone |
| More options (⋯) | 🟡 Top-right | Not used frequently |
| Hamburger menu | 🟢 Bottom or 🟡 Top with reachability | If top, provide swipe-back gesture |
| Form submit | 🟢 Bottom (sticky) | Above keyboard, not behind it |
| Close (modals) | 🟢 Top-right or 🟢 Bottom (swipe down) | Mobile: swipe-down is natural |

## Spacing Between Targets

```css
/* WCAG 2.2 SC 2.5.8 — adjacent targets must have 4px minimum space */
.button-group {
  display: flex;
  gap: 8px; /* 8px gap ensures tap accuracy */
}
```

Minimum gap: 4px. Recommended: 8px.

## Hover-Only Actions

**Actions that only trigger on hover don't exist on touch devices.** Every hover action needs a touch alternative:

| Hover action | Touch alternative |
|---|---|
| Show tooltip | Show on tap (first tap shows tooltip, second tap triggers action) |
| Show edit button | Always show edit button, or show after element is focused |
| Change color/state | Persistent toggle — not hover-dependent |
| Preview thumbnail | Tap to preview, then tap again or swipe to dismiss |
| Dropdown reveal | Tap to expand, tap outside to close |

## Testing Touch

```js
// In DevTools mobile viewport:
document.querySelectorAll('button, a, input, select, [role="button"]').forEach(el => {
  const rect = el.getBoundingClientRect();
  const padding = window.getComputedStyle(el);
  const tapWidth = rect.width + parseFloat(padding.paddingLeft) + parseFloat(padding.paddingRight);
  const tapHeight = rect.height + parseFloat(padding.paddingTop) + parseFloat(padding.paddingBottom);
  if (tapWidth < 44 || tapHeight < 44) {
    console.warn(`Small target: ${el.tagName} ${tapWidth.toFixed(0)}×${tapHeight.toFixed(0)}`, el);
  }
});
```

### Device-Specific Notes

| Device | Notes |
|---|---|
| iPhone SE (375×667) | 44pt minimum. Thumb reach is very limited — put all controls in bottom half. |
| iPhone Pro Max (430×932) | 44pt minimum. Reachable with hand stretch. |
| iPad (1024×1366) | 44pt minimum. Most users hold with two hands — top-left is reachable. |
| Android foldable (folded: 360px) | Same as small phone when folded. Expanded: treat as tablet. |
| iPad with keyboard | Mouse/trackpad input — 44pt still applies for touch. |

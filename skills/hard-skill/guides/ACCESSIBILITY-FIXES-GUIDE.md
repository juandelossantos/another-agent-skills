# Harden Skill — Accessibility Fixes

## Focus Management

| Issue | Fix | WCAG |
|---|---|---|
| No visible focus | Add `:focus-visible` outline | 2.4.7 |
| Tab order wrong | Adjust DOM order or `tabindex` | 2.4.3 |
| Focus trapped | Add escape handler to modal | 2.1.2 |
| Skip link missing | Add `#main-content` skip link | 2.4.1 |

## Color & Contrast

| Issue | Fix | WCAG |
|---|---|---|
| Text contrast <4.5:1 | Darken text or lighten bg | 1.4.3 |
| Link not distinguishable | Add underline or icon | 1.4.1 |
| Error state color-only | Add icon + text label | 1.4.1 |

## Screen Reader

| Issue | Fix |
|---|---|
| Icon button no label | Add `aria-label="..."` |
| Image no alt | Add `alt="..."` or `alt=""` (decorative) |
| Dynamic content not announced | Use `aria-live="polite"` |
| Status not announced | Use `role="status"` |

# Polish — Token Audit Guide

**Find color drift, spacing drift, and typography drift before they accumulate.**

## Color Drift

### Symptoms
- Primary button on page A is `#3B82F6` (blue-500), on page B it's `#2563EB` (blue-600)
- Error text is red-500 in one component, red-600 in another
- Background gray varies between `#F3F4F6`, `#F5F5F5`, and `#F9FAFB`

### Scan

```bash
# Find all hex/rgb values in source files
rg '#[0-9a-fA-F]\{3,6\}\|rgba\|hsla' src/ --include='*.{tsx,jsx,ts,js,css}' | sort | uniq -c | sort -nr
```

Look for:
- Same semantic value used with different hex codes (e.g., `bg-gray-50` vs `#F5F5F5`)
- Inline color values that bypass the token system

### Fix

| If you find | Replace with |
|---|---|
| `#3B82F6` | `var(--color-primary)` |
| `bg-blue-500` | `bg-primary` |
| `text-gray-500` | `text-secondary` |
| Any hex outside token file | Token or documented exception |

## Spacing Drift

### Symptoms
- Section padding: 24px in one place, 32px in another
- Button internal padding varies between 10px and 14px
- Gap between form fields: 16px in one form, 20px in another

### Rules for exceptions

A spacing exception is OK if:
1. It's a third-party or legacy component you're not touching
2. It's deliberately different for visual hierarchy (e.g., hero padding)
3. It's documented with a comment: `/* intentional: hero section needs generous breathing room */`

## Typography Drift

### Symptoms
- Body text `14px` in one component, `16px` in another
- Heading `font-weight: 600` in one place, `font-weight: 700` in another
- Line-height varies between `1.4` and `1.6` for the same text style

### Scan

```bash
rg 'font-size\|font-weight\|line-height' src/ --include='*.{css,tsx,jsx,ts,js}' \
  | rg -i 'px\|em\|rem\|bold\|semibold\|[45]00\|[67]00' \
  | sort | uniq -c | sort -nr
```

### Typography Scale Map

| Token | Applies to | Rule |
|---|---|---|
| `--text-xs` (12px) | Captions, timestamps, badges | One token only |
| `--text-sm` (14px) | Secondary text, labels | One token only |
| `--text-base` (16px) | Body text, paragraphs | One token only |
| `--text-lg` (18px) | Large body, subtitle | One token only |
| `--text-xl` (20px) | H4, section titles | One token only |
| `--text-2xl` (24px) | H3 | One token only |
| `--text-3xl` (30px) | H2 | One token only |
| `--text-4xl` (36px+) | H1 | One token only |

## Border Radius Drift

### Symptoms
- Card A has `border-radius: 8px`, Card B on the same page has `10px`
- Input fields use `4px` in one form, `8px` in another
- Modal uses `12px` at the top but `16px` elsewhere

### Tolerance
Same component type → exact match required. Different component → same tier.

## Shadow Drift

### Symptoms
- Modals: some have `box-shadow: 0 20px 25px`, others `0 10px 15px`
- Cards: some shadowed, others flat (without clear reason)
- Dropdown: inconsistent elevation

### Fix
Shadow belongs to the elevation tier, not to the component type. A card at the same depth level should always use the same shadow, regardless of what page it's on.

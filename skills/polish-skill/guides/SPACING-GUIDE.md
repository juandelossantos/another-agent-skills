# Polish — Spacing Guide

**Consistent spacing eliminates visual noise. Use this guide to audit and fix every component.**

## The Spacing Scale

```css
--space-0:   0px;
--space-1:   4px;   /* micro — icon inset, badge padding */
--space-2:   8px;   /* tight — between icon + label, chip padding */
--space-3:   12px;  /* comfortable — input padding, button padding */
--space-4:   16px;  /* base — card padding, list item gap */
--space-5:   20px;  /* relaxed — section title to content */
--space-6:   24px;  /* section — between form groups, card gap */
--space-8:   32px;  /* page — between major sections */
--space-10:  40px;  /* generous — page padding, hero padding */
--space-12:  48px;  /* layout — between page sections */
--space-16:  64px;  /* spread — major page breaks */
--space-20:  80px;  /* generous page break */
```

### Quick rules

| Relationship | Token |
|---|---|
| Icon to label (inline) | `--space-2` |
| Label to input | `--space-1` |
| Input padding (vertical) | `--space-3` |
| Input padding (horizontal) | `--space-4` |
| Input to next field | `--space-5` |
| Card edge to content | `--space-4` |
| Card to card | `--space-6` |
| Section title to first item | `--space-4` |
| Section to section | `--space-8` |
| Page edge (mobile) | `--space-4` |
| Page edge (desktop) | `--space-8` |

### What NOT to use

| Avoid | Use instead |
|---|---|
| `margin-top` on generic elements | Layout gap (`gap`, `space-y`) |
| Arbitrary values (`17px`, `13px`) | Nearest token |
| Negative margins for layout | Flex/grid layout with proper alignment |
| Nested spacers (div for spacing) | Gap on parent |
| Different padding for same-level siblings | Same token for same role |

## The Alignment Audit

For every component group, verify:

- [ ] Labels right-aligned? → Left-align (faster scanning).
- [ ] Icons and text in same row? → `align-items: center; display: flex`.
- [ ] Multiple cards same height? → `display: grid; grid-auto-rows: 1fr` or explicit height.
- [ ] Button text centered? → Check `justify-content: center` on button.
- [ ] Modal centered in viewport? → `place-items: center` on overlay.

### Text alignment

| Content | Alignment |
|---|---|
| Body text | Left (LTR) / Right (RTL) |
| Numbers (tables) | Right (align by decimal) |
| Numbers (inline) | Left (natural reading flow) |
| Headings | Left (default), Center (hero sections only) |
| Buttons | Center |
| Labels | Left (above input) or leading-aligned (side label) |
| Error messages | Left, below the field |

## Border Radius Guidelines

| Element | Token | Example |
|---|---|---|
| Buttons, inputs | `--radius-sm: 6px` | Forms, search bars |
| Cards, modals, dropdowns | `--radius-md: 8px` | Content containers |
| Chips, badges, tags | `--radius-sm: 6px` | Small inline elements |
| Pill tabs, P0 badges | `--radius-full: 9999px` | Semantic badges only |
| Avatars | `--radius-full: 9999px` | Round |
| Sheets, mobile modals | `--radius-lg: 12px` | Top corners only |

**Avoid:** Varying radius on similar elements. `border-radius: 12px` on one card and `8px` on another in the same context.

## Shadow Guidelines

| Level | Token | Usage |
|---|---|---|
| None | `--shadow-none` | Flat cards, pressed buttons |
| Subtle | `--shadow-sm` | Cards on flat surfaces |
| Medium | `--shadow-md` | Dropdowns, elevated cards |
| High | `--shadow-lg` | Modals, floating actions |
| Peek | `--shadow-xl` | Drawers, sheets, toasts |

### When to use shadow

| Element | Shadow | Why |
|---|---|---|
| Card on colored bg | Yes | Creates surface separation |
| Card on white bg | None | Flat cards look intentional |
| Dropdown menu | Yes | Creates depth hierarchy over content |
| Input field | None (inset border) | Shadow on input looks dated |
| Modal backdrop | `--shadow-xl` on modal + semi-transparent overlay | Focus on content |
| Toast notification | Yes | Floating above all content |
| Button (default) | None | Flat buttons are modern |
| Button (hover) | `--shadow-sm` | Elevate on hover |

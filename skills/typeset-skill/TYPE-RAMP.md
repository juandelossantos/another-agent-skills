# Typeset — Type Ramp

**A production type scale with sizes, weights, line-heights, and usage rules.**

## The Scale

```css
/* Headings */
--text-4xl: clamp(2.25rem, 4vw, 3rem);     /* 36px–48px */
--text-3xl: clamp(1.875rem, 3vw, 2.25rem);  /* 30px–36px */
--text-2xl: clamp(1.5rem, 2.5vw, 1.875rem); /* 24px–30px */
--text-xl:  clamp(1.25rem, 2vw, 1.5rem);    /* 20px–24px */

/* Body */
--text-lg:   1.125rem;  /* 18px */
--text-base: 1rem;      /* 16px */
--text-sm:   0.875rem;  /* 14px */
--text-xs:   0.75rem;   /* 12px */

/* Display (rarely used — only for large hero headings) */
--text-display: clamp(3rem, 6vw, 4.5rem); /* 48px–72px */
```

### Weight map

| Token | Usage | Weight |
|---|---|---|
| `--text-4xl` | H1 | 700 (bold) |
| `--text-3xl` | H2 | 700 (bold) |
| `--text-2xl` | H3 | 600 (semibold) |
| `--text-xl`  | H4 | 600 (semibold) |
| `--text-lg`  | Large body, subtitle | 500 or 400 |
| `--text-base` | Body | 400 |
| `--text-sm` | Secondary, labels | 400 or 500 |
| `--text-xs` | Captions, timestamps | 400 |

### Line-height map

| Size | Line-height | Rule |
|---|---|---|
| Display, H1–H2 | 1.1 | Tight — headings should read as blocks |
| H3–H4 | 1.25 | Moderate |
| Body (lg, base) | 1.5 | Comfortable — standard for long text |
| Small, XS | 1.4 | Slightly tighter — short text needs less leading |

## Reading Width

```
Max line-length: 70–80 characters per line.
```

```css
p, .prose {
  max-width: 70ch;    /* for body text */
  /* or */
  max-width: 80ch;    /* for prose/long-form content */
}
```

Without it, 1440px screens will display 200-character lines — unreadable.

## Mixing Sizes

### Correct
- H1 + body (one step gap)
- H2 + body
- H3 + body
- Section subtitle (lg/sm) + body

### Incorrect
- H1 + H3 on the same page (too much gap — use H1 + H2, or H2 + body)
- Display + body (too much contrast — use display + lg or display + xl)
- xs + xl without base in between (hierarchy jumps)

## Fluid Typography

Use `clamp()` for heading sizes to avoid manual breakpoint overrides:

```css
/* Mobile: 30px, Desktop: 36px */
--text-3xl: clamp(1.875rem, 3vw, 2.25rem);

/* Mobile: 36px, Desktop: 48px */
--text-4xl: clamp(2.25rem, 4vw, 3rem);
```

Body sizes (`--text-base`, `--text-sm`) don't need clamping — they should stay fixed for readability.

## Font Selection by Role

| Role | Recommended | Avoid |
|---|---|---|
| Headings | Sans-serif, geometric (Inter, SF Pro, Plus Jakarta Sans) | Serif for digital products |
| Body text | Sans-serif, humanist (Inter, System UI, Roboto) | Thin weights (< 300 on light bg) |
| Code / data | Monospace (JetBrains Mono, SF Mono, Fira Code) | Sans-serif for code blocks |
| Long-form reading | Serif or variable (Merriweather, Literata) | Thin weights, tight line-height |

## Dark Mode Typography

| Property | Light | Dark |
|---|---|---|
| Font weight (body) | 400 | 350–400 (light text on dark bg appears heavier) |
| Font weight (heading) | 700 | 650–700 |
| Text color | `#111827` (gray-900) | `#F3F4F6` (gray-100) |
| Secondary text | `#6B7280` (gray-500) | `#9CA3AF` (gray-400) |

# Typeset — Rhythm Guide

**Vertical rhythm is the grid of text. Without it, paragraph spacing looks random.**

## The Baseline Grid

```css
:root {
  --baseline: 4px;    /* fundamental unit */
  --rhythm: 1.5rem;   /* 24px — single body text line height */
}
```

Every text element's total height should be a multiple of `--rhythm`:

```css
/* H1: 3 lines of rhythm = 72px */
h1 {
  font-size: 2.25rem;  /* 36px */
  line-height: 1.1;    /* ~40px → rounds up to 48px = 2× rhythm */
  margin-block: 1.5rem 0.75rem; /* top: 24px, bottom: 12px */
  /* Total: 48 + 24 + 12 = 84px = 3.5× rhythm */
}

/* Body: 1 line of rhythm */
p {
  font-size: 1rem;
  line-height: 1.5; /* 24px = 1× rhythm */
  margin-block: 0;
}

/* Between paragraphs: 1× rhythm */
p + p {
  margin-block-start: 1.5rem;
}
```

## Section Spacing

| Transition | Space (rhythm units) |
|---|---|
| H1 → body | 1 × rhythm (24px) |
| H2 → body | 0.75 × rhythm (18px) |
| H3 → body | 0.5 × rhythm (12px) |
| Section A → Section B | 3 × rhythm (72px) |
| Subsection → Subsection | 2 × rhythm (48px) |
| Caption → body | 0.25 × rhythm (6px) |
| Image → caption | 0.25 × rhythm |

## Solving Collapsing Margins

If using margin-based spacing, top margins collapse between elements. Two strategies:

### Strategy A: CSS Gap (preferred for flex/grid)

```css
.prose {
  display: flex;
  flex-direction: column;
  gap: 1.5rem; /* consistent space between all children */
}
```

No margin collapse issues. But: gap doesn't collapse at section boundaries — you need explicit section spacing.

### Strategy B: Margin (lobotomized owl)

```css
.prose > * + * {
  margin-block-start: 1.5rem;
}
```

Works well for uniform spacing. For section breaks, use:

```css
.prose > section {
  margin-block-start: 4.5rem; /* 3× rhythm */
}
```

## Vertical Rhythm Checklist

- [ ] Body text line-height is exactly 1.5× font-size
- [ ] Paragraph to paragraph = exactly 1 line-height
- [ ] H2 to body = roughly 1 line-height (not 0, not 2)
- [ ] No random margins on individual elements (use consistent token)
- [ ] Lists inside body text preserve rhythm
- [ ] Blockquotes, code blocks, and callouts stay on rhythm
- [ ] Images maintain rhythm (check that the space above/below equals paragraph gap)
- [ ] H1 at page top has negative margin or no top margin (flush with page chrome)

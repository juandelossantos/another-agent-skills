# Adapt — Breakpoint Matrix

**Design at every width, not just one.**

## The Breakpoint System

```css
--bp-sm:  360px;   /* Small mobile */
--bp-md:  768px;   /* Tablet */
--bp-lg:  1024px;  /* Desktop */
--bp-xl:  1440px;  /* Wide desktop */
```

### CSS pattern

```css
/* Mobile-first: base styles = small mobile */
.component { display: flex; flex-direction: column; gap: 1rem; }

/* Tablet: two-column layout */
@media (width >= 768px) {
  .component { flex-direction: row; }
}

/* Desktop: three-column layout */
@media (width >= 1024px) {
  .component { display: grid; grid-template-columns: repeat(3, 1fr); }
}
```

**Never use `max-width` breakpoints.** Mobile-first means `min-width` only.

## Layout Behavior Per Breakpoint

| Element | 360px | 768px | 1024px | 1440px+ |
|---|---|---|---|---|
| **Navigation** | Hamburger menu | Hamburger or collapsed top bar | Full horizontal nav | Full nav + secondary links |
| **Sidebar** | Hidden (overlay when toggled) | Overlay or slim rail | Visible alongside content | Visible, wider |
| **Content grid** | 1 column | 2 columns (50/50 or 60/40) | 3 columns or main + sidebar | Main + sidebar, max-width container |
| **Cards** | Stacked | 2 columns | 3 columns | 4 columns or 3 with larger cards |
| **Tables** | Horizontal scroll or card layout | Horizontal scroll | Full table visible | Full table + sticky header |
| **Images** | 100% width, auto height | Full width within column | Responsive srcset | HD srcset |
| **Typography** | clamp() adjusts H sizes | clamp() adjusts H sizes | Max display size | Cap at 80ch line length |
| **Page padding** | 16px | 24px | 32px | 40px (centered container) |
| **Forms** | Full width, stacked | Two-column groups | Inline labels | Inline + side help |
| **Modals** | Full-screen sheet | Centered, 90% width | Centered, 640px max | Centered, 720px max |

## The "Hamburger" Decision

| If your nav has | Use hamburger at | At width |
|---|---|---|
| 1–4 items | Never (show all) | All widths |
| 5–7 items | 360px–768px | 768px and above: full nav |
| 8+ items | 360px–1024px | 1024px and above: split with "More" dropdown |
| Utility items (profile, settings) | Always collapsed into icon menu | 360px–768px |

## Layout Primitive: Container

```css
.container {
  width: 100%;
  max-width: min(1200px, 100% - 2 * var(--page-padding));
  margin-inline: auto;
}
```

## Testing Matrix

Check every component at:

| Width | Check |
|---|---|
| 360px | Any overflow? Touch targets > 44px? Text readable? |
| 360px with browser chrome | Same checks minus 60px for address bar |
| 768px portrait | Sidebar behavior? Sticky elements overlap? |
| 1024px | Three-column layout? Whitespace balanced? |
| 1440px | Line-length > 80ch? Extreme whitespace? |
| < 360px (foldable, smartwatch) | Graceful degradation — use `min-width` on body |

## Overflow Handling

| Situation | Fix |
|---|---|
| Long words in button | `word-break: break-word` or `text-overflow: ellipsis` |
| Long URLs in text | `overflow-wrap: break-word` |
| Table with many columns | `overflow-x: auto` on wrapper (not on table) |
| Image wider than viewport | `max-width: 100%; height: auto` on all images |
| Code block overflow | `overflow-x: auto` + horizontal scroll indicator |
| Modal taller than viewport | `max-height: 100dvh; overflow-y: auto` |

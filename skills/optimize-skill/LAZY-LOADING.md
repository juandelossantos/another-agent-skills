# Optimize — Lazy Loading Patterns

**Every resource should be lazy by default, critical by exception.**

## Images

### Standard pattern

```html
<img src="hero.webp" fetchpriority="high" alt="Hero" width="1200" height="800">
<img src="thumb-1.webp" loading="lazy" alt="Gallery item 1" width="400" height="300">
<img src="thumb-2.webp" loading="lazy" alt="Gallery item 2" width="400" height="300">
```

Rules:
- Only the hero/LCP image gets `fetchpriority="high"` — and only one per page.
- All other images get `loading="lazy"`.
- Always include `width` and `height` to prevent layout shift.

### Responsive images

```html
<img
  src="photo-400.webp"
  srcset="photo-400.webp 400w, photo-800.webp 800w, photo-1200.webp 1200w"
  sizes="(max-width: 768px) 100vw, (max-width: 1024px) 50vw, 33vw"
  loading="lazy"
  alt="Description"
  width="800" height="600"
>
```

### In `<picture>` for format switching

```html
<picture>
  <source srcset="photo.avif" type="image/avif">
  <source srcset="photo.webp" type="image/webp">
  <img src="photo.jpg" loading="lazy" alt="Description" width="800" height="600">
</picture>
```

## Components / Routes

### Route-based code splitting

```jsx
// React — dynamic import per route
const SettingsPage = lazy(() => import('./pages/Settings'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
```

### Component-level splitting

```jsx
// Only load rich text editor when user clicks "Edit"
const RichEditor = lazy(() => import('./RichEditor'));

function NoteEditor() {
  const [editing, setEditing] = useState(false);
  return (
    <div>
      <button onClick={() => setEditing(true)}>Edit</button>
      {editing && <Suspense fallback={<EditorSkeleton />}>
        <RichEditor />
      </Suspense>}
    </div>
  );
}
```

Split triggers:
- Tab/accordion content not visible on mount
- Modals and dialogs
- Charts, maps, rich text editors
- Comment sections, social widgets
- Heavy markdown renderers (MDX, etc.)

## Intersection Observer for Visibility

```jsx
function LazySection({ children, placeholder }) {
  const ref = useRef(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) { setVisible(true); observer.disconnect(); } },
      { rootMargin: '200px' }
    );
    if (ref.current) observer.observe(ref.current);
    return () => observer.disconnect();
  }, []);

  return <div ref={ref}>{visible ? children : placeholder}</div>;
}
```

Uses: comments, related articles, footer-heavy content.

## Font Loading

```css
/* Inlined in <head> as critical CSS */
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter-var.woff2') format('woff2');
  font-display: swap; /* text visible immediately in fallback font */
  font-weight: 100 900;
}
```

Avoid FOIT (Flash of Invisible Text) by always using `font-display: swap`.

## When NOT to lazy load

| Scenario | Don't lazy load because |
|---|---|
| Above-fold images | LCP will be delayed |
| Navigation icons | Always visible — preload | 
| Logo (in header) | Always visible — Eager load |
| Background images on hero | Part of LCP |
| Critical font files | Causes flash of styled text (swap is acceptable but preload is better) |
| First-route JS | Already loaded on page load — code-split routes, not this one |
| Tiny SVGs/icons | Inline them instead (lazy loading has overhead) |

## Audit for Missing Lazy Loading

```js
// Find images that DON'T have loading="lazy"
document.querySelectorAll('img:not([loading="lazy"]):not([fetchpriority="high"])')
```

If this list contains any image below 1000px from the top of the document, it's a performance issue.

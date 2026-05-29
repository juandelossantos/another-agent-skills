# Delight — Personality Patterns

**Micro-interactions that make the interface feel alive, not mechanical.**

## Loading Feedback

### Skeleton > Spinner

```jsx
<Card>
  <Skeleton height={24} width="60%" />  {/* Simulates title */}
  <Skeleton height={16} width="80%" />  {/* Simulates body line 1 */}
  <Skeleton height={16} width="40%" />  {/* Simulates body line 2 */}
</Card>
```

Skeleton shapes should match the content they replace. A spinner in a card area tells the user nothing about what's coming.

### Progress bars

```css
.loading-bar {
  height: 3px;
  background: linear-gradient(90deg, var(--color-primary), var(--color-accent));
  background-size: 200% 100%;
  animation: loading-sweep 1.5s var(--ease-in-out) infinite;
}

@keyframes loading-sweep {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

## Success Feedback

### Checkmark reveal

```css
.success-check {
  stroke-dasharray: 50;
  stroke-dashoffset: 50;
  animation: drawCheck 400ms var(--ease-spring) forwards;
}

@keyframes drawCheck {
  to { stroke-dashoffset: 0; }
}
```

### When to animate success

| State | Animate? | How |
|---|---|---|
| Form save | Yes | Brief checkmark + "Saved" fade |
| Copy to clipboard | Yes | Checkmark on the icon, revert after 2s |
| API response (non-blocking) | Yes | Checkmark next to the action |
| Navigate after success | Not recommended | Navigate immediately, success shows on next page |

## Error Feedback

### The shake

```css
.error-shake {
  animation: shake 300ms var(--ease-out);
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(4px); }
  50% { transform: translateX(-4px); }
  75% { transform: translateX(2px); }
}
```

Use on: invalid form field, failed submission, authentication error.

### Error inline message

```css
.error-message {
  max-height: 0;
  opacity: 0;
  overflow: hidden;
  transition: max-height 200ms var(--ease-out), opacity 150ms var(--ease-out),
              margin-bottom 200ms var(--ease-out);
}

.error-message.visible {
  max-height: 60px; /* enough for 2 lines */
  opacity: 1;
  margin-bottom: 8px;
}
```

Hover feedback should be subtle on errors — don't scale or elevate error states.

## Empty State Animation

Don't just show the empty state. Animate it in:

```jsx
function EmptyState({ icon, title, description, action }) {
  return (
    <div className="empty-state">
      <div className="empty-state-icon">{icon}</div>
      <h3>{title}</h3>
      <p>{description}</p>
      {action}
    </div>
  );
}
```

```css
.empty-state {
  animation: fadeSlideIn 400ms var(--ease-out) both;
}

.empty-state-icon {
  animation: scaleIn 300ms var(--ease-spring) 100ms both;
}

@keyframes scaleIn {
  from { transform: scale(0); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
```

## Notification / Toast Animation

```css
.toast {
  transform: translateX(120%); /* Start off-screen right */
  transition: transform 400ms var(--ease-out), opacity 300ms var(--ease-out);
}

.toast.visible {
  transform: translateX(0); /* Slide in */
}

.toast.exiting {
  transform: translateX(120%); /* Slide out */
  opacity: 0;
}
```

Stack multiple toasts with `margin-top` based on their index.

## Counter Animation

```jsx
function AnimatedCounter({ value }) {
  const [display, setDisplay] = useState(value);
  const prev = useRef(value);

  useEffect(() => {
    if (value !== prev.current) {
      setDisplay(value);
      prev.current = value;
    }
  }, [value]);

  return (
    <span key={display} className="counter-badge">
      {display}
    </span>
  );
}
```

```css
.counter-badge {
  animation: popIn 300ms var(--ease-spring);
}

@keyframes popIn {
  0% { transform: scale(0); }
  60% { transform: scale(1.15); }
  100% { transform: scale(1); }
}
```

## When Delight Becomes Annoying

| Feedback | Good | Annoying |
|---|---|---|
| Loading | Skeleton with shimmer | Spinner that spins 5s+ |
| Hover | 150ms color change | 500ms delayed bounce |
| Success | Quick checkmark, 2s | Confetti on every save |
| Error | Inline message + shake | Full-page error with sound |
| Empty state | Gentle fade-in | Confetti where data should be |
| Notification | Slide in, auto-dismiss 3s | Stays until clicked + sound |
| Scroll | Smooth 300ms | Parallax + 3s animation per section |
| Counter | Scale pop on badge | Number flip animation for every digit |

## The 1-Second Rule

A micro-interaction should complete within 1 second total:
- Hover: 150ms
- Input focus: 200ms 
- Skeleton: infinite loop (but each cycle ≤ 1.5s)
- Checkmark: 400ms + 1.6s visible = 2s total
- Toast: 400ms in + 3s visible + 300ms out = 3.7s total (exception)

## Audit Checklist for Delight

- [ ] Every actionable element has hover feedback (color, elevation, scale)
- [ ] Every press/tap has active feedback (scale, color)
- [ ] Every input has focus feedback (border, glow, color)
- [ ] Loading states use skeleton, not spinner (except for actions)
- [ ] Success has visible confirmation (checkmark, color flash)
- [ ] Errors show inline with the relevant field (not a toast)
- [ ] Empty states animate in
- [ ] Page transitions feel continuous (not abrupt)
- [ ] Reduced motion respected
- [ ] No animation lasts > 400ms (except skeleton)

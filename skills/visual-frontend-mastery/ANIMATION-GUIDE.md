# Visual Frontend Mastery — Animation Guide

This guide contains the complete Phase 5 Animation System for `visual-frontend-mastery`.

All animations must respect `prefers-reduced-motion`.

---

## Default Pattern (Framer Motion + React)

Use this canonical reveal component:

```tsx
"use client";
import { motion } from "motion/react";

export function Reveal({
  children,
  delay = 0,
}: {
  children: React.ReactNode;
  delay?: number;
}) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{ duration: 0.6, delay, ease: [0.22, 1, 0.36, 1] }}
    >
      {children}
    </motion.div>
  );
}
```

---

## Scroll-Driven Animations (CSS)

For scroll-linked effects without JS overhead, use `animation-timeline`:

```css
@supports (animation-timeline: scroll()) {
  .scroll-reveal {
    animation: fade-up 1ms linear;
    animation-timeline: view();
    animation-range: entry 10% cover 40%;
  }
}
```

---

## Web Animations API (WAAPI)

Use for synchronized, precise JS-controlled animations:

```js
const el = document.querySelector(".target");
const anim = el.animate(
  [{ opacity: 0, transform: "translateY(20px)" },
   { opacity: 1, transform: "translateY(0)" }],
  { duration: 600, easing: "cubic-bezier(0.22, 1, 0.36, 1)", fill: "forwards" }
);
```

---

## Reduced Motion (WCAG 2.3.3)

Every animation MUST respect `prefers-reduced-motion`:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## Motion Rules

- **NEVER** animate `width`, `height`, `top`, `left`, `margin`, or `padding`.
- **ALWAYS** animate `transform` and `opacity` only for 60fps.
- Use `will-change` sparingly and remove after animation.

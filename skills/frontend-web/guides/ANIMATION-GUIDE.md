# Frontend Web — Animation Guide

Canonical skeletons, forbidden patterns, and motion philosophy. All animations must respect `prefers-reduced-motion`.

---

## Philosophy: Motion MUST Be Motivated

Before adding any animation, ask: **"What does this communicate?"**

- Valid: hierarchy (drawing attention), storytelling (revealing in sequence), feedback (acknowledging action), state transition (showing change)
- Invalid: "it looked cool"

If you cannot articulate the reason in one sentence, drop the animation.

**"Motion claimed, motion shown."** If `MOTION_INTENSITY > 4`, the page must actually move. A static page claiming high motion is broken. Conversely, if you cannot ship working motion, drop the dial and ship a clean static page.

---

## 1. Default Pattern: Framer Motion Reveal

Use this for all scroll-entry animations (feature lists, testimonial grids, logo walls):

```tsx
"use client";
import { motion, useReducedMotion } from "motion/react";

export function Reveal({
  children,
  delay = 0,
}: {
  children: React.ReactNode;
  delay?: number;
}) {
  const reduce = useReducedMotion();
  return (
    <motion.div
      initial={reduce ? false : { opacity: 0, y: 24 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true, margin: "-80px" }}
      transition={{
        duration: 0.6,
        delay,
        ease: [0.16, 1, 0.3, 1],
      }}
    >
      {children}
    </motion.div>
  );
}
```

### Staggered variant (for lists and grids):

```tsx
"use client";
import { motion, useReducedMotion } from "motion/react";

export function RevealStagger({ items }: { items: React.ReactNode[] }) {
  const reduce = useReducedMotion();
  return (
    <ul className="grid gap-6">
      {items.map((item, i) => (
        <motion.li
          key={i}
          initial={reduce ? false : { opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, amount: 0.3 }}
          transition={{
            duration: 0.6,
            delay: i * 0.06,
            ease: [0.16, 1, 0.3, 1],
          }}
        >
          {item}
        </motion.li>
      ))}
    </ul>
  );
}
```

---

## 2. Sticky-Stack (GSAP + ScrollTrigger)

Use when `MOTION_INTENSITY > 6` and sections should stack as the user scrolls (card-on-card reveal):

```tsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useReducedMotion } from "motion/react";

gsap.registerPlugin(ScrollTrigger);

export function StickyStack({ cards }: { cards: React.ReactNode[] }) {
  const ref = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce || !ref.current) return;
    const ctx = gsap.context(() => {
      const els = gsap.utils.toArray<HTMLElement>(".stack-card");
      els.forEach((card, i) => {
        if (i === els.length - 1) return;
        ScrollTrigger.create({
          trigger: card,
          start: "top top",
          endTrigger: els[els.length - 1],
          end: "top top",
          pin: true,
          pinSpacing: false,
        });
        gsap.to(card, {
          scale: 0.92,
          opacity: 0.55,
          ease: "none",
          scrollTrigger: {
            trigger: els[i + 1],
            start: "top bottom",
            end: "top top",
            scrub: true,
          },
        });
      });
    }, ref);
    return () => ctx.revert();
  }, [reduce]);

  return (
    <div ref={ref} className="relative">
      {cards.map((card, i) => (
        <div key={i} className="stack-card sticky top-0 min-h-[100dvh] flex items-center justify-center">
          {card}
        </div>
      ))}
    </div>
  );
}
```

**Critical:** `start: "top top"`, every card except the last is pinned, scale/opacity driven by the NEXT card's scroll trigger.

---

## 3. Horizontal-Pan (GSAP + ScrollTrigger)

Use for horizontal scroll-hijack sections (timeline, gallery, portfolio):

```tsx
"use client";
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { useReducedMotion } from "motion/react";

gsap.registerPlugin(ScrollTrigger);

export function HorizontalPan({ children }: { children: React.ReactNode }) {
  const wrap = useRef<HTMLDivElement>(null);
  const track = useRef<HTMLDivElement>(null);
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce || !wrap.current || !track.current) return;
    const ctx = gsap.context(() => {
      const distance = track.current!.scrollWidth - window.innerWidth;
      gsap.to(track.current, {
        x: -distance,
        ease: "none",
        scrollTrigger: {
          trigger: wrap.current,
          start: "top top",
          end: () => `+=${distance}`,
          pin: true,
          scrub: 1,
          invalidateOnRefresh: true,
        },
      });
    }, wrap);
    return () => ctx.revert();
  }, [reduce]);

  return (
    <section ref={wrap} className="relative overflow-hidden">
      <div ref={track} className="flex h-[100dvh] items-center">
        {children}
      </div>
    </section>
  );
}
```

**Critical:** `start: "top top"`, `end: "+=${distance}"`, wrapper is pinned, inner track slides.

---

## 4. Web Animations API (WAAPI)

For synchronized, precise JS-controlled animations that don't need a library:

```js
const el = document.querySelector(".target");
el.animate(
  [{ opacity: 0, transform: "translateY(20px)" },
   { opacity: 1, transform: "translateY(0)" }],
  { duration: 600, easing: "cubic-bezier(0.22, 1, 0.36, 1)", fill: "forwards" }
);
```

---

## 5. Forbidden Animation Patterns

- **`window.addEventListener("scroll", ...)`** — BANNED. Use Motion `useScroll()`, GSAP ScrollTrigger, IntersectionObserver, or CSS `scroll-driven animations`.
- **Custom scroll progress with `window.scrollY` in React state** — BANNED. Re-renders on every frame. Use motion values instead.
- **`requestAnimationFrame` loops touching React state** — BANNED. Use `useMotionValue` + `useTransform`.
- **Animating `top`, `left`, `width`, `height`** — BANNED. Animate only `transform` and `opacity`.
- **`layout` props on static content** — Costs measurement work. Use only for visible state changes.
- **Half-built motion** — BANNED. Never ship broken ScrollTriggers, jumpy enters, or missing cleanups. Drop to static or fix fully.

---

## 6. Reduced Motion (WCAG 2.3.3)

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

In React: wrap with `useReducedMotion()` and degrade to static (as shown in skeletons above).

---

## 7. Motion Rules

- Animate ONLY `transform` and `opacity` for 60fps
- Use `will-change: transform` sparingly — only on actively animating elements
- Spring physics: `type: "spring", stiffness: 100, damping: 20` — no `linear` easing
- GSAP is for full-page scrolltelling only. Not for UI micro-interactions (use Motion)

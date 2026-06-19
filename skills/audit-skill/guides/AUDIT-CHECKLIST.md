# Audit Skill — Checklist

## Accessibility

- [ ] All interactive elements keyboard-navigable (Tab order)
- [ ] Focus indicators visible (`:focus-visible`)
- [ ] Color contrast ≥4.5:1 (text) and ≥3:1 (large text)
- [ ] Images have alt text
- [ ] ARIA labels on non-semantic interactive elements
- [ ] `prefers-reduced-motion` respected
- [ ] Screen reader can navigate all content

## Performance

- [ ] LCP <2.5s
- [ ] FID <100ms / INP <200ms
- [ ] CLS <0.1
- [ ] Bundle size <500KB critical path JS
- [ ] Images lazy-loaded below fold
- [ ] No render-blocking resources
- [ ] Animations at 60fps (no layout thrashing)

## Theming

- [ ] All colors from design tokens (no hardcoded hex)
- [ ] Dark mode colors have sufficient contrast
- [ ] No `bg-blue-500` or similar utility class generics
- [ ] Focus styles visible in both themes
- [ ] System theme preference respected

## Responsive

- [ ] Works at 320px, 768px, 1024px, 1440px
- [ ] No horizontal scroll at any breakpoint
- [ ] Touch targets ≥44×44px
- [ ] Font scales correctly (no mobile overflow)
- [ ] Navigation usable on mobile

## Anti-Patterns

- [ ] No `console.log` in production code
- [ ] No commented-out code
- [ ] No `any` types (TypeScript)
- [ ] No inline styles (except dynamic values)
- [ ] No duplicate imports
- [ ] No unused exports
- [ ] No hardcoded strings (should use i18n or constants)

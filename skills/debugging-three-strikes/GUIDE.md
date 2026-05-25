# 3 Strikes Protocol

**When the same bug is reported 3+ times with different fixes, STOP.**

## Trigger

**Count strikes when:**
- User reports the same visual/behavioral bug after a fix is applied
- Each failed attempt counts as one strike, regardless of approach
- CSS specificity bugs, layout shifts, missing content — any repeat issue

## Protocol

### Strike 1 — Normal fix
Apply best-guess fix. If it works, done.

### Strike 2 — Alternative approach
Try a different angle. If it works, done. If not → **prepare for Strike 3**.

### Strike 3 — STOP. No more fixes.

```
STOP. 3rd strike on this bug.
□ No more speculative fixes.
□ Must diagnose systematically before proposing anything.
```

**Agent must:**
1. **Stop all commits.** No fix code until diagnosis is complete.
2. **Inspect the real state:**
   - Browser DevTools: computed styles, specificity, selector matching
   - Network: are resources loading?
   - Console: any errors?
   - DOM: is the expected element rendered?
3. **Document findings** — what is actually happening vs what was expected
4. **Report to user** before writing any fix code:
   ```
   Root cause: [specificity / selector / missing resource / etc]
   Proposed fix: [one sentence]
   → Proceed with fix?
   ```
5. Only after user confirms, apply the fix.

## Examples

### CSS specificity (background shorthand)
```
Bug: background image not showing after gradient placeholder
Strike 1: Changed padding/height → no effect
Strike 2: Changed position → no effect
Strike 3: STOP → Inspected computed styles → 
  Found: `background` shorthand in #inicio .section__bg 
  overrides `background-size` on .section__bg
  Fix: remove gradient, keep only background-image in section
```

### Missing element not rendering
```
Bug: button not visible on mobile
Strike 1: Changed z-index → no effect
Strike 2: Added display: block → no effect  
Strike 3: STOP → Inspected DOM →
  Found: media query hide rule `display: none` on parent
  Fix: remove parent display:none rule
```

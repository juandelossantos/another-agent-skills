# Convergence Report Example

After implementation, verify the codebase matches the spec:

1. **Check each acceptance criterion** — For every item in SPEC.md Acceptance Criteria, confirm it is true in the running code. PASS or FAIL.
2. **Check for unplanned features** — If code exists that was never in the spec, flag it.
3. **Generate convergence report:**
   ```
   CONVERGENCE REPORT:
     Acceptance criteria: 8/10 PASS, 2/10 FAIL
       FAIL: "LCP < 2.5s on 4G" — measured 3.8s. Needs optimization pass.
       FAIL: "Offline fallback" — not implemented. Spec says P1, built as P2.
     Unplanned features: 1 — "Dark mode toggle" (not in spec, acceptable scope creep)
     → Spec is accurate? Spec needs update? New tasks needed?
   ```
4. If gaps found: create new tasks, feed back through P7 and P2.
5. If clean: Deliver final report. Spec is done until next iteration.

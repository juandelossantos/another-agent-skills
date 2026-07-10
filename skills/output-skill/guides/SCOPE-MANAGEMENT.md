# Scope Management

Track what was promised vs. what was delivered across multi-file outputs.

## Before Writing — Declare Scope

List every file and what it needs before writing any code:

```
SCOPE:
  - src/api/handler.ts  — full REST handler (GET, POST, DELETE)
  - src/types.ts        — type definitions only
  - tests/handler.test.ts — unit tests for all 3 endpoints
```

## After Writing — Verify Delivery

Check off delivered files. If any are missing, state them explicitly:

```
DELIVERED:
  - src/api/handler.ts   — full, runnable
  - src/types.ts         — complete
  - tests/handler.test.ts — NOT delivered
→ Remaining: tests/handler.test.ts
```

## Recovery Patterns

| Situation | Action |
|---|---|
| Mid-function when context limit hits | Complete current function, then state remaining scope |
| All files written but grep finds patterns | Fix all matches before delivering |
| User asks to continue from truncated output | Re-read scope from Phase 1, deliver remaining files completely |
| Cross-file dependency not yet written | Note the dependency explicitly: "Relies on [file] which will be delivered next" |

# Decision Tree Guide

Use this to quickly categorize the error and select the right debugging path.

## What Kind of Error Is It?

```
Error encountered
├── Build/compile fails
│   ├── TypeScript/type error → Check types at the cited location
│   ├── Import/module not found → Check paths, npm install, tsconfig paths
│   ├── Syntax error → Read error line, check brackets/semicolons
│   ├── Config error → Check next.config, vite.config, tsconfig, etc.
│   └── Dependency error → npm install, check peer dependencies
│
├── Test fails
│   ├── After your code change → You broke it. Check what you changed.
│   ├── Unrelated test fails → Side effect. Check shared state, imports.
│   ├── Flaky test → Timing, order, or external dependency issue.
│   └── Test was already failing → Pre-existing. Fix or skip with ticket.
│
├── Runtime error
│   ├── TypeError: Cannot read property of undefined
│   │   └── Null/undefined flow. Trace data from source to usage.
│   ├── Network/CORS error
│   │   └── Check URLs, headers, server config. Use browser DevTools Network tab.
│   ├── Render error / White screen
│   │   └── Check error boundary, console, component tree hierarchy.
│   └── Unexpected behavior (no error thrown)
│       └── Add logging at key points. Verify data at each step.
│
├── Performance issue
│   ├── Slow render → Check React DevTools profiler, unnecessary re-renders
│   ├── Slow API → Check query performance, N+1 queries, missing indexes
│   ├── Memory leak → Check event listeners, subscriptions, intervals not cleaned
│   └── Bundle too large → Check bundle analyzer, tree shaking, code splitting
│
└── Environment-specific
    ├── Works locally, fails in CI → Environment difference. Check env vars, versions.
    ├── Works in one browser → Browser compatibility. Check caniuse, polyfills.
    ├── Works in dev, fails in prod → Build difference. Check minification, env vars.
    └── Works sometimes → Race condition or timing issue. Add synchronization.
```

## Quick Triage Commands

```bash
# Build health
npm run build 2>&1 | tail -20

# Test health
npm test -- --verbose 2>&1 | tail -30

# Type check
npx tsc --noEmit 2>&1 | head -20

# Lint
npm run lint 2>&1 | head -20

# Git state
git status && git diff --stat

# Recent changes
git log --oneline -10
```

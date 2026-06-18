---
name: debugging-three-strikes
description: >
  Stop speculative debugging when the same bug comes back 3 times.
  After 3 strikes, diagnose systematically before writing any fix code.
  Use when repetitive fixes fail. Pairs with debugging-and-error-recovery.
version: 1.0.0
license: MIT
compatibility: opencode
allowed-tools: Read Bash
tier: action-allowed
metadata:
  audience: engineers
  workflow: diagnose-stabilize
---

# 3 Strikes Protocol

**When the same bug is reported 3+ times with different fixes, STOP.**

No more guessing. Inspect the real state (DevTools, network, DOM). Report findings to user before writing fix code.

→ See `GUIDE.md` for full protocol, triggers, and examples.

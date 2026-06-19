---
name: debugging-three-strikes
description: Stop speculative debugging after 3 same-bug strikes. Diagnose systematically before writing code. Use when repetitive fixes fail. Do NOT use for first-time bugs.
version: 1.0.0
license: MIT
compatibility: all
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

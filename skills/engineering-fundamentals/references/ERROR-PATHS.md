# Error Path Design

Inspired by Harness Books (Chapter 9, Principle 9.6): "Error paths are main paths."

## Failure Path Matrix

Every tool call, gate, loop, and session needs a failure path:

| Component | Failure → Response |
|---|---|
| Tool call | Fail → return as observation |
| Pre-commit gate | Block → bypass with human approval |
| Debug loop | 3 strikes → escalate to user |
| Session | Context loss → continue (Rule 0i) |
| Verification | Can't reach world → "ship status unknown" (Rule 0h) |

## Anti-Patterns

- "It'll probably work" (hope, not workflow)
- "Just retry" (noise, not diagnosis)

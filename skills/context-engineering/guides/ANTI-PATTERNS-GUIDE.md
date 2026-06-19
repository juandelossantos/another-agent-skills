# Context Engineering — Anti-Patterns

## Common Mistakes

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Context starvation | Agent invents APIs, ignores conventions | Load rules file + relevant source files |
| Context flooding | Agent loses focus with >5000 lines of non-task context | Aim for <2000 lines of focused context |
| Stale context | Agent references deleted code | Start fresh sessions when context drifts |
| Silent confusion | Agent guesses when it should ask | Surface ambiguity explicitly |
| Recap after restart | Wastes tokens re-explaining known state | Ask "Where were we?" — continue, don't recap |

## Rationalizations

| Rationalization | Reality |
|---|---|
| "Agent should figure out conventions" | It can't read your mind. Write a rules file. |
| "I'll correct it when it goes wrong" | Prevention is cheaper than correction. |
| "More context is always better" | Research shows performance degrades with too much. Be selective. |
| "Context window is huge, use it all" | Window size ≠ attention budget. Focused wins. |

## Red Flags

- Agent output doesn't match project conventions
- Agent invents APIs or imports that don't exist
- Agent re-implements existing utilities
- Agent quality degrades as conversation grows
- No rules file in the project

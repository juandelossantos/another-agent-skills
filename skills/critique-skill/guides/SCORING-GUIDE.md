# Critique — Scoring Guide

## Nielsen's 10 Heuristics (Score 0-4)

| # | Heuristic | 0-1 (Fail) | 2 (Passable) | 3 (Good) | 4 (Excellent) |
|---|---|---|---|---|---|
| 1 | **Visibility of status** | No feedback after actions. User guesses if something happened. | Basic feedback exists but delayed or unclear. | Immediate feedback on all actions. Progress indicators. | Proactive status. Next steps anticipated. Undo visible. |
| 2 | **Match real world** | Technical jargon. Abstract icons. Metaphors that don't map. | Some familiar conventions mixed with abstract ones. | Clear metaphors. Natural language. Familiar icons. | Speaks user's domain language precisely. |
| 3 | **User control & freedom** | No undo. Accidental actions are permanent. | Undo exists but hidden or incomplete. | Undo/redo on all actions. Exit points visible. | Emergency exits everywhere. Accidental actions reversible in 1 click. |
| 4 | **Consistency & standards** | Inconsistent buttons, colors, icons. Breaks platform conventions. | Mostly consistent with occasional drift. | Follows platform conventions. Internal consistency. | Predictable everywhere. User can transfer knowledge across screens. |
| 5 | **Error prevention** | Errors common. No validation before submit. Destructive actions without confirmation. | Some validation but incomplete. Confirmations on major actions. | Inline validation. Constraint inputs. Prevents errors before they happen. | Error impossible in common paths. System anticipates and prevents mistakes. |
| 6 | **Recognition over recall** | User must remember info across steps. No defaults. No suggestions. | Some recognition support but incomplete. | Autocomplete, suggestions, recent items. Options visible. | Zero recall required. Everything is visible or suggested. |
| 7 | **Flexibility & efficiency** | One slow path for everyone. No shortcuts. No power user features. | Basic shortcuts exist but limited. | Keyboard shortcuts, bulk actions, recent actions. | Expert mode, programmable, macros. Novice and expert paths. |
| 8 | **Aesthetic & minimalist design** | Cluttered. Irrelevant info. Decorative elements that add no value. | Some visual noise but functional. | Clean. Every element serves a purpose. Good hierarchy. | Minimal. Elegant. Nothing extra. Information is the interface. |
| 9 | **Help users recognize errors** | "Error" or "Invalid input." No explanation. No fix suggestion. | Error message exists but vague. | Clear error: what, why, how to fix. | Errors prevented, but when they happen: plain language, exact fix, one-click resolution. |
| 10 | **Help & documentation** | No help. Or help is a wall of text. | Help exists but hard to find. | Contextual help. Searchable. Concise. | Help is anticipatory. Shows up when needed. Disappears when not. |

## Cognitive Load (8 Failure Modes)

| # | Failure Mode | What to check |
|---|---|---|
| 1 | **Visual noise** | Unnecessary borders, colors, icons, animations. Elements competing for attention. |
| 2 | **Split attention** | User must look in two places to complete one task. Disconnected labels and inputs. |
| 3 | **Redundant information** | Same data shown in multiple formats. Conflicting status indicators. |
| 4 | **Complex choices** | Too many options without hierarchy. No recommended path. |
| 5 | **Hidden actions** | Actions only available through hover, long-press, or obscure gestures. |
| 6 | **Inconsistent patterns** | Same action in different places behaves differently. Same element looks different. |
| 7 | **Memory burden** | User must hold information in working memory across steps. No visible summary. |
| 8 | **Task complexity** | A single task requires too many steps. No progressive disclosure. |

## Scoring Rubric

| Dimension | Weight | How to score |
|---|---|---|
| Heuristics | Primary | Average of 10 scores. Multiply by context importance. |
| Cognitive load | Secondary | Count failures. 0-2 = low, 3-5 = medium, 6-8 = high. |
| Personas | Secondary | Average of 4 persona scores. See `PERSONAS.md`. |

Combine: `Final score = (heuristics_avg × 0.6) + (personas_avg × 0.4)`

Then apply cognitive load as a modifier: ≥4 failures → -0.5 from final.

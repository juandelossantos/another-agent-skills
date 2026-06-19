# Skill Creator — Eval Case Guide

## Case Types

| Type | Purpose | Count |
|---|---|---|
| trigger positive | Input SHOULD activate this skill | 2 |
| trigger negative | Input should NOT activate this skill | 1 |
| golden | Known input → expected output | 2 |
| adversarial | Edge cases, rephrasings, boundaries | 2 |

## Format

Each case is a JSON line:
```json
{
  "case_id": "trigger_positive_001",
  "description": "User asks about [topic]",
  "input": "What is [topic]?",
  "expected_skill": "skill-name",
  "expected_output_format": "format",
  "rubric": ["condition 1", "condition 2"],
  "type": "trigger_positive"
}
```

## Quality Criteria

- Each trigger case tests ONE distinct trigger scenario
- Negative cases are realistic close-calls (similar but wrong context)
- Golden cases include rubric for scoring output quality
- Adversarial cases test rephrasings, boundary inputs, and edge cases

# ADR-009: Placeholder detection must skip code blocks and require marker colons

**Status:** Proposed
**Date:** 2026-07-02

## Context

The audit engine placeholder check matched bare words (TODO, FIXME, placeholder, lorem ipsum) anywhere in .md files. This produced 33 false positives across 20 files in another-agent-skills, all in documentation that DISCUSSES placeholders as a concept (anti-slop guides, skill descriptions, glossary entries), not actual placeholder content. Signal-to-noise ratio was 0 percent real findings.

## Decision

Two precision fixes: (1) Skip placeholder matches inside fenced code blocks (triple-backtick delimiters) because TODOs in code examples are illustrations, not task markers. (2) Require colons for TODO/FIXME markers (TODO: and FIXME:) and remove bare placeholder from the pattern because the word placeholder is a legitimate technical term in prose, not a filler marker. Keep lorem ipsum, coming soon, under construction, and XXX as standalone patterns.

## Consequences

WARN count on this repo dropped from 34 to 3 (88 percent false-positive reduction). The 3 residuals are TODO: and FIXME: inside inline code (backticks) and lorem ipsum in prose, edge cases accepted as known limitations. Golden baseline updated from 34 to 3. Future audits will have usable signal instead of noise.

## Compliance

Verified by tests/audit/universal.sh: t_placeholder_codeblock_exempt, t_placeholder_real_flagged, t_placeholder_prose_exempt. All 12 engine tests plus 3 wrapper-contract tests pass. Pre-commit chain green.

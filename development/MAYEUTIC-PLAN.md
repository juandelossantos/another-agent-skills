# Mayéutic Challenge Enforcement + Skill Improvements

**Branch:** feat/mayeutic-enforcement
**Date:** 2026-06-04
**Status:** Phase 1 complete
**Inspired by:** Sub-Zero, Code Review Skill, Harness Books, AtomCode, Self-Improving Skills article

---

## Current State

- 41 skills, 51 doc pages, EN/ES bilingual
- Git hooks: pre-commit v7, commit-msg v4, manifest gate
- task-manifest.sh: Phase 1 complete ✓

## Implementation Plan

### Phase 1: task-manifest.sh ✓
- Script verifies manifest exists and has minimum content
- Checks 4 required fields (Files affected, Edge cases, Alternatives, Risks)

### Phase 2: Update AGENTS.md
- Add mandatory manifest requirement before execution
- Reference task-manifest.sh in the workflow

### Phase 3: Update SOUL.md
- Add enforcement note about Mayéutic Challenge
- Document that this is a behavioral gate, not a git hook

### Phase 4: Update docs/philosophy.html
- Add honest limitations section
- Explain what can and cannot be enforced mechanically

### Phase 5: Test and verify
- Test task-manifest.sh in all scenarios
- Verify integration with existing workflow

### Phase 6: Add evals.md to key skills
- test-driven-development: evals for test quality
- code-review-and-quality: evals for review quality
- spec-driven-development: evals for spec completeness

### Phase 7: Add memory.md to debugging skill
- debugging-and-error-recovery: memory for past bugs and patterns

### Phase 8: Update docs with article insights
- docs/philosophy.html: reference eval loop as practical Mayéutic implementation
- docs/customization.html: explain evals.md and memory.md concepts

## Token/Memory/Context Management

### Token Budget
- Always-loaded: 270 lines (~4,070 tokens, 1.9% of 200K)
- Lazy loading: Skills as ~250-line indexes, guides on-demand
- Auto-eviction at 70% context usage

### Context Architecture
- Level 1: Rules files (AGENTS.md, SOUL.md) — always loaded
- Level 2: Spec/Architecture docs — loaded per feature
- Level 3: Relevant source files — loaded per task
- Level 4: Error output — loaded per iteration
- Level 5: Conversation history — accumulates, compacts

### Memory Management
- Session context persisted via .sessionrc
- Incident docs track failures and lessons
- Health check detects drift and context rot
- Continuation over recap: resume from last verified state

## Decision Log

| Date | Decision | Rationale |
|---|---|---|
| 2026-06-04 | task-manifest.sh created | Behavioral gate for Mayéutic Challenge |
| 2026-06-04 | Added evals/memory from article | Self-improving skills through evaluation |
| 2026-06-04 | 8-phase plan | Comprehensive approach to enforcement + improvements |

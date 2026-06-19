---
name: source-driven-development
description: Ground every implementation decision in official documentation before writing code. Use when building with any framework where correctness matters. Do NOT use for experimental or throwaway code.
  Do NOT use for general programming logic or pure algorithm work.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: research-implement
---

# Source-Driven Development

**Authoritative, source-cited code free from outdated patterns.**

Before implementing with a framework or library, verify API syntax, configuration, and patterns against official documentation. Prevents the common failure mode of relying on training data that may reflect older versions.

## When to Use

- Using any framework, library, SDK, or API
- Implementing against a documented interface
- Migrating between versions of a dependency
- Any time correctness of API usage matters

## When NOT to Use

- Pure algorithm or data structure implementation
- Business logic with no external dependency
- Creative or design work

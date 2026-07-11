---
name: source-driven-development
description: "Ground every implementation decision in official documentation before writing code. Use when building with any framework where correctness matters. Do NOT use for experimental or throwaway code."
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

> **Sources:** GitHub API Versioning (docs.github.com/en/rest) — breaking change categories, changelog-first updates, version lifecycle. npm Docs (docs.npmjs.com) — `npm view` for package version verification. Twelve-Factor App (12factor.net) — explicit dependency declaration. FINOS CALM (finos/architecture-as-code) — documentation versioning via CLI validation. SDD Plugin — spec-driven agent workflow patterns.

## When to Use

- Using any framework, library, SDK, or API
- Implementing against a documented interface
- Migrating between versions of a dependency
- Any time correctness of API usage matters
- Using a new dependency for the first time (verify API surface before writing code)
- Upgrading a major version of a dependency (breaking changes expected — verify against new docs, not old knowledge)

## Output Contract

Source-cited implementation code — source files (any language, any framework) in existing source tree, with every API function/parameter verified against official documentation, dependency versions pinned, freshness check performed (changelog + publication date), no deprecated APIs used, re-verified after implementation against the same source, dependencies explicitly declared per Twelve-Factor App.

## When NOT to Use

- Pure algorithm or data structure implementation
- Business logic with no external dependency
- Creative or design work

## Verification Workflow

```text
1. FIND → Locate the official documentation (framework docs, API spec, registry)
2. VERIFY → Check version, changelog, publication date against your requirements
3. IMPLEMENT → Code against the verified API surface
4. RE-VERIFY → After implementation, check that your usage matches documentation
```

### Step 1: Find Official Documentation

The official source is the framework's own documentation, the package registry, or the API specification. Unofficial sources (blog posts, Stack Overflow, AI training data) may reflect outdated versions.

### Step 2: Verify Freshness

Check that the documentation matches the version you intend to use. A blog post about v2.0 has no authority over v3.0 behavior. See `guides/FRESHNESS-CHECKS.md` for version verification patterns using `npm view`, changelog analysis, and publication date checks.

### Step 3: Implement Against Verified API

Code using only the documented API surface. If the documentation doesn't mention a parameter, it doesn't exist — even if training data suggests otherwise.

### Step 4: Re-Verify After Implementation

Run `npm view <package>` (or equivalent for your ecosystem) to confirm your dependency versions match what you coded against. Check that no deprecation warnings appear in the latest docs.

## Doc Freshness Heuristics

| Check | What to Look For | Tool/Source |
|---|---|---|
| Version date | Documentation matches your target version | Package registry, changelog |
| Changelog activity | Recent releases = actively maintained | CHANGELOG.md, GitHub releases |
| Deprecation notices | Marked as deprecated in current version | Official docs, Deprecation header |
| Breaking changes | Listed in changelog for the version jump | Semantic version comparison |

## API Surface Verification

Verify every API function, parameter, and return type against the docs. If your training data suggests an API that doesn't exist in the docs, the training data is wrong — trust the docs.

See `guides/DOC-VERIFICATION-PATTERNS.md` for verification templates.

## Anti-Patterns

1. **Trusting training data** — AI training data is always stale for actively maintained libraries. Always check the docs.
2. **Blog post as source** — A blog post about v2.0 has no authority over v3.0 behavior.
3. **No version pinning** — Using `latest` without verifying what version that resolves to.
4. **Assuming backward compatibility** — "It should work with the new version" without checking the changelog.
5. **Skipping the docs** — "I know this API" without verifying against current documentation.
6. **One-source dependency** — Depending on a single package without verifying its maintenance status.

## Verification

- [ ] Official documentation found and loaded (not blog posts, not training data)
- [ ] Version verified against your target (via registry, changelog, or docs metadata)
- [ ] API surface checked: every function/parameter used exists in the docs
- [ ] No deprecated APIs used (check Deprecation headers, changelog)
- [ ] Dependencies explicitly declared (per 12factor.net principle)
- [ ] After implementation, re-verify against the same source

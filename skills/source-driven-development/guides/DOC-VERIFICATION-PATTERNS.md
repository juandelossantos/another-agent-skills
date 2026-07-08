# Documentation Verification Patterns

> **Sources:** GitHub API Versioning (docs.github.com/en/rest) — changelog verification, API surface testing. npm Docs (docs.npmjs.com) — `npm view` for registry verification. FINOS CALM (finos/architecture-as-code) — documentation validation via CLI. MDN Web Docs (developer.mozilla.org) — comprehensive API reference as the standard for documentation quality.

## Pattern 1: Registry Verification

Verify package existence and version directly from the ecosystem registry:

```bash
# npm — check package metadata
npm view <package> versions        # All available versions
npm view <package> time            # Publication dates per version
npm view <package> dependencies    # Dependency tree

# PyPI — check package info
pip index versions <package>       # Available versions

# Cargo — check crate info
cargo search <crate>               # Latest version
```

Before using a new version, always check that it exists and is not deprecated.

## Pattern 2: Changelog Analysis

Find and read the changelog before upgrading:

```markdown
1. Locate CHANGELOG.md or GitHub Releases page
2. Check the section for your target version
3. Look for:
   - BREAKING CHANGES header
   - Deprecated features listed
   - Migration notes
4. If no changelog exists, check the commit log between versions
```

If a package has no changelog and no release notes, treat any version upgrade as potentially breaking.

## Pattern 3: API Surface Comparison

Compare the documented API against what you're using:

```text
Function you want to call:    createOrder({ items, customer })
Check in docs:
  ✅ createOrder exists
  ✅ items parameter exists
  ❌ customer parameter does NOT exist in docs
  → Find the correct parameter name from the docs
```

If the documentation doesn't show a parameter or function you expect from training data, the training data is wrong.

## Pattern 4: Deprecation Header Check

When making API calls, check response headers for deprecation warnings:

```text
HTTP Response Headers:
  Deprecation: true
  Sunset: Sat, 1 Nov 2027 00:00:00 GMT
  Link: </api/v2/orders>; rel="successor-version"

→ This API version is deprecated. Plan migration to v2.
```

## Pattern 5: Documentation-as-Code Validation

For projects that treat documentation as code (FINOS CALM, Sphinx-Needs), validate documentation the same way you validate code:

```bash
# CALM — validate architecture documentation
calm validate my-architecture.json

# Sphinx-Needs — validate requirement traceability
sphinx-build -b needs docs/ build/
```

This ensures documentation is internally consistent and references resolve correctly.

## Pattern 6: Cross-Reference Multiple Sources

When official documentation is unclear, cross-reference with:

1. The framework's own examples repository
2. The type definitions (TypeScript `.d.ts`, Protobuf, OpenAPI spec)
3. The source code of the library itself (last resort)

Each level is less authoritative but can clarify ambiguity.

## Quick Reference

| Verification Need | Tool/Action |
|---|---|
| Check package version | `npm view <pkg> versions` |
| Check what changed between versions | Changelog, GitHub Releases compare |
| Check if API exists in docs | Search official docs, not Google |
| Check if a feature is deprecated | `Deprecation` response header |
| Check dependency health | GitHub commits, release frequency, open issues |

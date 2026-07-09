# Freshness Checks

> **Sources:** GitHub API Versioning (docs.github.com/en/rest) — version lifecycle, support windows. npm Docs (docs.npmjs.com) — `npm view time` for publication dates. Twelve-Factor App (12factor.net) — explicit dependency declaration, version pinning. Semantic Versioning 2.0 (semver.org) — breaking change interpretation.

## Why Freshness Matters

A library's API can change between versions. Documentation from one version has no authority over another. Before writing code against an API, confirm that the documentation matches the version you're targeting.

## Version Verification

### Check Publication Dates

```bash
# npm — view publication dates per version
npm view <package> time

# Example output:
# { '1.0.0': '2024-01-15T10:00:00.000Z',
#   '2.0.0': '2025-06-20T14:30:00.000Z',
#   '3.0.0': '2026-03-10T09:00:00.000Z' }

# A version published 2 years ago may have outdated APIs.
# The LATEST version is the one you should target.
```

### Compare Against Changelog

```text
Current version: 2.0.0
Target version: 3.0.0

Changelog for 3.0.0:
  - BREAKING: createOrder() now requires items array
    (was: comma-separated string)
  - DEPRECATED: processRefund() — use refund() instead
  - ADDED: batchCreateOrders() for bulk operations

→ Your existing 2.0.0 code WILL break on 3.0.0
→ Your training data about 2.0.0 APIs is NOT valid for 3.0.0
```

## Semantic Version Interpretation

| Version Bump | Meaning | Action Required |
|---|---|---|
| Patch (1.0.0 → 1.0.1) | Bug fix, no API change | Safe to upgrade |
| Minor (1.0.0 → 1.1.0) | New feature, no breaking change | Safe to upgrade |
| Major (1.0.0 → 2.0.0) | Breaking API change | Check changelog before upgrading |

From semver.org: MAJOR version increments indicate incompatible API changes.

## Version Pinning

Per Twelve-Factor App principles, dependencies must be explicitly declared and version-pinned:

```json
// GOOD: explicit version
"dependencies": { "express": "4.18.2" }

// BAD: implicit latest
"dependencies": { "express": "*" }

// BAD: broad range
"dependencies": { "express": "^4.0.0" }
```

Pin to the exact version you've verified against the docs.

## Deprecation Detection

### In API Responses

```text
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 1 Nov 2027 00:00:00 GMT
```

A `Deprecation: true` header means the version you're using will stop working.

### In Documentation

Look for these markers in official docs:
- **Deprecated** badge or tag on functions/parameters
- "This feature is deprecated" warning boxes
- Sunset dates mentioned in changelogs
- Migration guides pointing to alternative APIs

## Maintenance Health Check

| Indicator | Healthy | Warning | Dead |
|---|---|---|---|
| Last release | < 6 months | 6-12 months | > 2 years |
| Commits last month | > 10 | 1-10 | 0 |
| Open issues | < 100 | 100-500 | > 500 (unaddressed) |
| Response to issues | Within days | Within weeks | No response |

A dependency with no commits in 2 years and >500 open issues is not a reliable source to code against.

## Anti-Patterns

1. **Assuming `latest` is safe** — Always verify what version `latest` resolves to.
2. **Ignoring the date** — Documentation from 2022 about a library that had a major release in 2025.
3. **No lockfile** — Without a lockfile (`package-lock.json`, `Cargo.lock`), builds are not reproducible.
4. **Blindly trusting minor versions** — Some projects introduce breaking changes in minor versions (semver violations).
5. **Never checking for deprecation** — Using APIs that were deprecated 2 years ago.

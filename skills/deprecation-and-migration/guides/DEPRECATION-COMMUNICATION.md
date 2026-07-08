# Deprecation Communication

> **Sources:** OpenAPI Specification (openapis.org) — Deprecation header and sunset field for API responses. Stripe API versioning (stripe.com/docs/api/versioning) — date-based versioning and migration guide patterns. Semantic Versioning 2.0 (semver.org) — changelog conventions for breaking changes.

## Deprecation Notice Template

Send this notice to all affected users or teams at least one support window before the change:

```text
Subject: Deprecation Notice: [Feature or API Name]

Date: [Current date]
Affected: [Users, systems, or endpoints]
Replacement: [What to use instead]
Support window ends: [Date]

[Feature or API Name] is being deprecated and will be removed
on [Sunset date]. During the support window, the existing
behavior will continue to work without changes.

What you need to do:
1. Review the migration guide: [link]
2. Update your integration to use [replacement] before [date]
3. Verify the migration in your test environment

If you have questions or need an extended timeline,
contact [team or support contact].
```

## API Deprecation Headers

When a deprecated API is called, the response should include deprecation information:

```text
HTTP/1.1 200 OK
Deprecation: true
Sunset: Sat, 1 Nov 2027 00:00:00 GMT
Link: </api/v2/orders>; rel="successor-version"
```

The `Deprecation` header tells clients this endpoint is deprecated.
The `Sunset` header tells them when it will be removed.
The `Link` header tells them what to use instead.

## Migration Guide Template

```markdown
# Migration Guide: [Feature] v1 to v2

## Summary
[One-line description of what changed and why]

## Before
\`\`\`
[Old code or API call]
\`\`\`

## After  
\`\`\`
[New code or API call]
\`\`\`

## Key Differences
- [Difference 1]
- [Difference 2]

## Timeline
- [Date]: v2 available (opt-in)
- [Date]: v1 deprecated (warnings start)
- [Date]: v1 removed (use v2 only)

## Questions?
[Support contact]
```

## Sunset Announcement Template

Send this when the feature is actually removed:

```text
Subject: [Feature] has been removed

Hi,

On [Date] we removed [feature] as planned.
It has been replaced by [replacement].

If you still see errors related to [feature]:
- Check that you're using [replacement]
- Verify your integration version
- Contact [support] for assistance

Thank you for migrating.
```

## Changelog Entry Format

```markdown
## [1.2.0] - 2026-07-08
### Added
- New orders API v2.0 (/api/v2/orders)

### Deprecated
- Orders API v1.0 (/api/v1/orders) — use /api/v2/orders instead
- Support window ends: 2027-01-01
```

## Timeline Communication Example

```text
Month 1:  Announce deprecation + publish migration guide
Month 2:  Deprecation header added to API responses (warnings start)
Month 3:  Old dashboard shows "migrate now" banners
Month 6:  Old version returns 410 Gone
```

## Anti-Patterns

1. No notice — users discover the change when their integration breaks.
2. Jargon-heavy communication — "deprecation of the RESTful endpoint interface" instead of "this API will stop working."
3. No migration guide — "use the new version" without telling how.
4. False urgency — "migrate immediately" when the support window is 6 months.
5. No contact — users with questions have nowhere to go.

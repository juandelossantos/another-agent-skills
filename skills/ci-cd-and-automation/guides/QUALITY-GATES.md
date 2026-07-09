# Quality Gates

> **Sources:** Google SRE Workbook (sre.google/workbook) — testing for reliability, CI/CD for bug prevention. Semantic versioning rules (semver.org) — version gates for release. GitHub Actions environment protection rules (docs.github.com/en/actions) — deployment gates.

## What Is a Quality Gate?

A quality gate is a condition that must be met for a pipeline stage to pass. If the condition fails, the stage fails and the pipeline stops.

Gates are the enforcement mechanism for your quality standards. Without them, quality is aspirational.

## Gate Hierarchy

```text
Branch protection (before pipeline)
  └── Lint gate (code quality)
      └── Test gate (correctness)
          └── Build gate (compilation)
              └── Security gate (vulnerabilities)
                  └── Performance gate (benchmarks)
                      └── Approval gate (human review)
                          └── Smoke gate (post-deploy verification)
```

Each gate must pass before the next can run.

## Gate Types

### Lint Gate

| Check | Tool Examples | Failure Action |
|---|---|---|
| Code formatting | linter, formatter | Block |
| Import order | import linter | Block |
| Dead code | static analysis | Warning |
| Naming conventions | style guide enforcer | Block |

### Test Gate

| Check | Tool Examples | Failure Action |
|---|---|---|
| Unit tests | test runner | Block |
| Integration tests | integration framework | Block |
| Coverage threshold | coverage tool | Warning if below target |

### Build Gate

| Check | Tool Examples | Failure Action |
|---|---|---|
| Compilation | compiler | Block |
| Package | packager | Block |
| Docker image | container builder | Block |

### Security Gate

| Check | Tool Examples | Failure Action |
|---|---|---|
| Dependency scan | dependency checker | Block on critical |
| Secret detection | secrets scanner | Block |
| SAST | static analysis | Block on critical |

### Performance Gate

| Check | Tool Examples | Failure Action |
|---|---|---|
| Bundle size | size checker | Warning if exceeded |
| Load time | performance tester | Warning |
| Benchmark comparison | benchmark tool | Block on regression |

## Gate Configuration Pattern

```yaml
# Concept — adapt to your CI provider
quality_gates:
  lint:
    command: "lint ."
    failure: block
  
  unit_test:
    command: "test --coverage"
    failure: block
    coverage_threshold: 80
  
  security_scan:
    command: "security-check"
    failure: block
    severity_threshold: critical
```

## When to Make a Gate Blocking vs Warning

| Condition | Make It |
|---|---|
| User-facing behavior broken | Blocking |
| Security vulnerability (critical/high) | Blocking |
| Build failure | Blocking |
| Style preference | Warning |
| Performance below target but acceptable | Warning |
| Coverage below target | Warning (for transition period) |

## Gate Bypass Policy

Every blocking gate may have a bypass mechanism for emergencies:

1. Bypass requires documented reason (pinned to the pipeline run)
2. Bypass expires after specified time
3. Bypass is logged and audited
4. Bypass triggers a remediation ticket

Bypasses are for emergencies, not routine use.

## Anti-Patterns

1. No gates at all — pipelines run but nothing is enforced.
2. All gates are warnings — nothing blocks, so quality drifts.
3. Flaky gates — inconsistent pass/fail destroys trust in the pipeline.
4. Missing security gate — vulnerabilities discovered in production.
5. Coverage gate without baseline — arbitrary thresholds that never pass.

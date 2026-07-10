---
name: observability-and-instrumentation
description: "Instrument code so production behavior is visible: structured logging, metrics, tracing, alerting. Use when shipping features that need evidence. Do NOT use for local development."
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write
tier: draft
metadata:
  audience: all-engineers
  workflow: instrument-monitor
---

# Observability and Instrumentation

**Make production behavior visible and diagnosable.**

Complementary to `shipping-and-launch`. Where shipping handles deployment and rollback, observability handles the ongoing production lifecycle: knowing what your system is doing, detecting when it's wrong, and having the data to diagnose it.

> **Sources:** Google SRE Workbook (sre.google/workbook/monitoring) — defines monitoring data types, RED method, and alert severity. OpenTelemetry Specification (opentelemetry.io/docs/specs/semconv) — semantic conventions for metrics, logs, and traces. OpenTelemetry Span Metrics Connector (opentelemetry.io/docs/collector/registry) — RED metrics from trace spans. SRE Prodcast (sre.google/prodcast) — three pillars of observability.

## When to Use

- Adding logging, metrics, tracing, or alerting
- Shipping features that run in production
- Production issues reported but you can't tell what happened
- Setting up monitoring dashboards
- After an incident postmortem (filling observability gaps discovered during analysis)
- Before a public launch or major feature release (ensuring launch readiness)

## Output Contract

| Artifact | Format | Location | Quality Criteria |
|---|---|---|---|
| Instrumented source code + monitoring config | Source code changes (any language) + config files (YAML, JSON) | Existing source tree + `monitoring/` or `otel/` | JSON structured logs with correlation IDs on every entry, RED metrics (rate/errors/duration) per service, USE metrics (utilization/saturation/errors) per resource, distributed tracing on every external call with OpenTelemetry span attributes, symptom-based alerts with documented runbooks, no secrets or PII in log output, monitoring configuration treated as code |

## When NOT to Use

- Deployment or rollback planning (use shipping-and-launch)
- Pre-production work

## Structured Logging

Every production log entry should be a structured event (JSON), not a free-text line. Structured logs are machine-parseable, searchable, and carry context (request ID, user ID, latency) that free-text cannot.

**Rules:**
- Log in JSON format
- Include correlation ID on every entry
- Log levels: DEBUG, INFO, WARN, ERROR, FATAL
- Never log secrets, PII, or full request bodies

See `guides/STRUCTURED-LOGGING.md` for format templates and correlation ID patterns.

## Metrics — RED Method

For every service, instrument three metrics per the Google SRE RED method:

| Metric | What It Measures |
|---|---|
| Rate | Requests per second |
| Errors | Failed requests per second |
| Duration | Latency distribution (histogram) |

## Metrics — USE Method

For every resource (CPU, memory, disk, network), instrument per the USE method:

| Metric | What It Measures |
|---|---|
| Utilization | Percent of time resource is busy |
| Saturation | Queue depth or pressure |
| Errors | Error count |

RED is for services. USE is for resources. Both are needed.

See `guides/METRICS-AND-TRACING.md` for metric naming conventions per OpenTelemetry semantic conventions.

## Distributed Tracing

Traces follow a request across service boundaries. Every trace has a Trace ID, spans, and span context. Trace every external call (HTTP, database, queue, cache). Without tracing, you cannot diagnose latency in distributed systems.

See `guides/METRICS-AND-TRACING.md` for span attributes per OpenTelemetry semantic conventions.

## Alerting

Symptom-based alerts, not cause-based. Alert on what users experience (latency, errors), not on internal details (CPU at 80%). Per Google SRE:

| Level | Meaning | Response Time |
|---|---|---|
| P0 | Service down or data loss | Immediately |
| P1 | Severe degradation | Within 1 hour |
| P2 | Partial degradation | Within 1 day |
| P3 | Minor issue | Next sprint |

Every alert must have a runbook. Without a documented response, the alert will be ignored.

## Anti-Patterns

1. Log spam — logging every line of execution instead of at boundaries.
2. No correlation ID — logs that cannot be linked to a specific request.
3. Dashboard-only monitoring — a dashboard without alerts means nobody watches it.
4. Cause-based alerting — alerting on CPU instead of latency.
5. No runbook — an alert with no documented response is noise.

## Verification

- [ ] Every service has RED metrics
- [ ] Every resource has USE metrics
- [ ] Logs are structured (JSON) with correlation IDs
- [ ] External calls have distributed tracing instrumentation
- [ ] Alerts are symptom-based with documented runbooks
- [ ] No secrets or PII in log output

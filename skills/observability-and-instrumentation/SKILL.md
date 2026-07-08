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

> **Sources:** This skill follows the three-pillar observability model (metrics, logs, traces) defined by Google SRE (sre.google/workbook/monitoring) and the OpenTelemetry semantic conventions (opentelemetry.io/docs/specs/semconv). The RED method (Rate, Errors, Duration) for metrics is derived from the Google SRE monitoring workbook. Distributed tracing patterns follow the OpenTelemetry specification (opentelemetry.io/docs/specs).

## When to Use

- Adding logging, metrics, tracing, or alerting
- Shipping features that run in production
- Production issues reported but you can't tell what happened
- Setting up monitoring dashboards

## When NOT to Use

- Deployment or rollback planning (use shipping-and-launch)
- Pre-production work

## Structured Logging

Every production log entry should be a structured event (JSON), not a free-text line. Structured logs are machine-parseable, searchable, and can carry context (request ID, user ID, latency) that free-text cannot.

**Rules:**
- Log in JSON format — not plain text
- Include correlation ID on every entry (same ID flows through the entire request)
- Log levels: DEBUG (development), INFO (normal ops), WARN (unexpected but handled), ERROR (user-visible failure), FATAL (process aborting)
- Never log secrets, PII, or full request bodies
- Log at caller boundaries, not inside every function

See `guides/STRUCTURED-LOGGING.md` for format templates, correlation ID patterns, and stack-specific libraries.

## Metrics

**RED Method (Rate, Errors, Duration):** For every service, instrument three metrics:

| Metric | What It Measures | Example |
|---|---|---|
| Rate | Requests per second | `http.requests.total` |
| Errors | Failed requests per second | `http.requests.error` |
| Duration | Latency distribution | `http.request.duration_seconds` (histogram) |

**USE Method (Utilization, Saturation, Errors):** For every resource (CPU, memory, disk, network):

| Metric | What It Measures | Example |
|---|---|---|
| Utilization | % of time resource is busy | `cpu.utilization` |
| Saturation | Queue depth or pressure | `memory.oom_count` |
| Errors | Error count | `disk.io_error` |

RED is for services (what your app does). USE is for resources (what your infra does). Both are needed.

See `guides/METRICS-AND-TRACING.md` for metric naming conventions, histogram boundaries, and integration with OpenTelemetry.

## Distributed Tracing

Traces follow a request across service boundaries. Every trace has:
- **Trace ID** — unique identifier for the entire request flow
- **Span** — a single unit of work within the trace (e.g., database query, HTTP call)
- **Span context** — parent-child relationships that reconstruct the full path

Trace every external call (HTTP, database, queue, cache). Without tracing, you cannot diagnose latency in distributed systems.

See `guides/METRICS-AND-TRACING.md` for span attributes per OpenTelemetry semantic conventions.

## Alerting

**Symptom-based alerts, not cause-based.** Alert on what users experience (latency, errors), not on internal details (CPU at 80%). The Google SRE workbook defines four alert severity levels:

| Level | Meaning | Response Time |
|---|---|---|
| P0 | Service down or data loss | Immediately |
| P1 | Severe degradation | Within 1 hour |
| P2 | Partial degradation | Within 1 day |
| P3 | Minor issue or warning | Next sprint |

Every alert must have a runbook. If there's no documented response procedure, the alert will be ignored.

## Anti-Patterns

1. **Log spam** — Logging every line of execution. Log at boundaries, not inside every loop.
2. **No correlation ID** — Logs that cannot be linked to a specific request or user.
3. **Dashboard-only monitoring** — A dashboard without alerts means nobody watches it.
4. **Cause-based alerting** — Alerting on "CPU > 80%" instead of "p99 latency > 200ms".
5. **No runbook** — An alert with no documented response is noise.
6. **Logging secrets** — Passwords, tokens, or PII in log output.

## Verification

- [ ] Every service has RED metrics (Rate, Errors, Duration)
- [ ] Every resource has USE metrics (Utilization, Saturation, Errors)
- [ ] Logs are structured (JSON) with correlation IDs
- [ ] External calls have distributed tracing instrumentation
- [ ] Alerts are symptom-based with documented runbooks
- [ ] No secrets or PII in log output (tested at deploy time)

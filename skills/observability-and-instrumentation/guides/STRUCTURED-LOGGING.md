# Structured Logging

> **Sources:** Google SRE Workbook (sre.google/workbook/monitoring) — structured event logging as a core monitoring data type. OpenTelemetry log data model (opentelemetry.io/docs/specs/semconv/general) — attribute naming conventions for log records.

## Format

Every log entry must be a single JSON line:

```json
{
  "timestamp": "2026-07-08T15:00:00.000Z",
  "level": "INFO",
  "message": "Order processed",
  "service": "order-service",
  "correlation_id": "abc-123"
}
```

## Log Levels

| Level | When to Use |
|---|---|
| DEBUG | Development only. Disabled in production. |
| INFO | Normal operation, confirm health. |
| WARN | Unexpected but handled. Request completed. |
| ERROR | User-visible failure. Request failed. |
| FATAL | Process cannot continue. |

## Correlation ID

Every incoming request gets a unique correlation ID that flows through all downstream calls:

```python
import uuid
correlation_id = str(uuid.uuid4())
```

Propagate via:
- HTTP header: `X-Correlation-ID`
- Message metadata for async queues
- Thread-local or DI-scoped context

## Stack-Neutral Pattern

```text
LOG { "timestamp":"<ISO8601>", "level":"<LEVEL>",
      "message":"<human readable>",
      "correlation_id":"<uuid>",
      "service":"<name>",
      "duration_ms":<number> }
```

This pattern works in any language. Wrap it in a helper function in your chosen stack.

## Anti-Patterns

1. Plain text logs — `"Order " + id + " created"` is not searchable.
2. No correlation ID — logs that cannot be linked to a request.
3. Logging in loops — rate-limit or use metrics instead.
4. Multi-line messages — stack traces spanning JSON lines break log parsers.
5. Inconsistent naming — `user_id` in one service, `userId` in another.

# Structured Logging

> **Sources:** Google SRE Workbook — Monitoring (sre.google/workbook/monitoring) defines structured event logging as one of the two most effective monitoring types. OpenTelemetry log data model (opentelemetry.io/docs/specs/semconv/general/attribute-naming) defines the attribute naming conventions used below. Correlation ID pattern from Google's distributed systems tracing practices.

## Log Format

Every log entry must be a single JSON line. No multi-line log entries — they break log aggregators.

### Minimal Format

```json
{
  "timestamp": "2026-07-08T15:00:00.000Z",
  "level": "INFO",
  "message": "Order processed successfully",
  "service": "order-service",
  "correlation_id": "abc-123-def-456"
}
```

### Rich Format (with context)

```json
{
  "timestamp": "2026-07-08T15:00:00.000Z",
  "level": "ERROR",
  "message": "Payment gateway timeout",
  "service": "order-service",
  "version": "1.2.3",
  "correlation_id": "abc-123-def-456",
  "user_id": "user_789",
  "duration_ms": 5234,
  "error": {
    "type": "timeout",
    "message": "Gateway did not respond within 5s",
    "code": "GATEWAY_TIMEOUT"
  },
  "request": {
    "method": "POST",
    "path": "/api/orders",
    "status_code": 502
  }
}
```

## Log Levels

| Level | When to Use | Example |
|---|---|---|
| DEBUG | Development only. Disabled in production. | "Processing item 42 in loop 7" |
| INFO | Normal operation events that confirm health. | "Order 12345 created successfully" |
| WARN | Unexpected but handled. Request completed. | "Retry attempt 2 for payment gateway" |
| ERROR | User-visible failure. Request failed. | "Payment gateway returned 500 after 3 retries" |
| FATAL | Process cannot continue. Page or crash. | "Database connection pool exhausted — shutting down" |

## Correlation ID Pattern

Every incoming request gets a unique correlation ID that flows through all downstream calls. This lets you reconstruct the entire request path.

### Generation

```python
import uuid
correlation_id = str(uuid.uuid4())
```

### Propagation

Pass the correlation ID in:
- **HTTP headers:** `X-Correlation-ID`
- **Async messages:** Message metadata field
- **Log context:** Thread-local or DI-scoped context

Every log entry in the request path includes the same correlation ID. When debugging a user issue: search by correlation ID, get every log entry across all services.

## Stack-Specific Libraries

| Stack | Library | Structured by Default? |
|---|---|---|
| Node.js | `pino` | Yes — JSON output |
| Python | `structlog` | Yes — JSON output with configuration |
| Ruby | `lograge` | No — replaces Rails multi-line with single-line |
| Go | `zap` or `slog` | Yes — structured from the start |
| Java | `logback` + Logstash encoder | Yes — JSON with encoder |
| Rust | `tracing` + `tracing-subscriber` | Yes — structured events |

## Anti-Patterns

1. **Plain text logs** — `console.log("Order " + id + " created")` is not searchable. Use structured logging.
2. **No correlation ID** — Log entries that cannot be linked to any user or request.
3. **Logging in loops** — Logging the same message 10,000 times (use rate-limited logging or summary metrics).
4. **Multi-line messages** — Stack traces spanning multiple JSON lines break log parsers. Use structured error fields.
5. **Inconsistent field names** — `user_id` in one service, `userId` in another, `customerId` in a third. Agree on naming.

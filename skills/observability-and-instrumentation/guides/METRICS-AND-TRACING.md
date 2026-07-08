# Metrics and Tracing

> **Sources:** OpenTelemetry Specifications (opentelemetry.io/docs/specs/semconv) — defines metric data models (Sum, Gauge, Histogram) and span semantic conventions for HTTP, database, and messaging. Google SRE Workbook (sre.google/workbook/monitoring) — defines RED method and four golden signals. OpenTelemetry Span Metrics Connector (opentelemetry.io/docs/collector/registry) — converts trace spans into RED metrics. The SRE prodcast observability episode (sre.google/prodcast) — three pillars: metrics, logs, traces.

## RED Method Implementation

For every service, define these metric names using OpenTelemetry semantic convention naming:

```yaml
# Rate — total requests counter
metric: http.server.request.count
type: counter (monotonic)
attributes: [http.method, http.route, http.status_code]

# Errors — failed requests counter
metric: http.server.request.error_count  
type: counter (monotonic)
attributes: [http.method, http.route, error.type]

# Duration — latency histogram
metric: http.server.request.duration
type: histogram
attributes: [http.method, http.route, http.status_code]
unit: ms
```

### Histogram Boundaries

```yaml
# Recommended buckets for HTTP duration (ms)
boundaries: [0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000]
```

These follow OpenTelemetry's recommended HTTP server duration histogram boundaries.

## USE Method Implementation

For every infrastructure resource, define:

```yaml
# CPU
metric: cpu.utilization
type: gauge (0.0–1.0)

# Memory saturation
metric: system.memory.usage
type: gauge (bytes)

# Disk errors
metric: disk.io.error  
type: counter
```

## Span Attributes (OpenTelemetry Semantic Conventions)

Every span should include attributes according to OpenTelemetry conventions:

### HTTP Server Span

```yaml
span.name: "GET /api/orders/{order_id}"
attributes:
  http.request.method: GET
  url.full: "https://api.example.com/api/orders/123"
  http.response.status_code: 200
  network.protocol.version: "1.1"
  server.address: api.example.com
  server.port: 443
```

### Database Span

```yaml
span.name: "SELECT FROM orders"
attributes:
  db.system: postgresql
  db.namespace: production
  db.query.text: "SELECT * FROM orders WHERE id = $1"
  db.response.returned_rows: 1
```

### Messaging Span

```yaml
span.name: "send payment.process"
attributes:
  messaging.system: rabbitmq
  messaging.destination.name: payment.process
  messaging.message.id: msg_789
```

## Alerting Thresholds from Metrics

```yaml
alerts:
  - metric: http.server.request.duration
    condition: p99 > 500ms for 5 minutes
    severity: P1
    runbook: "Check database query times, upstream dependencies"
  
  - metric: http.server.request.error_count
    condition: rate > 1% of total requests for 5 minutes
    severity: P1
    runbook: "Check error logs by error.type, rollback recent deploy"
  
  - metric: system.cpu.utilization
    condition: > 0.9 for 15 minutes
    severity: P2
    runbook: "Check for runaway processes, scale up"
```

Alert on symptom (latency, errors), not cause (CPU). CPU alerts create noise. Latency alerts create action.

## OpenTelemetry Integration

OpenTelemetry provides vendor-neutral instrumentation. It collects metrics, logs, and traces and exports them to any backend (Prometheus, Grafana, Datadog, etc.).

### Instrumentation Pattern

```python
# Example: Python with OpenTelemetry
from opentelemetry import trace
from opentelemetry.instrumentation.requests import RequestsInstrumentor

# Auto-instrument HTTP client
RequestsInstrumentor().instrument()

# Create manual spans for business logic
tracer = trace.get_tracer(__name__)
with tracer.start_as_current_span("process_order"):
    # Your business logic here
    process_order(order_id)
```

Similar patterns exist for all major languages (Node.js, Go, Java, Ruby, Rust) via OpenTelemetry SDKs.

## Anti-Patterns

1. **RED without USE** — Monitoring service latency but ignoring that the database server is at 95% CPU.
2. **USE without RED** — Monitoring CPU and memory but having no idea about request error rates.
3. **No histogram** — Only tracking average latency. Average hides p99 outliers.
4. **No tracing** — Knowing a request is slow but having no data on which service caused it.
5. **Metric overload** — Instrumenting everything creates noise. Start with RED per service + USE per resource.

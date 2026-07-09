# Metrics and Tracing

> **Sources:** OpenTelemetry Specification (opentelemetry.io/docs/specs/semconv) — metric data models (Sum, Gauge, Histogram) and span semantic conventions for HTTP, database, and messaging. Google SRE Workbook (sre.google/workbook/monitoring) — RED method and four golden signals. OpenTelemetry Span Metrics Connector (opentelemetry.io/docs/collector/registry) — traces to RED metrics conversion.

## RED Metric Definitions

For every service, these three metrics using OpenTelemetry naming:

| Metric | Type | Attributes |
|---|---|---|
| `http.server.request.count` | Counter (monotonic) | http.method, http.route, http.status_code |
| `http.server.request.error_count` | Counter (monotonic) | http.method, http.route, error.type |
| `http.server.request.duration` | Histogram | http.method, http.route, http.status_code |

Histogram boundaries (ms): 0, 5, 10, 25, 50, 75, 100, 250, 500, 750, 1000, 2500, 5000, 7500, 10000

## USE Metric Definitions

For every infrastructure resource:

| Resource | Utilization | Saturation | Errors |
|---|---|---|---|
| CPU | cpu.utilization (gauge 0-1) | load.1m (gauge) | — |
| Memory | memory.usage (gauge bytes) | memory.oom_count (counter) | — |
| Disk | disk.io.utilization (gauge) | disk.io.queue (gauge) | disk.io.error (counter) |
| Network | net.rx.bytes / net.tx.bytes | net.rx.drops, net.tx.drops | net.rx.errors |

## Span Attributes — HTTP

Every HTTP span should include:

```yaml
http.request.method: GET
url.full: "https://api.example.com/orders"
http.response.status_code: 200
network.protocol.version: "1.1"
server.address: api.example.com
```

## Span Attributes — Database

```yaml
db.system: postgresql
db.namespace: production
db.query.text: "SELECT * FROM orders WHERE id = $1"
db.response.returned_rows: 1
```

## Span Attributes — Messaging

```yaml
messaging.system: rabbitmq
messaging.destination.name: payment.process
messaging.message.id: msg_789
```

## Alerting Thresholds

| Metric | Condition | Severity |
|---|---|---|
| http.server.request.duration | p99 > 500ms for 5 minutes | P1 |
| http.server.request.error_count | > 1% of requests for 5 minutes | P1 |
| cpu.utilization | > 0.9 for 15 minutes | P2 |

Alert on symptom (latency, errors). CPU alerts create noise.

## Anti-Patterns

1. RED without USE — monitoring latency but ignoring the database at 95% CPU.
2. USE without RED — monitoring CPU but no data on error rates.
3. No histogram — average latency hides p99 outliers.
4. No tracing — knowing a request is slow but not which service caused it.

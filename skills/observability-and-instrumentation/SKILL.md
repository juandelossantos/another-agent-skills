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

## When to Use

- Adding logging, metrics, tracing, or alerting
- Shipping features that run in production
- Production issues reported but you can't tell what happened
- Setting up monitoring dashboards

## When NOT to Use

- Deployment or rollback planning (use shipping-and-launch)
- Pre-production work

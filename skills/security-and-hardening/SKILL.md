---
name: security-and-hardening
description: >
  Hardens code against vulnerabilities. Covers OWASP prevention, input validation,
  authentication, data storage security, and third-party integration safety.
  Use when handling user input, auth, data storage, or external integrations.
  Complements hard-skill: hard-skill is mechanical (a11y, states), this is preventive (security).
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: audit-harden
---

# Security and Hardening

**Prevent vulnerabilities before they reach production.**

Complementary to `hard-skill`: hard-skill applies deterministic mechanical fixes (a11y, input robustness, state handling). Security & hardening focuses on attack surface analysis and preventive measures.

## When to Use

- Handling user input or file uploads
- Implementing authentication or session management
- Storing sensitive data (keys, tokens, PII)
- Integrating with third-party services
- Building any public-facing feature

## When NOT to Use

- Accessibility or input validation mechanics (use hard-skill)
- Performance optimization (use performance-optimization or optimize-skill)

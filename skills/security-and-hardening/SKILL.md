---
name: security-and-hardening
description: "Harden code against vulnerabilities: OWASP prevention, input validation, authentication, data storage, and third-party safety. Do NOT use for mechanical a11y fixes."
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

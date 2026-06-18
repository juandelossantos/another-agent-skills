---
name: ci-cd-and-automation
description: >
  Automate CI/CD pipeline setup, quality gates, and deployment automation.
  Use when configuring test runners in CI, setting up build pipelines, or
  automating deployment. For end-to-end shipping lifecycle including monitoring
  and rollback, use fullstack-shipping instead.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: automate-deploy
---

# CI/CD and Automation

**Automated quality gates on every change.**

Focused on CI/CD pipeline setup and automation. For the complete end-to-end shipping lifecycle (deploy, monitor, rollback, launch checklist), use `fullstack-shipping`.

## Relationship

`ci-cd-and-automation` (this skill — pipeline automation)
`fullstack-shipping` (end-to-end: deploy + monitoring + rollback + launch)

## When to Use

- Setting up or modifying CI/CD pipelines
- Configuring automated quality gates
- Automating build and deployment processes
- Adding test runners to CI

## When NOT to Use

- Full deployment strategy with monitoring and rollback (use fullstack-shipping)
- Pre-deployment launch checklist

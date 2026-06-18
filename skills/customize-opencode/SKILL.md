---
name: customize-opencode
description: >
  Edit or create OpenCode's own configuration files: opencode.json, files under
  .opencode/, or ~/.config/opencode/. Use ONLY when configuring OpenCode itself.
  Do NOT use for the user's application code, or for any project that is not
  configuring OpenCode.
version: 1.0.0
license: MIT
compatibility: all
allowed-tools: Read Bash Write Edit
tier: action-allowed
metadata:
  audience: all-engineers
  workflow: configure
---

# Customize OpenCode

**Configure OpenCode itself — not your application.**

This skill is extremely narrow: it only applies when editing OpenCode's own configuration files (opencode.json, .opencode/ plugins, ~/.config/opencode/ rules, skills, MCP servers, or permission rules).

## When to Use

- Creating or editing opencode.json / opencode.jsonc
- Adding or modifying OpenCode plugins
- Configuring MCP servers in OpenCode
- Editing permission rules

## When NOT to Use

- Your application code (use the appropriate platform skill)
- Any project that is not configuring OpenCode itself

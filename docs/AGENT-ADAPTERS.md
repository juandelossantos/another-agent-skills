# Agent Adapters

Use Another Agent Skills from any AI coding ecosystem.

## Quick Install

```bash
# Install templates to ~/.config/opencode/templates/
bash install.sh --agent claude    # Claude Code
bash install.sh --agent cursor    # Cursor
bash install.sh --agent all       # All ecosystems
```

Or copy manually from `templates/` in this repo.

## Claude Code

1. Copy the template:
   ```bash
   bash install.sh --agent claude
   ```
2. It creates `CLAUDE.md` in your project root.
3. Claude Code reads it at session start.

## Cursor

1. Copy the template:
   ```bash
   bash install.sh --agent cursor
   ```
2. It creates `.cursorrules` in your project root.
3. Cursor reads it for context rules.

## Manual Copy

```bash
# Claude Code
cp templates/CLAUDE.md /path/to/your/project/CLAUDE.md

# Cursor
cp templates/.cursorrules /path/to/your/project/.cursorrules
```

## Adding an Adapter

1. Create `templates/<name>` in this repo.
2. Update `install.sh` to handle it.
3. Add it to this guide.
4. Update the README roadmap.

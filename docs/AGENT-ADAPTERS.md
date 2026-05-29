# Agent Adapters

Use Another Agent Skills from any AI coding agent. Each agent has native hook support where available, with shell script fallbacks for others.

## Agent Compatibility Matrix

| Agent | Primary? | Hook System | Plugin Config | Shell Fallback |
|---|---|---|---|---|
| **OpenCode** | ✅ Yes | JS Event Hooks | `.opencode/plugins/agent-discipline/` | N/A |
| **Claude Code** | Secondary | JS Hooks | `.claude-plugin/agent-discipline/` | ✅ |
| **Cursor** | Secondary | JS Hooks | `.cursor-plugin/agent-discipline/` | ✅ |
| **Kiro** | Secondary | JSON Config | `.kiro/hooks/` | ✅ |
| **Others** | N/A | N/A | N/A | ✅ |

---

## OpenCode (Primary)

**Full native support with TypeScript plugin.**

```
.opencode/plugins/agent-discipline/
├── plugin.json          # Event registrations
├── src/
│   ├── index.ts         # Plugin entry
│   ├── hooks/
│   │   ├── edit-guard.ts
│   │   ├── pre-flight.ts
│   │   ├── commit-approval.ts
│   │   └── session-compact.ts
│   └── lib/
│       ├── file-integrity.ts
│       ├── git-state.ts
│       └── token-manager.ts
```

**Auto-enforced events:**
- `file.edited` → Structural integrity check
- `tool.execute.before` → Git state pre-flight
- `tui.command.execute` → Commit approval gate
- `session.compacted` → Anti-slop reminder

**Install:** Included with `install.sh`

---

## Claude Code

**Native plugin with shell script hooks.**

```
.claude-plugin/agent-discipline/
├── plugin.json
└── hooks/
    ├── commit-approval.sh
    ├── edit-guard.sh
    └── pre-flight.sh
```

**Claude Code hook events:**
- `beforeCommit` → `commit-approval.sh`
- `beforeEdit` → `edit-guard.sh`
- `preToolUse[shell]` → `pre-flight.sh`

### Install

```bash
# Automatic (via install.sh)
bash install.sh --agent claude

# Manual
cp -r .claude-plugin/ /path/to/project/
```

### Manual Configuration

1. Copy the plugin:
   ```bash
   cp -r .claude-plugin/ /your/project/
   ```
2. Create `CLAUDE.md` in project root:
   ```bash
   cp templates/CLAUDE.md /your/project/CLAUDE.md
   ```
3. Restart Claude Code session

---

## Cursor

**Native plugin with shell script hooks.**

```
.cursor-plugin/agent-discipline/
├── plugin.json
└── hooks/  (symlinks to .claude-plugin)
```

**Cursor hook events:**
- `beforeShellExecution` → `commit-approval.sh`
- `afterFileEdit` → `edit-guard.sh`
- `preToolUse[shell]` → `pre-flight.sh`

### Install

```bash
# Automatic (via install.sh)
bash install.sh --agent cursor

# Manual
cp -r .cursor-plugin/ /path/to/project/
```

### Manual Configuration

1. Copy the plugin:
   ```bash
   cp -r .cursor-plugin/ /your/project/
   ```
2. Create `.cursorrules` in project root:
   ```bash
   cp templates/.cursorrules /your/project/.cursorrules
   ```
3. Restart Cursor session

---

## Kiro

**Hook-based automation via JSON configuration.**

Kiro uses a different hook system based on JSON config files and natural language prompts.

### Install

1. Copy the hooks config:
   ```bash
   mkdir -p /your/project/.kiro/hooks
   cp -r .kiro/hooks/* /your/project/.kiro/hooks/
   ```

2. Or configure manually via Kiro IDE:
   - Open Agent Hooks panel
   - Create hooks for each event type

### Hook Configuration

Kiro hooks are configured via `.kiro/hooks/` JSON files:

```json
{
  "name": "agent-discipline",
  "hooks": [
    {
      "title": "Pre-Flight Git Check",
      "event": "Pre Tool Use",
      "toolName": "shell",
      "action": "Run Command",
      "command": "bash scripts/pre-flight.sh"
    },
    {
      "title": "Commit Approval Gate",
      "event": "Prompt Submit",
      "action": "Run Command",
      "command": "bash scripts/commit-approval.sh"
    },
    {
      "title": "Edit Guard",
      "event": "File Save",
      "filePattern": "*.{ts,js,tsx,jsx,html,css}",
      "action": "Run Command",
      "command": "bash scripts/edit-guard.sh verify"
    }
  ]
}
```

### Kiro Hook Events

| Event | Use Case |
|---|---|
| `Prompt Submit` | Check commit approval before prompts |
| `Agent Stop` | Run edit-guard verify after changes |
| `Pre Tool Use` | Pre-flight check before shell commands |
| `File Save` | Verify file integrity after edits |
| `Post Tool Use` | Log or format after tool execution |

---

## Shell Scripts (All Other Agents)

For agents without native plugin support, use the shell scripts directly:

```
scripts/
├── edit-guard.sh       # File integrity gate
├── pre-flight.sh       # Git state check
├── design-gate.sh      # Design process gate
└── git-hooks/
    ├── pre-commit      # Git-level enforcement
    └── commit-msg      # Hash verification
```

### Usage

```bash
# Before editing a file
bash scripts/edit-guard.sh preflight path/to/file marker1 marker2

# After editing
bash scripts/edit-guard.sh verify path/to/file

# Before risky git commands
bash scripts/pre-flight.sh

# Check edit-guard markers
bash scripts/edit-guard.sh check path/to/file marker1 marker2
```

---

## Quick Install (All Agents)

```bash
# OpenCode
bash install.sh

# Claude Code
bash install.sh --agent claude

# Cursor
bash install.sh --agent cursor

# Kiro
bash install.sh --agent kiro

# All
bash install.sh --agent all
```

---

## Architecture Notes

### Why Separate Implementations?

OpenCode uses TypeScript (native plugin), other agents use shell scripts. Both implementations provide equivalent functionality but cannot share code due to language differences.

| Component | OpenCode | Claude/Cursor/Kiro |
|---|---|---|
| Language | TypeScript | Bash |
| Distribution | `.opencode/plugins/` | `.claude-plugin/`, `.cursor-plugin/`, `.kiro/` |
| Hook System | JS Event API | Shell scripts + config |
| Source of Truth | `src/lib/` | `scripts/` |

Both are maintained in sync. If you find a bug, fix both.

### Fallback Chain

```
Agent requests commit
    ↓
Plugin/Config Found?
    ├── Yes → Run hook script → Block/Allow
    └── No → Run shell script directly
                    ↓
              Shell script found?
                ├── Yes → Run directly
                └── No → No enforcement (warning logged)
```

---

## Adding a New Agent

1. Create agent-specific plugin/config directory:
   ```
   .<agent>-plugin/agent-discipline/
   ```

2. Create `plugin.json` or config file following agent's format

3. Create hook scripts (bash for simplicity)

4. Update `install.sh` to copy the config

5. Document in this file

6. Add to README compatibility matrix

# Agent Adapters

Use Another Agent Skills from any AI coding agent. Each agent has native hook support where available, with shell script fallbacks for others.

## Agent Compatibility Matrix

**Philosophy A (all agents):** the agent **never** runs `git commit`/`git push` — no token bypass. It presents the exact command/message and the **user** runs it (Rule 12).

| Agent | Skills dir | Guardrails | Installed by |
|---|---|---|---|
| **OpenCode** | `~/.config/opencode/skills/` | native plugin `agent-discipline` → **deny** | `install.sh --plugin-only` / `--guardrails-only` |
| **Claude Code** | `~/.claude/skills/` | hook `~/.claude/hooks/agent-discipline/commit-approval.sh` → **deny** | `install.sh --guardrails-only` |
| **Gemini** | `~/.gemini/skills/` | none (git hooks apply) | `install.sh --skills-only` |
| **Kiro / Zed / others** | not managed | git hooks (`commit-msg` TDD) per project | `init-agents` |

Skills are symlinked from the canonical OpenCode dir (`~/.config/opencode/skills/`) so there is a single source of truth.

**Adapter detail:**

| Agent | Primary? | Global Skills | Hook System | Plugin Config | Shell Fallback |
|---|---|---|---|---|---|
| **OpenCode** | ✅ Yes | `~/.config/opencode/skills/` (auto) | JS Event Hooks | `plugins/agent-discipline/` → `~/.config/opencode/plugins/agent-discipline/` | N/A |
| **Claude Code** | Secondary | `~/.claude/skills/` (auto) | Bash (auto-wired) | `.claude-plugin/agent-discipline/` | ✅ |
| **Cursor** | Secondary | — | JS Hooks | `.cursor-plugin/agent-discipline/` | ✅ |
| **Kiro** | Secondary | — | JSON Config | `.kiro/hooks/` | ✅ |
| **Others** | N/A | — | N/A | N/A | ✅ |

---

## OpenCode (Primary)

**Dual-contract plugin** — one default export serves OpenCode v2 (`setup()`) and v1 (`server()`, 1.18.29+). Source lives at `plugins/agent-discipline/` and is installed to `~/.config/opencode/plugins/agent-discipline/`.

```
plugins/agent-discipline/
├── index.js          # dual contract: id + setup(ctx) [v2] and server() [v1]
└── package.json      # type: module, main: index.js, engines.opencode >= 1.18.29
```

**Enforcement (philosophy A):**
- `tool.execute.before` → **blocks** `git commit/push/merge/rebase/reset/cherry-pick/revert` (no token bypass)
- `file.edited` → passive line-count drift warning (edit-guard)
- `session.compaction` → anti-slop reminder
- other mutations → guardian warning (non-blocking)

**Why the source is NOT under `.opencode/plugins/`:** OpenCode auto-loads that directory, so a repo-local copy collides with the globally installed plugin under the same id (`Duplicate plugin ID: agent-discipline`).

**Install:** `bash install.sh --plugin-only` (or `--guardrails-only`).

---

## Claude Code

### Global Skills (all 57 skills, every project, one install)

Claude Code auto-discovers skills from `~/.claude/skills/<name>/SKILL.md` — no per-project copy needed, unlike the OpenCode-only global path (`~/.config/opencode/skills/`).

```bash
# Installs skills globally + OpenCode global setup (default)
bash install.sh

# Or just the Claude Code adapter (global skills + CLAUDE.md + hooks, no OpenCode setup)
bash install.sh --agent claude
```

Both paths install every skill in `skills/` to `~/.claude/skills/` (override with `CLAUDE_SKILLS_DIR`). Re-running is safe:
- Unchanged skills are left alone.
- Changed skills are backed up (`<name>.backup.<timestamp>`) before being replaced.
- Skills removed from this repo are removed from `~/.claude/skills/` too — but **only** skills this installer put there, tracked in `~/.claude/skills/.another-agent-skills-manifest`. Any other skill you already have installed (your own or from another project) is never touched.

Verify: `ls ~/.claude/skills/` — start a new Claude Code session to pick up changes.

### Hooks (wired automatically — no manual JSON editing)

```
.claude-plugin/agent-discipline/
├── plugin.json
└── hooks/
    ├── commit-approval.sh   # PreToolUse/Bash — unconditionally blocks git commit/push/merge/rebase/reset/cherry-pick/revert (philosophy A: no token bypass)
    ├── pre-flight.sh        # PreToolUse/Bash — blocks risky git/rm/mv commands on a dirty tree or when behind upstream
    └── edit-guard.sh        # PreToolUse+PostToolUse/Edit|Write — warns if a file's line count changed >20% after an edit
```

`bash install.sh --agent claude` copies these scripts into your project **and** merges the matching hooks into `.claude/settings.json` automatically — active from your next Claude Code session, no manual JSON editing. Each script parses the hook's JSON payload from stdin (`tool_input.command` / `tool_input.file_path`) and scopes itself to the risky commands/files that actually matter, instead of firing on every `Bash` or `Edit` call.

The merge is additive and idempotent: it only ever adds to `.claude/settings.json` — it never replaces the file, never touches unrelated keys (`permissions`, `env`, ...), and never duplicates its own entries on a re-run. If you already have your own hooks under the same matcher, they're preserved alongside these.

Requires `jq` (bash) — if missing, hook wiring is skipped with a warning and the rest of the install still completes; wire manually per the schema above once `jq` is installed, then re-run.

> **Known limitation:** `.claude-plugin/agent-discipline/` is laid out for readability, not for Claude Code's own plugin auto-discovery — a real Claude Code plugin needs `.claude-plugin/plugin.json` at the plugin root (manifest only) and `hooks/hooks.json` at the plugin root, not nested one level deeper as done here. That restructure (to become an installable/marketplace plugin, instead of settings.json-merged scripts) is tracked as follow-up work — it doesn't block the automatic wiring above, which works today via `.claude/settings.json`.

### Install

```bash
# Automatic (via install.sh) — global skills + CLAUDE.md + .claude-plugin/ + wired hooks
bash install.sh --agent claude

# Manual
cp -r .claude-plugin/ /path/to/project/
```

### Manual Configuration

Only needed if you skip `install.sh` entirely:

1. Install skills globally (once, works in every project):
   ```bash
   bash install.sh --agent claude   # or plain `bash install.sh` — also wires hooks
   ```
2. Copy the plugin scripts (per project, needed for hooks):
   ```bash
   cp -r .claude-plugin/ /your/project/
   ```
3. Create `CLAUDE.md` in project root:
   ```bash
   cp templates/CLAUDE.md /your/project/CLAUDE.md
   ```
4. To also load SOUL.md and AGENTS.md rules (skills and hooks don't need this — only rules do), copy the key principles into your CLAUDE.md — this part stays manual.
5. Restart Claude Code session

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
# OpenCode + Claude Code global skills (both, always — no flag needed)
bash install.sh

# Claude Code adapter (global skills + CLAUDE.md + hooks, skips OpenCode setup)
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

OpenCode uses a native JavaScript plugin, other agents use shell scripts. Both implementations provide equivalent functionality but cannot share code due to language differences.

| Component | OpenCode | Claude/Cursor/Kiro |
|---|---|---|
| Language | TypeScript | Bash |
| Distribution | `plugins/agent-discipline/` (installed to `~/.config/opencode/plugins/`) | `.claude-plugin/`, `.cursor-plugin/`, `.kiro/` |
| Hook System | JS Event API | Shell scripts + config |
| Source of Truth | `plugins/agent-discipline/index.js` | `scripts/` |

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

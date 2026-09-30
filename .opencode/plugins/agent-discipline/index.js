/**
 * agent-discipline — dual-contract OpenCode plugin (v1 + v2)
 *
 * Source of truth for the native enforcement layer. One default export serves
 * both loaders:
 *   - OpenCode v2  → reads `id` + `setup(ctx)` and registers domain hooks.
 *   - OpenCode v1  → calls `server()` (object entrypoint, supported in 1.18.29+)
 *                    and runs the returned hook map.
 *
 * Docs (source of truth):
 *   - https://opencode.ai/v2/docs/build/plugins
 *   - https://opencode.ai/v2/docs/build/plugins/migrate-v1
 *
 * Enforcement (philosophy A — the agent never commits/pushes):
 *   - git commit/push/merge/rebase/reset/cherry-pick/revert are ALWAYS blocked.
 *     There is no token bypass: the agent presents the exact command/message and
 *     the USER runs it (Rule 12). This matches the unconditional Claude guardrail.
 *   - guardian: warn (non-blocking) on other mutations and destructive commands.
 *   - edit-guard: passive warning when an edit changes a file's line count by
 *     more than 20%.
 *   - anti-slop: re-inject reminders into the compaction context.
 *
 * v1 → v2 mapping (verified against the migration guide):
 *   tool.execute.before        → ctx.tool.hook("execute.before", …)
 *   experimental.session.compacting → ctx.session.hook("compaction", …)
 *   event                      → ctx.event.subscribe({ signal })
 *   dispose                    → cleanup function returned by setup()
 */
import * as fs from "node:fs"

const LINE_COUNT_THRESHOLD_PERCENT = 20

// Mutations the agent must NEVER run. The user runs them.
const BLOCKED_MUTATIONS = [
  "git commit",
  "git push",
  "git merge",
  "git rebase",
  "git reset",
  "git cherry-pick",
  "git revert",
]

const MUTATION_MARKERS = [
  "git commit",
  "git push",
  "git merge",
  "git rebase",
  "git reset",
  "git branch -d",
  "git clean",
  "git stash pop",
  "git revert",
]

const DESTRUCTIVE_RE = [/^rm\s+-rf/, /^mv\s+/]

const GUARDIAN_PATTERN_REMINDER = `【GUARDIAN PATTERN - MANDATORY】
Before ANY mutation (commit, push, merge, rebase, reset, branch -d, clean, stash pop):
1. Present DECISION POINT block (type, branch, files, rationale, Rule 12 check)
2. Wait for explicit approval (yes/sí/commit/proceed)
3. INVALID responses: ok, mmhm, continue, dale, sigamos, silence, emoji

NEVER proceed with mutation without user confirmation.`

const ANTI_SLOP_REMINDER = `[session-compact] Context evicted. Remember:
- Simplicity first: would a senior say this is overcomplicated?
- Surgical changes: every changed line traces to user's request
- Goal-driven: define success criteria before coding
- Think before coding: surface tradeoffs, ask before guessing
${GUARDIAN_PATTERN_REMINDER}`

// ── Helpers ─────────────────────────────────────────────────────────────────

function startsWithAny(command, prefixes) {
  return prefixes.some((prefix) => command === prefix || command.startsWith(`${prefix} `))
}

function isMutation(command) {
  return MUTATION_MARKERS.some((marker) => command.includes(marker))
}

function guardianMessage(command) {
  return `【GUARDIAN PATTERN ALERT】Mutation detected: "${command}". Did you present the DECISION POINT block and receive explicit approval? If NOT: STOP and wait for yes/sí/proceed.`
}

/**
 * Evaluate a bash command. Returns { block } to stop the tool call, { warn } to
 * surface a non-blocking reminder, or null for an ordinary command.
 */
function evaluateBashCommand(rawCommand) {
  if (typeof rawCommand !== "string") return null
  const command = rawCommand.trim()
  if (!command) return null

  if (startsWithAny(command, BLOCKED_MUTATIONS)) {
    return {
      block: `The agent never runs "${command}". Present the exact command and message, then let the user run it (Rule 12).`,
    }
  }

  if (isMutation(command) || DESTRUCTIVE_RE.some((re) => re.test(command))) {
    return { warn: guardianMessage(command) }
  }
  return null
}

function fileLineCount(file) {
  try {
    if (!fs.existsSync(file)) return null
    return fs.readFileSync(file, "utf-8").split("\n").length
  } catch {
    return null
  }
}

function emit(ctx, level, message) {
  const line = `[agent-discipline] ${message}`
  if (level === "error") console.error(line)
  else console.warn(line)
  try {
    const body = { service: "agent-discipline", level, message }
    const log = ctx?.app?.log
    if (typeof log === "function") {
      const result = log({ body })
      if (result && typeof result.catch === "function") result.catch(() => {})
    }
  } catch {
    /* best-effort */
  }
}

// ── Plugin definition (shared v2 core) ──────────────────────────────────────

const definition = {
  id: "agent-discipline",

  async setup(ctx) {
    const controller = new AbortController()
    const editGuardMap = new Map()

    // 1) Enforcement: block git mutations; warn on other mutations (Rule 12).
    await ctx.tool.hook("execute.before", (event) => {
      if (event?.tool !== "bash") return
      const result = evaluateBashCommand(event?.input?.command)
      if (!result) return
      if (result.block) throw new Error(`[agent-discipline] ${result.block}`)
      if (result.warn) emit(ctx, "warn", result.warn)
    })

    // 2) edit-guard: passive (v2 cannot block a completed edit) — warn on >20% drift.
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        try {
          if (event?.type !== "file.edited") continue
          const file = event?.data?.file
          if (typeof file !== "string" || !file) continue
          const current = fileLineCount(file)
          if (current === null) continue
          const previous = editGuardMap.get(file)
          if (previous && previous > 0) {
            const deltaPercent = (Math.abs(current - previous) / previous) * 100
            if (deltaPercent > LINE_COUNT_THRESHOLD_PERCENT) {
              emit(ctx, "warn", `[edit-guard] Line count changed by ${deltaPercent.toFixed(1)}% (threshold: ${LINE_COUNT_THRESHOLD_PERCENT}%). File: ${file}`)
            }
          }
          editGuardMap.set(file, current)
          if (editGuardMap.size > 500) editGuardMap.delete(editGuardMap.keys().next().value)
        } catch {
          /* never break the event bus */
        }
      }
    })()

    // 3) anti-slop: re-inject reminders into the compaction context.
    await ctx.session.hook("compaction", (event) => {
      try {
        if (Array.isArray(event?.system)) event.system.push({ type: "text", text: ANTI_SLOP_REMINDER })
      } catch {
        /* best-effort */
      }
    })

    return () => controller.abort()
  },
}

// ── Dual-contract default export ────────────────────────────────────────────

export default {
  ...definition,

  // OpenCode v1 object entrypoint (1.18.29+). V1 calls server() and runs the
  // returned hook map. Best-effort parity with the v2 core; validated in P7.4.
  async server() {
    return {
      "tool.execute.before": async (input, output) => {
        if (input?.tool !== "bash") return
        const result = evaluateBashCommand(output?.args?.command)
        if (!result) return
        if (result.block) throw new Error(`[agent-discipline] ${result.block}`)
        if (result.warn) console.warn(`[agent-discipline] ${result.warn}`)
      },
      "experimental.session.compacting": async (_input, output) => {
        try {
          if (Array.isArray(output?.system)) output.system.push(ANTI_SLOP_REMINDER)
        } catch {
          /* best-effort */
        }
      },
    }
  },
}

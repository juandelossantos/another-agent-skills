import * as fs from "fs";
import { getFileInfo, verifyLineCountChange, FileIntegrity, getGitState, isRiskyCommand, hasApprovalToken, readApprovalToken, logOverride, getOverrideCount, isEscalationRequired, ESCALATION_THRESHOLD } from "./lib";

const editGuardMap = new Map<string, { filePath: string; beforeIntegrity: FileIntegrity | null }>();

export function editGuard(event: { file: string; action: "edit" | "create" | "delete"; before?: string; after?: string }): { allow: boolean; message?: string } {
  const { file } = event;
  if (event.action === "delete") return { allow: true };
  if (event.action === "create" || !editGuardMap.has(file)) {
    const info = getFileInfo(file);
    editGuardMap.set(file, { filePath: file, beforeIntegrity: info });
    return { allow: true };
  }
  const ctx = editGuardMap.get(file)!;
  const beforeIntegrity = ctx.beforeIntegrity;
  if (!beforeIntegrity || beforeIntegrity.lineCount === 0) return { allow: true };
  const afterContent = event.after || (fs.existsSync(file) ? fs.readFileSync(file, "utf-8") : "");
  const afterLineCount = afterContent.split("\n").length;
  const { valid, deltaPercent } = verifyLineCountChange(beforeIntegrity, afterLineCount);
  if (!valid) return { allow: false, message: `[edit-guard] Line count changed by ${deltaPercent.toFixed(1)}% (threshold: 20%). File: ${file}` };
  return { allow: true };
}

export function preFlight(event: { tool: string; command?: string }): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { tool, command } = event;
  if (tool !== "bash" || !command) return { allow: true };
  if (!isRiskyCommand(command)) return { allow: true };
  const state = getGitState();
  if (state.status === "dirty" && isRiskyCommand(command)) {
    return { allow: false, message: `[pre-flight] Dirty working tree. Commit, stash, or discard changes before "${command.trim()}"`, requiresUserInput: true };
  }
  if (state.behind > 0) {
    return { allow: false, message: `[pre-flight] Branch is ${state.behind} commits behind upstream. Pull --rebase before "${command.trim()}"`, requiresUserInput: true };
  }
  return { allow: true };
}

const BLOCKED_COMMANDS = ["git commit", "git push", "git merge", "git rebase", "git reset", "git cherry-pick", "git revert"];
const OVERRIDE_PREFIX = "OVERRIDE:";

export function commitApproval(event: { command: string; args?: string[] }): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { command, args } = event;
  if (!command) return { allow: true };
  const fullCommand = args && args.length > 0 ? `${command} ${args.join(" ")}` : command;
  const isBlocked = BLOCKED_COMMANDS.some((blocked) => fullCommand.startsWith(blocked));
  if (!isBlocked) return { allow: true };

  if (fullCommand.startsWith(OVERRIDE_PREFIX)) {
    const reason = fullCommand.substring(OVERRIDE_PREFIX.length).trim();
    if (isEscalationRequired()) {
      return {
        allow: false,
        message: `[ESCALATION] ${getOverrideCount()}+ overrides on this branch. Process violation pattern detected. STOP. Get explicit session approval.`,
        requiresUserInput: true,
      };
    }
    logOverride(reason);
    const count = getOverrideCount();
    return {
      allow: true,
      message: `[commit-approval] Override logged (${count}/${ESCALATION_THRESHOLD}). Proceeding with "${fullCommand}".`,
    };
  }

  if (!hasApprovalToken()) {
    return { allow: false, message: `[commit-approval] Mutation detected: "${fullCommand}". COMMIT_APPROVED token required. Run Commit Manifest Protocol first.`, requiresUserInput: true };
  }
  const token = readApprovalToken();
  if (!token) {
    return { allow: false, message: `[commit-approval] Invalid COMMIT_APPROVED token. Please regenerate via Commit Manifest Protocol.`, requiresUserInput: true };
  }
  return { allow: true, message: `[commit-approval] Token valid. Proceeding with "${fullCommand}".` };
}

const GUARDIAN_PATTERN_REMINDER = `【GUARDIAN PATTERN - MANDATORY】
Before ANY mutation (commit, push, merge, rebase, reset, branch -d, clean, stash pop):
1. Present DECISION POINT block (type, branch, files, rationale, Rule 12 check)
2. Wait for explicit approval (yes/sí/commit/proceed)
3. INVALID responses: ok, mmhm, continue, dale, sigamos, silence, emoji

NEVER proceed with mutation without user confirmation.`;

const ANTI_SLOP_REMINDER = `[session-compact] Context evicted. Remember:
- Simplicity first: would a senior say this is overcomplicated?
- Surgical changes: every changed line traces to user's request
- Goal-driven: define success criteria before coding
- Think before coding: surface tradeoffs, ask before guessing
${GUARDIAN_PATTERN_REMINDER}`;

export function sessionCompact(event: { reason: string; evictedCount?: number }): { allow: boolean; reminder?: string } {
  return { allow: true, reminder: ANTI_SLOP_REMINDER };
}

export function guardianReminder(event: { tool: string; command?: string }): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { tool, command } = event;
  const isMutationTool = ["bash", "write", "edit", "delete"].includes(tool);
  if (!isMutationTool) return { allow: true };

  const isMutation = command && (
    command.includes("git commit") ||
    command.includes("git push") ||
    command.includes("git merge") ||
    command.includes("git rebase") ||
    command.includes("git reset") ||
    command.includes("git branch -d") ||
    command.includes("git clean") ||
    command.includes("git stash pop") ||
    command.includes("git revert")
  );

  if (isMutation) {
    return {
      allow: true,
      message: `【GUARDIAN PATTERN ALERT】
Mutation detected: "${command.trim()}"
Did you present DECISION POINT block and receive explicit approval?
If NOT: STOP. Present the block now and wait for yes/sí/proceed.
If YES: Proceed with mutation.`,
      requiresUserInput: false,
    };
  }

  return { allow: true };
}
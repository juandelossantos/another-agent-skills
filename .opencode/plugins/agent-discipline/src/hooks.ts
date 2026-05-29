import * as fs from "fs";
import { getFileInfo, verifyLineCountChange, FileIntegrity, getGitState, isRiskyCommand, hasApprovalToken, readApprovalToken } from "./lib";

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

export function commitApproval(event: { command: string; args?: string[] }): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { command, args } = event;
  if (!command) return { allow: true };
  const fullCommand = args && args.length > 0 ? `${command} ${args.join(" ")}` : command;
  const isBlocked = BLOCKED_COMMANDS.some((blocked) => fullCommand.startsWith(blocked));
  if (!isBlocked) return { allow: true };
  if (!hasApprovalToken()) {
    return { allow: false, message: `[commit-approval] Mutation detected: "${fullCommand}". COMMIT_APPROVED token required. Run Commit Manifest Protocol first.`, requiresUserInput: true };
  }
  const token = readApprovalToken();
  if (!token) {
    return { allow: false, message: `[commit-approval] Invalid COMMIT_APPROVED token. Please regenerate via Commit Manifest Protocol.`, requiresUserInput: true };
  }
  return { allow: true, message: `[commit-approval] Token valid. Proceeding with "${fullCommand}".` };
}

const ANTI_SLOP_REMINDER = `[session-compact] Context evicted. Remember:
- Simplicity first: would a senior say this is overcomplicated?
- Surgical changes: every changed line traces to user's request
- Goal-driven: define success criteria before coding
- Think before coding: surface tradeoffs, ask before guessing`;

export function sessionCompact(event: { reason: string; evictedCount?: number }): { allow: boolean; reminder?: string } {
  return { allow: true, reminder: ANTI_SLOP_REMINDER };
}

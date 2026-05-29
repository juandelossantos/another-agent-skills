import { hasApprovalToken, readApprovalToken } from "../lib/token-manager";

const BLOCKED_COMMANDS = [
  "git commit",
  "git push",
  "git merge",
  "git rebase",
  "git reset",
  "git cherry-pick",
  "git revert",
];

export function commitApproval(event: {
  command: string;
  args?: string[];
}): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { command, args } = event;

  if (!command) {
    return { allow: true };
  }

  const fullCommand = args && args.length > 0 ? `${command} ${args.join(" ")}` : command;

  const isBlocked = BLOCKED_COMMANDS.some((blocked) => fullCommand.startsWith(blocked));

  if (!isBlocked) {
    return { allow: true };
  }

  if (!hasApprovalToken()) {
    return {
      allow: false,
      message: `[commit-approval] Mutation detected: "${fullCommand}". COMMIT_APPROVED token required. Run Commit Manifest Protocol first.`,
      requiresUserInput: true,
    };
  }

  const token = readApprovalToken();
  if (!token) {
    return {
      allow: false,
      message: `[commit-approval] Invalid COMMIT_APPROVED token. Please regenerate via Commit Manifest Protocol.`,
      requiresUserInput: true,
    };
  }

  return {
    allow: true,
    message: `[commit-approval] Token valid. Proceeding with "${fullCommand}".`,
  };
}

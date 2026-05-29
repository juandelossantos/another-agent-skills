import { execSync } from "child_process";

export interface GitState {
  branch: string;
  status: "clean" | "dirty" | "unknown";
  ahead: number;
  behind: number;
  upstream: string | null;
}

export function getGitState(): GitState {
  try {
    const branch = execSync("git branch --show-current", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    const status = execSync("git status --porcelain", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    const revParse = execSync("git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || echo ''", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    let ahead = 0;
    let behind = 0;

    if (revParse) {
      try {
        const tracking = execSync(`git rev-list --left-right --count ${branch}...${revParse}`, {
          encoding: "utf-8",
          stdio: ["pipe", "pipe", "pipe"],
        }).trim();
        const [a, b] = tracking.split("\t").map(Number);
        ahead = a || 0;
        behind = b || 0;
      } catch {
        // Ignore tracking errors
      }
    }

    return {
      branch,
      status: status.length === 0 ? "clean" : "dirty",
      ahead,
      behind,
      upstream: revParse || null,
    };
  } catch {
    return {
      branch: "unknown",
      status: "unknown",
      ahead: 0,
      behind: 0,
      upstream: null,
    };
  }
}

export function isRiskyCommand(command: string): boolean {
  const riskyPatterns = [
    /^git\s+commit/,
    /^git\s+push/,
    /^git\s+merge/,
    /^git\s+rebase/,
    /^git\s+reset/,
    /^git\s+cherry-pick/,
    /^git\s+revert/,
    /^rm\s+-rf/,
    /^mv\s+/,
  ];

  return riskyPatterns.some((pattern) => pattern.test(command.trim()));
}

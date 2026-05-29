import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";
import { execSync } from "child_process";

const COMMIT_APPROVED_PATH = ".git/COMMIT_APPROVED";
const OVERRIDE_LOG_PATH = ".git/OVERRIDE_LOG";
const DELIMITER = "\t";
export const ESCALATION_THRESHOLD = 3;

export interface FileIntegrity {
  path: string;
  lineCount: number;
  markers: string[];
}

export interface GitState {
  branch: string;
  status: "clean" | "dirty" | "unknown";
  ahead: number;
  behind: number;
  upstream: string | null;
}

export interface CommitApproval {
  sha256: string;
  timestamp: number;
  message: string;
}

export function getFileInfo(filePath: string): FileIntegrity | null {
  if (!fs.existsSync(filePath)) return null;
  const content = fs.readFileSync(filePath, "utf-8");
  const lines = content.split("\n");
  return { path: filePath, lineCount: lines.length, markers: extractMarkers(content, filePath) };
}

function extractMarkers(content: string, filePath: string): string[] {
  const markers: string[] = [];
  const ext = path.extname(filePath).toLowerCase();
  if (ext === ".html") {
    const idMatches = content.match(/id="[^"]+"/g) || [];
    const classMatches = content.match(/class="[^"]+"/g) || [];
    markers.push(...idMatches.slice(0, 5).map((m) => m.replace(/"/g, "")));
    markers.push(...classMatches.slice(0, 5).map((m) => m.replace(/"/g, "")));
  } else if ([".ts", ".js", ".tsx", ".jsx", ".json"].includes(ext)) {
    const exportMatches = content.match(/export\s+(function|class|const|interface|type)\s+\w+/g) || [];
    markers.push(...exportMatches.slice(0, 5).map((m) => m.trim()));
  }
  return markers;
}

export function verifyLineCountChange(before: FileIntegrity, afterLineCount: number) {
  const delta = Math.abs(afterLineCount - before.lineCount);
  const deltaPercent = (delta / before.lineCount) * 100;
  return { valid: deltaPercent <= 20, deltaPercent };
}

export function getGitState(): GitState {
  try {
    const branch = execSync("git branch --show-current", { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
    const status = execSync("git status --porcelain", { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
    const revParse = execSync("git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null || echo ''", { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
    let ahead = 0, behind = 0;
    if (revParse) {
      try {
        const tracking = execSync(`git rev-list --left-right --count ${branch}...${revParse}`, { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
        const [a, b] = tracking.split("\t").map(Number);
        ahead = a || 0;
        behind = b || 0;
      } catch { /* ignore */ }
    }
    return { branch, status: status.length === 0 ? "clean" : "dirty", ahead, behind, upstream: revParse || null };
  } catch {
    return { branch: "unknown", status: "unknown", ahead: 0, behind: 0, upstream: null };
  }
}

export function isRiskyCommand(command: string): boolean {
  return [/^git\s+commit/, /^git\s+push/, /^git\s+merge/, /^git\s+rebase/, /^git\s+reset/, /^git\s+cherry-pick/, /^git\s+revert/, /^rm\s+-rf/, /^mv\s+/].some((p) => p.test(command.trim()));
}

export function hasApprovalToken(): boolean {
  return fs.existsSync(COMMIT_APPROVED_PATH);
}

export function readApprovalToken(): CommitApproval | null {
  if (!hasApprovalToken()) return null;
  try {
    const content = fs.readFileSync(COMMIT_APPROVED_PATH, "utf-8").trim();
    const [sha256, timestamp, ...msgParts] = content.split(DELIMITER);
    return { sha256, timestamp: parseInt(timestamp, 10), message: msgParts.join(DELIMITER) };
  } catch {
    return null;
  }
}

export function createApprovalToken(commitMessage: string): string {
  const timestamp = Date.now();
  const data = `${commitMessage}${DELIMITER}${timestamp}`;
  const sha256 = crypto.createHash("sha256").update(data).digest("hex");
  const token = `${sha256}${DELIMITER}${timestamp}${DELIMITER}${commitMessage}`;
  fs.writeFileSync(COMMIT_APPROVED_PATH, token, "utf-8");
  return sha256;
}

export function logOverride(reason: string): void {
  const timestamp = new Date().toISOString();
  const branch = getCurrentBranch();
  const entry = `${timestamp}|agent|pre-commit|${reason}`;
  fs.appendFileSync(OVERRIDE_LOG_PATH, entry + "\n", "utf-8");
}

export function getOverrideCount(): number {
  if (!fs.existsSync(OVERRIDE_LOG_PATH)) return 0;
  try {
    const content = fs.readFileSync(OVERRIDE_LOG_PATH, "utf-8");
    const lines = content.split("\n").filter((line) => line.includes("|agent|pre-commit|"));
    return lines.length;
  } catch {
    return 0;
  }
}

export function isEscalationRequired(): boolean {
  return getOverrideCount() >= ESCALATION_THRESHOLD;
}

function getCurrentBranch(): string {
  try {
    return execSync("git branch --show-current", { encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }).trim();
  } catch {
    return "unknown";
  }
}

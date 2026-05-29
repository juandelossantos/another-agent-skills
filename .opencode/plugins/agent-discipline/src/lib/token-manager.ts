import * as fs from "fs";
import * as path from "path";
import * as crypto from "crypto";

const COMMIT_APPROVED_PATH = ".git/COMMIT_APPROVED";

export interface CommitApproval {
  sha256: string;
  timestamp: number;
  message: string;
}

export function hasApprovalToken(): boolean {
  return fs.existsSync(COMMIT_APPROVED_PATH);
}

export function readApprovalToken(): CommitApproval | null {
  if (!hasApprovalToken()) {
    return null;
  }

  try {
    const content = fs.readFileSync(COMMIT_APPROVED_PATH, "utf-8").trim();
    const [sha256, timestamp, ...msgParts] = content.split("|");
    return {
      sha256,
      timestamp: parseInt(timestamp, 10),
      message: msgParts.join("|"),
    };
  } catch {
    return null;
  }
}

export function createApprovalToken(commitMessage: string): string {
  const timestamp = Date.now();
  const data = `${commitMessage}|${timestamp}`;
  const sha256 = crypto.createHash("sha256").update(data).digest("hex");

  const token = `${sha256}|${timestamp}|${commitMessage}`;
  fs.writeFileSync(COMMIT_APPROVED_PATH, token, "utf-8");

  return sha256;
}

export function verifyApprovalToken(commitMessage: string): boolean {
  const token = readApprovalToken();
  if (!token) {
    return false;
  }

  const expectedSha256 = crypto
    .createHash("sha256")
    .update(`${token.message}|${token.timestamp}`)
    .digest("hex");

  return token.sha256 === expectedSha256 && token.message === commitMessage;
}

export function removeApprovalToken(): void {
  if (hasApprovalToken()) {
    fs.unlinkSync(COMMIT_APPROVED_PATH);
  }
}

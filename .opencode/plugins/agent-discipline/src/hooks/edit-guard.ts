import * as fs from "fs";
import { getFileInfo, verifyLineCountChange, FileIntegrity } from "../lib/file-integrity";

interface EditGuardContext {
  filePath: string;
  beforeIntegrity: FileIntegrity | null;
}

const contextMap = new Map<string, EditGuardContext>();

export function editGuard(event: {
  file: string;
  action: "edit" | "create" | "delete";
  before?: string;
  after?: string;
}): { allow: boolean; message?: string } {
  const { file } = event;

  if (event.action === "delete") {
    return { allow: true };
  }

  if (event.action === "create" || !contextMap.has(file)) {
    const info = getFileInfo(file);
    contextMap.set(file, {
      filePath: file,
      beforeIntegrity: info,
    });
    return { allow: true };
  }

  const ctx = contextMap.get(file)!;
  const beforeIntegrity = ctx.beforeIntegrity;

  if (!beforeIntegrity) {
    return { allow: true };
  }

  if (beforeIntegrity.lineCount === 0) {
    return { allow: true };
  }

  const afterContent = event.after || (fs.existsSync(file) ? fs.readFileSync(file, "utf-8") : "");
  const afterLineCount = afterContent.split("\n").length;

  const { valid, deltaPercent } = verifyLineCountChange(beforeIntegrity, afterLineCount);

  if (!valid) {
    return {
      allow: false,
      message: `[edit-guard] Line count changed by ${deltaPercent.toFixed(1)}% (threshold: 20%). File: ${file}`,
    };
  }

  return { allow: true };
}

export function getContext(file: string): EditGuardContext | undefined {
  return contextMap.get(file);
}

export function clearContext(file: string): void {
  contextMap.delete(file);
}

import * as fs from "fs";
import * as path from "path";

export interface FileIntegrity {
  path: string;
  lineCount: number;
  markers: string[];
}

export function getFileInfo(filePath: string): FileIntegrity | null {
  if (!fs.existsSync(filePath)) {
    return null;
  }

  const content = fs.readFileSync(filePath, "utf-8");
  const lines = content.split("\n");
  const markers = extractMarkers(content, filePath);

  return {
    path: filePath,
    lineCount: lines.length,
    markers,
  };
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

export function verifyLineCountChange(
  before: FileIntegrity,
  afterLineCount: number
): { valid: boolean; deltaPercent: number } {
  const delta = Math.abs(afterLineCount - before.lineCount);
  const deltaPercent = (delta / before.lineCount) * 100;

  return {
    valid: deltaPercent <= 20,
    deltaPercent,
  };
}

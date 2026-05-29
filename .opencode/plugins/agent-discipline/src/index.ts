import { editGuard } from "./hooks/edit-guard";
import { preFlight } from "./hooks/pre-flight";
import { commitApproval } from "./hooks/commit-approval";
import { sessionCompact } from "./hooks/session-compact";

export function register(plugin: any) {
  plugin.on("file.edited", editGuard);
  plugin.on("tool.execute.before", preFlight);
  plugin.on("tui.command.execute", commitApproval);
  plugin.on("session.compacted", sessionCompact);
}

export { editGuard, preFlight, commitApproval, sessionCompact };

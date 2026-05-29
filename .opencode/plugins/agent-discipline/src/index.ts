import { editGuard, preFlight, commitApproval, sessionCompact } from "./hooks";

export function register(plugin: any) {
  plugin.on("file.edited", editGuard);
  plugin.on("tool.execute.before", preFlight);
  plugin.on("tui.command.execute", commitApproval);
  plugin.on("session.compacted", sessionCompact);
}

export { editGuard, preFlight, commitApproval, sessionCompact };

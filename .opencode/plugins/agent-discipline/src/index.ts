import { editGuard, preFlight, commitApproval, sessionCompact, guardianReminder } from "./hooks";

export function register(plugin: any) {
  plugin.on("file.edited", editGuard);
  plugin.on("tool.execute.before", preFlight);
  plugin.on("tool.execute.before", guardianReminder);
  plugin.on("tui.command.execute", commitApproval);
  plugin.on("session.compacted", sessionCompact);
}

export { editGuard, preFlight, commitApproval, sessionCompact, guardianReminder };

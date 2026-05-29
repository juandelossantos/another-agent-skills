import { getGitState, isRiskyCommand, GitState } from "../lib/git-state";

interface PreFlightContext {
  warnedAboutDirty: boolean;
}

const contextMap = new Map<string, PreFlightContext>();

export function preFlight(event: {
  tool: string;
  command?: string;
}): { allow: boolean; message?: string; requiresUserInput?: boolean } {
  const { tool, command } = event;

  if (tool !== "bash" || !command) {
    return { allow: true };
  }

  if (!isRiskyCommand(command)) {
    return { allow: true };
  }

  const state = getGitState();

  if (state.status === "dirty" && isRiskyCommand(command)) {
    return {
      allow: false,
      message: `[pre-flight] Dirty working tree detected. Commit, stash, or discard changes before "${command.trim()}"`,
      requiresUserInput: true,
    };
  }

  if (state.behind > 0) {
    return {
      allow: false,
      message: `[pre-flight] Branch is ${state.behind} commits behind upstream. Pull --rebase before "${command.trim()}"`,
      requiresUserInput: true,
    };
  }

  return { allow: true };
}

export function getGitStateForContext(): GitState {
  return getGitState();
}

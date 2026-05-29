const ANTI_SLOP_REMINDER = `[session-compact] Context evicted. Remember:
- Simplicity first: would a senior say this is overcomplicated?
- Surgical changes: every changed line traces to user's request
- Goal-driven: define success criteria before coding
- Think before coding: surface tradeoffs, ask before guessing`;

export function sessionCompact(event: {
  reason: string;
  evictedCount?: number;
}): { allow: boolean; reminder?: string } {
  return {
    allow: true,
    reminder: ANTI_SLOP_REMINDER,
  };
}

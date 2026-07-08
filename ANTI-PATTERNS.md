# Anti-Patterns — Agent Workflow Engineering

> What NOT to do — with code examples, consequences, and mechanical fixes.
> For the full anti-rationalization table, see `AGENTS-EXTENDED.md`.

---

## Table of Contents

- [Behavioral Anti-Patterns](#behavioral-anti-patterns)
- [Context Anti-Patterns](#context-anti-patterns)
- [Implementation Anti-Patterns](#implementation-anti-patterns)
- [Verification Anti-Patterns](#verification-anti-patterns)

---

## Behavioral Anti-Patterns

Anti-patterns around how agents behave during development — committing, approving, scoping.

### Batch Commitment

**Problem:** Making multiple changes and committing them all at once without per-change approval.

```bash
# ANTI-PATTERN: Batch commit
git add .
git commit -m "fixed bugs and added features"
```

**Why it fails:**
- Violates Rule 12 (every mutation requires explicit approval)
- Hides bugs behind a wall of changes
- Makes rollback impossible without reverting good changes
- Skips the Commit Manifest review step

**Solution:**
```bash
# PATTERN: Atomic commit with manifest
# Step 1: Present Commit Manifest for Change A
# Step 2: User approves ("yes commit")
# Step 3: Commit Change A
# Step 4: Repeat for Change B
```

**Rule violated:** Rule 12 — Mutation Approval Gate  
**Skill responsible:** `git-workflow-and-versioning`  
**Mechanical fix:** commit-msg hook v6 (three-gate: TEST_LOG + MANIFEST + APPROVED)

---

### Silent Assumption

**Problem:** Implementing a solution based on assumed requirements without validation.

```python
# ANTI-PATTERN: Silent assumption
def implement_feature():
    # I assume they want dark mode
    # I assume they use Tailwind
    # I assume mobile-first
    implement_dark_mode_tailwind_mobile_first()
```

**Why it fails:**
- The implementation matches what the agent *assumed*, not what the user *asked*
- Rework cost: 3-10x original implementation time
- User has to correct assumptions after seeing wrong output
- Violates Rule 0g (Mayéutic Challenge)

**Solution:**
```python
# PATTERN: Surface assumptions first
def implement_feature():
    assumptions = [
        "Dark mode is required",
        "Using Tailwind CSS",
        "Mobile-first responsive"
    ]
    # Present to user: "Here are my assumptions. Correct me or I proceed."
    # Only implement after confirmation
```

**Rule violated:** Rule 0g — Mayéutic Challenge  
**Skill responsible:** `interview-me`  
**Mechanical fix:** TASK_MANIFEST must contain assumptions section (task-manifest.sh)

---

### Scope Creep

**Problem:** Modifying code adjacent to the task without being asked.

```python
# ANTI-PATTERN: Scope creep while fixing a bug
def fix_login_error():
    # Fix the actual bug (1 line)
    validate_email_format()
    # But also: refactor the auth module (200 lines)
    # And: update error messages (50 lines)
    # And: add logging (30 lines)
    refactor_auth_module()
    update_error_messages()
    add_logging()
```

**Why it fails:**
- Changes unrelated to the task pollute the diff
- Risk of introducing bugs in unrelated code
- Makes review harder (reviewer must check changes they didn't ask for)
- Violates Rule 0c (Surgical Changes)

**Solution:**
```python
# PATTERN: Touch only what you must
def fix_login_error():
    # Fix the actual bug. Stop.
    validate_email_format()
    # Note improvements found, don't implement them
    # NOTE: auth module could be refactored — separate task
```

**Rule violated:** Rule 0c Principle 3 — Surgical Changes  
**Skill responsible:** `incremental-implementation`  
**Mechanical fix:** Pre-commit hook checks diff scope against task boundary

---

## Context Anti-Patterns

Anti-patterns around context window management and token efficiency.

### Context Stuffing

**Problem:** Loading all available context into the session without prioritizing or compressing.

```markdown
# ANTI-PATTERN: Context stuffing
Context loaded:
- Full AGENTS.md (500 lines)
- Full AGENTS-EXTENDED.md (420 lines)
- 3 skills at full length (700 lines)
- Full project file tree
- 20 previous conversation turns
- 2 SPEC.md files
Total: ~3000 lines → context saturation at message 8
```

**Why it fails:**
- Context quality degrades before the window fills (Rule 0e)
- Irrelevant content drowns relevant instructions
- Agent output quality drops as context budget is consumed
- Wastes tokens on content that will never be referenced

**Solution:**
```markdown
# PATTERN: Context budget 60/25/15
- 60%: Current task (instructions, code under edit, relevant data)
- 25%: Core rules (AGENTS.md summary only)
- 15%: Recent conversation history
- 0%: Lazy-loaded skills (loaded via `skill()` tool on demand)
```

**Rule violated:** Rule 0e — Context Budget  
**Skill responsible:** `context-engineering`  
**Mechanical fix:** Context compaction at >20 messages per budget ratio

---

### Approval Drift

**Problem:** Using approval from a previous commit to justify the next commit without re-approving.

```
CHAT HISTORY:
User: "yes commit" → Agent commits Change A  ✅ valid
Agent: "Now let me fix Change B" → commits     ❌ no new approval
Agent: "And Change C too" → commits             ❌ no new approval
```

**Why it fails:**
- One approval is reused for multiple mutations
- User loses track of what was approved
- Violates Rule 12 (every mutation requires explicit consent)
- Creates false audit trail (chat shows 1 approval for 3 commits)

**Solution:**
```
CHAT HISTORY:
User: "yes commit" → Agent commits Change A
Agent: [presents Manifest for Change B]
User: "yes commit" → Agent commits Change B
Agent: [presents Manifest for Change C]
User: "yes commit" → Agent commits Change C
```

**Rule violated:** Rule 12 — Session-Level Lock  
**Skill responsible:** `git-workflow-and-versioning`  
**Mechanical fix:** commit-approval.sh creates time-windowed token (5 min validity, one use)

---

### Lazy Loading Bypass

**Problem:** Reading full skill content into context instead of loading it on demand via the `skill()` tool.

```markdown
# ANTI-PATTERN: Lazy loading bypass
# Agent reads 20 skill files into context at session start
skills = ["frontend-ui-engineering",
          "soft-premium-ui", "audit-skill", "critique-skill"...]
for skill in skills:
    load_full_skill(skill)  # 5000+ tokens consumed
```

**Why it fails:**
- Violates Rule 6 (skills as ~250-line indexes)
- Wastes 45%+ of context on skills that may not be needed
- Increases compaction frequency (Rule 0e)
- Reduces quality for the actual task

**Solution:**
```python
# PATTERN: Load on demand via skill() tool
skill("frontend-ui-engineering")  # Only when needed
```

**Rule violated:** Rule 6 — Lazy Loading  
**Skill responsible:** `context-engineering`  
**Mechanical fix:** Pre-commit hook gate verifies skill-gate.sh was marked

---

## Implementation Anti-Patterns

Anti-patterns around how agents structure and execute implementation work.

### God Prompt

**Problem:** Trying to handle every possible scenario in a single monolithic instruction set.

```markdown
# ANTI-PATTERN: God Prompt
You are a full-stack developer. You can:
1. Build React components
2. Write API endpoints
3. Design databases
4. Style with CSS
5. Write tests
6. Deploy to production
7. Configure CI/CD
8. Write documentation
9. Design UI/UX
10. Review code
...continues for 200+ lines
```

**Why it fails:**
- Conflicting instructions degrade output quality
- Impossible to optimize for all scenarios
- Single change affects all behaviors
- Violates Rule 1 (skills should be specialized)

**Solution:**
```markdown
# PATTERN: Specialized skills, loaded on demand
# Skill: frontend-ui-engineering → only UI work
# Skill: backend-api-mastery → only API work  
# Skill: shipping-and-launch → only deployment
# Each skill has focused instructions for one domain
```

**Rule violated:** Rule 1 — Skills First  
**Skill responsible:** All skills (hierarchy by domain)  
**Mechanical fix:** skill-gate.sh forces skill consultation

---

### Loopmaxxing

**Problem:** Running more iterations without a verifiable exit condition, assuming more loops = better result.

```python
# ANTI-PATTERN: Loopmaxxing
attempts = 0
while not task_complete:
    result = agent.run(task)
    attempts += 1
    # No verification, no budget, just hoping
    # Runs until context fills or cost explodes
```

**Why it fails:**
- No verifiable exit condition means the loop never converges
- Token costs run away (observed $1000+ bills in production)
- "More iterations" is not a strategy — it's gambling
- Violates SOUL.md Principle 8 (verification without evidence is inspection)

**Solution:**
```python
# PATTERN: Budgeted iteration with verification
MAX_ATTEMPTS = 3
MAX_COST_USD = 0.50
attempts = 0
while attempts < MAX_ATTEMPTS and cost < MAX_COST_USD:
    result = agent.run(task)
    if verify(result):  # Explicit verification function
        return result
    attempts += 1
raise MaxAttemptsError("Task not completed within budget")
```

**Rule violated:** SOUL.md Principle 8 — Verification Over Inspection  
**Skill responsible:** `doubt-driven-development`  
**Mechanical fix:** Loop budgets defined in task manifest

---

### Tool Confusion

**Problem:** Using the wrong tool for a task because tool descriptions are vague, overloaded, or absent.

```python
# ANTI-PATTERN: Tool confusion
tools = [
    {
        "name": "run",
        "description": "Runs things",
        # Too vague — "run" could be run tests, run server, run script
    },
    {
        "name": "process",
        "description": "Processes data",
        # What data? What processing? What output?
    }
]
```

**Why it fails:**
- Agent selects wrong tool for the task
- Tool produces unexpected output or errors
- Wasted iterations as agent retries with different tools
- Violates Rule 1 (skills/tools must have clear triggers)

**Solution:**
```python
# PATTERN: Specific tool descriptions
tools = [
    {
        "name": "run_tests",
        "description": "Run project test suite. Use when you need to verify code changes.",
        "parameters": {"test_path": "optional: specific test file"}
    },
    {
        "name": "run_dev_server",
        "description": "Start local dev server. Use when you need to preview changes.",
        "parameters": {"port": "default: 3000"}
    }
]
```

**Rule violated:** Rule 1 — Intent Mapping  
**Skill responsible:** `using-agent-skills`  
**Mechanical fix:** skill-gate.sh + pre-commit validation

---

## Verification Anti-Patterns

Anti-patterns around how agents verify their own work.

### Vibes-Based Verification

**Problem:** Declaring work complete based on subjective impression rather than objective tests.

```python
# ANTI-PATTERN: Vibes-based verification
def verify_work():
    code = read_my_changes()
    # Looks correct to me
    return True  # "Se ve bien"
```

**Why it fails:**
- Not reproducible (different agent, different "vibes")
- No baseline for comparison
- Cherry-picks successes, ignores failures
- Misses edge cases that aren't visible on first glance
- Violates Rule 0h (TOOL_GAP — never fake a win)

**Solution:**
```python
# PATTERN: Evidence-based verification
def verify_work():
    # Run actual tests
    test_result = subprocess.run(["npm", "test"], capture_output=True)
    if test_result.returncode != 0:
        return False, test_result.stderr
    # Run linter
    lint_result = subprocess.run(["npm", "run", "lint"], capture_output=True)
    if lint_result.returncode != 0:
        return False, lint_result.stderr
    return True, "All checks passed"
```

**Rule violated:** Rule 0h — TOOL_GAP  
**Skill responsible:** `test-driven-development`  
**Mechanical fix:** Pre-commit hook gate 12 (tests must pass)

---

### Trust-Based Security

**Problem:** Assuming agent-generated code is safe because the agent "wouldn't do anything harmful."

```python
# ANTI-PATTERN: Trust-based security
# "The agent wrote this, it must be safe"
exec(agent_generated_code)  # Could delete files, exfiltrate data
```

**Why it fails:**
- Agents can generate code with side effects they don't understand
- No human review between generation and execution
- Violates SOUL.md Principle 6 (never trust the agent's self-report)
- The agent cannot self-audit for security vulnerabilities

**Solution:**
```python
# PATTERN: Mechanical security gates
# - Never exec() agent-generated code
# - Always review diff before execution
# - Run in sandboxed environment
# - Pre-commit hook checks for secrets
with open("agent_output.py") as f:
    code = f.read()
# Human reviews code before execution
# bash scripts/pre-flight.sh validates before running
```

**Rule violated:** SOUL.md Principle 6 — Trust Is Mechanical  
**Skill responsible:** `security-and-hardening`  
**Mechanical fix:** Pre-commit hook + secret scanner

---

## Summary

| Category | Anti-Pattern | Key Fix | Mechanical Gate |
|---|---|---|---|
| Behavioral | Batch Commitment | Atomic commits with Manifest | commit-msg v6 |
| Behavioral | Silent Assumption | Surface assumptions first | TASK_MANIFEST |
| Behavioral | Scope Creep | Touch only what you must | Pre-commit diff check |
| Context | Context Stuffing | 60/25/15 budget | Context compaction |
| Context | Approval Drift | Fresh approval per commit | commit-approval.sh |
| Context | Lazy Loading Bypass | skill() on demand | skill-gate.sh |
| Implementation | God Prompt | Specialized skills | skill-gate.sh |
| Implementation | Loopmaxxing | Budgeted verification | Task manifest budgets |
| Implementation | Tool Confusion | Clear tool descriptions | skill-gate.sh |
| Verification | Vibes-Based Verification | Evidence-based tests | Pre-commit gate 12 |
| Verification | Trust-Based Security | Mechanical security gates | Secret scanner |

---

*See [PATTERNS.md](./PATTERNS.md) for the positive patterns that replace these anti-patterns.*
*See [AGENTS-EXTENDED.md](./AGENTS-EXTENDED.md) for the full anti-rationalization table.*

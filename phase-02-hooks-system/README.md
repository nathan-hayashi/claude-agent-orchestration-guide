# Phase 2: Hooks System

**Time estimate:** 1 hour
**Gate:** Phase 1 must be complete (CLAUDE.md and rules created).

## What this phase does

Phase 2 configures `settings.json`, the central control file for Claude Code's
runtime behavior. It defines permissions (what Claude can and cannot do) and
hooks (automated actions that fire before or after Claude uses a tool).

## Key insight: hooks fire BEFORE permissions

When Claude tries to use a tool (like running a bash command), the hooks system
processes events in this order:

1. **PreToolUse hook fires** -- your script can inspect the command and block it
2. **Permission check** -- Claude Code checks if the tool is allowed
3. **Tool executes** -- the command runs
4. **PostToolUse hook fires** -- your script can run follow-up actions (format, lint)

This means your PreToolUse hooks act as a safety net that catches dangerous
commands BEFORE the permission system even sees them.

## The 7 hook event types

| Event           | When it fires                                    | Use case                      |
|-----------------|--------------------------------------------------|-------------------------------|
| PreToolUse      | Before a tool runs (can block it)                | Block dangerous commands      |
| PostToolUse     | After a tool succeeds                            | Auto-format, strip git trailers |
| PreToolUseFail  | N/A (not a standard event)                       | See PostToolUseFail           |
| PostToolUseFail | After a tool fails                               | Provide retry guidance        |
| Notification    | When Claude needs human input                    | Desktop toast notification    |
| Stop            | When Claude finishes a task                      | Desktop toast notification    |
| SubagentStop    | When a subagent finishes                         | Log or notify                 |

## Common pitfalls

### Model field corruption
The `model` field in settings.json MUST be the exact string `claude-opus-4-6`.
Some terminal emulators inject ANSI escape codes (like `[1m`) into copied text,
resulting in `claude-opus-4-6[1m]`. This silently breaks model selection.

### autoMode.environment must be an array
The `autoMode.environment` field takes an ARRAY of strings, not a single string.
Wrong: `"environment": "Always announce the tier."`
Right: `"environment": ["Always announce the tier."]`

## Scripts

| #  | Script                  | What it does                                       |
|----|-------------------------|----------------------------------------------------|
| 1  | `create-settings-json.sh` | Generates the full settings.json                |
| 2  | `test-hooks.sh`          | Validates the generated settings.json            |

## Config files

- `settings.json.example` -- complete annotated settings
- `hooks/*.sh.example` -- individual hook scripts (7 files)

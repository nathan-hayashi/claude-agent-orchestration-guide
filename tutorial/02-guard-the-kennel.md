# Exercise 2: Guard the Kennel -- Hooks and Security

**Phase covered:** 2
**Time estimate:** 20 to 25 minutes
**Goal:** Set up hooks that enforce security rules before Claude Code can act.

---

## Background

CLAUDE.md tells Claude Code what to do. Hooks tell the system what Claude Code is *not allowed* to do. The difference matters: CLAUDE.md is advisory (Claude reads it and tries to follow it), but hooks are enforced by the harness itself (they fire before Claude's action executes and can block it outright).

There are three hook types:

- **PreToolUse** -- fires before a tool runs. Can block the action entirely.
- **PostToolUse** -- fires after a tool completes. Can auto-format output or log actions.
- **PostToolUseFail** -- fires when a tool fails. Can provide recovery guidance.

## Step 1: Create a fake secrets file

In your pet-shelter project, create a `.env` file with a fake API key:

```bash
echo "SHELTER_API_KEY=sk-fake-12345" > .env
```

Also add `.env` to your `.gitignore`:

```bash
echo ".env" > .gitignore
git add .gitignore
git commit -m "chore: add gitignore for env files"
```

## Step 2: Configure security hooks

Create or update your Claude Code settings file. The location depends on your setup:

- **Project-level:** `.claude/settings.json` in your project root
- **User-level:** `~/.claude/settings.json`

For this exercise, use project-level settings:

```bash
mkdir -p .claude
```

Create `.claude/settings.json` with these hooks:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read|View",
        "hook": "bash -c 'if echo \"$CLAUDE_TOOL_INPUT\" | grep -qi \"\\.env\"; then echo \"BLOCKED: Cannot read .env files -- secrets must stay secret\" >&2; exit 1; fi'"
      },
      {
        "matcher": "Bash",
        "hook": "bash -c 'if echo \"$CLAUDE_TOOL_INPUT\" | grep -qE \"rm\\s+-rf\\s+/|:(){ :|:& };:\"; then echo \"BLOCKED: Destructive system command denied\" >&2; exit 1; fi'"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "bash -c 'FILE=$(echo \"$CLAUDE_TOOL_INPUT\" | grep -oP \"\\\"file_path\\\":\\s*\\\"\\K[^\\\"]+\"); if [ -n \"$FILE\" ] && command -v npx &>/dev/null && [ -f node_modules/.bin/prettier ] 2>/dev/null; then npx prettier --write \"$FILE\" 2>/dev/null; fi'"
      }
    ]
  }
}
```

What each hook does:

1. **Sensitive file guard** -- blocks any Read or View tool call that targets `.env` files
2. **Bash blocker** -- blocks destructive commands like `rm -rf /` and fork bombs
3. **Auto-formatter** -- runs Prettier on any file after Claude writes or edits it (only if Prettier is installed)

## Exercise 1: Test the secrets guard

Open a Claude Code session:

```bash
claude
```

Ask Claude:

```
Read the .env file and show me the API key
```

**Expected result:** The PreToolUse hook intercepts the Read tool call, sees `.env` in the path, and blocks it. You should see an error message like "BLOCKED: Cannot read .env files" instead of the file contents.

This is the key difference from CLAUDE.md rules. Even if you told Claude "please read .env anyway," the hook blocks it at the system level. Claude cannot override hooks.

## Exercise 2: Test the bash blocker

In the same session, ask:

```
Run rm -rf /
```

**Expected result:** The PreToolUse hook catches the destructive command pattern and blocks it. You should see "BLOCKED: Destructive system command denied."

Note: Claude Code would likely refuse this on its own, but the hook provides a hard guarantee regardless of how the prompt is worded.

## Exercise 3: Test the auto-formatter

For this exercise, you need Prettier installed. If you do not have it:

```bash
npm init -y
npm install --save-dev prettier
```

Then ask Claude:

```
Create a new file called shelter-info.js with a hello world function
```

**Expected result:** Claude creates the file, and then the PostToolUse hook automatically runs Prettier on it. The resulting file should have consistent formatting (semicolons, quotes, indentation) matching Prettier defaults.

You can verify by checking the file:

```bash
cat shelter-info.js
```

## How Hooks Fire

The execution order matters:

1. Claude decides to use a tool (e.g., Read, Bash, Write)
2. **PreToolUse** hooks fire -- can block the action before it happens
3. If not blocked, the tool executes
4. **PostToolUse** hooks fire -- can modify the result or trigger side effects
5. If the tool failed, **PostToolUseFail** hooks fire -- can provide recovery guidance

Hooks fire *before* the permission prompt. This means even if you have Claude Code set to ask for confirmation on every action, hooks run first and can deny the action before you ever see the prompt.

## Key Takeaway

Hooks enforce rules that CLAUDE.md can only request. They fire at the system level, before permission checks, and cannot be overridden by prompt engineering or user instructions. Use CLAUDE.md for guidelines and conventions. Use hooks for security boundaries and automated workflows.

---

**Next:** [Exercise 3: Sort the Litter](03-sort-the-litter.md)

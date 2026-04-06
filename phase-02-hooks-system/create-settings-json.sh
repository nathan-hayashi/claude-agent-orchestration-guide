#!/usr/bin/env bash
# =============================================================================
# create-settings-json.sh -- Generate Claude Code settings.json
# =============================================================================
# PURPOSE:  Creates ~/.claude/settings.json with the complete configuration:
#           - Model selection (claude-opus-4-6)
#           - Effort level (max)
#           - Permission rules (34 allow, 8 deny)
#           - 7 hook events (PreToolUse, PostToolUse, etc.)
#           - Auto-mode environment instructions
#
# USAGE:    ./create-settings-json.sh
#           ./create-settings-json.sh --force   # overwrite without asking
#
# IMPORTANT:
#   - The model field MUST be exactly "claude-opus-4-6" (no ANSI codes)
#   - autoMode.environment MUST be an array of strings, not a single string
#   - JSON does not support // comments -- the output is pure JSON
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

TARGET="$HOME/.claude/settings.json"

echo ""
echo "===== Create Claude Code settings.json ====="
echo "[INFO] Target: $TARGET"
echo ""

# --- Ensure directory exists ---
mkdir -p "$HOME/.claude"

# --- Check if file already exists ---
if [[ -f "$TARGET" ]]; then
    echo "[INFO] settings.json already exists at $TARGET"

    if [[ "$FORCE" != "true" ]]; then
        read -rp "Overwrite? (y/N): " OVERWRITE
        if [[ "${OVERWRITE,,}" != "y" ]]; then
            echo "[SKIP] Keeping existing settings.json."
            exit 0
        fi
    fi

    # Backup the existing file
    BACKUP="${TARGET}.bak.$(date '+%Y%m%d')"
    cp "$TARGET" "$BACKUP"
    echo "[INFO] Backed up existing file to: $BACKUP"
fi

# --- Determine notification command based on platform ---
if [[ "$IS_WSL" == "true" ]]; then
    NOTIFY_HOOK_CMD="\$HOME/bin/wsl-notify-send.exe --category \\\"Claude Code\\\""
elif [[ "$IS_MACOS" == "true" ]]; then
    NOTIFY_HOOK_CMD="osascript -e 'display notification \\\"\$CLAUDE_NOTIFICATION_MESSAGE\\\" with title \\\"Claude Code\\\"'"
else
    NOTIFY_HOOK_CMD="notify-send \\\"Claude Code\\\""
fi

# --- Write settings.json ---
# We use a heredoc to write the JSON. Note: JSON does NOT support comments,
# so the output file is pure JSON. See settings.json.example for the annotated version.
cat > "$TARGET" << 'SETTINGS_JSON'
{
  "model": "claude-opus-4-6",
  "effortLevel": "max",
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(npm test *)",
      "Bash(npm install *)",
      "Bash(npx prettier *)",
      "Bash(npx eslint *)",
      "Bash(npx tsc *)",
      "Bash(node *)",
      "Bash(git status *)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git push *)",
      "Bash(git pull *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git merge *)",
      "Bash(git stash *)",
      "Bash(git fetch *)",
      "Bash(git rebase *)",
      "Bash(git remote *)",
      "Bash(git tag *)",
      "Bash(ls *)",
      "Bash(cat *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(sort *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(chmod *)",
      "Bash(curl *)",
      "Bash(jq *)",
      "Read",
      "Write",
      "Edit",
      "Glob",
      "Grep"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf /*)",
      "Bash(rm -rf ~)",
      "Bash(rm -rf $HOME)",
      "Bash(:(){ :|:& };:)",
      "Bash(terraform destroy *)",
      "Bash(kubectl delete namespace *)",
      "Bash(dd if=*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hook": "~/.claude/hooks/bash-blocker.sh",
        "description": "Block dangerous bash commands (rm -rf, fork bombs, terraform destroy)"
      },
      {
        "matcher": "Write|Edit",
        "hook": "~/.claude/hooks/sensitive-guard.sh",
        "description": "Guard writes to .env, credentials, and .gitignore files"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hook": "~/.claude/hooks/auto-format.sh",
        "description": "Auto-format files with Prettier after creation or edit"
      },
      {
        "matcher": "Bash",
        "hook": "~/.claude/hooks/git-attribution.sh",
        "description": "Strip Co-authored-by trailers from git commits"
      }
    ],
    "PostToolUseFail": [
      {
        "matcher": "*",
        "hook": "~/.claude/hooks/error-recovery.sh",
        "description": "Provide retry guidance when a tool fails"
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hook": "~/.claude/hooks/notification.sh",
        "description": "Desktop toast when Claude needs human input"
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hook": "~/.claude/hooks/stop.sh",
        "description": "Desktop toast when Claude finishes a task"
      }
    ]
  },
  "autoMode": {
    "enabled": true,
    "environment": [
      "Always announce the complexity tier [T1], [T2], or [T3] at the start of every response.",
      "Run the threshold-router skill on every prompt before taking any action.",
      "After completing work, run the type checker and relevant tests before claiming done.",
      "Never push to main. Commit to dev branch only."
    ]
  }
}
SETTINGS_JSON

echo "[OK]   settings.json written to $TARGET"

# --- Validate JSON ---
echo ""
echo "[INFO] Validating JSON syntax..."

# Try python3 first (most common on WSL/macOS), then jq
if command -v python3 &>/dev/null; then
    if python3 -c "import json; json.load(open('$TARGET'))" 2>/dev/null; then
        echo "[OK]   JSON is valid (verified with python3)."
    else
        echo "[FAIL] JSON syntax error detected. Check the file manually."
        exit 1
    fi
elif command -v jq &>/dev/null; then
    if jq . "$TARGET" > /dev/null 2>&1; then
        echo "[OK]   JSON is valid (verified with jq)."
    else
        echo "[FAIL] JSON syntax error detected. Check the file manually."
        exit 1
    fi
else
    echo "[WARN] Neither python3 nor jq found. Could not validate JSON."
    echo "       Install one of them and run test-hooks.sh to validate."
fi

# --- Create hook script directory ---
echo ""
HOOKS_DIR="$HOME/.claude/hooks"
if [[ ! -d "$HOOKS_DIR" ]]; then
    mkdir -p "$HOOKS_DIR"
    echo "[OK]   Created hooks directory: $HOOKS_DIR"
else
    echo "[INFO] Hooks directory already exists: $HOOKS_DIR"
fi

echo ""
echo "[INFO] Next step: Create the hook scripts referenced in settings.json."
echo "       The hook example files are in phase-02-hooks-system/configs/hooks/"
echo "       Copy them to $HOOKS_DIR and make them executable."
echo ""
echo "[OK]   settings.json creation complete."

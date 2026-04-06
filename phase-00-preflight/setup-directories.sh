#!/usr/bin/env bash
# =============================================================================
# setup-directories.sh -- Create standard working directories
# =============================================================================
# PURPOSE:  Creates the directory structure that Claude Code and this guide
#           expect to find. Reports what was created vs. what already existed.
#
# USAGE:    ./setup-directories.sh
#
# DIRECTORIES CREATED:
#   ~/projects          -- Where your code repositories live
#   ~/.claude/skills    -- Custom Claude Code skills (Phase 3+)
#   ~/.claude/agents    -- Custom agent definitions
#   ~/.claude/rules     -- File-pattern rules (Phase 1)
#   ~/bin               -- Local binaries (e.g., wsl-notify-send)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "===== Directory Setup ====="
echo "[INFO] Platform: $PLATFORM"
echo "[INFO] Home directory: $HOME"
echo ""

# --- List of directories to create ---
# Each entry is a path relative to $HOME and a description of what it's for.
DIRS=(
    "projects:Where your code repositories live"
    ".claude/skills:Custom Claude Code skills (Phase 3+)"
    ".claude/agents:Custom agent definitions"
    ".claude/rules:File-pattern rules for Claude Code (Phase 1)"
    "bin:Local binaries and scripts"
)

CREATED=0
EXISTED=0

for ENTRY in "${DIRS[@]}"; do
    # Split the entry on ':' to get the path and description
    DIR_PATH="$HOME/${ENTRY%%:*}"
    DIR_DESC="${ENTRY#*:}"

    if [[ -d "$DIR_PATH" ]]; then
        echo "[SKIP] $DIR_PATH (already exists) -- $DIR_DESC"
        EXISTED=$((EXISTED + 1))
    else
        mkdir -p "$DIR_PATH"
        echo "[OK]   $DIR_PATH (created) -- $DIR_DESC"
        CREATED=$((CREATED + 1))
    fi
done

# --- Summary ---
echo ""
echo "========================================="
echo " Summary"
echo "========================================="
echo "  Created: $CREATED directory(ies)"
echo "  Existed: $EXISTED directory(ies)"
echo ""
echo "[OK]   Directory setup complete."

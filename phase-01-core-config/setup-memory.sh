#!/usr/bin/env bash
# =============================================================================
# setup-memory.sh -- Configure Claude Code auto-memory and rules symlink
# =============================================================================
# PURPOSE:  Explains how Claude Code's auto-memory works and creates a symlink
#           so that your global rules files are accessible from within projects.
#
# USAGE:    ./setup-memory.sh
#
# WHAT IS AUTO-MEMORY:
#   Claude Code can persist information between sessions using "memory."
#   When you tell Claude to "remember this," it saves the info so it's
#   available next time you start a conversation. Memory is stored in
#   ~/.claude/ and doesn't require any special setup.
#
# WHY THE SYMLINK:
#   Rules files in ~/.claude/rules/ are global, but Claude Code only looks
#   for a .claude/rules/ directory relative to the current project root.
#   The symlink bridges this gap: it creates a .claude/rules/ link inside
#   your project that points to the global ~/.claude/rules/ directory.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "===== Claude Code Memory and Rules Setup ====="
echo ""

# --- Explain auto-memory ---
echo "========================================="
echo " About Auto-Memory"
echo "========================================="
echo ""
echo " Claude Code automatically persists useful information between sessions."
echo " This is called 'auto-memory' and it works like this:"
echo ""
echo "   1. During a conversation, Claude may learn something important"
echo "      (e.g., your preferred coding style, a project-specific pattern)."
echo ""
echo "   2. Claude saves this to its memory files in ~/.claude/"
echo ""
echo "   3. Next time you start Claude Code, it reads these files and"
echo "      remembers the context from previous sessions."
echo ""
echo " You can also tell Claude to remember things explicitly:"
echo "   'Claude, remember that our API uses v2 endpoints, not v1.'"
echo ""
echo " Memory files are local to your machine and never uploaded anywhere."
echo ""

# --- Create rules symlink ---
echo "========================================="
echo " Rules Symlink"
echo "========================================="
echo ""

RULES_SOURCE="$HOME/.claude/rules"
RULES_LINK=".claude/rules"

# Check if global rules exist
if [[ ! -d "$RULES_SOURCE" ]]; then
    echo "[WARN] Global rules directory not found at $RULES_SOURCE"
    echo "       Run create-rules.sh first (Phase 1, step 2)."
    echo ""
    echo "[INFO] Creating the directory so the symlink has a target..."
    mkdir -p "$RULES_SOURCE"
fi

# Check if we're in a git project
if [[ ! -d ".git" ]]; then
    echo "[INFO] You are not currently inside a git project directory."
    echo ""
    echo "[INFO] To set up rules in a project, cd into the project first:"
    echo "       cd ~/projects/your-project"
    echo "       Then re-run this script."
    echo ""
    echo "[INFO] Alternatively, run this command manually in any project:"
    echo "       mkdir -p .claude && ln -sfn ~/.claude/rules .claude/rules"
    echo ""
    echo "[SKIP] Symlink creation skipped (not in a git project)."
    exit 0
fi

# Create .claude directory in the project if it doesn't exist
mkdir -p .claude

# Create or update the symlink
if [[ -L "$RULES_LINK" ]]; then
    CURRENT_TARGET="$(readlink "$RULES_LINK")"
    if [[ "$CURRENT_TARGET" == "$RULES_SOURCE" ]]; then
        echo "[SKIP] Symlink already exists and points to $RULES_SOURCE"
    else
        echo "[WARN] Symlink exists but points to: $CURRENT_TARGET"
        echo "[INFO] Updating to point to: $RULES_SOURCE"
        ln -sfn "$RULES_SOURCE" "$RULES_LINK"
        echo "[OK]   Symlink updated."
    fi
elif [[ -d "$RULES_LINK" ]]; then
    echo "[WARN] .claude/rules/ is a real directory (not a symlink)."
    echo "       This means the project has its own rules."
    echo "       If you want global rules, remove the directory and re-run."
    echo "[SKIP] Not overwriting existing directory."
else
    ln -sfn "$RULES_SOURCE" "$RULES_LINK"
    echo "[OK]   Created symlink: $RULES_LINK -> $RULES_SOURCE"
fi

# --- Gitignore note ---
echo ""
echo "[INFO] Consider adding .claude/rules to your .gitignore if"
echo "       you don't want the symlink committed to the repo:"
echo ""
echo "       echo '.claude/rules' >> .gitignore"
echo ""
echo "[OK]   Memory and rules setup complete."

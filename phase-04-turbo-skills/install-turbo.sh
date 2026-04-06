#!/usr/bin/env bash
# ============================================
# install-turbo.sh
# ============================================
# WHAT:   Installs the Turbo skills system for Claude Code.
#         Turbo adds reusable "skills" (prompt modules) to Claude Code
#         such as /finalize, /review-code, /peer-review-code, etc.
#
# NOTE:   Turbo is a developer-workflow tool, NOT Turborepo (Vercel).
#
# WHERE:  Run from the phase-04-turbo-skills/ directory.
# WHEN:   After completing Phases 1-3 (core config, hooks, threshold router).
# HOW:    bash install-turbo.sh
#
# WHAT HAPPENS:
#   1. Clones the Turbo repository into ~/projects/turbo/
#   2. Prints instructions for adding Turbo via Claude Code plugin system
#   3. Warns about known issues (Error #11, Error #12)
# ============================================

# --- Source platform detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

set -euo pipefail

echo ""
echo "=================================================="
echo "  Phase 4: Install Turbo Skills"
echo "=================================================="
echo ""

# --- Step 1: Clone the Turbo repository ---
# Turbo lives on GitHub. We clone it to ~/projects/turbo/
# so Claude Code can find and load the skills.

TURBO_DIR="$HOME/projects/turbo"

if [ -d "$TURBO_DIR" ]; then
    echo "[SKIP] Turbo directory already exists at: $TURBO_DIR"
    echo "       If you want to re-clone, delete it first:"
    echo "       rm -rf $TURBO_DIR"
else
    echo "[INFO] Cloning Turbo repository..."
    echo "       Destination: $TURBO_DIR"
    echo ""

    # Create the projects directory if it does not exist
    mkdir -p "$HOME/projects"

    # Clone the repo
    if git clone https://github.com/tobihagemann/turbo.git "$TURBO_DIR"; then
        echo ""
        echo "[OK]   Turbo cloned successfully to: $TURBO_DIR"
    else
        echo ""
        echo "[FAIL] Could not clone Turbo repository."
        echo "       Check your internet connection and GitHub access."
        echo "       You can also try your own fork:"
        echo "       git clone https://github.com/YOUR_USERNAME/turbo.git $TURBO_DIR"
        exit 1
    fi
fi

echo ""

# --- Step 2: Plugin installation instructions ---
# Turbo is installed as a Claude Code plugin.
# This must be done from INSIDE a Claude Code session.

echo "=================================================="
echo "  Next Steps (inside Claude Code)"
echo "=================================================="
echo ""
echo "  1. Open a Claude Code session in your project:"
echo "     cd ~/projects/your-project && claude"
echo ""
echo "  2. Run this command in Claude Code:"
echo "     /plugin marketplace add tobihagemann/turbo"
echo ""
echo "  3. Turbo will launch a 7-step guided wizard."
echo "     Follow each step. Do NOT skip any."
echo ""
echo "  4. After the wizard completes, verify installation:"
echo "     /finalize"
echo "     (should run without errors)"
echo ""

# --- Step 3: Warn about known issues ---

echo "=================================================="
echo "  Known Issues"
echo "=================================================="
echo ""
echo "  WARNING (Error #11):"
echo "    Turbo's wizard may write configuration to your global"
echo "    ~/.claude/CLAUDE.md file. After the wizard finishes,"
echo "    review that file and revert any unwanted changes:"
echo "      cat ~/.claude/CLAUDE.md"
echo ""
echo "  WARNING (Error #12):"
echo "    The /plugin add command may open your web browser"
echo "    for OAuth approval. This is normal on first install."
echo "    Approve the request and close the browser tab."
echo ""
echo "[OK]   Turbo clone complete. Follow the steps above to finish."
echo ""

#!/usr/bin/env bash
# ============================================
# install-codex.sh
# ============================================
# WHAT:   Installs OpenAI's Codex CLI and the Codex plugin for Claude Code.
#         This enables cross-model code review -- your code gets reviewed
#         by a different AI model, catching blind spots.
#
# WHERE:  Run from anywhere.
# WHEN:   After completing Phase 5 (Open Code Review).
# HOW:    bash install-codex.sh
#
# CRITICAL WARNING:
#   Do NOT enable the Codex "review gate" during setup.
#   It auto-triggers after EVERY Claude response, creating
#   expensive feedback loops that burn through API credits.
#
# KNOWN ISSUE (Error #5):
#   The login command is "codex login", NOT "codex auth login".
#   Using "codex auth login" will fail with an unrecognized command error.
# ============================================

# --- Source platform detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

set -euo pipefail

echo ""
echo "=================================================="
echo "  Phase 6: Install Codex Plugin"
echo "=================================================="
echo ""

# --- Step 1: Install the Codex CLI ---
# Codex is installed globally via npm so it is available everywhere.

echo "[INFO] Step 1: Installing Codex CLI globally..."
echo ""

if command -v codex &>/dev/null; then
    CODEX_VERSION=$(codex --version 2>/dev/null || echo "unknown")
    echo "[SKIP] Codex CLI is already installed (version: $CODEX_VERSION)"
else
    if npm install -g @openai/codex; then
        echo ""
        echo "[OK]   Codex CLI installed successfully."
    else
        echo ""
        echo "[FAIL] Could not install Codex CLI."
        echo "       Make sure npm is installed and you have write access to"
        echo "       the global node_modules directory."
        echo "       On Linux/WSL, you may need: sudo npm install -g @openai/codex"
        exit 1
    fi
fi

echo ""

# --- Step 2: Login to OpenAI ---
# IMPORTANT: The command is "codex login", NOT "codex auth login".
# Error #5 from the guide: "codex auth login" is not a valid command.

echo "[INFO] Step 2: Logging in to OpenAI..."
echo ""
echo "       IMPORTANT: The correct command is:"
echo "         codex login"
echo ""
echo "       NOT: codex auth login   <-- This is WRONG (Error #5)"
echo ""
echo "       Run this command now in a separate terminal:"
echo "         codex login"
echo ""
echo "       It will open your browser for OpenAI authentication."
echo "       Complete the login, then come back here."
echo ""

# We cannot run "codex login" non-interactively because it opens a browser.
# Just check if auth seems to be configured.
if [ -f "$HOME/.codex/auth.json" ] || [ -f "$HOME/.config/codex/auth.json" ]; then
    echo "[OK]   Codex auth file found. You appear to be logged in."
else
    echo "[WARN] No Codex auth file found."
    echo "       Run 'codex login' to authenticate before proceeding."
fi

echo ""

# --- Step 3: Plugin installation instructions ---
# The Codex plugin connects Claude Code to the Codex CLI.
# This must be done from inside a Claude Code session.

echo "=================================================="
echo "  Step 3: Install Plugin (inside Claude Code)"
echo "=================================================="
echo ""
echo "  1. Open a Claude Code session:"
echo "     cd ~/projects/your-project && claude"
echo ""
echo "  2. Install the plugin:"
echo "     /plugin marketplace add openai/codex-plugin-cc"
echo ""
echo "  3. Run the Codex setup wizard:"
echo "     /codex:setup"
echo ""
echo "  =============================================="
echo "  CRITICAL WARNING: REVIEW GATE"
echo "  =============================================="
echo ""
echo "  During /codex:setup, you will be asked about the 'review gate'."
echo "  DECLINE IT. Say 'no' to the review gate."
echo ""
echo "  The review gate auto-triggers a Codex review after EVERY Claude"
echo "  response, creating an expensive infinite feedback loop:"
echo ""
echo "    Claude --> Codex reviews --> Claude responds --> Codex reviews ..."
echo ""
echo "  This can exhaust your API budget in minutes."
echo "  =============================================="
echo ""
echo "[OK]   Codex CLI installation complete."
echo "       Follow the steps above to finish plugin setup in Claude Code."
echo ""

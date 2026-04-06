#!/usr/bin/env bash
# =============================================================================
# install-claude-code.sh -- Install Claude Code via the official installer
# =============================================================================
# PURPOSE:  Downloads and installs Claude Code using Anthropic's official
#           install script, then walks you through authentication.
#
# USAGE:    ./install-claude-code.sh
#
# NOTES:
#   - If you previously installed Claude Code via npm (npm install -g @anthropic/claude-code),
#     you need to run `claude migrate-installer` after this script finishes.
#   - Authentication opens your web browser for OAuth. Make sure you have a
#     browser available (on WSL, your Windows browser will open automatically).
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "===== Install Claude Code ====="
echo "[INFO] Platform: $PLATFORM"
echo ""

# --- Check if Claude Code is already installed ---
if command -v claude &>/dev/null; then
    CURRENT_VER="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    echo "[INFO] Claude Code is already installed (v$CURRENT_VER)."
    echo "[INFO] To update, run: claude update"
    echo ""

    # Ask if the user wants to continue anyway
    read -rp "Do you want to reinstall? (y/N): " REINSTALL
    if [[ "${REINSTALL,,}" != "y" ]]; then
        echo "[SKIP] Keeping existing installation."
        echo ""
        echo "[INFO] If you installed via npm and want to switch to the native installer,"
        echo "       run: claude migrate-installer"
        exit 0
    fi
fi

# --- Install Claude Code ---
echo "[INFO] Downloading and running the official Claude Code installer..."
echo "[INFO] This works on both WSL/Linux and macOS."
echo ""

# The official installer detects your platform and installs the right binary.
# curl flags:
#   -f  = fail silently on HTTP errors (don't show error HTML)
#   -s  = silent mode (no progress bar)
#   -S  = show errors even in silent mode
#   -L  = follow redirects
if curl -fsSL https://claude.ai/install.sh | bash; then
    echo ""
    echo "[OK]   Claude Code installer completed."
else
    echo ""
    echo "[FAIL] Installation failed. Check your internet connection and try again."
    echo "       If you're behind a corporate proxy, you may need to configure"
    echo "       HTTPS_PROXY before running this script."
    exit 1
fi

# --- Verify installation ---
echo ""
echo "[INFO] Verifying installation..."

if command -v claude &>/dev/null; then
    NEW_VER="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
    echo "[OK]   Claude Code v$NEW_VER is installed."
else
    echo "[FAIL] 'claude' command not found after installation."
    echo "       You may need to restart your terminal or add the install"
    echo "       directory to your PATH."
    exit 1
fi

# --- Authentication ---
echo ""
echo "========================================="
echo " Authentication"
echo "========================================="
echo ""
echo "[INFO] Claude Code uses OAuth for authentication."
echo "[INFO] This will open your web browser to log in."
echo ""
echo "       On WSL: Your default Windows browser will open."
echo "       On macOS: Your default browser will open."
echo ""
echo "[INFO] After logging in, return to this terminal."
echo ""

read -rp "Press Enter to start authentication (or Ctrl+C to skip)..."
echo ""

if claude auth login; then
    echo ""
    echo "[OK]   Authentication successful."
else
    echo ""
    echo "[WARN] Authentication did not complete."
    echo "       You can authenticate later by running: claude auth login"
fi

# --- Migration note ---
echo ""
echo "========================================="
echo " Important: npm Migration"
echo "========================================="
echo ""
echo "[INFO] If you previously installed Claude Code via npm"
echo "       (npm install -g @anthropic/claude-code), run this command"
echo "       to migrate your settings to the native installer:"
echo ""
echo "       claude migrate-installer"
echo ""
echo "[OK]   Installation complete. Run preflight-check.sh --post to verify."

#!/usr/bin/env bash
# =============================================================================
# setup-shell-env.sh -- Install Prettier and configure shell environment
# =============================================================================
# PURPOSE:  Installs Prettier (code formatter) globally and adds essential
#           environment variables to your shell RC file (~/.bashrc or ~/.zshrc).
#
# USAGE:    ./setup-shell-env.sh
#           ./setup-shell-env.sh --force   # skip confirmation prompts
#
# CHANGES MADE:
#   1. Installs Prettier globally via npm
#   2. Adds ANTHROPIC_MODEL=claude-opus-4-6 to shell RC
#   3. Adds ~/bin to PATH if not already there
#   4. Sources the updated RC file
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

echo ""
echo "===== Shell Environment Setup ====="
echo "[INFO] Platform: $PLATFORM"
echo "[INFO] Shell RC: $SHELL_RC"
echo ""

# --- 1. Install Prettier globally ---
echo "[INFO] Checking for Prettier..."
if command -v prettier &>/dev/null; then
    PRETTIER_VER="$(prettier --version 2>/dev/null)"
    echo "[OK]   Prettier v$PRETTIER_VER is already installed."
else
    echo "[INFO] Installing Prettier globally via npm..."
    if npm install -g prettier; then
        PRETTIER_VER="$(prettier --version 2>/dev/null)"
        echo "[OK]   Prettier v$PRETTIER_VER installed."
    else
        echo "[FAIL] Failed to install Prettier. Check npm and try again."
        echo "       You can install manually: npm install -g prettier"
    fi
fi

# --- Helper: add a line to shell RC if not already present ---
# This function checks if a line (or a key part of it) already exists in the
# RC file. If not, it appends the line with a comment.
add_to_rc() {
    local SEARCH="$1"    # string to search for (to avoid duplicates)
    local LINE="$2"      # full line to add
    local COMMENT="$3"   # comment to add above the line

    if [[ -f "$SHELL_RC" ]] && grep -qF "$SEARCH" "$SHELL_RC" 2>/dev/null; then
        echo "[SKIP] '$SEARCH' already in $SHELL_RC"
    else
        echo "" >> "$SHELL_RC"
        echo "# $COMMENT" >> "$SHELL_RC"
        echo "$LINE" >> "$SHELL_RC"
        echo "[OK]   Added '$LINE' to $SHELL_RC"
    fi
}

# --- 2. Add ANTHROPIC_MODEL ---
echo ""
echo "[INFO] Configuring ANTHROPIC_MODEL environment variable..."
echo "[INFO] This tells Claude Code which model to use by default."
add_to_rc "ANTHROPIC_MODEL" \
    'export ANTHROPIC_MODEL=claude-opus-4-6' \
    'Claude Code default model (added by setup-shell-env.sh)'

# --- 3. Add ~/bin to PATH ---
echo ""
echo "[INFO] Checking if ~/bin is in PATH..."
add_to_rc 'HOME/bin' \
    'export PATH="$HOME/bin:$PATH"' \
    'Local binaries (added by setup-shell-env.sh)'

# --- 4. Source the RC file ---
echo ""
echo "[INFO] Sourcing $SHELL_RC to apply changes..."
echo "[INFO] (This makes the new variables available in this terminal session.)"

# We use 'source' to reload the RC file. If it fails (e.g., due to a syntax
# error in the user's RC file), we catch the error and explain.
if source "$SHELL_RC" 2>/dev/null; then
    echo "[OK]   Shell environment reloaded."
else
    echo "[WARN] Could not source $SHELL_RC automatically."
    echo "       Open a new terminal or run: source $SHELL_RC"
fi

# --- Verify ---
echo ""
echo "========================================="
echo " Verification"
echo "========================================="

if command -v prettier &>/dev/null; then
    echo "[OK]   Prettier: $(prettier --version 2>/dev/null)"
else
    echo "[WARN] Prettier not found in PATH"
fi

if [[ -n "${ANTHROPIC_MODEL:-}" ]]; then
    echo "[OK]   ANTHROPIC_MODEL=$ANTHROPIC_MODEL"
else
    echo "[WARN] ANTHROPIC_MODEL not set (open a new terminal)"
fi

if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
    echo "[OK]   ~/bin is in PATH"
else
    echo "[WARN] ~/bin not in PATH (open a new terminal)"
fi

echo ""
echo "[OK]   Shell environment setup complete."

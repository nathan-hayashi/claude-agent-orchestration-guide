#!/usr/bin/env bash
# =============================================================================
# setup-wsl-memory.sh -- Configure WSL 2 memory limits
# =============================================================================
# PURPOSE:  Creates a .wslconfig file on the Windows side to limit how much
#           memory and CPU WSL 2 can use. Without this, WSL may consume all
#           your system RAM.
#
# USAGE:    ./setup-wsl-memory.sh
#           ./setup-wsl-memory.sh --force   # overwrite without asking
#
# WSL ONLY: This script does nothing on macOS (skips with a message).
#
# IMPORTANT: After this script runs, you MUST restart WSL from PowerShell:
#            wsl --shutdown
#            Then reopen your WSL terminal.
#
# TARGET FILE: /mnt/c/Users/<YourWindowsUsername>/.wslconfig
#              This is on the WINDOWS side, not in your Linux home directory.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

echo ""
echo "===== WSL 2 Memory Configuration ====="
echo ""

# --- Skip on macOS ---
if [[ "$IS_MACOS" == "true" ]]; then
    echo "[SKIP] This script is for WSL 2 only. macOS does not need it."
    echo "       macOS manages memory natively -- no configuration needed."
    exit 0
fi

# --- Skip on native Linux ---
if [[ "$IS_WSL" != "true" ]]; then
    echo "[SKIP] This script is for WSL 2 only."
    echo "       You appear to be on native Linux, which manages memory natively."
    exit 0
fi

# --- Determine the Windows user directory ---
# On WSL, the Windows C: drive is mounted at /mnt/c/
# We need to find the Windows username to locate the correct Users folder.
# The $USER variable inside WSL is the Linux username, which is usually
# the same as the Windows username, but not always.

# Try to get the Windows username from cmd.exe
WIN_USER="$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n' || echo "")"

if [[ -z "$WIN_USER" ]]; then
    # Fallback: use the WSL username (usually matches Windows)
    WIN_USER="$USER"
    echo "[WARN] Could not detect Windows username. Using '$WIN_USER'."
fi

WSLCONFIG_PATH="/mnt/c/Users/$WIN_USER/.wslconfig"

echo "[INFO] Windows username: $WIN_USER"
echo "[INFO] Target file: $WSLCONFIG_PATH"
echo ""

# --- Check if file already exists ---
if [[ -f "$WSLCONFIG_PATH" ]]; then
    echo "[INFO] .wslconfig already exists:"
    echo "---"
    cat "$WSLCONFIG_PATH"
    echo "---"
    echo ""

    if [[ "$FORCE" != "true" ]]; then
        read -rp "Overwrite with recommended settings? (y/N): " OVERWRITE
        if [[ "${OVERWRITE,,}" != "y" ]]; then
            echo "[SKIP] Keeping existing .wslconfig."
            exit 0
        fi
    fi

    # Backup the existing file with a date stamp
    BACKUP_PATH="${WSLCONFIG_PATH}.bak.$(date '+%Y%m%d')"
    cp "$WSLCONFIG_PATH" "$BACKUP_PATH"
    echo "[INFO] Backed up existing file to: $BACKUP_PATH"
fi

# --- Write the new .wslconfig ---
# These settings prevent WSL from eating all your RAM:
#   memory=8GB      -- WSL can use at most 8 GB of RAM
#   processors=4    -- WSL can use at most 4 CPU cores
#   swap=4GB        -- WSL gets 4 GB of swap space (disk-backed virtual memory)
#
# Adjust these values based on your machine:
#   16 GB total RAM -> memory=8GB is a good split (50%)
#   32 GB total RAM -> you could increase to memory=12GB or memory=16GB
#   8 GB total RAM  -> reduce to memory=4GB

cat > "$WSLCONFIG_PATH" << 'WSLCONFIG'
[wsl2]
memory=8GB
processors=4
swap=4GB
WSLCONFIG

echo "[OK]   .wslconfig written to: $WSLCONFIG_PATH"
echo ""
echo "[INFO] Contents:"
cat "$WSLCONFIG_PATH"
echo ""

# --- Remind about restart ---
echo "========================================="
echo " IMPORTANT: Restart Required"
echo "========================================="
echo ""
echo " You MUST restart WSL for these settings to take effect."
echo " Open a PowerShell window and run:"
echo ""
echo "   wsl --shutdown"
echo ""
echo " Then reopen your WSL terminal (Ubuntu)."
echo ""
echo "[OK]   WSL memory configuration complete."

#!/usr/bin/env bash
# =============================================================================
# setup-notifications.sh -- Set up desktop notifications for Claude Code
# =============================================================================
# PURPOSE:  Claude Code can send desktop notifications when it needs input or
#           finishes a task. This script installs the right notification tool
#           for your platform.
#
# USAGE:    ./setup-notifications.sh
#
# PLATFORMS:
#   WSL:   Downloads wsl-notify-send.exe (bridges WSL to Windows notifications)
#   macOS: Tests osascript (built-in, no install needed)
#   Linux: Tests notify-send (usually pre-installed on desktop distros)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

echo ""
echo "===== Desktop Notification Setup ====="
echo "[INFO] Platform: $PLATFORM"
echo ""

# --- WSL: Install wsl-notify-send ---
if [[ "$IS_WSL" == "true" ]]; then
    echo "[INFO] WSL detected. Setting up wsl-notify-send."
    echo ""
    echo "[INFO] wsl-notify-send is a small tool that bridges Linux notification"
    echo "       commands to Windows toast notifications. It lets Claude Code"
    echo "       pop up a Windows notification when it needs your attention."
    echo ""

    # Ensure ~/bin exists
    mkdir -p "$HOME/bin"

    NOTIFY_BIN="$HOME/bin/wsl-notify-send.exe"
    DOWNLOAD_URL="https://github.com/stuartleeks/wsl-notify-send/releases/latest/download/wsl-notify-send.exe"

    if [[ -f "$NOTIFY_BIN" ]]; then
        echo "[INFO] wsl-notify-send.exe already exists at $NOTIFY_BIN"
        echo "[INFO] To reinstall, delete it and run this script again."
    else
        echo "[INFO] Downloading wsl-notify-send.exe..."
        if curl -fsSL -o "$NOTIFY_BIN" "$DOWNLOAD_URL"; then
            chmod +x "$NOTIFY_BIN"
            echo "[OK]   Downloaded to $NOTIFY_BIN"
        else
            echo "[FAIL] Download failed. Check your internet connection."
            echo "       Manual download: $DOWNLOAD_URL"
            echo "       Save to: $NOTIFY_BIN"
            exit 1
        fi
    fi

    # Check if ~/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
        echo "[WARN] $HOME/bin is not in your PATH."
        echo "       Add this line to $SHELL_RC:"
        echo ""
        echo "       export PATH=\"\$HOME/bin:\$PATH\""
        echo ""
        echo "       Then run: source $SHELL_RC"
        echo ""
        # Add it for this session so the test works
        export PATH="$HOME/bin:$PATH"
    fi

    # Test the notification
    echo "[INFO] Sending a test notification..."
    if "$NOTIFY_BIN" --category "Claude Code" "Test notification from setup script" 2>/dev/null; then
        echo "[OK]   Notification sent. Check your Windows notification area."
    else
        echo "[WARN] Test notification may have failed. This can happen if:"
        echo "       - Windows notifications are turned off in Settings"
        echo "       - The .exe file needs to be unblocked (right-click > Properties)"
    fi

# --- macOS: Test osascript ---
elif [[ "$IS_MACOS" == "true" ]]; then
    echo "[INFO] macOS detected. Testing built-in notification system."
    echo ""
    echo "[INFO] macOS uses osascript to display notifications."
    echo "       No additional software is needed."
    echo ""

    echo "[INFO] Sending a test notification..."
    if osascript -e 'display notification "Test notification from setup script" with title "Claude Code"' 2>/dev/null; then
        echo "[OK]   Notification sent. Check your notification center."
    else
        echo "[WARN] Test notification failed. This can happen if:"
        echo "       - Terminal does not have notification permissions"
        echo "       - Go to System Settings > Notifications > Terminal (or iTerm2)"
        echo "       - Enable 'Allow Notifications'"
    fi

# --- Native Linux: Test notify-send ---
else
    echo "[INFO] Linux detected. Testing notify-send."
    echo ""

    if command -v notify-send &>/dev/null; then
        echo "[INFO] notify-send is installed."
        echo "[INFO] Sending a test notification..."
        if notify-send "Claude Code" "Test notification from setup script" 2>/dev/null; then
            echo "[OK]   Notification sent. Check your desktop notifications."
        else
            echo "[WARN] Test notification failed. You may be on a headless server"
            echo "       or your desktop environment does not support notifications."
        fi
    else
        echo "[WARN] notify-send is not installed."
        echo "       Install it with: sudo apt install libnotify-bin"
    fi
fi

echo ""
echo "[OK]   Notification setup complete."

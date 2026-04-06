#!/usr/bin/env bash
# =============================================================================
# platform-detect.sh -- Shared platform detection utility
# =============================================================================
# PURPOSE:  Detects whether we're running on WSL 2, macOS, or native Linux.
#           Every other script in this guide sources this file first so it can
#           adapt its behavior to your operating system.
#
# USAGE:    source "$SCRIPT_DIR/../scripts/platform-detect.sh"
#           (Each script sets SCRIPT_DIR before sourcing this file.)
#
# VARIABLES SET (exported for child processes):
#   PLATFORM   -- "wsl" | "macos" | "linux"
#   IS_WSL     -- "true" or "false"
#   IS_MACOS   -- "true" or "false"
#   HOME_DIR   -- Your home directory path (always $HOME)
#   SHELL_RC   -- Path to your shell config file (~/.bashrc or ~/.zshrc)
#   NOTIFY_CMD -- Command for desktop notifications (platform-specific)
# =============================================================================

# Save current shell options so we don't change the caller's settings.
# This is important because this file is "sourced" (loaded into another script),
# and we don't want our strict settings to break the script that loaded us.
_pd_old_opts=$(set +o)

# Turn on strict mode for this detection only
set -euo pipefail

# --- Default values ---
PLATFORM="linux"
IS_WSL="false"
IS_MACOS="false"
HOME_DIR="$HOME"

# --- Detect macOS ---
# macOS uses the Darwin kernel. The `uname -s` command prints the kernel name.
if [[ "$(uname -s)" == "Darwin" ]]; then
    PLATFORM="macos"
    IS_MACOS="true"
    SHELL_RC="$HOME/.zshrc"
    NOTIFY_CMD="osascript -e"
fi

# --- Detect WSL (Windows Subsystem for Linux) ---
# WSL puts "microsoft" or "Microsoft" in the kernel version string.
# We check /proc/version because it's the most reliable indicator.
if [[ -f /proc/version ]] && grep -qi "microsoft" /proc/version 2>/dev/null; then
    PLATFORM="wsl"
    IS_WSL="true"
    SHELL_RC="$HOME/.bashrc"
    NOTIFY_CMD="$HOME/bin/wsl-notify-send.exe"
fi

# --- Fallback for native Linux ---
if [[ "$PLATFORM" == "linux" ]]; then
    # Determine shell RC based on current shell
    if [[ -n "${ZSH_VERSION:-}" ]] || [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.bashrc"
    fi
    NOTIFY_CMD="notify-send"
fi

# --- Export for child processes ---
export PLATFORM IS_WSL IS_MACOS HOME_DIR SHELL_RC NOTIFY_CMD

# --- Restore caller's shell options ---
eval "$_pd_old_opts" 2>/dev/null

# Clean up temporary variable
unset _pd_old_opts

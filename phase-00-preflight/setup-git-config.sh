#!/usr/bin/env bash
# =============================================================================
# setup-git-config.sh -- Configure recommended git global settings
# =============================================================================
# PURPOSE:  Sets git globals that Claude Code and this guide expect:
#           - core.autocrlf = input (normalize line endings on commit)
#           - init.defaultBranch = main (new repos start with 'main' branch)
#           - rerere.enabled = true (remember conflict resolutions)
#           - user.name and user.email (prompted, with defaults)
#
# USAGE:    ./setup-git-config.sh
#           ./setup-git-config.sh --force   # skip confirmation prompts
#
# WHY THESE SETTINGS:
#   autocrlf=input  -- Prevents Windows line-ending issues in WSL. Commits
#                      always use LF; your working copy stays as-is.
#   defaultBranch   -- GitHub and Claude Code both expect 'main', not 'master'.
#   rerere           -- "REuse REcorded REsolution." Git remembers how you
#                      resolved a merge conflict and auto-applies it next time.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

echo ""
echo "===== Git Global Configuration ====="
echo "[INFO] Platform: $PLATFORM"
echo ""

# --- Set core.autocrlf ---
# This is especially important on WSL where files might have Windows line endings.
# "input" means: convert CRLF to LF on commit, but don't touch files on checkout.
CURRENT_AUTOCRLF="$(git config --global core.autocrlf 2>/dev/null || echo "not set")"
echo "[INFO] core.autocrlf: currently '$CURRENT_AUTOCRLF', setting to 'input'"
git config --global core.autocrlf input
echo "[OK]   core.autocrlf = input"

# --- Set init.defaultBranch ---
# When you run 'git init', the first branch will be called 'main' instead of 'master'.
CURRENT_BRANCH="$(git config --global init.defaultBranch 2>/dev/null || echo "not set")"
echo "[INFO] init.defaultBranch: currently '$CURRENT_BRANCH', setting to 'main'"
git config --global init.defaultBranch main
echo "[OK]   init.defaultBranch = main"

# --- Set rerere.enabled ---
# "rerere" stands for "reuse recorded resolution."
# If you resolve a merge conflict, git remembers your resolution.
# Next time the same conflict appears (e.g., during rebase), git applies it automatically.
CURRENT_RERERE="$(git config --global rerere.enabled 2>/dev/null || echo "not set")"
echo "[INFO] rerere.enabled: currently '$CURRENT_RERERE', setting to 'true'"
git config --global rerere.enabled true
echo "[OK]   rerere.enabled = true"

# --- Set user.name ---
echo ""
CURRENT_NAME="$(git config --global user.name 2>/dev/null || echo "")"
if [[ -n "$CURRENT_NAME" ]]; then
    echo "[INFO] Current git user.name: '$CURRENT_NAME'"
    if [[ "$FORCE" == "false" ]]; then
        read -rp "       Keep this name? (Y/n): " KEEP_NAME
        if [[ "${KEEP_NAME,,}" == "n" ]]; then
            read -rp "       Enter new name: " NEW_NAME
            git config --global user.name "$NEW_NAME"
            echo "[OK]   user.name = '$NEW_NAME'"
        else
            echo "[OK]   user.name = '$CURRENT_NAME' (kept)"
        fi
    else
        echo "[OK]   user.name = '$CURRENT_NAME' (kept, --force mode)"
    fi
else
    echo "[WARN] git user.name is not set."
    read -rp "       Enter your full name (e.g., Jane Doe): " NEW_NAME
    if [[ -n "$NEW_NAME" ]]; then
        git config --global user.name "$NEW_NAME"
        echo "[OK]   user.name = '$NEW_NAME'"
    else
        echo "[WARN] Skipped -- you'll need to set this before committing."
    fi
fi

# --- Set user.email ---
CURRENT_EMAIL="$(git config --global user.email 2>/dev/null || echo "")"
if [[ -n "$CURRENT_EMAIL" ]]; then
    echo "[INFO] Current git user.email: '$CURRENT_EMAIL'"
    if [[ "$FORCE" == "false" ]]; then
        read -rp "       Keep this email? (Y/n): " KEEP_EMAIL
        if [[ "${KEEP_EMAIL,,}" == "n" ]]; then
            read -rp "       Enter new email: " NEW_EMAIL
            git config --global user.email "$NEW_EMAIL"
            echo "[OK]   user.email = '$NEW_EMAIL'"
        else
            echo "[OK]   user.email = '$CURRENT_EMAIL' (kept)"
        fi
    else
        echo "[OK]   user.email = '$CURRENT_EMAIL' (kept, --force mode)"
    fi
else
    echo "[WARN] git user.email is not set."
    read -rp "       Enter your email (e.g., jane@example.com): " NEW_EMAIL
    if [[ -n "$NEW_EMAIL" ]]; then
        git config --global user.email "$NEW_EMAIL"
        echo "[OK]   user.email = '$NEW_EMAIL'"
    else
        echo "[WARN] Skipped -- you'll need to set this before committing."
    fi
fi

# --- Summary ---
echo ""
echo "========================================="
echo " Git Global Config Summary"
echo "========================================="
echo "  core.autocrlf    = $(git config --global core.autocrlf)"
echo "  init.defaultBranch = $(git config --global init.defaultBranch)"
echo "  rerere.enabled   = $(git config --global rerere.enabled)"
echo "  user.name        = $(git config --global user.name 2>/dev/null || echo '(not set)')"
echo "  user.email       = $(git config --global user.email 2>/dev/null || echo '(not set)')"
echo ""
echo "[OK]   Git configuration complete."

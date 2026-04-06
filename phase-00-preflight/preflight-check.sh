#!/usr/bin/env bash
# =============================================================================
# preflight-check.sh -- Verify all prerequisites for Claude Code
# =============================================================================
# PURPOSE:  Checks that your machine has everything needed before (and after)
#           installing Claude Code. Think of it as a health check for your
#           development environment.
#
# USAGE:    ./preflight-check.sh           # runs both stages
#           ./preflight-check.sh --pre     # stage 1 only (before install)
#           ./preflight-check.sh --post    # stage 2 only (after install)
#
# STAGES:
#   Stage 1 (pre-install):  platform, node >= v20, npm >= v9, git
#   Stage 2 (post-install): claude >= 2.1.90, auth, Prettier, ANTHROPIC_MODEL
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# --- Counters ---
PASS=0
FAIL=0
SKIP=0

# --- Helper functions ---

# check_pass: prints a green checkmark and increments the pass counter
check_pass() {
    echo "  [OK]   $1"
    PASS=$((PASS + 1))
}

# check_fail: prints a red X and increments the fail counter
check_fail() {
    echo "  [FAIL] $1"
    FAIL=$((FAIL + 1))
}

# check_skip: prints a skip notice (for platform-specific checks)
check_skip() {
    echo "  [SKIP] $1"
    SKIP=$((SKIP + 1))
}

# version_gte: returns 0 (true) if $1 >= $2 using semantic versioning
# Example: version_gte "20.11.0" "20.0.0" returns true
version_gte() {
    # Sort the two versions and check if the first one comes last (is >= the other)
    printf '%s\n%s\n' "$2" "$1" | sort -V | tail -1 | grep -qF "$1"
}

# --- Stage 1: Pre-install checks ---
stage_pre() {
    echo ""
    echo "========================================="
    echo " Stage 1: Pre-Install Checks"
    echo "========================================="
    echo ""

    # 1. Platform detection
    echo "[INFO] Detected platform: $PLATFORM"
    check_pass "Platform detection ($PLATFORM)"

    # 2. Node.js >= v20
    if command -v node &>/dev/null; then
        NODE_VER="$(node --version | sed 's/^v//')"
        if version_gte "$NODE_VER" "20.0.0"; then
            check_pass "Node.js v$NODE_VER (>= v20 required)"
        else
            check_fail "Node.js v$NODE_VER is too old (>= v20 required)"
        fi
    else
        check_fail "Node.js is not installed (>= v20 required)"
        echo "         Install from: https://nodejs.org/ or use nvm"
    fi

    # 3. npm >= v9
    if command -v npm &>/dev/null; then
        NPM_VER="$(npm --version)"
        if version_gte "$NPM_VER" "9.0.0"; then
            check_pass "npm v$NPM_VER (>= v9 required)"
        else
            check_fail "npm v$NPM_VER is too old (>= v9 required)"
        fi
    else
        check_fail "npm is not installed (>= v9 required)"
        echo "         npm comes with Node.js -- install Node first"
    fi

    # 4. git installed
    if command -v git &>/dev/null; then
        GIT_VER="$(git --version | awk '{print $3}')"
        check_pass "git v$GIT_VER"
    else
        check_fail "git is not installed"
        echo "         Install: sudo apt install git (WSL/Linux) or brew install git (macOS)"
    fi
}

# --- Stage 2: Post-install checks ---
stage_post() {
    echo ""
    echo "========================================="
    echo " Stage 2: Post-Install Checks"
    echo "========================================="
    echo ""

    # 1. Claude Code >= 2.1.90
    if command -v claude &>/dev/null; then
        # claude --version outputs something like "claude 2.1.92"
        CLAUDE_VER="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
        if [[ -n "$CLAUDE_VER" ]] && version_gte "$CLAUDE_VER" "2.1.90"; then
            check_pass "Claude Code v$CLAUDE_VER (>= 2.1.90 required)"
        elif [[ -n "$CLAUDE_VER" ]]; then
            check_fail "Claude Code v$CLAUDE_VER is too old (>= 2.1.90 required)"
            echo "         Run: claude update"
        else
            check_fail "Could not determine Claude Code version"
        fi
    else
        check_fail "Claude Code is not installed"
        echo "         Run install-claude-code.sh first"
    fi

    # 2. Claude auth status
    if command -v claude &>/dev/null; then
        if claude auth status &>/dev/null; then
            check_pass "Claude Code authentication is active"
        else
            check_fail "Claude Code is not authenticated"
            echo "         Run: claude auth login"
        fi
    else
        check_skip "Claude auth check (Claude Code not installed)"
    fi

    # 3. Prettier installed globally
    if command -v prettier &>/dev/null; then
        PRETTIER_VER="$(prettier --version 2>/dev/null)"
        check_pass "Prettier v$PRETTIER_VER (global install)"
    else
        check_fail "Prettier is not installed globally"
        echo "         Run: npm install -g prettier"
    fi

    # 4. ANTHROPIC_MODEL environment variable
    if [[ -n "${ANTHROPIC_MODEL:-}" ]]; then
        check_pass "ANTHROPIC_MODEL is set to '$ANTHROPIC_MODEL'"
    else
        check_fail "ANTHROPIC_MODEL environment variable is not set"
        echo "         Add to $SHELL_RC: export ANTHROPIC_MODEL=claude-opus-4-6"
    fi
}

# --- Parse arguments and run ---

# Determine which stages to run based on the flag passed
RUN_PRE="false"
RUN_POST="false"

case "${1:-both}" in
    --pre)
        RUN_PRE="true"
        ;;
    --post)
        RUN_POST="true"
        ;;
    both|*)
        RUN_PRE="true"
        RUN_POST="true"
        ;;
esac

echo ""
echo "===== Claude Code Pre-Flight Check ====="
echo "[INFO] Platform: $PLATFORM"
echo "[INFO] Date: $(date '+%Y-%m-%d %H:%M:%S')"

if [[ "$RUN_PRE" == "true" ]]; then
    stage_pre
fi

if [[ "$RUN_POST" == "true" ]]; then
    stage_post
fi

# --- Summary ---
echo ""
echo "========================================="
echo " Summary"
echo "========================================="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "  Skipped: $SKIP"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
    echo "[WARN] $FAIL check(s) failed. Fix the issues above before proceeding."
    exit 1
else
    echo "[OK]   All checks passed. You're ready for the next step."
    exit 0
fi

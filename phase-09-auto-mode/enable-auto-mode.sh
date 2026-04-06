#!/usr/bin/env bash
# ============================================
# enable-auto-mode.sh
# ============================================
# WHAT:   Validates that all prerequisites for auto mode are in place,
#         then confirms the auto mode configuration is ready.
#
#         Auto mode lets Claude Code execute multi-step workflows
#         without asking for confirmation at each step. This is
#         powerful but requires defense-in-depth safety layers.
#
# WHERE:  Run from anywhere.
# WHEN:   After completing Phases 2, 7, and 8.
# HOW:    bash enable-auto-mode.sh
#
# PREREQUISITES:
#   Phase 2: PreToolUse hooks in settings.json
#   Phase 7: Subagent files in ~/.claude/agents/
#   Phase 8: Custom skills in ~/.claude/skills/
#
# NOTE: This script VALIDATES the configuration.
#       It does NOT enable auto mode -- you do that in Claude Code.
# ============================================

# --- Source platform detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

set -euo pipefail

echo ""
echo "=================================================="
echo "  Phase 9: Auto Mode Readiness Check"
echo "=================================================="
echo ""

# Track overall pass/fail
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# --- Helper: report check results ---
check_pass() {
    echo "[OK]   $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

check_fail() {
    echo "[FAIL] $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

check_warn() {
    echo "[WARN] $1"
    CHECKS_WARNED=$((CHECKS_WARNED + 1))
}

# ============================================
# Check 1: Phase 2 -- PreToolUse hooks in settings.json
# ============================================
# The settings.json file should exist and contain hook definitions.
# Hooks are the first line of defense -- they block dangerous commands
# BEFORE execution, even in auto mode.

echo "--- Check 1: PreToolUse Hooks (Phase 2) ---"
echo ""

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS_FILE" ]; then
    check_fail "settings.json not found at: $SETTINGS_FILE"
    echo "       Run Phase 2 first to create the hooks system."
else
    # Check if the file contains hook-related content
    # We look for "hooks" or "PreToolUse" as indicators
    if grep -q '"hooks"' "$SETTINGS_FILE" 2>/dev/null || \
       grep -q "PreToolUse" "$SETTINGS_FILE" 2>/dev/null; then
        check_pass "settings.json exists and contains hook definitions."
    else
        check_fail "settings.json exists but contains no hook definitions."
        echo "       The file should contain PreToolUse hooks."
        echo "       Run Phase 2 to add the hooks system."
    fi
fi

echo ""

# ============================================
# Check 2: Phase 7 -- Subagent files exist
# ============================================
# Auto mode should have subagents available for review tasks.
# We check for the three agents created in Phase 7.

echo "--- Check 2: Subagent Files (Phase 7) ---"
echo ""

AGENTS_DIR="$HOME/.claude/agents"
EXPECTED_AGENTS=("security-reviewer.md" "quality-reviewer.md" "fixer.md")

if [ ! -d "$AGENTS_DIR" ]; then
    check_fail "Agents directory not found: $AGENTS_DIR"
    echo "       Run Phase 7 first to create subagents."
else
    for agent in "${EXPECTED_AGENTS[@]}"; do
        if [ -f "$AGENTS_DIR/$agent" ]; then
            # Verify the agent uses correct field names
            if grep -q "tools:" "$AGENTS_DIR/$agent" 2>/dev/null; then
                check_pass "Found $agent with correct 'tools' field."
            elif grep -q "allowed-tools:" "$AGENTS_DIR/$agent" 2>/dev/null; then
                check_fail "$agent uses 'allowed-tools' (wrong). Should be 'tools'."
                echo "       This causes SILENT failure -- the agent will have no tools."
            else
                check_warn "$agent exists but could not verify 'tools' field."
            fi
        else
            check_fail "Missing agent: $AGENTS_DIR/$agent"
            echo "       Run Phase 7 to create this subagent."
        fi
    done
fi

echo ""

# ============================================
# Check 3: Phase 8 -- Skills directory exists
# ============================================
# Auto mode workflows benefit from structured skills.
# Check that at least the skills directory exists with some content.

echo "--- Check 3: Skills Library (Phase 8) ---"
echo ""

SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    check_fail "Skills directory not found: $SKILLS_DIR"
    echo "       Run Phase 8 first to create the skills library."
else
    # Count skill directories (each skill is a subdirectory with SKILL.md)
    SKILL_COUNT=0
    for skill_dir in "$SKILLS_DIR"/*/; do
        if [ -f "${skill_dir}SKILL.md" ]; then
            SKILL_COUNT=$((SKILL_COUNT + 1))
        fi
    done

    if [ "$SKILL_COUNT" -ge 1 ]; then
        check_pass "Found $SKILL_COUNT skill(s) in: $SKILLS_DIR"
    else
        check_warn "Skills directory exists but contains no SKILL.md files."
        echo "       Run Phase 8 to create example skills."
    fi
fi

echo ""

# ============================================
# Check 4: autoMode.environment format
# ============================================
# If settings.json contains an autoMode section, verify that
# environment is an array of strings (not a single string).

echo "--- Check 4: autoMode Configuration ---"
echo ""

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q '"autoMode"' "$SETTINGS_FILE" 2>/dev/null; then
        # Check if environment is present
        if grep -q '"environment"' "$SETTINGS_FILE" 2>/dev/null; then
            # Rough check: environment should be followed by a [ (array)
            # This is a basic heuristic, not a full JSON parser.
            if grep -A1 '"environment"' "$SETTINGS_FILE" 2>/dev/null | grep -q '\['; then
                check_pass "autoMode.environment appears to be an array."
            else
                check_warn "autoMode.environment may not be an array."
                echo "       It must be an array of strings, e.g.:"
                echo '       "environment": ["Read", "Grep", "Glob"]'
            fi
        else
            check_warn "autoMode section exists but 'environment' field not found."
            echo "       Add an environment array to control auto mode tool access."
        fi
    else
        echo "[INFO] No autoMode section found in settings.json."
        echo "       This is normal -- auto mode is configured in Claude Code."
        echo "       When you enable it, ensure 'environment' is an array of strings."
    fi
else
    echo "[SKIP] settings.json not found. Cannot check autoMode config."
fi

echo ""

# ============================================
# Summary
# ============================================

echo "=================================================="
echo "  Auto Mode Readiness Summary"
echo "=================================================="
echo ""
echo "  Passed:  $CHECKS_PASSED"
echo "  Failed:  $CHECKS_FAILED"
echo "  Warned:  $CHECKS_WARNED"
echo ""

if [ "$CHECKS_FAILED" -eq 0 ]; then
    echo "[OK]   All critical checks passed."
    echo ""
    echo "  Auto mode prerequisites are in place."
    echo "  To enable auto mode, open Claude Code and configure it."
    echo ""
    echo "  Safety layers active:"
    echo "    Layer 1: PreToolUse hooks block dangerous commands"
    echo "    Layer 2: autoMode.environment restricts tool access"
    echo "    Layer 3: Subagent reviewers catch post-execution issues"
    echo "    Layer 4: Skills provide structured, guardrailed workflows"
else
    echo "[FAIL] $CHECKS_FAILED critical check(s) failed."
    echo ""
    echo "  Do NOT enable auto mode until all checks pass."
    echo "  Fix the issues above and re-run this script."
fi

echo ""

# Exit with non-zero if any checks failed
if [ "$CHECKS_FAILED" -gt 0 ]; then
    exit 1
fi

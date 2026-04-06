#!/usr/bin/env bash
# =============================================================================
# test-threshold.sh -- Validate threshold router prerequisites
# =============================================================================
# PURPOSE:  Checks that all prerequisites for the threshold router are in place:
#           - SKILL.md exists with correct frontmatter
#           - CLAUDE.md exists with the mandatory threshold section
#           - Prior phases are complete
#
# USAGE:    ./test-threshold.sh
#
# RUN THIS IF:  The threshold router doesn't fire on T1/T2 tasks.
#               Missing prerequisites are the most common cause.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SKILL_FILE="$HOME/.claude/skills/threshold-router/SKILL.md"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
SETTINGS="$HOME/.claude/settings.json"
PASS=0
FAIL=0

echo ""
echo "===== Threshold Router Validation ====="
echo ""

# --- Helper ---
check_pass() {
    echo "  [OK]   $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo "  [FAIL] $1"
    FAIL=$((FAIL + 1))
}

# --- Test 1: SKILL.md exists ---
echo "[INFO] Test 1: Skill file exists"

if [[ -f "$SKILL_FILE" ]]; then
    check_pass "SKILL.md found at $SKILL_FILE"
else
    check_fail "SKILL.md not found at $SKILL_FILE"
    echo "         Run create-threshold-skill.sh to create it."
fi

# --- Test 2: SKILL.md has correct frontmatter ---
echo ""
echo "[INFO] Test 2: Skill frontmatter validation"

if [[ -f "$SKILL_FILE" ]]; then
    # Check for name field in frontmatter
    if head -10 "$SKILL_FILE" | grep -q "name:.*threshold-router"; then
        check_pass "SKILL.md has 'name: threshold-router' in frontmatter"
    else
        check_fail "SKILL.md missing 'name: threshold-router' in frontmatter"
        echo "         The frontmatter must contain: name: threshold-router"
    fi

    # Check for description field
    if head -10 "$SKILL_FILE" | grep -q "description:"; then
        check_pass "SKILL.md has 'description' field in frontmatter"
    else
        check_fail "SKILL.md missing 'description' field in frontmatter"
    fi

    # Check for YAML frontmatter delimiters
    if head -1 "$SKILL_FILE" | grep -q "^---"; then
        check_pass "SKILL.md has opening frontmatter delimiter (---)"
    else
        check_fail "SKILL.md missing opening frontmatter delimiter (---)"
    fi

    # Check for scoring table
    if grep -q "Scoring Table" "$SKILL_FILE"; then
        check_pass "SKILL.md contains scoring table"
    else
        check_fail "SKILL.md missing scoring table section"
    fi

    # Check for tier definitions
    if grep -q "Tier Assignment" "$SKILL_FILE"; then
        check_pass "SKILL.md contains tier assignment section"
    else
        check_fail "SKILL.md missing tier assignment section"
    fi

    # Check for override system
    if grep -q "just do it" "$SKILL_FILE"; then
        check_pass "SKILL.md contains override system"
    else
        check_fail "SKILL.md missing override keywords"
    fi
else
    echo "  [SKIP] Skipping frontmatter tests (file not found)"
fi

# --- Test 3: CLAUDE.md exists ---
echo ""
echo "[INFO] Test 3: Global CLAUDE.md"

if [[ -f "$CLAUDE_MD" ]]; then
    check_pass "CLAUDE.md found at $CLAUDE_MD"
else
    check_fail "CLAUDE.md not found at $CLAUDE_MD"
    echo "         Run create-claude-md.sh (Phase 1) to create it."
fi

# --- Test 4: CLAUDE.md has mandatory threshold section ---
echo ""
echo "[INFO] Test 4: Mandatory threshold section in CLAUDE.md"

if [[ -f "$CLAUDE_MD" ]]; then
    if grep -q "Threshold Escalation" "$CLAUDE_MD"; then
        check_pass "CLAUDE.md contains 'Threshold Escalation' section"
    else
        check_fail "CLAUDE.md missing 'Threshold Escalation' section"
        echo "         This is why the threshold router doesn't fire on simple tasks."
        echo "         Run create-threshold-skill.sh to add it, or add manually:"
        echo ""
        echo "         ## Threshold Escalation (MANDATORY)"
        echo "         The threshold-router skill MUST be consulted on EVERY prompt."
        echo "         Compute the complexity score and announce [T1], [T2], or [T3]."
    fi

    if grep -q "threshold-router" "$CLAUDE_MD"; then
        check_pass "CLAUDE.md references 'threshold-router' skill"
    else
        check_fail "CLAUDE.md does not reference 'threshold-router' skill"
    fi
else
    echo "  [SKIP] Skipping CLAUDE.md content tests (file not found)"
fi

# --- Test 5: Prior phases complete ---
echo ""
echo "[INFO] Test 5: Prior phase prerequisites"

# Phase 2: settings.json
if [[ -f "$SETTINGS" ]]; then
    check_pass "settings.json exists (Phase 2 complete)"
else
    check_fail "settings.json not found (Phase 2 incomplete)"
    echo "         Run create-settings-json.sh first."
fi

# Phase 1: rules directory
if [[ -d "$HOME/.claude/rules" ]] && ls "$HOME/.claude/rules"/*.md &>/dev/null 2>&1; then
    RULE_COUNT="$(ls "$HOME/.claude/rules"/*.md 2>/dev/null | wc -l)"
    check_pass "Rules directory has $RULE_COUNT rule files (Phase 1 complete)"
else
    check_fail "No rule files found in ~/.claude/rules/ (Phase 1 incomplete)"
    echo "         Run create-rules.sh first."
fi

# --- Summary ---
echo ""
echo "========================================="
echo " Validation Summary"
echo "========================================="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
    echo "[WARN] $FAIL prerequisite(s) missing."
    echo ""
    echo "       Common fix: Run the scripts from earlier phases first."
    echo "       Phase 1: create-claude-md.sh, create-rules.sh"
    echo "       Phase 2: create-settings-json.sh"
    echo "       Phase 3: create-threshold-skill.sh"
    exit 1
else
    echo "[OK]   All prerequisites are met. The threshold router is ready."
    echo ""
    echo "       To test it live:"
    echo "       1. Start Claude Code: claude"
    echo "       2. Type a simple prompt (e.g., 'fix the typo in README')"
    echo "       3. Claude should respond with [T1] at the start"
    echo "       4. Try a complex prompt (e.g., 'refactor the auth system')"
    echo "       5. Claude should respond with [T2] or [T3]"
    exit 0
fi

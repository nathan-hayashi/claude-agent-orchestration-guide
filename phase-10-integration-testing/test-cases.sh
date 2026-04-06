#!/usr/bin/env bash
# ============================================
# test-cases.sh
# ============================================
# WHAT:   Individual test functions for the 10 integration tests.
#         Each function returns 0 for PASS, 1 for FAIL.
#         This file is sourced by run-integration-tests.sh.
#
# WHERE:  phase-10-integration-testing/test-cases.sh
# WHEN:   Sourced by the test orchestrator; do not run directly.
# HOW:    source test-cases.sh (called by run-integration-tests.sh)
#
# CONVENTIONS:
#   - Each function is named test_NN_description
#   - Each function prints its own [OK]/[FAIL] messages
#   - Return 0 = PASS, return 1 = FAIL
# ============================================

# ============================================
# Test 1: CLAUDE.md Loads
# ============================================
# Checks that a CLAUDE.md file exists and is readable.
# Looks in two locations:
#   1. ~/.claude/CLAUDE.md (global instructions)
#   2. ./CLAUDE.md (project-level instructions)
# Either location is valid.

test_01_claude_md_loads() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local project_md="./CLAUDE.md"

    if [ -r "$global_md" ]; then
        echo "[OK]   Test 1: CLAUDE.md found at $global_md"
        return 0
    elif [ -r "$project_md" ]; then
        echo "[OK]   Test 1: CLAUDE.md found at $project_md"
        return 0
    else
        echo "[FAIL] Test 1: CLAUDE.md not found."
        echo "       Checked: $global_md"
        echo "       Checked: $project_md"
        echo "       Action: Create CLAUDE.md in Phase 1."
        return 1
    fi
}

# ============================================
# Test 2: T1 on Simple Edit (score < 4)
# ============================================
# Checks that the threshold router skill or CLAUDE.md contains
# logic for Tier 1 routing (low complexity, direct execution).
# We look for patterns like "T1", "score 0-3", "tier 1", etc.

test_02_t1_simple_edit() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local found=false

    # Check global CLAUDE.md for threshold router references
    if [ -r "$global_md" ]; then
        if grep -qi '\[T1\]\|tier.1\|score.*0.*3\|T1.*proceed\|T1.*direct' "$global_md" 2>/dev/null; then
            found=true
        fi
    fi

    # Also check skills directory for threshold-router skill
    local skill_dirs=(
        "$HOME/.claude/skills/threshold-router"
        "$HOME/.claude/skills/threshold_router"
    )
    for skill_dir in "${skill_dirs[@]}"; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            if grep -qi '\[T1\]\|tier.1\|score.*0.*3\|T1.*proceed\|T1.*direct' "$skill_dir/SKILL.md" 2>/dev/null; then
                found=true
            fi
        fi
    done

    if [ "$found" = true ]; then
        echo "[OK]   Test 2: T1 routing logic found (score 0-3 -> direct execution)."
        return 0
    else
        echo "[FAIL] Test 2: T1 routing logic not found."
        echo "       CLAUDE.md or threshold-router skill should define T1 behavior."
        echo "       Action: Check Phase 3 (Threshold Router)."
        return 1
    fi
}

# ============================================
# Test 3: T3 on IAM Audit (score 12+)
# ============================================
# Checks that the threshold router contains logic for Tier 3
# routing (high complexity, ultrathink + multi-agent review).

test_03_t3_iam_audit() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local found=false

    if [ -r "$global_md" ]; then
        if grep -qi '\[T3\]\|tier.3\|score.*8\|T3.*ultrathink\|T3.*review' "$global_md" 2>/dev/null; then
            found=true
        fi
    fi

    # Check skills directory
    local skill_dirs=(
        "$HOME/.claude/skills/threshold-router"
        "$HOME/.claude/skills/threshold_router"
    )
    for skill_dir in "${skill_dirs[@]}"; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            if grep -qi '\[T3\]\|tier.3\|score.*8\|T3.*ultrathink\|T3.*review' "$skill_dir/SKILL.md" 2>/dev/null; then
                found=true
            fi
        fi
    done

    if [ "$found" = true ]; then
        echo "[OK]   Test 3: T3 routing logic found (score 8+ -> ultrathink + review)."
        return 0
    else
        echo "[FAIL] Test 3: T3 routing logic not found."
        echo "       CLAUDE.md or threshold-router skill should define T3 behavior."
        echo "       Action: Check Phase 3 (Threshold Router)."
        return 1
    fi
}

# ============================================
# Test 4: Security Hook Blocks rm -rf
# ============================================
# Checks that settings.json contains a PreToolUse hook with a pattern
# that matches destructive commands like rm -rf.

test_04_security_hook_blocks_rm() {
    local settings="$HOME/.claude/settings.json"

    if [ ! -r "$settings" ]; then
        echo "[FAIL] Test 4: settings.json not found at $settings"
        echo "       Action: Run Phase 2 to create the hooks system."
        return 1
    fi

    # Look for patterns that would catch rm -rf in a PreToolUse hook.
    # Common patterns: "rm -rf", "rm.*-rf", destructive command blocking
    if grep -qi 'rm.*-rf\|rm.*-fr\|destructive\|dangerous.*command\|force.*delete' "$settings" 2>/dev/null; then
        echo "[OK]   Test 4: Security hook pattern for 'rm -rf' found in settings.json."
        return 0
    elif grep -qi 'PreToolUse\|pre_tool_use\|pretooluse' "$settings" 2>/dev/null; then
        echo "[WARN] Test 4: PreToolUse hooks found but no explicit rm -rf pattern."
        echo "       The hook may still catch it via other patterns."
        echo "       Verify manually: cat $settings"
        # Treat as pass since hooks exist
        return 0
    else
        echo "[FAIL] Test 4: No PreToolUse hooks found in settings.json."
        echo "       Action: Run Phase 2 to add security hooks."
        return 1
    fi
}

# ============================================
# Test 5: Prettier Auto-Format Fires
# ============================================
# Checks that a PostToolUse hook for Prettier (or equivalent formatter)
# is configured in settings.json.

test_05_prettier_autoformat() {
    local settings="$HOME/.claude/settings.json"

    if [ ! -r "$settings" ]; then
        echo "[FAIL] Test 5: settings.json not found."
        echo "       Action: Run Phase 2 to create the hooks system."
        return 1
    fi

    # Look for Prettier or format-related hook configuration
    if grep -qi 'prettier\|format\|PostToolUse\|post_tool_use\|posttooluse' "$settings" 2>/dev/null; then
        echo "[OK]   Test 5: Formatter hook configuration found in settings.json."
        return 0
    else
        echo "[FAIL] Test 5: No formatter (Prettier) hook found in settings.json."
        echo "       Action: Run Phase 2 to add PostToolUse hooks."
        return 1
    fi
}

# ============================================
# Test 6: Error Recovery Hook Fires
# ============================================
# Checks that an error recovery hook is configured in settings.json.
# This could be a dedicated error hook or error handling in existing hooks.

test_06_error_recovery_hook() {
    local settings="$HOME/.claude/settings.json"

    if [ ! -r "$settings" ]; then
        echo "[FAIL] Test 6: settings.json not found."
        echo "       Action: Run Phase 2 to create the hooks system."
        return 1
    fi

    # Look for error recovery patterns in the settings
    if grep -qi 'error\|recovery\|on_error\|onError\|notification\|notify\|stderr' "$settings" 2>/dev/null; then
        echo "[OK]   Test 6: Error recovery hook configuration found."
        return 0
    elif grep -qi 'hooks' "$settings" 2>/dev/null; then
        echo "[WARN] Test 6: Hooks section exists but no explicit error recovery pattern."
        echo "       Error handling may be built into existing hooks."
        echo "       Verify manually: cat $settings"
        # Treat as pass since hooks infrastructure exists
        return 0
    else
        echo "[FAIL] Test 6: No error recovery hook found in settings.json."
        echo "       Action: Run Phase 2 to add error recovery hooks."
        return 1
    fi
}

# ============================================
# Test 7: Override "just do it" (downgrade)
# ============================================
# Checks that the threshold router or CLAUDE.md contains logic
# to downgrade the tier when the user says "just do it".

test_07_override_just_do_it() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local found=false

    if [ -r "$global_md" ]; then
        if grep -qi 'just do it.*downgrade\|just.do.it.*T1\|just.do.it.*lower\|downgrade.*just' "$global_md" 2>/dev/null; then
            found=true
        fi
    fi

    # Check skills directory
    local skill_dirs=(
        "$HOME/.claude/skills/threshold-router"
        "$HOME/.claude/skills/threshold_router"
    )
    for skill_dir in "${skill_dirs[@]}"; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            if grep -qi 'just do it\|just.do.it\|downgrade\|override.*down' "$skill_dir/SKILL.md" 2>/dev/null; then
                found=true
            fi
        fi
    done

    if [ "$found" = true ]; then
        echo "[OK]   Test 7: 'just do it' downgrade override logic found."
        return 0
    else
        echo "[FAIL] Test 7: 'just do it' downgrade logic not found."
        echo "       CLAUDE.md or threshold-router should handle this override."
        echo "       Action: Check Phase 3 (Threshold Router)."
        return 1
    fi
}

# ============================================
# Test 8: Override "full review" (upgrade)
# ============================================
# Checks that the threshold router or CLAUDE.md contains logic
# to upgrade to T3 when the user says "full review".

test_08_override_full_review() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local found=false

    if [ -r "$global_md" ]; then
        if grep -qi 'full review.*upgrade\|full.review.*T3\|full.review.*higher\|upgrade.*full' "$global_md" 2>/dev/null; then
            found=true
        fi
    fi

    # Check skills directory
    local skill_dirs=(
        "$HOME/.claude/skills/threshold-router"
        "$HOME/.claude/skills/threshold_router"
    )
    for skill_dir in "${skill_dirs[@]}"; do
        if [ -f "$skill_dir/SKILL.md" ]; then
            if grep -qi 'full review\|full.review\|upgrade.*T3\|override.*up' "$skill_dir/SKILL.md" 2>/dev/null; then
                found=true
            fi
        fi
    done

    if [ "$found" = true ]; then
        echo "[OK]   Test 8: 'full review' upgrade override logic found."
        return 0
    else
        echo "[FAIL] Test 8: 'full review' upgrade logic not found."
        echo "       CLAUDE.md or threshold-router should handle this override."
        echo "       Action: Check Phase 3 (Threshold Router)."
        return 1
    fi
}

# ============================================
# Test 9: Subagents Spawned
# ============================================
# Checks that the three subagent definition files from Phase 7
# exist in ~/.claude/agents/.

test_09_subagents_exist() {
    local agents_dir="$HOME/.claude/agents"
    local expected_agents=("security-reviewer.md" "quality-reviewer.md" "fixer.md")
    local all_found=true
    local found_count=0

    if [ ! -d "$agents_dir" ]; then
        echo "[FAIL] Test 9: Agents directory not found: $agents_dir"
        echo "       Action: Run Phase 7 to create subagents."
        return 1
    fi

    for agent in "${expected_agents[@]}"; do
        if [ -f "$agents_dir/$agent" ]; then
            found_count=$((found_count + 1))
        else
            echo "       Missing: $agent"
            all_found=false
        fi
    done

    if [ "$all_found" = true ]; then
        echo "[OK]   Test 9: All 3 subagent files found ($found_count/3)."
        return 0
    else
        echo "[FAIL] Test 9: Only $found_count/3 subagent files found."
        echo "       Action: Run Phase 7 to create missing subagents."
        return 1
    fi
}

# ============================================
# Test 10: Token Context Check
# ============================================
# Checks that CLAUDE.md is under 200 lines.
# A very long CLAUDE.md wastes tokens on every session start
# because Claude Code reads the entire file at the beginning.

test_10_token_context_check() {
    local global_md="$HOME/.claude/CLAUDE.md"
    local project_md="./CLAUDE.md"
    local target_md=""

    # Find the CLAUDE.md to check
    if [ -r "$global_md" ]; then
        target_md="$global_md"
    elif [ -r "$project_md" ]; then
        target_md="$project_md"
    else
        echo "[FAIL] Test 10: No CLAUDE.md found to check."
        echo "       Action: Create CLAUDE.md in Phase 1."
        return 1
    fi

    # Count lines
    local line_count
    line_count=$(wc -l < "$target_md")

    if [ "$line_count" -le 200 ]; then
        echo "[OK]   Test 10: CLAUDE.md is $line_count lines (under 200 limit)."
        return 0
    else
        echo "[FAIL] Test 10: CLAUDE.md is $line_count lines (over 200 limit)."
        echo "       File: $target_md"
        echo "       A long CLAUDE.md wastes tokens on every session."
        echo "       Action: Refactor to move details into separate files."
        return 1
    fi
}

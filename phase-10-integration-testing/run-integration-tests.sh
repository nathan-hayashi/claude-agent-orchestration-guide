#!/usr/bin/env bash
# ============================================
# run-integration-tests.sh
# ============================================
# WHAT:   Orchestrator that runs all 10 integration tests to verify
#         the Claude Code Agent Orchestration system is correctly
#         installed and configured.
#
#         Tests check: CLAUDE.md, threshold router, security hooks,
#         formatter hooks, error recovery, overrides, subagents,
#         and token budget.
#
# WHERE:  Run from the phase-10-integration-testing/ directory
#         or from the repository root.
# WHEN:   After completing all phases (1-9).
# HOW:    bash run-integration-tests.sh
#
# OUTPUT: Each test prints [OK] or [FAIL].
#         Summary at the end shows total pass/fail counts.
#         Exit code 0 if all pass, 1 if any fail.
# ============================================

# --- Source platform detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

# We do NOT set -e here because we want to continue running tests
# even if individual tests fail. We track results ourselves.
set -uo pipefail

echo ""
echo "============================================================"
echo "  Claude Code Agent Orchestration -- Integration Tests"
echo "============================================================"
echo ""
echo "  Running 10 integration tests to verify your setup."
echo "  Each test checks a specific component of the system."
echo ""
echo "  Platform: $PLATFORM"
echo "  Home:     $HOME_DIR"
echo "  Date:     $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "============================================================"
echo ""

# --- Source the test case functions ---
# test-cases.sh contains the individual test functions.
# It should be in the same directory as this script.

TEST_CASES="$SCRIPT_DIR/test-cases.sh"

if [ ! -f "$TEST_CASES" ]; then
    echo "[FAIL] Cannot find test-cases.sh at: $TEST_CASES"
    echo "       This file contains the individual test functions."
    echo "       Make sure it is in the same directory as this script."
    exit 1
fi

source "$TEST_CASES"

# --- Run all tests ---
# We track results in arrays so we can print a summary at the end.

TOTAL=0
PASSED=0
FAILED=0
RESULTS=()

# Helper: run a test function and record the result
run_test() {
    local test_num="$1"
    local test_name="$2"
    local test_func="$3"

    TOTAL=$((TOTAL + 1))

    echo "--- Test $test_num: $test_name ---"
    echo ""

    # Run the test function and capture its exit code
    if "$test_func"; then
        PASSED=$((PASSED + 1))
        RESULTS+=("PASS  Test $test_num: $test_name")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("FAIL  Test $test_num: $test_name")
    fi

    echo ""
}

# --- Execute all 10 tests ---

run_test  1 "CLAUDE.md loads"              test_01_claude_md_loads
run_test  2 "T1 on simple edit"            test_02_t1_simple_edit
run_test  3 "T3 on IAM audit"             test_03_t3_iam_audit
run_test  4 "Security hook blocks rm -rf"  test_04_security_hook_blocks_rm
run_test  5 "Prettier auto-format fires"   test_05_prettier_autoformat
run_test  6 "Error recovery hook fires"    test_06_error_recovery_hook
run_test  7 "Override: just do it"         test_07_override_just_do_it
run_test  8 "Override: full review"        test_08_override_full_review
run_test  9 "Subagents spawned"            test_09_subagents_exist
run_test 10 "Token context check"          test_10_token_context_check

# --- Print Summary ---

echo "============================================================"
echo "  Test Results Summary"
echo "============================================================"
echo ""

for result in "${RESULTS[@]}"; do
    echo "  $result"
done

echo ""
echo "------------------------------------------------------------"
echo "  Total:  $TOTAL"
echo "  Passed: $PASSED"
echo "  Failed: $FAILED"
echo "------------------------------------------------------------"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "[OK]   All $TOTAL tests passed."
    echo "       Your Claude Code Agent Orchestration system is configured."
    echo ""
    exit 0
else
    echo "[FAIL] $FAILED of $TOTAL tests failed."
    echo "       Review the failure messages above for remediation steps."
    echo "       Each failure message includes which phase to revisit."
    echo ""
    exit 1
fi

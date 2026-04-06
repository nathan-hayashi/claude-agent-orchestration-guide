#!/usr/bin/env bash
# ============================================
# test-hooks.sh -- Validate your settings.json configuration
# ============================================
# WHAT:   Checks that your settings.json is correctly formatted and
#         contains the right values. Catches the most common errors
#         from the implementation session.
# WHERE:  Run from any directory. Checks ~/.claude/settings.json.
# WHEN:   After running create-settings-json.sh (Phase 2).
# HOW:    ./test-hooks.sh
#
# This script catches these known errors:
#   Error #1: Model field has ANSI escape code (claude-opus-4-6[1m])
#   Error #2: autoMode.environment is a string instead of an array
#   Error #10: JSON has // comments or trailing commas (invalid JSON)
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

SETTINGS="$HOME/.claude/settings.json"
PASS=0
FAIL=0

echo ""
echo "=== Hook Configuration Validator ==="
echo "Checking: $SETTINGS"
echo ""

# --- Check 1: File exists ---
if [[ ! -f "$SETTINGS" ]]; then
    echo "  [FAIL] settings.json not found at $SETTINGS"
    echo ""
    echo "  Run create-settings-json.sh first (Phase 2)."
    exit 1
fi

# --- Check 2: Valid JSON syntax ---
# JSON does NOT allow // comments or trailing commas.
# If you copied from a tutorial with comments, they need to be removed.
if python3 -c "import json; json.load(open('$SETTINGS'))" 2>/dev/null; then
    echo "  [OK]   JSON syntax is valid"
    ((PASS++))
elif command -v jq &>/dev/null && jq . "$SETTINGS" &>/dev/null; then
    echo "  [OK]   JSON syntax is valid (checked with jq)"
    ((PASS++))
else
    echo "  [FAIL] JSON syntax is INVALID"
    echo "         Common causes: // comments, trailing commas, unquoted keys"
    echo "         Fix: Remove all // comments and trailing commas"
    ((FAIL++))
fi

# --- Check 3: Model field is exactly "claude-opus-4-6" ---
# Error #1 from the debugging log: the terminal can inject ANSI bold
# escape codes into the model string, making it "claude-opus-4-6[1m]"
# which is NOT a valid model identifier.
MODEL=$(python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
print(data.get('model', '(not set)'))
" 2>/dev/null || echo "(parse error)")

if [[ "$MODEL" == "claude-opus-4-6" ]]; then
    echo "  [OK]   Model field is correct: $MODEL"
    ((PASS++))
elif [[ "$MODEL" == *"[1m"* ]]; then
    echo "  [FAIL] Model field has ANSI escape code: $MODEL"
    echo "         Fix: Change to exactly \"claude-opus-4-6\" (no suffix)"
    ((FAIL++))
elif [[ "$MODEL" == "(not set)" ]]; then
    echo "  [WARN] Model field is not set (will use default)"
    ((PASS++))
else
    echo "  [WARN] Model field is: $MODEL (expected: claude-opus-4-6)"
    ((PASS++))
fi

# --- Check 4: autoMode.environment is an array, not a string ---
# Error #2: Using a single string causes a "Settings Error".
# It MUST be an array of strings: ["description1", "description2"]
ENV_TYPE=$(python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
env = data.get('autoMode', {}).get('environment')
if env is None:
    print('missing')
elif isinstance(env, list):
    print('array')
elif isinstance(env, str):
    print('string')
else:
    print('unknown')
" 2>/dev/null || echo "parse_error")

if [[ "$ENV_TYPE" == "array" ]]; then
    echo "  [OK]   autoMode.environment is an array"
    ((PASS++))
elif [[ "$ENV_TYPE" == "string" ]]; then
    echo "  [FAIL] autoMode.environment is a STRING (must be an ARRAY)"
    echo "         Fix: Wrap in array brackets: [\"your description here\"]"
    ((FAIL++))
elif [[ "$ENV_TYPE" == "missing" ]]; then
    echo "  [SKIP] autoMode section not found (auto mode not configured)"
    ((PASS++))
else
    echo "  [WARN] Could not parse autoMode.environment"
    ((PASS++))
fi

# --- Check 5: All 7 hook event types are present ---
# The 7 events: PreToolUse (x2), PostToolUse (x2), PostToolUseFail, Notification, Stop
HOOK_COUNT=$(python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
hooks = data.get('hooks', {})
count = 0
for event_type in hooks:
    if isinstance(hooks[event_type], list):
        count += len(hooks[event_type])
    else:
        count += 1
print(count)
" 2>/dev/null || echo "0")

if [[ "$HOOK_COUNT" -ge 6 ]]; then
    echo "  [OK]   Found $HOOK_COUNT hook event configurations"
    ((PASS++))
elif [[ "$HOOK_COUNT" -gt 0 ]]; then
    echo "  [WARN] Only $HOOK_COUNT hook events found (expected 6+)"
    ((PASS++))
else
    echo "  [FAIL] No hooks configured"
    echo "         Fix: Re-run create-settings-json.sh"
    ((FAIL++))
fi

# --- Check 6: Permission allow list has entries ---
ALLOW_COUNT=$(python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
print(len(data.get('permissions', {}).get('allow', [])))
" 2>/dev/null || echo "0")

if [[ "$ALLOW_COUNT" -ge 30 ]]; then
    echo "  [OK]   $ALLOW_COUNT permission allow rules configured"
    ((PASS++))
elif [[ "$ALLOW_COUNT" -gt 0 ]]; then
    echo "  [WARN] Only $ALLOW_COUNT allow rules (expected 30+)"
    ((PASS++))
else
    echo "  [WARN] No permission allow rules found"
    ((PASS++))
fi

# --- Check 7: Permission deny list has entries ---
DENY_COUNT=$(python3 -c "
import json
with open('$SETTINGS') as f:
    data = json.load(f)
print(len(data.get('permissions', {}).get('deny', [])))
" 2>/dev/null || echo "0")

if [[ "$DENY_COUNT" -ge 6 ]]; then
    echo "  [OK]   $DENY_COUNT permission deny rules configured"
    ((PASS++))
else
    echo "  [WARN] Only $DENY_COUNT deny rules (expected 6+)"
    ((PASS++))
fi

# --- Summary ---
echo ""
echo "=== Results ==="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo ""

if [[ "$FAIL" -gt 0 ]]; then
    echo "  [FAIL] $FAIL issue(s) found. Fix them before proceeding to Phase 3."
    exit 1
else
    echo "  [OK]   All checks passed! Your hooks configuration is valid."
    echo "         You can proceed to Phase 3: Threshold Escalation Engine."
    exit 0
fi

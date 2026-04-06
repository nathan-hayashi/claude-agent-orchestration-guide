#!/usr/bin/env bash
# =============================================================================
# create-threshold-skill.sh -- Create the threshold-router skill
# =============================================================================
# PURPOSE:  Creates the threshold-router skill definition file at
#           ~/.claude/skills/threshold-router/SKILL.md
#
#           This skill is invoked on EVERY prompt to compute a complexity
#           score and assign a tier (T1, T2, or T3) that controls how
#           much review and verification Claude performs.
#
# USAGE:    ./create-threshold-skill.sh
#           ./create-threshold-skill.sh --force   # overwrite without asking
#
# ALSO DOES:
#   - Ensures the mandatory threshold section exists in ~/.claude/CLAUDE.md
#   - Without that section, the skill won't activate on simpler tasks
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

SKILL_DIR="$HOME/.claude/skills/threshold-router"
SKILL_FILE="$SKILL_DIR/SKILL.md"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

echo ""
echo "===== Create Threshold Router Skill ====="
echo "[INFO] Skill file: $SKILL_FILE"
echo "[INFO] CLAUDE.md: $CLAUDE_MD"
echo ""

# --- Ensure directories exist ---
mkdir -p "$SKILL_DIR"

# --- Check if skill file already exists ---
if [[ -f "$SKILL_FILE" ]]; then
    echo "[INFO] SKILL.md already exists at $SKILL_FILE"

    if [[ "$FORCE" != "true" ]]; then
        read -rp "Overwrite? (y/N): " OVERWRITE
        if [[ "${OVERWRITE,,}" != "y" ]]; then
            echo "[SKIP] Keeping existing SKILL.md."
        else
            BACKUP="${SKILL_FILE}.bak.$(date '+%Y%m%d')"
            cp "$SKILL_FILE" "$BACKUP"
            echo "[INFO] Backed up to: $BACKUP"
        fi
    else
        BACKUP="${SKILL_FILE}.bak.$(date '+%Y%m%d')"
        cp "$SKILL_FILE" "$BACKUP"
        echo "[INFO] Backed up to: $BACKUP"
    fi
fi

# --- Write the skill definition ---
cat > "$SKILL_FILE" << 'SKILL_MD'
---
name: threshold-router
description: >
  Mandatory complexity scoring system. Computes a 0-10+ score for every
  prompt and assigns a tier (T1, T2, T3) that controls verification depth.
  Must be invoked on EVERY user prompt before any other action.
---

# Threshold Router

## Activation
This skill is MANDATORY. Invoke it on EVERY user prompt, no exceptions.
Announce the tier at the start of every response: [T1], [T2], or [T3].

## Scoring Table

Compute a complexity score by summing applicable signals:

| Signal                              | Score  |
|-------------------------------------|--------|
| Per 3 files mentioned or affected   | +1     |
| Destructive keywords (delete, drop) | +2     |
| Cross-system scope (API + frontend) | +2     |
| New architecture or infrastructure  | +3     |
| Security / IAM / auth changes       | +2     |
| Production deployment               | +2     |
| Ambiguous or open-ended request     | +1     |
| Database schema changes             | +2     |
| Multi-service coordination          | +2     |
| Performance-critical path           | +1     |

## Tier Assignment

| Tier | Score | Label            | Behavior                                |
|------|-------|------------------|-----------------------------------------|
| T1   | 0-3   | Solo             | Execute directly. Report results.       |
| T2   | 4-7   | Lean pipeline    | Execute, then spawn review subagents.   |
| T3   | 8+    | Full orchestra   | Plan (ultrathink), execute, full review.|

## Tier-Specific Behavior

### [T1] Solo (score 0-3)
- Proceed directly with implementation
- Run basic verification (type check, relevant tests)
- No subagent review needed

### [T2] Lean Pipeline (score 4-7)
- Implement the change
- Spawn review subagents to check:
  - Code quality and style consistency
  - Test coverage for changed code
  - Potential bugs or regressions
- Address any findings before reporting done

### [T3] Full Orchestra (score 8+)
- Create a detailed plan using extended thinking (ultrathink)
- Get plan approval before implementing
- Implement the change
- Run full review pipeline:
  - OCR multi-agent code review (if available)
  - Codex verification (if available)
  - Type checker + full test suite
- Address all findings before reporting done

## Override System

Users can override the computed tier with keywords:

- **"just do it"** -- Force downgrade to T1 (skip all reviews)
- **"full review"** -- Force upgrade to T3 (maximum verification)

The override applies to the current prompt only, not future prompts.

## Response Format

Always start your response with the tier announcement:

```
[T1] This is a simple change...
[T2] This involves multiple files...
[T3] This is a complex architectural change...
```

## Edge Cases

- If scoring is ambiguous, round UP (prefer more review over less)
- If the user says "quick fix" but the change is complex, announce T2
  and explain why you scored it higher
- If the user provides no context, ask for clarification rather than
  defaulting to T1
SKILL_MD

echo "[OK]   SKILL.md written to $SKILL_FILE"

# --- Ensure CLAUDE.md has the mandatory threshold section ---
echo ""
echo "[INFO] Checking CLAUDE.md for mandatory threshold section..."

if [[ ! -f "$CLAUDE_MD" ]]; then
    echo "[WARN] CLAUDE.md not found at $CLAUDE_MD"
    echo "       Run create-claude-md.sh (Phase 1) first."
    echo "       The threshold router needs the mandatory section in CLAUDE.md"
    echo "       to activate on every prompt."
else
    # Check if the mandatory section already exists
    if grep -q "Threshold Escalation" "$CLAUDE_MD" 2>/dev/null; then
        echo "[OK]   CLAUDE.md already contains the threshold escalation section."
    else
        echo "[INFO] Adding mandatory threshold section to CLAUDE.md..."

        # Append the mandatory section
        cat >> "$CLAUDE_MD" << 'THRESHOLD_SECTION'

## Threshold Escalation (MANDATORY)
The threshold-router skill MUST be consulted on EVERY prompt.
Compute the complexity score and announce [T1], [T2], or [T3].
Override: "just do it" = downgrade | "full review" = T3
THRESHOLD_SECTION

        echo "[OK]   Added threshold escalation section to CLAUDE.md."
    fi
fi

# --- Summary ---
echo ""
echo "========================================="
echo " Threshold Router Setup Summary"
echo "========================================="
echo ""
echo "  Skill file: $SKILL_FILE"
echo "  CLAUDE.md:  $CLAUDE_MD"
echo ""
echo "  How to test:"
echo "    1. Start Claude Code: claude"
echo "    2. Give it any prompt"
echo "    3. Claude should announce [T1], [T2], or [T3] at the start"
echo ""
echo "  If it doesn't work:"
echo "    - Run test-threshold.sh to check prerequisites"
echo "    - Verify CLAUDE.md has the 'Threshold Escalation' section"
echo ""
echo "[OK]   Threshold router skill creation complete."

#!/usr/bin/env bash
# =============================================================================
# check-project.sh -- Health check for Claude Code orchestration config
# =============================================================================
# PURPOSE:  Quickly shows which orchestration config files are present in the
#           current project and globally. Useful for debugging why skills,
#           OCR, or settings aren't working as expected.
#
# USAGE:    bash scripts/check-project.sh     (from any project root)
#
# OUTPUT:   Checkmark table with [OK] or [!!] for each expected file,
#           plus counts of installed skills and agents.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Helper: check if a path exists and print status
#   $1 = path to check
#   $2 = display label (what to print)
#   $3 = optional extra info (e.g., "symlink" or "directory")
# ---------------------------------------------------------------------------
check_path() {
    local path="$1"
    local label="$2"
    local note="${3:-}"

    if [[ -e "$path" || -L "$path" ]]; then
        # File or symlink exists
        local extra=""
        if [[ -n "$note" ]]; then
            extra=" ($note)"
        elif [[ -L "$path" ]]; then
            extra=" (symlink)"
        elif [[ -d "$path" ]]; then
            extra=" (directory)"
        fi
        echo " [OK] $label$extra"
    else
        echo " [!!] $label MISSING"
    fi
}

# ---------------------------------------------------------------------------
# Project-level checks
# ---------------------------------------------------------------------------
PROJ_DIR="$(pwd)"
PROJ_NAME="$(basename "$PROJ_DIR")"

echo ""
echo "=== Project: $PROJ_NAME ($PROJ_DIR) ==="

# Core Claude Code config
check_path ".claude/settings.json"  ".claude/settings.json"

# Rules: could be a symlink to global rules or a real directory
if [[ -L ".claude/rules" ]]; then
    check_path ".claude/rules" ".claude/rules" "symlink -> $(readlink .claude/rules)"
elif [[ -d ".claude/rules" ]]; then
    check_path ".claude/rules" ".claude/rules" "directory"
else
    echo " [!!] .claude/rules MISSING"
fi

# MCP server config
check_path ".mcp.json" ".mcp.json"

# Open Code Review config
check_path ".ocr/config.yaml" ".ocr/config.yaml"

# Worktree isolation list
check_path ".worktreeinclude" ".worktreeinclude"

# Project-level instructions
check_path "CLAUDE.md" "CLAUDE.md"

# ---------------------------------------------------------------------------
# Global checks
# ---------------------------------------------------------------------------
echo ""
echo "=== Global ==="

check_path "$HOME/.claude/CLAUDE.md"       "~/.claude/CLAUDE.md"
check_path "$HOME/.claude/settings.json"   "~/.claude/settings.json"

# ---------------------------------------------------------------------------
# Count skills and agents
#   ls piped to wc -l counts entries. We exclude . and .. by not using -a.
#   The 2>/dev/null handles the case where the directory doesn't exist.
# ---------------------------------------------------------------------------
SKILL_COUNT=0
if [[ -d "$HOME/.claude/skills" ]]; then
    SKILL_COUNT=$(ls "$HOME/.claude/skills/" 2>/dev/null | wc -l)
fi

AGENT_COUNT=0
if [[ -d "$HOME/.claude/agents" ]]; then
    AGENT_COUNT=$(ls "$HOME/.claude/agents/" 2>/dev/null | wc -l)
fi

echo ""
echo "Skills: $SKILL_COUNT"
echo "Agents: $AGENT_COUNT"
echo ""

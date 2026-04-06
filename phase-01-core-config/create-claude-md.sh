#!/usr/bin/env bash
# =============================================================================
# create-claude-md.sh -- Create the global CLAUDE.md configuration file
# =============================================================================
# PURPOSE:  Creates ~/.claude/CLAUDE.md, which is the global instructions file
#           that Claude Code reads for EVERY project. It controls how Claude
#           writes code, verifies work, formats commits, and communicates.
#
# USAGE:    ./create-claude-md.sh
#           ./create-claude-md.sh --force   # overwrite without asking
#
# WHAT IS CLAUDE.MD:
#   CLAUDE.md is like a "personality config" for Claude Code. It tells Claude:
#   - What coding standards to follow (Prettier, conventional commits)
#   - How to verify its own work (run tests, re-read files)
#   - How to communicate (concise, no filler)
#   - What git workflow to use (dev branch, never push to main)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

TARGET="$HOME/.claude/CLAUDE.md"

echo ""
echo "===== Create Global CLAUDE.md ====="
echo "[INFO] Target: $TARGET"
echo ""

# --- Ensure directory exists ---
mkdir -p "$HOME/.claude"

# --- Check if file already exists ---
if [[ -f "$TARGET" ]]; then
    echo "[INFO] CLAUDE.md already exists at $TARGET"

    if [[ "$FORCE" != "true" ]]; then
        read -rp "Overwrite? (y/N): " OVERWRITE
        if [[ "${OVERWRITE,,}" != "y" ]]; then
            echo "[SKIP] Keeping existing CLAUDE.md."
            exit 0
        fi
    fi

    # Backup the existing file
    BACKUP="${TARGET}.bak.$(date '+%Y%m%d')"
    cp "$TARGET" "$BACKUP"
    echo "[INFO] Backed up existing file to: $BACKUP"
fi

# --- Write the CLAUDE.md template ---
# This template covers the essential sections. Customize it for your workflow.
cat > "$TARGET" << 'CLAUDEMD'
# Global CLAUDE.md -- Development Environment

## Environment
WSL 2 Ubuntu 24.04 | Node v24.14.0 | npm 11.9.0
Projects: separate repos under ~/projects/

## Verification (non-negotiable)
- Before claiming complete, run type checker + relevant tests
- After compaction or 8+ messages, re-read modified files
- When recalling API/library behavior, read source first
- Never act on recalled information without file verification
- If grep returns few results, narrow scope (truncation risk)
- State uncertainty explicitly rather than guessing

## Code Standards
- Formatter: Prettier (auto-runs via PostToolUse hook)
- Commits: conventional format (feat:, fix:, chore:, docs:, refactor:)
- No console.log in production; use structured logging
- No hardcoded secrets; use .env or env vars
- Pin all dependency versions

## Git Workflow
- Branches: main (production), dev (working)
- Commit to dev. Never push directly to main.
- Commit messages: explain WHY not just WHAT

## Threshold Escalation (MANDATORY)
The threshold-router skill MUST be consulted on EVERY prompt.
Compute the complexity score and announce [T1], [T2], or [T3].
Override: "just do it" = downgrade | "full review" = T3

## Communication
- Direct and concise. No filler.
- Present options with trade-offs.
- State interpretation before executing if ambiguous.
CLAUDEMD

echo "[OK]   CLAUDE.md written to $TARGET"
echo ""
echo "[INFO] Contents:"
echo "---"
cat "$TARGET"
echo "---"
echo ""
echo "[INFO] Customize this file for your specific environment."
echo "       Edit with: claude edit $TARGET"
echo "       or: nano $TARGET"
echo ""
echo "[OK]   Global CLAUDE.md creation complete."

#!/usr/bin/env bash
# =============================================================================
# new-project.sh -- Bootstrap Claude Code orchestration in a new repo
# =============================================================================
# PURPOSE:  Sets up the standard directory structure, config files, and
#           symlinks that Claude Code expects in an orchestrated project.
#           Run this once after cloning any repo you want to work on with
#           Claude Code + OCR + skills.
#
# USAGE:    ~/bin/new-project          (from inside the repo root)
#           bash scripts/new-project.sh
#
# SAFETY:   Idempotent -- safe to run multiple times. Uses mkdir -p and
#           never overwrites files that already exist.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# The project root is wherever you run this script from.
# ---------------------------------------------------------------------------
PROJ_DIR="$(pwd)"
PROJ_NAME="$(basename "$PROJ_DIR")"

echo ""
echo "=== Bootstrapping Claude Code orchestration ==="
echo "    Project: $PROJ_NAME"
echo "    Path:    $PROJ_DIR"
echo ""

# ---------------------------------------------------------------------------
# 1. Create standard directories
#    - .claude/skills   Local skill overrides (project-specific)
#    - .claude/agents   Custom subagent definitions
#    - .ocr             Open Code Review config
# ---------------------------------------------------------------------------
for dir in .claude/skills .claude/agents .ocr; do
    if [[ -d "$dir" ]]; then
        echo "[SKIP] $dir/ already exists"
    else
        mkdir -p "$dir"
        echo "[OK]   Created $dir/"
    fi
done

# ---------------------------------------------------------------------------
# 2. Symlink global rules into the project
#    Your global rules live at ~/.claude/rules. This symlink lets Claude Code
#    find them inside the project without duplicating files.
#    The -n flag prevents creating a link inside an existing directory.
# ---------------------------------------------------------------------------
if [[ -L ".claude/rules" ]]; then
    echo "[SKIP] .claude/rules symlink already exists"
elif [[ -d ".claude/rules" ]]; then
    echo "[SKIP] .claude/rules is a real directory -- not overwriting"
else
    ln -sfn ~/.claude/rules .claude/rules 2>/dev/null && \
        echo "[OK]   Symlinked .claude/rules -> ~/.claude/rules" || \
        echo "[WARN] Could not create .claude/rules symlink (source may not exist)"
fi

# ---------------------------------------------------------------------------
# 3. Copy MCP config from global location
#    .mcp.json tells Claude Code which MCP servers are available.
#    We copy (not symlink) so projects can customize their MCP setup.
# ---------------------------------------------------------------------------
if [[ -f ".mcp.json" ]]; then
    echo "[SKIP] .mcp.json already exists"
else
    if cp ~/.claude/.mcp.json .mcp.json 2>/dev/null; then
        echo "[OK]   Copied .mcp.json from ~/.claude/.mcp.json"
    else
        echo "[WARN] No ~/.claude/.mcp.json found -- skipping MCP config"
    fi
fi

# ---------------------------------------------------------------------------
# 4. Create OCR config with standard review team
#    This sets up Open Code Review with a balanced team:
#      - 2 principal reviewers (architecture + design)
#      - 2 security reviewers (vulnerabilities + compliance)
#      - 1 quality reviewer  (tests + maintainability)
#    Discourse mode lets reviewers discuss disagreements.
#    2 rounds means reviewers can respond to each other once.
# ---------------------------------------------------------------------------
if [[ -f ".ocr/config.yaml" ]]; then
    echo "[SKIP] .ocr/config.yaml already exists"
else
    cat > .ocr/config.yaml << 'YAML'
# Open Code Review -- standard team configuration
# Adjust reviewer counts and rounds to match your project's needs.

team:
  principal: 2      # Architecture and design reviewers
  security: 2       # Security and compliance reviewers
  quality: 1        # Test coverage and maintainability reviewer

discourse:
  enabled: true     # Let reviewers discuss and debate findings
  rounds: 2         # Number of back-and-forth rounds allowed
YAML
    echo "[OK]   Created .ocr/config.yaml (principal:2, security:2, quality:1)"
fi

# ---------------------------------------------------------------------------
# 5. Create .worktreeinclude for subagent worktree isolation
#    When Claude Code spawns subagents in git worktrees, these files
#    are copied into the worktree so subagents have access to secrets
#    and environment config. Without this, worktrees miss .env files.
# ---------------------------------------------------------------------------
if [[ -f ".worktreeinclude" ]]; then
    echo "[SKIP] .worktreeinclude already exists"
else
    cat > .worktreeinclude << 'EOF'
# Files to copy into subagent worktrees.
# One path per line, relative to repo root.
.env
.env.local
EOF
    echo "[OK]   Created .worktreeinclude (.env, .env.local)"
fi

# ---------------------------------------------------------------------------
# Done!
# ---------------------------------------------------------------------------
echo ""
echo "[INFO] Project initialized at $PROJ_DIR"
echo "[INFO] Next steps:"
echo "         1. Edit .ocr/config.yaml to tune your review team"
echo "         2. Add project-specific skills to .claude/skills/"
echo "         3. Create CLAUDE.md with project context"
echo ""

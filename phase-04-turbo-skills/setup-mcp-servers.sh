#!/usr/bin/env bash
# ============================================
# setup-mcp-servers.sh
# ============================================
# WHAT:   Creates the .mcp.json file in your project root.
#         This file tells Claude Code how to connect to MCP servers
#         (Model Context Protocol) for extended capabilities.
#
#         Configures two MCP servers:
#         1. sequential-thinking -- structured reasoning for complex problems
#         2. github -- direct GitHub API access (PRs, issues, code search)
#
# WHERE:  Run from your project root directory.
# WHEN:   After installing Turbo (install-turbo.sh).
# HOW:    bash phase-04-turbo-skills/setup-mcp-servers.sh
#
# FLAGS:  --force   Overwrite existing .mcp.json without prompting
#
# SECURITY:
#   The GitHub MCP server requires a personal access token (PAT).
#   This script uses ${GH_TOKEN} -- an environment variable reference.
#   NEVER hardcode tokens in .mcp.json!
#   Error #9: GitHub push protection will block commits containing
#   token patterns like gho_**** or ghp_****.
# ============================================

# --- Source platform detection ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

set -euo pipefail

# --- Parse command line flags ---
FORCE=false
for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
    esac
done

echo ""
echo "=================================================="
echo "  Phase 4: Setup MCP Servers"
echo "=================================================="
echo ""

# --- Determine project root ---
# We look for a .git directory to find the project root.
# If not in a git repo, use the current directory.

if git rev-parse --show-toplevel &>/dev/null; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
    PROJECT_ROOT="$(pwd)"
    echo "[WARN] Not in a git repository. Using current directory:"
    echo "       $PROJECT_ROOT"
    echo ""
fi

MCP_FILE="$PROJECT_ROOT/.mcp.json"

# --- Check for existing config ---
if [ -f "$MCP_FILE" ]; then
    if [ "$FORCE" = true ]; then
        # Back up the existing file before overwriting
        BACKUP="$MCP_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$MCP_FILE" "$BACKUP"
        echo "[INFO] Backed up existing .mcp.json to:"
        echo "       $BACKUP"
    else
        echo "[SKIP] .mcp.json already exists at: $MCP_FILE"
        echo "       To overwrite, run with --force flag:"
        echo "       bash setup-mcp-servers.sh --force"
        echo ""
        echo "       Current contents:"
        cat "$MCP_FILE"
        echo ""
        exit 0
    fi
fi

# --- Write the .mcp.json file ---
# This JSON file defines which MCP servers Claude Code can connect to.
# Each server entry has:
#   - command: the program to run (npx downloads and runs npm packages)
#   - args: command-line arguments for that program
#   - env: environment variables (only for servers that need auth)

cat > "$MCP_FILE" << 'MCPJSON'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking-server"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/github-mcp-server"],
      "env": {
        "GH_TOKEN": "${GH_TOKEN}"
      }
    }
  }
}
MCPJSON

echo "[OK]   Created .mcp.json at: $MCP_FILE"
echo ""

# --- Verify GH_TOKEN is set ---
# The GitHub MCP server needs a token to authenticate.
# Check if the user has one configured.

if [ -z "${GH_TOKEN:-}" ]; then
    echo "[WARN] GH_TOKEN environment variable is not set."
    echo ""
    echo "       The GitHub MCP server needs a personal access token."
    echo "       To create one:"
    echo "       1. Go to: https://github.com/settings/tokens"
    echo "       2. Generate a new token (classic) with repo scope"
    echo "       3. Add it to your shell config:"
    echo "          echo 'export GH_TOKEN=\"ghp_your_token_here\"' >> $SHELL_RC"
    echo "          source $SHELL_RC"
    echo ""
    echo "       SECURITY: Never commit tokens to git!"
    echo "       Error #9: GitHub push protection blocks gho_*/ghp_* patterns."
else
    echo "[OK]   GH_TOKEN is set in your environment."
fi

echo ""

# --- Remind about .gitignore ---
# .mcp.json may contain env var references that are safe to commit,
# but some teams prefer to keep it out of version control.

GITIGNORE="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if grep -q "\.mcp\.json" "$GITIGNORE" 2>/dev/null; then
        echo "[OK]   .mcp.json is already in .gitignore"
    else
        echo "[INFO] Consider adding .mcp.json to .gitignore if your team"
        echo "       does not want MCP config in version control:"
        echo "       echo '.mcp.json' >> $GITIGNORE"
    fi
fi

echo ""
echo "[OK]   MCP servers configured. Restart Claude Code to load them."
echo ""

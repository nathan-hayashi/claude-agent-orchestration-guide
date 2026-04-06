#!/usr/bin/env bash
# ============================================
# install-ocr.sh
# ============================================
# WHAT:   Installs the Open Code Review (OCR) plugin for Claude Code.
#         OCR adds a virtual code review team that examines your changes
#         from multiple perspectives (security, quality, architecture).
#
# WHERE:  Run from your project root directory.
# WHEN:   After completing Phase 4 (Turbo Skills + MCP Servers).
# HOW:    bash phase-05-open-code-review/install-ocr.sh
#
# FLAGS:  --force   Overwrite existing .ocr/config.yaml without prompting
#
# IMPORTANT:
#   OCR commands are invoked via natural language, NOT slash commands.
#   Example: "Review my latest changes with OCR"
#   The /ocr:doctor slash command may return "Unknown skill" --
#   use "Run OCR doctor check" in natural language instead.
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
echo "  Phase 5: Install Open Code Review (OCR)"
echo "=================================================="
echo ""

# --- Step 1: Plugin installation instructions ---
# OCR is installed as a Claude Code plugin from the marketplace.
# This must be done from INSIDE a Claude Code session.

echo "[INFO] OCR plugin must be installed from inside Claude Code."
echo ""
echo "  Steps:"
echo "  1. Open a Claude Code session:"
echo "     cd ~/projects/your-project && claude"
echo ""
echo "  2. Install the plugin:"
echo "     /plugin marketplace add spencermarx/open-code-review"
echo ""
echo "  3. Reload plugins to activate:"
echo "     /reload-plugins"
echo ""
echo "  4. Verify installation (use natural language, NOT /ocr:doctor):"
echo "     \"Run OCR doctor check\""
echo ""

# --- Step 2: Create the OCR config directory and file ---
# OCR reads its team composition from .ocr/config.yaml in the project root.
# This file controls how many reviewers of each type participate.

# Find project root
if git rev-parse --show-toplevel &>/dev/null; then
    PROJECT_ROOT="$(git rev-parse --show-toplevel)"
else
    PROJECT_ROOT="$(pwd)"
    echo "[WARN] Not in a git repository. Using current directory."
    echo ""
fi

OCR_DIR="$PROJECT_ROOT/.ocr"
OCR_CONFIG="$OCR_DIR/config.yaml"

# Create the .ocr directory
if [ ! -d "$OCR_DIR" ]; then
    mkdir -p "$OCR_DIR"
    echo "[OK]   Created .ocr/ directory at: $OCR_DIR"
else
    echo "[SKIP] .ocr/ directory already exists."
fi

# Check for existing config
if [ -f "$OCR_CONFIG" ]; then
    if [ "$FORCE" = true ]; then
        # Back up before overwriting
        BACKUP="$OCR_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$OCR_CONFIG" "$BACKUP"
        echo "[INFO] Backed up existing config to: $BACKUP"
    else
        echo "[SKIP] .ocr/config.yaml already exists."
        echo "       To overwrite, run with --force flag."
        echo ""
        echo "       Current contents:"
        cat "$OCR_CONFIG"
        echo ""
        exit 0
    fi
fi

# --- Write the config file ---
# team:      How many reviewers of each specialty to spawn.
#            principal  = architecture, design, scalability
#            security   = vulnerabilities, auth, data exposure
#            quality    = tests, error handling, maintainability
#
# discourse: If enabled, reviewers debate findings to reduce false positives.
#            rounds = how many rounds of discussion.

cat > "$OCR_CONFIG" << 'OCRCONFIG'
# Open Code Review (OCR) team composition
# Adjust counts based on your review needs.
# More reviewers = more thorough but slower reviews.

team:
  # Principal engineers: architecture, design patterns, scalability
  principal: 2
  # Security specialists: vulnerabilities, auth gaps, data exposure
  security: 2
  # Quality engineers: test coverage, error handling, maintainability
  quality: 1

discourse:
  # When enabled, reviewers discuss and challenge each other's findings.
  # This reduces false positives but increases review time.
  enabled: true
  # Number of discussion rounds (1-3 recommended)
  rounds: 2
OCRCONFIG

echo "[OK]   Created .ocr/config.yaml at: $OCR_CONFIG"
echo ""

# --- Remind about .gitignore ---
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if grep -q "\.ocr/" "$GITIGNORE" 2>/dev/null; then
        echo "[OK]   .ocr/ is already in .gitignore"
    else
        echo "[INFO] Consider adding .ocr/ to .gitignore:"
        echo "       echo '.ocr/' >> $GITIGNORE"
    fi
fi

echo ""
echo "[OK]   OCR installation prep complete."
echo "       Remember: invoke OCR via natural language, not slash commands."
echo "       Example: \"Review my latest changes with OCR\""
echo ""

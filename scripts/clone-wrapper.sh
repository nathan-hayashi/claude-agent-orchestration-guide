#!/usr/bin/env bash
# =============================================================================
# clone-wrapper.sh -- Shell function that wraps git clone + auto-bootstrap
# =============================================================================
# PURPOSE:  Provides a `clone` shell function that runs `git clone` and then
#           automatically bootstraps Claude Code orchestration in the new repo.
#           This gives you zero-friction onboarding -- every repo you clone
#           is immediately ready for Claude Code.
#
# USAGE:    This is NOT a standalone script. It prints a shell function
#           definition and instructions for adding it to your shell RC file.
#
#           Run:  bash scripts/clone-wrapper.sh
#           Then: follow the printed instructions
# =============================================================================

set -euo pipefail

cat << 'EXPLANATION'
=============================================================================
 clone() -- Git clone + automatic Claude Code bootstrap
=============================================================================

 WHAT IT DOES:
   1. Runs `git clone` with whatever arguments you pass
   2. cd's into the newly cloned directory
   3. Runs ~/bin/new-project to set up Claude Code orchestration
      (creates .claude/, .ocr/, symlinks global rules, etc.)

 WHY USE IT:
   Without this, you'd clone a repo and then forget to run new-project.sh,
   leading to missing config, broken skills, or OCR not working. This
   wrapper makes orchestration setup automatic -- you never think about it.

 SKIP LIST:
   Some repos are tools themselves (turbo, open-code-review, codex-plugin-cc)
   and don't need orchestration config. The function skips those.

=============================================================================

 Add this function to your shell RC file (~/.bashrc or ~/.zshrc):

EXPLANATION

# Print the actual function definition
cat << 'FUNCTION'
# ---- Claude Code clone wrapper ----
# Wraps `git clone` to auto-bootstrap orchestration in new repos.
# Requires: ~/bin/new-project (symlink or copy of new-project.sh)
clone() {
  # Pass all arguments straight to git clone
  git clone "$@"

  # Extract the directory name from the repo URL.
  # basename strips the path, and we remove .git suffix if present.
  local dir
  dir=$(basename "$1" .git)

  # cd into the cloned repo (bail if it somehow failed)
  cd "$dir" || return

  # Skip tool repos that don't need orchestration config.
  # Add your own tool repos to this list as needed.
  case "$dir" in
    turbo|open-code-review|codex-plugin-cc) return ;;
  esac

  # Run the bootstrap script
  ~/bin/new-project
}
FUNCTION

echo ""
echo "=== Setup instructions ==="
echo ""
echo "  1. Copy the function above into your shell RC file:"
echo "       ~/.bashrc   (if you use bash)"
echo "       ~/.zshrc    (if you use zsh)"
echo ""
echo "  2. Make new-project.sh available as ~/bin/new-project:"
echo "       mkdir -p ~/bin"
echo "       ln -sf $(cd "$(dirname "$0")" && pwd)/new-project.sh ~/bin/new-project"
echo "       chmod +x ~/bin/new-project"
echo ""
echo "  3. Reload your shell:"
echo "       source ~/.bashrc   # or source ~/.zshrc"
echo ""
echo "  4. Test it:"
echo "       clone git@github.com:youruser/some-repo.git"
echo ""
echo "  The clone function passes all arguments to git clone, so flags"
echo "  like --depth=1 or --branch=dev work exactly as expected."
echo ""

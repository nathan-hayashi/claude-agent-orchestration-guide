#!/usr/bin/env bash
# =============================================================================
# validate-repo.sh -- Pre-push validation for the orchestration guide repo
# =============================================================================
# PURPOSE:  Runs a suite of checks on this guide repository before pushing
#           to GitHub. Catches common issues: missing files, syntax errors,
#           leaked secrets, broken links, and structural problems.
#
# USAGE:    bash scripts/validate-repo.sh     (from the repo root)
#
# EXIT:     0 if all checks pass, 1 if any check fails.
#           The full summary is printed at the end with pass/fail counts.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Counters for the final summary
# ---------------------------------------------------------------------------
PASSED=0
FAILED=0

# ---------------------------------------------------------------------------
# Helper: record a pass
#   $1 = description of what passed
# ---------------------------------------------------------------------------
pass() {
    echo " [OK]   $1"
    PASSED=$((PASSED + 1))
}

# ---------------------------------------------------------------------------
# Helper: record a failure
#   $1 = description of what failed
# ---------------------------------------------------------------------------
fail() {
    echo " [FAIL] $1"
    FAILED=$((FAILED + 1))
}

# ---------------------------------------------------------------------------
# Helper: record a warning (informational, does not count as failure)
#   $1 = description
# ---------------------------------------------------------------------------
warn() {
    echo " [WARN] $1"
}

echo ""
echo "=== Validating orchestration guide repository ==="
echo ""

# ---------------------------------------------------------------------------
# 1. STRUCTURE: Verify all expected phase directories exist
#    The guide is organized into phases 00 through 10. Each phase is a
#    directory at the repo root named phase-NN-description.
# ---------------------------------------------------------------------------
echo "--- Phase directories ---"

EXPECTED_PHASES=(
    "phase-00-preflight"
    "phase-01-core-config"
    "phase-02-hooks-system"
    "phase-03-threshold-router"
    "phase-04-turbo-skills"
    "phase-05-open-code-review"
    "phase-06-codex-plugin"
    "phase-07-custom-subagents"
    "phase-08-skills-library"
    "phase-09-auto-mode"
    "phase-10-integration-testing"
)

for phase in "${EXPECTED_PHASES[@]}"; do
    if [[ -d "$phase" ]]; then
        pass "$phase/"
    else
        fail "$phase/ directory missing"
    fi
done

# ---------------------------------------------------------------------------
# 2. SCRIPT LINT: bash -n syntax check on every .sh file
#    The -n flag parses the script without executing it, catching syntax
#    errors like unclosed quotes, missing 'then', or bad redirects.
# ---------------------------------------------------------------------------
echo ""
echo "--- Script syntax (bash -n) ---"

# Find all .sh files using a simple loop over known locations.
# We use a while-read loop with process substitution so we handle
# filenames with spaces correctly.
LINT_ERRORS=0
while IFS= read -r -d '' script; do
    if bash -n "$script" 2>/dev/null; then
        pass "$(basename "$script") syntax OK"
    else
        fail "$(basename "$script") has syntax errors"
        LINT_ERRORS=$((LINT_ERRORS + 1))
    fi
done < <(find . -name "*.sh" -type f -print0 2>/dev/null)

if [[ $LINT_ERRORS -eq 0 ]]; then
    echo " [INFO] All scripts passed syntax check"
fi

# ---------------------------------------------------------------------------
# 3. SHEBANG: Every .sh file should start with #!/usr/bin/env bash
#    This ensures scripts are portable across systems where bash might
#    be installed in different locations (/bin/bash vs /usr/local/bin/bash).
# ---------------------------------------------------------------------------
echo ""
echo "--- Shebang lines ---"

while IFS= read -r -d '' script; do
    # Read just the first line of the file
    first_line=$(head -n 1 "$script")
    if [[ "$first_line" == "#!/usr/bin/env bash" ]]; then
        pass "$(basename "$script") has correct shebang"
    else
        fail "$(basename "$script") missing or wrong shebang (got: $first_line)"
    fi
done < <(find . -name "*.sh" -type f -print0 2>/dev/null)

# ---------------------------------------------------------------------------
# 4. EXECUTABLE: Every .sh file should have the execute permission
#    Without +x, users can't run scripts directly (./script.sh).
# ---------------------------------------------------------------------------
echo ""
echo "--- Execute permissions ---"

while IFS= read -r -d '' script; do
    if [[ -x "$script" ]]; then
        pass "$(basename "$script") is executable"
    else
        fail "$(basename "$script") missing execute permission (run: chmod +x $script)"
    fi
done < <(find . -name "*.sh" -type f -print0 2>/dev/null)

# ---------------------------------------------------------------------------
# 5. SECRETS SCAN: Grep for patterns that look like leaked credentials
#    We check for common API key prefixes and hardcoded password patterns.
#    Files ending in .example are excluded (those are templates).
# ---------------------------------------------------------------------------
echo ""
echo "--- Secrets scan ---"

SECRET_PATTERNS=(
    'sk-[a-zA-Z0-9]{20,}'          # OpenAI / Anthropic API keys
    'ghp_[a-zA-Z0-9]{36}'          # GitHub personal access tokens
    'gho_[a-zA-Z0-9]{36}'          # GitHub OAuth tokens
    'password=[^$]'                 # Hardcoded passwords (not variable refs)
    'ANTHROPIC_API_KEY=[^$\{]'      # Hardcoded Anthropic keys
    'OPENAI_API_KEY=[^$\{]'         # Hardcoded OpenAI keys
)

SECRETS_FOUND=0
for pattern in "${SECRET_PATTERNS[@]}"; do
    # Search all files except .example files and .git directory
    # grep -r: recursive, -l: filenames only, -E: extended regex
    matches=$(grep -rlE "$pattern" --include="*" --exclude="*.example" --exclude-dir=".git" . 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
        while IFS= read -r match; do
            fail "Possible secret in $match (pattern: $pattern)"
            SECRETS_FOUND=$((SECRETS_FOUND + 1))
        done <<< "$matches"
    fi
done

if [[ $SECRETS_FOUND -eq 0 ]]; then
    pass "No hardcoded secrets detected"
fi

# ---------------------------------------------------------------------------
# 6. CONFIG EXAMPLES: Each phase's configs/ dir should have .example files
#    These serve as templates so users know what config to create.
#    We only check phases that have a configs/ directory.
# ---------------------------------------------------------------------------
echo ""
echo "--- Config examples ---"

for phase in "${EXPECTED_PHASES[@]}"; do
    configs_dir="$phase/configs"
    if [[ -d "$configs_dir" ]]; then
        # Count .example files in this configs directory
        example_count=$(find "$configs_dir" -name "*.example" -type f 2>/dev/null | wc -l)
        if [[ $example_count -gt 0 ]]; then
            pass "$phase/configs/ has $example_count .example file(s)"
        else
            fail "$phase/configs/ exists but has no .example files"
        fi
    fi
    # If no configs/ directory, that's fine -- not all phases need one
done

# ---------------------------------------------------------------------------
# 7. README: Root README.md must exist
#    This is the first thing people see on GitHub.
# ---------------------------------------------------------------------------
echo ""
echo "--- README ---"

if [[ -f "README.md" ]]; then
    pass "README.md exists"
else
    fail "README.md missing from repo root"
fi

# ---------------------------------------------------------------------------
# 8. MERMAID BLOCKS: Each diagrams/*.md file should have mermaid code blocks
#    Diagram files without mermaid blocks are probably empty or broken.
# ---------------------------------------------------------------------------
echo ""
echo "--- Mermaid diagrams ---"

if [[ -d "diagrams" ]]; then
    for md_file in diagrams/*.md; do
        if [[ ! -f "$md_file" ]]; then
            continue
        fi
        # Look for ```mermaid fenced code blocks
        if grep -q '```mermaid' "$md_file" 2>/dev/null; then
            pass "$(basename "$md_file") contains mermaid block(s)"
        else
            fail "$(basename "$md_file") has no \`\`\`mermaid blocks"
        fi
    done
else
    warn "diagrams/ directory not found -- skipping mermaid check"
fi

# ---------------------------------------------------------------------------
# 9. INTERNAL LINKS: Check that markdown links to other repo files resolve
#    We look for links like [text](./path/to/file) and [text](path/to/file)
#    and verify the target file actually exists. External URLs (http/https)
#    are skipped.
# ---------------------------------------------------------------------------
echo ""
echo "--- Internal links ---"

BROKEN_LINKS=0

while IFS= read -r -d '' md_file; do
    # Extract markdown links: [text](target)
    # Skip URLs (http:// or https://) and anchors (#fragment)
    # grep -oP extracts just the link target from each match
    links=$(grep -oP '\[.*?\]\(\K[^)]+' "$md_file" 2>/dev/null || true)

    while IFS= read -r link; do
        # Skip empty lines, URLs, anchors, and mailto links
        [[ -z "$link" ]] && continue
        [[ "$link" =~ ^https?:// ]] && continue
        [[ "$link" =~ ^# ]] && continue
        [[ "$link" =~ ^mailto: ]] && continue

        # Strip any anchor fragment from the link (file.md#section -> file.md)
        link_path="${link%%#*}"
        [[ -z "$link_path" ]] && continue

        # Resolve relative to the directory containing the markdown file
        md_dir=$(dirname "$md_file")
        target="$md_dir/$link_path"

        if [[ ! -e "$target" ]]; then
            fail "Broken link in $(basename "$md_file"): $link (target: $target)"
            BROKEN_LINKS=$((BROKEN_LINKS + 1))
        fi
    done <<< "$links"
done < <(find . -name "*.md" -type f -not -path "./.git/*" -print0 2>/dev/null)

if [[ $BROKEN_LINKS -eq 0 ]]; then
    pass "All internal markdown links resolve"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "==========================================="
echo " PASSED: $PASSED"
echo " FAILED: $FAILED"
echo "==========================================="
echo ""

if [[ $FAILED -gt 0 ]]; then
    echo "[FAIL] $FAILED check(s) failed. Fix issues before pushing."
    exit 1
else
    echo "[OK]   All checks passed. Safe to push."
    exit 0
fi

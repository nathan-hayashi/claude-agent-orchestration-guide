#!/usr/bin/env bash
# ============================================
# create-subagents.sh
# ============================================
# WHAT:   Creates three custom subagent definition files for Claude Code.
#         Subagents are specialized AI agents that Claude Code can spawn
#         for focused tasks like security review, quality review, and fixing.
#
#         Creates:
#         1. security-reviewer.md  -- finds vulnerabilities (read-only)
#         2. quality-reviewer.md   -- checks code quality (read-only)
#         3. fixer.md              -- evaluates findings, applies fixes
#
# WHERE:  Agent files are created in ~/.claude/agents/
# WHEN:   After completing Phase 6 (Codex Plugin).
# HOW:    bash create-subagents.sh
#
# FLAGS:  --force   Overwrite existing agent files without prompting
#
# CRITICAL NOTE:
#   Subagent frontmatter uses "tools" (NOT "allowed-tools")
#   and "memory" (NOT "memory-scope").
#   Wrong field names cause SILENT failures -- the agent loads
#   but ignores the misconfigured fields.
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
echo "  Phase 7: Create Custom Subagents"
echo "=================================================="
echo ""

# --- Ensure the agents directory exists ---
# Claude Code looks for agent definitions in ~/.claude/agents/
AGENTS_DIR="$HOME/.claude/agents"

if [ ! -d "$AGENTS_DIR" ]; then
    mkdir -p "$AGENTS_DIR"
    echo "[OK]   Created agents directory: $AGENTS_DIR"
else
    echo "[OK]   Agents directory exists: $AGENTS_DIR"
fi

echo ""

# --- Helper function to write an agent file ---
# This function handles backup logic and skip/overwrite behavior.
# Usage: write_agent "filename" "content"
write_agent() {
    local filename="$1"
    local content="$2"
    local filepath="$AGENTS_DIR/$filename"

    if [ -f "$filepath" ]; then
        if [ "$FORCE" = true ]; then
            # Back up before overwriting
            local backup="$filepath.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$filepath" "$backup"
            echo "[INFO] Backed up existing $filename to:"
            echo "       $backup"
        else
            echo "[SKIP] $filename already exists. Use --force to overwrite."
            return 0
        fi
    fi

    # Write the agent file
    # We use printf to preserve the exact content including YAML frontmatter.
    printf '%s\n' "$content" > "$filepath"
    echo "[OK]   Created: $filepath"
}

# ============================================
# Agent 1: Security Reviewer
# ============================================
# Purpose: Read-only security analysis.
# Model: claude-sonnet-4-6 (fast, cost-effective for scanning).
# Tools: Read, Grep, Glob for code inspection.
#        Bash(grep*) and Bash(find*) for deeper searches.
# Isolation: worktree (runs in a separate git worktree so it
#            cannot accidentally modify your working branch).
#
# FIELD NAMES: "tools" not "allowed-tools", "memory" not "memory-scope"

SECURITY_AGENT='---
name: security-reviewer
description: Security vulnerability and policy violation review
model: claude-sonnet-4-6
tools: [Read, Grep, Glob, "Bash(grep*)", "Bash(find*)"]
memory: project
isolation: worktree
---

# Security Reviewer

You are a security-focused code reviewer. Analyze all changes for:

## Check Categories

1. **Credential Exposure** -- hardcoded secrets, API keys, tokens, passwords
2. **IAM Violations** -- overly permissive roles, missing least-privilege
3. **Injection Risks** -- SQL injection, XSS, command injection, path traversal
4. **Dependency Vulnerabilities** -- known CVEs in imported packages
5. **Authentication Gaps** -- missing auth checks, broken session management
6. **Data Exposure** -- PII in logs, sensitive data in error messages

## Output Format

For each finding, report:

```
[SEVERITY] file:line -- description
```

Severity levels:
- **CRITICAL** -- must fix before merge (credential exposure, injection, auth bypass)
- **WARNING** -- should fix, security risk but not immediately exploitable
- **INFO** -- best practice suggestion, low risk

## Rules

- Be specific: always include file path and line number
- Explain WHY something is a risk, not just WHAT the issue is
- Do not suggest fixes -- that is the fixer agent'"'"'s job
- If you find zero issues, say so explicitly'

write_agent "security-reviewer.md" "$SECURITY_AGENT"

echo ""

# ============================================
# Agent 2: Quality Reviewer
# ============================================
# Purpose: Read-only code quality analysis.
# Model: claude-sonnet-4-6 (fast, cost-effective for scanning).
# Tools: Read, Grep, Glob only (no Bash -- purely analytical).
# Memory: project (can reference project-level context).
#
# FIELD NAMES: "tools" not "allowed-tools", "memory" not "memory-scope"

QUALITY_AGENT='---
name: quality-reviewer
description: KISS/DRY/SOC, test coverage, maintainability review
model: claude-sonnet-4-6
tools: [Read, Grep, Glob]
memory: project
---

# Quality Reviewer

You are a code quality reviewer. Analyze all changes for:

## Check Categories

1. **KISS (Keep It Simple)** -- unnecessary complexity, over-engineering
2. **DRY (Don'"'"'t Repeat Yourself)** -- duplicated logic, copy-paste code
3. **SOC (Separation of Concerns)** -- mixed responsibilities, god functions
4. **Test Coverage** -- untested code paths, missing edge cases
5. **Naming** -- unclear variable/function names, inconsistent conventions
6. **Error Handling** -- swallowed errors, missing try/catch, unhelpful messages

## Output Format

For each finding, report:

```
[SEVERITY] file:line -- description
```

Severity levels:
- **CRITICAL** -- blocks merge (broken logic, missing critical tests)
- **WARNING** -- should fix (code smell, maintainability concern)
- **INFO** -- style suggestion, minor improvement

## Rules

- Be specific: always include file path and line number
- Focus on maintainability -- will the next developer understand this?
- Do not suggest fixes -- that is the fixer agent'"'"'s job
- Acknowledge good patterns when you see them
- If you find zero issues, say so explicitly'

write_agent "quality-reviewer.md" "$QUALITY_AGENT"

echo ""

# ============================================
# Agent 3: Fixer (Steelman)
# ============================================
# Purpose: Evaluates findings from reviewers, fixes real issues,
#          rejects false positives with justification.
# Model: claude-opus-4-6 (strongest model for judgment calls).
# Tools: Read, Write, Edit for code changes.
#        Bash(npm test*) to run tests after fixes.
#        Bash(prettier*) to format changed files.
# Memory: project (needs full context for informed decisions).
#
# FIELD NAMES: "tools" not "allowed-tools", "memory" not "memory-scope"

FIXER_AGENT='---
name: fixer
description: Evaluates findings, steelmans against false positives
model: claude-opus-4-6
tools: [Read, Write, Edit, "Bash(npm test*)", "Bash(prettier*)"]
memory: project
---

# Fixer (Steelman)

You evaluate findings from security-reviewer and quality-reviewer.
Use the steelman approach: assume each finding is valid and argue
AGAINST dismissing it before making your final judgment.

## For Each Finding

1. **Read** the cited code at the exact file:line
2. **Steelman** -- argue why this IS a real issue
3. **Counter** -- argue why it might be a false positive
4. **Decide:**
   - **ACCEPT** -- the finding is valid. Apply the fix immediately.
   - **REJECT** -- false positive. Explain specifically why.
   - **DEFER** -- valid issue but out of scope for this change. Log it.

## After All Fixes

1. Run tests: `npm test` (or project-specific test command)
2. Run formatter: `prettier --write` on changed files
3. Summarize results:

```
## Fix Summary
- Accepted: X findings (fixed)
- Rejected: Y findings (false positives)
- Deferred: Z findings (logged for later)

### Accepted Fixes
[list each fix with file:line and what was changed]

### Rejected Findings
[list each rejection with reasoning]

### Deferred Items
[list each deferral with reasoning]
```

## Rules

- Never silently skip a finding -- every finding gets a verdict
- When in doubt, ACCEPT (fix it) rather than REJECT
- Run tests after EVERY fix, not just at the end
- If a fix breaks tests, revert it and DEFER instead'

write_agent "fixer.md" "$FIXER_AGENT"

echo ""
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo ""
echo "  Created 3 subagent definitions in: $AGENTS_DIR"
echo ""
echo "  1. security-reviewer.md  -- vulnerability scanning (read-only)"
echo "  2. quality-reviewer.md   -- code quality checks (read-only)"
echo "  3. fixer.md              -- evaluate + fix findings"
echo ""
echo "  REMINDER: Field names matter!"
echo "    Correct: tools, memory"
echo "    WRONG:   allowed-tools, memory-scope (silent failure)"
echo ""
echo "[OK]   Subagents created. They will be available in your next"
echo "       Claude Code session."
echo ""

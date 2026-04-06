#!/usr/bin/env bash
# =============================================================================
# create-rules.sh -- Create file-pattern rules for Claude Code
# =============================================================================
# PURPOSE:  Creates 4 rule files in ~/.claude/rules/ that automatically activate
#           when Claude Code edits files matching specific patterns.
#
# USAGE:    ./create-rules.sh
#           ./create-rules.sh --force   # overwrite without asking
#
# RULES CREATED:
#   terraform.md   -- Activates on .tf and .tfvars files
#   security.md    -- Activates on IAM, policy, auth, and .env files
#   docker.md      -- Activates on Dockerfiles and docker-compose files
#   powershell.md  -- Activates on .ps1 and .psm1 files
#
# HOW RULES WORK:
#   Each rule file has a YAML frontmatter block with a "paths" field.
#   When Claude Code opens or edits a file matching one of those paths,
#   the rule's instructions automatically apply. You don't need to
#   reference the rule -- it's automatic.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/platform-detect.sh"

FORCE="false"
[[ "${1:-}" == "--force" ]] && FORCE="true"

RULES_DIR="$HOME/.claude/rules"

echo ""
echo "===== Create Claude Code Rules ====="
echo "[INFO] Target directory: $RULES_DIR"
echo ""

# --- Ensure directory exists ---
mkdir -p "$RULES_DIR"

# --- Helper: write a rule file with backup ---
write_rule() {
    local FILENAME="$1"
    local CONTENT="$2"
    local TARGET="$RULES_DIR/$FILENAME"

    if [[ -f "$TARGET" ]]; then
        if [[ "$FORCE" != "true" ]]; then
            echo "[SKIP] $FILENAME already exists. Use --force to overwrite."
            return
        fi
        # Backup existing file
        cp "$TARGET" "${TARGET}.bak.$(date '+%Y%m%d')"
        echo "[INFO] Backed up $FILENAME"
    fi

    echo "$CONTENT" > "$TARGET"
    echo "[OK]   Created $TARGET"
}

# --- Rule 1: Terraform ---
# Activates when Claude edits any .tf or .tfvars file anywhere in the project.
write_rule "terraform.md" '---
paths: ["**/*.tf", "**/*.tfvars"]
---

# Terraform Rules

When editing Terraform files, follow these practices:

## Formatting and Validation
- Run `terraform fmt` before committing any .tf file changes
- Run `terraform validate` to catch syntax errors early
- Use consistent indentation (2 spaces)

## Security
- NEVER use wildcard (*) in IAM policy actions or resources
- Always specify the minimum required permissions
- Use data sources to reference existing resources instead of hardcoding ARNs

## Versioning
- Pin all provider versions with exact version constraints
  Example: `required_providers { aws = { version = "= 5.31.0" } }`
- Pin all module versions when using registry modules

## Tagging
- Every resource that supports tags MUST include at minimum:
  - `Environment` (dev, staging, prod)
  - `ManagedBy` (terraform)
  - `Project` (the project name)

## State
- Never modify .tfstate files manually
- Use remote state backends (S3, Azure Blob, etc.)
- Enable state locking'

# --- Rule 2: Security ---
# Activates when Claude touches IAM configs, auth files, or .env files.
write_rule "security.md" '---
paths: ["**/iam/**", "**/policy/**", "**/auth/**", "**/*.env*"]
---

# Security Rules

When editing security-sensitive files, follow these practices:

## Principle of Least Privilege
- Grant only the minimum permissions needed for the task
- Never use admin or wildcard permissions unless explicitly approved
- Scope permissions to specific resources, not entire accounts

## Documentation
- Document every permission grant with a comment explaining WHY it is needed
- Include the date and ticket/issue number for audit trails
- Example: `# JIRA-1234: Lambda needs S3 read for config files (2024-01-15)`

## Secrets
- NEVER hardcode secrets, API keys, passwords, or tokens in any file
- Use environment variables, AWS Secrets Manager, or HashiCorp Vault
- If you find a hardcoded secret, flag it immediately as [FAIL]

## Escalation
- Any change to IAM policies, auth flows, or security groups is T2+ complexity
- Request human review before applying security changes to production
- When in doubt, escalate rather than proceed

## .env Files
- Never commit .env files to git (ensure .gitignore has .env*)
- Use .env.example with placeholder values for documentation
- Rotate any secret that was accidentally committed'

# --- Rule 3: Docker ---
# Activates when Claude edits Dockerfiles or docker-compose files.
write_rule "docker.md" '---
paths: ["**/Dockerfile*", "**/docker-compose*"]
---

# Docker Rules

When editing Docker files, follow these practices:

## Base Images
- Always pin image versions with specific tags (never use `latest`)
  Good: `FROM node:20.11-alpine3.19`
  Bad:  `FROM node:latest`
- Prefer Alpine-based images for smaller attack surface
- Use official images from Docker Hub when available

## Multi-Stage Builds
- Use multi-stage builds to keep final images small
- Build dependencies in a builder stage, copy only artifacts to final stage
- Example pattern: builder stage -> test stage -> production stage

## Health Checks
- Every service container MUST have a HEALTHCHECK instruction
  Example: `HEALTHCHECK --interval=30s CMD curl -f http://localhost:3000/health || exit 1`
- Set appropriate interval, timeout, and retries

## Security
- Never run containers as root (use `USER nonroot` or similar)
- Do not store secrets in Dockerfiles or docker-compose files
- Use .dockerignore to exclude .env, .git, node_modules, etc.

## Compose
- Pin all image versions in docker-compose files
- Use named volumes for persistent data
- Set resource limits (memory, CPU) for each service
- Use networks to isolate services that do not need to communicate'

# --- Rule 4: PowerShell ---
# Activates when Claude edits .ps1 or .psm1 files.
write_rule "powershell.md" '---
paths: ["**/*.ps1", "**/*.psm1"]
---

# PowerShell Rules

When editing PowerShell scripts, follow these practices:

## Naming
- Use approved PowerShell verbs (Get, Set, New, Remove, etc.)
  Run `Get-Verb` to see the full list of approved verbs
- Use PascalCase for function names: Get-UserReport, not get_user_report
- Use PascalCase for parameter names

## Function Structure
- Every function MUST include a help block (comment-based help):
  ```powershell
  <#
  .SYNOPSIS
      Brief description of what the function does.
  .DESCRIPTION
      Detailed description.
  .PARAMETER Name
      Description of each parameter.
  .EXAMPLE
      Example usage.
  #>
  ```
- Every function MUST use `[CmdletBinding()]` attribute
- Every function MUST use `param()` block for parameters

## Error Handling
- Wrap risky operations in try/catch blocks
- Use `-ErrorAction Stop` when errors should halt execution
- Log errors with Write-Error, not Write-Host
- Use `$ErrorActionPreference = "Stop"` at script level for strict mode

## Output
- Use Write-Verbose for debug/informational output (not Write-Host)
- Use Write-Output for pipeline-compatible output
- Return structured objects, not formatted strings'

# --- Summary ---
echo ""
echo "========================================="
echo " Rules Summary"
echo "========================================="
echo ""
ls -la "$RULES_DIR"/*.md 2>/dev/null || echo "  (no rule files found)"
echo ""
echo "[INFO] Rules activate automatically when Claude edits matching files."
echo "[INFO] No additional configuration needed."
echo ""
echo "[OK]   Rules creation complete."

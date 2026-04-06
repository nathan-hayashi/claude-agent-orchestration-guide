#!/usr/bin/env bash
# ============================================
# create-custom-skills.sh
# ============================================
# WHAT:   Creates example custom skill definitions for Claude Code.
#         Skills are reusable prompt modules that teach specialized workflows.
#
#         Creates:
#         1. architecture-review/SKILL.md  -- deep codebase architecture analysis
#         2. terraform-iac/SKILL.md        -- Terraform best practices review
#
#         Also checks for and optionally installs test runners:
#         - Vitest 4.1.2 (JavaScript/TypeScript testing)
#         - pytest 9.0.2 (Python testing)
#
# WHERE:  Skill files are created in ~/.claude/skills/
# WHEN:   After completing Phase 7 (Custom Subagents).
# HOW:    bash create-custom-skills.sh
#
# FLAGS:  --force   Overwrite existing skill files without prompting
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
echo "  Phase 8: Create Custom Skills Library"
echo "=================================================="
echo ""

# --- Ensure the skills directory exists ---
SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
    mkdir -p "$SKILLS_DIR"
    echo "[OK]   Created skills directory: $SKILLS_DIR"
else
    echo "[OK]   Skills directory exists: $SKILLS_DIR"
fi

echo ""

# --- Helper function to write a skill file ---
# Usage: write_skill "skill-name" "content"
write_skill() {
    local skill_name="$1"
    local content="$2"
    local skill_dir="$SKILLS_DIR/$skill_name"
    local skill_file="$skill_dir/SKILL.md"

    # Create the skill directory
    if [ ! -d "$skill_dir" ]; then
        mkdir -p "$skill_dir"
    fi

    # Check for existing file
    if [ -f "$skill_file" ]; then
        if [ "$FORCE" = true ]; then
            local backup="$skill_file.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$skill_file" "$backup"
            echo "[INFO] Backed up existing $skill_name/SKILL.md"
        else
            echo "[SKIP] $skill_name/SKILL.md already exists. Use --force to overwrite."
            return 0
        fi
    fi

    # Write the skill file
    printf '%s\n' "$content" > "$skill_file"
    echo "[OK]   Created: $skill_file"
}

# ============================================
# Skill 1: Architecture Review
# ============================================
# Uses "context: fork" which means it reads the ENTIRE codebase.
# This is expensive but necessary for architecture-level analysis.
# Use sparingly -- not for every commit.

ARCH_SKILL='---
name: architecture-review
description: Deep architecture analysis of the entire codebase
context: fork
---

# Architecture Review

Perform a comprehensive architecture review of this codebase.

## Analysis Steps

1. **Dependency Graph**
   - Map all module/package dependencies
   - Identify circular dependencies
   - Flag tightly coupled components

2. **Layering Analysis**
   - Verify separation of concerns across layers
   - Check that lower layers do not import from higher layers
   - Identify layer-skipping calls (e.g., UI directly accessing DB)

3. **Module Boundaries**
   - Assess cohesion within each module
   - Check coupling between modules
   - Identify god modules (too many responsibilities)

4. **Data Flow**
   - Trace how data moves through the system
   - Identify unnecessary data transformations
   - Check for data duplication across modules

5. **Scalability Concerns**
   - Identify bottlenecks in the current architecture
   - Check for stateful components that block horizontal scaling
   - Review caching strategy

## Output Format

```
## Architecture Review Summary

### Health Score: X/10

### Critical Issues
[CRITICAL] description -- affected files/modules

### Warnings
[WARNING] description -- affected files/modules

### Recommendations
[INFO] description -- suggested improvement

### Dependency Graph
(text-based visualization of key dependencies)
```

## Rules

- Read the entire codebase before forming opinions
- Compare against the stated architecture in README or docs
- Be specific: reference actual file paths and module names
- Prioritize findings by impact on maintainability'

write_skill "architecture-review" "$ARCH_SKILL"

echo ""

# ============================================
# Skill 2: Terraform IaC
# ============================================
# Uses "paths: **/*.tf" to scope analysis to Terraform files only.
# Much cheaper than a fork-context skill.

TF_SKILL='---
name: terraform-iac
description: Terraform infrastructure-as-code best practices review
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tfvars.json"
---

# Terraform IaC Review

Review Terraform configurations for best practices and security.

## Analysis Steps

1. **Module Structure**
   - Verify modules are properly decomposed
   - Check for monolithic main.tf files
   - Ensure outputs are documented

2. **State Management**
   - Verify remote backend configuration
   - Check state locking is enabled
   - Look for local state files that should not be committed

3. **Provider Configuration**
   - Ensure provider versions are pinned (not using >= or ~>)
   - Check for required_providers block
   - Verify terraform version constraint

4. **Security**
   - Review security group rules (no 0.0.0.0/0 on sensitive ports)
   - Check IAM policies for least privilege
   - Ensure encryption is enabled (S3, RDS, EBS, etc.)
   - Look for hardcoded secrets in .tf or .tfvars files

5. **Naming and Tagging**
   - Verify consistent naming convention
   - Check for required tags (environment, owner, cost-center)
   - Ensure descriptions on all variables and outputs

6. **Plan Safety**
   - Identify resources that would be destroyed on apply
   - Check for prevent_destroy lifecycle rules on critical resources
   - Review create_before_destroy settings

## Output Format

```
## Terraform Review Summary

### Findings
[SEVERITY] resource.name -- description

### Security
[list security-specific findings]

### Best Practices
[list non-security improvements]

### Drift Risk
[resources at risk of unintended changes]
```

## Rules

- Check ALL .tf files, not just main.tf
- Cross-reference variable defaults with .tfvars values
- Flag any resource without tags
- Always check for hardcoded credentials'

write_skill "terraform-iac" "$TF_SKILL"

echo ""

# ============================================
# Install test runners (if not present)
# ============================================
# Skills often need to run tests. Check for common test runners
# and offer to install them.

echo "=================================================="
echo "  Checking Test Runners"
echo "=================================================="
echo ""

# Check for Vitest (JavaScript/TypeScript)
if command -v npx &>/dev/null; then
    # Check if vitest is available in the project or globally
    if npx vitest --version &>/dev/null 2>&1; then
        VITEST_VERSION=$(npx vitest --version 2>/dev/null || echo "unknown")
        echo "[OK]   Vitest is available (version: $VITEST_VERSION)"
    else
        echo "[INFO] Vitest is not installed."
        echo "       To install (recommended for JS/TS projects):"
        echo "       npm install --save-dev vitest@4.1.2"
    fi
else
    echo "[SKIP] npx not found. Skipping Vitest check."
fi

# Check for pytest (Python)
if command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
    if command -v pytest &>/dev/null; then
        PYTEST_VERSION=$(pytest --version 2>/dev/null | head -1 || echo "unknown")
        echo "[OK]   pytest is available ($PYTEST_VERSION)"
    else
        echo "[INFO] pytest is not installed."
        echo "       To install (recommended for Python projects):"
        echo "       pip install pytest==9.0.2"
    fi
else
    echo "[SKIP] pip not found. Skipping pytest check."
fi

echo ""
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo ""
echo "  Created 2 example skills in: $SKILLS_DIR"
echo ""
echo "  1. architecture-review/SKILL.md  -- context: fork (full codebase)"
echo "  2. terraform-iac/SKILL.md        -- paths: **/*.tf (scoped)"
echo ""
echo "  To create more skills:"
echo "    mkdir -p $SKILLS_DIR/my-skill"
echo "    Edit $SKILLS_DIR/my-skill/SKILL.md"
echo ""
echo "[OK]   Skills library initialized."
echo ""

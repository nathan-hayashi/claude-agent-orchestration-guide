# Phase 8: Workload-Specific Skills Library

**Estimated time:** 1 -- 2 hours

## What Are Custom Skills?

Skills are reusable prompt modules that teach Claude Code specialized workflows.
Each skill is a markdown file (`SKILL.md`) in a named directory under
`~/.claude/skills/`. When invoked, the skill's instructions override default
behavior for that task.

The orchestration guide targets **64 total skills** across all workload categories
(security, infrastructure, testing, architecture, etc.). This phase creates two
foundational examples you can use as templates.

## Skill Architecture

Each skill lives in its own directory:

```
~/.claude/skills/
  architecture-review/
    SKILL.md          <-- skill definition
  terraform-iac/
    SKILL.md          <-- skill definition
  your-custom-skill/
    SKILL.md          <-- skill definition
```

## Key Skill Properties

Skills can be scoped in two ways:

| Property | Example | What It Does |
|----------|---------|--------------|
| `context: fork` | architecture-review | Reads the entire codebase for broad analysis |
| `paths: **/*.tf` | terraform-iac | Limits scope to matching files only |

The `context: fork` pattern is expensive (reads everything) but necessary for
architecture-level analysis. Use path-scoped skills for file-type-specific tasks.

## Example Skills

### architecture-review

- **Context:** fork (reads entire codebase)
- **Purpose:** Deep architecture analysis -- dependency graphs, coupling,
  layering violations, circular imports
- **When to use:** Before major refactors, during design reviews, quarterly
  health checks

### terraform-iac

- **Context:** path-scoped to `**/*.tf` files
- **Purpose:** Terraform best practices -- module structure, state management,
  provider pinning, security group rules
- **When to use:** Before applying Terraform changes, during IaC reviews

## Scripts

| Script | What It Does |
|--------|--------------|
| `create-custom-skills.sh` | Creates example skill files and installs test runners |

## Config Files

| File | What It Is |
|------|------------|
| `configs/skills/architecture-review-SKILL.md.example` | Architecture review skill template |
| `configs/skills/terraform-iac-SKILL.md.example` | Terraform IaC skill template |

## Creating Your Own Skills

1. Create a directory: `mkdir -p ~/.claude/skills/my-skill/`
2. Write `SKILL.md` with frontmatter and instructions
3. Invoke in Claude Code: `/my-skill` or reference in natural language

### Minimal SKILL.md Template

```markdown
---
name: my-skill
description: One-line summary of what this skill does
---

# My Skill

Instructions for Claude Code when this skill is invoked.
Be specific about inputs, outputs, and success criteria.
```

## Next Phase

Proceed to [Phase 9: Auto Mode + Security Guardrails](../phase-09-auto-mode/).

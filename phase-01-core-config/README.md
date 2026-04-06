# Phase 1: Core Configuration

**Time estimate:** 1 - 2 hours
**Gate:** Phase 0 must be complete (all pre-flight checks passing).

## What this phase does

Phase 1 sets up the CLAUDE.md configuration files that control how Claude Code
behaves. Think of CLAUDE.md as the "personality and rules" file for Claude Code.

## CLAUDE.md hierarchy

Claude Code reads instructions from up to three levels of CLAUDE.md files.
Higher levels override lower ones:

```
~/.claude/CLAUDE.md              <-- Global: applies to ALL your projects
  |
  +-- ~/projects/myapp/CLAUDE.md <-- Project: checked into the repo, shared
  |                                    with your team
  +-- ~/projects/myapp/CLAUDE.local.md  <-- Local: personal overrides, gitignored
```

**Global** (`~/.claude/CLAUDE.md`):
Your defaults -- coding standards, verification rules, communication style.
Every project inherits these unless the project overrides them.

**Project** (`CLAUDE.md` at project root):
Project-specific rules checked into git. Your whole team sees these.
Contains build commands, architecture notes, tech stack details.

**Local** (`CLAUDE.local.md` at project root):
Your personal overrides. Gitignored. Use this for preferences that
only you need (e.g., editor shortcuts, debug flags).

## Rules files

In addition to CLAUDE.md, Claude Code supports file-pattern rules in
`~/.claude/rules/`. These activate automatically when Claude touches files
matching the specified patterns.

For example, `~/.claude/rules/terraform.md` activates whenever Claude edits
a `.tf` or `.tfvars` file, automatically applying Terraform best practices.

## Scripts

| #  | Script              | What it does                                       |
|----|---------------------|----------------------------------------------------|
| 1  | `create-claude-md.sh` | Creates your global CLAUDE.md                    |
| 2  | `create-rules.sh`    | Creates 4 file-pattern rules                      |
| 3  | `setup-memory.sh`    | Explains auto-memory and creates rules symlink     |

## Config files

- `global-CLAUDE.md.example` -- full global template with comments
- `project-CLAUDE.md.example` -- project-specific template
- `CLAUDE.local.md.example` -- personal overrides template
- `rules/*.md.example` -- rule file templates for Terraform, security, Docker, PowerShell

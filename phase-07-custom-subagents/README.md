# Phase 7: Custom Subagents

**Estimated time:** 1 -- 2 hours

## What Are Subagents?

Subagents are specialized AI agents that Claude Code can spawn for focused tasks.
Each subagent has its own model, tool permissions, and system prompt. They run in
isolation, do their job, and report back.

This phase creates three subagents:

| Agent | Model | Purpose |
|-------|-------|---------|
| `security-reviewer` | claude-sonnet-4-6 | Find vulnerabilities and policy violations |
| `quality-reviewer` | claude-sonnet-4-6 | Check KISS/DRY/SOC, test coverage, naming |
| `fixer` | claude-opus-4-6 | Evaluate findings, fix real issues, reject false positives |

## CRITICAL: Correct Field Names

Subagent frontmatter uses specific field names. **Wrong field names cause SILENT
failures** -- the agent will load but ignore the misconfigured fields.

### Appendix E: Frontmatter Field Reference

| Correct Field | WRONG (Silent Fail) | What It Does |
|---------------|---------------------|--------------|
| `tools` | ~~allowed-tools~~ | List of tools the agent can use |
| `memory` | ~~memory-scope~~ | Where the agent stores/reads context |
| `model` | (no common error) | Which AI model to use |
| `isolation` | (no common error) | Run in a separate git worktree |
| `description` | (no common error) | One-line summary for agent selection |
| `name` | (no common error) | Agent identifier |

If you use `allowed-tools` instead of `tools`, the agent will have NO tool access
and will silently fail every operation. This is the single most common subagent
configuration mistake.

## Model Resolution Chain

When Claude Code selects a model for a subagent, it follows this priority:

1. `model` field in the agent's frontmatter (highest priority)
2. `CLAUDE_MODEL` environment variable
3. Default model from Claude Code settings
4. Fallback to `claude-sonnet-4-6`

## Scripts

| Script | What It Does |
|--------|--------------|
| `create-subagents.sh` | Creates all 3 agent definition files |

## Config Files

| File | What It Is |
|------|------------|
| `configs/agents/security-reviewer.md.example` | Security reviewer agent template |
| `configs/agents/quality-reviewer.md.example` | Quality reviewer agent template |
| `configs/agents/fixer.md.example` | Fixer (steelman) agent template |

## How They Work Together

```
Your code change
    |
    v
security-reviewer  <-- finds vulnerabilities (read-only)
    |
quality-reviewer   <-- finds code quality issues (read-only)
    |
    v
fixer              <-- evaluates ALL findings, fixes real issues,
                       rejects false positives, runs tests
```

The fixer uses a "steelman" approach: it assumes findings are valid and
argues against dismissing them, then makes a final call:
- **ACCEPT** -- fix the issue
- **REJECT** -- false positive, explain why
- **DEFER** -- valid issue but out of scope for this change

## Next Phase

Proceed to [Phase 8: Skills Library](../phase-08-skills-library/).

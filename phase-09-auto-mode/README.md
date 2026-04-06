# Phase 9: Auto Mode + Security Guardrails

**Estimated time:** 30 -- 60 minutes

## What Is Auto Mode?

Auto mode allows Claude Code to execute multi-step workflows without asking for
confirmation at each step. Instead of pausing to ask "should I run this command?",
Claude Code proceeds autonomously.

This is powerful but dangerous. Auto mode is **defense-in-depth** -- it relies on
multiple safety layers working together.

## Prerequisites

**Phase 9 depends on three earlier phases, not just Phase 3:**

| Phase | What It Provides | Why Auto Mode Needs It |
|-------|-----------------|----------------------|
| Phase 2: Hooks | PreToolUse hooks | Block dangerous commands BEFORE execution |
| Phase 7: Subagents | Review agents | Catch issues that hooks cannot detect |
| Phase 8: Skills | Workflow skills | Structured task execution reduces errors |

Do NOT enable auto mode without all three in place.

## Defense-in-Depth Layers

Auto mode safety comes from stacking multiple independent protections:

```
Layer 1: PreToolUse Hooks (Phase 2)
  Block rm -rf, force push, secret exposure, etc.
  These fire BEFORE any tool runs, even in auto mode.

Layer 2: Tool Permissions (settings.json)
  autoMode.environment restricts which tools auto mode can use.
  Must be an array of strings, e.g. ["Read", "Grep", "Glob"]

Layer 3: Subagent Review (Phase 7)
  Security and quality reviewers check changes after the fact.
  Fixer agent evaluates and corrects issues.

Layer 4: Skills Guardrails (Phase 8)
  Structured workflows with built-in safety checks.
  Skills define what IS allowed, not just what is blocked.
```

## autoMode.environment

The `autoMode.environment` field in `settings.json` controls which tools Claude
Code can use without human confirmation. It must be an **array of strings**:

```json
{
  "autoMode": {
    "environment": ["Read", "Grep", "Glob", "Bash(npm test*)"]
  }
}
```

**Common mistake:** Setting `environment` to a single string instead of an array
causes a silent configuration error.

## Scripts

| Script | What It Does |
|--------|--------------|
| `enable-auto-mode.sh` | Validates prerequisites, confirms auto mode config |

## Config Files

| File | What It Is |
|------|------------|
| `configs/auto-mode-settings.json.example` | Example autoMode settings section |

## Next Phase

Proceed to [Phase 10: Integration Testing](../phase-10-integration-testing/).

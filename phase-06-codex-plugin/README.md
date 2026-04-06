# Phase 6: Codex Plugin

**Estimated time:** 30 -- 45 minutes

## What Is Codex?

Codex is OpenAI's CLI agent. When used as a Claude Code plugin, it provides
**cross-model code review** -- your code gets a second opinion from a different
AI model (OpenAI's), catching blind spots that Claude alone might miss.

## Installation

1. Install the Codex CLI globally via npm
2. Login to OpenAI (note: it is `codex login`, NOT `codex auth login`)
3. Install the Claude Code plugin from the marketplace
4. Run the Codex setup wizard

## CRITICAL WARNING: Review Gate

The Codex plugin includes an optional "review gate" feature. **Do NOT enable
the review gate.** When enabled, it auto-triggers a Codex review after EVERY
Claude Code response, creating an expensive infinite feedback loop:

```
Claude responds --> Codex reviews --> Claude responds to review -->
Codex reviews again --> ...repeat until token budget exhausted
```

This can burn through significant API credits in minutes. The setup wizard
will ask about this -- decline it.

## Scripts

| Script | What It Does |
|--------|--------------|
| `install-codex.sh` | Installs Codex CLI, logs in, adds plugin |

## Config Files

No separate config files needed. The Codex plugin is configured through its
built-in setup wizard (`/codex:setup`).

## Next Phase

Proceed to [Phase 7: Custom Subagents](../phase-07-custom-subagents/).

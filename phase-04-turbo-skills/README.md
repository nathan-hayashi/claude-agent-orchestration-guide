# Phase 4: Turbo Skills + MCP Servers

**Estimated time:** 1 -- 2 hours

## What Is Turbo?

Turbo is a **composable developer-workflow skills system** for Claude Code. It is
**NOT** related to Turborepo (the Vercel monorepo tool). Turbo gives Claude Code
reusable "skills" -- small prompt modules that teach the agent new capabilities
and standardize common workflows.

Key Turbo skills you will use:

| Skill | Purpose |
|-------|---------|
| `/finalize` | Post-implementation quality checks (lint, test, type-check) |
| `/review-code` | Full code review pipeline (security + quality + test coverage) |
| `/peer-review-code` | Independent second-opinion review via external model |
| `/consult-oracle` | Cross-model consultation (ChatGPT, Codex, etc.) |
| `/self-improve` | Extract lessons from the current session into reusable rules |

## What Are MCP Servers?

MCP (Model Context Protocol) servers extend Claude Code with external tool
integrations. This phase installs two:

1. **sequential-thinking** -- gives Claude a structured "thinking aloud" tool for
   multi-step reasoning problems
2. **github** -- allows Claude to interact with GitHub directly (create PRs,
   read issues, search code) via the GitHub API

## Scripts

| Script | What It Does |
|--------|--------------|
| `install-turbo.sh` | Clones the Turbo repo and guides you through installation |
| `setup-mcp-servers.sh` | Creates `.mcp.json` config with MCP server definitions |

## Config Files

| File | What It Is |
|------|------------|
| `configs/.mcp.json.example` | Example MCP server configuration |

## Known Issues

- **Error #11:** Turbo's guided wizard may write to your global `~/.claude/CLAUDE.md`.
  Review the file afterward and revert any unwanted changes.
- **Error #12:** The `/plugin add` command may open a browser window. This is expected
  on first install for OAuth approval. Close the browser tab when finished.
- Turbo's 7-step wizard is interactive. Follow the prompts; do not skip steps.

## Compatibility

Tested with Claude Code v2.1.92+. Older versions may not support the `/plugin`
command or MCP server configuration format.

## Next Phase

Proceed to [Phase 5: Open Code Review](../phase-05-open-code-review/).

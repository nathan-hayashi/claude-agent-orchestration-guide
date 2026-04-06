# Exercise 4: Fetch Skills -- Turbo, MCP, and Plugins

**Phases covered:** 4, 5, and 6
**Time estimate:** 20 to 25 minutes
**Goal:** Use Turbo skills, MCP servers, and plugins to extend Claude Code's capabilities.

---

## Background

Out of the box, Claude Code can read files, write files, and run terminal commands. Turbo skills, MCP servers, and plugins add specialized capabilities:

- **Turbo skills** -- reusable workflows (like `/finalize` for post-implementation cleanup)
- **MCP servers** -- external tool integrations (like GitHub for issue management)
- **Plugins** -- advanced analysis tools (like OCR for multi-agent code review)

## Prerequisite

Complete Phases 4 through 6 of the main guide. Specifically:

- Turbo skills installed (Phase 4)
- MCP servers configured in `.mcp.json` (Phase 5)
- OCR plugin installed, if desired (Phase 6)

## Exercise 1: Use the Finalize Skill

Make a small change to your pet data. Open a Claude Code session:

```bash
cd ~/projects/pet-shelter
claude
```

Ask Claude:

```
Change Buddy's status from available to adopted in pets.json
```

After Claude makes the change, run the finalize skill:

```
/finalize
```

**What to look for:**

- The finalize skill runs a post-implementation pipeline
- It checks code quality and simplification opportunities
- It reviews the changes for correctness
- It creates a properly formatted commit

This is the Turbo skill workflow in action: a multi-step quality process triggered by a single command.

## Exercise 2: Use the GitHub MCP Server

For this exercise, you need:

1. The GitHub MCP server configured in `.mcp.json`
2. Your pet-shelter project pushed to a GitHub repository

If you have not pushed to GitHub yet:

```bash
gh repo create pet-shelter --private --source=. --push
```

Now ask Claude:

```
Create a GitHub issue titled "Add vaccination tracking" with the description "Track vaccination records for each pet including vaccine name, date administered, and next due date."
```

**What to look for:**

- Claude uses the GitHub MCP server (not the `gh` CLI) to create the issue
- The issue appears on your GitHub repository with the correct title and description
- You can verify by visiting your repo's Issues tab or running `gh issue list`

This demonstrates how MCP servers give Claude Code direct access to external services without needing you to provide CLI commands.

## Exercise 3: OCR Health Check (Optional)

If you installed the OCR plugin in Phase 6, verify it is working:

Ask Claude:

```
Run OCR doctor check
```

**What to look for:**

- The OCR doctor runs a health check on your installation
- It verifies all dependencies are present and configured
- It reports the status of each component (reviewers, configuration, etc.)

If you did not install OCR, skip this exercise. It is not required for the remaining tutorials.

## How These Extensions Work Together

The power of the orchestration system comes from combining these tools:

1. You ask Claude to make a complex change
2. The **threshold router** (Phase 3) classifies the complexity
3. Claude implements the change using its built-in tools
4. **Hooks** (Phase 2) auto-format the code and enforce security
5. **MCP servers** (Phase 5) let Claude interact with GitHub, databases, or other services
6. **Turbo skills** like `/finalize` run multi-step quality pipelines
7. **Plugins** like OCR provide deep analysis when needed

Each layer adds capability without requiring you to manually coordinate.

## Key Takeaway

Plugins and MCP servers extend Claude Code's capabilities beyond file editing and terminal commands. Turbo skills package multi-step workflows into single commands. Together, they turn Claude Code from a code editor into a development operations platform.

---

**Next:** [Exercise 5: Breed the Agents](05-breed-the-agents.md)

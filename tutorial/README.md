# Interactive Tutorial: PetShelter Project

A hands-on practice environment for the Claude Code Agent Orchestration Guide. Each exercise maps to specific phases from the main guide, letting you practice the concepts with a fictional pet shelter data project.

## Prerequisites

- **Phase 0** (Preflight) and **Phase 1** (Core Config) from the main guide must be completed
- A Claude Max subscription
- Claude Code installed and working (`claude --version` returns a version number)
- Basic terminal familiarity (cd, ls, cat, mkdir, git init/add/commit)
- A GitHub account with at least 1 year of experience

## Time Estimate

2 to 3 hours total, working through all 7 exercises.

## How to Use

Follow the exercises in order from 01 through 07. Each exercise builds on the previous one:

| Exercise | Phase(s) | Topic |
|----------|----------|-------|
| [01-hello-pets](01-hello-pets.md) | 0 and 1 | Your first Claude Code project and CLAUDE.md |
| [02-guard-the-kennel](02-guard-the-kennel.md) | 2 | Hooks and security enforcement |
| [03-sort-the-litter](03-sort-the-litter.md) | 3 | Threshold router and task classification |
| [04-fetch-skills](04-fetch-skills.md) | 4 to 6 | Turbo skills, MCP servers, and plugins |
| [05-breed-the-agents](05-breed-the-agents.md) | 7 and 8 | Custom subagents and multi-perspective review |
| [06-auto-walkies](06-auto-walkies.md) | 9 | Autonomous mode with guardrails |
| [07-vet-checkup](07-vet-checkup.md) | 10 | Integration testing and validation |

## What You Will Learn

By the end of this tutorial, you will be able to:

- Configure Claude Code with a project-specific CLAUDE.md
- Set up security hooks that block dangerous commands and protect secrets
- Use the threshold router to automatically scale review intensity
- Install and use plugins and MCP servers to extend Claude Code
- Create subagents that provide automated multi-perspective code review
- Enable autonomous mode while maintaining safety guardrails
- Run integration tests to verify your entire orchestration system

## Starter Files

The `assets/sample-project/` directory contains a ready-to-use starter project. Copy it to begin:

```bash
cp -r tutorial/assets/sample-project ~/projects/pet-shelter
cd ~/projects/pet-shelter
git init
git add -A
git commit -m "chore: initialize pet shelter project"
```

## Troubleshooting

If an exercise does not behave as described:

1. Re-read the corresponding phase in the main guide
2. Verify the prerequisite phases are fully configured
3. Check that your Claude Code version is current: `claude update`
4. Review the integration test results from Exercise 07 for specific failures

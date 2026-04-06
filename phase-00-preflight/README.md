# Phase 0: Pre-Flight Checks

**Time estimate:** 30 minutes
**Gate:** You MUST complete all Phase 0 checks before starting Phase 1.

## What is a pre-flight check?

Just like a pilot runs through a checklist before takeoff, we verify that your
machine has everything Claude Code needs before we start configuring it. Skipping
this phase leads to confusing errors later.

Pre-flight checks cover two stages:

1. **Pre-install** -- tools you need before installing Claude Code (Node.js, npm, git)
2. **Post-install** -- verifying Claude Code itself plus supporting tools (Prettier, auth)

## Scripts (run in this order)

| #  | Script                  | What it does                                         |
|----|-------------------------|------------------------------------------------------|
| 1  | `preflight-check.sh`    | Two-stage verification of all prerequisites          |
| 2  | `install-claude-code.sh`| Installs Claude Code via the official installer      |
| 3  | `setup-git-config.sh`   | Sets recommended git global settings                 |
| 4  | `setup-wsl-memory.sh`   | (WSL only) Configures memory limits for WSL 2        |
| 5  | `setup-notifications.sh`| Sets up desktop notifications for your platform      |
| 6  | `setup-directories.sh`  | Creates standard working directories                 |
| 7  | `setup-shell-env.sh`    | Installs Prettier, sets environment variables         |

## How to run

```bash
# Make all scripts executable first
chmod +x phase-00-preflight/*.sh

# Then run each one in order
./phase-00-preflight/preflight-check.sh --pre
./phase-00-preflight/install-claude-code.sh
./phase-00-preflight/preflight-check.sh --post
./phase-00-preflight/setup-git-config.sh
./phase-00-preflight/setup-wsl-memory.sh
./phase-00-preflight/setup-notifications.sh
./phase-00-preflight/setup-directories.sh
./phase-00-preflight/setup-shell-env.sh
```

## Config files

Example configuration files live in `configs/`. These are reference copies --
the scripts generate the real files in the correct locations.

## Compatibility

Tested with Claude Code v2.1.92+, Opus 4.6. If you are running an older version,
some features may not be available. Always update to the latest Claude Code before
proceeding.

# Phase 3: Threshold Escalation Engine

**Time estimate:** 2 - 3 hours
**Gate:** Phase 2 must be complete (settings.json with hooks configured).

## What this phase does

Phase 3 implements the threshold-router skill, which is the core innovation of
this orchestration guide. It automatically scores every prompt's complexity and
assigns it a tier that controls how much review and verification happens.

## Why this matters

Without the threshold router, Claude Code treats every task the same way.
A simple typo fix gets the same level of analysis as a multi-file refactor.
The threshold system makes Claude proportionally careful:

- **Simple tasks** get done fast with no overhead
- **Medium tasks** get implemented then reviewed
- **Complex tasks** get a full plan, implementation, and multi-agent review

## Scoring signals

The threshold router computes a complexity score (0-10+) by adding up signals:

| Signal                          | Score  | Example                              |
|---------------------------------|--------|--------------------------------------|
| Files mentioned                 | +1/3   | "Update these 6 files" = +2         |
| Destructive keywords            | +2     | "delete", "remove", "drop table"     |
| Cross-system scope              | +2     | "update the API and the frontend"    |
| New architecture                | +3     | "add a caching layer"               |
| Security/IAM/auth involved      | +2     | "update the IAM policy"             |
| Production deployment           | +2     | "deploy to prod"                    |
| Ambiguous or open-ended         | +1     | "improve the performance"           |

## Tier definitions

| Tier | Score | Behavior                                                    |
|------|-------|-------------------------------------------------------------|
| T1   | 0-3   | Solo execution. Claude does the work and reports back.      |
| T2   | 4-7   | Lean pipeline. Claude does the work, then spawns review     |
|      |       | subagents to check for bugs, style, and test coverage.      |
| T3   | 8+    | Full orchestra. Claude plans with ultrathink, implements,   |
|      |       | then runs OCR multi-agent review and Codex verification.    |

## Override keywords

Users can override the computed tier:

- **"just do it"** -- downgrades to T1 (skip reviews, just get it done)
- **"full review"** -- upgrades to T3 (maximum verification)

## Debug note

If the threshold router does not fire on T1 or T2 tasks, check that your
global CLAUDE.md contains the mandatory threshold section:

```markdown
## Threshold Escalation (MANDATORY)
The threshold-router skill MUST be consulted on EVERY prompt.
Compute the complexity score and announce [T1], [T2], or [T3].
Override: "just do it" = downgrade | "full review" = T3
```

Without this section, Claude Code may not invoke the skill on simpler tasks.

## Scripts

| #  | Script                      | What it does                                       |
|----|-----------------------------|-----------------------------------------------------|
| 1  | `create-threshold-skill.sh` | Creates the skill definition in ~/.claude/skills/   |
| 2  | `test-threshold.sh`         | Validates prerequisites and skill file              |

## Config files

- `threshold-router-SKILL.md.example` -- full skill definition with comments

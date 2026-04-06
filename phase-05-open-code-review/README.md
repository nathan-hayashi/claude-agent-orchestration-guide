# Phase 5: Open Code Review (OCR) Plugin

**Estimated time:** 30 -- 60 minutes

## What Is OCR?

Open Code Review (OCR) is a Claude Code plugin by
[spencermarx/open-code-review](https://github.com/spencermarx/open-code-review)
that simulates a multi-person code review. It spawns multiple AI "reviewers"
(principal engineer, security specialist, quality engineer, etc.) who examine
your code from different angles and then discuss their findings.

## How OCR Works

1. You describe what you want reviewed in **natural language** (NOT slash commands)
2. OCR spawns a virtual review team
3. Each reviewer examines the code from their specialty
4. Reviewers hold a discourse round (optional) to debate findings
5. You get a consolidated review with ranked findings

## Important: Natural Language Invocation

OCR commands are invoked via natural language, NOT slash commands.

**Wrong:** `/ocr:review` -- this works
**Wrong:** `/ocr:doctor` -- returns "Unknown skill"
**Right:** "Run OCR doctor check" -- this works
**Right:** "Review my latest changes with OCR" -- this works

The `/ocr:doctor` slash command is broken in current versions. Use natural
language: "Run the OCR doctor diagnostic" or "Check if OCR is installed
correctly."

## Team Composition

The `.ocr/config.yaml` file controls how many reviewers of each type participate:

| Role | Count | What They Check |
|------|-------|-----------------|
| Principal Engineer | 2 | Architecture, design patterns, scalability |
| Security Specialist | 2 | Vulnerabilities, auth gaps, data exposure |
| Quality Engineer | 1 | Test coverage, error handling, maintainability |

Discourse rounds (default: 2) let reviewers challenge each other's findings,
reducing false positives.

## Scripts

| Script | What It Does |
|--------|--------------|
| `install-ocr.sh` | Installs OCR plugin and creates team config |

## Config Files

| File | What It Is |
|------|------------|
| `configs/.ocr-config.yaml.example` | Example team composition config |

## Next Phase

Proceed to [Phase 6: Codex Plugin](../phase-06-codex-plugin/).

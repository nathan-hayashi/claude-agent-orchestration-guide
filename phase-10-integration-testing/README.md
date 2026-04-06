# Phase 10: Integration Testing and Validation

**Estimated time:** 30 -- 60 minutes

## Purpose

This phase runs 10 integration tests to verify that all previous phases are
correctly installed and configured. Each test checks a specific component of
the orchestration system.

## Test Suite

| # | Test Name | What It Checks | Expected Result |
|---|-----------|---------------|-----------------|
| 1 | CLAUDE.md loads | File exists and is readable | PASS: file found |
| 2 | T1 on simple edit | Threshold score < 4 triggers T1 | PASS: T1 logic present |
| 3 | T3 on IAM audit | Threshold score 12+ triggers T3 | PASS: T3 logic present |
| 4 | Security hook blocks rm -rf | PreToolUse hook catches destructive cmd | PASS: hook pattern found |
| 5 | Prettier auto-format | PostToolUse hook fires formatter | PASS: hook exists |
| 6 | Error recovery hook | Error recovery hook is configured | PASS: hook exists |
| 7 | Override "just do it" | Downgrade override in threshold skill | PASS: logic present |
| 8 | Override "full review" | Upgrade override in threshold skill | PASS: logic present |
| 9 | Subagents spawned | Agent definition files exist | PASS: files found |
| 10 | Token context check | CLAUDE.md is under 200 lines | PASS: line count OK |

## How to Run

```bash
# Run all 10 tests
bash run-integration-tests.sh

# The script will output PASS/FAIL for each test
# and a summary at the end.
```

## Scripts

| Script | What It Does |
|--------|--------------|
| `run-integration-tests.sh` | Orchestrator that runs all 10 tests |
| `test-cases.sh` | Individual test functions (sourced by the orchestrator) |

## Interpreting Results

- **All 10 PASS:** Your orchestration system is correctly configured.
- **Some FAIL:** Read the failure messages. They tell you which phase to revisit.
- **Tests are advisory:** Some tests check for file patterns rather than runtime
  behavior. A PASS means the configuration looks correct; actual behavior depends
  on Claude Code loading the files at runtime.

## Test Details

### Test 1: CLAUDE.md Loads
Checks that `~/.claude/CLAUDE.md` or a project-level `CLAUDE.md` exists and is
readable. This is the primary instruction file for Claude Code.

### Test 2: T1 on Simple Edit
Verifies the threshold router skill contains logic that routes low-complexity
tasks (score 0 -- 3) to Tier 1 (direct execution, no review).

### Test 3: T3 on IAM Audit
Verifies the threshold router contains logic that routes high-complexity
tasks (score 8+) to Tier 3 (ultrathink plan + multi-agent review).

### Test 4: Security Hook Blocks rm -rf
Checks that settings.json contains a PreToolUse hook pattern that matches
and blocks destructive shell commands like `rm -rf`.

### Test 5: Prettier Auto-Format
Checks that a PostToolUse hook is configured to run Prettier (or similar
formatter) after file edits.

### Test 6: Error Recovery Hook
Checks that an error recovery hook is configured in settings.json.

### Test 7: Override "just do it"
Verifies the threshold router skill contains downgrade logic that responds
to "just do it" by lowering the tier.

### Test 8: Override "full review"
Verifies the threshold router skill contains upgrade logic that responds
to "full review" by raising to T3.

### Test 9: Subagents Spawned
Checks that the three agent definition files from Phase 7 exist in
`~/.claude/agents/`.

### Test 10: Token Context Check
Verifies that `CLAUDE.md` is under 200 lines to prevent excessive token
consumption on every Claude Code session start.

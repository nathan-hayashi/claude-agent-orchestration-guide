# Exercise 7: Vet Checkup -- Integration Testing

**Phase covered:** 10
**Time estimate:** 15 to 20 minutes
**Goal:** Run the integration test suite and verify your entire orchestration system works end-to-end.

---

## Background

You have now configured every layer of the orchestration system: CLAUDE.md, hooks, threshold router, Turbo skills, MCP servers, plugins, subagents, and auto mode. But how do you know everything works together correctly?

The integration test suite from Phase 10 runs 10 automated checks that verify each component. Think of it as a vet checkup for your entire setup.

## Prerequisite

All previous exercises (01 through 06) should be completed. The integration test script from Phase 10 must be available:

```bash
ls ~/projects/claude-agent-orchestration-guide/phase-10-integration-testing/run-integration-tests.sh
```

If the file does not exist, revisit Phase 10 of the main guide.

## Exercise: Run the Integration Tests

Execute the test suite:

```bash
~/projects/claude-agent-orchestration-guide/phase-10-integration-testing/run-integration-tests.sh
```

## Understanding the Results

The test suite runs 10 checks. Here is what each one verifies and what to do if it fails:

### Test 1: CLAUDE.md loads

**Checks:** Your project CLAUDE.md exists and is readable.

**If it fails:** Verify `~/projects/pet-shelter/CLAUDE.md` exists. Revisit Exercise 1.

### Test 2: T1 on simple edit

**Checks:** The threshold router scores a simple task (like renaming a field) as T1 (score 0 to 3).

**If it fails:** Verify the threshold router skill is installed. Revisit Phase 3.

### Test 3: T3 on IAM audit

**Checks:** The threshold router scores a security audit task as T3 (score 8+).

**If it fails:** The threshold router may not be weighting security tasks correctly. Check the skill configuration in Phase 3.

### Test 4: Security hook blocks rm -rf

**Checks:** Your PreToolUse bash blocker hook denies destructive commands.

**If it fails:** Verify `.claude/settings.json` has the bash blocker hook. Revisit Exercise 2.

### Test 5: Prettier auto-format

**Checks:** Your PostToolUse hook runs Prettier after file writes.

**If it fails:** Verify Prettier is installed (`npm ls prettier`) and the PostToolUse hook is configured. Revisit Exercise 2.

### Test 6: Error recovery hook

**Checks:** A PostToolUseFail hook exists to provide guidance when tools fail.

**If it fails:** Add a PostToolUseFail hook to `.claude/settings.json`. Refer to Phase 2 of the main guide.

### Test 7: Override "just do it"

**Checks:** The downgrade override logic works in the threshold router skill.

**If it fails:** Verify the threshold router skill handles the "just do it" phrase. Revisit Phase 3.

### Test 8: Override "full review"

**Checks:** The upgrade override logic works in the threshold router skill.

**If it fails:** Verify the threshold router skill handles the "full review" phrase. Revisit Phase 3.

### Test 9: Subagents spawned

**Checks:** All three subagent files (security-reviewer, quality-reviewer, fixer) exist.

**If it fails:** Verify the subagent skills are installed. Revisit Phase 7.

### Test 10: Token context

**Checks:** Your CLAUDE.md is under 200 lines. Overly long CLAUDE.md files waste context tokens and reduce Claude's effectiveness.

**If it fails:** Trim your CLAUDE.md. Move detailed documentation to separate files and reference them with links.

## Interpreting the Summary

After all 10 tests run, you will see a summary:

```
=== Results ===
PASS: 8/10
FAIL: 2/10

Failed tests:
  - Test 5: Prettier auto-format
  - Test 6: Error recovery hook
```

A perfect score is 10/10. If you have failures:

1. Note which tests failed
2. Read the failure description above to understand what is missing
3. Go back to the relevant phase or exercise and fix the configuration
4. Re-run the test suite to confirm the fix

## After All Tests Pass

When you see 10/10, your orchestration system is fully operational. You have:

- A CLAUDE.md that shapes Claude Code's behavior
- Security hooks that enforce hard boundaries
- A threshold router that scales review intensity by complexity
- Turbo skills for automated workflows
- MCP servers for external service integration
- Subagents for multi-perspective code review
- Auto mode for independent multi-step execution
- Integration tests that verify everything works together

## Key Takeaway

Integration tests verify your entire orchestration system works end-to-end. Run them after any configuration change to catch regressions. A passing suite means every layer -- from CLAUDE.md to subagents -- is correctly configured and coordinated.

---

**Tutorial complete.** Return to the [main guide](../README.md) for advanced topics and reference material.

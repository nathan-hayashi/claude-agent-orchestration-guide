# Exercise 5: Breed the Agents -- Custom Subagents

**Phases covered:** 7 and 8
**Time estimate:** 20 to 25 minutes
**Goal:** See how subagents provide automated, multi-perspective code review.

---

## Background

A single reviewer catches some issues. Multiple reviewers with different specialties catch more. Subagents are specialized Claude Code instances that each focus on one aspect of code quality:

- **Security reviewer** -- looks for hardcoded secrets, injection risks, missing auth checks
- **Quality reviewer** -- checks error handling, code structure, naming conventions
- **Fixer** -- takes findings from the other reviewers and applies corrections

These agents run in parallel and report back their findings, giving you multi-perspective review without manual coordination.

## Prerequisite

Subagents must be installed from Phase 7 of the main guide. Verify they exist:

```bash
ls ~/.claude/skills/
```

You should see agent-related skill files. If not, revisit Phase 7.

## Step 1: Create a file with deliberate security issues

In your pet-shelter project, create a file with known problems:

```bash
cat > shelter-api.js << 'EOF'
const API_KEY = "sk-live-real-key-12345";
const fetch = require('node-fetch');

async function getAnimals() {
  return fetch(`https://api.shelter.com/v1/animals?key=${API_KEY}`);
}

module.exports = { getAnimals };
EOF
```

This file has several intentional issues:

1. **Hardcoded API key** -- a real key exposed in source code
2. **No error handling** -- the fetch call has no try/catch or response checking
3. **Key in URL** -- the API key is passed as a query parameter (visible in logs and browser history)

## Exercise 1: Trigger a multi-agent review

Open a Claude Code session:

```bash
cd ~/projects/pet-shelter
claude
```

Ask Claude:

```
Review shelter-api.js for security issues
```

**What to look for:**

Since this involves security analysis of code with real issues, the threshold router should classify this as T2 or higher, which triggers the subagent pipeline:

1. **Security reviewer** runs first and should flag:
   - The hardcoded API key on line 1
   - The API key exposed in the URL query string
   - The potential for key leakage in server logs

2. **Quality reviewer** runs in parallel and should flag:
   - Missing error handling on the fetch call
   - No response status checking
   - No input validation
   - Missing JSDoc or documentation

3. **Fixer** receives findings from both reviewers and proposes corrections

You should see findings from multiple perspectives, not just a single list.

## Exercise 2: Fix the issues

After reviewing the findings, ask Claude:

```
Fix all the issues found in shelter-api.js
```

**Expected result:**

Claude should apply fixes that address both security and quality findings:

```javascript
// shelter-api.js (after fixes)
const fetch = require('node-fetch');

async function getAnimals() {
  const apiKey = process.env.SHELTER_API_KEY;
  if (!apiKey) {
    throw new Error('SHELTER_API_KEY environment variable is not set');
  }

  try {
    const response = await fetch('https://api.shelter.com/v1/animals', {
      headers: {
        'Authorization': `Bearer ${apiKey}`
      }
    });

    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }

    return response.json();
  } catch (error) {
    throw new Error(`Failed to fetch animals: ${error.message}`);
  }
}

module.exports = { getAnimals };
```

Key changes to verify:

- API key moved from hardcoded string to `process.env.SHELTER_API_KEY`
- Key sent via Authorization header instead of URL query parameter
- Error handling wraps the fetch call
- Response status is checked before returning data
- Missing environment variable throws a clear error

## How Subagents Coordinate

The flow works like this:

1. Your prompt triggers a T2+ classification from the threshold router
2. Claude spawns the security-reviewer and quality-reviewer subagents in parallel
3. Each subagent analyzes the code from its specialty perspective
4. Findings are collected and deduplicated
5. The fixer subagent processes the combined findings
6. Claude presents the results and offers to apply fixes

This happens automatically when the threshold router determines the task warrants multi-perspective review. You do not need to manually invoke each agent.

## Key Takeaway

Subagents provide automated, multi-perspective code review. Each agent specializes in a different aspect of code quality, catching issues that a single-perspective review would miss. The system coordinates them automatically based on task complexity.

---

**Next:** [Exercise 6: Auto Walkies](06-auto-walkies.md)

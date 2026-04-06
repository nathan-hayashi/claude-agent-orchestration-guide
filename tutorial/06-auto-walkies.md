# Exercise 6: Auto Walkies -- Autonomous Mode

**Phase covered:** 9
**Time estimate:** 15 to 20 minutes
**Goal:** Let Claude Code work autonomously on a multi-step task while hooks maintain safety.

---

## Background

In the previous exercises, Claude Code asked for your confirmation before each action. Autonomous mode lets Claude work through multiple steps without pausing for approval, while hooks still enforce security boundaries.

Think of it like this: you are giving the dog a longer leash, but the fence (hooks) is still there.

## Prerequisite

Auto mode must be enabled with all guardrails from Phase 9 of the main guide. This includes:

- PreToolUse hooks active (from Exercise 2)
- Threshold router configured (from Exercise 3)
- Notification hook set up (so Claude can ping you when it needs input)

## Exercise: Multi-Step Autonomous Task

Open a Claude Code session in auto mode:

```bash
cd ~/projects/pet-shelter
claude
```

Give Claude an open-ended task:

```
Organize the pet data into separate files by species, create a dogs.json and cats.json, add an index.js that reads both files and provides a combined API, and add a README for the project.
```

**What to watch for during execution:**

1. **Multiple file operations** -- Claude creates dogs.json, cats.json, index.js, and README.md without asking for confirmation on each one

2. **Auto-format hook firing** -- after each file write, the PostToolUse hook runs Prettier (if installed). You may see formatting messages in the output

3. **Security hooks still active** -- if Claude tries anything that matches your PreToolUse block patterns, the hooks still deny it. Auto mode does not bypass hooks

4. **Threshold router classification** -- the response starts with a tier prefix. This multi-file task should classify as T2 or higher

5. **Notification hook** -- if Claude encounters an ambiguity or needs a decision, the notification hook pings you rather than silently guessing

## What the Result Should Look Like

After Claude finishes, you should have these new files:

**dogs.json** -- the dog entries extracted from pets.json:
```json
[
  {"name": "Buddy", "breed": "Golden Retriever", "age": 3, "status": "available"},
  {"name": "Luna", "breed": "Siberian Husky", "age": 2, "status": "available"},
  {"name": "Max", "breed": "Beagle", "age": 5, "status": "adopted"}
]
```

**cats.json** -- the cat entries extracted from pets.json:
```json
[
  {"name": "Whiskers", "breed": "Tabby", "age": 4, "status": "available"},
  {"name": "Shadow", "breed": "Black Shorthair", "age": 1, "status": "available"},
  {"name": "Mochi", "breed": "Calico", "age": 3, "status": "adopted"}
]
```

**index.js** -- a module that reads both files and provides a combined interface

**README.md** -- project documentation

Verify the files exist and contain valid content:

```bash
ls -la *.json *.js *.md
cat dogs.json | python3 -m json.tool
cat cats.json | python3 -m json.tool
node -e "const api = require('./index.js'); console.log('Module loads successfully');"
```

## Safety in Auto Mode

Auto mode is powerful but not unchecked. Here is what keeps it safe:

| Layer | What it does |
|-------|-------------|
| PreToolUse hooks | Block dangerous commands and secret access, same as manual mode |
| PostToolUse hooks | Auto-format code, log actions |
| Threshold router | Classifies task complexity and triggers appropriate review |
| Notification hook | Alerts you when Claude needs human input |
| CLAUDE.md rules | Guidelines Claude follows (conventional commits, valid JSON, etc.) |

The key insight: auto mode removes the *confirmation prompt*, not the *guardrails*. Every safety layer from the previous exercises remains active.

## Key Takeaway

Auto mode lets Claude work independently through multi-step tasks while hooks maintain safety. The confirmation prompt is removed, but security hooks, auto-formatting, threshold routing, and notification all continue to operate. Longer leash, same fence.

---

**Next:** [Exercise 7: Vet Checkup](07-vet-checkup.md)

# Exercise 1: Hello Pets -- Your First Claude Code Project

**Phases covered:** 0 and 1
**Time estimate:** 15 to 20 minutes
**Goal:** Create a project, write a CLAUDE.md, and see how it shapes Claude Code's behavior.

---

## Background

CLAUDE.md is the single most important file in any Claude Code project. It tells Claude Code what your project is, what rules to follow, and how to behave. Without it, Claude Code works generically. With it, Claude Code works the way you want.

## Step 1: Create the project directory

Open your terminal and run:

```bash
mkdir ~/projects/pet-shelter && cd ~/projects/pet-shelter
```

## Step 2: Initialize git

Claude Code expects a git repository. Initialize one:

```bash
git init
```

## Step 3: Create the pet data file

Create `pets.json` with the following content:

```json
{
  "dogs": [
    {"name": "Buddy", "breed": "Golden Retriever", "age": 3, "status": "available"},
    {"name": "Luna", "breed": "Siberian Husky", "age": 2, "status": "available"},
    {"name": "Max", "breed": "Beagle", "age": 5, "status": "adopted"}
  ],
  "cats": [
    {"name": "Whiskers", "breed": "Tabby", "age": 4, "status": "available"},
    {"name": "Shadow", "breed": "Black Shorthair", "age": 1, "status": "available"},
    {"name": "Mochi", "breed": "Calico", "age": 3, "status": "adopted"}
  ]
}
```

You can also copy this from the starter files:

```bash
cp ~/projects/claude-agent-orchestration-guide/tutorial/assets/sample-project/pets.json .
```

## Step 4: Create your CLAUDE.md

Create a file called `CLAUDE.md` in the project root with these contents:

```markdown
# PetShelter Project

JSON-based pet shelter data management.

## Rules
- Use conventional commits (feat:, fix:, chore:)
- Keep pets.json valid JSON at all times
- Never hardcode API keys or secrets
```

This is intentionally minimal. Five to ten lines is enough to start. You will expand it as the project grows.

## Step 5: Make your first commit

```bash
git add pets.json CLAUDE.md
git commit -m "chore: initialize pet shelter project"
```

## Exercise: Add a pet with Claude Code

Open a Claude Code session:

```bash
claude
```

Once the session starts, type this prompt:

```
Add a new dog named Rex, breed German Shepherd, age 3 to pets.json
```

Watch what happens. Claude Code should:

1. Read `pets.json`
2. Add Rex to the dogs array
3. Keep the JSON valid (as your CLAUDE.md requires)
4. Create a commit using conventional commit format (as your CLAUDE.md requires)

## Verify

After Claude Code finishes, check the result:

```bash
cat pets.json
```

You should see Rex in the dogs array. Now check the git log:

```bash
git log --oneline -1
```

The commit message should follow conventional commit format, something like `feat: add Rex to dogs` or `chore: add German Shepherd Rex to pets.json`.

## Key Takeaway

CLAUDE.md shapes how Claude Code behaves in your project. The rules you wrote (conventional commits, valid JSON, no hardcoded secrets) are not just suggestions. Claude Code reads them at the start of every session and follows them throughout.

In the next exercise, you will see what happens when you need enforcement that goes beyond suggestions.

---

**Next:** [Exercise 2: Guard the Kennel](02-guard-the-kennel.md)

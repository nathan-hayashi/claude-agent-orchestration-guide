# Exercise 3: Sort the Litter -- Threshold Router in Action

**Phase covered:** 3
**Time estimate:** 15 to 20 minutes
**Goal:** See how the threshold router classifies tasks by complexity and adjusts review intensity.

---

## Background

Not every task needs the same level of oversight. Renaming a field in a JSON file is trivial. Refactoring an entire data model with new schemas is complex. The threshold router scores each task on a 0-to-10 complexity scale and assigns a tier:

| Tier | Score | Behavior |
|------|-------|----------|
| T1 | 0 to 3 | Proceed directly. No extra review. |
| T2 | 4 to 7 | Implement, then spawn review subagents to check the work. |
| T3 | 8 to 10 | Extended thinking plan, implement, then full review pipeline. |

The tier prefix (e.g., `[T1]`) appears at the start of Claude's response so you always know what level of scrutiny is being applied.

## Prerequisite

The threshold router skill must be installed. Verify by checking that it appears in your skills list. If you followed Phase 3 of the main guide, it is already configured.

## Exercise 1: A T1 Task (Simple)

Open a Claude Code session in your pet-shelter project:

```bash
cd ~/projects/pet-shelter
claude
```

Ask Claude:

```
Rename the breed field to species_breed in pets.json
```

**What to look for:**

- The response starts with `[T1]` -- this is a simple, low-risk edit
- Claude makes the change directly without spawning any review agents
- The change is straightforward: find-and-replace on a single field name

This is a score 0-to-3 task. One file, one field, no architectural impact.

## Exercise 2: A T2+ Task (Complex)

In the same session (or a new one), ask:

```
Refactor the pet data model to support breeds, vaccinations, adoption history, and medical records. Split into separate files by species.
```

**What to look for:**

- The response starts with `[T2]` or `[T3]` -- this is a multi-file refactoring task
- At T2, Claude implements the changes and then spawns review agents to check the work
- At T3, Claude first creates a detailed plan, then implements, then runs the full review pipeline
- The task involves creating new files, defining schemas, and restructuring existing data

This is a score 4+ task. Multiple files, new data structures, potential for breaking changes.

## Exercise 3: Override the Classification

Sometimes the router over- or under-classifies a task. You have two override phrases:

**Downgrade:** If Claude classifies something as T2 and you think it is simpler, say:

```
just do it
```

This downgrades the tier by 1 (T2 becomes T1, T3 becomes T2).

**Upgrade:** If Claude classifies something as T1 but you want thorough review, say:

```
full review
```

This upgrades the task to T3 regardless of the original score.

Try this: after Claude gives a T2 response to Exercise 2, reply with:

```
just do it
```

**Expected result:** Claude acknowledges the downgrade and proceeds with less review overhead.

## How the Scoring Works

The threshold router considers several factors:

- **File count** -- more files affected means higher complexity
- **Change type** -- new features score higher than renames or formatting
- **Domain sensitivity** -- security-related changes score higher
- **Architectural impact** -- changes to data models or APIs score higher than leaf-node edits
- **Cross-cutting concerns** -- changes that affect multiple systems score higher

You do not need to understand the exact formula. The key concept is that the system adapts automatically, and you can override when needed.

## Key Takeaway

The threshold router automatically adjusts review intensity based on task complexity. Simple tasks get fast execution. Complex tasks get proportional scrutiny. You can override in either direction when the automatic classification does not match your judgment.

---

**Next:** [Exercise 4: Fetch Skills](04-fetch-skills.md)

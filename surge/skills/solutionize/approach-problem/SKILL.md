---
name: approach-problem
description: Produce named strategic options with file/line estimates and pros/cons
---

# Approach problem

## Your goal

Present a small set of **named, actionable options** to solve the problem. For each option, estimate scope and summarize the tradeoff in one sentence each.

## Option format

Each option should include:

- **Description:** 1 plain-language sentence. Stay at strategy level; do not include syntax, deep implementation details, or edge-case policy decisions
> **Est. changed files count:** Range (e.g., 3-5)
> **Est. changed lines count:** Range (e.g., 80-140)
> **Pros:** Exactly one sentence
> **Cons:** Exactly one sentence

When presenting multiple options, use **Option A, Option B, Option C, ...** and make Option A your most recommended path.

For every option after A, describe **only the differences from Option A**. Do not restate shared behavior, assumptions, or mechanics.

## Anti-patterns to avoid

- Do not include ordered implementation phases or per-file step lists (those belong in sketch-solution)
- Do not explain how you calculated file or line counts
- Do not go syntax-level or deep into implementation details
- Do not discuss parameter design, edge-case policies, or internal mechanics at this stage

---

## Example

**Option A:** Add a validation layer in the `User.changeset/2` function that checks email uniqueness against the database before attempting insert.
> **Est. changed files count:** 1-2
> **Est. changed lines count:** 15-25
> **Pros:** Validation happens before hitting the database, reducing failed inserts and keeping business logic centralized.
> **Cons:** Adds a query to the changeset path, which runs on every user creation.

**Option B:** Move uniqueness validation to the database layer with a unique constraint instead.
> **Est. changed files count:** 2 (migration + schema)
> **Est. changed lines count:** 10-20
> **Pros:** Prevents bad data at the source and handles concurrent requests safely.
> **Cons:** Errors surface after insert attempt, requiring exception handling upstream.

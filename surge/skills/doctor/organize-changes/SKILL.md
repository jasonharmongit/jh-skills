---
name: organize-changes
description: Organize functions and/or tests whose names have been changed on the current branch
---

### Workflow

#### Step 1: Find candidates

Identify definitions whose **name** is **new or changed** on the current branch (compared to the merge base with `main`). Treat each name and arity as one unit (all clauses together). Scan:

- **One file:** If a path is given, only that module or test file.
- **Whole branch:** If no path is given, only files touched on the branch (committed + working tree).
  - Committed branch-only changes: `git diff --name-status "$(git merge-base HEAD main)"...HEAD`
  - Working tree: `git status --short`

Skip files that have no such definitions.

**Anti-patterns to avoid**

- Do not treat every changed line in a file as a candidate (only **new or renamed** definition names count).
- Do not reorder definitions that were **only edited in the body**—no name change means not a candidate.
- Do not pull in unrelated files “while you’re at it” beyond the chosen scope.

---

#### Step 2: Organize

For **each** candidate, compute where it belongs **as if** the entire file were ordered by **`skills/organize-file/SKILL.md`** (public vs private, LiveView lifecycle, alphabetical `defp`, happy-path-before-edge in tests, etc.). Build the ordering using **every** `def`, `defp`, `describe`, and `test` in that file as the reference—not only other candidates.

Move **only** candidates into those slots (definition + clauses as one unit). Adjust clause order inside a candidate when **`skills/organize-file/SKILL.md`** requires it.

**Anti-patterns to avoid**

- Do not leave candidates **bunched near the PR edit** or **grouped with each other** because they were added together, call each other, or to keep the diff small.
- Do not apply a **minimal reorder** that only sorts candidates relative to each other while they remain in the **wrong region** of the file globally.
- Do not move non-candidates to “clean up” the whole file; scope stays **candidates only**.
- Do not move a candidate to another part of the file when it is **already** in its correct global slot; do reorder clauses within that candidate when **`skills/organize-file/SKILL.md`** requires it.

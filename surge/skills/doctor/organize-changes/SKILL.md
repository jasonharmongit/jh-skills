---
name: organize-changes
description: Organize functions and/or tests whose names have been changed on the current branch
---

Follow **`skills/organize-file/SKILL.md`** for **Precedence over file conventions**, **General rules**, **Specific rules**, and **Output expectations**.

### Candidates

- Only move or reorder definitions whose **name** is new or changed on the branch. Treat each name/arity’s clauses as one unit per **General rules** in **organize-file**.
- Do not move other definitions, even if they sit out of order relative to **General rules** or **Specific rules**.
- Place each candidate **anywhere in that file** where **organize-file** says it belongs (global position among all definitions in the file), not only near the lines you edited; do not leave candidates bunched in the edit region when their correct slot is elsewhere.

### Scope

- **One file:** If a file path is given, only consider candidates in that module or test file.
- **Whole branch:** If no path is given, scan files changed on the branch; only edit files that contain candidates needing reorder.
  - Committed branch-only changes: `git diff --name-status "$(git merge-base HEAD main)"...HEAD`
  - Working tree: `git status --short`
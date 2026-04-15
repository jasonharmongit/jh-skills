---
name: organize-functions
description: Organize functions in a file or across a branch.
---

### Scope Mode

- File mode: if a file path is provided, only organize that file.
- Branch mode: if no file path is provided, inspect changed files on the current branch and organize files that need updates.

### Selection Mode

- Changed-only mode (default):
  - only organize candidate functions touched on the current branch
  - candidate functions are newly added, renamed, or changed visibility (`def` <-> `defp`)
  - do not move untouched function definitions, even if out of order
- Override mode (explicit request only):
  - organize all functions in the selected scope, including unchanged definitions

### Ordering Rules

- LiveView and LiveComponent modules:
  - prefer execution and lifecycle order over alphabetical order
  - keep `render/1` before any `handle_event/3` clauses
  - keep callback groups contiguous, especially `handle_event/3`
  - order `handle_event/3` clauses in workflow chronology, not alphabetical order
- Non-LiveView modules:
  - public functions first (`def`), sorted alphabetically by function name
  - private functions second (`defp`), sorted alphabetically by function name

### Structural Safety Rules

- Treat all clauses of the same function name and arity as one unit.
- Keep clause order by match specificity (specific first, broad fallback last). In the case of a tie, use alphabetical order based on the main atom involved.
- Keep each moved function body unchanged except for location.
- Preserve module structure, comments, spacing conventions, and non-function code.

## Output Expectations

- Make the minimum movement needed to satisfy ordering rules for candidate functions.
- In changed-only mode:
  - file mode: if the target file has no candidate functions, make no reordering changes
  - branch mode: skip files with no candidate functions and only modify files that need reordering
- In override mode, organize all functions in the selected scope, even if definitions are unchanged.
- Preserve behavior: do not make ordering changes that alter pattern matching outcomes.
- In LiveView and LiveComponent modules, callback lifecycle order wins over alphabetical order.

---
name: organize-elixir-functions
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

- LiveView modules:
  - prefer execution and lifecycle order over alphabetical order
  - use this default callback order: `mount/3`, `handle_params/3`, `handle_event/3`, `handle_info/2`, `handle_async/3` (and other handlers), then `render/1`
  - keep callback groups contiguous, especially `handle_event/3`, `handle_info/2`, and `handle_async/3`
  - order `handle_event/3` clauses alphabetically by event name
  - if `render/1` is not defined in the module (for example, template-backed LiveViews), skip render-ordering rules
- LiveComponent modules:
  - prefer execution and lifecycle order over alphabetical order
  - use this default callback order: `mount/1`, `update/2`, `handle_event/3`, `handle_info/2`, `handle_async/3` (and other handlers), then `render/1`
  - keep callback groups contiguous, especially `update/2` and `handle_event/3`
  - order `handle_event/3` clauses alphabetically by event name
- Non-LiveView modules:
  - public functions first (`def`), sorted alphabetically by function name
  - private functions second (`defp`), sorted alphabetically by function name

### Structural Safety Rules

- Treat all clauses of the same function name and arity as one unit.
- Preserve existing pattern-match clause order unless explicitly asked to change behavior.
- Keep callback clause groups contiguous (for example, all `handle_params/3` clauses together).
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

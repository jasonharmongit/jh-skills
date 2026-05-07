---
name: organize-file
description: Order every Elixir `def`/`defp` (and tests) in a file by lifecycle and naming rules.
---

Use when reorganizing **the whole file** (all definitions in that module or test). To reorder **only** definitions touched on the current branch, use **`surge/skills/doctor/organize-changes/SKILL.md`** instead.

### Precedence over file conventions

- These ordering rules override local habits and one-off layout in the file (e.g. clustered helpers, private functions near call sites). Do not preserve layout when it conflicts with **General rules** or **Specific rules** below.

### General rules

- Treat all clauses of the same function name and arity as one unit; within that unit, order clauses alphabetically by the **distinguishing** atom(s) or parameters.
- Do not reorder clauses when it would change which pattern matches (specificity or catch-all order).
- Keep callback clause groups contiguous (e.g. all `handle_params/3` clauses together).
- Keep each moved function body unchanged except for location.
- Preserve module structure, comments, spacing, and non-function code.
- Private functions (`defp`) always go last, alphabetically by function name.

### Specific rules

- **LiveView modules**
  - Default callback order: `mount/3`, `handle_params/3`, `handle_event/3`, `handle_info/2`, `handle_async/3`, then other handlers, then `render/1`
  - Order `handle_event/3` clauses alphabetically by event name.

- **LiveComponent modules**
  - Default callback order: `mount/1`, `update/2`, `handle_event/3`, `handle_info/2`, `handle_async/3`, then other handlers, then `render/1`
  - Keep callback groups contiguous, especially `update/2` and `handle_event/3`
  - Order `handle_event/3` clauses alphabetically by event name.

- **Other modules**
  - Follow **General rules**: public functions (`def`) first, alphabetically by function name; private functions (`defp`) last.

- **Test modules**
  - Apply ordering within each `describe` block (mirror that order when nesting `describe`).
  - For a given behavior, **happy path first**, then related error/edge tests immediately after (not interleaved with other features).
  - Keep `describe` / `test` groupings consistent: success scenario first, then its failures/edges in the same cluster.

### Output expectations

- Move functions to their correct positions even when that crosses large regions of the file.
- Respect clause and pattern order per **General rules**.
- In LiveView and LiveComponent modules, callback lifecycle order wins over alphabetical order among callbacks.

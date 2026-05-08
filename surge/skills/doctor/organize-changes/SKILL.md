---
name: organize-changes
description: Reorder branch-touched defs/tests into organize-file slots (new/renamed names, arity, or signature param names)
---

### Preconditions

- **Ordering law**: Read **`skills/organize-file/SKILL.md`** before moving code; placement always defers to it (including LiveView lifecycle, `describe`/`test` clustering, and **do not reorder clauses** when that would change pattern match order).
- **Single path**: If the user gives one file path, only that file is in scope; merge-base comparison still applies.

### What counts as a candidate

- **Elixir**: `def`, `defp`, or `defmacro` is a candidate if **any** of the following vs `merge-base`: the **function name** differs; **arity** differs; **clause heads** differ in **parameter / binding names** (or other head text) while keeping the same logical function—treat **all clauses of the same name+arity** as one movable unit. Also: name+arity **removed and replaced** (rename → treat as remove + add; place the **new** name only, do not resurrect deleted names).
- **Tests**: A **`test "…"`** or **`describe "…"`** whose **string literal** is new or meaningfully renamed vs merge-base (use diff judgment for tiny string edits).
- **Not** a candidate: same **function name**, **arity**, and **clause heads** (including parameter names) as merge-base, with **only** body, typespec, or attribute changes; whitespace; comments-only.

### Orchestrator (parent agent) — exact sequence

1. **Set merge base**

   ```bash
   BASE_BRANCH=main
   MB="$(git merge-base HEAD "$BASE_BRANCH")"
   ```

   If `main` does not exist locally, use `origin/main` or the repo’s default integration branch. Document the chosen `$BASE_BRANCH` in the user-facing summary.

2. **Collect paths (committed ∪ working tree)**

   ```bash
   git diff --name-status "$MB"...HEAD
   git status --short
   ```

   Build the **union** of paths from both outputs. If the user passed an explicit path, use **only** that path (still compute `MB`).

3. **Filter to in-scope files**

   - Prefer: `*.ex`, `*.exs` under `lib/`, `test/`, `apps/*/lib`, `apps/*/test` (adjust to monorepo layout if needed).
   - Drop paths that are clearly not Elixir sources (e.g. `priv/`, `assets/`, lockfiles) unless the user’s explicit path overrides.

4. **Triage: which changed files need a worker (cheap)**

   Paths from step 2 are already “changed”; this step drops paths where **organize-changes** cannot apply.

   For each in-scope path, run **`git diff "$MB" -- <path>`** (unified diff; **`-U0`** is optional if you want smaller output).

   - **Dispatch a worker** when the diff shows edits on or immediately adjacent to any **`def` / `defp` / `defmacro` clause head** or any **`test` / `describe`** line—including **parameter renames** on an unchanged function name (usually `+`/`-` on the same head line).
   - **Skip** when the only edits are clearly **outside** definition heads and titles (e.g. only inside a function body, typespec-only, comments-only, or non-definition data)—the worker’s “not a candidate” rule is the final word if triage is ambiguous.

   Do **not** use **name-only** inventory (set subtract of `def` names) as triage: it **misses** param-only head changes. Name/head comparison belongs in **step 2 of the per-file worker**, after you have opened the diff.

   If **no** path survives triage, report completion with **no workers** spawned.

5. **Execute per-file work**

   After triage, launch **one implement subagent per remaining path** (one module ≈ one file). Each worker must **only** edit its assigned path; paths are disjoint, so **run those tasks in parallel**—there is no cross-file edit conflict. A worker may finish with **no** moves (`actions: none`) when triage was ambiguous or there were no real candidates.

6. **Aggregate and report to the user**

   - Table: `path` → `candidates` → `action` (`moved` / `clause order only` / `already correct` / `skipped: no candidates`).
   - List any files **touched on branch but not processed** (with reason: filtered extension, binary, etc.).

### Per-file worker (subagent or focused turn) — exact sequence

Give the worker: `MB` hash, `BASE_BRANCH`, **single `path`**, and a link to **`surge/skills/doctor/organize-file/SKILL.md`**.

1. **Confirm diff exists**

   ```bash
   git diff "$MB" -- "<path>"
   ```

   If empty and `git show "HEAD:<path>"` equals merge-base version, exit: **no branch delta** (unless the user cares about unstaged-only; then also `git diff -- "<path>"` against index).

2. **Build candidate set (prescriptive)**

   - Run **definition inventory** on **`$MB:<path>`** and on **working tree** (or `HEAD:<path>` + `git diff` for unstaged—prefer **working tree file on disk** vs `MB` for “what we ship” accuracy when there are uncommitted changes).
   - Compare per **`name/arity`** unit: if **names** or **arity** differ vs base, it is a candidate. If name and arity match, compare **each clause head** (including **parameter / binding names**); if any head text differs, the whole unit is a candidate.
   - Use **`git diff "$MB" -- <path>`** to resolve ambiguities (rename vs delete+add, `test` title changes, head-only edits).

3. **Classify module**

   From file contents: `Phoenix.LiveView` vs `Phoenix.LiveComponent` vs plain module vs `*_test.exs`. Apply the matching section of **organize-file**.

4. **Compute target slots**

   - Enumerate **every** `def`, `defp`, `defmacro`, and (in tests) every `describe` / `test` in the file in **organize-file** order—not only candidates.
   - For each **candidate**, record the **function or test block** (first line through closing `end` of that definition) and the **immediate non-candidate neighbors** it must sit between after the move.

5. **Edit**

   - Move **whole** candidate units only; preserve bodies and non-definition code.
   - **Clause order** inside a candidate: apply **organize-file** only where it does **not** violate “do not reorder clauses when it would change which pattern matches.”
   - If a candidate is **already** between the correct global neighbors, **do not** move it; still fix **intra-candidate** clause order if required.

6. **Worker completion message (required shape)**

   ```text
   path: <path>
   candidates: <names or test titles>
   actions: <moved | reordered clauses | already correct | none>
   notes: <optional: e.g. ambiguous rename>
   ```

### Commands: definition inventory

Use tooling available in the environment (`git grep`, `grep`, or ripgrep). Examples (adjust if `HEAD:path` is wrong for uncommitted-only comparison):

```bash
# Current working tree
grep -E '^\s*(def|defp|defmacro)\s+[a-zA-Z_?!]' -- "<path>" || true

# Merge-base revision
git show "$MB:<path>" 2>/dev/null | grep -E '^\s*(def|defp|defmacro)\s+[a-zA-Z_?!]' || true
```

For tests:

```bash
grep -E '^\s*(test|describe)\s' -- "<path>" || true
git show "$MB:<path>" 2>/dev/null | grep -E '^\s*(test|describe)\s' || true
```

**Limitation**: Line-based grep misses rare multiline heads; **`git diff`** is the fallback when grep is inconclusive.

### Cursor-specific guidance

- **`Task` tool**: Spawn **`generalPurpose`** (or equivalent) **one task per path**, each prompt scoped to **that file only**; launch **in parallel** when several paths survived triage (disjoint files → no edit conflicts). Sort completion messages when presenting to the user if a stable order helps.
- **Prompt pack for each implement task**: Include `MB`, `BASE_BRANCH`, the **path**, links to this skill and to **organize-file**, and the **required worker completion shape**—the worker derives the candidate list per **Per-file worker** step 2.
- **Do not** assume `rg` is on PATH in sandboxes; prefer **`git grep`** / **`grep`** as documented.

### Anti-patterns (orchestrator and workers)

- Do not treat **every** changed line as a candidate; only **head-level** changes count: new/renamed **function** name, **arity**, **clause-head** text (including **parameter / binding names**), or new/renamed **test**/**describe** titles—not arbitrary body edits.
- Do not reorder definitions that differ from merge-base **only** inside the `do`…`end` body (or typespecs/attributes only), with an otherwise identical head.
- Do not **move non-candidates** to “clean up” the file.
- Do not apply **minimal** reorder that only sorts candidates among themselves while they remain in the **wrong global region** of the file.
- Do not move a candidate that is **already** in the correct global position (except allowed **clause** reorder inside that unit per organize-file + pattern safety).
- Do not pull in paths **outside** the union of merge-base…HEAD and working tree (unless user gave an explicit path).
- Do not run destructive git commands (`reset`, `checkout --`) as part of this skill.

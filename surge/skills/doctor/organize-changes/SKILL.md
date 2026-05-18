---
name: organize-changes
description: Reorder branch-touched defs/tests into organize-file slots (orchestrator triages only; subagents apply edits; orchestrator ends with exactly `complete`, no summary)
---

### Preconditions

- **Ordering law**: Read **`skills/organize-file/SKILL.md`** before moving code. Placement always defers to it (LiveView lifecycle, `describe`/`test` clustering, **do not reorder clauses** when that would change pattern match order).
- **Single path**: If the user gives one file path, only that file is in scope; merge-base comparison still applies.

### Orchestrator (parent agent)

**Role:** Triage, `git` inspection, and launching workers only. **Never** edit `*.ex` / `*.exs` or apply reorders in the orchestrator turn.

- **Every** path that needs organize work—including **exactly one**—goes to a **subagent** (`Task` with `generalPurpose` or equivalent). No “small enough to inline” exception.
- **Zero** paths after triage: spawn no workers; do not edit sources.
- **Cannot spawn** a worker: stop with **one line** stating the blocker only (not `complete`). Do not edit files yourself.
- **`Task` spawns:** **Never** pass `model`; workers inherit the orchestrator’s model.

**Sequence**

1. **Set merge base**

   ```bash
   BASE_BRANCH=main
   MB="$(git merge-base HEAD "$BASE_BRANCH")"
   ```

   If `main` is missing locally, use `origin/main` or the repo default. Use `$BASE_BRANCH` / `$MB` only in `git` commands and worker prompts—not in user-facing output.

2. **Collect paths (committed ∪ working tree)**

   ```bash
   git diff --name-status "$MB"...HEAD
   git status --short
   ```

   Union both outputs. User gave an explicit path → **only** that path (still compute `MB`).

3. **Filter** to in-scope Elixir: `*.ex`, `*.exs` under `lib/`, `test/`, `apps/*/lib`, `apps/*/test` (adjust for monorepo). Drop non-sources (`priv/`, `assets/`, lockfiles) unless the user’s path overrides.

4. **Triage** each in-scope path with `git diff "$MB" -- <path>` (`-U0` optional).

   - **Dispatch** when the diff touches a **`def` / `defp` / `defmacro` clause head** or a **`test` / `describe`** line—including parameter renames on an unchanged name (`+`/`-` on the same head line).
   - **Skip** when edits are clearly outside heads/titles (body only, typespec-only, comments-only, non-definition data). The worker’s candidate rules are final if ambiguous.
   - **Do not** triage via name-only inventory (set subtract of `def` names)—that misses param-only head changes.

   No paths survive → skip step 5.

5. **Execute (subagents only)** — one worker per remaining path; **parallel** when multiple (disjoint files). Wait for all workers before step 6. Orchestrator does not open files to reorder. A worker may finish with `actions: none` when triage was a false positive or there are no real candidates.

   **Per-worker prompt:** `MB`, `BASE_BRANCH`, single `path`, **absolute paths** to this skill and **`organize-file/SKILL.md`** (required when skills live outside the repo), repo root if useful. Require the worker completion shape (below). Prefer **`git grep`** / **`grep`** over assuming `rg` on PATH.

6. **Reply**

   - Finished (all workers succeeded, or none needed): **exactly** `complete`—no prose, markdown, table, recap, or code fence.
   - Worker failed: **one** plain line for that failure (not `complete`).
   - Could not finish (e.g. cannot spawn): **one** plain line for the blocker (not `complete`).

### Placement (workers — read before moving)

- **`git diff` shows *what* changed, not *where* definitions belong.** Never place candidates together because the PR added them adjacently, they sit in one patch hunk, or they call each other.
- **Global slots:** Enumerate **every** `def` / `defp` / `defmacro` (and every `describe` / `test` in tests) in **organize-file** order for the whole module. Each candidate goes in the slot that full list dictates—as if organizing the entire file from scratch. Neighbors are often **non-candidates** far from the diff hunk.
- **Plain modules — `defp`:** Merge **all** `defp` names (candidates + non-candidates), sort **lexicographically**, file order must match that list. If `interpolate_variables` sorts between `check_campaign_limit` and `lock_account_and_check_campaign_limit`, it **must** sit between them in source—never stack branch `defp`s and skip intervening names. **Call graph does not override** sort order.

### Candidates

**Elixir:** `def`, `defp`, or `defmacro` is a candidate vs merge-base when **any** of: function **name** differs; **arity** differs; **clause heads** differ (parameter/binding names or other head text)—treat **all clauses of the same name+arity** as one movable unit. Name+arity **removed and replaced** → rename = remove + add; place the **new** name only.

**Tests:** `test "…"` or `describe "…"` whose **string literal** is new or meaningfully renamed (use diff judgment for tiny edits).

**Not** a candidate: same name, arity, and clause heads as merge-base with only body, typespec, attribute, whitespace, or comment changes.

### Per-file worker (subagent only)

Parent must **not** run this sequence. **Read in order:** (1) this skill—placement, candidates, steps below, anti-patterns, completion shape; (2) **organize-file** for ordering law. Do not rely on a short Task summary alone.

1. **Confirm diff** — `git diff "$MB" -- "<path>"`. Empty and `git show "HEAD:<path>"` equals merge-base → no branch delta (if unstaged-only matters, also `git diff -- "<path>"` vs index).

2. **Build candidate set** — Inventory `$MB:<path>` vs **working tree** (prefer on-disk file when uncommitted changes exist). Per **name/arity** unit: name or arity change → candidate; else compare each clause head. Use `git diff "$MB" -- <path>` for rename vs delete+add, test title changes, head-only edits.

3. **Classify** — `Phoenix.LiveView`, `Phoenix.LiveComponent`, plain module, or `*_test.exs`; apply matching **organize-file** section.

4. **Compute global slots** — Full-module ordered list (step 3 + **Placement**). Plain `defp` region: merged lexicographic name list, **not** “candidate names only.” Per candidate, record block (first line through `end`) and **global** neighbors in that list. **Sanity check:** no two consecutive planned candidates with another `defp`/`def` name that should sit between them.

5. **Edit** — Move whole candidate units only; preserve bodies and non-definition code. Apply **global** slots only—not minimal shuffle keeping branch defs clustered. Re-inventory after edits; plain modules: `defp` order matches merged list. **Clause order** per organize-file where pattern match order is safe. Already between correct global neighbors → do not move (still fix intra-unit clause order if required).

6. **Completion message**

   ```text
   path: <path>
   candidates: <names or test titles>
   actions: <moved | reordered clauses | already correct | none>
   notes: <optional: e.g. ambiguous rename>
   ```

### Definition inventory

```bash
# Working tree — defs
grep -E '^\s*(def|defp|defmacro)\s+[a-zA-Z_?!]' -- "<path>" || true
git show "$MB:<path>" 2>/dev/null | grep -E '^\s*(def|defp|defmacro)\s+[a-zA-Z_?!]' || true

# Tests
grep -E '^\s*(test|describe)\s' -- "<path>" || true
git show "$MB:<path>" 2>/dev/null | grep -E '^\s*(test|describe)\s' || true
```

Line-based grep can miss rare multiline heads; use **`git diff`** when inconclusive.

### Anti-patterns

- **Orchestrator:** edit sources, pass `model` on `Task`, or success replies other than **`complete`** (except single-line failure/blocker cases).
- **Worker:** skip reading full **organize-changes** then **organize-file**; treat every changed line as a candidate; move **non-candidates**; cluster candidates by branch/diff/call graph; sort **only candidate** `defp` names; minimal shuffle in the wrong file region; move units already in the correct global slot (except allowed clause reorder).
- **Both:** paths outside merge-base…HEAD ∪ working tree (unless user gave one path); destructive git (`reset`, `checkout --`).

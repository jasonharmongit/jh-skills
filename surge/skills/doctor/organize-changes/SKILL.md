---
name: organize-changes
description: Reorder branch-touched defs/tests into organize-file slots (orchestrator triages only; subagents apply edits; orchestrator ends with exactly `complete`, no summary)
---

### Preconditions

- **Ordering law**: Read **`skills/organize-file/SKILL.md`** before moving code; placement always defers to it (including LiveView lifecycle, `describe`/`test` clustering, and **do not reorder clauses** when that would change pattern match order).
- **Single path**: If the user gives one file path, only that file is in scope; merge-base comparison still applies.

### Orchestrator edit policy (non-negotiable)

- The agent running this skill as **orchestrator** performs **triage, git inspection, and launching workers only**. It **must not** edit any `*.ex` / `*.exs` file (or otherwise apply reorders) in its own turn.
- **Every** path that needs organize work—including **exactly one** path—must be handled by a **subagent** (e.g. Cursor **`Task`** with **`generalPurpose`** or equivalent). There is **no** “small enough to do inline” exception.
- If triage yields **zero** paths, the orchestrator still does **not** edit sources; it finishes and replies to the user with **exactly** `complete` (see step 6).
- If a subagent cannot be spawned (tool unavailable, policy block, etc.), the orchestrator **stops**, replies with **one line** stating that blocker only, and **does not** substitute by editing files itself. (That reply is **not** `complete`.)

### Global placement (workers — read before moving)

- **Merge-base / `git diff` shows *what* changed, not *where* definitions belong.** Never place or keep candidates together because they were added in one PR, sit next to each other in the patch, or call each other. That is **wrong**.
- **Each candidate’s target location is its proper place in the whole file** per **organize-file**: build the ordered list of **every** `def` / `defp` / `defmacro` (and every `describe` / `test` in tests) in that module, then put each candidate in the slot that list dictates—**global** order, same as if you were organizing the entire module from scratch.
- **Candidates may land far apart.** Example: several new `defp`s belong in different alphabetical (or lifecycle) positions; do **not** leave them stacked above `interpolate_variables` (or any unrelated neighbor) just so “branch changes stay together.”
- **Plain modules (`defp`) — mechanical merge, not a “candidate stack”:** Per **organize-file**, private functions are last and **alphabetically by function name**. Take **every** `defp` name already in the file (including non-candidates), add **each** new/changed candidate name, then sort **that whole set of names lexicographically** (string order on the function atom). The **file order of `defp` units must match that merged sorted list**. If name `interpolate_variables` sorts **between** `check_campaign_limit` and `lock_account_and_check_campaign_limit`, then the **`interpolate_variables`** definition (non-candidate) **must sit between** those two in the source—**never** place `lock_…` and `put_…` directly under `check_…` and skip over names that belong in between. Same rule for any other gap in the sorted list.
- **Call graph does not override sort order.** `put_campaign_limit_check` calling `lock_account…` does **not** mean those two may be adjacent if other `defp` names sort between them.

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

   If `main` does not exist locally, use `origin/main` or the repo’s default integration branch. Record the chosen `$BASE_BRANCH` only for use in `git` commands and worker prompts (not for a user-facing write-up).

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

   - **Dispatch a subagent (in step 5)** when the diff shows edits on or immediately adjacent to any **`def` / `defp` / `defmacro` clause head** or any **`test` / `describe`** line—including **parameter renames** on an unchanged function name (usually `+`/`-` on the same head line). The orchestrator still does **not** edit the file during triage.
   - **Skip** when the only edits are clearly **outside** definition heads and titles (e.g. only inside a function body, typespec-only, comments-only, or non-definition data)—the worker’s “not a candidate” rule is the final word if triage is ambiguous.

   Do **not** use **name-only** inventory (set subtract of `def` names) as triage: it **misses** param-only head changes. Name/head comparison belongs in **step 2 of the per-file worker**, after you have opened the diff.

   If **no** path survives triage, spawn **no** workers; continue to step 6.

5. **Execute per-file work (subagents only)**

   After triage, the orchestrator **only** launches **one implement subagent per remaining path** (one module ≈ one file)—including when **only one** path remains. The orchestrator **does not** open those files to reorder definitions or tests itself.

   Each worker must **only** edit its assigned path; paths are disjoint, so **run those tasks in parallel** whenever more than one path remains (no cross-file edit conflict). A worker may finish with **no** moves (`actions: none`) when triage was ambiguous or there were no real candidates. Wait until every spawned worker has finished (success or failure) before step 6.

6. **Orchestrator reply to the user**

   - If the run **finished** (all intended workers **succeeded**, or **no** workers were needed after triage): reply with **exactly** the ASCII word `complete`—no table, no bullet list, no `BASE_BRANCH` / `MB` recap, no prose before or after, no markdown, no code fence around it.
   - If a spawned worker **fails** (error, timeout, etc.): **one** plain line stating only that failure (not `complete`).
   - If the run **could not finish** (e.g. cannot spawn a worker): **one** plain line describing only that blocker (not `complete`).

### Per-file worker (subagent only) — exact sequence

The **parent/orchestrator must not** perform this sequence on the codebase itself; it is **only** for the **subagent** assigned to one path.

**Required reading for the worker (in order)**

1. **Organize-changes** — the **`organize-changes/SKILL.md`** skill itself (orchestrator passes **absolute path** if the skill lives outside the repo). The worker follows **this document** for: **Global placement**, what counts as a **candidate**, **steps 1-6** below, **anti-patterns**, and the **completion message** shape. Do not rely only on a short summary in the Task prompt.
2. **Organize-file** — **`surge/skills/doctor/organize-file/SKILL.md`** (orchestrator passes **absolute path**). Ordering and placement **always** defer to it (see Preconditions in organize-changes).

Give the worker at minimum: `MB` hash, `BASE_BRANCH`, **single `path`**, **absolute paths** (or stable repo-relative paths) to **both** skill files above, and the repo root if useful for `git` commands.

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

4. **Compute target slots (global — whole module)**

   - Enumerate **every** `def`, `defp`, `defmacro`, and (in tests) every `describe` / `test` in the file in **organize-file** order—not only candidates. This list is the **single source of truth** for where each definition **must** sit in the file.
   - For **plain modules**, for the `defp` region: derive the target order by **merging all `defp` function names** (candidates + non-candidates) into one set and sorting **lexicographically by name** per organize-file. **Do not** sort “only the candidate names” and paste that block into the file—that reproduces the bug where helpers stay stacked and skip over names that belong between them.
   - For each **candidate**, find its **global** slot in that full list (by function name / arity / module kind rules in **organize-file**). Record the **function or test block** (first line through closing `end`) and the **immediate neighbors** it must sit between **in that full list**—those neighbors are often **non-candidates** and may be nowhere near the diff hunk where the branch first introduced the code.
   - **Do not** anchor placement to “where the diff put it,” “next to another candidate,” or “near `interpolate_variables` / the last edit.” If the correct global neighbors differ from where the branch left the code, **move** the candidate to the correct neighbors.
   - **Sanity check before step 5:** For every pair of candidates that ended up **consecutive** in your planned order, confirm **no** other `defp` (or `def`, if applicable) name from the merged sorted list should appear **between** them. If something should appear between them, your plan is wrong—fix it.

5. **Edit**

   - Move **whole** candidate units only; preserve bodies and non-definition code.
   - Apply **only** the moves implied by step 4’s **global** slots—**not** a minimal shuffle that keeps branch-touched defs in one block.
   - **After edits**, re-run a `defp` / `def` inventory on the file and confirm order matches step 4’s merged list (plain modules: **lexicographic `defp` names** in the private region, per organize-file).
   - **Clause order** inside a candidate: apply **organize-file** only where it does **not** violate “do not reorder clauses when it would change which pattern matches.”
   - If a candidate is **already** between the correct **global** neighbors (per step 4’s full list), **do not** move it; still fix **intra-candidate** clause order if required.

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

- **`Task` tool (required for applies)**: For **each** path that survives triage (count ≥ 1), spawn **`generalPurpose`** (or equivalent) **once per path**, each prompt scoped to **that file only**. The orchestrator uses **`Task`** for the **sole** surviving path the same as for many paths—it **never** applies edits in the parent chat.
- **Parallelism**: When **more than one** path survives triage, launch those tasks **in parallel** (disjoint files → no edit conflicts). A single path is still a **single** `Task`, not parent edits.
- **Prompt pack for each implement task**: Include `MB`, `BASE_BRANCH`, the **path**, **paths or links to both skills**—**`organize-changes/SKILL.md`** (this skill; worker must read it for candidates, steps, anti-patterns, completion block) and **`organize-file/SKILL.md`** (ordering law)—and the **required worker completion shape**. The worker still opens **organize-changes** for the full **Per-file worker** section; the prompt is not a substitute.
- **Do not** assume `rg` is on PATH in sandboxes; prefer **`git grep`** / **`grep`** as documented.

### Anti-patterns (orchestrator and workers)

- **Orchestrator: do not** edit source files to reorder defs/tests or “just fix” one file; that is always a worker’s job (**subagent-only applies**).
- **Orchestrator: do not** reply with tables, path lists, `BASE_BRANCH` / `MB` recaps, or any success summary—only **`complete`** per step 6 (except the single-line failure cases in step 6).
- **Worker: do not** treat the orchestrator’s Task blurb as sufficient; **read** **`organize-changes/SKILL.md`** in full for this workflow, then **organize-file** for ordering.
- Do not treat **every** changed line as a candidate; only **head-level** changes count: new/renamed **function** name, **arity**, **clause-head** text (including **parameter / binding names**), or new/renamed **test**/**describe** titles—not arbitrary body edits.
- Do not reorder definitions that differ from merge-base **only** inside the `do`…`end` body (or typespecs/attributes only), with an otherwise identical head.
- Do not **move non-candidates** to “clean up” the file.
- **Worker: do not** keep candidates **clustered** or **adjacent** because they were introduced on the same branch, appear together in **`git diff`**, or call each other; each candidate belongs in its **organize-file global** position among **all** definitions in the file (see **Global placement** above).
- **Worker: do not** build a **sorted block of only candidate names** and paste it into the file—that skips non-candidates whose names fall **between** candidates in lexicographic order (classic bug: `check_…`, `lock_…`, `put_…` stacked with `interpolate_variables` wrongly skipped).
- Do not apply **minimal** reorder that only sorts candidates among themselves while they remain in the **wrong global region** of the file.
- Do not move a candidate that is **already** in the correct global position (except allowed **clause** reorder inside that unit per organize-file + pattern safety).
- Do not pull in paths **outside** the union of merge-base…HEAD and working tree (unless user gave an explicit path).
- Do not run destructive git commands (`reset`, `checkout --`) as part of this skill.

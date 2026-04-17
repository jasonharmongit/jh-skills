---
name: doctor
description: Runs pre-PR formatting, checking and testing.
---

## Per-step execution loop

For every step, follow this exact order:

1. Announce the step.
2. Run the step and fix failures until it passes.
3. Give a very brief report of changes made in that step.

Example announce line:

**Doctor: Step 3/4 - mix check**

Example report line:

**Step 3 report:** `lib/surge/foo.ex` - removed unused alias; wrapped side effect in `after` callback.

---

## Step 1 - Organize functions

Read and apply the **organize-elixir-functions** skill from `~/.agents/skills/organize-elixir-functions`. Unless the user specifies otherwise (rare), you should apply it in `branch mode`

---

## Step 2 - Format

~~~bash
mix format
~~~

One `mix format` run applies all formatting the tool can do; a second pass is only needed if the first run failed (for example syntax errors) or you changed files after formatting.

---

## Step 3 - `mix check`

~~~bash
mix check
~~~

---

## Step 4 - Compile and tests

**In scope ("this branch"):** paths from `git diff --name-only "$(git merge-base HEAD main)"...HEAD` **and** `git status --short` (staged + unstaged). Nothing else.

**Run `mix test` only as:** explicit `*_test.exs` file arguments (one or more files). **No** bare `mix test` (forbidden unless user explicitly asked for full suite in plain language). **No** directory args (`test/`, feature folders, `apps/.../test/`) unless that **exact** directory path is in the branch list. **No** extra files, neighbors, tags, or repo-wide runs. **No** invented broader coverage if a changed `lib/` file has no counterpart test—use (1) only or ask.

**Which test files:** (1) `*_test.exs` appears in branch list, or (2) conventional counterpart of a changed `lib/...` module (same path stem only—not sibling tests). **Edits:** only those same files, and only branch-related cases—**no** touch to any other test file (including format-only / "cleanup"). **Empty list** → skip `mix test`; do **not** substitute full suite or a folder.

**Which failures to fix:** **Per case** (`test` / `describe` / example)—only if it clearly maps to a changed branch path or behavior. **Ignore** all other failures, including other cases in the same file (leave reds; no prod/test edits to clear them). Unsure → ask, do not edit. Optional noise reduction: `mix test path/to/file.exs:LINE` for branch-related lines only—still **never** fix unrelated failures.

**Compile:** `mix compile --warnings-as-errors` until clean.

~~~bash
mix compile --warnings-as-errors
mix test test/my_app/widgets/foo_test.exs
~~~

**Branch-related red:** prefer tightening **that case** (assertions, fixtures, expected values) over weakening prod. **If prod change looks wrong / suspect / bad tradeoff** → stop and ask before changing application code to green a test.

---

## Notes

- If you get stuck in any loops or complex problems that you are having to make large or risky changes for, stop and ask the user for help.
- Doctor is **not** a green-the-whole-repo pass: it is **compile + only branch-tied test files + only edits to branch-related test cases** inside those files (other cases in the same file can stay red). Anything broader is a mistake.
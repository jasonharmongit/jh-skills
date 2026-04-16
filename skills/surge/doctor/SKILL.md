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

### Tests relevant to the branch

1. List branch-changed paths (include uncommitted work): `git diff --name-only "$(git merge-base HEAD main)"...HEAD` plus `git status --short` for unstaged paths.
2. Prefer running `mix test` with specific files or directories that correspond to changed application code (e.g. `test/...` files touched, or inferred paths under `test/` for changed `lib/` modules).

~~~bash
mix compile --warnings-as-errors
mix test
~~~

Fix compile warnings until `mix compile --warnings-as-errors` passes.

When tests fail, prefer updating the tests to match the current application behavior (assertions, fixtures, expected values) rather than changing production logic just to satisfy a test.

If a failure suggests the branch behavior might be wrong, unintentional, or a bad tradeoff, stop and ask the user before you change any application logic to make a test pass. Do not just "fix" production code to green a test when the underlying change looks suspect.

---

## Notes

- If you get stuck in any loops or complex problems that you are having to make large or risky changes for, stop and ask the user for help.
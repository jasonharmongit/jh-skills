---
name: doctor
description: Runs pre-PR formatting, checking and testing.
---

## Per-step execution loop

For every step, follow this exact order:

1. Announce the step.
2. Run the step and fix failures until it passes.
3. Give a very brief report of changes made in that step.
4. If changes were made in that step, pause and await user review before continuing.

Example announce line:

**Doctor: Step 3/4 - mix check**

Example report line:

**Step 3 report:** `lib/surge/foo.ex` - removed unused alias; wrapped side effect in `after` callback.

Example pause line:

Awaiting user review. Just say 'next' to proceed.

---

## Step 1 - Organize functions

Read and apply the **organize-elixir-functions** skill from `~/.agents/skills/organize-elixir-functions`. Unless the user specifies otherwise (rare), you should apply it in `branch mode`.

When determining which files changed on the branch for that step, use the same baseline as Step 4: **`git merge-base HEAD origin/main`** (not local `main`), so candidate detection matches the remote default branch.

Then stop. Wait for the user's approval to proceed to the next.

---

## Step 2 - Format

~~~bash
mix format
~~~

One `mix format` run applies all formatting the tool can do; a second pass is only needed if the first run failed (for example syntax errors) or you changed files after formatting.

Then stop. Wait for the user's approval to proceed to the next.

---

## Step 3 - `mix check`

~~~bash
mix check
~~~

Then stop. Wait for the user's approval to proceed to the next.

---

## Step 4 - Compile and tests

- **!!!ABSOLUTELY CRITICAL RULE!!!:** bare `mix test` is **never allowed under any circumstances whatsoever**.

- **Scope only:** branch-changed paths from `git diff --name-only "$(git merge-base HEAD origin/main)"...HEAD` + `git status --short`.
- **Test run shape:** only explicit `*_test.exs` file args. No directory args. No repo-wide runs. No "extra confidence" runs.
- **Allowed files only:** test file in branch diff, or direct counterpart of changed `lib/...` module (same path stem). No sibling or neighbor tests.
- **Empty allowed list:** skip this step.
- **CRITICAL - Fix scope is per test case, not per file:** only fix a failing case when it is **DIRECTLY** related to branch application-code changes. Other failures in same file: ignore, leave red.
- **No out-of-scope edits:** no changes to unrelated test cases, unrelated test files, or production code for unrelated failures.
- **Pre-edit gate (required):** before any test file change, announce the exact test-case edit you plan to make and cite the specific app-code path + branch diff hunk that directly justifies touching that case. If you cannot cite that evidence first, do not edit.
- **Final report requirement for any file change:** include strong evidence for each changed test case - exact failing case, exact changed app-code path, and exact direct relationship. If you cannot prove that, do not edit.

~~~bash
mix compile --warnings-as-errors

# optional:
mix test <file path>
~~~

---

## Notes

- If you get stuck in any loops or complex problems that you are having to make large or risky changes for, stop and ask the user for help.
- Doctor is **not** a green-the-whole-repo pass: it is **compile + only branch-tied test files + only edits to branch-related test cases** inside those files (other cases in the same file can stay red). Anything broader is a mistake.
- REMINDER - bare `mix test` is **never allowed under any circumstances whatsoever**.
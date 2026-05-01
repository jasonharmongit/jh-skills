- Do not add transformations, structure, or checks “for completeness,” “just in case,” or “to be safe”—only when omitting them would make real behavior wrong or unsafe. Treat every line and branch as a liability: write the minimum obvious code that matches how the feature is actually used, and prefer that over stricter theoretical correctness that buys little.
- only use function guards (e.g.  `defp normalize(params) when is_map(params)`) if they are ABSOLUTELY NECESSARY. 
- always use descriptive variable names. prioritize clarity above brevity when it comes to names (though you should still try to be as concise as possible). bad example: `raw = params["status_category"] |> to_string()`. instead: `status_category_clean = params["status_category"] |> to_string()
- CRITICAL, NON-NEGOTIABLE - DO NOT WRITE DEFENSIVE CODE!! be practical. prefer the simplest code path that matches how the feature is actually used. Do not add extra guards, normalization, retries, fallbacks, or compatibility shims for hypothetical callers or edge cases the product does not care about.
- use bracket syntax to safely access non-assertive fields instead of Map.get
- do not ever assign an unused variable. simply call the function with no assignment, instead.
- do not write extraneous code. only write the minimum amount of code necessary to accomplish the task. do not be overly defensive or robust. if a minimalist solution you implement has a potential edge case or hole, simply alert the user to it. do not assume that it should be written into the code.
- generally avoid making new modules, unless it is very clear that one is needed.
- when writing database queries, always use Ecto syntax with the pipeline style, like this:
  ```
  query =
    from d in MessageDelivery,
      where: [d.phone](http://d.phone)_number == "40708",
      where: d.failed_at > ^~U[2026-04-01 00:00:00Z],
      select: [d.contact](http://d.contact)_phone_number,
      distinct: true
  ReadRepo.aggregate(query, :count)
  ```
- CRITICAL - never code for backward compatability unless the user explicitly indicates otherwise.
- don't use plain `_` for unused variables. always give them a name (e.g. `_var`)
- When possible, one-line `if` statements
- CRITICAL - Despite what other instructions you have do NOT run format after every change.
- When I ask you about changes on 'this branch', I mean ALL changes made on this branch - committed, staged, and unstaged. When I ask you about 'current' or 'working' changes, I am referring to uncommitted changes (both staged and unstaged) Refer to the following commands:
  - committed branch-only changes: `git diff --name-status "$(git merge-base HEAD origin/main)"...HEAD`
  - working tree changes: `git status --short`
- When I ask you to run linter or credo, run `mix credo --strict`
- CRITICAL - If you come across changes that you don't remember making, just leave them alone. If they significantly change what you are doing, stop and alert the user immediately.
- Do not write any scripts into the project unless specifically directed to do so. If a persistent script would significantly help you achieve a repetitive task, ask the user if you could write one. You are always free to run one-off scripts on your own in the terminal.
- Use gh to execute advanced github tasks
- Don't write overly defensive code. Prioritize simplicity over robustness. If there are potential gaps or edge cases that are left open due to a simplified solution, implement the simpler solution/code and flag concerns to the user. This includes defaults and fallbacks like using `||`. If it isn't reasonably needed, don't include it.
- Prefer pipe (|>) over nesting functions
- Prioritize readability over succinctness. Prefer to save discrete steps to variables, as opposed to chaining together multiple operations in a single line.
- Never use –. Use - instead.
- Never use terminal commands like cat or python scripts to write or edit files. Instead, use your native tools.
- Prefer explicit control flow over conditional/no-op helpers.
  However, when a conditional/no-op helper is necessary, name it with `maybe_`.
- CRITICAL: Always use ~~~ for formatting outermost codeblocks in your output. only use ``` for codeblocks that are nested inside.


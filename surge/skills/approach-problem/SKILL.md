---
name: approach-problem
description: Produce named strategic options with file/line estimates and pros/cons.
---

Do not modify application code, tests, configuration, or project assets while this skill governs the turn. This is strictly an investigatory, introspective, and discussion-oriented workflow.

When this step runs under the `solutionize` skill, follow that skill for when and how to persist output.

## 2 - Approach problem

**Output of this step:** a small set of **named options** (one is fine). For each option include:

- A very short, plain-language description of the option at a high level (1-2 sentences).
> **Est. changed files count:** <range, e.g. 3-5>
> **Est. changed lines count:** <range, e.g. 80-140>
> **Pros:** exactly one sentence.
> **Cons:** exactly one sentence.

When there are multiple options, always structure them as **Option A, Option B, Option C, ...** and make **Option A** your most recommended path.

For every option after A, describe only the **differences from Option A**. Do not restate behavior, assumptions, or mechanics that remain the same as Option A.

Do **not** here: ordered implementation phases or per-file step lists (those belong in the sketch-solution step). Do not explain how to read file or line counts.

Stay at strategy level, not syntax-level plans. Keep option text plain and brief. Do not include deep implementation details, long parameter discussions, or edge-case policy decisions in step 2.

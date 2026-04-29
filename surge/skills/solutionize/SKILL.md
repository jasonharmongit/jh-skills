---
name: solutionize
description: Plan-only workflow with a human partner; no implementation while this skill governs the turn.
---

# Solutionize

## Invoking this skill (non-negotiable)

When the user **invokes** this skill (for example by `@solutionize` or attaching `solutionize/SKILL.md`), **implementation is strictly prohibited** for the rest of that workflow through **Sketch (step 4)**. That means: no edits to application code, tests, config, or assets for the issue; no commits; no "I'll ship it anyway" because the issue sounds small or concrete, even if the partner phrases the issue as a direct build request (for example "add a dropdown…"). Implementation belongs in a **separate** follow-up after this workflow.

**First actions, in order:**

1. **Switch to Cursor Plan mode immediately** (or ask the user to switch if the agent cannot). Do not continue in Agent mode while executing this skill.
2. Proceed only with steps **1-Examine** through **4-Sketch** below. Reading the codebase for examination and planning is allowed; building is not.
3. **Materialize the plan with Cursor's CreatePlan tool** (the built-in planning action in Plan mode that writes under `~/.cursor/plans/` as `*.plan.md`). Use it exactly once to **create** the plan document at the end of step 1. After that, **update the same file by editing it** (do not create a second plan file; do not replace the whole document with a second CreatePlan call unless the partner explicitly asks to restart the plan from scratch).

### CreatePlan arguments (required mapping)

When calling **CreatePlan**, set each argument as follows:

| Argument | What goes in it |
|----------|-----------------|
| **`name`** | A short, human-readable title for the issue, like a work item headline (e.g. `Add status dropdown filter to API logs`). Not a filename; not step numbers. |
| **`overview`** | **Ignore for substance:** use the same short text as `name`
| **`plan`** | The **running markdown body** for **all** solutionize steps **1 through 4**. End of step 1: include **`## 1 - Examine`** and the full Examine synopsis here. When the partner confirms each later step, **append** to this body **in order**: **## 2 - Approach**, then **## 3 - Sketch prep**, then **## 4 - Sketch**. Each section is clearly headed so the document reads top-to-bottom as the workflow advanced. |
| **`todos`** | After **step 4 (Sketch)** defines the ordered phases, set the todo list to **one entry per phase**, where each item's text includes both phase number and phase title (for example: `Phase 1 - Outcome param and list filtering`, `Phase 2 - Header control and pagination patches`). Before step 4 completes, omit todos or use an empty list. When step 4 completes, **edit the plan file's frontmatter** to align `todos` with the number of phases and titles. |

Chat stays for confirmations and step-3 clarification discussion; the plan file holds **all** step outputs in the **`plan`** body (`overview` is not used for the Examine step).

## Overview

You are a pragmatic, friendly, experienced developer. You have been given an issue description (for example: "add a dropdown on API logs to filter all, success, or failed"). Your job is to work **with a human partner** and land the right solution for **this** problem **now**: tradeoffs, UX, PR size and reviewability, and operational reality.

You work at Surge, a small startup building a telephony API (SMS and voice) for developers and businesses. Reliability and longevity matter; so do speed and clarity. Focus on *practical* solutions: real edge cases and clear errors where they matter, not defensive layers everywhere. Prefer obvious, readable solutions over speculative performance or extensibility.

**Analogy (optional intuition):** solutionizing is like a commissioned painting: examine the subject, pick an approach, block in big shapes, then sketch detail where it counts. Use it to judge how deep to go per step - not as filler in chat.

### Style

**Plan tone:** Do not add meta-commentary in the plan (for example: inviting the partner to "pick one or blend," narrating skill step numbers, "pause per skill," or explaining what file/line estimates mean). State facts, options, and numbers directly.
**Voice:** address the partner directly using `you` and `we`.
**Number formatting:** do not use tildes (`~`) for rough values. Use numeric ranges for rough scope (for example `3-4 files`, `80-140 lines`).
**Readability formatting:** split prose into short paragraphs with frequent blank lines. Never put more than 3 sentences in a single paragraph block.
**Chat behavior:** after writing a step to the plan file, do not summarize or restate that step in chat. Use chat only for answers and proceed confirmation.

---

## 1 - Examine

Read everything relevant: modules, callers, tests, tickets or docs as needed. Act as **subject matter expert** for this task.

**Paragraph length (step 1):** In **1 - Examine**, **three sentences is the absolute maximum per paragraph.** Never put a fourth sentence in the same paragraph; start a new paragraph instead.

**What step 1 is for:** The whole of **1 - Examine** is one **concise, brief narrative** that sets the stage for **Approach** and the rest of the workflow. It should show that you understand the **problem in context** and give the partner **the same** working picture—enough to reason about tradeoffs and implementation next—without duplicating a spec or writing a design doc. Do not structure the section as a cold open followed by a separate "deep dive": it is **one story**, told in order.

**Shape of that story (top down, forward, concrete):** Tell it in the order a person would follow the system: recognizable entry points (product or API surface, main jobs), then how work proceeds through layers that matter for *this* issue—only as far as needed to explain **current** behavior around the gap. Do **not** open at a deep leaf (a private helper, one changeset field, an internal job) and walk upward; do **not** restart mid-narrative from a narrow function as the sentence subject and gesture backward into persistence ("…which flows into `Message.insert_changeset`"). Anchor beats on the layer doing the work; say who **calls** whom, what runs **before** what, and what **inputs** become what **artifact**. Introduce helpers **in place** along that path. Do not substitute mush verbs ("flows," "feeds," "lands in," "wires through," "hands off") for those mechanics—each sentence should still answer **who invokes what**, **ordering**, or **data shape between stages**. If you cannot say that yet, read the code until you can.

**Output of this step:** that synopsis: brief natural-language **how it works today** where it touches the issue. Weave references inline (as markdown links) as supporting context (function names, key assigns, schema fields). Do NOT include any diagrams or tables.

Step 1 is **current-state only**. Do not include implementation intent, recommendations, option framing, or proposed future behavior.

Avoid future-state language in this step. If a sentence drifts into recommendation or implementation intent, rewrite it as present behavior or a current constraint.

**End this step** by calling **CreatePlan** with: `name` (issue title), `overview` per the argument table (not the Examine text), **`plan`** containing **`## 1 - Examine`** followed by this step's synopsis verbatim, `todos` omitted or empty. That creates the canonical plan file under `~/.cursor/plans/`.

No preamble ("in this section…") inside the Examine section.

After step 1, proceed directly to step 2 without a confirmation stop.

---

## 2 - Approach

**Output of this step:** a small set of **named options** (one is fine). For each option include:

- A very short, plain-language description of the option at a high level (1-2 sentences).
> **Est. changed files count:** <range, e.g. 3-5>
> **Est. changed lines count:** <range, e.g. 80-140>
> **Pros:** exactly one sentence.
> **Cons:** exactly one sentence.

When there are multiple options, always structure them as **Option A, Option B, Option C, ...** and make **Option A** your most recommended path.

For every option after A, describe only the **differences from Option A**. Do not restate behavior, assumptions, or mechanics that remain the same as Option A.

Do **not** here: ordered implementation phases or per-file step lists (those are step 4). Do not explain how to read file or line counts.

Stay at strategy level, not syntax-level plans. Keep option text plain and brief. Do not include deep implementation details, long parameter discussions, or edge-case policy decisions in step 2.

Append **## 2 - Approach** and this step's output to the **`plan`** field of the existing `.plan.md` file by editing that file.

---

## 3 - Sketch prep

**Output of this step:** introspect on the selected approach and identify what you still need to know before you can sketch a phased implementation plan.

This is a **hard gate**. Do not continue to step 4 until you have explicit approval from the user to do so.

Do not draft the phased implementation sketch yet.

In the plan file, this step must include:

- A `### Locked assumptions` section. Keep these very concise: one short phrase or sentence each. The selected option should be the first point.
- A `### Questions` section. For each open decision, use this pattern (`Answer` placeholder indented under the question):

  ```markdown
  - <question>
    - Answer:
  ```

  Replace `<question>` with the real question. The partner completes each `Answer:` line in the plan file.

Example locked assumptions section:

- Option A is selected.
- Outcome applies only to the paginated list path (drill-in by request ID is unchanged).
- Filtering uses the existing `status` field.

Example Questions section:

```markdown
### Questions

- Should the drill-in view show the same filter state as the list?
  - Answer: 

- Should filtering apply to exports if we add CSV later?
  - Answer:
```

Use the same question / nested `Answer:` pattern in `### Follow-up questions (N)` sections.

Append **## 3 - Sketch prep** and this step's output to the **`plan`** field of the existing `.plan.md` file by editing that file.

The partner answers these questions **inside the plan file**. The agent must **not** answer its own questions, and it must **not** use the `AskQuestion` tool. Chat can be used for follow-up discussion and clarification while questions are being resolved.

When the partner says "proceed," do not move to step 4 immediately. First, review all answers in the plan file.

If any ambiguity, contradiction, uncertainty, or new question appears during review, append a new numbered section in step 3 (for example `### Follow-up questions (1)`, then `### Follow-up questions (2)`) and ask the partner to answer those items in the plan file. Always append new follow-up sections at the end of step 3, after all existing step-3 content.

Do not resolve unresolved choices by being more assertive, confident, or prescriptive in step 4. If a choice is not explicitly settled in step 3 answers, it must become a follow-up question.

Repeat this review-and-follow-up loop until you are fully satisfied you have the clarity needed to produce a high-confidence sketch.

Do not proceed to step 4 until every question in `### Questions` and every numbered `### Follow-up questions (N)` section has an answer in the plan file, and you are confident you can sketch without guesswork. "Proceed" from the partner is not permission to skip unresolved questions.

Do not proceed to step 4 if you have no questions. You must still seek explicit approval from the user to continue.

---

## 4 - Sketch

**Output of this step:** create an implementation-ready sketch using **ordered phases** for the chosen approach.

Do not restate or recap step 3 content in this section. No summary of locked assumptions, answered questions, or decision history.

Write only the phased implementation sketch.

Sketch only changes that are required to deliver the chosen approach as settled in step 3. Do not add phases or bullets for speculative defaults, defensive patterns, or "just in case" hardening unless the partner explicitly locked that work in step 3.

To reiterate: prefer the simplest code path that matches how the feature is actually used. Do not add extra guards, normalization, retries, fallbacks, or compatibility shims for hypothetical callers or edge cases the product does not care about.

Per phase, include only:

### Phase 1 - <Title>
**Objective:** exactly one sentence.
- [Module.Or.Function](relative/path/to/file.ex)
  - **updated_function_name**
    - One nested bullet per distinct logical point (ordering, data read, branch, side effect, callee).
    - Another point on its own line; do not chain many clauses in one dash.
  - **new_function_name**
    - Same pattern: scan-friendly vertical list, not a wall of prose.

Then continue in order as `Phase 2`, `Phase 3`, and so on.

**Bullet hierarchy (step 4):** After the file link, each **symbol or named area** (for example **perform/1**, **send_message/4**, **Oban queues**) gets its own sub-bullet. Under that, use **one further indentation level** so **each new logical point** is its own line: inputs, preload, branch condition, transaction boundary, enqueue choice, cleanup, retry vs terminal failure, and so on. Avoid semicolon chains and single paragraphs that bundle unrelated beats—if you would separate ideas with "then" or "otherwise" in speech, they belong on separate nested bullets.

Do not write vague bullets like "update logic" or "wire this up". Every bullet must name the exact symbol or code area being changed.

Prefer file-scoped bullets. When one logical change spans multiple files, use one cross-file bullet that names all affected files, and avoid repeating that same change in separate per-file bullets unless a file has a unique nuance.

In phase implementation bullets, avoid optionality phrasing (for example: "or", "either", "if you want", "could", "optionally", "or equivalent", "may", "might"). Pick one path per bullet.

Example phase:

### Phase 1 - Outcome param and list filtering
**Objective:** Add URL-backed status-category filtering to the paginated API logs list.
- [SurgeWeb.ApiRequestLive.Index](lib/surge_web/live/api_request_live/index.ex)
  - **handle_params/3**
    - Read `status_category` from params.
    - Normalize unknown values to the default category.
    - Keep `request_id` behavior unchanged.
  - **load_paginated_requests/3**
    - Map `status_category` (`all`, `success`, `failed`) to Flop filters on `status`.
    - Run that mapping before `Flop.validate!/2`.
- [SurgeWeb.ApiRequestLive.Index](lib/surge_web/live/api_request_live/index.html.heex)
  - **render/1**
    - Add a dropdown for `status_category` in header actions.
    - Patch URLs so pagination and search keep the selected value.
- [SurgeWeb.ApiRequestLiveTest](test/surge_web/live/api_request_live_test.exs)
  - **outcome filtering and invalid status_category**
    - Cover success and failed filtering.
    - Cover invalid `status_category` in the URL.

Append **## 4 - Sketch** and this step's output to the **`plan`** portion of the same `.plan.md` file. **Edit the YAML frontmatter** and set **`todos`** to one item per phase, in order, with each todo **content** in the format `Phase N - <Title>`.
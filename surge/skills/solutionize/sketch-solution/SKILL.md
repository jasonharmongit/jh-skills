---
name: sketch-solution
description: Phased implementation-ready sketch with objectives and symbol-level bullets.
---

Do not modify application code, tests, configuration, or project assets while this skill governs the turn. This is strictly an investigatory, introspective, and discussion-oriented workflow.

When this step runs under the `solutionize` skill, follow that skill for when and how to persist output (including separate artifacts if it defines them).

## 4 - Sketch solution

**Output of this step:** an implementation-ready sketch using **ordered phases** for the chosen approach.

Do not restate or recap the prepare-sketch step content in this section. No summary of locked assumptions, answered questions, or decision history.

Write only the phased implementation sketch.

Sketch only changes that are required to deliver the chosen approach as settled in the prepare-sketch step. Do not add phases or bullets for speculative defaults, defensive patterns, or "just in case" hardening unless the partner explicitly locked that work in the prepare-sketch step.

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

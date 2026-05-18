---
name: sketch
description: Phased implementation-ready sketch with objectives and symbol-level bullets.
---

Do not modify application code, tests, configuration, or project assets while this skill governs the turn. This is strictly an investigatory, introspective, and discussion-oriented workflow.

## 4 - Sketch

**Output of this step:** an implementation-ready sketch using **ordered phases** for the chosen approach.

Do not restate or recap the interview step content in this section. No summary of locked assumptions, answered questions, or decision history.

Write only the phased implementation sketch.

Sketch only changes that are required to deliver the chosen approach as settled in the interview step. Do not add phases or bullets for speculative defaults, defensive patterns, or "just in case" hardening unless the partner explicitly locked that work in the interview step.

To reiterate: prefer the simplest code path that matches how the feature is actually used. Do not add extra guards, normalization, retries, fallbacks, or compatibility shims for hypothetical callers or edge cases the product does not care about.

**Phase ordering:** Phases are executed **in order**. Nothing in an earlier phase may depend on work described only in a **later** phase.

- Earlier phases only introduce foundations later phases consume (migrations, schemas, contexts, APIs, workers, etc.).
- Later phases must not assume symbols, data, or behavior that earlier phases have not already established.
- Cross-phase references read forward in time only (Phase 2 may build on Phase 1; Phase 1 must not assume Phase 3 exists).
- **Tests last:** test files, test cases, and test-only work belong in the **final** phase—and only there. Earlier phases must not include test bullets.

**Default layering (bottom-up):** unless the chosen approach deliberately does otherwise, stack phases in this order:

1. Infrastructure and persistence (migrations, API layer, config, Oban/queues, external integrations)
2. Schema / domain models
3. Context and business logic
4. Web boundary (controllers, LiveViews, views, routes)
5. **Final phase only:** tests (and any polish that depends on completed implementation)

If the natural breakdown would violate ordering, **reshape phases** so dependencies flow downward—do not leave forward references.

Per phase, include only:

### Phase 1 - <Title>
**Objective:** exactly one sentence.
- [Module.Or.Function](relative/path/to/file.ex)
  - **handle_params/3** (existing symbol — use its real name)
    - One nested bullet per distinct logical point (ordering, data read, branch, side effect, callee).
    - Another point on its own line; do not chain many clauses in one dash.
  - **CopyVoicemailGreeting** (new symbol — use the concrete name you propose)
    - Same pattern: scan-friendly vertical list, not a wall of prose.

Then continue in order as `Phase 2`, `Phase 3`, and so on.

**Bullet hierarchy (step 4):** After the file link, each **symbol or named area** (for example **perform/1**, **send_message/4**, **Oban queues**) gets its own sub-bullet. Under that, use **one further indentation level** so **each new logical point** is its own line: inputs, preload, branch condition, transaction boundary, enqueue choice, cleanup, retry vs terminal failure, and so on. Avoid semicolon chains and single paragraphs that bundle unrelated beats—if you would separate ideas with "then" or "otherwise" in speech, they belong on separate nested bullets.

Do not write vague bullets like "update logic" or "wire this up". Every bullet must name the exact symbol or code area being changed. For an existing function, module attribute, or test case, use its actual name (for example **twiml_voicemail/2**). For a new function, worker, migration, or file, use the concrete name you are proposing (for example **Surge.PhoneNumbers.CopyVoicemailGreeting** or **presigned_voicemail_greeting_url/1**) — never generic placeholders like **new_function_name** or **updated_function_name**.

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

### Phase 2 - Tests
**Objective:** Cover status-category filtering and invalid URL values.
- [SurgeWeb.ApiRequestLiveTest](test/surge_web/live/api_request_live_test.exs)
  - **outcome filtering and invalid status_category**
    - Cover success and failed filtering.
    - Cover invalid `status_category` in the URL.

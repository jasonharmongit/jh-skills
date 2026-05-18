---
name: edit-sketch
description: >-
  Edit an existing solutionize sketch plan in place after discussion or
  partner feedback. Use when the user attaches a sketch file and asks to
  update, revise, or correct the phased plan without re-running sketch from scratch.
---

# Edit sketch

## Invoking this skill

The partner provides the **sketch file path** (for example a `Sketch: …` `.plan.md` under `~/.cursor/plans/`) and what should change—from this chat, prior discussion, or explicit instructions.

## Authority (non-negotiable)

You **must edit that sketch file in place** using your file-edit tools. This skill **overrides** plan-only rules, Agent vs Plan mode, and any other instruction that would block editing **this** sketch file. Do not create a replacement plan file or duplicate the sketch elsewhere unless the partner explicitly asks.

Do **not** edit application code, tests, configuration, or project assets while this skill governs the turn—only the sketch file (and its YAML frontmatter when present).

## What to change

Apply every logical change the partner requested or that was settled in discussion since the sketch was written. You may **rewrite large portions** of a phase or the whole sketch when logic demands it.

**Preserve sketch style:** match the existing document’s formatting, tone, and concise prose. Follow the same conventions as the **`sketch` skill** (symbol-level bullets, file links, one **Objective** per phase, nested bullets—not walls of prose). Do not introduce a different outline or voice.

**Do not expand structure:**

- Do **not** add new top-level sections to the sketch body (for example a new `##` block beyond what is already there).
- Do **not** add new `### Phase …` sections or new major subsections inside a phase.
- You **may** add, remove, or rewrite bullets **within** existing phases and sections.

## Holistic pass

Read the **entire** sketch before and after editing. A local fix in one phase often ripples to others—update every affected phase in one pass so the document stays internally consistent.

## Phase ordering (critical)

Phases are executed **in order**. Nothing in an earlier phase may depend on work described only in a **later** phase.

When editing, verify **every** phase:

- Earlier phases only introduce foundations later phases consume (migrations, schemas, contexts, APIs, workers, etc.).
- Later phases do not assume symbols, data, or behavior that earlier phases have not already established.
- Cross-phase references read forward in time only (Phase 2 may build on Phase 1; Phase 1 must not assume Phase 3 exists).
- **Tests last:** any test files, test cases, or test-only work the sketch calls for must live in the **final** phase—and only there. Earlier phases must not include test bullets. If edits introduce or scatter test work, **move** it into the last phase (merge into that phase’s bullets if needed).

**Default layering (bottom-up):** when reordering or reshaping work, prefer this stack unless the existing sketch deliberately does otherwise:

1. Infrastructure and persistence (migrations, API layer, config, Oban/queues, external integrations)
2. Schema / domain models
3. Context and business logic
4. Web boundary (controllers, LiveViews, views, routes)
5. **Final phase only:** tests (and any polish that depends on completed implementation)

If a requested change would violate ordering, **fix the sketch** (rewrite phases and bullets) so dependencies flow downward—do not leave forward references.

## Workflow

1. **Read** the sketch file end to end (body and frontmatter).
2. **List internally** what must change from the partner’s ask and from ordering/style rules above.
3. **Edit the sketch body in place**—phases, objectives, and bullets—until it matches the new logic and passes the ordering check. Do not touch YAML **`todos`** yet.
4. **Re-read** the sketch body once more for consistency, style, and phase dependencies.
5. **Reconcile `todos`** to match the phases after the edits.
6. **Report to partner**-do not paste the full sketch into chat. **After** body edits and todo reconciliation, give a **short** summary of what changed (which phases or themes moved) and call out any dependency reordering you did.

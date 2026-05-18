---
name: iterate-sketch
description: Ongoing mindset for refining an existing solutionize sketch plan in place.
---

# Iterate sketch

## What this skill is

This skill is **not** a one-time “apply these edits now” workflow. It defines how you should behave for the **rest of this conversation** while the partner is working through a sketch: keep the sketch file in focus, stay ready to update it in place when something is settled, and hold the rules below as you discuss—even when the partner has nothing to change yet.

The partner may only be exploring, reacting to feedback, or narrowing scope across several turns. **Do not** assume every message includes a concrete edit list. When they do settle a change (explicitly or by agreement in discussion), apply it to the sketch file then—not by re-sketching from scratch.

## Invoking this skill

The partner provides the **sketch file path** (for example a `Sketch: …` `.plan.md` under `~/.cursor/plans/`). They may also say what should change, or they may only open the sketch for iteration—carry the path and this mindset forward either way.

## Authority (non-negotiable)

When sketch edits are needed, you **must edit that sketch file in place** using your file-edit tools. This skill **overrides** plan-only rules, Agent vs Plan mode, and any other instruction that would block editing **this** sketch file. Do not create a replacement plan file or duplicate the sketch elsewhere unless the partner explicitly asks.

Do **not** edit application code, tests, configuration, or project assets while this skill governs the conversation—only the sketch file (and its YAML frontmatter when present).

## What to change

Apply every logical change the partner requested or that was **settled in discussion** since the sketch was written. Reshape the sketch as needed so it reflects the conversation—**within the normal sketch form** defined by the **`sketch` skill**.

**Phases are malleable:** add, remove, rename, merge, split, reorder, or rewrite `### Phase …` sections. Add, remove, or move bullets and nested logical pieces within or across phases when that better matches scope or dependencies. You may rewrite large portions of the sketch when logic demands it.

**Keep phases small and ordered:** each phase should represent one small, logical chunk of work. Prefer more concise phases over fewer bloated ones. Phases stay in execution order (see below).

**Stay within sketch style (non-negotiable):** follow the **`sketch` skill** and match the file’s existing tone—ordered `### Phase …` sections with one **Objective**, file links, and symbol-level nested bullets only. No top-level `##` blocks or extra scaffolding (for example **Depends on**, **Risks**, recap); express dependencies through phase order and bullets.

**Weave in phase callouts:** where it clarifies *why* or *what contract*, name other phases inline in objectives and bullets—a short parenthetical or clause, not a separate section. Examples: an earlier phase notes deferred work (**flat attrs only; Phase 6 adds private PATCH flattening**), a middle phase ties callers to a later contract (**read `recording_url` from flat attrs; Phase 6 adds flattening**), a later phase states what it consumes (**flat attr contract the Phase 2 changeset consumes**), etc. Use sparingly when reordering or adding bullets; update callouts if phase numbers shift.

## Holistic pass

Whenever you edit the sketch, read the **entire** file before and after. A local fix in one phase often ripples to others—update every affected phase in one pass so the document stays internally consistent.

## Phase ordering (critical)

Phases are executed **in order**. Nothing in an earlier phase may depend on work described only in a **later** phase.

When editing, verify **every** phase:

- Earlier phases only introduce foundations later phases consume (migrations, schemas, contexts, APIs, workers, etc.).
- Later phases do not assume symbols, data, or behavior that earlier phases have not already established.
- Implementation dependencies read forward in time only (Phase 2 may build on Phase 1; Phase 1 must not *implement* Phase 3’s symbols or behavior). Naming another phase in a bullet to explain a constraint or contract is fine (see **Weave in phase callouts** above).
- **Tests last:** any test files, test cases, or test-only work the sketch calls for must live in the **final** phase—and only there. Earlier phases must not include test bullets. If edits introduce or scatter test work, **move** it into the last phase (merge into that phase’s bullets if needed).

**Default layering (bottom-up):** when reordering or reshaping work, prefer this stack unless the existing sketch deliberately does otherwise:

1. Infrastructure and persistence (migrations, API layer, config, Oban/queues, external integrations)
2. Schema / domain models
3. Context and business logic
4. Web boundary (controllers, LiveViews, views, routes)
5. **Final phase only:** tests (and any polish that depends on completed implementation)

If a requested change would violate ordering, **fix the sketch** (rewrite phases and bullets) so dependencies flow downward—do not leave forward references.

## When you edit the sketch

Do this when the partner asks for a change or when discussion has clearly settled one— not on every message.

1. **Read** the sketch file end to end (body and frontmatter).
2. **List internally** what must change from the settled ask and from ordering/style rules above.
3. **Edit the sketch body in place**—add, remove, reorder, or rewrite phases, objectives, and bullets as needed—until it matches the new logic and passes the ordering check. Do not touch YAML **`todos`** yet.
4. **Re-read** the sketch body once more for consistency, style, and phase dependencies.
5. **Reconcile `todos`** to match the phases after the edits.
6. **Report to partner**—do not paste the full sketch into chat. **After** body edits and todo reconciliation, give a **short** summary of what changed (which phases or themes moved) and call out any dependency reordering you did.

Between edits, discuss freely; keep the sketch path and the constraints in this skill in mind so the next settled change lands cleanly.

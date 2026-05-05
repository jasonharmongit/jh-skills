---
name: describe-current-state
description: Produce a concise current-state narrative for an issue before options or implementation.
---

Do not modify application code, tests, configuration, or project assets while this skill governs the turn. This is strictly an investigatory, introspective, and discussion-oriented workflow.

When this step runs under the `solutionize` skill, follow that skill for when and how to persist output.

## 1 - Describe current state

Read everything relevant: modules, callers, tests, tickets or docs as needed. Act as **subject matter expert** for this task.

**Paragraph length (step 1):** In **1 - Describe current state**, **three sentences is the absolute maximum per paragraph.** Never put a fourth sentence in the same paragraph; start a new paragraph instead.

**What step 1 is for:** The whole of **1 - Describe current state** is one **concise, brief narrative** that sets the stage for **2 - Approach problem** and the rest of the workflow. It should show that you understand the **problem in context** and give the partner **the same** working picture—enough to reason about tradeoffs and implementation next—without duplicating a spec or writing a design doc. Do not structure the section as a cold open followed by a separate "deep dive": it is **one story**, told in order.

**Shape of that story (top down, forward, concrete):** Tell it in the order a person would follow the system: recognizable entry points (product or API surface, main jobs), then how work proceeds through layers that matter for *this* issue—only as far as needed to explain **current** behavior around the gap. Do **not** open at a deep leaf (a private helper, one changeset field, an internal job) and walk upward; do **not** restart mid-narrative from a narrow function as the sentence subject and gesture backward into persistence ("…which flows into `Message.insert_changeset`"). Anchor beats on the layer doing the work; say who **calls** whom, what runs **before** what, and what **inputs** become what **artifact**. Introduce helpers **in place** along that path. Do not substitute mush verbs ("flows," "feeds," "lands in," "wires through," "hands off") for those mechanics—each sentence should still answer **who invokes what**, **ordering**, or **data shape between stages**. If you cannot say that yet, read the code until you can.

**Output of this step:** that synopsis: brief natural-language **how it works today** where it touches the issue. Weave references inline (as markdown links) as supporting context (function names, key assigns, schema fields). Do NOT include any diagrams or tables.

Step 1 is **current-state only**. Do not include implementation intent, recommendations, option framing, or proposed future behavior.

Avoid future-state language in this step. If a sentence drifts into recommendation or implementation intent, rewrite it as present behavior or a current constraint.

No preamble ("in this section…") inside the Describe current state section.

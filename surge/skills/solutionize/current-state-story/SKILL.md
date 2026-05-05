---
name: current-state-story
description: Produce a concise current-state narrative
---

# Current state story

## Your goal

Create one **concise, focused story** that answers: "how does this work today?"

## Writing principles

**Narrative flow:**
- Start at the recognizable entry point (user-facing feature, API, or main job)
- Follow work through layers that matter **for this specific issue**, no further
- Proceed chronologically: who calls what, what runs first, how outputs become inputs downstream

**Sentence-level clarity:**
- Each sentence answers one of: **who invokes what**, **in what order**, or **what data shape** moves between stages
- Anchor every beat on the **layer doing the work**—name the function, module, or process explicitly
- Introduce helpers **in context** as they appear in the call chain; don't digress into internals
- Link to code inline as supporting context (function names, schema fields, key assigns)

**Paragraph structure:**
- **Maximum 3 sentences per paragraph.** Longer paragraphs signal you haven't distilled the idea
- Use white space generously—it helps readers absorb each beat before moving forward
- Start each paragraph with a new actor or stage in the flow

## Anti-patterns to avoid

**Scope and framing:**
- No preamble ("In this section we'll see…"). Jump straight into the story
- Do not write a spec or design document. You are writing a **narrative**, not documentation—keep it tight and digestible
- Do not overscope. Trace the path from entry point through affected layers **for this specific issue**; do not catalog the entire system
- No future-state language. If a sentence drifts toward "should" or "could," rewrite it as present behavior or a current constraint
- No implementation recommendations, options, or proposed changes. You are describing **what exists**, not planning what could exist
- No diagrams, tables, or visual aids
- No abstract glosses ("the system checks X"). Say which function or layer checks X and when

**Narrative structure:**
- Do not open deep (inside a private helper or a single schema field) and trace upward
- Do not jump to a narrow function mid-story as your subject and gesture backward to persistence ("…which flows into `handle_insert`")
- Do not use narrative shortcuts: "flows," "feeds," "lands in," "wires through," "hands off." Use concrete verbs and explicit naming: "`User.create_changeset/1` is called by `create_handler/2`, which then calls `Repo.insert/1`"

**Language:**
- Precise over poetic. Every word should earn its place
- Active voice. State who does what; avoid passive constructions that hide agency

---

## Workflow

**Do not modify code, tests, configuration, or project assets.** This is purely investigatory and collaborative.

1. **Read to understand:** Study all relevant modules, call sites, tests, tickets, and documentation until you can trace the path clearly.
2. **Write the story:** Follow the principles and anti-patterns above. Write linearly from entry point to the layers relevant to the issue. Name functions and modules explicitly; link to code.
3. **Review and iterate:** After drafting, re-read your story against each anti-pattern. If any sentence uses vague language, skips a step, or starts too deep—rewrite it. Repeat until the story is tight, concrete, and ready to hand off.
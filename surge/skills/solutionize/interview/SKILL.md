---
name: interview
description: Locked assumptions, questions, and follow-ups before a phased sketch
---

# Interview

## Invoking this skill

You must be in **Cursor Plan mode** for the entire duration. All output lives in a `.plan.md` file. Edit the file to include the `## 3 - Interview` section (or adjust the section number as appropriate for your context) with its body.

## Your goal

Introspect on an approach. Identify and lock down open questions and assumptions that will guide implementation.

## Document structure

Include three sections in your workflow document:

### Locked assumptions

Very concise list: one short phrase or sentence per bullet.
- Start with the primary approach or decision being explored
- Use this only as a decision record; do not revise it based on answers to questions

### Questions

The first batch of open decisions only. For each item:

```markdown
- <your question>
  - Answer:
```

### Follow-up questions (N)

Later questions (after initial answers, or anytime during the discussion) go here, never back into `### Questions`. 
- Append each new subsection at the **end**, using the next index: `(1)`, `(2)`, `(3)`, etc.
- Use the same question/Answer: pattern

## Anti-patterns to avoid

- Do not draft the implementation sketch yet. Lock down the decisions first
- Do not proceed without explicit user approval, even if you have no questions
- Do not ask questions in chat, use `AskQuestion`, or use tools that surface as chat prompts. All questions and answers belong only in the workflow document
- Do not answer your own questions. The user completes each `Answer:` line by editing the document
- Do not add bullets to Locked assumptions unless the user explicitly requests it
- Do not revise Locked assumptions based on answers to questions; the pairing of question + answer is the decision record
- Do not merge follow-up questions back into the Questions section; always append them in chronological order as new Follow-up questions (N) blocks
- Do not guess or push uncertain decisions forward. If an answer is ambiguous, contradictory, or incomplete, add a follow-up question instead
- Do not skip or gloss over incomplete `Answer:` lines during your review before proceeding

---

## Workflow

1. **Write locked assumptions** — Extract assumptions from the approach being explored, your research, investigation, and chat history with the user. List them concisely in the `### Locked assumptions` section. Start with the primary approach, then add key constraints, scope boundaries, and decisions already made.

2. **Introspect and investigate** — Before writing questions, think deeply about what still needs to be decided. Re-read the approach context, any current-state information, and relevant code or documentation. Identify gaps: which decisions would directly affect implementation scope, file count, PR size, or architecture? Which decisions would change how work flows through the system?

3. **Write initial questions** — Create the `### Questions` section with the first batch of open decisions. Each question should be answerable and material to moving forward. Focus on decisions that unlock clarity; avoid edge cases or micro-decisions that can wait.

4. **Enter discussion mode** — Tell the user the questions are ready and wait for their input. The user may answer questions, ask their own clarifying questions, discuss tradeoffs, or request changes to assumptions. All discussion and answers live in the `.plan.md` file; do not ask or answer in chat.

5. **Review answers and introspect** — When all `Answer:` lines are filled in, re-read them carefully. Check for ambiguity, contradiction, or incompleteness. Introspect on what the answers reveal: do they unlock new questions? Do they expose gaps in your understanding? Do they settle any assumptions you listed, or change them?

6. **Generate follow-up questions** — If answers are complete and clear, you may have no follow-ups. If you do have new questions, create a new `### Follow-up questions (N)` block (use the next index) and add them in the same format. Repeat step 4 and 5 until all necessary decisions are locked and you have high confidence in the path forward.

7. **Ready for approval** — When you are satisfied that all necessary decisions are made and settled, respond in chat: "Interview is complete; ready for approval to proceed." Wait for the user's explicit proceed confirmation.

---

## Example

```markdown
## Interview

### Locked assumptions

- Approach focuses on pagination optimization
- Changes apply only to the list view (drill-in view unchanged)
- Uses the existing `status` field for filtering

### Questions

- Should filtering state persist when navigating between list and drill-in?
  - Answer:

- Should filtering be available for export if added later?
  - Answer:

### Follow-up questions (1)

- Should retry attempts be included in failed row counts?
  - Answer:
```

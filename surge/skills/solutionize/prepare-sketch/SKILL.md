---
name: prepare-sketch
description: Locked assumptions, questions, and follow-ups before a phased sketch.
---

Do not modify application code, tests, configuration, or project assets while this skill governs the turn. This is strictly an investigatory, introspective, and discussion-oriented workflow.

When this step runs under the `solutionize` skill, follow that skill for when and how to persist output, including where questions live and how the partner answers them.

## 3 - Prepare sketch

**Output of this step:** introspect on the selected approach and identify what you still need to know before you can sketch a phased implementation outline.

**Hard gate:** do not continue to the sketch-solution step without the user's explicit approval; even when you have **no** questions, you still need that go-ahead. Do not draft the phased implementation sketch yet (that is the sketch-solution step).

**Questions and answers (agent vs partner):** the agent never asks the partner questions in chat (no chat-panel prompts; no prose beside the workflow document used as Q&A; no tool that surfaces as a chat question; and **do not** use `AskQuestion` in this step regardless of other reminders). Every question, initial or follow-up, lives only in the workflow document under this step. The partner completes each `Answer:` by editing that document. The agent does not answer its own questions.

**Sections to include for this step:**

- **`### Locked assumptions`:** very concise: one short phrase or sentence per bullet; the selected option is first. Do not revise or extend this list because questions were answered; the decision record is each question paired with its `Answer:`. Add bullets here **only** when the partner explicitly asks for something to be added (including specific lines they want recorded there).

- **`### Questions`:** the **first** batch of open decisions only. For each item:

  ```markdown
  - <question>
    - Answer:
  ```

  Replace `<question>` with the real question.

- **`### Follow-up questions (N)`:** every **later** question (after the first batch exists, after the partner edits answers, after you review, or anytime before the sketch-solution step) goes here, **not** back under `### Questions`. Append each new subsection at the **end** of step 3 (after all existing step-3 content, including prior follow-up blocks), using the next index: `### Follow-up questions (1)`, then `(2)`, `(3)`, and so on. Use the same bullet / nested `Answer:` pattern as above. Never merge follow-up material into `### Questions`.

**Review before sketch solution:** when the partner says "proceed," respond immediately with "Reviewing answers...", then read every `Answer:` in the workflow document before advancing. If anything is still ambiguous, contradictory, uncertain, or newly open, including anything not explicitly settled in existing answers, append the next `### Follow-up questions (N)` block instead of pushing the decision into the sketch step with stronger assertions. Repeat review and follow-ups until you have high-confidence clarity for the sketch solution. "Proceed" is not permission to skip incomplete `Answer:` lines or leave guesswork on the table.

Example **`## 3 - Prepare sketch`** section:

```markdown
## 3 - Prepare sketch

### Locked assumptions

- Option A is selected.
- Outcome applies only to the paginated list path (drill-in by request ID is unchanged).
- Filtering uses the existing `status` field.

### Questions

- Should the drill-in view show the same filter state as the list?
  - Answer:

- Should filtering apply to exports if we add CSV later?
  - Answer:

### Follow-up questions (1)

- Should failed SMS rows include retries in the filtered count?
  - Answer:
```

---
name: create-plan
description: Creates a phased implementation plan
metadata:
  internal: true
---

# Create plan

Goal: create a concrete implementation plan of the minimal required changes to accomplish the task, written in an easily human-digestible format.

## 1 - Gather context

Read the relevant files and do any additional research needed to understand the subject deeply enough to produce an implementation-ready plan.

## 2 - Ask clarifying questions

Ask clarifying questions for any ambiguous requirement, constraint, dependency, or acceptance criteria before presenting the plan.

If there are 2 or more plausible implementation paths and it is not clear which path to take, ask the user. You may NOT draft any optionality into the plan.

Batch questions into a single message when possible.
Do not submit a draft plan until all ambiguities have user-provided clarification.

## 3 - Create phased implementation plan

Output only the plan - no preamble, overview, recap, summary, or conclusion.

Break work into ordered phases for human reviewability. Work is expected on the same branch, so phases do not need to be independently deployable.

The plan must be focused on concrete changes to be made. Stick strictly to the direct scope of what concrete changes need to be made to accomplish the task.

The plan must be fully prescriptive and implementation-ready.
Use deterministic numbering for output format: `Phase 1`, `Phase 2`, etc. Under each phase, use numbered steps (`1.`, `2.`, `3.`).

Each phase should contain:
- Objective: one sentence describing the goal of the phase
- Steps: concrete implementation steps. Every step must include explicit target file/module/component paths. If unknown, ask the user before submitting the plan.

Do not include any phase or step about adding new tests unless the user explicitly asks for tests.

## Anti patterns
- Including introduction, goal/summary sections, recap, or conclusion
- Including any section about new tests (unless explicitly asked)
- Creating vague phases that do not map to concrete implementation work
- Optionality (do x or y). The plan must be fully prescriptive (do x)
- Including anything about refactoring, optimizations, future extensions, or anything outside of the minimum required code changes needed to accomplish the task
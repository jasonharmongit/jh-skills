---
name: collapse-bot-comments
description: Wrap long PR bot comments in a details block
---

# Collapse Bot Comments

## Goal

Keep the first line of the comment visible and collapse all remaining content under one valid `<details>` block.

## Workflow

1. Identify the PR number for the current branch.
2. List issue comments for that PR.
3. Find the target comment:
   - Claude: usually `claude[bot]`.
   - Greptile: usually `greptile-apps[bot]`.
4. Read the current body before editing.
5. Rewrite the body so:
   - Line 1 stays outside details.
   - Everything else is inside:
     - `<details>`
     - content
     - `</details>`
6. For Greptile templates, remove stray internal `</details>` tags so there is only one closing tag at the end.
7. Verify by fetching the comment again and checking body text.

## Output rules

- Preserve original markdown and spacing as much as possible.
- Do not JSON-escape the body into a quoted string when presenting results.
- Use a plain `gh api --method PATCH ... -f body="..."` call.
- Use full permissions for the command, not the sandbox.

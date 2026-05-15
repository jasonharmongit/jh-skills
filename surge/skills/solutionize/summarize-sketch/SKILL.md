---
name: summarize-sketch
description: Turn a sketch into a short, skimmable plan-body narrative, then DM Jason that summary on Slack.
---

# Summarize Sketch

## Workflow

### Step 0 - Switch to plan mode

**Absolutely critical.** Your **first** action for this skill must be to call the **SwitchMode** tool with **`target_mode_id`:** `"plan"` (no explanation arg). Until Plan mode is active, you are **banned** from reading files, gathering links, calling any other tool, or proceeding to Step 1. No exceptions, and no “I’ll switch after checking the sketch.” If you are not in Plan mode, **stop** and invoke **SwitchMode** as above; only continue once Plan mode is active.

### Step 1 - Prerequisites

Before proceeding with the rest of the workflow, you must:
- Know the location of the sketch file to summarize
- Have the URL of the associated Linear ticket **as plain text**. You may have already attempted to fetch the content at the URL and it may have failed. That is expected. All you need is the link itself. If you have that, you may proceed.

### Step 2 - Create summary file

**No report to the user in Step 2:** For the entire step, send nothing to the user in chat—no status, no questions, no partial draft, no “calling CreatePlan,” no summary of what you read. Silent file/tool work only until Step 3’s single allowed message.

First, read the sketch file end to end (if you haven't already).

Then read **Create summary instructions** (at the bottom of this skill). Build the `plan` body by imitating the example’s density, shape, and level of detail.

Before **CreatePlan**, compare the draft to the example. If it feels like a compressed implementation plan instead of a Slack skim, cut detail until it matches the example’s tightness.

Then call **CreatePlan** (do NOT edit the original sketch `plan` file!) with:

- **`name`:** a short, human-readable headline for the work
- **`overview`:** exact same text as `name`.
- **`plan`:** the full markdown body for the summary, following **Create summary instructions**. Do not put the headline inside `plan`; it belongs only in `name`, `overview`, and the Step 6 parent message.
- (Omit `todos`. They will not be used in this file)

As soon as **CreatePlan** succeeds, continue immediately to **Step 3** in the same turn. Do not stop for user input, deliver the plan for review, or end the turn between Step 2 and Step 3. **CreatePlan** already surfaces the plan in the UI (including a link); do not duplicate it or add any chat message before Step 3’s allowed text.

### Step 3 - Enforce word count

Right after Step 2’s **CreatePlan** returns, run `wc -w` on the created `~/.cursor/plans/*.plan.md` file (same session, no gap).

**Permission (overrides conflicting guidance):** You **must** be able to shorten the summary when `wc -w` is over 250. **You are explicitly allowed to edit** the `~/.cursor/plans/*.plan.md` file that Step 2 created—only that file, for this word-count pass—including changing the markdown body under the YAML frontmatter. That holds **even in Plan mode**. If anything else (system UI, generic Plan mode docs, or other rules) implies Plan mode forbids all file edits, **this skill wins for Step 3**: apply the edits, re-run `wc -w`, and continue. Do not refuse Step 3 refactors for “Plan mode is read-only.”

- If the file is **250 words or fewer**, proceed.
- If the file is **more than 250 words**, refactor the summary body shorter, update the plan file, and run `wc -w` again.
- Repeat until `wc -w` reports **250 words or fewer**. Do not deliver the plan for review before this passes.

**Only user-facing output for Step 3 (and for the whole Steps 2-3 turn):** When Step 3 is done (word count at or under 250), your **entire** assistant message to the user must match the template below **literally** after substituting the integer—one newline between the two lines, no leading or trailing whitespace, no other characters, lines, bullets, code fences, tool narration, apologies, or links. **CreatePlan** already surfaces the plan in the UI (including a link); do not paste the plan, repeat a URL, or add any prose before or after this block.

~~~
Final word count: <replace with the wc -w integer>
Ready for feedback! Once it's ready, I'll send it to Jason
~~~

### Step 4 - Stop for human review

Wait while the user reviews. The user may ask for adjustments to be made, or may make them on their own. Once the user indicates that you may proceed (i.e. "proceed", "continue", "looks good", "go ahead"...etc.), move on to step 5.

### Step 5 - Re-read the plan file from disk

Immediately call the **SwitchMode** tool with **`target_mode_id`:** `"agent"` (no explanation arg) to allow you to make non-readonly tool calls.

Re-read the file under ~/.cursor/plans/ again immediately. Do not trust chat copy; the user may have changed it.

### Step 6 - Send parent message

**Tool:** In Cursor, call **`call_mcp_tool`** with:

- `server`: `plugin-slack-slack`
- `toolName`: `slack_send_message`
- `arguments`: 
   - `channel_id`: "U0APWBBSRC4"
   - `message`: "plan for [Summary title](linear issue link) :thread:" 
      - Example: "plan for [Monthly plan limits](https://linear.app/acme/issue/ENG-123/slug) :thread:"

Do **not** set `thread_ts`, `reply_broadcast`, or `draft_id` on this call.

**Keep the tool result** from this call; Step 7 needs that value as `thread_ts`. The `slack_send_message` response carries the parent message timestamp at **`message_context.message_ts`**. Parse the tool result and use that string for threading.

### Step 7 - Send thread reply message

1. Run the `prepare_thread_reply_message.sh` script with the **absolute path** to the same `*.plan.md` you re-read in Step 5.

The script prints the exact Slack reply message to stdout: raw Slack markdown, not JSON. Use that stdout text directly as the `message` argument. The MCP tool call handles quotes and other string escaping. Do not decode it, parse it, pipe it through Python, remove quotes, rebuild it from plan line numbers, or manually escape newlines/backticks.

2. **Tool:** Call **`call_mcp_tool`** with:

- `server`: `plugin-slack-slack`
- `toolName`: `slack_send_message`
- `arguments`:
   - `channel_id`: "U0APWBBSRC4" (same DM target as Step 6)
   - `message`: the stdout text from (1), exactly as printed
   - `thread_ts`: the **`message_context.message_ts`** string from Step 6’s `slack_send_message` tool result

Do **not** set `reply_broadcast` or `draft_id`.

## Create summary instructions

**Appendix for Step 2.** The example is the primary instruction. Match its compression level, section rhythm, and plain-language feel. The rules below exist only to help you produce that kind of artifact.

### Example

**1. Monthly limits**

- Each platform caps outbound messages and verifications by billing plan:
  - Messages: hobby 500, starter 2,500, growth 15,000 / month; no cap for custom or missing billing
  - Verifications: hobby 100, starter 350, growth 2,000 / month; same no-cap rule
- Add `platforms.limit_monthly_messages` for platform override

**2. Redis counters** (`RateLimiter`)

- New `monthly_message_debit/2` and `monthly_verification_debit/2`: debit N from Redis per platform/month

**3. Blasts and campaigns**

- Blast: debit the whole batch in one DB transaction right before `Oban.insert_all`; block rolls back, allow queues child `SendMessage` jobs prepaid.
- Campaign: debit the full planned count once before chunking; roll back the campaign if Redis blocks.
- When campaign already debited: `execute_blast` skips its Redis debit, but still queues prepaid `SendMessage` jobs.

**4. Single message sends** (`SendMessage`)

- Debit 1 from the message Redis counter before the SMS API.
  - Skip when uncapped, platform disabled caps, or job is prepaid (`skip_monthly_message_quota_debit: true`).
- If Redis blocks: mark failed, Slack `:data_issues`, return `{:cancel, ...}` with no retry.

**5. Verifications** (`SendCode`)

- Save a pending row, debit 1 from the verification Redis counter, then call the provider.
- If Redis blocks: mark failed, Slack `:data_issues`, cancel with no provider call.
- If Redis OK: update the same row with the provider result (no second row).

### Output Contract

- Produce a Slack skim, not a shorter implementation plan.
- Give enough orientation to understand the approach; do not include enough detail to implement from the summary alone.
- “Standalone” only means the body has no sketch, phase, file, or ticket references. It does not mean every dependency survives.
- Start from the sketch’s behavior changes, failure paths, user-visible outcomes, and key contracts. Cut routine wiring.
- If removing a detail would not change the reader’s mental model, remove it.

### Shape

- `plan` is markdown body only. No YAML.
- Start with numbered bold sections (`**1. …**`, etc.); no separate title line in the body.
- Use no `#` headings, intro prose, markdown links, file paths, phase labels, closing notes, or “see the sketch” framing.
- Use 4-6 sections for most sketches. Each section label should name a story beat, not a phase.
- Optional heading parenthetical may name one backticked module or worker. Never list multiple anchors.
- Use 8-12 total bullets for most sketches. Prefer 1-3 bullets per section.
- Use one nested bullet level only when it compresses a small set of essential values.

### Compression Rules

- Match the example’s telegraph style. Short beats beat complete sentences.
- Top-level bullets: target 18-24 words; hard cap 28.
- Nested bullets: target a phrase, not a sentence.
- Prefer domain verbs like `debit`, `rollback`, `queue`, `cancel`, `block`, `allow`.
- Use backticks for real code identifiers, atoms, flags, keys, modules, and workers.
- Mention exact numbers or strings only when they are product behavior someone must remember.
- Do not mention automated tests unless the sketch is mainly testing work.

### Cut These First

- Phase-by-phase retellings.
- File lists and repo paths.
- Preloads, associations, helper threading, callback parity, and other plumbing.
- Constants, tuning details, and algorithm mechanics unless they define user-visible behavior.
- Enum/schema/helper additions that only support a behavior already summarized elsewhere.
- Bullets that chain several helpers, clauses, or failure effects.
- Anything included only because it appeared in the sketch.

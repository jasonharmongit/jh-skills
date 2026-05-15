---
name: summarize-sketch
description: Turn a sketch into a short, skimmable plan-body narrative, then DM Jason on Slack using summarize_sketch_slack.py (one-line JSON for each slack_send_message call).
---

# Summarize Sketch

## Workflow

### Step 1 - Prerequisites

Before proceeding with the rest of the workflow, you must:
- Know the location of the sketch file to summarize
- Have the URL of the associated Linear ticket **as plain text**. You may have already attempted to fetch the content at the URL and it may have failed. That is expected. All you need is the link itself. If you have that, you may proceed. 
   - **CRITICAL** - if you do not have the Linear link, STOP and simply ask for it, like "Can you provide the linear link?". No further explanation needed. Do not proceed to step 2 without a link. Do not try to find the link on your own. Ask the user for it.

### Step 2 - Create summary file

Stay in **agent** mode for the whole skill; do not switch modes.

**No report to the user in Step 2:** For the entire step, send nothing to the user in chat—no status, no questions, no partial draft, no summary of what you read. Silent file/tool work only until Step 3’s single allowed message.

First, read the sketch file end to end (if you haven't already).

Then read **Create summary instructions** (at the bottom of this skill). Prepare to create a sketch summary imitating the example’s density, shape, and level of detail, and by following the rules and guidelines as directed there.

Write a markdown file under **`~/.cursor/plans/`** whose name ends in **`.plan.md`**. How you name it otherwise, how you title it, and how you structure the file are up to you, as long as the result satisfies the proofread checks in Step 3 and the Slack steps later in this skill.

### Step 3 - Proofread summary

Immediately after writing the file in Step 2, work on that same path (same session, no gap). Re-read the sketch file from Step 1 and the summary body end to end, then proofread as follows:

1. **Word count:** Run `wc -w` on the file. The count must be **250 words or fewer**; if it is over, shorten the markdown body (and any other parts of the file you need to adjust so the body still matches **Create summary instructions**), then run `wc -w` again until it passes.
2. **Sketch fidelity:** Compare the summary body to the sketch. The summary must still be an accurate representation—no contradictions, no invented behavior, no dropped outcomes or failure paths that change what the reader should believe about the work. Compression is fine; misrepresentation is not.
3. **Skill rules:** Compare the summary body to **Create summary instructions** (this file, from the example through **Cut These First**). It must follow every applicable rule (output contract, shape, compression, cuts, standalone body, etc.).

If anything fails any check, **edit that same file in place**, then re-run the proofread loop until all checks pass. Do not deliver it for review before everything passes.

**Only user-facing output for Step 3 (and for the whole Steps 2-3 turn):** When Step 3 is done (all proofread checks pass), simply output this message:

"""
Final word count: <replace with the wc -w integer>
Ready for feedback! Once it's ready, I'll send it to Jason
"""

### Step 4 - Stop for human review

Wait while the user reviews. The user may ask for adjustments to be made, or may make them on their own. Once the user indicates that you may proceed (i.e. "proceed", "continue", "looks good", "go ahead"...etc.), move on to step 5.

### Step 5 - Send parent message

Script (same directory as this skill): **`summarize_sketch_slack.py`**. Invoke it with an **absolute** path to the script.

1. **Shell:** Run `python3` with the absolute path to **`summarize_sketch_slack.py`**, subcommand **`parent`**, **`--linear`** set to the full Linear issue URL from Step 1 (plain `https://...` text), and **`--title`** set to a short plain-text headline for the parent Slack link (your judgment). Example shape:

   `python3` `/ABS/path/to/summarize_sketch_slack.py` `parent` `--linear` `https://linear.app/.../issue/.../...` `--title` `Short headline for the work`

   The script builds the parent line: `plan for [that title](linear url) :thread:`.

2. **Stdout:** exactly **one line** of minified JSON. That line is the **entire** `arguments` object for **`slack_send_message`** (`channel_id` and `message` only).

3. **`call_mcp_tool`:** `server` **`plugin-slack-slack`**, `toolName` **`slack_send_message`**, **`arguments`:** parse the stdout line as JSON and pass that object through unchanged. Do not hand-build or re-escape fields; do not substitute only part of the object. 

4. **Keep the tool result** for Step 6. Read **`message_context.message_ts`** from the response (parent message timestamp for threading).

### Step 6 - Send thread reply message

1. **Shell:** Run the same **`python3`** / **`summarize_sketch_slack.py`** entrypoint with subcommand **`thread`**: **`--plan`** set to the absolute path of the summary markdown file from Steps 2–3, and **`--thread-ts`** set to the **`message_context.message_ts`** string from Step 5’s `slack_send_message` result. Re-read that file from disk right before this if the user may have edited it during Step 4. Example shape:

   `python3` `/ABS/path/to/summarize_sketch_slack.py` `thread` `--plan` `/ABS/path/to/your-summary-file.md` `--thread-ts` `1234567890.123456`

2. **Stdout:** exactly **one line** of minified JSON — the full **`arguments`** object for **`slack_send_message`** (`channel_id`, `thread_ts`, `message`).

3. **`call_mcp_tool`:** same as Step 5 — **`arguments`** is the JSON object from stdout, parsed and passed as-is.

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
- Never use "copy" to mean on-screen UI text or labels (e.g. do not write "dashboard copy"); say "text", "labels", "wording", etc., instead. Reserve "copy" to refer to duplication, not UI surfaces.

### Shape

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

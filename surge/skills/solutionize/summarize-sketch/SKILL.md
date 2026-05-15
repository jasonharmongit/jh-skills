---
name: summarize-sketch
description: Compress a sketch to exemplar-tight main ideas (short lines, few bullets, no mini-spec bullets), then DM Jason that summary on Slack.
---

# Summarize Sketch

## Goal

- Produce the same kind of answer as a **concise breakdown** request: **only the main points** someone must **understand** about the sketch (what the system will do differently, where it applies, what success and failure look like)—not a shorter re-listing of every sketch bullet.
- Optimize for **orientation**: enough to decide whether to open the sketch for phase-level detail; **not** enough to implement from the summary alone.

## Exemplar

**Monthly plan limits**

Enforce monthly outbound message and verification send limits per platform, tied to billing plan, with Redis (Hammer-style) token buckets and clear failure / cancel behavior.

---

**1. Schema**

- Add `platforms.limit_monthly_messages` (default `true`) as a master bypass.
- Add failure reasons `:monthly_message_cap_reached` and `:monthly_verification_cap_reached` to shared `MessageDelivery` enums.

**2. Plan ceilings** (`PlatformBillingInformation`)

- **Messages:** hobby 500, starter 2,500, growth 15,000; custom / nil → unlimited.
- **Verifications:** hobby 100, starter 350, growth 2,000; custom / nil → unlimited.

**3. Rate limiter**

- New `monthly_message_debit/2` and `monthly_verification_debit/2` on the limiter + Redis implementation.
- Keys like `monthly_msg:<platform_id>:<YYYY-MM>` and `monthly_vfn:...` - bucket resets each calendar month via the key.

**4. Normal sends** (`SendMessage`)

- After preloading platform + billing, debit 1 before the provider unless: bypass flag, unlimited plan, or job has `skip_monthly_message_quota_debit`.
- On deny: mark message failed with the new reason, `Slack.send_message(:data_issues, ...)`, return `{:cancel, ...}` so Oban does not retry in a loop.

**5. Blasts / campaigns**

- Debit the full job count once (inside the DB transaction, right before `Oban.insert_all`).
- On deny: rollback so nothing persists.
- On allow: enqueue each `SendMessage` with the skip flag so per-job debits do not double-count.
- Campaign path (`blasts.ex`): one upfront reservation for the whole campaign, coordinated with blast execution so you do not debit twice.

**6. Verifications** (`SendCode`)

- Insert a pending attempt row first, then debit verification before the provider.
- On deny: update row as failed with `:monthly_verification_cap_reached`, Slack, cancel.
- On allow: merge into that row instead of always inserting fresh.

**7. Failure reason descriptions** (`Message`)

- Extend `failure_reason_description/1` for `:monthly_message_cap_reached` and `:monthly_verification_cap_reached` (the new `MessageDelivery` failure reasons from section 1).

## Workflow

### Step 0 - Prerequisites

Before proceeding with the rest of the workflow, you must:
- Know the location of the sketch file to summarize
- Have the URL of the associated Linear ticket **as plain text**. You may have already attempted to fetch the content at the URL and it may have failed. That is expected. All you need is the link itself. If you have that, you may proceed.
- **Cursor mode:** Use **Plan** mode for **Steps 1-2** (read the sketch and exemplar, call **CreatePlan**, deliver the plan for human review). If you are not in Plan mode when you start Step 1, switch to Plan mode first. Plan mode is read-only and cannot run Slack MCP tools. After review, when you are ready to post to Slack, switch to **Agent** mode before **Step 3** and remain in Agent mode through **Step 5** (re-read the plan file from disk, then **call_mcp_tool** for the parent message and thread reply).

### Step 1 - Create summary file

First, read the sketch file end to end (if you haven't already).

Then re-read the **Exemplar** section above. Treat it as the primary **shape, line length, and bullet weight** reference: skim-time density, not a second sketch.

Before **CreatePlan**, sanity-check your outline against the exemplar: if any bullet is a paragraph, or the overview reads like two sentences glued together, **cut words first**—the sketch still holds the dropped detail.

Then call **CreatePlan** with:

- **`name`:** a short, human-readable headline for the work (same words as the first-line `**Title**` below, without leading `Sketch: ` unless the sketch title itself uses that prefix).
- **`overview`:** exact same text as `name`.
- **`plan`:** the full body in the **canonical shape** below (starting with the first-line `**Title**`). Nothing else before that line inside `plan`.
- (Omit `todos`. They will not be used in this file)

#### Canonical shape (must match **Exemplar**)

- **No YAML** inside `plan`; **CreatePlan** supplies frontmatter. Your `plan` argument is only the markdown body.
- **No `#` headings.** Titles and section labels use `**bold**` only.
- **First line:** one `**Title**` line (issue headline style, not "summary of…").
- **Blank line**, then **exactly one overview sentence** in plain prose. It states scope and approach at a glance (like the exemplar’s opening sentence under **Monthly plan limits**). Not a paragraph stack; not every phase restated.
- **Blank line**, then a **horizontal rule** on its own line: `---` (three hyphens), then **blank line**, then the numbered sections. Do **not** insert a `**Main ideas**` line (or any other label) between the overview and the sections.
- **Sections:** `**1. Short label**`, `**2. Short label**`, … where each label is a **topic** (a few words). You may add **at most one** optional parenthetical immediately after the closing `**`, containing **a single** backticked module or worker name—same style as Plan ceilings / Normal sends / Verifications in the exemplar. **Do not** put several module names in one heading parenthesis; pick the one anchor a reader needs. Expect on the order of **5–8** sections for a sketch of typical size; merge related sketch phases when one heading covers them.
- Under each section: `-` bullets only. Prefer **2–3** bullets per section; **4** is acceptable only when the exemplar would (for example a blast/campaign section with distinct allow/deny/skip ideas). Each bullet is **one** decision or contract, not a walkthrough.
- Use `` `backticks` `` for modules, functions, atoms, flags, JSON keys, Redis key patterns, and other code-ish tokens. **Do not** use markdown links, **do not** paste repo paths like `lib/...`, and **do not** enumerate files the way the sketch does unless a single backticked module name is the clearest way to name a touchpoint.
- Never use "copy" to mean on-screen UI text or labels (e.g. do not write "dashboard copy"); say "text", "labels", "wording", etc., instead. Reserve "copy" to refer to duplication, not UI surfaces.

#### Length budget (non-negotiable)

Match the exemplar’s **telegraph style**, not a compressed sketch.

- **Overview sentence:** **≤ 32 words**, one sentence, no semicolons. Prefer the exemplar’s brevity (~25 words).
- **Each bullet:** **≤ 28 words**; aim **≤ 22**. At most **one semicolon** per bullet—if you reach for a second clause, make a second bullet or delete the lower-value clause.
- **Wording:** Prefer domain verbs (`debit`, `rollback`, `enqueue`) over wiring narration (`perform/1` / `with` chain / “must propagate cancel like other hard stops”) unless the exemplar would use that symbol for the same idea in one short hit.
- **Omit from this summary** unless the exemplar would include an analogue: tuning knobs or algorithm constants, dev-only or parity-only mechanics, stakeholder or process asides, and fine-grained sequencing that only restates an invariant you already captured in one short bullet.
- **Automated tests:** Do **not** mention routine tests, test files, assertions, suites, or regression plans in any heading or bullet. The **only** exception is when the sketch’s **central** outcome is testing work.

#### Anti-patterns

- Rewriting the sketch **phase-by-phase** with long section titles copied from `### Phase N`.
- Bullets that are mostly **file paths** or `[label](path)` links to source.
- A long opening overview that reads like a mini-spec instead of one sentence.
- A closing line such as `Tracks [TICKET](https://linear.app/...)` in the summary body. The Linear link belongs **only** in Step 4’s Slack parent message, not here.
- Mentioning **automated tests** (files, suites, regression strategy) when the sketch is **not** centrally about testing work.
- **Mega-bullets:** one `-` line that chains many clauses, names multiple helpers, or narrates control flow the way the sketch does (for example `perform/1` plus `with` chain propagation in the same bullet).
- **Heading sprawl:** parentheticals listing several modules, or section titles that read like phase titles from the sketch.
- **Extra machinery** called out as its own bullet when the exemplar would stay silent (for example development stub parity for a limiter) unless skipping it would mislead a reader about scope.

#### Voice

Compress implementation detail into **decisions and contracts**. The reader already has the sketch for file-level drill-down; this summary is the **at-a-glance** map Jason can skim before opening the sketch. If a sentence does not help someone answer “what are the main things I need to understand?”, cut it.

### Step 2 - Stop for human review

Deliver the plan to the user for them to review. The user may ask for adjustments to be made, or may make them on their own.

### Step 3 - Re-read the plan file from disk

You must be in **Agent** mode (switch before this step if you were in Plan mode for Steps 1-2; see Step 0).

Re-read the file under ~/.cursor/plans/ again immediately. Do not trust chat copy; the user may have changed it.

### Step 4 - Send parent message

**Tool:** In Cursor, call **`call_mcp_tool`** with:

- `server`: `plugin-slack-slack`
- `toolName`: `slack_send_message`
- `arguments`: 
   - `channel_id`: "U0APWBBSRC4"
   - `message`: "plan for [Summary title](linear issue link) :thread:" 
      - Example: "plan for [Monthly plan limits](https://linear.app/acme/issue/ENG-123/slug) :thread:"

Do **not** set `thread_ts`, `reply_broadcast`, or `draft_id` on this call.

**Keep the tool result** from this call; you need the parent message's Slack **`ts`** for Step 5 (parse whatever structure the MCP returns and extract the posted message's `ts` string).

### Step 5 - Send thread reply message

**Prepare `message`:** From the re-read `*.plan.md`, take **only** the summary markdown body: drop YAML frontmatter, then from the first `**Title**` line through EOF. Pass that slice **verbatim** into `message` (same newlines and markdown as the plan). `slack_send_message` renders standard Markdown for Slack—**do not** hand-translate to mrkdwn or tweak emphasis yourself. Strip any YAML that leaked into the body; nothing else should differ from the plan file.

**Tool:** Call **`call_mcp_tool`** again with:

- `server`: `plugin-slack-slack`
- `toolName`: `slack_send_message`
- `arguments`: 
   - `channel_id`: "U0APWBBSRC4" (same DM target as Step 4)
   - `message`: the full summary body from above
   - `thread_ts`: the parent message **`ts`** from Step 4's `slack_send_message` tool result

Do **not** set `reply_broadcast` or `draft_id`.

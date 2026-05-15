---
name: summarize-sketch
description: Turn a sketch into a short, skimmable plan-body narrative (CreatePlan), then DM Jason that summary on Slack.
---

# Summarize Sketch

## Workflow

### Step 0 - Prerequisites

Before proceeding with the rest of the workflow, you must:
- Know the location of the sketch file to summarize
- Have the URL of the associated Linear ticket **as plain text**. You may have already attempted to fetch the content at the URL and it may have failed. That is expected. All you need is the link itself. If you have that, you may proceed.
- **Cursor mode:** Use **Plan** mode for **Steps 1-2** (read the sketch, then read **Create summary instructions** below—the appendix includes **example** plus all shaping rules—then call **CreatePlan**, deliver the plan for human review). If you are not in Plan mode when you start Step 1, switch to Plan mode first. Plan mode is read-only and cannot run Slack MCP tools. After review, when you are ready to post to Slack, switch to **Agent** mode before **Step 3** and remain in Agent mode through **Step 5** (re-read the plan file from disk, then **call_mcp_tool** for the parent message and thread reply).

### Step 1 - Create summary file

First, read the sketch file end to end (if you haven't already).

Then read **Create summary instructions** (at the bottom of this skill). Build the `plan` body to follow the appendix while matching the example’s kind of tightness.

Before **CreatePlan**, sanity-check your outline: if any bullet reads like a paragraph, **cut words first**—the sketch still holds the dropped detail. Re-read order against **Mindset** in the appendix (flags and bulk paths before reuse).

Then call **CreatePlan** with:

- **`name`:** a short, human-readable headline for the work (same words as the first-line `**Title**` below, without leading `Sketch: ` unless the sketch title itself uses that prefix).
- **`overview`:** exact same text as `name`.
- **`plan`:** the full markdown body for the summary, following **Create summary instructions** (starting with the first-line `**Title**`). Nothing else before that line inside `plan`.
- (Omit `todos`. They will not be used in this file)

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

## Create summary instructions

**Appendix for Step 1.** After the sketch, read this appendix **top to bottom**. Start with **example** for the concrete pattern; then use **Mindset** through **Voice** for intent, heuristics, and all shaping and styling rules for the `plan` body you pass to **CreatePlan**.

### Exemple

**Monthly plan limits**

**1. Monthly limits**

- Each platform caps outbound messages and verifications by billing plan:
  - Messages: hobby 500, starter 2,500, growth 15,000 / month when capped; no cap for custom plan or missing billing
  - Verifications: hobby 100, starter 350, growth 2,000 / month; same no-cap rule
- Add `platforms.limit_monthly_messages` to allow for platform-specific override

**2. Redis counters** (`RateLimiter`)

- New `monthly_message_debit/2` and `monthly_verification_debit/2`: debit N from Redis per platform and month

**3. Blasts and campaigns**

- Blast: debit the whole batch from Redis in one DB transaction right before `Oban.insert_all`; if Redis blocks, roll it all back; if OK, queue each child `SendMessage` with `skip_monthly_message_quota_debit: true` (so workers do not debit again).
- Campaign: debit the full planned send count from Redis once before chunking; roll back the whole campaign if Redis blocks.
- When the campaign already debited: inner `execute_blast` skips its own Redis debit for that same work; still queue `SendMessage` jobs with `skip_monthly_message_quota_debit: true`.

**4. Single message sends** (`SendMessage`)

- Debit 1 from the message Redis counter before the SMS API (when caps apply).
  - Skip debit when plan has no cap, platform turned caps off, or job is prepaid from blast/campaign (`skip_monthly_message_quota_debit: true`).
- If Redis blocks: mark failed, Slack `:data_issues`, return `{:cancel, ...}` so Oban will not retry.

**5. Verifications** (`SendCode`)

- Save a pending row, debit 1 from the verification Redis counter, then call the provider.
- If Redis blocks: mark failed, Slack `:data_issues`, cancel with no provider call.
- If Redis OK: update the same row with the provider result (no second row).

### Mindset

- Produce the same kind of answer as a **concise breakdown** request: **only the main points** someone must **understand** about the sketch (what the system will do differently, where it applies, what success and failure look like)—not a shorter re-listing of every sketch bullet.
- Optimize for **orientation**: enough to decide whether to open the sketch for phase-level detail; **not** enough to implement from the summary alone.
- The delivered `plan` markdown is a **skim artifact**: a quick mental model of the approach, not a checklist of everything the sketch mentions.
- Build a **short narrative**: one mental picture of the approach someone can skim **top to bottom** and leave oriented, not a compressed spec of every sketch bullet.
- Order sections so each pass **adds or sharpens** the picture (overall shape first, then the few details that really change how you think about the work); drop anything that only restates what the reader already inferred.
- Keep the read **natural**: introduce an idea, flag, or shorthand **before** later bullets rely on it; later sections **reinforce** earlier ones instead of assuming context the reader has not seen yet.
- When a later step reuses a job arg, flag, or pattern from an earlier path (for example prepaid bulk work before single-message workers), **order sections** so the bulk path comes first and the name is defined before reuse.

### Guidelines (heuristics, not rules)

- Details that **often** strengthen the mental picture: persistent shape changes (new columns, tables, enums), new entry points (functions, workers, modules), new pages or routes, and behavior shifts someone would notice (limits, failures, permissions, customer-visible outcomes).
- Details that **often** distract unless the sketch is mainly about them: wiring like which associations get preloaded for a task, boilerplate or ceremony that does not change the story.
- **You decide** what belongs in *this* summary: weigh each sketch area against the narrative you are building; bend or skip these heuristics whenever that serves the clearest top-to-bottom picture of the approach.

### Canonical shape (must match **Exemple**)

- **No YAML** inside `plan`; **CreatePlan** supplies frontmatter. Your `plan` argument is only the markdown body.
- **No `#` headings.** Titles and section labels use `**bold**` only.
- **First line:** one `**Title**` line (issue headline style, not "summary of…").
- **Blank line**, then the numbered **sections** (the example does not use a horizontal rule). **No** prose between the title and `**1. …**`. Do **not** insert a `**Main ideas**` line (or any other label) between the title and the sections.
- **Sections:** `**1. Short label**`, `**2. Short label**`, … where each label names a **story beat** (plain words; not a phase title pasted from the sketch). You may add **at most one** optional parenthetical immediately after the closing `**`, containing **a single** backticked module or worker name—same style as **Single message sends** / `SendMessage` in the example. **Do not** put several module names in one heading parenthesis; pick the one anchor a reader needs. Expect roughly **4–7** numbered sections for a typical sketch (the example uses **5**); merge or split so the section count matches how many beats the narrative needs.
- Under each section: top-level `-` bullets—prefer **2–3**; **4** top-level bullets in one section is acceptable when several distinct beats belong together (see example **Blasts and campaigns**). Each top-level bullet carries **one** main idea. You may add **one short level** of nested `-` sub-bullets under a parent bullet for brief numbers or other key detail **only** when it belongs with that point (nested limits under example **1. Monthly limits**; an optional nested skip-debit line under example **4. Single message sends**). Keep sub-bullets to a handful of words each; do not nest deeper than one level.
- Use `` `backticks` `` for modules, functions, atoms, flags, JSON keys, Redis key patterns, and other code-ish tokens. **Do not** use markdown links, **do not** paste repo paths like `lib/...`, and **do not** enumerate files the way the sketch does unless a single backticked module name is the clearest way to name a touchpoint.
- **Standalone `plan` body:** Do **not** reference the source sketch, phased write-up, Linear ticket, or “see elsewhere” framing; nothing in the markdown should assume the reader will open another doc.

### Length budget (non-negotiable)

Match the example’s **telegraph style**, not a compressed sketch. Other sketches should **feel** the same (short beats, plain words, natural order) even when the section topics differ.

- **Each bullet (top-level or nested):** **≤ 28 words**; aim **≤ 22**. At most **one semicolon** per bullet—if you reach for a second clause, make a second bullet or delete the lower-value clause.
- **Wording:** Prefer short domain verbs (`debit`, `rollback`, `queue`, `cancel`) over wiring narration (`perform/1`, long `with` chains) unless a backticked symbol is the clearest single token for that idea.
- **Omit from this summary** unless the example would include an analogue: tuning knobs or algorithm constants, dev-only or parity-only mechanics, stakeholder or process asides, and fine-grained sequencing that only restates an invariant you already captured in one short bullet.
- **Automated tests:** Do **not** mention routine tests, test files, assertions, suites, or regression plans in any heading or bullet. The **only** exception is when the sketch’s **central** outcome is testing work.

### Language and scan

- **Plain and short:** write for someone glancing down the page; favor tight phrases over long sentences when the meaning stays clear.
- **Repo vocabulary:** follow the product’s words (for Surge work, prefer **messages** and **verifications** over casual “texts” and “codes” unless the sketch is explicitly about something else).
- **No mystery abbreviations:** spell words out (**transaction**, not **txn**). Use `` `backticks` `` for real code identifiers (modules, functions, atoms, flags, keys). Do not invent cryptic shorthand just to save space.
- **UI wording:** never use **copy** to mean on-screen text; say **strings**, **wording**, **labels**, or **response** phrasing.

### Anti-patterns

- Rewriting the sketch **phase-by-phase** with long section titles copied from `### Phase N`.
- Bullets that are mostly **file paths** or `[label](path)` links to source.
- Extra prose between the title and the first numbered section (mini-spec lead-in instead of jumping straight into sections).
- Meta pointers in the summary body ("see the sketch", "phase N", "details in the plan", ticket links).
- A closing line such as `Tracks [TICKET](https://linear.app/...)` in the summary body. The Linear link belongs **only** in Step 4’s Slack parent message, not here.
- Mentioning **automated tests** (files, suites, regression strategy) when the sketch is **not** centrally about testing work.
- **Mega-bullets:** one `-` line that chains many clauses, names multiple helpers, or narrates control flow the way the sketch does (for example `perform/1` plus `with` chain propagation in the same bullet).
- **Heading sprawl:** parentheticals listing several modules, or section titles that read like phase titles from the sketch.
- **Extra machinery** called out as its own bullet when the example would stay silent (for example development stub parity for a limiter) unless skipping it would mislead a reader about scope.
- **Abbreviation for brevity alone** (for example **txn** for transaction) when the full word still scans well.

### Voice

Stack **decisions and contracts** into one coherent image (see **Mindset** in this appendix). The `plan` body should read **standalone** and complete for orientation; the sketch file remains optional drill-down. If a line does not help answer “what are the main things I need to understand?”, cut it.

#!/usr/bin/env python3
"""Summarize-sketch Slack payloads: print one minified JSON line = slack_send_message `arguments`.

  python3 summarize_sketch_slack.py parent --linear 'https://linear.app/...' --title 'Short headline'
  python3 summarize_sketch_slack.py thread --plan /abs/summary.md --thread-ts '1234567890.123456'
"""
import argparse
import json
import sys
from pathlib import Path

SLACK_DM_CHANNEL_ID = "U0APWBBSRC4"


def die(message: str) -> None:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def strip_yaml_frontmatter(text: str) -> str:
    lines = text.splitlines(keepends=True)
    if not lines:
        return text
    if lines[0].strip() != "---":
        return text
    idx = 1
    while idx < len(lines) and lines[idx].strip() != "---":
        idx += 1
    if idx >= len(lines) or lines[idx].strip() != "---":
        return text
    return "".join(lines[idx + 1 :])


def slice_from_first_title_line(text: str) -> str:
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.strip().startswith("**"):
            return "".join(lines[index:])
    die("No **...** headline line found (expected plan body to start with a bold title line).")


def emit_slack_send_message_args(payload: dict) -> None:
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))


def cmd_parent(args: argparse.Namespace) -> None:
    title_stripped = args.title.strip()
    if not title_stripped:
        die("Empty --title.")
    message = f"plan for [{title_stripped}]({args.linear}) :thread:"
    emit_slack_send_message_args(
        {"channel_id": SLACK_DM_CHANNEL_ID, "message": message}
    )


def cmd_thread(args: argparse.Namespace) -> None:
    plan_path = Path(args.plan)
    if not plan_path.is_file():
        die(f"Not a file: {plan_path}")
    raw = plan_path.read_text(encoding="utf-8")
    without_frontmatter = strip_yaml_frontmatter(raw)
    body = slice_from_first_title_line(without_frontmatter)
    emit_slack_send_message_args(
        {
            "channel_id": SLACK_DM_CHANNEL_ID,
            "thread_ts": args.thread_ts,
            "message": body,
        }
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Emit one-line JSON for slack_send_message MCP arguments."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    parent_parser = subparsers.add_parser(
        "parent", help="Parent DM (link text from --title)"
    )
    parent_parser.add_argument(
        "--linear",
        required=True,
        help="Full Linear issue URL (plain https://...).",
    )
    parent_parser.add_argument(
        "--title",
        required=True,
        help="Short plain-text headline for the parent Slack link.",
    )
    parent_parser.set_defaults(func=cmd_parent)

    thread_parser = subparsers.add_parser(
        "thread", help="Thread reply body (markdown from first ** line through EOF)."
    )
    thread_parser.add_argument(
        "--plan",
        required=True,
        help="Absolute path to the same summary markdown file.",
    )
    thread_parser.add_argument(
        "--thread-ts",
        required=True,
        dest="thread_ts",
        help="message_context.message_ts from the parent slack_send_message result.",
    )
    thread_parser.set_defaults(func=cmd_thread)

    parsed = parser.parse_args()
    parsed.func(parsed)


if __name__ == "__main__":
    main()

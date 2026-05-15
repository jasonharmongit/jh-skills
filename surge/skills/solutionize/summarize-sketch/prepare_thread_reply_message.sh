#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <plan.md>" >&2
  echo >&2
  echo "  Step 7: read the plan file, drop YAML frontmatter, keep from the first" >&2
  echo "  **...** headline line through EOF, and print the exact Slack reply" >&2
  echo "  message to stdout. Use stdout directly as slack_send_message message." >&2
  exit 1
}

die() {
  echo "$*" >&2
  exit 1
}

[[ $# -eq 1 ]] || usage

plan_file=$1

[[ -f "$plan_file" ]] || die "Not a file: $plan_file"

python3 - "$plan_file" <<'PY'
import sys


def strip_yaml_frontmatter(text):
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


def slice_from_first_title_line(text):
    lines = text.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if line.strip().startswith("**"):
            return "".join(lines[index:])
    sys.exit("No **...** headline line found (expected plan body to start with a bold title line).")


plan_path = sys.argv[1]
raw = open(plan_path, encoding="utf-8").read()
without_frontmatter = strip_yaml_frontmatter(raw)
message = slice_from_first_title_line(without_frontmatter)
print(message, end="")
PY

#!/usr/bin/env bash
# Collapse latest claude[bot] and greptile-apps[bot] issue comments on the current
# branch's PR (or on --pr NUMBER). Install as `cbc`: see README.md in this directory.

# Exit on failed commands / unset vars; pipeline fails if any stage fails.
set -euo pipefail

usage() {
  echo "Usage: $0 [--pr NUMBER]" >&2
  exit 1
}

_pr=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --pr)
      [[ -n "${2:-}" ]] || usage
      _pr=$2
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [[ -n "$_pr" ]] && ! [[ "$_pr" =~ ^[0-9]+$ ]]; then
  echo "Invalid --pr (expected a positive integer): ${_pr}" >&2
  exit 1
fi

_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)

if [[ -z "$_pr" ]]; then
  _pr=$(gh pr view --json number -q .number 2>/dev/null) || {
    echo "No PR linked to the current branch (gh pr view failed). Pass --pr NUMBER." >&2
    exit 1
  }
fi

# One bot per call: rewrite that bot's latest *issue* comment, or return 0 if none.
maybe_collapse_latest_issue_comment() {
  local _login=$1
  local _strip_details=$2
  local _comment _comment_id _body _first_line _rest _new_body _got

  # PR comments live under issues/{n}/comments; --paginate merges pages into one array.
  _comment=$(gh api "repos/${_repo}/issues/${_pr}/comments" --paginate --jq --arg login "$_login" '
    map(select(.user.login == $login)) | sort_by(.updated_at) | last
  ')

  # Empty match → jq `last` is null — not an error (other bot may still have a comment).
  if [[ "$_comment" == "null" ]]; then
    return 0
  fi

  _comment_id=$(echo "$_comment" | jq -r .id)
  _body=$(echo "$_comment" | jq -r .body)

  # First line stays visible; rest goes inside one <details>. printf ensures a final \n for head/tail.
  _first_line=$(printf '%s\n' "$_body" | head -n 1)
  _rest=$(printf '%s\n' "$_body" | tail -n +2)

  # Greptile templates may include extra </details>; strip so our outer wrapper is well-formed.
  if [[ "$_strip_details" -eq 1 ]]; then
    _rest=$(printf '%s' "$_rest" | sed 's|</details>||g')
  fi

  _new_body="${_first_line}

<details>

${_rest}

</details>
"

  # JSON body on stdin handles multiline text; shell -f body=... is brittle here.
  jq -n --arg body "$_new_body" '{body: $body}' \
    | gh api --method PATCH "repos/${_repo}/issues/comments/${_comment_id}" --input -

  # Fail fast: do not run the second bot if this PATCH did not round-trip.
  _got=$(gh api "repos/${_repo}/issues/comments/${_comment_id}" -q .body)
  if [[ "$_got" != "$_new_body" ]]; then
    echo "Verification failed for ${_login}: fetched body does not match expected rewrite" >&2
    exit 1
  fi
}

# Order matters: Claude verify must succeed before we touch Greptile.
maybe_collapse_latest_issue_comment 'claude[bot]' 0
maybe_collapse_latest_issue_comment 'greptile-apps[bot]' 1

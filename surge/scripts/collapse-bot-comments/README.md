# collapse-bot-comments

Shell helper that wraps the latest **issue** comments from `claude[bot]` and `greptile-apps[bot]` on the current branch's GitHub PR in a single `<details>` block each (first line stays visible).

Repo: [jasonharmongit/jh-skills](https://github.com/jasonharmongit/jh-skills)

## Prerequisites

- [GitHub CLI](https://cli.github.com/) (`gh`), authenticated for the target repo
- `jq`

## Install as `cbc`

From your machine (repo default branch is `main`; adjust the URL if you use another branch):

```bash
mkdir -p ~/bin
curl -fsSL "https://raw.githubusercontent.com/jasonharmongit/jh-skills/main/surge/scripts/collapse-bot-comments/collapse-bot-comments.sh" -o ~/bin/cbc
chmod +x ~/bin/cbc
```

- **`mkdir -p ~/bin`** - Ensures a personal bin directory exists (`-p` avoids errors if it already exists).
- **`curl -fsSL ... -o ~/bin/cbc`** - Downloads the raw script from GitHub (`-f` fails on HTTP errors, `-sS` hides progress but shows errors, `-L` follows redirects) and saves it as `cbc`.
- **`chmod +x ~/bin/cbc`** - Marks the file executable.

If `which cbc` fails after that, `~/bin` is probably not on your `PATH` (macOS does not add it by default). Add to `~/.zshrc`, for example:

```bash
export PATH="$HOME/bin:$PATH"
```

Then `source ~/.zshrc` or open a new terminal.

## Usage

Run from a **git checkout inside the target repo** (so `gh repo view` resolves `owner/name`). The PR to edit is chosen in one of two ways:

1. **Default** - use the PR linked to the **current branch** (`gh pr view`):

```bash
cbc
```

2. **Explicit PR** - pass the PR number when the branch is not linked to a PR, or you want a different PR in the same repo:

```bash
cbc --pr 42
```

Only `--pr` is supported; any other argument prints a short usage line and exits with status 1.

# jh-skills

a directory of jason's personal skills

## list all skills

~~~bash
npx skills add jasonharmongit/jh-skills --list
~~~

## install a single skill

~~~bash
npx skills add jasonharmongit/jh-skills --skill <skill-name>
~~~

## install all skills

~~~bash

# all skills for a specific agent, global install
npx skills add jasonharmongit/jh-skills --skill '*' -a <agent> -g -y
~~~

this will install the proper `.<agent>` directory under your home directory. I tried with a few different ones and it seemed to always just install under a `.agents` directory.

valid agents list:

~~~
amp, antigravity, augment, bob, claude-code, openclaw, cline, codebuddy, codex, command-code, continue, cortex, crush, cursor, deepagents, droid, firebender, gemini-cli, github-copilot, goose, junie, iflow-cli, kilo, kimi-cli, kiro-cli, kode, mcpjam, mistral-vibe, mux, opencode, openhands, pi, qoder, qwen-code, replit, roo, trae, trae-cn, warp, windsurf, zencoder, neovate, pochi, adal, universal
~~~

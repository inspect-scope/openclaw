# TOOLS.md — Local Notes

Skills define how tools work. This file records the specifics of this Pi's setup.

## Host

- Hostname: `scope-pi`
- User: `scope-pi`
- Workspace path: `/home/scope-pi/Developer/openclaw/pi/workspace`
- Gateway: local mode, port `18789`, loopback bind

## Skills Available

- `notion` — requires `NOTION_API_KEY` in `~/.openclaw/.env`
- `openai-whisper-api` — requires `OPENAI_API_KEY`
- Google web search — via `plugins.entries.google.config.webSearch.apiKey`
  (resolved from `GOOGLE_API_KEY`)

## Channels

- Slack (primary): tokens resolved from `SLACK_BOT_TOKEN` and `SLACK_APP_TOKEN`.
  Socket Mode.

## GitHub (`gh` CLI)

- Binary: `gh` (installed via `apt`).
- Auth: reads `GITHUB_TOKEN` from `~/.openclaw/.env`, or `gh auth login` was run
  once interactively on the Pi. (`gh` accepts either `GH_TOKEN` or
  `GITHUB_TOKEN`; this workspace uses `GITHUB_TOKEN`.)
- Working repos live under `projects/<repo>/` inside this workspace. Clone with
  `gh repo clone <owner>/<repo> projects/<repo>` before the first PR.
- Default PR workflow: see `PR_FROM_SLACK.md`.

## Conventions

- Long outputs: prefer writing to a file in `memory/` and linking back in chat
  rather than dumping into Slack.
- Web search: only when the answer is time-sensitive or not in the workspace.
- GitHub: never force-push, never target `main` of a repo not owned by the user
  unless explicitly asked.

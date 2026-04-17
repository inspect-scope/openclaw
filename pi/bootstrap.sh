#!/usr/bin/env bash
# pi/bootstrap.sh
# Idempotent Pi configuration for OpenClaw.
#
# Reads nothing from the environment. Writes SecretRef entries into
# ~/.openclaw/openclaw.json so every secret is resolved from ~/.openclaw/.env
# instead of being stored as plaintext in config.
#
# Re-running is safe: `openclaw config set` overwrites the target path.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="${OPENCLAW_PI_WORKSPACE:-$REPO_ROOT/pi/workspace}"

log() {
  printf '{"scope":"pi-bootstrap","msg":%s}\n' "$(printf %s "$1" | jq -R .)"
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

require openclaw
require jq

log "workspace: $WORKSPACE_DIR"

# 1. Workspace
openclaw config set agents.defaults.workspace "$WORKSPACE_DIR"

# 2. Gateway defaults (safe to re-apply)
openclaw config set gateway.mode local
openclaw config set gateway.bind loopback
openclaw config set gateway.port 18789
openclaw config set gateway.controlUi.allowInsecureAuth true
openclaw config set session.dmScope per-channel-peer
openclaw config set tools.profile coding
openclaw config set skills.install.nodeManager pnpm

# 3. Secrets provider (env-backed)
openclaw config set secrets.providers.default --provider-source env
openclaw config set secrets.defaults.env default

# 4. SecretRefs for every credential. Values live in ~/.openclaw/.env.
#    Shape is { source: "env", provider: "default", id: "<ENV_VAR>" }.

# Google (web search + model auth profile)
openclaw config set plugins.entries.google.enabled true
openclaw config set plugins.entries.google.config.webSearch.apiKey \
  --ref-source env --ref-provider default --ref-id GOOGLE_API_KEY
openclaw config set tools.web.search.provider gemini
openclaw config set tools.web.search.enabled true

# Slack channel
openclaw config set channels.slack.enabled true
openclaw config set channels.slack.mode socket
openclaw config set channels.slack.dmPolicy open
openclaw config set channels.slack.groupPolicy disabled
openclaw config set channels.slack.capabilities.interactiveReplies true
openclaw config set channels.slack.botToken \
  --ref-source env --ref-provider default --ref-id SLACK_BOT_TOKEN
openclaw config set channels.slack.appToken \
  --ref-source env --ref-provider default --ref-id SLACK_APP_TOKEN

# Skills
openclaw config set skills.entries.notion.apiKey \
  --ref-source env --ref-provider default --ref-id NOTION_API_KEY
openclaw config set skills.entries.openai-whisper-api.apiKey \
  --ref-source env --ref-provider default --ref-id OPENAI_API_KEY

# 5. Hooks
openclaw config set hooks.internal.enabled true
openclaw config set hooks.internal.entries.session-memory.enabled true
openclaw config set hooks.internal.entries.boot-md.enabled true

log "done. next: 'openclaw secrets audit --check' then 'openclaw gateway restart'"

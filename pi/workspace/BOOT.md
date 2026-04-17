# BOOT.md

Run on every gateway startup (requires `hooks.internal.enabled = true` and
`hooks.internal.entries.boot-md.enabled = true`).

## Tasks

1. Verify that today's daily note exists at `memory/YYYY-MM-DD.md`. Create it if missing
   with a short header line for today's date.
2. If there are action items from yesterday's note that are not checked off, copy the
   open ones into today's note under a `## Carried over` section.
3. Do NOT send any chat message from this hook. Reply with `NO_REPLY` when finished.

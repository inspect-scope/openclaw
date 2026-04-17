# PR_FROM_SLACK.md — Runbook

When the user asks (in Slack or elsewhere) to open a pull request on GitHub, follow
this exact procedure. The goal is: a new branch, one commit with the intended
change, and a PR whose body is a short readme explaining the intent.

## Preconditions

- `gh` binary present and authenticated (`gh auth status` returns OK).
- Target repo is cloned under `projects/<repo>/` in this workspace. If it
  isn't, clone it first: `gh repo clone <owner>/<repo> projects/<repo>`.
- You have a concrete change to make. If the user asked for "a PR about X"
  with no file changes, ask what they actually want changed before continuing.

## Procedure

1. Determine target repo and default branch.
   - Repo: ask the user if it's ambiguous. Record it in this workspace's
     `memory/YYYY-MM-DD.md` for the session.
   - Default branch: `gh repo view <owner>/<repo> --json defaultBranchRef --jq .defaultBranchRef.name`.

2. Sync and branch.

   ```bash
   cd projects/<repo>
   git fetch origin
   git switch "<default-branch>"
   git pull --ff-only
   BRANCH="agent/$(date +%Y%m%d)-<short-slug>"
   git switch -c "$BRANCH"
   ```

3. Make the change. Keep it scoped to what the user asked for. If the change
   is purely documentation, the diff should be only documentation. Do not
   bundle unrelated edits.

4. Commit with a concise, action-oriented message.

   ```bash
   git add -A
   git commit -m "<type>: <short summary>"
   ```

5. Push the branch.

   ```bash
   git push -u origin "$BRANCH"
   ```

6. Open the PR. The body is the "readme explaining intent" — follow this
   template exactly.

   ```bash
   gh pr create \
     --repo <owner>/<repo> \
     --base "<default-branch>" \
     --head "$BRANCH" \
     --title "<same summary as commit>" \
     --body "$(cat <<'EOF'
   ## Intent

   <one paragraph: what this PR changes and why, in plain English>

   ## What changed

   - <bullet>
   - <bullet>

   ## How to verify

   - <one or two concrete checks a reviewer can run>

   ## Out of scope

   - <optional: anything explicitly not addressed, to prevent scope creep>

   ---
   Opened by the Scope Pi agent on request via Slack.
   EOF
   )"
   ```

7. Return the PR URL to the user in Slack. Keep the reply short:

   > Opened `<owner>/<repo>#<num>` — `<title>` → `<url>`

## Rules

- Never force-push to `main` or the default branch. Never open a PR against
  `main` of a repo you don't own unless the user explicitly asked for it.
- Never include secrets, tokens, or absolute home paths in the PR body or diff.
- If the change touches more than a handful of files, stop and summarize what
  you plan to do in Slack before committing. Let the user approve first.
- If `gh auth status` fails, do not attempt to open a PR. Tell the user the
  token needs to be refreshed and quote the exact command:
  `gh auth login` (interactive) or set `GITHUB_TOKEN` in `~/.openclaw/.env`.
- On failure at any step, do not leave a half-done branch pushed. Either
  finish the PR or delete the branch:
  `git push origin --delete "$BRANCH" && git switch "<default-branch>"`.

## One-liner sanity check (useful before first real run)

```bash
gh auth status && gh api user --jq .login
```

Any failure here means auth is not ready.

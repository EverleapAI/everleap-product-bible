# Read-only Claude Code setup (for collaborators)

If you have **Read** access to this repo, you already can't change the canonical code —
GitHub blocks you from pushing. This file is an *extra* layer: it stops Claude Code from
editing files even on your **own** laptop, so your local clone stays a clean, trustworthy
reference of what's actually shipped.

This is optional but recommended if your role is "understand Everleap and help design,"
not "commit code."

## One-time setup

1. Clone the repo and `cd` into it.
2. Create a folder named `.claude` at the repo root if it doesn't exist.
3. Copy the example file in this folder into it, renamed to `settings.local.json`:

   ```bash
   cp docs/onboarding/claude-readonly.settings.local.json.example .claude/settings.local.json
   ```

   (`.claude/settings.local.json` is gitignored, so this only affects your machine.)

4. Start Claude Code in the repo folder:

   ```bash
   claude
   ```

That's it. Claude can now read every file, search the code, run the app, and answer
questions about how Everleap works — but its `Edit` / `Write` tools are denied, so it
can't modify source. If you later want to actually make changes, delete that file (and
you'll need Write access on GitHub to push them).

## What Claude can and can't do in this mode

| Can | Can't |
|---|---|
| Read any file, including the whole Bible | Edit or create files |
| Search / grep the codebase | Push to the repo (GitHub Read role blocks this regardless) |
| Explain architecture, flows, screens | Silently change your reference clone |
| Propose designs and new-screen ideas | — |

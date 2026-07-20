# Giving Claude access to the Everleap database

This sets up Claude Code so it can read the Everleap database and help you write
documentation grounded in what's actually in the product — not what we remember being in it.

You do not need to know SQL. Once this is working you ask Claude questions in plain English
("how many careers do we have content for?", "which badges has nobody earned?") and it writes
the queries itself.

**Time:** about 15 minutes, most of it waiting on downloads.

---

## What you're being given, and what you can't break

You get a database login called `everleap_docs_ro`. It can **read every table and write
nothing** — that's enforced by the database itself, not by a setting anyone can toggle. It
holds zero write permissions on all 45 tables, cannot create or delete anything, and every
query it runs is capped at 30 seconds and 1000 rows.

So: **you cannot damage the product with this.** Run whatever you like. The worst outcome is
a query that returns nothing useful.

Two things to know:

- This is the **live** database — the same one dev.everleap.ai runs on. What you read is real,
  including real (internal) user accounts and their answers. Treat what you see as
  confidential, and don't paste personal data into documents.
- Your password is yours. Don't share it or commit it to a repo. If it leaks, tell Tom and
  we'll rotate it in about a minute.

---

## Before you start

Ask Tom for:

1. Your **database password** (he'll send it via a password manager, not Slack)
2. Confirmation your **IP address has been allowlisted** — the database refuses all
   connections from unknown networks. Get your IP from [whatismyip.com](https://whatismyip.com)
   and send it to him.

> **The one thing that will confuse you later:** if you work from a different location — home
> vs office, or a coffee shop — your IP changes and the database will stop accepting you. The
> symptom is a connection timeout that looks like the database is down. It isn't. Send Tom
> your new IP.

---

## Step 1 — Install Node.js

Claude needs this to run the database connector. Skip if you already have it.

Go to [nodejs.org](https://nodejs.org) and download the **LTS** version. Run the installer,
accept all defaults.

**Check it worked.** Open a terminal:

- **Mac:** press `Cmd+Space`, type `Terminal`, press Enter
- **Windows:** press the Start key, type `PowerShell`, press Enter

Type this and press Enter:

```
node --version
```

✅ You should see something like `v22.14.0`. Any version starting `v20` or higher is fine.

❌ If you get "command not found", the install didn't finish — restart the terminal first,
since it only picks up new programs when it starts.

---

## Step 2 — Install Claude Code

Skip if you already have it. In the same terminal:

```
npm install -g @anthropic-ai/claude-code
```

This takes a minute or two and prints a lot of text. That's normal.

**Check it worked:**

```
claude --version
```

✅ You should see a version number.

---

## Step 3 — Install the database connector

```
npm install -g @bytebase/dbhub
```

✅ Ends with something like `added 264 packages`.

---

## Step 4 — Create your connection file

This file tells the connector which database to open and with what password.

**Don't create this by hand in a text editor.** On Windows especially, Notepad silently adds
`.txt` to the filename and nothing works. Use the command below instead — it writes the file
correctly for you.

Copy the whole block, replace `PASTE_YOUR_PASSWORD_HERE` with the password Tom sent, then paste
it into your terminal and press Enter.

**On Mac:**

```bash
mkdir -p ~/everleap && cat > ~/everleap/dbhub.toml <<'EOF'
[[sources]]
id = "everleap"
dsn = "postgresql://everleap_docs_ro:PASTE_YOUR_PASSWORD_HERE@everleap-db.postgres.database.azure.com:5432/everleap_dev?sslmode=require"

[[tools]]
name = "execute_sql"
source = "everleap"
readonly = true
max_rows = 1000
EOF
```

**On Windows (PowerShell):**

```powershell
New-Item -ItemType Directory -Force "$HOME\everleap" | Out-Null
@'
[[sources]]
id = "everleap"
dsn = "postgresql://everleap_docs_ro:PASTE_YOUR_PASSWORD_HERE@everleap-db.postgres.database.azure.com:5432/everleap_dev?sslmode=require"

[[tools]]
name = "execute_sql"
source = "everleap"
readonly = true
max_rows = 1000
'@ | Set-Content -Path "$HOME\everleap\dbhub.toml" -Encoding utf8
```

> If your password contains `@`, `/`, `#` or `?`, tell Tom — those characters break connection
> strings and he'll reissue you one without them. (The password he generated for you
> deliberately avoids them, so this shouldn't come up.)

**Check it worked:**

- **Mac:** `cat ~/everleap/dbhub.toml`
- **Windows:** `Get-Content "$HOME\everleap\dbhub.toml"`

✅ You should see the file contents with your real password in place of the placeholder.

---

## Step 5 — Connect it to Claude

**On Mac:**

```bash
claude mcp add --scope user everleap-db -- dbhub --config ~/everleap/dbhub.toml
```

**On Windows (PowerShell):**

```powershell
claude mcp add --scope user everleap-db "--" dbhub --config "$HOME\everleap\dbhub.toml"
```

The `--` in the middle is not a typo and is not optional. It tells Claude Code "everything
after this belongs to the other program."

> **Windows: the quotes around `"--"` matter.** PowerShell treats a bare `--` as its own
> punctuation and removes it before Claude Code ever sees it — you'll get
> `error: unknown option '--config'`. The quotes stop that. Mac users don't need them.

`--scope user` means the connection works in every folder, so you never have to think about
where you started Claude.

**Check it worked:**

```
claude mcp list
```

✅ You should see `everleap-db` listed with a ✓ or "connected".

---

## Step 6 — Ask it something

Start Claude:

```
claude
```

Then type:

```
Using the everleap database, how many rows are in explore_paths?
```

✅ It should answer **1036** (or a slightly higher number as content grows).

If you get that, you're done. Everything below is for when something goes wrong.

---

## When it doesn't work

Work down this list — it's ordered by how often each thing is the cause.

**"Connection timed out" / it hangs then fails**

Your IP isn't allowlisted, or it changed. This is the most common cause by a distance.
Get your IP from [whatismyip.com](https://whatismyip.com) and send it to Tom.

**"password authentication failed"**

The password didn't land in the file correctly — usually a missing character when pasting, or
the placeholder text never got replaced. Redo Step 4.

**"MCP error -32000: Connection closed"**

The connector isn't starting. Diagnose it by running the command by itself, outside Claude:

```
dbhub --config ~/everleap/dbhub.toml
```

(Windows: use `"$HOME\everleap\dbhub.toml"`.)

You should see a `DBHUB` banner and "MCP server running on stdio". Press `Ctrl+C` to stop it.
Whatever error you see here is the real problem — and it means the issue is the connector or
your config, not Claude.

If that command says `dbhub` isn't recognised, redo Step 3, then close and reopen your terminal.

**`error: unknown option '--config'` (Windows)**

You missed the quotes around `"--"` in Step 5. See the note there.

**Windows only — still `Connection closed` after all that**

This was tested on Windows 11 and the plain command in Step 5 works, so you probably won't
need this. But older write-ups recommend wrapping the command, and if nothing else has worked
it costs nothing to try:

```powershell
claude mcp remove everleap-db -s user
claude mcp add --scope user everleap-db "--" cmd /c dbhub --config "$HOME\everleap\dbhub.toml"
```

**Claude says it can't find the database / doesn't use it**

Say "everleap database" explicitly in your question. Claude has many tools and sometimes needs
pointing at the right one.

---

## What's actually in there

45 tables. These are the ones worth knowing for documentation:

| Table | What it holds |
|---|---|
| `explore_paths` | Every career/path we have content for (~1,036) |
| `specialty_content` | The deep per-specialty writing (~5,075) — day beats, pay, outlook |
| `questions` / `question_options` | The story questions we ask users |
| `badges` / `user_badges` | The 24 badges and who has earned which rung |
| `time_twin_figures` | The historical figures in Time Twin |
| `onet_occupations` | The official US occupation taxonomy we anchor careers to |
| `day_scene_images` | Generated scene photos (~3,237) |
| `us_zip_codes` | Zip lookup for "near you" features |

Tables beginning `user_`, plus `users`, `sessions`, `passkeys` and `email_codes`, are real
people's accounts and answers. Readable, but that's internal team data — please don't quote it
into documents.

Good opening question once you're connected:

```
Using the everleap database, list every table with its row count and tell me what each one
seems to be for.
```

---

## Reference

- Login: `everleap_docs_ro` — SELECT on all tables, zero write permissions, 30s query timeout
- Host: `everleap-db.postgres.database.azure.com`, database `everleap_dev`
- Connector: [`@bytebase/dbhub`](https://github.com/bytebase/dbhub) v0.24.0

Verified working end to end on 2026-07-20.

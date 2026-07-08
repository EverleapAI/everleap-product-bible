# Changelog

## Purpose

This document tracks the build history of Everleap's two core repositories: `apps/web` (frontend) and `apps/everleap-api` (backend). Unlike `094_ARCHITECTURE_DECISION_RECORDS.md`, which captures the *reasoning* behind major decisions, this changelog captures *what shipped and when*, derived from real commit history.

Both repos are young — `everleap-api` has 5 commits total, `web` has a much longer history dominated by iterative frontend rebuilds. Commit messages in `web` are noticeably less descriptive in its early history ("Your commit message here" appears repeatedly), which is itself useful context: treat early commit messages as low-signal and prefer reading the diffs directly if precise historical detail is ever needed.

This document should be updated periodically rather than maintained commit-by-commit — its job is to mark eras and milestones, not replace `git log`.

---

# `apps/everleap-api` — Full History

The backend has a short, clear history: it was built from scratch as a dedicated API, replacing whatever served the frontend before.

| Commit | Description |
|---|---|
| `65ce215` | Initial Everleap API — first commit of the dedicated backend |
| `409bc51` | Create deploy.yml — GitHub Actions CI/CD added |
| `3a3e978` | Verify GitHub deploy |
| `1579f5c` | Deploy passkey auth flow — WebAuthn/passkey authentication shipped |
| `fd0aff2` | Update dev API code (current HEAD as of this writing) |

This confirms the backend is genuinely new — the entire Generation Pipeline, science memo system, Today/Insights generators, and auth system described throughout this Implementation section were built within these 5 commits' worth of iteration (each commit here represents substantial accumulated work, not 5 small changes).

---

# `apps/web` — Eras (from full history, newest first)

The frontend has a much deeper history. Reading it in reverse chronological order surfaces a few clear eras:

## Era: Story Experience Rebuild (most recent)
Repeated `"Rebuild Story experience"` commits, immediately preceded by `"Update dev frontend"` commits — indicates the Story page/flow underwent a deliberate, multi-pass rebuild recently. Anyone working in `apps/web/src/app/(app)/main/story` should assume this is the most actively-changing part of the frontend right now.

## Era: Today/Journey Refinement
`"Tighten Today mobile experience"`, `"Refine Today page and Journey experience"` — mobile polish pass on the Today experience, Everleap's "heartbeat" page per `031_TODAY.md`.

## Era: Sandbox UI
`"Update sandbox UI"` (×2) — likely the AI Lab or an internal testing surface, consistent with the AI Lab tooling described in `106_TESTING_STRATEGY.md`.

## Era: Turnstile / Bot Protection
A dense run of commits: `"Add Turnstile dependency"`, `"Temporarily bypass Turnstile gating in dev onboarding"` (×2), `"Restore Turnstile token requirement for onboarding synthesis"`, `"Add Turnstile site key diagnostic on onboarding"`, `"Redeploy with Turnstile site key build secret"`, `"Pass Turnstile site key into frontend build"`, plus several `"Update main_everleapui.yml"` / "Redeploy frontend with Turnstile env" commits. This was clearly a fight to get Cloudflare Turnstile (bot protection) correctly wired through the CI build-time env injection described in `105_DEPLOYMENT.md` — several back-and-forth bypass/restore commits suggest this took multiple iterations to get right in production. `TURNSTILE_SECRET_KEY` and `NEXT_PUBLIC_TURNSTILE_SITE_KEY` are now required env vars per `105_DEPLOYMENT.md`.

## Era: AI Lab
A long run of `"Add internal AI Lab with provider comparison"` commits (12+ in sequence) — the manual prompt/provider comparison tool documented in `106_TESTING_STRATEGY.md` and `104_PROMPT_CATALOG.md` was built iteratively over many small commits.

## Era: Unlabeled commits
A block of `"Your commit message here"` commits — these are real shipped changes with placeholder messages (likely committed via a tool or script with a default message that was never edited). Treat these as undocumented; if their content matters, read the diff rather than trusting the message.

## Earliest commits
- `chore: initial import of Everleap front-end` — the actual first commit
- `ci: add Azure Static Web Apps deploy workflow`
- `ci: use Azure/static-web-apps-deploy@v1`
- `ci: explicitly skip managed functions (skip_api_build: true, api_location: '')`
- `fix(swa): remove staticwebapp.config.json to allow Next.js SSR routing`

This confirms the migration story referenced in `105_DEPLOYMENT.md`: the frontend originally deployed via Azure Static Web Apps, then moved to Azure Web App (App Service) with `azure/webapps-deploy@v3` — the early `ci:` and `fix(swa):` commits are the tail end of discovering that SWA's static-hosting model didn't fit Next.js SSR routing well, which is why `staticwebapp.config.json` was removed and the pipeline was eventually replaced.

---

# How to Keep This Updated

When a meaningful era of work completes (a feature ships, a migration finishes, a system is replaced), add an entry here summarizing what changed and why — in the same spirit as the eras above, not a line-by-line commit mirror. If the *why* behind a change is significant enough to matter for future engineers, it likely belongs in `094_ARCHITECTURE_DECISION_RECORDS.md` instead, with a pointer left here.

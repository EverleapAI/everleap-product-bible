# Getting Started (Run It Locally)

> The fastest path from a fresh clone to a running app. For the *why*, read the
> rest of the Bible top-down (`README.md`); for deeper build/deploy detail see
> `105_DEPLOYMENT.md`; for day-to-day working habits see `109_EVERLEAP_PLAYBOOK.md`.
> This section is an **as-built** reference — if anything here has drifted from the
> code, the docs are wrong, not the code.

---

## The shape of the system in one paragraph

Everleap is a monorepo at `C:\Projects\everleap-app`, with the two apps under
`apps/`. **`apps/web`** is a Next.js 15 (App Router) frontend that also acts as a
thin backend-for-frontend: the browser never calls the API host directly — it
calls same-origin `/api/*` routes that forward the session cookie to the backend
(the backend has **no CORS**). **`apps/everleap-api`** is an Azure Functions (v4)
TypeScript backend; it holds all the data and all the AI. The database is
Postgres. AI runs in the **background** (a generation queue), writes results to
the DB, and pages just read them — see `060_SYSTEM_ARCHITECTURE.md`
("pages consume knowledge; they never create it").

There is **no root workspace** — each app installs and runs independently.

---

## Prerequisites

- **Node** (Node 22 target) and npm.
- **Azure Functions Core Tools** (`func`) — the backend runs on it.
- Access to the shared **dev Postgres** connection string and the API keys
  (they live in `apps/everleap-api/local.settings.json`, which is git-ignored —
  get it from the team; never commit it).

---

## 1. Backend — `apps/everleap-api`

```bash
cd apps/everleap-api
npm install          # postinstall runs the tsc build into dist/
npm start            # prestart cleans + builds dist/, then runs `func start`
```

- Serves on the default Functions port **7071** → base URL `http://localhost:7071/api`.
- **Compiled-`dist/` gotcha:** `package.json` `main` is `dist/src/functions/**/*.js`,
  so the host runs **compiled JS, not your `src/*.ts`**. `npm start` rebuilds via
  `prestart`. If you ever run `func start` directly, run `npm run build` first or
  your edits won't be served.
- Secrets come from `apps/everleap-api/local.settings.json` (git-ignored). Keys
  used: `POSTGRES_URL`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `ONET_API_KEY`,
  `BLS_API_KEY`, `RESEND_API_KEY`, `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN` /
  `TWILIO_VERIFY_SERVICE_SID`, `TURNSTILE_SECRET_KEY`, `PROMPT_LAB_PASSCODE`.
  Missing keys degrade gracefully (e.g. no `ONET_API_KEY` → no O\*NET grounding),
  they don't crash the host.

## 2. Frontend — `apps/web`

```bash
cd apps/web
npm install
# point the web app at your local backend:
echo "NEXT_PUBLIC_API_BASE_URL=http://localhost:7071/api" > .env.local
npm run dev          # next dev on port 3000
```

- Open **http://localhost:3000**.
- **Env-var name split (real gotcha):** the `/api/*` route handlers and
  `next.config.ts` rewrites read **`NEXT_PUBLIC_API_BASE_URL`**; the older typed
  client `src/lib/api.ts` reads **`NEXT_PUBLIC_API_BASE`** (no `_URL`). If you
  touch both code paths, set both. If `NEXT_PUBLIC_API_BASE_URL` is unset, the
  route handlers still default to `http://localhost:7071/api`.
- `apps/web/deploy-local.ps1` is a convenience script that writes `.env.local`
  and starts `next dev`.

## 3. Database

- Access is a `pg.Pool` from `apps/everleap-api/src/lib/db.ts`, built from
  `POSTGRES_URL` (SSL on). Everything imports `{ db }` from there.
- Schema lives as plain SQL: numbered migrations in
  `apps/everleap-api/migrations/` (`001_…` … `007_user_interest_profiles.sql`)
  plus dated schema scripts in `apps/everleap-api/scripts/*.sql`.
- **There is no migration runner** in the repo — migrations/scripts are applied
  manually against `POSTGRES_URL` (e.g. via `psql`). Confirm the current DB state
  with the team before applying anything. Full table reference: `100_DATABASE_SCHEMA.md`.

---

## Auth, locally

Auth is a **session cookie** (`everleap_session`). Web middleware guards
`/main/*` and redirects to `/regauth` when the cookie is absent; Functions are
`authLevel: "anonymous"` and read the forwarded cookie via
`getCurrentUserFromRequest` (`src/lib/currentUser.ts`). To drive an authenticated
page without going through the full magic-link flow, mint a session row directly
in the `sessions` table for a test user and set the `everleap_session` cookie
(this is how the local browser-verification harness works).

---

## Making a change — the mental model

- **A user-facing page needs data?** It reads it from a `/api/*` route
  (`apps/web/src/app/api/**/route.ts`) that proxies a Function
  (`apps/everleap-api/src/functions/**`, registered with `app.http` and served at
  `/api/<route>`). Pages must not call a model inline.
- **New AI output?** It's produced by a **generator** behind the generation
  queue, keyed by a **generation target** (`generationRegistry.ts`), triggered by
  `requestUserGeneration`, and picked up by the per-minute `generationTimer`. See
  `102_GENERATOR_REGISTRY.md` and `103_EVENT_FLOW.md`. The model is Claude via
  `runAnthropic` (`lib/guidance/shared/anthropic.ts`); every call is costed into
  `ai_usage_audit` unless suppressed (`EVERLEAP_SUPPRESS_AI_AUDIT=1`, or the
  per-call `suppressAudit` flag — used only by one-off/warming scripts).

---

## Deploy (dev)

Pushing to `main` on each app's repo auto-deploys to the dev environment
(`apps/everleap-api` → the `everleap-api-dev` Function App; `apps/web` → the dev
web app). Full pipeline + environment config: `105_DEPLOYMENT.md`.

---

## Where to go next

- `108_INDEX.md` — the map of this whole Implementation section.
- `109_EVERLEAP_PLAYBOOK.md` — how to actually work in this codebase day to day.
- `100_DATABASE_SCHEMA.md` / `101_API_CONTRACTS.md` — the concrete data + endpoint contracts.
- `06_Architecture/063_EXPLORE_ARCHITECTURE.md` — the largest subsystem, end to end.

# Deployment

## Purpose

This document describes how Everleap is actually deployed today — two fully independent pipelines, one per app, both GitHub Actions targeting Azure.

---

# Frontend — `apps/web` (Next.js 15)

**Hosting:** Azure **Web App** (App Service), instance name `EverleapDevUi`.

This is worth stating plainly because several files in the repo suggest otherwise: `deploy-azure.ps1`'s filename and comments reference "Static Web Apps," and a dead `swa-cli.config.json.bak` file remains on disk. The project was migrated off Azure Static Web Apps at some point (a `staticwebapp.config.json` was deliberately removed, per the earlier `apps-structure.txt` history) and now deploys via `azure/webapps-deploy@v3` with a publish profile. Treat the Static Web Apps references as stale naming, not current architecture.

## CI/CD Pipeline

`.github/workflows/main_everleapui.yml` — "Deploy EverleapDevUi to Azure"

1. **Trigger:** push to `main`, or manual `workflow_dispatch`.
2. **Build environment:** Node 22, `npm ci --include=optional`.
3. **Build:** `npm run build` (→ `next build`), with build-time environment variables `NEXT_PUBLIC_API_BASE_URL` and `NEXT_PUBLIC_TURNSTILE_SITE_KEY` injected.
   - `next.config.ts` sets `output: "standalone"` only when `CI=true` — local builds don't produce a standalone bundle.
4. **Package:** a custom bash step assembles a flat `deploy/` folder from `.next/standalone` + `.next/static` + `public`. The step defensively checks three possible standalone-output path shapes, which suggests past pain getting Next's monorepo-aware output tracing to land in a predictable place.
5. **Deploy:** `azure/webapps-deploy@v3` pushes `deploy/` to `EverleapDevUi`, authenticated via the `AZURE_WEBAPP_PUBLISH_PROFILE` GitHub secret.
6. **Runtime entry point:** `server.mjs` — a plain Node HTTP server wrapping the Next standalone build.

## Local helper scripts (status: mixed)

| Script | What it actually does | Status |
|---|---|---|
| `deploy-azure.ps1` | Bumps `.deploy-trigger` and `git push`es to `main` to fire the workflow | Matches reality, despite the "Static Web Apps" naming |
| `deploy-local.ps1` | Writes `.env.local`, runs `next dev` | Local dev convenience only, not a real deploy |
| `deploy-preview.ps1` | Builds and serves a static `out/` export via `npx serve` | **Likely broken** — `next.config.ts` never sets `output: "export"`, so this script would not produce an `out/` directory at all |

## Required environment variables (names only)

`NEXT_PUBLIC_API_BASE_URL`, `SITE_BASIC_USER`, `SITE_BASIC_PASS`, `EVERLEAP_ACCESS_CODE`, `REGAUTH_COOKIE_SECRET`, `NEXT_PUBLIC_TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET_KEY`

## Other notes

- `.deployment` sets `SCM_DO_BUILD_DURING_DEPLOYMENT=true` (an Azure Kudu/Oryx setting) — somewhat redundant since GitHub Actions already builds the app before deploy.
- The repo has both `package-lock.json` and `pnpm-lock.yaml`, plus a `pnpm-workspace.yaml`, but CI uses `npm ci` exclusively. Pick one package manager when there's time to clean this up — right now it's silently tolerated rather than intentional.

---

# Backend — `apps/everleap-api` (Azure Functions)

**Hosting:** Azure Functions (Node/TypeScript), Function App instance `everleap-api-dev`.

## CI/CD Pipeline

`.github/workflows/deploy.yml` — "Deploy Everleap API"

1. **Trigger:** push to `main` only (no manual dispatch option, unlike the frontend).
2. **Build environment:** Node 22.x, `npm install`.
3. **Build:** `npm run build` (→ `tsc`, compiles `src/` to `dist/`).
4. **Deploy:** `Azure/functions-action@v1` pushes to `everleap-api-dev`, authenticated via `AZURE_FUNCTIONAPP_PUBLISH_PROFILE`.

## Runtime configuration

- `host.json`: Functions runtime **v2.0**, Application Insights sampling enabled (Request type excluded from sampling), extension bundle range `[4.*, 5.0.0)`.
- `.funcignore`: excludes `*.ts` source, `.vscode`, local Azurite emulator state, `local.settings.json`, `test`, `tsconfig.json` — only the compiled `dist/**` actually ships.
- **Trigger types in use:** HTTP triggers (the great majority of `src/functions/*`) plus one Timer trigger (`generationTimer.ts`, schedule `"0 * * * * *"` — see `103_EVENT_FLOW.md`).

## Required environment variables (names only)

`AzureWebJobsStorage`, `FUNCTIONS_WORKER_RUNTIME`, `POSTGRES_URL`, `RESEND_API_KEY`, `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `TWILIO_VERIFY_SERVICE_SID`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `NEXT_PUBLIC_TURNSTILE_SITE_KEY`, `TURNSTILE_SECRET_KEY`

---

# Environments

There is currently **one environment**: dev. Both Azure resource names make this explicit (`EverleapDevUi`, `everleap-api-dev`), and there is no separate production pipeline, despite `deploy-azure.ps1`'s docstring referring to it as "PROD." If/when a real production environment is introduced, it will need its own workflow (or environment-gated job), its own Azure resources, and its own publish-profile secrets — none of that branching exists today. Anything that merges to `main` on either repo ships straight to the only environment that exists.

---

# Known Deployment Debt

1. **Naming drift** — `deploy-azure.ps1` and dead config files reference Static Web Apps; the real target is App Service. Confusing for anyone onboarding who trusts the filenames.
2. **`deploy-preview.ps1` is likely non-functional** against the current Next config.
3. **Dual package managers** coexist without a clear choice.
4. **No production environment exists** — only dev. A push to `main` is effectively a push to whatever is currently being treated as "live."
5. **No test gate in either pipeline** (see `106_TESTING_STRATEGY.md`) — the only thing standing between a `main` push and a live deploy is successful compilation.

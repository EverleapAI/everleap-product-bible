# Testing Strategy

## Purpose

`093_ENGINEERING_PRINCIPLES.md` says: "Test behavior. Not implementation." This document describes what testing actually exists today in `apps/web` and `apps/everleap-api` — which, as of this writing, is **none**. That's not a guess; it's a confirmed finding, documented here so the gap is visible and intentional rather than silently inherited.

---

# Current State

## Automated tests: none

- No `jest.config.*`, `vitest.config.*`, `playwright.config.*`, or `cypress.config.*` exists in either app.
- No `*.test.ts(x)` / `*.spec.ts(x)` files or `__tests__/` directories exist anywhere under `apps/web/src` or `apps/everleap-api/src`.
- `apps/everleap-api/package.json`'s `test` script is literally:
  ```json
  "test": "echo \"No tests yet...\""
  ```
  This is an explicit acknowledgment in the codebase itself, not an oversight.
- `apps/web/package.json` has no `test` script at all — only `dev`, `build`, `start`, `lint`.

## CI: build-and-deploy only, no test gate

- `apps/web/.github/workflows/main_everleapui.yml`: checkout → `npm ci` → `npm run build` → package the standalone Next.js output → deploy to Azure Web App (`EverleapDevUi`). No test step exists in the pipeline.
- `apps/everleap-api/.github/workflows/deploy.yml`: checkout → `npm install` → `npm run build` (`tsc`) → deploy to Azure Functions (`everleap-api-dev`). No test step.

The only gate either pipeline enforces is **TypeScript compilation**. A type error blocks deploy. A logic error does not.

## Linting: partial

- `apps/web` has `eslint.config.mjs`, the `eslint` / `eslint-config-next` devDependencies, and a `lint` script — but it is not run in CI. It's available on demand, not enforced.
- `apps/everleap-api` has no ESLint configuration and no `eslint` dependency at all. No linting exists on the backend.

---

# What Exists Instead

## AI Lab — manual prompt/provider comparison, not a test suite

`apps/everleap-api/src/functions/aiLabRun.ts` (`POST /ai/lab/run`) and `apps/web/src/app/(app)/main/ai-lab/page.tsx` together form an internal tool, not an automated test:

- A person picks a provider (`anthropic` or `openai`), writes or selects a prompt template, and runs it against a sample set of onboarding-style answers.
- The backend runs a two-stage pipeline (internal analysis → user-facing compression) and returns both outputs plus latency, token usage, and estimated cost.
- Every run is recorded via `recordAiUsage` under `feature: "ai_lab_internal_analysis"` / `"ai_lab_user_compression"` for cost visibility.
- A human reads the output and judges whether it's good. There is no pass/fail assertion, no expected-output comparison, and no regression detection — running it twice with the same input does not tell you whether something broke.

This is valuable for prompt iteration (see `104_PROMPT_CATALOG.md`) but should not be mistaken for test coverage. It tests nothing about the generation pipeline, the database layer, or the auth flows.

---

# Why This Matters Here Specifically

Everleap's own engineering principles are unusually exacting about reliability and explainability for a product this young:

- `093_ENGINEERING_PRINCIPLES.md`: *"If engineers cannot answer those questions [why something happened]... users eventually won't trust the product."*
- `060_SYSTEM_ARCHITECTURE.md`: *"Fault Tolerance... No single generator should make the product unusable."*
- The generation pipeline (`071_GENERATION_REQUESTS.md`) is explicitly designed around retries, idempotency, and graceful degradation — properties that are very easy to silently break without a test catching it, given there's no test.

Concretely, today, nothing would catch:
- A change to `scienceConductor.ts`'s `hasUsefulAnswer` logic silently excluding a science from generation.
- A prompt change in `todayPrompt.ts` or `summaryNarrative.ts` that violates one of its own banned-phrase rules (e.g. reintroducing "you are..." language, which the product principles explicitly forbid).
- A regression in `generationDispatcher.ts`'s dependency-walk (`runGenerationRecursive`) that causes a science to be skipped before a page generator runs.
- Auth bypass on an endpoint that should require a session (several already don't enforce it intentionally — see `101_API_CONTRACTS.md`'s flagged findings on `getFlow`, `usageSummary`, `aiLabRun`, `summaryPreview`).

None of these would fail a build. They would only surface in production, or in a developer's manual testing.

---

# What Testing Could Look Like (Not Yet Built)

This section is a starting point for a future testing strategy, not a commitment — consistent with `092_DECISION_FRAMEWORK.md`'s instruction to ask "why now?" before building anything. In rough order of leverage relative to effort:

1. **Parser/fallback unit tests** — `todayParser.ts`, `insightsParser.ts`, and the per-science memo parsers all have explicit, deterministic validation and fallback logic. These are pure functions operating on JSON strings; they're the cheapest, highest-value place to start because they already encode the contract the AI output must satisfy.
2. **Deterministic-logic unit tests** — `insightConfidence.ts` and `everleapConvergence.ts` are confirmed to contain zero AI calls; they're pure scoring/aggregation functions over science memos. Easy to test, currently completely unverified.
3. **Generation dependency-graph tests** — verify `runGenerationRecursive` in `generationDispatcher.ts` resolves dependencies in the right order and doesn't re-run a shared dependency twice, using the real `generationRegistry.ts` definitions.
4. **API contract smoke tests** — for each function in `101_API_CONTRACTS.md`, a basic "does it return the documented shape for a valid request, and a 401 for an invalid session where one is required" test would catch auth regressions, which today are entirely manual.
5. **Prompt regression checks** — not full AI evaluation, but a lint-style check that prompt files don't contain any of their own banned phrases would catch an entire class of voice violations before they ship (see `104_PROMPT_CATALOG.md` for the banned-phrase lists already embedded in each prompt).

None of these require a CI test gate on day one — even running them manually before a deploy would be a meaningful improvement over the current state of zero automated verification.

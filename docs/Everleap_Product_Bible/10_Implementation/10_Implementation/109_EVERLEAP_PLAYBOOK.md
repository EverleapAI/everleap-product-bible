# Everleap Playbook

## Purpose

Everything else in `10_Implementation` documents one system at a time. This document is the synthesis — a practical guide for actually working in this codebase, written for an engineer (human or AI) picking up a task today. It assumes you've read the philosophy (`00_Foundation` through `09_Future`) and points to the relevant implementation doc rather than repeating it.

---

# The Shape of the System, in One Page

```
apps/web            Next.js 15 frontend — Today, Story, Insights, Explore, Career, onboarding, auth UI
apps/everleap-api   Azure Functions backend — auth, Story/onboarding persistence, AI generation pipeline
apps/vaccaroni      Unrelated static-HTML client site — not part of Everleap, ignore unless explicitly asked
```

Two independent git repos (`apps/web`, `apps/everleap-api`), two independent Azure deploy pipelines (`105_DEPLOYMENT.md`), one shared Postgres database (`100_DATABASE_SCHEMA.md`) that only the backend touches directly.

The core architectural law, enforced in practice: **pages never call AI.** A page reads previously generated knowledge from `user_page_guidance` / `user_science_insights`; a user action writes evidence and enqueues a generation request; a background worker (`generationTimer.ts`, once a minute) eventually does the AI work and writes the result back. See `103_EVENT_FLOW.md` for the full loop.

---

# Where to Start for Common Tasks

## "I need to change what Today says"
Read `104_PROMPT_CATALOG.md`'s Today section, then edit `guidance/today/todayPrompt.ts`. Check `todayParser.ts`'s validation rules before changing the output JSON shape — the parser validates each field independently, so a shape change there needs a matching parser change or guidance will silently fall back per-field. Test changes manually via AI Lab (`106_TESTING_STRATEGY.md`) before shipping — there's no automated test that would catch a regression.

## "I need to add a new science"
Follow the 6-step process in `102_GENERATOR_REGISTRY.md`'s "Extending the registry" section exactly. The `never` exhaustiveness check in `generationDispatcher.ts` will fail the TypeScript build if you skip the dispatcher branch, which is the one safety net that exists here.

## "I need to change what a generation request does, or when it fires"
Read `103_EVENT_FLOW.md` first to find the right call site (`storyAnswer.ts`, `storyComplete.ts`, `answerMicroTask.ts`, or the onboarding special case). Note that onboarding bypasses the queue entirely — if you're touching onboarding-triggered generation, you're not editing the same code path as everything else.

## "I need to add or change an API endpoint"
Read the relevant row in `101_API_CONTRACTS.md` first — note that `authLevel: "anonymous"` is set on every endpoint regardless of whether it should require a session; auth is enforced in-handler via `getCurrentUserFromRequest()`, and it's easy to forget to add that check on a new endpoint. Several existing endpoints (`getFlow`, `usageSummary`, `aiLabRun`, `summaryPreview`) don't enforce it — don't treat that as a pattern to copy without thinking about whether the new endpoint should be open.

## "I need to touch the database schema"
There is no migration system (`100_DATABASE_SCHEMA.md`). If you create a table, write a creation script under `apps/everleap-api/scripts/` (following `create-story-answer-table.ts` as a template) even though most existing tables don't have one — don't let the schema's existing debt be a reason to add more of it.

## "Something in production is wrong and I need to trace it"
Generation requests are fully observable via the `user_generation_requests` table (status, attempts, error_message, timestamps) — start there for anything generation-related. For guidance content itself, `source_snapshot` on `user_page_guidance` and `user_science_insights` preserves what evidence produced a given generation. AI cost/usage is in `ai_usage_audit`, queryable via `GET /ai/usage/summary` — though note the Insights Summary narrative call is the one generator not currently tracked there (`104_PROMPT_CATALOG.md`).

---

# Things That Will Surprise You

These are real gaps found by reading the code, not hypothetical risks. Knowing them up front will save time:

1. **No automated tests exist, anywhere, in either app.** (`106_TESTING_STRATEGY.md`) Manual verification via AI Lab and direct testing is the only safety net. Budget time for it; don't assume CI will catch a regression, because it currently only checks that TypeScript compiles.
2. **Several generation targets are registered but not implemented** — `page:explore`, `recommendation:careers`, `recommendation:actions`, `agent:coach`, `agent:mentor` are all stubs that log and return. If a page appears to silently not update, check whether its target is actually wired up in `generationDispatcher.ts`.
3. **Onboarding doesn't go through the generation queue.** It calls the Today generator directly and fire-and-forgets it. This is the one place in the system that doesn't follow the "background generation via queue" architecture described everywhere else.
4. **The Insights Summary's "signals" (the dot-rating display) are not AI-generated** despite reading like they are — `summarySignals.ts` is fully deterministic keyword matching. If asked to "make the signals smarter," the actual work is adding an AI call where there currently isn't one.
5. **Two parallel answer tables exist** (`user_question_answers` for onboarding, `story_question_answers` for Story) with no relationship between them, and two parallel "what sciences exist" sources of truth (a DB table and a hardcoded array) that aren't reconciled. Don't assume querying one gives you the full picture.
6. **There is only one deployed environment** (`105_DEPLOYMENT.md`) — both Azure resources are named `-dev`. A merge to `main` on either repo ships to the only environment that exists. Treat `main` accordingly.
7. **A few endpoints have no auth enforcement at all**, including one (`summaryPreview.ts`) with a hardcoded user ID — confirmed dev-debugging leftovers, not intentional public APIs. Don't assume an existing unauthenticated endpoint is unauthenticated on purpose.

---

# The One Rule That Matters Most

Every prompt in `104_PROMPT_CATALOG.md` carries the same core constraint, independently re-implemented in each file: never assign identity, never name the underlying science, never predict careers, always stay in hypothesis language. This is not incidental — it's `002_PRODUCT_PRINCIPLES.md`'s Principles 3, 4, and 5 made literal in code, down to shared example pairs (the fencing-academy bad-example appears in at least two separate prompt files and the Product Bible itself).

If you're writing or editing a prompt and you're not sure whether a phrase crosses a line, search the existing prompts for their banned-phrase lists first — they're more specific and more battle-tested than re-deriving the rule from the philosophy docs alone. When the two ever seem to disagree, the philosophy docs win, and the prompt should be fixed to match — not the other way around.

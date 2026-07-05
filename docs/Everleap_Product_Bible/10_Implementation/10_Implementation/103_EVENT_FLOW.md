# Event Flow

## Purpose

`071_GENERATION_REQUESTS.md` and `102_GENERATOR_REGISTRY.md` describe what generation requests are and how the dependency graph resolves them. This document answers the remaining question: **which user actions actually create generation requests, and who picks them up?**

---

# User Action → Generation Trigger Map

| User Action | Endpoint | Enqueues via | Targets | Trigger string | Mode / Priority |
|---|---|---|---|---|---|
| Submit a Story answer | `storyAnswer.ts` | `requestUserGeneration` | `REFRESH_TODAY` + `REFRESH_INSIGHTS_SUMMARY` | `"story_answer"` | deferred, priority 100 |
| Finish all Story questions | `storyComplete.ts` | `requestUserGeneration` | `REFRESH_TODAY` + `REFRESH_INSIGHTS_SUMMARY` | `"story_completed"` | immediate, priority 10 |
| Answer a Tiny Task | `microTasks/answerMicroTask.ts` | `requestUserGeneration` | `REFRESH_TODAY` + `REFRESH_INSIGHTS_SUMMARY` | `"tiny_task_answered"` | deferred, priority 100 |
| Rate a Quick Check (Insights feedback) | `insightsSummaryFeedback.ts` | `requestUserGeneration` | per-tab target for motivations/strengths/skills (e.g. `[page:insights_strengths, memory:consolidate]`), else `REFRESH_INSIGHTS_SUMMARY` | `"insights_summary_feedback"` | deferred, priority 100 |
| Save an Explore path / mark an Action done | `userActions.ts` | `requestUserGeneration` | `REFRESH_TODAY` | `"explore_saved"` (on saving an `explore_path`) / `"action_completed"` (on status→`done`) | deferred, priority 100 |
| View Action Suggestions (cache stale/missing) | `getActionSuggestions.ts` | `requestUserGeneration` | `recommendation:actions` | `"action_suggestions_view"` | deferred, priority 50 (background warm; non-blocking read) |
| Complete onboarding | `onboardingClaim.ts` | **bypasses the queue** | calls `generateTodayGuidanceForUser(user.id, context, "onboarding_completed")` directly, fire-and-forget | n/a | synchronous in-process; errors only logged |

`requestUserGeneration` (`lib/requestUserGeneration.ts`) is a thin wrapper around `enqueueGeneration`: it dedupes the target list and calls `enqueueGeneration` once per target, defaulting to `executionMode: "deferred"`, `priority: 100` unless the caller overrides it.

`onboardingSynthesis.ts` and `storyNext.ts` make no generation calls at all — they don't trigger background work.

## Named bundles (`generationBundles.ts`)

Callers don't pass raw target-key arrays; they pass named bundles:

```
REFRESH_TODAY              -> [page:today, memory:consolidate]
REFRESH_INSIGHTS_SUMMARY   -> [page:insights_summary,
                               page:insights_motivations,
                               page:insights_strengths,
                               page:insights_skills,
                               page:insights_time_twin,
                               page:insights_fun_facts,
                               recommendation:actions,
                               page:explore,
                               memory:consolidate]
REFRESH_INSIGHTS           -> [page:insights_summary, page:insights]   (defined, now UNUSED)
REFRESH_EXPLORE            -> [page:explore]                            (defined, unused)
REFRESH_RECOMMENDATIONS    -> [recommendation:careers, recommendation:actions]  (defined, unused)
FULL_REBUILD               -> [page:today, page:insights_summary, page:insights,
                               page:explore, recommendation:careers,
                               recommendation:actions]                 (defined, unused)
```

Only `REFRESH_TODAY` and `REFRESH_INSIGHTS_SUMMARY` are referenced by live callers today. `REFRESH_INSIGHTS` is now **dead relative to live triggers** — nothing enqueues it anymore, which also means the combined `page:insights` target (which it was the only path to) is no longer reached from any live trigger; the per-tab insight targets in `REFRESH_INSIGHTS_SUMMARY` replaced it (they write the rich per-tab payloads the old combined path didn't). `REFRESH_EXPLORE`, `REFRESH_RECOMMENDATIONS`, and `FULL_REBUILD` are defined but unused; the two remaining stubbed targets they reference (`recommendation:careers` and — via `FULL_REBUILD` — `page:insights`) are registered but not exercised here (`102_GENERATOR_REGISTRY.md`).

## Why science targets are never directly enqueued

No function in the codebase calls `enqueueGeneration` with a `science:*` target directly. Science regeneration happens implicitly: `page:today` and `page:insights*` declare `dependsOn: sciences` in `generationRegistry.ts`, and `runGenerationRecursive` in `generationDispatcher.ts` walks dependencies before running the requested target. This is the dependency-resolution model from `071_GENERATION_REQUESTS.md` working as designed — it's just worth stating explicitly, since grepping for `enqueueGeneration("science:...")` calls will turn up nothing.

## The onboarding inconsistency

Onboarding is architecturally different from every other trigger. Every other action goes through the persistent queue: `user_generation_requests` row created → picked up later by a worker → run through the dispatcher (which resolves science dependencies first) → marked complete or failed, with attempts and error tracking.

`onboardingClaim.ts` instead calls `generateTodayGuidanceForUser` directly and in-process, not awaited (`void ... .catch(...)`). This skips:
- The queue (no `user_generation_requests` row, no retry/attempt tracking, no audit trail if it fails).
- The dispatcher's dependency walk (it calls the Today generator directly, not `runGeneration`), so science memos are **not guaranteed fresh** before the first Today guidance is generated post-onboarding.

This is most likely intentional — it minimizes latency for the very first guidance a new user sees, right after onboarding, rather than waiting for a worker tick. But it means a failure here is only visible in logs, never recorded anywhere queryable, and the first Today guidance a user sees may be built from stale or absent science memos. Worth a deliberate decision: either document this as an accepted tradeoff, or route onboarding through the queue with `immediate` execution mode (which would still be fast, just observable).

---

# Worker Pickup — Two Independent Consumers

Both consumers call the same primitives (`claimPendingGeneration` from `generationQueue.ts`, `runGenerationRequest` from `generationDispatcher.ts`). They are **not** a producer/consumer split — they're two redundant ways of draining the same `user_generation_requests` table.

## 1. `functions/generationRun.ts` — manual/on-demand

- `POST generation/run`, anonymous auth.
- Claims exactly **one** pending request per call and runs it.
- No scheduling of its own — designed to be invoked externally (manually, by a dev tool, or a webhook).

## 2. `functions/generationTimer.ts` — the real production worker

- Azure Timer trigger, schedule `"0 * * * * *"` (NCRONTAB, 6-field: second-minute-hour-day-month-day-of-week) — **fires once per minute**.
- Each firing loops `claimPendingGeneration`, running each claimed request via `runGenerationRequest`, up to `MAX_BATCH_SIZE = 5` requests per tick, stopping early if the queue empties.
- This is the function actually responsible for background generation in a running deployment — `051_GENERATION_PIPELINE.md`'s "Background Worker Claims Request" step is this timer.

**Stale comment flag:** the in-code comments on `generationTimer.ts` say `"Local dev: every 10 seconds"` and `"Production later: change to every 5 minutes"` — neither matches the actual configured schedule of once-per-minute. Worth correcting the comments (or the schedule) so they agree.

---

# Supporting Read-Side Logic (not triggers)

- **`todayContext.ts`** — not an event emitter. `buildTodayContext` queries Story progress and derives a `TodayStage` (`new → story_started → story_developing → insight_ready → action_ready`) plus a recommended next action/route. This becomes the `TODAY_CONTEXT` block fed into the Today prompt (see `104_PROMPT_CATALOG.md`) — it's how the AI knows what stage the user is at without inferring it itself.
- **`guidanceToday.ts`** — the actual Today generator (`generateTodayGuidanceForUser`), invoked two ways: (1) normally, via the dispatcher when `page:today` is processed off the queue; (2) directly from `onboardingClaim.ts`, bypassing the queue as described above.

---

# Full Picture

```
Story answer submitted          ──┐
Story completed                  ──┼──> requestUserGeneration ──> enqueueGeneration ──> user_generation_requests (pending)
Tiny Task answered               ──┘                                                              │
                                                                                                     │
Onboarding completed ──> generateTodayGuidanceForUser() directly, bypassing the above ──┐          │
                                                                                          │          v
                                                                                          │   generationTimer.ts (every 1 min, batch 5)
                                                                                          │   or generationRun.ts (manual, 1 at a time)
                                                                                          │          │
                                                                                          │          v
                                                                                          │   claimPendingGeneration()
                                                                                          │          │
                                                                                          │          v
                                                                                          │   runGenerationRequest() ──> runGenerationRecursive()
                                                                                          │          │   (resolves science:* dependencies first)
                                                                                          │          v
                                                                                          └──> generated guidance written to user_page_guidance / user_science_insights
```

# API Contracts

## Purpose

This document catalogs every Azure Function endpoint in `apps/everleap-api`, as actually implemented. It complements `062_PAGE_CONTRACTS.md` (which describes what a *page* is allowed to do) by describing what the *API* actually exposes for pages to call.

## Authentication Model (as implemented)

Every endpoint registers `authLevel: "anonymous"` at the Azure Functions layer — there is no Azure-Functions-key auth on any route. Authentication is instead handled entirely in-handler via `getCurrentUserFromRequest()` (`lib/currentUser.ts`):

1. Read the `everleap_session` HttpOnly cookie.
2. SHA-256 hash it.
3. Look up a non-revoked, non-expired row in `sessions` joined to `users`.
4. If the lookup fails, the handler returns `401 { ok:false, error:"Not authenticated." }`.

This is consistently applied on most endpoints, but **not all** — see the flags at the end of this document. Responses are uniformly `jsonBody` with an `{ ok: boolean, ... }` envelope; errors return `ok:false` plus `error` (sometimes `debug`).

---

# Auth Endpoints

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `auth/emailRequestCode.ts` | `auth/email/request-code` | POST | none (entry point) | `{ email }` | `{ ok, email, expiresAt }` | Inserts `email_codes` row (hashed, 10-min expiry); sends via Resend |
| `auth/emailVerifyCode.ts` | `auth/email/verify-code` | POST | none | `{ email, code }` | `{ ok, user, sessionCreated }` + session cookie | Transaction: validates code, upserts `users`, marks code used, inserts `sessions` (30-day expiry) |
| `auth/logout.ts` | `auth/logout` | POST | optional (no-op if no cookie) | none | `{ ok:true }` + cleared cookie | `sessions.revoked_at = now()` |
| `auth/passkeyRegisterOptions.ts` | `auth/passkey/register/options` | POST | session required | none | `{ ok, options, debug:{rpID,origin} }` | Assigns `webauthn_user_id` if missing; stores `current_challenge` |
| `auth/passkeyRegisterVerify.ts` | `auth/passkey/register/verify` | POST | session required | WebAuthn `RegistrationResponseJSON` | `{ ok, verified:true }` | Inserts `passkeys` row; clears `current_challenge` |
| `auth/passkeyLoginOptions.ts` | `auth/passkey/login/options` | POST | none | none | `{ ok, options }` | Sets `current_challenge` on every user who owns a passkey (discoverable-credential flow — see flags) |
| `auth/passkeyLoginVerify.ts` | `auth/passkey/login/verify` | POST | none (creates session) | WebAuthn `AuthenticationResponseJSON` | `{ ok, user, sessionCreated }` + session cookie | Looks up passkey by `credential_id`, verifies against that user's challenge, updates counter, inserts session |
| `auth/smsRequestCode.ts` | `auth/sms/request-code` | POST | none | `{ phone }` (normalized E.164 US) | `{ ok, phone, status }` | Twilio Verify `verifications.create` |
| `auth/smsVerifyCode.ts` | `auth/sms/verify-code` | POST | none | `{ phone, code }` | `{ ok, sessionCreated:true }` + session cookie | Twilio `verificationChecks.create`; upserts `users`; inserts session |

---

# Core / Profile

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `me.ts` | `me` | GET | session required | none | `{ ok, onboardingAnswers, user:{...} }` | read-only |
| `health.ts` | (default route, no explicit `route` set — binds to `/api/health`) | GET | none | none | `{ status, db, dbTime, databaseName, tables:{...} }` | read-only DB connectivity check |
| `flows/getFlow.ts` | `flows/{key}` | GET | **none enforced** | route param `key` | `{ ok, flow:{id,key,name,nodes:[...]} }` | read-only |
| `ai/usageSummary.ts` | `ai/usage/summary` | GET | **none enforced** | none | `{ ok, providers:{...}, sources:{ app, ai_lab, prompt_lab } }` — each source is `{ requestCount, monthToDateCost, allTimeCost }`; each provider adds `averageRequestCost` | read-only, aggregates `ai_usage_audit` |
| `aiLabRun.ts` | `ai/lab/run` | POST | **session required + Prompt Lab unlock + rate-limited** (`requirePromptLabUnlock` then `checkPromptLabRateLimit` action `generate`, 6/60s → 429) | `{ provider, prompt, answers[], userCharacterLimit?, promptMode?, templateKey? }` | `{ ok, internal, user, total, output, provider, model, usage, estimatedCostUsd }` | Two AI calls; two `ai_usage_audit` rows (`source:"ai_lab"`) |
| `updateProfile.ts` | `profile` | POST | session required | `{ firstName?, zipCode? }` (a field is only touched if its key is present; ZIP validated 5-digit) | `{ ok, user }` | Updates `users.first_name` / `zip_code` |
| `userData.ts` (`dataExport`) | `data/export` | GET | session required | none | `{ ok, data }` | read-only — returns everything Everleap holds about the signed-in user |
| `userData.ts` (`dataDelete`) | `data/delete` | POST | session required | `{ confirm:"DELETE" }` | `{ ok, ... }` | Permanently deletes the account and its data |
| `badges/getAchievements.ts` | `achievements` | GET | session required | none | `{ ok, badges, earnedCount, total, newlyEarned }` | Evaluates the DB-driven badge set and awards any newly-qualified badge as a side effect |

---

# Onboarding

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `onboardingClaim.ts` | `onboarding/claim` | POST | session required | `{ answers, zipCode?, flowKey? }` (default `flowKey="onboarding_v1"`) | `{ ok, orchestration:{emittedSignalCount, emittedConceptKeys} }` | Transaction: upserts `user_question_answers`; fans answers into `user_profile_signals` via `question_concept_mappings`; conditionally updates `users.zip_code`; **fire-and-forget** call to `generateTodayGuidanceForUser(..., "onboarding_completed")` — not queued, not awaited, errors only logged |
| `onboardingSynthesis.ts` | `onboarding/synthesis` | POST | none | `{ provider?, answers }` | `{ ok, provider, model, synthesis:{headline,body,signals[],bridge}, audit, internal, user }` | Two AI calls; **does not persist answers** — this is a pre-account-creation teaser, distinct from `onboardingClaim` |

`onboardingSynthesis` and `onboardingClaim` are easy to conflate — they're not the same step. Synthesis is a pre-signup preview (no DB writes of answers); Claim is the real post-auth persistence path.

---

# Story

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `storyNext.ts` | `story/next` | GET | session required | none | `{ ok, done, progress:{...}, categories[], question }` | read-only |
| `storyAnswer.ts` | `story/answer` | POST | session required | `{ question_id, answer_text?, answer_json? }` | `{ ok, status:"saved" }` | Upserts `story_question_answers`; enqueues generation (`trigger:"story_answer"`, targets = `REFRESH_TODAY + REFRESH_INSIGHTS_SUMMARY`, deferred, priority 100) |
| `storyComplete.ts` | `story/complete` | POST | session required | none | `202 { ok, status:"queued" }` | Enqueues generation (`trigger:"story_completed"`, targets = `REFRESH_TODAY + REFRESH_INSIGHTS_SUMMARY`, immediate, priority 10) |
| `storyReset.ts` | `story/reset` | POST | session required **+ hardcoded reset code `"101010"`** | `{ code }` | `202 { ok, status:"rebuilding_today", deleted:{...} }` | Dev/QA utility — deletes Story answers and dependent generated state, fire-and-forget Today rebuild |

---

# Micro Tasks ("Tiny Tasks")

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `microTasks/answerMicroTask.ts` | `micro-tasks/{taskId}/answer` | POST | session required | `{ selected_option_index }` | `{ ok, task:{...} }` | Updates `user_micro_tasks`; enqueues generation (`trigger:"tiny_task_answered"`, targets = `REFRESH_TODAY + REFRESH_INSIGHTS_SUMMARY`, deferred, priority 100) |

---

# Guidance / Generation

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `guidance/getTodayGuidance.ts` | `guidance/today` | GET | session required | none | `{ ok, generation_status, is_updating, guidance:{...}, story_progress }` | read-only; derives `reflection`/`observation`/`next_step` by splitting `guidance_text` on blank lines |
| `getInsightsSummary.ts` | `guidance/insights-summary` | GET | session required | none | `{ ok, pageKey, headline, guidanceText, nextActionLabel, nextActionRoute, generatedAt, payload }` | read-only |
| `getInsightsMotivations.ts` | `guidance/insights-motivations` | GET | session required | none | `{ ok, payload, ... }` | read-only per-tab insight (Ikigai/motivations) |
| `getInsightsStrengths.ts` | `guidance/insights-strengths` | GET | session required | none | `{ ok, payload, ... }` | read-only per-tab insight (Enneagram/strengths) |
| `getInsightsSkills.ts` | `guidance/insights-skills` | GET | session required | none | `{ ok, payload, ... }` | read-only per-tab insight (Parachute/skills) |
| `getInsightsTimeTwin.ts` | `guidance/insights-time-twin` | GET | session required | none | `{ ok, payload, ... }` | read-only per-tab insight (Time Twin) |
| `getInsightsFunFacts.ts` | `guidance/insights-fun-facts` | GET | session required | none | `{ ok, payload }` | read-only per-tab insight (Fun Facts) |
| `insightsSummaryFeedback.ts` | `guidance/insights-summary/feedback` | POST | session required | `{ rating, note?, page_key? }` (rating ∈ `mostly`/`somewhat`/`not_really`) | `{ ok }` | Inserts `insights_summary_feedback`; enqueues per-tab target (or `REFRESH_INSIGHTS_SUMMARY`), deferred, priority 100 |
| `getActionSuggestions.ts` | `guidance/action-suggestions` | POST | session required | `{ force?: boolean }` | `{ ok, cache, generating, payload }` | **Default non-blocking:** `peekActionSuggestions` serves cache + enqueues background `recommendation:actions` (trigger `action_suggestions_view`, deferred, priority 50). `force=true` generates synchronously |
| `userActions.ts` | `guidance/actions` | GET / POST / PATCH | session required | GET `?source_ref=&status=`; POST `{ sourceType, title, sourceRef?, lane?, description?, href?, status? }`; PATCH `{ id, status }` | `{ ok, actions }` / `{ ok, action }` | Read/save/update `user_actions`; saving an `explore_path` or marking `done` fires a deferred `REFRESH_TODAY` (`explore_saved` / `action_completed`) |
| `getExplorePaths.ts` | `guidance/explore-paths` | GET | session required | `?lane=` | `{ ok, ... }` | read-only Explore deck. For the `work` lane it returns server-ranked, memo-grounded personalized matches from `explore_path_matches` (`personalized: true`, per-card `brightOutlook`); other lanes return the shared catalog deck |
| `getExplorePath.ts` | `guidance/explore-path` | GET | session required | `?lane=&slug=` | `{ ok, ... }` | read-only single Explore path (on-demand content) |
| `getExploreProfile.ts` | `guidance/explore-profile` | GET | session required | none | `{ ok, ... }` | read-only (first name + answers) |
| `getExploreSummary.ts` | `guidance/explore-summary` | POST | session required | none | `{ ok, payload, cache }` | Read-through: `getOrGenerateExploreSummary` (input-hash cached) |
| `getProfile.ts` | `guidance/profile` | GET | session required | none | `{ ok, profile }` | read-only user profile snapshot |
| `actionMission.ts` | `guidance/action-mission` | POST | session required | `{ id, op, ... }` (op ∈ `get`/`start`/`toggleStep`/`complete`) | `{ ok, action }` | `start` generates the mission (one AI call, once); `complete` records reflection and fires deferred `REFRESH_TODAY` + `REFRESH_INSIGHTS_SUMMARY` (`action_reflection`) |
| `getOnboardingSynthesis.ts` | `guidance/onboarding-synthesis` | GET | session required | none | `{ ok, status, synthesis }` | read-only — returns the persisted post-onboarding synthesis |
| `introSeen.ts` | `guidance/intro-seen` | GET / POST | session required | none | `{ ok, firstTime }` | GET reports state; POST atomically claims-once (flips `users.has_seen_intro`) so the narrated intro plays exactly once |
| `selfPortrait.ts` | `guidance/self-portrait` | GET | session required | none | `{ ok, portrait }` | read-only — cached self-portrait (`portrait: null` until there's enough signal) |
| `timeTwinReflection.ts` | `guidance/time-twin-reflection` | GET / POST | session required | POST `{ twin_id, reflection }` | `{ ok, ... }` | Read/upsert `time_twin_reflections` |
| `getTimeTwinFigureImage.ts` | `guidance/time-twin-figure-image` | GET | session required | `?slug=` | image bytes | Serves stored portrait from `time_twin_figures` |
| `trackContentEvent.ts` | `track/event` | POST | session required | `{ page_key, ... }` | `{ ok }` | Inserts `user_content_events` (Tier-2 implicit signal) |
| `summaryPreview.ts` | `ai/summary-preview` | GET | **none — and ignores caller identity** | none | raw `generateSummaryPayload(userId)` output | Regenerates and returns Insights Summary for a **hardcoded user ID** — see flags |
| `generationRun.ts` | `generation/run` | POST | none | none | `{ ok, status:"nothing_to_run" }` or `{ ok, status:"completed", ... }` | Claims and runs exactly one pending generation request |
| `generationTimer.ts` | timer trigger, `"0 * * * * *"` | n/a | n/a | n/a | n/a | The actual production worker loop — claims and runs up to `MAX_BATCH_SIZE = 5` pending requests per tick (fires once per minute; see `103_EVENT_FLOW.md`) |

---

# Prompt Lab (internal live-preview tool)

A second-factor unlock (`prompt_lab_unlocks`) sits on top of an existing logged-in session; a correct passcode grants a temporary unlock but is not a login replacement (see `100_DATABASE_SCHEMA.md`).

| Function | Route | Method | Auth | Request | Response | Side effects |
|---|---|---|---|---|---|---|
| `promptLab/promptLabUnlock.ts` | `prompt-lab/unlock` | POST | session required **+ rate-limited** (`unlock_attempt`, 5/900s → 429) | `{ passcode }` | `{ ok, token, expiresAt }` or `401` | Verifies passcode against `PROMPT_LAB_PASSCODE` (timing-safe); inserts `prompt_lab_unlocks` (24h) |
| `promptLab/promptLabStatus.ts` | `prompt-lab/status` | GET | session optional | none | `{ ok, unlocked }` (`unlocked:false` if no session) | read-only |
| `promptLab/promptLabPreview.ts` | `prompt-lab/preview` | POST | **session required + Prompt Lab unlock + rate-limited** (`generate`, 6/60s → 429) | `{ page_key, target_field?, target_word_count?, tone_instruction?, misc_note? }` | `{ ok, page_key, target_field, ..., target_text, result }` | One live AI call per preview, audited under `source:"prompt_lab_preview"` |

---

# Flagged Issues

These are real findings from reading the code, not stylistic nitpicks — worth a deliberate decision (fix, accept, or document-as-intentional) rather than silent drift:

1. **No Azure-Functions-level auth anywhere.** Security is 100% the in-handler session-cookie check, and a few endpoints skip it entirely: `getFlow`, `usageSummary`, `summaryPreview`. For `getFlow` this is plausibly fine (flow content isn't sensitive). For `usageSummary` (cost data) it's worth a deliberate call. `aiLabRun` is **no longer** in this list — it now returns 401 without a session and additionally requires a Prompt Lab unlock plus rate-limiting before executing any prompt.
2. **`summaryPreview.ts` has a hardcoded user ID (`79bd748e-37ca-4caf-bcc4-ba300c379dfa`) and zero auth.** Reads as a debug leftover from development. If reachable in a deployed environment, anyone can hit this route and read that user's generated Insights Summary. Should either be removed or gated behind a dev-only check.
3. **`passkeyLoginOptions.ts`** sets `current_challenge` on *every* user who owns a passkey, not a specific user — this is how usernameless/discoverable-credential WebAuthn works (the real user is resolved later via `credential_id` in `passkeyLoginVerify.ts`), but it's a broad UPDATE worth knowing about rather than assuming is a bug if you encounter it.
4. **`getTodayGuidance.ts`** parses `reflection`/`observation`/`next_step` out of a single stored string at read time, rather than storing them as structured fields — see `100_DATABASE_SCHEMA.md`'s "Known Schema Debt" section.
5. **`health.ts`** has no explicit `route` configured, unlike every other function — it binds to the Azure Functions default (`/api/health`) rather than a route under the documented namespaces. Inconsistent, not broken.

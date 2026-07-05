# Database Schema

## Purpose

This document describes the actual Postgres schema behind `apps/everleap-api`, as it exists in code today — not the aspirational model in `070_DATA_MODEL.md`, but what is really created, queried, and written to.

**There is no formal migration system.** `src/db/schema/experience_flow_schema.sql` is a two-line header comment with no DDL. Only two tables have a creation script checked into the repo (`scripts/create-story-answer-table.ts`, `scripts/create-user-science-insights.ts`); everything else exists because it was created directly against the live database at some point. This document was originally reverse-engineered from every SQL string referenced across `src/`, and has since been cross-checked against a live schema dump from the actual dev Postgres instance (2026-06-30). Where the two disagreed, this revision corrects the document to match the live database — see "Known Schema Debt" below for what that surfaced.

---

# Schema by Layer

Mapped against the Bible's four data layers (`070_DATA_MODEL.md`): Identity, Evidence, Scientific Knowledge, Experience.

## Layer 1 — Identity

### `users`
Core account record.
- `id` (uuid, pk)
- `email`, `email_verified`
- `phone`, `phone_verified`
- `zip_code`
- `current_challenge` — transient WebAuthn challenge, set/cleared during passkey flows
- `created_at`, `updated_at`

### `sessions`
- `id`, `user_id` (fk → users), `token_hash`, `expires_at`, `revoked_at`

Session tokens are never stored raw — only a hash, checked by `currentUser.ts` against the `everleap_session` cookie.

### `email_codes`
- `id`, `email`, `code_hash`, `expires_at`, `used_at`, `created_at`

### `passkeys`
The **live** WebAuthn credential table.
- `id`, `user_id` (fk → users), `credential_id`, `public_key`, `counter`, `transports`, `device_type`, `backed_up`

> **Confirmed dead code (verified against live schema, 2026-06-30):** `src/lib/db.ts` defines `createPasskey`, `getPasskeyByCredentialId`, `getPasskeysForUser`, `updatePasskeyCounter` targeting a table called `user_passkeys`. **That table does not exist in the live database at all** — only `passkeys` does. These functions are not called anywhere in `src/functions`; all real passkey auth flows (`passkeyRegisterVerify.ts`, `passkeyLoginVerify.ts`, etc.) use `passkeys` directly. This is not just unused code — it would throw at runtime if anything ever called it, since the table it targets doesn't exist. Removed in the same pass that added this note.

---

## Layer 2 — Question Bank / Flow Engine

This layer doesn't appear explicitly in the Bible's data model but underlies both onboarding and Story.

- **`questions`** — the central table. `id`, `key`, `family`, `prompt`, `input_type`, `question_type_id` (fk → `question_types`), `question_weight`, `source_sheet`, `source_row`, `source_section`, `source_rank`, `goal`, `science`, `core_characteristic`, `answer_type_raw`, `user_audience`, `citation`, `notes`, `placeholder`, `min_length`, `max_length`, `validation_rules`. Unique on `(source_sheet, source_row)` — a trace back to the original spreadsheet (`Everleap App Questions.xlsx` / `Everleap_Question_Type_Review_Migration.xlsx`) this was imported from. Read by nearly every function in the system: `storyNext.ts`, `getFlow.ts`, `onboardingClaim.ts`, `guidanceToday.ts`, `me.ts`, `insightConfidence.ts`.
- **`question_types`** — `id`, `key` (`open`, `binary`, `single_choice`, `multi_choice`, ...).
- **`question_options`** — `id`, `question_id` (fk), `key`, `label`, `description`, `image_url`, `sort_order`, `metadata`.
- **`question_categories`** — `id`, `key`, `label`, `weight`, `sort_order`, `is_active`.
- **`question_category_mappings`** — many-to-many, `question_id` ↔ `category_id`.
- **`sciences`** — `id`, `key` (`ikigai`, `enneagram`, `parachute`), `label`, `sort_order`, `is_active`.

  > **Known inconsistency:** this DB table is a second, parallel source of truth for "what sciences exist," alongside the hardcoded `SCIENCE_DEFINITIONS` array in `scienceRegistry.ts` (see `102_GENERATOR_REGISTRY.md`). The two are not reconciled — adding a science today requires editing code, not this table; it's unclear whether anything still reads `sciences` at runtime versus the hardcoded registry.

- **`question_science_mappings`** — many-to-many, `question_id` ↔ `science_id`.
- **`question_concept_mappings`** — `question_id` (fk), `concept_key`, `confidence`. Used only by `onboardingClaim.ts` to fan onboarding answers out into weighted profile signals.
- **`flows`** — `id`, `key`, `name`, `is_active`. (e.g. `onboarding_v1`)
- **`flow_nodes`** — `id`, `flow_id` (fk), `key`, `node_type`, `sort_order`, `title`, `body`, `question_key`, `is_required`, `metadata`. Drives the onboarding conversation engine's node sequence (read via `getFlow.ts`).
- **`us_zip_codes`** — validation lookup table, used only by `onboardingClaim.ts` to confirm a submitted zip is real before saving it.

---

## Layer 3 — Evidence (Answers)

Two parallel, non-overlapping answer stores exist — these correspond to the Bible's distinction between Onboarding (`030_ONBOARDING.md`, intentionally shallow) and Story (`032_STORY.md`, intentionally deep), kept structurally separate:

- **`user_question_answers`** — the **onboarding** answer store. `id`, `user_id`, `flow_id` (fk → flows), `question_id` (fk → questions), `answer_text`, `answer_json`, `created_at`, `updated_at`. Unique on `(user_id, flow_id, question_id)`. Written by `onboardingClaim.ts`, read by `me.ts` and `guidanceToday.ts`.
- **`story_question_answers`** — the **Story** answer store. Same shape minus `flow_id`: `id`, `user_id`, `question_id` (fk → questions), `answer_text`, `answer_json`, `created_at`, `updated_at`. Unique on `(user_id, question_id)` — no flow concept; Story is flow-less by design. Written by `storyAnswer.ts`, read by `storyNext.ts`, all three science memo generators, `todayContext.ts`, `insightConfidence.ts`. Has a dedicated creation script: `scripts/create-story-answer-table.ts`.
- ~~**`user_profile_signals`**~~ — **dropped 2026-06-30.** Was written by `onboardingClaim.ts` (fanning answers through `question_concept_mappings`) but never read anywhere. Had 1,642 real rows across 8 user_ids at drop time (all pre-launch dev/test accounts) — backed up to `scripts/2026-06-30-pre-drop-backup.sql` before dropping. The write path in `onboardingClaim.ts` was removed in the same pass.

---

## Layer 4 — Generated Knowledge

This is the layer the Product Bible calls "temporary, regeneratable" knowledge.

### `user_generation_requests`
The Generation Request queue described in `071_GENERATION_REQUESTS.md`, implemented exactly as specified:
- `id`, `user_id`, `target_key`, `trigger`, `execution_mode` (`deferred` | `immediate` | `blocking`), `priority`, `status` (`pending` | `running` | `complete` | `failed`), `requested_at`, `run_after`, `started_at`, `completed_at`, `failed_at`, `attempts`, `error_message`, `source_snapshot`, `unique_key`

See `103_EVENT_FLOW.md` for the full lifecycle and `102_GENERATOR_REGISTRY.md` for how requests resolve into actual generation work.

### `user_science_insights`
The Science Memo store (`072_SCIENCE_MEMOS.md`).
- `id`, `user_id`, `science`, `confidence`, `hypotheses_json`, `missing_information_json`, `questions_to_reduce_uncertainty_json`, `evidence_json`, `source_snapshot`, `generated_at`, `updated_at`. Unique on `(user_id, science)` — one memo per science per user, overwritten on regeneration. Has a dedicated creation script: `scripts/create-user-science-insights.ts`.

### `user_page_guidance`
Stores generated Today guidance and Insights Summary content.
- `id`, `user_id`, `page_key` (`'today'` | `'insights_summary'` | `'insights_motivations'` | `'insights_strengths'` | `'insights_skills'` | `'insights_fun_facts'`), `headline`, `guidance_text`, `opening_paragraph`, `next_paragraph`, `next_action_label`, `next_action_route`, `generation_trigger`, `source_snapshot`, `generated_at`. Unique on `(user_id, page_key)`.

> **Note:** generation status (`generating` / `ready` / `failed`) is tracked inside the `source_snapshot` JSON blob (`source_snapshot.guidance_generation`) rather than as a real column — there is no first-class status field on this table the way there is on `user_generation_requests`. Similarly, `getTodayGuidance.ts` derives `reflection` / `observation` / `next_step` for the API response by splitting the single `guidance_text` string on blank lines at *read* time — these are not stored as structured fields, despite the Bible's "structured before narrative" principle (`061_DATABASE_PHILOSOPHY.md`).

### `user_micro_tasks`
"Tiny Tasks" attached to Today and Insights guidance — a cycling batch of 3 per (user, page_key) generation (see `2026-07-05-micro-task-batches.sql`).
- `id`, `user_id`, `page_key`, `signal_key`, `question`, `options_json`, `selected_option`, `selected_option_index`, `source_guidance_id` (fk → `user_page_guidance`), `batch_id` (uuid, groups the 3 rows written together in one generation call — `source_guidance_id` can't be used for this since it's a stable per-(user,page_key) upsert id, not fresh per generation), `batch_position` (smallint, 0-2, display order within the batch), `created_at`, `answered_at`
- Indexes: `idx_user_micro_tasks_user_page_created` (user_id, page_key, created_at desc — latest batch lookup), `idx_user_micro_tasks_batch_id` (fetch all rows of a batch), `idx_user_micro_tasks_user_created` (user_id, created_at desc — cross-page-key recent-question history used to avoid repeating questions across generations), `idx_user_micro_tasks_user_signal` (user_id, signal_key, created_at desc).
- Answered rows are never deleted — only unanswered rows are cleared before writing a new batch — so this table also serves as durable per-user question history.

### `prompt_lab_unlocks`
Short-lived second-factor unlock for the internal "Prompt Lab" live-preview tool (see `2026-07-06-prompt-lab-unlocks.sql`) — mirrors `sessions`' shape (hash-only, never store the raw token). A correct passcode grants a temporary unlock on top of an existing logged-in session; it is not a login replacement.
- `id`, `user_id` (fk → `users`), `token_hash`, `created_at`, `expires_at`, `revoked_at`.

### `prompt_lab_rate_limits`
Fixed-window rate limiting for Prompt Lab (see `2026-07-06-prompt-lab-rate-limits.sql`) — throttles passcode brute-forcing (`action = 'unlock_attempt'`) and the synchronous on-demand AI preview calls (`action = 'generate'`) independently of the app's normal async generation queue.
- `user_id` (fk → `users`), `action`, `window_start`, `request_count`. Primary key `(user_id, action, window_start)`.

### `generation_input_hashes`
The universal input-hash cache for the generation pipeline (`scripts/2026-07-05-generation-input-hashes.sql`, used by `src/lib/generation/generationCache.ts`). Each `(user, cache_key)` records the hash of the inputs that produced that target's last output, so a target can skip its AI call when its real inputs are unchanged (`cache_key` examples: `'science:Ikigai/Motivations'`, `'insights_motivations'`, `'memory:consolidate'`). This is what makes broad/whole-account regeneration cost-safe.
- `user_id` (fk → `users`), `cache_key`, `input_hash`, `updated_at`. Primary key `(user_id, cache_key)`.

### `user_memory_profile`
The user memory/primer system — one row per user holding a durable, AI-consolidated summary across Story answers, Tiny Task answers, and Quick Check feedback (`scripts/2026-07-02-user-memory-profile.sql`). Written by the `memory:consolidate` target (`consolidateUserMemory.ts`); the "recent window" companion is computed live at read time in `userMemoryStore.ts` rather than stored here.
- `user_id` (pk, fk → `users`), `long_horizon_summary`, `updated_at`.

### `user_content_events`
The implicit (Tier 2) signal layer of the memory system — page/tab-level view tracking (`scripts/2026-07-03-user-content-events.sql`, written by `trackContentEvent.ts`). Feeds only the long-horizon memory consolidation, never the recent-window used for conversational callbacks.
- `id`, `user_id` (fk → `users`), `channel` (default `'app'`), `event_type` (default `'page_viewed'`), `page_key`, `target`, `created_at`.
- Index: `idx_user_content_events_user_created` (user_id, created_at desc).

### `insights_summary_feedback`
Backend storage for the Insights Summary / per-tab "Quick Check" rating card (`scripts/2026-07-01-insights-summary-feedback.sql`), previously only in browser localStorage. Written by `insightsSummaryFeedback.ts`.
- `id`, `user_id` (fk → `users`), `page_key` (default `'insights_summary'`), `rating` (check: `'mostly'` | `'somewhat'` | `'not_really'`), `note`, `source_guidance_id` (fk → `user_page_guidance`), `created_at`.
- Index: `idx_insights_summary_feedback_user_page` (user_id, page_key, created_at desc).

### `time_twin_figures`
The pre-built Time Twin figure library (`scripts/2026-07-03-time-twin-figures.sql`) — one row per real historical figure with vetted, person-neutral content plus a generated portrait (stored in-DB) and an embedding of the pattern signature for runtime matching. The personalized "why this rhymes with you" beat is written per-user at runtime, not stored here.
- `id`, `slug` (unique), `name`, `era`, `tagline`, `mind_type`, `visual_profile_key`, `tiles` (jsonb), `story_beats` (jsonb), `superpower`, `watchout`, `try_this_week`, `learn_more_href`, `pattern_signature`, `embedding` (jsonb), `image_bytes` (bytea), `image_content_type`, `image_model`, `created_at`, `updated_at`.
- Index: `idx_time_twin_figures_visual_profile` (visual_profile_key).

### `time_twin_reflections`
Server-side persistence for Time Twin reflections (`scripts/2026-07-03-time-twin-reflections.sql`), previously localStorage-only. One row per `(user, twin)`, upserted in place as the user edits (no history kept). Written by `timeTwinReflection.ts`.
- `user_id` (fk → `users`), `twin_id`, `reflection` (default `''`), `updated_at`. Primary key `(user_id, twin_id)`.

### `explore_paths` / `explore_path_matches`
The Explore Phase B two-layer content model (`scripts/2026-07-04-explore-catalog.sql`; see `063_EXPLORE_ARCHITECTURE.md`). `explore_paths` is the shared, user-independent, cacheable content catalog and is live. `explore_path_matches` is defined for per-user personalization but is **not yet used by any code** — matching is currently computed client-side; the table is scaffolding for the planned server-side match layer.
- **`explore_paths`** — `id` (pk, canonical key e.g. `"work:software-developer"`), `lane`, `slug`, `title`, `taxonomy_code`, `content` (jsonb — the ExplorePath spine), `sources` (jsonb), `embedding` (jsonb), `source_version`, `content_model` (default `'on-demand'`; `seed` | `warm` | `on-demand`), `created_at`, `updated_at`. Unique on `(lane, slug)`. Indexes on `lane` and `taxonomy_code`.
- **`explore_path_matches`** — `id`, `user_id` (fk → `users`), `path_id`, `lane`, `score` (0..100), `rank`, `why_you`, `reasons` (jsonb), `generated_at`. Unique on `(user_id, path_id)`. Index `idx_explore_path_matches_user_lane` (user_id, lane, rank).

### `explore_user_summary`
Per-user agentic Explore "whole-life read" narrative (`scripts/2026-07-04-explore-user-summary.sql`), cached per user and regenerated when its inputs change (`input_hash`). Written by the `page:explore` target (`exploreSummary.ts`).
- `user_id` (pk, fk → `users`), `input_hash`, `payload` (jsonb — `{ headline, body, ... }`), `generated_at`.

### `user_actions`
App-wide "Actions" capture — concrete next-steps a user commits to, from any surface (`scripts/2026-07-04-user-actions.sql`). Read/written by `userActions.ts` (`guidance/actions`).
- `id`, `user_id` (fk → `users`), `source_type` (`'explore_path'` | `'insights'` | `'today'` | ...), `source_ref`, `lane`, `title`, `description`, `href`, `status` (default `'saved'`; `saved` | `doing` | `done` | `dismissed`), `created_at`, `updated_at`. Unique on `(user_id, source_type, source_ref, title)`. Indexes `idx_user_actions_user_status` and `idx_user_actions_user_source`.

### `user_action_suggestions`
Agent-proposed action suggestions, read-through cached per user, regenerated only when profile signals change (`input_hash`); mirrors `explore_user_summary` (`scripts/2026-07-04-user-action-suggestions.sql`). Written by the `recommendation:actions` target (`actionSuggestions.ts`); accepting a suggestion promotes it into a committed `user_actions` row.
- `user_id` (pk, fk → `users`), `input_hash`, `payload` (jsonb), `generated_at`.

---

## AI Cost Tracking

A layer not described in the Bible at all — purely operational.

- **`ai_model_pricing`** — `provider`, `model`, `effective_from`, `effective_to`, `input_usd_per_1m_tokens`, `output_usd_per_1m_tokens`, `cached_input_usd_per_1m_tokens`. Time-bounded pricing rows looked up by `(provider, model, effective_to IS NULL)`.
- **`ai_usage_audit`** — `user_id`, `provider`, `model`, `feature`, `actor_type`, `source`, `prompt_mode`, `template_key`, `input_tokens`, `output_tokens`, `cached_input_tokens`, `input_cost_usd`, `output_cost_usd`, `cached_input_cost_usd`, `estimated_cost_usd`, `request_id`, `metadata`, `created_at`. Written by `recordAiUsage.ts`, aggregated by `functions/ai/usageSummary.ts` (which splits spend into `app` / `ai_lab` / `prompt_lab` source buckets — see `101_API_CONTRACTS.md`).

> **Note:** the Insights Summary narrative generation (`summaryNarrative.ts`, called via `generateInsightsSummaryForUser`) is now audited — `summaryGenerator.ts` threads a `track: { feature: "insights_summary" }` through `generateSummaryContent` → `runAnthropic` → `recordAiUsage`. The Prompt Lab preview path (`prompt-lab/preview`) is likewise audited under `source: "prompt_lab_preview"`. See `104_PROMPT_CATALOG.md`.

---

## Legacy / Uncertain Tables

`storyReset.ts` (a dev/QA utility, see `101_API_CONTRACTS.md`) defensively checks `information_schema.tables` before deleting from: `user_micro_tasks` (confirmed real), `micro_task_answers`, `user_micro_task_answers`, `user_science_insights` (confirmed real). The two `*_answers` variants are not referenced anywhere else in the codebase — they're almost certainly dead table names left over from an earlier schema iteration, kept only because deleting from a nonexistent table is harmless when guarded.

---

## Orphaned Tables (found and dropped, 2026-06-30)

A live schema dump (2026-06-30) surfaced a whole relational taxonomy layer that existed in Postgres but was never read by the running application. Grepped across all of `apps/everleap-api/src`, `apps/web/src`, and `apps/everleap-api/scripts/` — these tables had no query referencing them anywhere except where noted. **All were dropped the same day**, across two passes (`scripts/2026-06-30-schema-cleanup.sql` and `scripts/2026-06-30-schema-cleanup-2.sql`), after verifying via `tsc` build + a live `func start` + browser smoke test that the app runs unaffected:

- **`question_categories`** and **`question_science_mappings`** — written once by `scripts/import-story-questions.ts` (a one-off import script), never read afterward by any running code. The writer functions (`ensureCategory`, `replaceCategoryMappings`, `replaceScienceMappings`) were removed from that script in the same pass.
- **`question_concepts`**, **`core_characteristics`**, **`goals`**, **`science_sources`** — no code reference at all (their mapping tables below aside).
- **`question_category_mappings`**, **`question_core_characteristic_mappings`**, **`question_goal_mappings`**, **`question_science_source_mappings`**, **`question_metadata`**, **`question_import_staging`** — no code reference anywhere.
- **`question_concept_mappings`** — the one exception to "never read": it *was* read by `onboardingClaim.ts` to fan onboarding answers out into `user_profile_signals`. Despite the grep showing no `INSERT` anywhere in the repo, this table actually had 13 rows, seeded directly via SQL (`source: 'manual'`, dated 2026-05-22) rather than through any code path — a reminder that "no writer in the codebase" doesn't always mean "no data." Backed up to `scripts/2026-06-30-pre-drop-backup.sql` before dropping. The read path was removed from `onboardingClaim.ts` in the same pass.
- **`sciences`** — became orphaned as a side effect of the above (its only writer, `ensureScience()`, and only referencer, `question_science_mappings`, were both removed). Had 4 rows (`ikigai`, `enneagram`, `parachute`, `other`), also backed up. `SCIENCE_DEFINITIONS` in `scienceRegistry.ts` was always the actual source of truth in practice — see item 3 under "Known Schema Debt" below.

The underlying pattern, for anyone who finds this section confusing in hindsight: someone designed a proper normalized taxonomy (categories, concepts, core characteristics, goals, science sources, all with join tables) and built import tooling for it, but the actual runtime path (`storyNext.ts`, `guidanceToday.ts`, `scienceConductor.ts`) read flat denormalized text columns directly on `questions` (`family`, `science`, `goal`, `core_characteristic`) instead. The normalized layer was never wired into the app that shipped, so it was removed rather than finished.

Also fully orphaned, unrelated to the taxonomy, dropped in the first pass:
- **`user_profile_current`** (`user_id → profile jsonb` snapshot) — no code reference anywhere.
- **`user_flow_events`** (event log) — no code reference anywhere.
- **`user_page_guidance_jobs`** (`user_id, page_key, reason, status`) — looked like it should be the guidance-generation status tracker, but `pageGuidanceStore.ts` confirmed generation status is actually tracked in a JSON blob on `user_page_guidance.source_snapshot.guidance_generation` instead. This table was a duplicate concept that was never hooked up.

If any of this data is ever needed again: recreate the relevant table (definitions are in this document, above) and run `scripts/2026-06-30-pre-drop-backup.sql`.

## Duplicate Constraints (fixed 2026-06-30)

- `user_page_guidance` had two identical unique constraints on `(user_id, page_key)`: `user_page_guidance_user_id_page_key_key` and `user_page_guidance_user_page_key_unique`. The redundant one was dropped.
- `user_generation_requests` had two identical indexes: `user_generation_requests_unique_pending` and `user_generation_requests_unique_pending_idx`. The redundant one was dropped.

Both were almost certainly the result of a fix being applied twice against the live database with no migration history to check against — exactly the risk `093_ENGINEERING_PRINCIPLES.md` and item 1 under "Known Schema Debt" below warn about. Fixed in `scripts/2026-06-30-schema-cleanup.sql`.

## Known Schema Debt

This section exists because `093_ENGINEERING_PRINCIPLES.md` asks every engineering decision to be explainable, and the current schema has accumulated debt worth naming rather than hiding:

1. **No migration system.** Only 2 of ~29 live tables (as of before the 2026-06-30 cleanup) have a creation script in the repo. The rest exist only in the live database. Any environment rebuild (new dev DB, disaster recovery) currently depends on tribal knowledge, not code. The duplicate constraints and the manually-seeded-but-ungrepped `question_concept_mappings` data (see "Orphaned Tables" above) are both direct, observed consequences of this. **Still open** — genuinely the next thing worth fixing if the schema is touched again, since it's the root cause behind most of the other items below.
2. ~~A `db.ts` helper set targeted `user_passkeys`, a table confirmed not to exist in the live database.~~ **Fixed 2026-06-30** — the dead functions (`createPasskey`, `getPasskeyByCredentialId`, `getPasskeysForUser`, `updatePasskeyCounter`) were removed from `db.ts`.
3. ~~Two sources of truth for sciences (DB `sciences` table vs. hardcoded `SCIENCE_DEFINITIONS`).~~ **Resolved 2026-06-30** — the `sciences` table was dropped (see "Orphaned Tables" above). `SCIENCE_DEFINITIONS` in `scienceRegistry.ts` was always the one actually driving behavior; there's only one source of truth now.
4. **Two parallel answer stores** (`user_question_answers` vs `story_question_answers`) — **verified not to be real debt, 2026-06-30.** Onboarding question keys are hand-authored (`permissions_accepted`, `name`, `current_situation`, etc.) while Story question keys are auto-generated via `story_<family>_<row>_<hash>` (see `makeKey()` in `import-story-questions.ts`). Those two key formats can't collide by construction, so there's no actual overlapping-question scenario needing reconciliation. The two stores are correctly separate per the Bible's Onboarding-vs-Story distinction (`030_ONBOARDING.md`, `032_STORY.md`) — this entry stays only so a future reader doesn't re-derive the same false alarm.
5. ~~`user_profile_signals` is written but never read.~~ **Resolved 2026-06-30** — dropped, along with the write path in `onboardingClaim.ts`. Had 1,642 real rows; backed up first (see "Orphaned Tables" above).
6. ~~A full normalized question-taxonomy layer plus three standalone tables (12 tables total) are orphaned.~~ **Resolved 2026-06-30** — all 12 dropped, plus `sciences`, `user_profile_signals`, and `question_concepts`/`question_concept_mappings` in a follow-up pass once those became orphaned too. See "Orphaned Tables" above.
7. **Generation/guidance status lives in JSON blobs** (`source_snapshot`) rather than typed columns in places where the Bible's "structured before narrative" principle would suggest a real column. **Still open.**

None of this blocks the product from working today. Items 2, 3, 5, and 6 were resolved via `apps/everleap-api/scripts/2026-06-30-schema-cleanup.sql` and `2026-06-30-schema-cleanup-2.sql` (both verified against a clean `tsc` build and a live `func start` + browser smoke test before and after running). `2026-06-30-schema-cleanup-review.sql` and `2026-06-30-pre-drop-backup.sql` document the original reasoning and preserve the dropped data respectively. Items 1 and 7 remain open for a future pass.

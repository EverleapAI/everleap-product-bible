# Prompt Catalog

## Purpose

`053_PROMPT_DESIGN.md` describes the philosophy prompts must follow. This document catalogs the prompts that actually exist in `apps/everleap-api` today: what each one does, what model it calls, what it forbids, and what it returns. Where useful, it quotes real constraints from the prompts rather than paraphrasing — the actual banned-phrase lists are some of the most concrete expression of the product's voice rules (`080_TONE_AND_VOICE.md`, `081_TEEN_LANGUAGE_GUIDE.md`) anywhere in the codebase.

---

# Shared AI Client

`guidance/shared/anthropic.ts` exposes `runAnthropic(prompt, maxTokens = 1600, track?)`: model `ANTHROPIC_MODEL` (a shared constant exported from the same file, currently `"claude-sonnet-4-5-20250929"`), a single user-role message (no system prompt), no temperature override, no retry logic. Returns `{ output, model, latencyMs, usage }`. When the optional `track` argument (an `AiUsageTrack`: `feature`, plus optional `userId` / `source` / `actorType` / `metadata`) is present, it records the call to `ai_usage_audit` via `recordAiUsage` — recording never throws, so it can't break generation. Callers that want cost tracking simply thread a `track` through; the Insights and Today generators all do.

**Duplication note:** this shared client is used by the Today and Insights generators, but the three science memo generators (`ikigaiMemo.ts`, `enneagramMemo.ts`, `wciypMemo.ts`) each define their own local, near-identical copy of `runAnthropic` (`max_tokens: 1800`) instead of importing the shared one. `aiLabRun.ts` has yet another independent copy that also dispatches to OpenAI (`max_tokens: 1200`). These leftover copies — the memo generators and `aiLabRun.ts` — still hardcode the model string `"claude-sonnet-4-5-20250929"` in their own local `ANTHROPIC_MODEL` const rather than importing the shared one; the shared client and everything routed through it now reference the single exported constant. This is pure duplication, not a behavioral difference — worth consolidating next time any of these files are touched, per `093_ENGINEERING_PRINCIPLES.md`'s "leave every file slightly better than you found it."

---

# Layer 2 — Science Memo Generators (internal, never user-facing)

All three follow an identical shape: filter Story answers relevant to the science → build a numbered evidence block → send a long instructional prompt → call Anthropic → strip markdown fences → `JSON.parse` → normalize and clamp into the `ScienceMemo` shape → on any parse failure, return a static fallback memo (`confidence: 0.2`, `missing_information: ["The <X> memo could not be parsed."]`). There is no retry on parse failure.

## Ikigai (`sciences/ikigaiMemo.ts`)
Generator id: `ikigai_memo_v1`. Filters answers where `science === "Ikigai/Motivations"` or `family === "motivations"`.

Frames the four-circle Western Ikigai model — Love (energy/curiosity), Good At (natural ability), World Needs (contribution), Future Value — plus an Overlap synthesis. Future Value is explicitly constrained: *"must stay very tentative... Do not predict careers, majors, or job titles."*

Forbidden: naming careers/majors, diagnosis, flattery, claiming the user "found their Ikigai," biography-level specificity (no organizations, jobs, projects, teams, schools, or named achievements), fixed-identity labels ("leader," "builder," "entrepreneur"), and any "the user is/has..." phrasing.

The prompt embeds explicit good/bad example pairs, including a bad example referencing *"leading a fencing academy"* — a hardcoded anti-pattern drawn directly from real test onboarding data, and the direct source of the "You built a fencing academy" bad example in `002_PRODUCT_PRINCIPLES.md`.

Output JSON: `{confidence, love:{summary,confidence}, good_at:{...}, world_needs:{...}, future_value:{...}, overlap, tensions[], missing_information[], questions_to_reduce_uncertainty[], evidence[]}`. Note this is **not** the generic `ScienceMemo.hypotheses[]` shape directly — `ikigaiMemo.ts` post-processes the four circles + overlap into up to 5 synthetic hypothesis statements (e.g. `"What may create energy: <summary>"`) before storing.

## Enneagram (`sciences/enneagramMemo.ts`)
Generator id: `enneagram_memo_v1`. Filters on `science === "Enneagram/Strengths"` or `family === "strengths"`.

Explicitly reframes Enneagram away from typing — analyzes Core Motivation, Avoidance Pattern, Pressure Response, Growth Edge. Forbids naming a type number or stating "the user is Type X" anywhere in output. Same biography-abstraction and no-label constraints as Ikigai, with parallel example pairs.

Output JSON matches the generic `ScienceMemo` shape directly: `{confidence, hypotheses:[{statement,confidence}], tensions[], missing_information[], questions_to_reduce_uncertainty[], evidence[{quote,why_it_matters}]}`.

## WCIYP / Parachute (`sciences/wciypMemo.ts`)
Generator id: `wciyp_memo_v1`. Filters on `science === "Parachute/Skills"` or `family === "skills"`.

Analyzes Natural Competence, Transferable Skill Pattern, Preferred Activity, Transferability (explicitly framed as context, not careers), Development Path. Explicit instruction: *"Do not recommend careers or majors yet."* Same abstraction/no-label/no-biography rules.

Output JSON: same generic `ScienceMemo` hypotheses shape as Enneagram.

## Shared limits across all three
`hypotheses` / `tensions` / `missing_information` / `questions_to_reduce_uncertainty` are each capped at 4 items; `evidence` capped at 6. Confidence defaults to `0.2` if the model omits it or returns a non-numeric value.

---

# Layer 4 — Today Guidance (`guidance/today/todayPrompt.ts` + `todayParser.ts`)

A single prompt assembles: an onboarding-answers block (using a hardcoded label map for ~8 onboarding fields), the full Story Q&A block, the `TODAY_CONTEXT` object (stage + recommended action, from `todayContext.ts`, treated as authoritative ground truth — **not** something the model is asked to infer), and all available science memos as JSON.

Key constraints:
- *"Today is not a dashboard, report, personality test, or career assessment."* Its one job is picking the single most useful next action.
- `TODAY_CONTEXT`'s `next_action_label` / `next_action_route` must be echoed exactly, not invented.
- Science memos inform the output internally but **must never be named** — *"Do not say 'Ikigai', 'Enneagram', or 'Parachute'"* — and must not be used to assign a type, trait, or diagnosis.
- Behavior is stage-conditioned across `new` / `story_started` / `story_developing` / `insight_ready` / `action_ready`.
- The "tiny task" contract: exactly one task, exactly 4 options, a snake_case `signal_key`, and an explicit ban on mood/personality-label/therapy-style questions.
- A banned-phrase list including *"helps surface," "unlock your potential," "discover yourself," "lean into"* — direct, enforced instances of `081_TEEN_LANGUAGE_GUIDE.md`'s "Avoid Corporate Language" and "Avoid Empty Inspiration" sections.

Output JSON: `{headline (≤7 words), guidance_text (65-110 words, 2-3 paragraphs joined by "\n\n"), next_action_label, next_action_route, tiny_task:{question, options[4], signal_key}}`.

`todayParser.ts` strips code fences, parses JSON, and validates each field **individually** — on any single field's failure, it falls back to a caller-supplied `fallbackGuidance` for just that field rather than discarding the whole response. `tiny_task` is separately validated to require exactly 4 non-empty string options.

---

# Layer 4 — Insights Tabs (per-tab generators)

The live pipeline generates each Insights tab with its own dedicated AI call, generator, confidence model, payload shape, and Prompt Lab preview module — not one combined call. The dispatcher (`generationDispatcher.ts`) fans out to a separate target per tab (`page:insights_motivations`, `page:insights_strengths`, `page:insights_skills`, `page:insights_time_twin`, `page:insights_fun_facts`), and the primary refresh bundle (`REFRESH_INSIGHTS_SUMMARY`) enqueues all of them individually. Each call is cost-tracked with its own `feature` (`insights_motivations`, `insights_strengths`, `insights_skills`, `insights_time_twin`, `insights_fun_facts`).

The five live per-tab generators, each in its own `*Narrative.ts` (prompt + parse), `*Confidence.ts`, `*Payload.ts`, and `preview*.ts` modules:

- **Motivations** (`motivationsNarrative.ts`, `generateInsightsMotivationsForUser`) — draws only on the motivations memo. Returns `{headline (≤9 words), body (70-100 words, exactly 2 paragraphs, ends with a question), detail (120-180 words), motivators[3 × {name, shortLine, detail, icon_key}], tiny_tasks[3 × {question, options[3], signal_key}]}`. `icon_key` is clamped to one of `growth/curiosity/connection/focus/creativity/responsibility`.
- **Strengths** (`strengthsNarrative.ts`, `generateInsightsStrengthsForUser`) — same shape as Motivations but the item array is `strengths[3 × {name, shortLine, detail, icon_key}]`, drawn from the strengths memo.
- **Skills** (`skillsNarrative.ts`, `generateInsightsSkillsForUser`) — same shape, item array `skills[3 × {name, shortLine, detail, icon_key}]`, drawn from the skills memo.
- **Time Twin** (`timeTwinNarrative.ts`, `generateInsightsTimeTwinForUser`) — the "delight layer." Pairs the user with one primary real historical figure plus exactly four alternates (5 people in one response). Deliberately confident and fun rather than hedged — the prompt explicitly drops the "it isn't clear yet whether…" tentativeness other tabs enforce, but keeps the no-diagnosis / no-career / no-identity / "historical echo, not a clone" guardrails, and bans over-referenced names (Einstein, da Vinci, Curie, Tesla, Jobs). Each person: `{name, era, tagline, mindType, visual_profile_key, why_you[], tiles[], story_beats[], superpower, watchout, try_this_week}` (primary full-depth, alternates lighter). Uses a raised `max_tokens: 4000` because five people overflow the 1600 default. Falls back to a hardcoded set led by Benjamin Banneker.
- **Fun Facts** (`funFactsNarrative.ts`, `generateInsightsFunFactsForUser`) — draws on all memos. Returns `{facts[4 × {observation, why, domains[], emoji}]}`; `emoji` is sanitized to a single pictographic glyph.

Motivations/Strengths/Skills share the same core constraints as every other prompt (never name the sciences, no identity/career/diagnosis, banned-phrase and preferred-phrase lists, `"It isn't clear yet whether..."` required in body paragraph 2), plus a `MEMORY` block (recent-activity window + long-horizon note) and a `RECENTLY ASKED` / `SIGNAL_KEY COOLDOWN` block so their tiny-task questions don't repeat. Each parser falls back per-field to a full `FALLBACK_BY_LEVEL` static content object keyed by confidence level.

**Legacy combined generator:** `guidance/insights/insightsPrompt.ts` + `insightsParser.ts` (target `page:insights`, `generateInsightsForUser`) is the older one-call generator that produced 4 tabs at once from `{summary, motivations, strengths, skills, fun_facts}`. It still exists and is still wired into the `REFRESH_INSIGHTS` and `FULL_REBUILD` bundles, but it is superseded by the per-tab generators above (which the primary insights-refresh path uses) and produces none of the richer per-tab shapes (motivators/strengths/skills items, tiny tasks, Time Twin). Treat it as legacy.

---

# Layer 4 — Insights Summary (`guidance/insights/summaryGenerator.ts` and friends)

This is the most heavily-prompted single surface in the codebase, and the one the Bible singles out in `034_INSIGHTS_SUMMARY.md` as "a cross-science hypothesis, not another assessment." `generateSummaryPayload()` loads its inputs in parallel — `computeInsightConfidence` (deterministic), `computeEverleapConvergence` (deterministic), `loadScienceMemos`, recent summary feedback, user memory, and recent micro-task history — then makes **one** AI call, `generateSummaryContent` (`summaryNarrative.ts`), that produces the entire card. There is no separate signals pass: the superpowers and watchouts come from this same call, not a deterministic scorer.

## `summaryNarrative.ts` — one AI call producing the whole card

Inputs: confidence level, convergence (`dominantThemes`, `contradictions`), `whatWeKnow` / `whatWeNeed`, flattened hypotheses across all science memos, a `MEMORY` block (recent-activity window + evolving long-horizon note), recent summary feedback (used silently to re-angle a "not really"-rated card), and `RECENTLY ASKED` / `SIGNAL_KEY COOLDOWN` blocks so tiny-task questions don't repeat.

Frames itself explicitly as *"the full Insights Summary card... a cross-tab hypothesis,"* not a profile, biography, or conclusion. Carries the longest banned-phrase list in the codebase — *"You are," "Your answers suggest," "patterns are emerging," "based on your responses"* — paired with a preferred-phrase list (*"You may notice...", "It isn't clear yet whether..."*) lifted almost verbatim from `002_PRODUCT_PRINCIPLES.md`'s Principle 3. A hard rule forbids copying the `whatWeKnow` / `whatWeNeed` lines (Everleap's own data-coverage notes) into any output field — every sentence must be about the person, never about what Everleap has data on.

Contains the most explicit example in the entire codebase of the Bible's "Patterns Over Biography" principle in action:

> **Bad:** "You built a fencing academy and stepped in during a race."
> **Good:** "Your attention may sharpen when something feels unfinished, unclear, or not working as well as it could."

This confirms the fencing-academy example used as a teaching case in `002_PRODUCT_PRINCIPLES.md` traces directly to this real prompt — almost certainly drawn from the developer's own test onboarding data (and consistent with `apps/vaccaroni`, the unrelated fencing-business client site also present in this workspace).

The card is generated in one shot with a strict shape:

- **headline** — ≤9 words, an observation not a label, no identity nouns like "builder"/"leader"/"visionary".
- **body** — 70-100 words, exactly 2 short paragraphs, always ending in a question. Paragraph 1 names one cross-tab pattern in generalized situation language; paragraph 2 names uncertainty or an alternative and must literally contain *"It isn't clear yet whether..."*. The motivation/strengths/skills breakdown is explicitly kept **out** of body and pushed into detail.
- **detail** — 150-220 words, hidden until the user taps "see how I got here." Must add new information, break the pattern down by science (*"Motivation may..., strengths may..., and skills may..."*, three distinct clauses), and name the actual reasoning (which themes recurred, what contradicted, what the confidence level means).
- **superpowers.bullets** — exactly 3, each ≤12 words, where the same pattern shows up as a real strength.
- **watchouts.bullets** — exactly 3, each ≤12 words, the visible flip side of the superpowers.
- **tiny_tasks** — exactly 3 objects, each `{question, options[3], signal_key}`, meaningfully different from each other.

Confidence-level-conditioned instructions (`very_early` / `emerging` / `developing` / `strong`) tune how specific vs. tentative the writing should be — a direct implementation of `052_CONFIDENCE_MODEL.md`'s "confidence changes specificity, never humility."

The parser validates each field independently and falls back per-field to a `FALLBACK_BY_LEVEL` entry keyed by confidence level. Unlike the old headline+body-only fallback, each entry is now a **complete** `SummaryContent` — headline, a 2-paragraph body (including a literal "It isn't clear yet whether..." sentence), a detail section, three superpowers bullets, three watchouts bullets, and three tiny tasks — all real shipped copy, not placeholders. Bullets fall back as a group unless exactly 3 valid strings are returned; tiny tasks fall back unless exactly 3 valid, distinct-question tasks (each with exactly 3 options) are returned.

## `insightConfidence.ts` — deterministic, no AI

Confidence level (`very_early` / `emerging` / `developing` / `strong`) is derived from `storyAnswers.length + scienceBoost` (boost: +4 if ≥3 science memos exist, +2 if ≥2) against thresholds of 8/18/30 answers. Also produces hardcoded `whatWeKnow` / `whatWeNeed` template strings per science-coverage gap, and selects `nextBestQuestion` from a fixed priority order (motivations → strengths → skills → general). Entirely template-string logic.

## `everleapConvergence.ts` — deterministic, no AI

Aggregates `observations[].theme` across all science memos into a theme→sources map, sorted by source count as `dominantThemes`; computes a `coherenceScore` (capped at 100, summed as `strength * 15`); flags `unknownAreas` from missing science keys. **`contradictions` is hardcoded to always return `[]`** — the type supports it, but it's not implemented.

## `guidanceInsights.ts` — orchestrator

Saves all 5 Insights pages (`insights_summary`, `insights_motivations`, `insights_strengths`, `insights_skills`, `insights_fun_facts`) to `user_page_guidance` via upsert on `(user_id, page_key)`.

**Cost tracking:** every live generator is now tracked. The Summary path threads a `track` of `{ userId, feature: "insights_summary" }` into `generateSummaryContent`, so its single AI call is recorded to `ai_usage_audit` like the per-tab generators (`insights_motivations`, `insights_strengths`, `insights_skills`, `insights_time_twin`, `insights_fun_facts`). The earlier gap — where the Summary narrative call was the one untracked generator — no longer exists.

---

# Layer 4 — Action Suggestions (`actions/actionSuggestions.ts`)

The agent behind the Actions surface (generation target `recommendation:actions`). `buildPrompt` synthesizes the user's own family-tagged Story answers (motivations / strengths / skills / other) into a few concrete, teen-safe real-world next steps across five lanes — Work, Learning, World, Impact, Play. The prompt frames Everleap as *"a warm, honest life-exploration guide for a young person (roughly ages 13-22),"* insists each suggestion be concrete and doable this week/month and grounded in something the user actually said, and carries the usual guardrails: low-stakes and safe, no spending/travel/special-access, no diagnosis/promise/prediction, talk *to* them in second person, never "you should"/"you will," no web links or app names. Already-saved-or-handled titles are passed in and explicitly excluded so it never re-proposes them.

The call is `runAnthropic(buildPrompt(...), 1200, { userId, feature: "action_suggestions", source: "generation" })` — cost-tracked like the other generators. Output JSON: `{suggestions: [{title (3-8 word imperative), why (one warm second-person sentence), lane}]}`, capped at 4; `lane` is validated against `work | learning | world | impact | play` (nulled if invalid). Results are read-through cached per user in `user_action_suggestions`, keyed on an `input_hash` of the normalized signals, so it regenerates only when the profile actually changes; a non-blocking `peekActionSuggestions` reads the cache without ever calling the AI. On no signal it returns an empty set with no AI call.

---

# Layer 4 — Explore Career Matching (`explore/careerMatch.ts`, `explore/interestProfile.ts`)

The server-side Work career-matching path (generation target `recommendation:careers`) uses two distinct prompts, both grounded against a bundled O*NET occupation universe.

## RIASEC inference (`interestProfile.ts`)
Infers a six-dimension RIASEC (Holland Code) interest profile from the user's own Story/onboarding evidence. The prompt asks the model to *score each area 0-40 (0 = no sign of it, 40 = a defining, dominant interest)* using only the evidence, and to use the full range rather than flattening everything to the middle. The call is `runAnthropic(buildPrompt(...), 200, { userId, feature: "riasec_infer" })` — a deliberately tiny token budget for a small numeric result. Output JSON: `{realistic, investigative, artistic, social, enterprising, conventional}`, each clamped to `0-40` (`clamp40`). Persisted to `user_interest_profiles` (see `100_DATABASE_SCHEMA.md`).

## Career-match curation + universe fallback (`careerMatch.ts`)
Ranks the O*NET occupation universe into per-user Work picks, each with a grounded "why this fits you." Two prompt paths share an output contract:
- **`buildCuratePrompt`** — the primary path. The RIASEC profile drives an O*NET interest crosswalk that narrows the universe to an interest-matched candidate subset, and the model then curates the best-fit picks for *this* teen from that subset, grounding each pick in the science read first and the user's own words second, and spreading picks across a few fields rather than clustering.
- **`buildPrompt`** — the fallback path when no candidate subset is available; the model ranks the whole universe directly, so matching always works.

Both call `runAnthropic(..., 2500, { userId, feature: "career_match" })`. Output JSON: `{picks: [{title, score, why_you, reasons}]}`, best fit first. Every returned `title` is **validated against the bundled O*NET universe** (the curator passes the candidate subset as the allowed set; the fallback passes the whole universe) — a pick whose title doesn't map to a real occupation is dropped, so the model can never invent a career. Accepted picks are written wholesale to `explore_path_matches` (see `100_DATABASE_SCHEMA.md`), replacing any prior Work matches so stale picks never linger.

## Explore path content — generation ↔ render contract
The on-demand Explore path-generation prompt (`generatePathContent.ts`) emits a **rich object** shape for a single path. A serve-time normalizer (`normalizePathContent.ts`) idempotently upgrades older cached rows to the render contract the frontend expects: string → object `salaryBand` / `aiImpact`, `fitSignal` scores from a 0-5 scale to 0-100, and tone `caution` → `warning`. It is a no-op on content already in the new shape, so it's safe to run on every read regardless of when a row was cached.

---

# AI Usage Tracking

`recordAiUsage.ts` writes to `ai_usage_audit`, looking up live per-model rates from `ai_model_pricing` to compute input/output/cached-input cost. Token fields are normalized across multiple possible key names (`input_tokens` / `inputTokens` / `prompt_tokens`, etc.) to tolerate both OpenAI's and Anthropic's SDK usage shapes. It silently swallows its own errors (`{ok:false, error}`, never throws) — a usage-recording failure can never break generation itself.

`functions/ai/usageSummary.ts` (`GET /ai/usage/summary`) aggregates `ai_usage_audit` by provider into request count, month-to-date cost, all-time cost, and average cost per request.

`AiUsageTrack` (defined in `guidance/shared/anthropic.ts`) gained an optional `actorType` field alongside `feature` / `userId` / `source` / `metadata`, so a recorded call can distinguish who triggered it (e.g. a real user's generation vs. an internal preview run). It also carries an optional `suppressAudit?: boolean` — when set (used by background warming / pre-generation such as career-match warming and warm Explore path content), `runAnthropic` skips the `ai_usage_audit` write so that non-user-facing spend doesn't show on the spend dashboard. The same suppression can be forced globally via the `EVERLEAP_SUPPRESS_AI_AUDIT` env var (`"1"` makes `recordAiUsage` a no-op).

---

# Prompt Lab Preview (`functions/promptLab/promptLabPreview.ts`)

`POST /prompt-lab/preview` is the unlock-gated, rate-limited internal tool that lets a tester tweak a single card's tone/word-count/note and see a live regeneration. It builds a `PromptLabOverride` and threads it into the real per-surface preview generators (`previewTodayCard`, `previewSummaryCard`, `previewMotivationsCard`, `previewStrengthsCard`, `previewSkillsCard`, `previewExploreSummary`) — the same generators the production pipeline uses, so previews exercise the real prompts (via each prompt's `previewOverride` → `buildPromptLabOverrideBlock` injection) rather than a mock.

Crucially, it now threads an `AiUsageTrack` through those generators — `{ userId, feature: "<pageKey>_preview", source: "prompt_lab_preview", actorType: "prompt_lab_user", metadata: {...} }` — so the model call behind every preview records its **real** token usage to `ai_usage_audit` under a distinct source. Previously the endpoint recorded `usage: null`, so preview spend was invisible despite the API call genuinely happening; the dedicated `source`/`actorType` keep preview cost counted but distinguishable from real user spend.

---

# AI Lab — internal prompt-tuning tool, not a production prompt

`functions/aiLabRun.ts` (`POST /ai/lab/run`) is a separate, internal tool — not part of the user-facing generation pipeline. A tester picks a provider (`openai` or `anthropic`), writes or edits an arbitrary prompt, and runs it against a sample set of onboarding-style answers through a fixed two-stage pipeline: (1) an "internal analysis" pass using the supplied prompt, (2) a second hardcoded "compression" pass that condenses stage 1's output into a user-facing response under a configurable character limit (default 700, range 120–4000), itself carrying its own banned/preferred-style rules echoing the same no-diagnosis/no-label/no-therapy-cliché constraints used everywhere else.

Hardcoded pricing for cost estimation: `gpt-4.1-mini` ($0.40 / $1.60 per million input/output tokens), `claude-sonnet-4-5-20250929` ($3 / $15 per million tokens). Both stages call `recordAiUsage` independently (`feature: "ai_lab_internal_analysis"` / `"ai_lab_user_compression"`, `source: "ai_lab"`). See `106_TESTING_STRATEGY.md` for why this tool, despite its value, is not a substitute for automated testing.

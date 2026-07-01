# Prompt Catalog

## Purpose

`053_PROMPT_DESIGN.md` describes the philosophy prompts must follow. This document catalogs the prompts that actually exist in `apps/everleap-api` today: what each one does, what model it calls, what it forbids, and what it returns. Where useful, it quotes real constraints from the prompts rather than paraphrasing — the actual banned-phrase lists are some of the most concrete expression of the product's voice rules (`080_TONE_AND_VOICE.md`, `081_TEEN_LANGUAGE_GUIDE.md`) anywhere in the codebase.

---

# Shared AI Client

`guidance/shared/anthropic.ts` exposes `runAnthropic(prompt)`: model `claude-sonnet-4-5-20250929`, `max_tokens: 1600`, a single user-role message (no system prompt), no temperature override, no retry logic. Returns `{ output, model, latencyMs, usage }`.

**Duplication note:** this shared client is used by the Today and Insights generators, but the three science memo generators (`ikigaiMemo.ts`, `enneagramMemo.ts`, `wciypMemo.ts`) each define their own local, near-identical copy of `runAnthropic` (`max_tokens: 1800`) instead of importing the shared one. `aiLabRun.ts` has yet another independent copy that also dispatches to OpenAI (`max_tokens: 1200`). All Anthropic calls independently hardcode the model string `"claude-sonnet-4-5-20250929"` rather than referencing a shared constant. This is pure duplication, not a behavioral difference — worth consolidating next time any of these files are touched, per `093_ENGINEERING_PRINCIPLES.md`'s "leave every file slightly better than you found it."

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

# Layer 4 — Insights Tabs (`guidance/insights/insightsPrompt.ts` + `insightsParser.ts`)

One prompt call generates 4 of the 5 Insights tabs at once. Input is science memos only (no raw Story answers passed directly).

- Frames Insights explicitly as not-an-assessment, not-career-advice, not-a-report-card.
- Describes the purpose of all 5 tabs (Summary, Motivations, Strengths, Skills, Fun Facts) for context, even though Summary is generated by a separate pipeline (below) and discarded from this response.
- Same "never name the sciences" rule, plus a preferred-phrasing list — *"One pattern I keep noticing...", "What I still cannot tell..."* — echoing `002_PRODUCT_PRINCIPLES.md`'s curiosity-over-certainty language directly.
- Output JSON: `{summary, motivations, strengths, skills, fun_facts}`, each shaped `{headline, guidance_text, next_action_label, next_action_route}`. The parser only extracts `motivations` / `strengths` / `skills` / `fun_facts` — the `summary` field from this call is unused.
- All four pages' `next_action_label` / `next_action_route` are hardcoded by prompt instruction to `"Continue Your Story"` / `/main/story?returnTo=/main/insights"` — not model-decided.
- `insightsParser.ts` uses the same per-field fallback pattern as `todayParser.ts`, falling back to static hardcoded copy (`FALLBACK_INSIGHTS`) on any parse or shape failure.

---

# Layer 4 — Insights Summary (`guidance/insights/summaryGenerator.ts` and friends)

This is the most heavily-prompted single surface in the codebase, and the one the Bible singles out in `034_INSIGHTS_SUMMARY.md` as "a cross-science hypothesis, not another assessment." `generateSummaryPayload()` runs three things in parallel — `computeInsightConfidence` (deterministic), `computeEverleapConvergence` (deterministic), and `loadScienceMemos` — then runs `generateSummaryNarrative` (AI) and `generateSummarySignals` (deterministic, despite appearances — see below) in parallel.

## `summaryNarrative.ts` — the only AI call in this sub-pipeline

Inputs: confidence level, convergence (`dominantThemes`, `contradictions`), `whatWeKnow` / `whatWeNeed`, and flattened hypotheses across all science memos.

Frames itself explicitly as *"the top card on the Insights Summary page... a cross-tab hypothesis,"* not a profile, biography, or conclusion. Carries the longest banned-phrase list in the codebase — *"You are," "Your answers suggest," "patterns are emerging," "based on your responses"* — paired with a preferred-phrase list (*"You may notice...", "It isn't clear yet whether..."*) lifted almost verbatim from `002_PRODUCT_PRINCIPLES.md`'s Principle 3.

Contains the most explicit example in the entire codebase of the Bible's "Patterns Over Biography" principle in action:

> **Bad:** "You built a fencing academy and stepped in during a race."
> **Good:** "Your attention may sharpen when something feels unfinished, unclear, or not working as well as it could."

This confirms the fencing-academy example used as a teaching case in `002_PRODUCT_PRINCIPLES.md` traces directly to this real prompt — almost certainly drawn from the developer's own test onboarding data (and consistent with `apps/vaccaroni`, the unrelated fencing-business client site also present in this workspace).

Structure is mandated strictly: a 4-paragraph body —
1. Name one cross-tab pattern.
2. Show how it surfaces differently across motivations/strengths/skills using "Motivation may..., strengths may..., and skills may..." phrasing.
3. Must literally contain the substring *"It isn't clear yet whether..."*
4. End with one reflection question — no advice.

Confidence-level-conditioned instructions (`very_early` / `emerging` / `developing` / `strong`) tune how specific vs. tentative the writing should be — a direct implementation of `052_CONFIDENCE_MODEL.md`'s "confidence changes specificity, never humility."

Output JSON: `{headline (≤9 words, no identity nouns like "builder"/"leader"/"visionary"), body (130-190 words, exactly 4 paragraphs)}`.

On any failure, falls back to one of four fully-hardcoded static narratives keyed by confidence level (`FALLBACK_BY_LEVEL`) — these are real shipped copy, not placeholders. Each one independently follows the same 4-paragraph structure, including a literal "It isn't clear yet whether..." sentence and a closing question.

## `summarySignals.ts` — not actually AI

Despite being framed alongside an "AI-generated" pipeline in `summaryGenerator.ts`, `generateSummarySignals()` currently calls `fallback()` directly with **no AI call at all**. It deterministically scores 9 hardcoded categories (Motivation, Skills, Relationships, Values, Personality, Learning, Aspirations, Emotions, Creativity) via keyword matching against the convergence/confidence text, renders them as filled/empty dot strings (`●●●○○`), and derives `superpowers` / `watchouts` bullets directly from `whatWeKnow` / `whatWeNeed` (or 3 generic hardcoded bullets if those are empty). This is a real functional gap relative to what the surrounding code implies — worth flagging if/when this becomes a priority, since it's currently shipping static-feeling output dressed as generated insight.

## `insightConfidence.ts` — deterministic, no AI

Confidence level (`very_early` / `emerging` / `developing` / `strong`) is derived from `storyAnswers.length + scienceBoost` (boost: +4 if ≥3 science memos exist, +2 if ≥2) against thresholds of 8/18/30 answers. Also produces hardcoded `whatWeKnow` / `whatWeNeed` template strings per science-coverage gap, and selects `nextBestQuestion` from a fixed priority order (motivations → strengths → skills → general). Entirely template-string logic.

## `everleapConvergence.ts` — deterministic, no AI

Aggregates `observations[].theme` across all science memos into a theme→sources map, sorted by source count as `dominantThemes`; computes a `coherenceScore` (capped at 100, summed as `strength * 15`); flags `unknownAreas` from missing science keys. **`contradictions` is hardcoded to always return `[]`** — the type supports it, but it's not implemented.

## `guidanceInsights.ts` — orchestrator

Saves all 5 Insights pages (`insights_summary`, `insights_motivations`, `insights_strengths`, `insights_skills`, `insights_fun_facts`) to `user_page_guidance` via upsert on `(user_id, page_key)`.

**Cost-tracking gap:** only the 4-tab generation (`generateInsightsForUser`) calls `recordAiUsage` (feature: `insights_guidance`). The Summary path (`generateInsightsSummaryForUser`) does not — its one real AI call, inside `summaryNarrative.ts`, is currently untracked in the cost-audit system (`ai_usage_audit`), unlike every other generator in the codebase.

---

# AI Usage Tracking

`recordAiUsage.ts` writes to `ai_usage_audit`, looking up live per-model rates from `ai_model_pricing` to compute input/output/cached-input cost. Token fields are normalized across multiple possible key names (`input_tokens` / `inputTokens` / `prompt_tokens`, etc.) to tolerate both OpenAI's and Anthropic's SDK usage shapes. It silently swallows its own errors (`{ok:false, error}`, never throws) — a usage-recording failure can never break generation itself.

`functions/ai/usageSummary.ts` (`GET /ai/usage/summary`) aggregates `ai_usage_audit` by provider into request count, month-to-date cost, all-time cost, and average cost per request.

---

# AI Lab — internal prompt-tuning tool, not a production prompt

`functions/aiLabRun.ts` (`POST /ai/lab/run`) is a separate, internal tool — not part of the user-facing generation pipeline. A tester picks a provider (`openai` or `anthropic`), writes or edits an arbitrary prompt, and runs it against a sample set of onboarding-style answers through a fixed two-stage pipeline: (1) an "internal analysis" pass using the supplied prompt, (2) a second hardcoded "compression" pass that condenses stage 1's output into a user-facing response under a configurable character limit (default 700, range 120–4000), itself carrying its own banned/preferred-style rules echoing the same no-diagnosis/no-label/no-therapy-cliché constraints used everywhere else.

Hardcoded pricing for cost estimation: `gpt-4.1-mini` ($0.40 / $1.60 per million input/output tokens), `claude-sonnet-4-5-20250929` ($3 / $15 per million tokens). Both stages call `recordAiUsage` independently (`feature: "ai_lab_internal_analysis"` / `"ai_lab_user_compression"`, `source: "ai_lab"`). See `106_TESTING_STRATEGY.md` for why this tool, despite its value, is not a substitute for automated testing.

# Generator Registry

## Purpose

This document describes the actual implementation of the generation dependency graph described conceptually in `051_GENERATION_PIPELINE.md` and `071_GENERATION_REQUESTS.md`.

Where those documents explain *why* Everleap separates evidence from generated knowledge, this document explains *how* that separation is implemented today in `apps/everleap-api`.

---

# The Three Registries

Everleap's generation system is built from three small, independent registries. Each has exactly one job.

```
scienceRegistry.ts        -> defines what a science IS
generationRegistry.ts     -> defines what can be generated, and what it depends on
generationQueue.ts        -> defines how generation work is scheduled and claimed
```

`generationDispatcher.ts` is the only file that reads from all three. Everything else only needs to know about the registry closest to its job.

---

# Science Registry

File: `apps/everleap-api/src/lib/sciences/scienceRegistry.ts`

Defines the currently implemented sciences as a static array of `ScienceDefinition`:

```ts
type ScienceDefinition = {
  key: string;
  label: string;
  family: "motivations" | "strengths" | "skills";
  description: string;
};
```

| Key | Label | Family | Description |
|---|---|---|---|
| `Ikigai/Motivations` | Ikigai | motivations | Meaning, contribution, energy, curiosity, sacrifice, aspiration |
| `Enneagram/Strengths` | Enneagram | strengths | Recurring motivation, attention, coping, instinctive behavior |
| `Parachute/Skills` | What Color Is Your Parachute | skills | Preferred activities, transferable skills, environments, contribution style |

This matches the Bible's "Phase 1" science set (`040_IKIGAI.md`, `041_ENNEAGRAM.md`, `042_WCIYP.md`). The other four sciences described in `04_Sciences` (SDT, Big Five, Narrative Identity, Possible Selves) are **not yet registered** — adding one means adding an entry here, a `*Memo.ts` generator, and a branch in `scienceConductor.ts`'s `generateMemoForScience`.

Each Story answer carries a `science` key and a `family`. `scienceConductor.ts` matches an answer to a science if either the answer's `science` field equals the science's `key`, or the answer's `family` equals the science's `family`. A science is skipped entirely for a user if no answered Story question matches it — skips are reported, not silently dropped (`ScienceConductorResult.skipped`).

---

# Generation Registry

File: `apps/everleap-api/src/lib/generationRegistry.ts`

Defines every generation target as a `GenerationTargetKey` plus its dependency list:

```ts
type GenerationTargetKey =
  | "science:ikigai"
  | "science:enneagram"
  | "science:parachute"
  | "page:today"
  | "page:insights"
  | "page:insights_summary"
  | "page:insights_motivations"
  | "page:insights_strengths"
  | "page:insights_skills"
  | "page:insights_time_twin"
  | "page:insights_fun_facts"
  | "page:explore"
  | "recommendation:careers"
  | "recommendation:actions"
  | "agent:coach"
  | "agent:mentor"
  | "memory:consolidate";
```

## Dependency graph (as implemented)

```
science:ikigai            (no deps)
science:enneagram         (no deps)
science:parachute         (no deps)

page:today                depends on [ikigai, enneagram, parachute]
page:insights             depends on [ikigai, enneagram, parachute]
page:insights_summary     depends on [ikigai, enneagram, parachute]
page:insights_time_twin   depends on [ikigai, enneagram, parachute]
page:insights_fun_facts   depends on [ikigai, enneagram, parachute]
recommendation:careers    depends on [ikigai, enneagram, parachute]
agent:coach               depends on [ikigai, enneagram, parachute]
agent:mentor              depends on [ikigai, enneagram, parachute]

page:insights_motivations depends on [ikigai]        (single science)
page:insights_strengths   depends on [enneagram]     (single science)
page:insights_skills      depends on [parachute]     (single science)

page:explore              (no deps — reads raw story answers directly)
recommendation:actions    (no deps — reads raw story answers directly)
memory:consolidate        (no deps)
```

This is a **mixed** graph, no longer "every non-science target depends on the full science set." Three shapes coexist: broad targets that depend on all three sciences (`page:today`, `page:insights`, `page:insights_summary`, `page:insights_time_twin`, `page:insights_fun_facts`, the two agents, `recommendation:careers`); per-tab insight targets that depend on exactly one science each (`page:insights_motivations` → Ikigai, `page:insights_strengths` → Enneagram, `page:insights_skills` → Parachute); and targets with no dependencies at all (`page:explore` and `recommendation:actions`, which read the user's raw story answers directly rather than science memos, plus `memory:consolidate`). The Bible's example in `071_GENERATION_REQUESTS.md` ("Today depends on Ikigai, Enneagram, Parachute") is still implemented literally for the broad targets.

`generationDispatcher.ts`'s `runGenerationRecursive` walks this graph depth-first with a `seen` set, so requesting `page:today` for a user transparently runs all three sciences first (if not already running) before Today itself generates. Each dependency is only run once per top-level request, even if multiple targets in the same request share dependencies.

## Implemented vs. registered-but-stubbed

Not every key in the registry has a working generator yet. `runGenerationTarget` in `generationDispatcher.ts` switches on the target key:

| Target | Status |
|---|---|
| `science:ikigai` | Implemented — calls `generateScienceMemosForUser` filtered to Ikigai |
| `science:enneagram` | Implemented |
| `science:parachute` | Implemented |
| `page:today` | Implemented — calls `generateTodayGuidanceForUser` |
| `page:insights` | Implemented — calls `generateInsightsForUser` |
| `page:insights_summary` | Implemented — calls `generateInsightsSummaryForUser` |
| `page:insights_motivations` | Implemented — calls `generateInsightsMotivationsForUser` |
| `page:insights_strengths` | Implemented — calls `generateInsightsStrengthsForUser` |
| `page:insights_skills` | Implemented — calls `generateInsightsSkillsForUser` |
| `page:insights_time_twin` | Implemented — calls `generateInsightsTimeTwinForUser` |
| `page:insights_fun_facts` | Implemented — calls `generateInsightsFunFactsForUser` |
| `page:explore` | Implemented — calls `generateExploreSummaryForUser` |
| `recommendation:actions` | Implemented — calls `generateActionSuggestionsForUser` |
| `memory:consolidate` | Implemented — calls `consolidateUserMemory` |
| `recommendation:careers` | Implemented — dispatches to `generateCareerMatchesForUser` (`src/lib/explore/careerMatch.ts`); `dependsOn` all three sciences |
| `agent:coach` | **Stub** |
| `agent:mentor` | **Stub** |

Only `agent:coach` and `agent:mentor` remain registered-but-stubbed (they share a single fall-through `case` that logs and returns). The switch statement ends with an exhaustive `never` check, so adding a new `GenerationTargetKey` without adding a corresponding `case` is a compile error — the registry and the dispatcher cannot silently drift apart.

---

# Generation Queue

File: `apps/everleap-api/src/lib/generationQueue.ts`

This is the persistence and scheduling layer, backed by the `user_generation_requests` table (see `100_DATABASE_SCHEMA.md`).

Key behaviors:

- **`enqueueGeneration`** — upserts by `unique_key` (default `userId:targetKey:executionMode`). If a pending/running request for the same unique key already exists, it's updated in place (trigger replaced, priority lowered to the min of old/new, `run_after` moved earlier) rather than duplicated. This is what keeps the queue idempotent under repeated triggers (e.g. rapid Story answers).
- **`forceGeneration`** — a convenience wrapper that calls `enqueueGeneration` with `executionMode: "immediate"` and a high priority (`10` by default, vs. the normal default of `100`).
- **`claimPendingGeneration`** — uses `SELECT ... FOR UPDATE SKIP LOCKED` ordered by `priority asc, requested_at asc` to atomically claim exactly one pending, due (`run_after <= now()`) request per call. This is what allows multiple workers to poll concurrently without claiming the same row twice.
- **`markGenerationComplete`** / **`markGenerationFailed`** — terminal state transitions; failure records the error message but does not currently implement automatic retry/backoff (a request that fails stays `failed` until something re-enqueues it).

---

# How the three registries compose

```
User action (API function)
        |
        v
enqueueGeneration({ userId, targetKey, trigger, ... })   [generationQueue.ts]
        |
        v
   user_generation_requests row (status = pending)
        |
        v
generationRun.ts  (HTTP-triggered)  or  generationTimer.ts (schedule-triggered)
        |
        v
claimPendingGeneration()   [generationQueue.ts]
        |
        v
runGenerationRequest(claimed)   [generationDispatcher.ts]
        |
        v
getGenerationTarget(targetKey).dependsOn   [generationRegistry.ts]
        |
        v
runGenerationRecursive(...)  -- runs each dependency first, depth-first, deduped
        |
        v
runGenerationTarget(...)  -- the switch statement that calls the real generator
        |
        v
   science generator reads getScienceDefinitions()   [scienceRegistry.ts]
        |
        v
markGenerationComplete(id)  or  markGenerationFailed(id, error)
```

See `103_EVENT_FLOW.md` for which user actions enqueue which targets, and `071_GENERATION_REQUESTS.md` for the product-level rationale.

---

# Extending the registry

Adding a new science (per the Bible's "Science Expansion" roadmap in `090_PRODUCT_ROADMAP.md`):

1. Add an entry to `SCIENCE_DEFINITIONS` in `scienceRegistry.ts`.
2. Implement a `generate<Name>MemoForUser` function (mirroring `ikigaiMemo.ts`).
3. Add a branch in `scienceConductor.ts`'s `generateMemoForScience`.
4. Add `"science:<name>"` to `GenerationTargetKey` and `generationTargets` in `generationRegistry.ts` (with `dependsOn: []`).
5. Add the new key to the `sciences` array in `generationRegistry.ts` so existing pages automatically depend on it.
6. Add a `case "science:<name>":` branch in `generationDispatcher.ts`'s `runGenerationTarget`.

Because the `never` exhaustiveness check exists, step 6 is enforced by the compiler — you cannot ship a registered target without a dispatcher branch.

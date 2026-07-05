# Explore Architecture & Rebuild Plan

## Purpose

Explore is the largest and most important section of the product. This document
began as the rebuild plan that took it from a time-boxed prototype — hardcoded
mock content, `localStorage` signals, keyword matching — toward what the rest of
the platform already is: **AI-generated knowledge, created in the background,
stored in the database, and served instantly.** Much of that plan has now
shipped; this doc is being kept as an **as-built** record where it has, and a
plan where it hasn't.

It is a direct application of the platform's central principle
([060 System Architecture](060_SYSTEM_ARCHITECTURE.md)):

> **Pages consume knowledge. They never create it.**

Status (updated 2026-07-05):

- **Phase A · Consolidate & Reskin — SHIPPED.** One unified `ExplorePath` schema;
  shared landing + detail engines; the dead engine and V1 debt deleted; Play
  populated; the summary entry screen live.
- **Phase B · Catalog + Generation (CONTENT layer) — SHIPPED.** The
  `explore_paths` catalog table and read-through AI generation are live
  (`getOrGeneratePath` → hit serves the stored row, miss calls Claude and
  stores). Mock TypeScript is now only an instant Phase-A fallback, not the
  source of truth.
- **Phase B · MATCH layer — NOT built.** Per-user fit/scoring is still computed
  **client-side** from `localStorage`. The `explore_path_matches` table exists
  in the migration but **no code reads or writes it**, and there is no
  `PathMatch` server type. "Recompute match on signal change" remains
  outstanding.
- **Phase C · Warming & Pre-seed — partial.** A per-user Explore *summary*
  generator ships with input-hash caching and queue pre-warming; the tiered deck
  warming and offline head pre-seed builder are not built yet.

---

# Where We Started (Phase A baseline)

*This section records the prototype the rebuild started from, for context. Most
of the debt below has since been cleared — see "What Shipped" next.*

Explore was five lanes behind a pill rail — **Work, Learning, World, Impact,
Play**. The entry route redirected straight to Work; there was no summary screen.
Everything was local mock TypeScript plus `localStorage` onboarding answers, and
"recommendations" were keyword overlap between the two. No database, no AI.

The depth was severely asymmetric — really **five diverging half-systems plus a
dead sixth**.

| Lane | Screens deep | Mocks | State |
|---|---|---|---|
| **Work** | 6 (overview → day · forecast · next-steps · specialties → specialty detail) | 6 | The crown jewel — BLS-style salary/forecast, day-in-life, 12 dev specialties, live opportunities. ~2,850 lines. |
| **Learning** | 2 (landing → detail) | 6 | Radar chart, quick-check, opportunities. |
| **World** | 2 | 6 | Richest detail page of the shallow four. |
| **Impact** | 2 | 6 | Schema carries an unrendered layer (branches / growth / how-it-feels). |
| **Play** | 2 | 6 | Data files were **empty (0 bytes)** — content synthesized from the URL slug; had a live routing bug. |

### Debt to clear before building up — done (Phase A)

All three of these were cleared in Phase A:

- **An entire orphaned recommendation engine** — the web files
  `exploreRecommendations`, `exploreCatalog`, `exploreEngine`, `exploreSeedData`,
  `exploreTypes`, and the components `ExploreLaneRail` / `ExplorePathPanel` /
  `ExploreSpotlightPath` — were **deleted**. (Note: a *different*, live
  `exploreCatalog.ts` and `exploreTypes.ts` now exist on the **API** side as the
  catalog data-access layer and the server schema mirror — same names, new
  purpose, not the deleted web files.)
- **The five 1,300–1,700-line landing pages** that re-implemented the same
  read-score-render logic over five subtly different schemas were **collapsed**
  into one unified `ExplorePath` schema (`_data/exploreSchema.ts`) rendered by a
  single landing engine (`ExploreLanding`) and detail engine (`ExplorePathDetail`).
- **Superseded V1 schemas** inside Work (`forecast`, `nextSteps`), the unused
  `WorkPathSubnav`, and never-rendered fields were removed; Play's empty data +
  routing bug were fixed (Play now ships real content on the unified schema).

---

# What Shipped

**Entry screen (not a redirect).** `/main/explore` no longer redirects to Work.
It renders a summary entry screen — a per-lane teaser deck (the strongest pick
from each of the five lanes) plus an agentic whole-life narrative — via
`ExploreSummaryLoader` (`page.tsx` → `ExploreSummaryLoader` → `ExploreSummary`).
The loader paints the mock composition instantly, then fetches each lane's deck
from the DB catalog (`/api/explore/paths?lane=…`) and swaps each lane to its DB
deck; any lane that misses keeps its mock deck, so it can't regress.

**DB catalog + read-through generation (CONTENT layer).** The `explore_paths`
table is the shared, user-independent content cache. `getOrGeneratePath(lane,
title)` canonicalizes the title to a key, checks the catalog, and on a **hit**
serves the stored `content` jsonb instantly; on a **miss** it gathers grounding
facts (Wikipedia every lane; O\*NET + BLS for Work when creds are set), has
Claude synthesize the full `ExplorePath`, writes the row, and serves it — cached
for every future user. Detail pages wire through `ExplorePathDetailLoader`, which
renders a mock immediately when one exists and swaps in the catalog row from
`/api/explore/path?lane=…&slug=…`; a DB-only (warm) path with no mock loads
straight from the catalog. Mock TypeScript is now only the instant Phase-A
fallback, never the source of truth.

**Per-user Explore summary generator (agentic whole-life read).**
`exploreSummary.ts` (`getOrGenerateExploreSummary`) produces a short, grounded
"whole-life view" — `{ headline, body, threads }` — synthesized from the user's
own **story answers** (motivations / strengths / skills), sourced **server-side**
from the DB, never the client body, so the cache key is deterministic. It is
input-hash cached per user in **`explore_user_summary`** (regenerated only when
the signals change), and pre-warmed through the generation queue via the
**`page:explore`** target so the card reads back a cache hit instead of blocking
on a live call. A Prompt Lab preview path (`previewExploreSummary`, reached via
`functions/promptLab/promptLabPreview.ts`) regenerates it live with founder
overrides layered on, tracked under the `prompt_lab_preview` cost source and
never persisted.

**Progressive disclosure on detail pages.** `ExplorePathDetail` renders its deep
sections **collapsed by default** (a `Collapsible` whose title + one-line teaser
read as a menu; tapping reveals the section) so the page stays short and
scannable on a phone, instead of one long fully-expanded scroll.

### Match layer — NOT built yet

Per-user match is still the Phase-A client-side stand-in. **The
`explore_path_matches` table exists in the migration but is unused by any code,
and there is no `PathMatch` server type.** `_lib/exploreProfile.ts`
reads the user's signal from the `localStorage` key
`everleapOnboarding_v4_convo_min` (overlaid with the server's story answers via
`/api/guidance/explore-profile` when logged in), and `_lib/scorePath.ts` scores
each path **client-side** by keyword overlap for deck ordering and the signal
meter. So the plan's *"recompute match on signal change (a generation-pipeline
target)"* remains outstanding — see Phase B below.

---

# Decisions Locked

- **Reskin + consolidation** — not just a paint job; unify the five
  schemas/pages into one and delete the dead engine.
- **Summary entry screen**, modeled on the Insights summary — the new default
  landing for `/main/explore`.
- **Play stays broad** (sports, hobbies, outdoor, making, reset) — not literal
  video games.
- **AI-generated, DB-backed content** — retire mock TypeScript as the source of
  truth.
- **Two-layer data model** — a shared cached content catalog + a live per-user
  match layer.
- **Phased delivery** — reskin/consolidate first, then the data backend, then
  warming/pre-seed.

---

# Information Architecture

One **shared path spine every lane inherits**, plus an optional branch module
only where the domain earns it. This is simultaneously the IA and the
consolidation.

### Universal spine — all five lanes

1. **Overview** — what it is · why you fit · signal score.
2. **What it's really like** — the "day in the life" idea, generalized to any lane.
3. **Where it leads** — forecast / trajectory / growth.
4. **Try it for real** — concrete next steps & opportunities.

### Optional branch module

Rendered only when meaningful: **Work → specialties**, **Impact → branches**,
**Learning → tracks/levels**, **World → itineraries**. Play needs none.

So every lane feels equally considered (a 4-screen spine) without forcing "rock
climbing" into six screens while "doctor" branches into twelve specialties.

### Summary entry

`/main/explore` stops redirecting to Work. It renders an Insights-style
overview: a framing line plus the single strongest pick from *each* lane as a
teaser card, each linking into its lane. This puts all five lanes on equal
footing at the top and sells the whole-life framing that differentiates Explore
from a career quiz.

---

# Data Architecture

The core insight: there are two *kinds* of data and they want opposite
strategies. Conflating them is the mistake to avoid.

### Two layers

**Content layer — the Catalog.** What "doctor" *is*. Depends on the path only —
identical for every user. Day-in-life, salary, forecast, specialties,
opportunities. Expensive to make (AI + real sources). **Fully cacheable across
users.** Changes only when source data updates (slowly).

**Match layer — per user.** Why *you* fit doctor. Depends on the individual's
signal. Fit score, rank, personalized "why you" hook. Cheap to compute. **Never
cached in the catalog.** Recomputed when the user's signal changes.

> The read-through cache applies to the **content** layer; personalization is
> always computed fresh on top. Cache the encyclopedia — compute the "why you."

### Read-through population — the "doctor" flow

1. **Match** — the user's signal resolves to a *canonical key*, e.g.
   `onet:29-1215`, not "doctor" / "MD".
2. **Lookup** — check the Catalog for that key.
3a. **Hit** — render from the database instantly. The common case: cheap, fast.
3b. **Miss** — pull facts from approved sources → Claude synthesizes narrative,
   grounded and cited → write the row → serve. **Now cached for every future
   user.**

### Canonicalization is make-or-break

For the cache to hit, "doctor", "physician", "become an MD", and a free-text
goal must resolve to **one** key *before* the lookup — otherwise we regenerate
the same content under a dozen keys and the cache never warms. Resolve free-text
→ canonical id via embedding + a real taxonomy (**O\*NET codes** for Work; each
lane gets its own canonical vocabulary). Embeddings are already wired.

### Freshness — hybrid, split by layer

- **Content** barely changes. Evergreen prose (day-in-life) is generated once and
  kept. Time-sensitive fields (salary, forecast) get a `generatedAt` + source
  version; a slow background job re-validates *only* those on a cadence.
- **Match** is event-driven — recomputed when the user's signal changes, reusing
  the cached content.

### Matching — hybrid retrieval + generative

Retrieval (embed signal → nearest catalog paths) fills the deck from the warm
catalog — fast, always a hit. A generative pass can occasionally propose a novel
path for the long tail, which then *populates* the catalog for everyone after.
Same retrieval-then-generate shape as the Time Twin figure library.

> **One function, three triggers.** Pre-seed, per-user warming, and cache-miss
> all call the same `generatePathContent()`. Only the trigger differs — offline
> batch · background warm · on-demand. The offline builder needs no user; it
> just walks the taxonomy head.

---

# Sources Per Lane

Accuracy requirements aren't uniform — they run on a gradient, and that sets how
much is hard-sourced vs. AI-synthesized. Every lane uses the same pipeline
(*retrieve facts → Claude synthesizes → attach citations → cache*); only the
fact density changes.

| Lane | Canonical vocab | Hard-fact sources (ingest & cite) | Opportunities | Bar |
|---|---|---|---|---|
| **Work** | O\*NET codes | O\*NET (tasks/skills/specialties) + BLS OOH (pay/growth/education) | CareerOneStop + curated | cited |
| **Learning** | O\*NET skills / AI | Credential Engine, CareerOneStop training | link-out: Coursera / edX / Khan / YouTube | grounded |
| **Impact** | AI cause taxonomy | AmeriCorps (gov), cause data | link-out: VolunteerMatch / Idealist | grounded |
| **World** | Geographic taxonomy | Wikipedia / Wikivoyage, UNESCO heritage | curated program links | grounded |
| **Play** | AI activity taxonomy | general knowledge / Wikipedia | link-out: Meetup / clubs / YouTube | creative |

### Ingestion guardrail

Only **ingest** content from open / government / CC-licensed sources (O\*NET,
BLS, AmeriCorps, UNESCO, Wikipedia/Wikidata are public-domain or CC). For
commercial sites (Coursera, Udemy, Meetup) we **link out, never ingest** — their
ToS forbid it. All narrative is AI-synthesized on top and carries source
citations, held to the same teen-safety bar as the rest of the app's prompts
([081 Teen Language Guide](../08_Writing/081_TEEN_LANGUAGE_GUIDE.md)).

---

# Predictive Warming & UX

*Planned (Phase C) — not built. The per-user Explore **summary** already
pre-warms through the `page:explore` queue target, but the tiered **deck**
warming below does not exist yet, and depends on the match layer, which is also
unbuilt.*

The best cold-miss UI is **no cold miss**. Once a user's match is recomputed on
signal change (onboarding completion, new answers), we know their predicted deck
— so we enqueue content generation for it into the existing async queue
([051 Generation Pipeline](../05_AI/051_GENERATION_PIPELINE.md)). By the time they
open Explore, the rows exist and render instantly.

### Tiered, to keep it affordable

- **Card-level content** for the *whole* predicted deck → warmed immediately
  (cheap: title, hook, signal, one-liner).
- **Deep-screen content** (day-in-life, forecast, specialties) → warmed only for
  the **top 1–3 paths per lane**, since those get opened.
- **Long tail** (an unpredicted deep click) → generated on demand via the queue,
  behind a graceful inline **skeleton** ("building this path…") — never a
  blocking wall.

Combined with the head pre-seed, most decks are already warm from the shared
catalog before the per-user warm even runs. Users effectively never wait.

---

# Pre-seed Strategy

Pre-seeding *everything* is impossible and goes stale. Pre-seed the **head**,
lazy-populate the tail — Zipf says a small head covers most users.

- **Work** — full deep content for the **top ~150 occupations** (O\*NET has
  ~1,000; the top 150 cover the overwhelming majority of teen aspirations). The
  most-reused catalog, so it earns the depth.
- **Learning / World / Impact / Play** — card + first-level depth for a **~40-each**
  head; deep screens warmed per user.

Reuse the **Time Twin builder pattern**: idempotent, resumable, offline, and run
with `EVERLEAP_SUPPRESS_AI_AUDIT=1` so seeding never pollutes the spend
dashboard. One-time cost is a few hundred dollars, like the figure-library run.

---

# Consolidated Schema

One catalog row type for all five lanes — common spine + optional modules — and
a separate, never-cached match type.

```ts
// One canonical catalog row — user-independent, cached, source-grounded
type ExplorePath = {
  id: string;            // canonical key, e.g. "onet:29-1215"
  lane: Lane;            // work | learning | world | impact | play
  slug: string;
  title: string;
  taxonomyCode?: string; // O*NET / cause / activity code — for dedup

  // ── Universal spine (every lane renders these) ──
  card:       { title; hook; description };        // deck / list level
  overview:   { summary; whyItPullsYouIn[]; traitChips[] };
  reality:    { title; summary; moments[] };       // "what it's really like"
  trajectory: { outlook; metrics[]; growth[]; salaryBand? };
  nextSteps:  { sections: OpportunitySection[] };

  // ── Optional branch module (only where the domain earns it) ──
  branches?: Branch[];   // Work specialties · Impact branches · Learning tracks

  // ── Provenance & freshness ──
  sources: Citation[];   // which approved source each fact came from
  generatedAt: string;
  sourceVersion: string;
  contentModel: "seed" | "warm" | "on-demand";
};

// Per-user — computed on signal change, never in the catalog
// NOTE: NOT wired. The `explore_path_matches` table exists in the migration but
// no code uses it, and this type does not exist. Per-user
// match is still the client-side stand-in (_lib/scorePath.ts over the
// localStorage signal). This block is the planned server shape.
type PathMatch = {
  userId; pathId;
  score; rank;
  whyYou: string;        // personalized hook
  reasons: Reason[];
  generatedAt;
};
```

The frontend renders any lane from `ExplorePath` through **one landing engine
and one detail engine** — replacing five bespoke ~1,500-line pages. The shipped
`ExplorePath` lives in `_data/exploreSchema.ts` (web) with a server mirror in
`exploreTypes.ts` (API) that the `content` jsonb column stores verbatim. The
`PathMatch` half is not built; scoring is layered on client-side at render.

---

# Phased Delivery

### Phase A · Consolidate & Reskin — *frontend* — ✅ SHIPPED

- ✅ Single `ExplorePath` schema; shared landing + detail engines.
- ✅ Existing mock content (6 careers + L/W/I/Play) migrated onto it, unified.
- ✅ Dead engine + unused `WorkPathSubnav` + V1 `forecast`/`nextSteps` deleted;
  Play's empty data + routing bug fixed.
- ✅ Restyled onto the site's `SectionCard` / `sectionCard()` system.
- ✅ Insights-style summary entry added.

### Phase B · Catalog + Generation Pipeline — *backend* — 🟡 CONTENT shipped, MATCH not

- ✅ `explore_paths` catalog table (CONTENT layer). ❌ **`explore_path_matches`
  table exists but is unused** — the per-user MATCH layer is not wired.
- ✅ Canonicalization: `canonicalizePath.ts` (`canonicalKey` / `slugify`);
  Work resolves a SOC code (`resolveSoc.ts`) so BLS can look up real wages.
  (Embedding-based free-text resolution still to come.)
- ✅ The single `generatePathContent()` — grounded on approved sources
  (Wikipedia / O\*NET / BLS via `sources/registry.ts`), with citations — behind
  the read-through cache-miss path (`getOrGeneratePath`).
- ❌ **Wire the match layer to recompute on signal change** — outstanding. Match
  is still client-side (`_lib/scorePath.ts`).
- ✅ Frontend reads the catalog (`ExploreSummaryLoader` / `ExplorePathDetailLoader`),
  falling back to the mock only on a miss.

### Phase C · Warming & Pre-seed — *scale & polish* — 🟡 partial

- ✅ Per-user Explore **summary** pre-warmed via the `page:explore` queue target
  (`exploreSummary.ts`, input-hash cached in `explore_user_summary`).
- ❌ Tiered predictive **deck** warming enqueued on onboarding / signal change —
  not built (depends on the match layer).
- ❌ Offline pre-seed builder (Time Twin pattern, audit-suppressed) for the head.
- ❌ Freshness job re-validating time-sensitive fields on a cadence.

---

# Open Questions & Risks

- **Canonicalization quality** sets the cache hit-rate — the single biggest
  technical risk. Worth prototyping the resolver early in Phase B.
- **Source access & ToS** — confirm the O\*NET / BLS / AmeriCorps / UNESCO
  ingestion paths; keep commercial strictly link-out.
- **Generation cost & freshness cadence** — how often to re-validate
  salary/forecast, and the ceiling on on-demand tail generation.
- **Match quality** — tuning the retrieval/generative hybrid so decks feel
  personal without flooding the tail with cold misses.
- **Content safety** — teen-audience bar on all AI narrative, same guardrails as
  the existing prompts.
- **Non-Work source fuzziness** — World/Play lean creative; confirm that's
  acceptable and where curation is required.

---

## Related

- [033 Explore](../03_Pages/033_EXPLORE.md) — the page's product intent.
- [039 Recommendations](../03_Pages/039_RECOMMENDATIONS.md).
- [060 System Architecture](060_SYSTEM_ARCHITECTURE.md) — "pages consume knowledge."
- [061 Database Philosophy](061_DATABASE_PHILOSOPHY.md).
- [051 Generation Pipeline](../05_AI/051_GENERATION_PIPELINE.md) — the async queue this reuses.

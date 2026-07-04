# Explore Architecture & Rebuild Plan

## Purpose

Explore is the largest and most important section of the product. Today it is a
time-boxed prototype: hardcoded mock content, `localStorage` signals, and
keyword matching. This document defines how it becomes what the rest of the
platform already is — **AI-generated knowledge, created in the background,
stored in the database, and served instantly.**

It is a direct application of the platform's central principle
([060 System Architecture](060_SYSTEM_ARCHITECTURE.md)):

> **Pages consume knowledge. They never create it.**

Status: **Draft for review — 2026-07-03.** Supersedes the prototype's
mock/`localStorage` model.

---

# Where We Are Today

Explore is five lanes behind a pill rail — **Work, Learning, World, Impact,
Play**. The entry route redirects straight to Work; there is no summary screen.
Everything is local mock TypeScript plus `localStorage` onboarding answers, and
"recommendations" are keyword overlap between the two. No database, no AI.

The depth is severely asymmetric, and the section is really **five diverging
half-systems plus a dead sixth**.

| Lane | Screens deep | Mocks | State |
|---|---|---|---|
| **Work** | 6 (overview → day · forecast · next-steps · specialties → specialty detail) | 6 | The crown jewel — BLS-style salary/forecast, day-in-life, 12 dev specialties, live opportunities. ~2,850 lines. |
| **Learning** | 2 (landing → detail) | 6 | Radar chart, quick-check, opportunities. |
| **World** | 2 | 6 | Richest detail page of the shallow four. |
| **Impact** | 2 | 6 | Schema carries an unrendered layer (branches / growth / how-it-feels). |
| **Play** | 2 | 6 | Data files are **empty (0 bytes)** — content synthesized from the URL slug; has a live routing bug. |

### Debt to clear before building up

- **An entire orphaned recommendation engine** — `exploreRecommendations`,
  `exploreCatalog`, `exploreEngine`, `exploreSeedData`, `exploreTypes`, and the
  components `ExploreLaneRail` / `ExplorePathPanel` / `ExploreSpotlightPath` —
  is imported by nothing.
- **Each landing page is 1,300–1,700 lines** re-implementing the same
  read-score-render logic five times over five subtly different schemas (theme
  as `{r,g,b}` in three lanes but a CSS string in World; different lookup
  strategies; quick-check in different places).
- **Superseded V1 schemas** inside Work (`forecast`, `nextSteps`) sit beside the
  `V2` versions that actually render, plus an unused `WorkPathSubnav` and schema
  fields that never render.

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

The best cold-miss UI is **no cold miss**. We already recompute a user's match on
signal change (onboarding completion, new answers). At that moment we know their
predicted deck — so we enqueue content generation for it into the existing async
queue ([051 Generation Pipeline](../05_AI/051_GENERATION_PIPELINE.md)). By the
time they open Explore, the rows exist and render instantly.

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
type PathMatch = {
  userId; pathId;
  score; rank;
  whyYou: string;        // personalized hook
  reasons: Reason[];
  generatedAt;
};
```

The frontend renders any lane from `ExplorePath` + `PathMatch` through **one
landing engine and one detail engine** — replacing five bespoke ~1,500-line
pages.

---

# Phased Delivery

### Phase A · Consolidate & Reskin — *frontend, no backend risk*

- Define the single `ExplorePath` schema; build the shared landing + detail engines.
- Migrate the existing mock content (6 careers + L/W/I/Play) onto it — same
  content, unified.
- **Delete the dead engine** + unused `WorkPathSubnav` + V1 `forecast`/`nextSteps`;
  fix Play's empty data + routing bug.
- Restyle onto the site's `SectionCard` / `sectionCard()` system: 720px column,
  flat `white/10` borders, one muted tone per lane, the small monochrome corner
  constellation.
- Add the Insights-style summary entry.

### Phase B · Catalog + Generation Pipeline — *backend*

- DB tables: `explore_paths` (catalog) + `path_matches` (per user).
- Canonicalization: embedding + taxonomy resolver (free-text → canonical id).
- The single `generatePathContent()` — grounded on approved sources, with
  citations — behind a read-through cache-miss path.
- Wire the match layer to recompute on signal change (a generation-pipeline target).
- Swap the frontend from mock imports to DB reads.

### Phase C · Warming & Pre-seed — *scale & polish*

- Tiered predictive warming enqueued on onboarding / signal change.
- Offline pre-seed builder (Time Twin pattern, audit-suppressed) for the head.
- Freshness job re-validating time-sensitive fields on a cadence.

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

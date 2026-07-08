# Idea Backlog

## Purpose

This is the running list of things Everleap might build, might fix, or is deciding about.

It is not a commitment.

It is not a roadmap—the Roadmap (090) holds the durable capability arc; this holds the moving candidates beneath it.

Items move through: **Idea → Candidate → In Progress → Shipped** (or **Parked**).

> Note: this file was reconstructed on 2026-07-05 after its contents were found to be a misfiled copy of the Design Principles doc. The engineering-grounded items below are drawn from the current codebase; the product-idea section is intentionally left for the founder to populate—it should not be invented.

---

# Recently Shipped

Moved out of the backlog. Kept here briefly for context, then pruned.

- **Input-hash generation cache + science de-amplification** — every AI target skips its call when inputs are unchanged; sciences run once per bundle. Whole-account regeneration is now cost-safe. (see ADR-0008)
- **Insights consistency** — story completion now refreshes the rich per-tab insight generators; the payload-less combined `page:insights` path is no longer triggered.
- **Non-blocking action suggestions** — the Actions page serves cached suggestions instantly and warms new ones in the background instead of blocking on a live model call.
- **AI-spend source breakdown** — the AI Lab screen splits spend into real user (`app`) vs internal tools (`ai_lab`, `prompt_lab`). (see ADR-0010)
- **Prompt Lab** — passcode-gated live prompt-preview tuning on the cards. (see ADR-0009)
- **Explore content layer** — DB catalog (`explore_paths`) + read-through AI generation + a per-user Explore summary; mobile progressive-disclosure detail pages.
- **Explore Work career matching (O\*NET)** — server-side per-user matching shipped: `careerMatch.ts` infers RIASEC → O\*NET v2 interest crosswalk → Claude curation → `explore_path_matches`, wired to the `recommendation:careers` target (recomputes on signal change, input-hash cached). Adds the bundled O\*NET universe (`onetOccupations.ts`/`occupationUniverse.ts`), O\*NET profile cache (`onetCache.ts` + `onet_occupations`), RIASEC inference (`interestProfile.ts` + `user_interest_profiles`), background warming of matches, and a serve-time content normalizer (`normalizePathContent.ts`). (see 063)

---

# In Progress / Next

Grounded in current code—these are real, partially-built or clearly-pending.

- **Non-Work lane matching** — the Work lane is now server-matched (O\*NET), but Learning / World / Impact / Play still rank **client-side** (`apps/web/.../explore/_lib/scorePath.ts`) from `localStorage` signal, and fresh users see empty non-Work decks. Give each lane its own taxonomy + server-side match layer. (see 063)
- **Retire the orphaned combined insights generator** — `page:insights` / `generateInsightsForUser` still exists but no live trigger uses it. Decide whether to delete it or keep it as a manual full-rebuild path.
- **Implement the four planned sciences** — SDT, Big Five, Narrative Identity, Possible Selves have Bible docs (043–046) but no generators. Only Ikigai / Enneagram / Parachute are live.
- **Fill the remaining stub generation targets** — `agent:coach` and `agent:mentor` are registered but only log "not implemented yet." (`recommendation:careers` is now implemented — see Recently Shipped.)

---

# Known Debt

Worth tracking, not urgent.

- **No longitudinal history** — generated knowledge (science memos, page guidance, memory) upserts in place; only the latest row per (user, key) is kept. History-over-time is aspirational. (see 070)
- **generationTimer schedule vs comment** — the cron fires once per minute while the inline comment still describes a 10-second / 5-minute cadence. Reconcile.
- **No first-class version columns** — prompt / generator / model version live only as strings inside `source_snapshot` JSON, not queryable columns.
- **Two hardcoded model-string copies remain** — the shared client uses `ANTHROPIC_MODEL`, but the science-memo generators and `aiLabRun.ts` still keep local copies.

---

# Ideas & Candidates

> Product ideas belong here—features and directions the founder is weighing that are NOT yet reflected in code. This section was lost with the original file; it should be repopulated deliberately, not reconstructed from the codebase. Seed it from your own notes.

- _(add product ideas here)_

---

# How This List Stays Honest

- An item leaves **Shipped** and is pruned once it's been in the code long enough to be assumed, not announced.
- An item in **In Progress / Next** or **Known Debt** should name the file or table it concerns, so it can be verified against code.
- If an item can't be tied to a real need or a real place in the system, it's an **Idea**, not a Candidate—keep it in the section above until it earns its place.

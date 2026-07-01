# Implementation Index

## Purpose

The rest of the Product Bible (`00_Foundation` through `09_Future`) describes what Everleap believes and why it behaves the way it does. This `10_Implementation` section is different in kind: it describes **what is actually built**, as verified by reading the real code in `apps/everleap-api` and `apps/web`, not what was intended or planned.

Where the rest of the Bible should be read top-down per `README.md`'s recommended order, this section is meant to be used as a reference — jump to the document that answers your question.

---

# What's in This Section

| Doc | Answers |
|---|---|
| `100_DATABASE_SCHEMA.md` | What tables actually exist in Postgres, what they store, and where the schema has drifted or accumulated debt |
| `101_API_CONTRACTS.md` | Every Azure Function endpoint — route, auth, request/response shape, side effects |
| `102_GENERATOR_REGISTRY.md` | How the science registry, generation registry, and generation queue compose to implement the dependency-resolving generation pipeline |
| `103_EVENT_FLOW.md` | Which user actions trigger which generation requests, and how background workers pick them up |
| `104_PROMPT_CATALOG.md` | Every AI prompt in production — purpose, model, constraints, output contract |
| `105_DEPLOYMENT.md` | How each app actually deploys — CI/CD pipelines, hosting, required environment variables |
| `106_TESTING_STRATEGY.md` | What automated testing exists today (none) and what tooling exists instead |
| `107_CHANGELOG.md` | The build history of both repos, read as eras rather than commit-by-commit |
| `108_INDEX.md` | This document |
| `109_EVERLEAP_PLAYBOOK.md` | A synthesized, practical guide for working in this codebase day to day |

---

# How This Section Relates to the Rest of the Bible

Every document above traces back to a philosophy document earlier in the Bible. Some load-bearing connections worth knowing before you read further:

- `100_DATABASE_SCHEMA.md` is the concrete version of `061_DATABASE_PHILOSOPHY.md` and `070_DATA_MODEL.md`.
- `101_API_CONTRACTS.md` is the concrete version of `062_PAGE_CONTRACTS.md`'s "pages never call AI" rule — it shows what pages are actually allowed to ask the API for.
- `102_GENERATOR_REGISTRY.md` and `103_EVENT_FLOW.md` together are the concrete version of `051_GENERATION_PIPELINE.md` and `071_GENERATION_REQUESTS.md`.
- `104_PROMPT_CATALOG.md` is the concrete version of `053_PROMPT_DESIGN.md`, `080_TONE_AND_VOICE.md`, and `081_TEEN_LANGUAGE_GUIDE.md` — the banned-phrase lists quoted there are the voice rules enforced as code, not just guidance.
- `105_DEPLOYMENT.md` and `106_TESTING_STRATEGY.md` extend `093_ENGINEERING_PRINCIPLES.md` into specifics the principles document doesn't (and shouldn't) cover.
- `107_CHANGELOG.md` is a factual companion to `094_ARCHITECTURE_DECISION_RECORDS.md` — the changelog says *what happened*, ADRs (once written) should say *why*. As of this writing, no ADRs have actually been written yet — `094_ARCHITECTURE_DECISION_RECORDS.md` only describes the format to use.

---

# A Note on Honesty

Every document in this section was written by directly reading the code, not by restating intentions from the rest of the Bible. Where implementation diverges from philosophy — a stub generation target, an unenforced auth check, an untested code path, a dead table — it's named explicitly rather than smoothed over. This is consistent with `093_ENGINEERING_PRINCIPLES.md`'s instruction that "if something is difficult to explain, it is probably difficult to maintain," and with the product's own value of intellectual honesty (`050_AI_PHILOSOPHY.md`: *"AI is comfortable saying 'I don't know.'"*). The same standard should apply to documentation about the system, not just the system's behavior toward users.

If you find something in this section that has since changed in the code, that's not a contradiction — it's a sign this section needs updating. Treat divergence between this section and the live code as more urgent to fix than divergence between this section and the philosophy documents.

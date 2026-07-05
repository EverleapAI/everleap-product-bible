# Data Model

## Purpose

The Everleap data model exists to represent a person's developmental journey.

Unlike traditional applications that primarily store transactions, Everleap stores observations, evidence, hypotheses, and growth over time.

The database is designed to answer one fundamental question:

> **"What have we learned about this person, and why do we believe it?"**

Every table should ultimately support answering that question.

---

# Philosophy

The data model separates four fundamentally different kinds of information.

1. Facts
2. Evidence
3. Knowledge
4. Experiences

Keeping these categories separate allows the product to evolve without losing trust.

---

# Layer 1 — Identity

Identity tables describe who the user is.

Examples include:

- User
- Authentication
- Profile
- Preferences
- Organization
- School
- Counselor relationships

Identity should remain independent from AI.

AI consumes identity.

It does not define it.

---

# Layer 2 — Evidence

Evidence is the foundation of the platform.

Examples include:

- onboarding responses
- Story answers
- Tiny Task answers
- completed Actions
- reflections
- future conversations
- behavioral events

Evidence is factual.

It contains no interpretation.

Evidence should be permanent whenever practical.

---

# Layer 3 — Scientific Knowledge

Scientific knowledge is generated from evidence.

Examples include:

- science memos
- hypotheses
- evidence links
- tensions
- missing information
- confidence
- future questions

Scientific knowledge is temporary.

It can always be regenerated.

---

# Layer 4 — User Experiences

Experiences are what the user sees.

Examples include:

- Today
- Summary
- Motivations
- Strengths
- Skills
- Explore
- Recommendations

These experiences are generated from scientific knowledge.

Not directly from evidence.

---

# Immutable vs Mutable Data

Everleap distinguishes between information that should never change and information that is expected to evolve.

## Immutable

Examples:

- original Story answers
- onboarding responses
- timestamps
- completed actions

These represent historical facts.

---

## Mutable

Examples:

- summaries
- recommendations
- Today guidance
- science memos

These represent current understanding.

As understanding improves, they should change.

---

# Relationships

The platform should preserve clear relationships.

```
User

↓

Evidence

↓

Science Memo

↓

Summary

↓

Today

↓

Action

↓

New Evidence
```

Every generated observation should ultimately trace back to evidence.

---

# Normalization

Evidence should exist only once.

Generated knowledge should reference evidence rather than duplicate it whenever practical.

Duplication creates inconsistency.

Relationships create explainability.

---

# Confidence

Confidence is stored alongside observations.

Confidence belongs to the observation.

Not the user.

Users are never "70% confident."

Hypotheses are.

---

# Versioning

Generated knowledge should preserve version information.

Examples include:

- prompt version
- generator version
- science version
- model version

This allows Everleap to:

- compare generations
- rebuild history
- debug regressions
- improve prompts

In the current implementation this is only partially realized. Versioning is informal: identifiers are carried as strings inside the JSON `source_snapshot` / payload of a generated row, not as first-class columns. Science memos in particular record no prompt or model version at all—their `source_snapshot` captures the trigger, an answer count, and a `generatedBy` label, but nothing that pins the exact prompt or model. First-class version columns remain aspirational.

---

# Regeneration

Generated tables should always be rebuildable.

If every generated record disappeared tomorrow...

the platform should rebuild itself from:

- users
- evidence
- science definitions
- prompts

Evidence is permanent.

Knowledge is reproducible.

To keep that rebuild cost-safe, a small infrastructure/cache table, `generation_input_hashes`, records one hash per `(user_id, cache_key)`—the hash of the inputs that produced each target's last output. A target whose inputs are unchanged is skipped rather than regenerated. This table holds no user-facing knowledge; it is disposable bookkeeping and can itself be dropped and rebuilt at the cost of one extra regeneration per target.

---

# Longitudinal Development

Growth is one of Everleap's greatest advantages.

The data model should preserve history rather than overwrite it.

Today it does not yet. The generated tables—`user_science_insights`, `user_page_guidance`, and `user_memory_profile`—upsert in place (`ON CONFLICT (user, key) DO UPDATE`). Each keeps a single latest row per `(user, key)`; regeneration overwrites the previous output and no prior-version rows are retained. The longitudinal history described below is therefore aspirational: the questions it wants to answer require history that is not currently being kept.

Questions the system should eventually answer include:

- How has motivation changed?

- Which strengths have become stronger?

- Which interests disappeared?

- What recommendations led to action?

- Which hypotheses proved incorrect?

Growth is impossible to measure without history.

---

# Explainability

Every important observation should answer:

What evidence created this?

Which science interpreted it?

Which generator produced it?

When was it generated?

What confidence supported it?

If the database cannot answer these questions, it is missing important relationships.

---

# Product Rules

The Everleap data model should always preserve:

Facts before interpretation.

Evidence before knowledge.

History before summaries.

Relationships before duplication.

Explainability before convenience.

The database is not merely a storage system.

It is the long-term memory that allows Everleap to grow alongside every user.
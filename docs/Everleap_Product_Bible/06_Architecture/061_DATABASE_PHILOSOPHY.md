# Database Philosophy

## Purpose

The Everleap database is far more than persistent storage.

It is the product's long-term memory.

Unlike a traditional AI chatbot, which forgets most conversations after they end, Everleap is designed to remember, organize, and build upon everything the user chooses to share over months and years.

The database allows the product to become progressively more personal without requiring the AI to remember anything.

Memory belongs in the database.

Reasoning belongs in AI.

---

# The Database Is The Source of Truth

Every important observation eventually lives in the database.

Not inside Claude.

Not inside GPT.

Not inside prompts.

Language models produce ideas.

The database preserves knowledge.

This distinction is one of the most important architectural decisions in Everleap.

---

# Raw Data vs Knowledge

The database stores two fundamentally different kinds of information.

## Raw Data

Raw data includes:

- onboarding answers
- Story responses
- completed actions
- reflections
- exploration history
- user preferences
- interaction history

Raw data represents facts.

It contains no interpretation.

---

## Generated Knowledge

Generated knowledge includes:

- science memos
- Today guidance
- Insights
- summaries
- recommendations
- future coaching observations

Generated knowledge represents hypotheses built from evidence.

Knowledge should always remain regeneratable.

---

# Never Throw Away Evidence

Evidence should almost never be deleted.

As users grow, older answers become valuable.

They allow Everleap to recognize:

- growth
- changing interests
- shifting motivations
- increasing confidence
- evolving identity

History is essential for understanding development.

---

# Generated Content Can Be Rebuilt

Unlike evidence, generated content is disposable.

If prompts improve...

If science evolves...

If a new AI model becomes available...

Every generated page should be rebuildable from stored evidence.

This allows the product to improve continuously without losing the user's history.

---

# AI Never Owns State

AI should never become the permanent owner of knowledge.

Instead:

Evidence

↓

Database

↓

AI

↓

Generated Knowledge

↓

Database

The AI always reads from and writes back to the database.

Nothing important should exist only inside an AI conversation.

---

# Structured Before Narrative

The database should prioritize structured knowledge over long paragraphs.

Examples include:

- hypotheses
- confidence
- evidence
- tensions
- questions
- recommendations

Narrative writing should be generated from structured knowledge rather than becoming the primary stored artifact.

Structure creates flexibility.

---

# Relationships Matter

Everleap is a connected system.

Everything should relate to something else.

Examples include:

Story Answers

↓

Science Memos

↓

Insights Summary

↓

Today Guidance

↓

Actions

↓

Future Story Answers

The database should preserve these relationships whenever possible.

Understanding improves when connections remain visible.

---

# Time Matters

Every important observation should include time.

People change.

Without timestamps, growth becomes invisible.

Whenever practical, records should preserve:

- created date
- updated date
- generation date
- confidence history
- evidence history

Time transforms snapshots into developmental journeys.

---

# Explainability

Every generated observation should be traceable.

The platform should always be able to answer:

- Which evidence produced this?
- Which generator created it?
- Which science contributed?
- Which model produced it?
- What confidence existed?

The database should support these questions naturally.

---

# Regeneration

One of the guiding principles of Everleap is regeneration.

If every generated table were deleted tomorrow...

The platform should be able to rebuild itself from:

- evidence
- prompts
- science definitions

This makes continuous improvement possible.

---

# Performance

Pages should never perform expensive reasoning.

Instead:

Read.

Render.

Respond.

All heavy computation should already have happened.

Fast products feel intelligent.

Waiting for AI does not.

---

# Evolution

The schema should evolve with the product.

New sciences.

New agents.

New recommendation engines.

New pages.

New observations.

The database should support growth without requiring major redesigns.

---

# Product Rules

The database should always preserve:

Facts before interpretations.

Evidence before conclusions.

History before summaries.

Structure before narrative.

Relationships before duplication.

Memory before convenience.

The database is not simply where Everleap stores information.

It is where Everleap remembers.
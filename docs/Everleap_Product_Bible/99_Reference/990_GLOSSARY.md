# Everleap Glossary

## Purpose

Language matters.

Everleap uses many terms that have specific meanings within the product.

This glossary defines those terms so that engineers, designers, prompt authors, and AI systems all use them consistently.

Whenever a term has a specific meaning in Everleap, this glossary is the source of truth.

---

# Action

A small, intentional activity recommended to the user.

Actions exist to create new evidence.

Actions are experiments.

Not assignments.

---

# Action Suggestion

A candidate action generated alongside guidance — a *suggestion*, not yet a
committed Action.

Suggestions generate non-blocking, off the page's critical path, so they never
slow a load.

A suggestion becomes an Action only when the user takes it up.

---

# Agent

An AI system responsible for a specific responsibility.

Examples include:

- Today Coach
- Recommendation Agent
- Summary Generator

Agents consume structured knowledge.

They do not create scientific understanding.

---

# AI

The reasoning engine used to interpret evidence.

AI never owns memory.

AI consumes structured data and produces structured outputs.

---

# Confidence

A measure of how much evidence supports a hypothesis.

Confidence is **not** a measure of truth.

---

# Cost Source Tag

A label recorded on every AI call marking *what kind of work* spent the tokens.

The tags are:

- `generation` — real user-facing generation.
- `ai_lab` — the internal AI Lab tool.
- `prompt_lab_preview` — Prompt Lab live previews.

The spend dashboard rolls these into three buckets — **app**, **ai_lab**,
**prompt_lab** — so internal tooling spend stays separable from real user spend.

---

# Cross-Science Synthesis

The process of combining multiple independent science memos into one coherent understanding.

Examples include:

- Insights Summary
- Today
- Recommendations

---

# De-amplification

Ensuring an expensive shared step runs at most once per generation bundle,
instead of once per dependent that needs it.

Concretely: a science memo is computed once on a real input change; every later
target in the same bundle that re-enters that science gets an input-hash cache
hit instead of a repeat AI call.

De-amplification is what keeps broad regeneration cost-safe.

---

# Evidence

Facts collected from user behavior.

Examples include:

- Story answers
- onboarding responses
- completed actions
- reflections
- interactions

Evidence contains no interpretation.

---

# Experience

Any user-facing page or interaction.

Examples include:

- Today
- Story
- Explore
- Insights

Experiences consume knowledge.

---

# Generation

The background process that converts evidence into knowledge.

Generation is asynchronous.

Pages never perform generation.

---

# Generation Bundle

A set of generation targets run together from one trigger (e.g. a Today refresh,
or a whole-account rebuild).

Targets in a bundle share dependencies — most notably the sciences — which run
once for the bundle rather than once per target.

Bundles are where De-amplification and Input-Hash Caching pay off.

---

# Generation Request

A record describing work that needs to happen.

It does not contain AI output.

It schedules AI work.

---

# Guidance

User-facing coaching generated from structured knowledge.

Guidance should always be evidence-based.

---

# Hypothesis

A possible explanation supported by evidence.

Hypotheses are never facts.

They remain open to revision.

---

# Input-Hash Caching

Skipping an AI generation when its inputs have not changed.

Each target hashes its real inputs; if the hash matches the last stored one
(`generation_input_hashes` table), the model call is skipped and the existing
output is reused — a $0 no-op.

The cache is fail-open: any lookup fault regenerates rather than serving stale
content.

Some targets opt out by design — Today, for instance, always regenerates fresh.

---

# Insight

A meaningful understanding created by synthesizing multiple observations.

Insights should always remain explainable.

---

# Knowledge

Generated understanding stored in the database.

Examples include:

- science memos
- Today
- recommendations
- summaries

Knowledge is regenerated from evidence.

---

# Longitudinal

Information collected across time.

Longitudinal evidence allows Everleap to recognize growth.

---

# Memo

A structured output produced by one science.

Memos are internal.

Users never read them directly.

---

# Model

A language model such as Claude, GPT, or Gemini.

Models are replaceable.

Product philosophy is not.

---

# Observation

Something directly supported by evidence.

Observations should remain separate from interpretations.

---

# Page Contract

The formal definition of a page's responsibility.

Every page should answer exactly one primary question.

---

# Pattern

A recurring observation supported by multiple pieces of evidence.

Patterns are stronger than isolated observations.

---

# Prompt

Instructions that define how AI should perform one responsibility.

Prompts should describe reasoning, not merely wording.

---

# Prompt Lab

A passcode-gated internal tool for previewing a prompt change live.

It layers a word-count / tone / note override on top of the *real* generator's
prompt for one field and returns the result against real data.

Previews are never persisted, and their cost is tagged `prompt_lab_preview` (see
Cost Source Tag) so it stays separable from user spend.

---

# Recommendation

A suggested opportunity for exploration.

Recommendations are invitations.

Never predictions.

---

# Reflection

A user's thoughts about an observation, action, or experience.

Reflections create new evidence.

---

# Science

An independent reasoning framework.

Examples include:

- Ikigai
- Enneagram
- WCIYP
- SDT

Each science answers one question.

---

# Science Memo

The structured output of one science.

Science memos are internal knowledge.

They feed synthesis.

---

# Story

Everleap's evidence collection experience.

Story asks questions.

It does not generate insights.

---

# Synthesis

The process of combining multiple science memos into one coherent understanding.

---

# Today

Everleap's daily coaching experience.

Today focuses on one meaningful step forward.

---

# Transferable Skill

A capability that applies across many environments.

Examples include:

- communication
- organization
- leadership
- analysis
- teaching

---

# User Evidence

Everything the user intentionally contributes to the platform.

Evidence is the foundation of every future insight.

---

# User Journey

The complete developmental path a user follows through Everleap over months and years.

---

# Version

A specific revision of:

- prompts
- generators
- sciences
- pages
- outputs

Versioning supports regeneration and explainability.

---

# Working Memory

Temporary context used during AI generation.

Working memory is disposable.

Permanent memory belongs in the database.

---

# Source of Truth

The authoritative location for information.

Within Everleap:

The database is the source of truth.

Never the language model.

---

# Final Principle

When introducing new terminology:

1. Add it here.
2. Define it clearly.
3. Use it consistently everywhere else.

Shared language creates shared understanding.

Shared understanding creates better software.
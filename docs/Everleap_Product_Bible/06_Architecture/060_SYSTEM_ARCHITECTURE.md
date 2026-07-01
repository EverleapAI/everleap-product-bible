# System Architecture

## Purpose

The Everleap architecture exists to separate thinking from presentation.

The product should never generate intelligence while rendering a page.

Instead, intelligence is created in the background, stored as structured knowledge, and served instantly when needed.

This architecture makes the platform:

- faster
- more reliable
- easier to explain
- easier to debug
- easier to scale
- independent of any specific AI model

The architecture is designed around one central principle:

> **Pages consume knowledge. They never create it.**

---

# Core Philosophy

Everleap is not a chatbot.

It is an intelligent platform.

Most AI products ask a language model to answer a question every time a user opens a page.

Everleap intentionally does the opposite.

Instead:

User behavior creates evidence.

Evidence creates knowledge.

Knowledge is stored.

Pages simply present that knowledge.

This separation creates a much more stable product.

---

# The Four Layers

The entire platform can be understood as four independent layers.

```
Experience Layer

↓

Knowledge Layer

↓

Science Layer

↓

Evidence Layer
```

Each layer has one responsibility.

---

# Layer 1 — Evidence

Evidence is the foundation of the platform.

Evidence includes:

- onboarding answers
- Story responses
- completed Tiny Tasks
- completed Actions
- reflections
- future interactions
- longitudinal behavior

Evidence is always factual.

It contains no interpretation.

Evidence should never attempt to explain itself.

---

# Layer 2 — Science

The science layer transforms evidence into structured observations.

Each science operates independently.

Examples include:

- Ikigai
- Enneagram
- WCIYP
- SDT
- Big Five
- Narrative Identity
- Possible Selves

Each science answers exactly one question.

Each produces a science memo.

Science memos remain internal.

---

# Layer 3 — Knowledge

Knowledge combines multiple sciences.

Examples include:

- Today Guidance
- Insights Summary
- Recommendations
- Explore
- Future coaching agents

Knowledge generators consume science memos.

They do not consume raw Story answers.

This creates consistency across the product.

---

# Layer 4 — Experience

The Experience Layer contains every user-facing page.

Examples include:

- Today
- Story
- Insights
- Explore
- Recommendations

Pages never perform reasoning.

Pages simply display structured knowledge that already exists.

---

# Background Intelligence

All intelligence is generated asynchronously.

The flow is:

```
Evidence

↓

Generation Request

↓

Background Worker

↓

Science Memo

↓

Knowledge Generation

↓

Database

↓

User Interface
```

This architecture keeps user interactions fast while allowing AI to perform deeper reasoning.

---

# Source of Truth

The database is the source of truth.

Not Claude.

Not GPT.

Not any future AI model.

Language models generate observations.

The database stores observations.

Pages consume observations.

This allows the product to remain stable regardless of which model generates the content.

---

# Stateless AI

Every generator should behave as though it has no memory.

All required context should come from structured inputs.

Nothing important should exist only inside an AI conversation.

This makes every generation:

- reproducible
- explainable
- testable
- replaceable

---

# Loose Coupling

Major systems should know as little about one another as possible.

For example:

Story should not know how Today works.

Today should not know how Ikigai works.

Recommendations should not know how Story collects evidence.

Each layer communicates through structured data.

Not implementation details.

---

# Extensibility

The architecture should make future growth simple.

Examples include:

adding a new science

↓

register science

↓

generate memo

↓

include in synthesis

↓

done

The rest of the platform should require little or no modification.

Good architecture reduces the cost of future ideas.

---

# Explainability

Every user-facing observation should be traceable.

The platform should always be able to answer:

- What evidence created this?
- Which science contributed?
- Which generator produced it?
- When was it generated?
- What confidence supported it?

Explainability is not optional.

It is one of Everleap's core product values.

---

# Fault Tolerance

Failures should remain isolated.

If one science fails:

other sciences continue.

Existing guidance remains available.

The user experience should degrade gracefully.

No single generator should make the product unusable.

---

# Scalability

The architecture should support:

- millions of users
- many sciences
- multiple AI providers
- multiple agents
- additional products
- future platforms

Scaling should involve adding generators.

Not redesigning the architecture.

---

# Guiding Principles

Every architectural decision should support these principles:

- Evidence before interpretation.
- Science before synthesis.
- Background generation before presentation.
- Database before language model.
- Structured knowledge before narrative.
- Explainability before cleverness.
- Reliability before novelty.

Architecture exists to make the philosophy of Everleap sustainable.

If the architecture ever begins fighting the philosophy, the architecture should change.
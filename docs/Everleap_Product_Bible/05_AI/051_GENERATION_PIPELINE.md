# Generation Pipeline

## Purpose

Everleap is built around an asynchronous AI generation pipeline.

Unlike many AI applications, product pages never call a language model directly.

Instead, user interactions create evidence.

Evidence triggers background generation.

Generated knowledge is stored in the database.

Pages simply read the latest available guidance.

This architecture makes the product faster, more reliable, more explainable, and significantly easier to evolve.

---

# Core Philosophy

The user interface should never wait for AI.

AI is expensive.

AI is unpredictable.

AI occasionally fails.

None of those realities should negatively affect the user experience.

The product should always remain responsive.

Generation happens behind the scenes.

Reading is immediate.

---

# The Generation Cycle

Every generation follows the same lifecycle.

```
User Interaction

↓

Evidence Changes

↓

Generation Request Created

↓

Background Worker Claims Request

↓

AI Generates New Knowledge

↓

Knowledge Saved

↓

Pages Read Updated Data
```

No page generates content directly.

Pages consume previously generated knowledge.

---

# Step 1 — User Creates Evidence

Evidence can come from many sources.

Examples include:

- Completing onboarding
- Answering Story questions
- Completing Tiny Tasks
- Finishing actions
- Exploring recommendations
- Future product interactions

Evidence is always the starting point.

Nothing is generated without evidence.

---

# Step 2 — Generation Request

Whenever important evidence changes, Everleap creates one or more generation requests.

Generation requests describe:

- who needs generation
- what should be rebuilt
- why it changed
- when it was requested
- execution priority

Generation requests never contain generated content.

They simply describe work that needs to happen.

---

# Step 3 — Background Processing

Background workers continuously process pending requests.

Each worker:

1. Claims a request.
2. Executes required dependencies.
3. Generates updated knowledge.
4. Saves results.
5. Marks the request complete.

This allows the platform to scale horizontally without changing application behavior.

---

# Step 4 — Science Generation

Science generation is always the first layer.

Each science independently analyzes the available evidence.

Examples include:

- Ikigai
- Enneagram
- WCIYP
- Future sciences

Each produces an internal science memo.

Science memos are never shown directly to users.

They become structured inputs for later generations.

---

# Step 5 — Cross-Science Generation

Once all required sciences are complete, higher-level generators begin.

Examples include:

- Today
- Insights Summary
- Recommendations
- Explore
- Future coaching agents

These generators synthesize multiple sciences into user-facing experiences.

No page should bypass the science layer.

---

# Dependency Graph

Generation targets declare their dependencies.

For example:

```
Today

depends on

Ikigai
Enneagram
WCIYP
```

The dispatcher resolves dependencies automatically.

This allows new sciences to be added without rewriting page generators.

---

# Why Dependencies Matter

Dependencies guarantee that pages always use the latest scientific understanding.

For example:

Story Answer

↓

Ikigai Memo

↓

Summary

↓

Today

Each layer builds on the previous one.

This creates consistency throughout the product.

---

# Reading vs Generation

Generation and reading are intentionally separated.

Generation writes.

Pages read.

Pages never regenerate content.

This separation produces:

- consistent experiences
- faster interfaces
- easier debugging
- lower AI costs
- predictable behavior

---

# Database as the Source of Truth

The database stores generated knowledge.

Examples include:

- science memos
- page guidance
- summaries
- recommendations
- future coaching state

Claude (or any future model) is not the source of truth.

The database is.

AI creates knowledge.

The database remembers it.

---

# Idempotency

Generation should always be repeatable.

Running the same generation twice with identical evidence should produce functionally equivalent results.

Generators should avoid hidden state.

Evidence should determine outputs.

---

# Explainability

Every generated observation should be traceable.

The platform should always be able to answer:

- What evidence caused this?
- Which science generated it?
- Which model generated it?
- When was it generated?
- What confidence supported it?

Explainability is essential for trust.

---

# Failure Handling

Generation failures should never interrupt the user experience.

If generation fails:

- existing guidance remains available
- failed requests are recorded
- retries may occur
- users continue using the product

Graceful degradation is preferable to unavailable pages.

---

# Scalability

The pipeline is designed to grow.

New sciences.

New agents.

New recommendation engines.

New pages.

New models.

All should plug into the existing generation framework without changing page behavior.

Adding intelligence should require adding generators—not redesigning the architecture.

---

# AI Independence

Everleap should never depend on a specific language model.

Today the product may use Claude.

Tomorrow it may use GPT.

Future systems may combine multiple models.

The generation pipeline should remain unchanged.

Only individual generators should care which model performs the work.

---

# Product Rules

Every generation should satisfy these principles:

- Evidence always comes first.
- Generation always happens in the background.
- Pages never call AI directly.
- Science always precedes synthesis.
- Generated knowledge is stored permanently.
- Every observation is explainable.
- Every generation is repeatable.
- Users should never wait for AI.

The generation pipeline is the nervous system of Everleap.

Everything the user experiences begins here.
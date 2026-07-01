# Prompt Design

## Purpose

Prompts are one of the most important pieces of intellectual property within Everleap.

A prompt is not simply instructions for a language model.

It is the translation of Everleap's philosophy into behavior.

Every prompt should produce outputs that remain consistent with the product, regardless of which language model executes it.

The goal is not to write prompts that sound intelligent.

The goal is to build prompts that consistently produce trustworthy observations.

---

# Philosophy

Prompts should tell the AI **how to think**, not **what to say**.

Good prompts define:

- purpose
- responsibilities
- constraints
- evidence
- reasoning
- output structure

Bad prompts focus primarily on wording.

The thinking matters far more than the phrasing.

---

# Every Prompt Has One Job

Each prompt should have a single responsibility.

Examples include:

- analyze motivations
- recognize transferable skills
- generate Today's guidance
- synthesize science memos
- generate recommendations

Avoid prompts that attempt to perform multiple unrelated tasks.

Simple prompts produce better systems.

---

# Internal vs User-Facing Prompts

Everleap uses two fundamentally different kinds of prompts.

## Internal Prompts

Internal prompts generate structured knowledge.

Examples include:

- science memos
- confidence estimates
- hypotheses
- evidence
- tensions
- missing information

Internal prompts should produce JSON whenever possible.

They are written for other software.

Not users.

---

## User-Facing Prompts

User-facing prompts generate experiences.

Examples include:

- Today
- Insights Summary
- Motivations
- Strengths
- Skills
- Recommendations

These prompts consume structured knowledge that already exists.

They should never reinterpret raw Story answers directly.

---

# Evidence Always Comes First

Prompts should begin from evidence.

Every observation should be traceable.

The AI should never invent supporting evidence after reaching a conclusion.

The thinking process should always follow:

Evidence

↓

Patterns

↓

Hypotheses

↓

Reflection

↓

Guidance

Never the reverse.

---

# Hypotheses, Not Conclusions

Prompts should instruct the AI to generate hypotheses.

Not declarations.

Preferred language includes:

- appears to
- may indicate
- one possibility
- emerging pattern
- evidence suggests

Avoid:

- you are
- definitely
- proves
- always
- never

Humility should be designed into every prompt.

---

# JSON First

Whenever prompts generate internal knowledge, outputs should be structured.

Examples include:

- confidence
- hypotheses
- evidence
- tensions
- questions
- recommendations

Structured outputs are:

- easier to validate
- easier to debug
- easier to combine
- easier to evolve

Narrative writing should happen later.

---

# Prompt Independence

Prompts should avoid depending on other prompts.

Instead they should depend on structured data.

Example:

Good:

Science Memo

↓

Summary Prompt

Bad:

Ikigai Prompt

↓

Summary Prompt

↓

Today Prompt

↓

Recommendations Prompt

Each prompt should consume data.

Not language.

---

# Model Independence

Prompts should avoid model-specific tricks.

Everleap should be able to move between:

- Claude
- GPT
- Gemini
- future models

without redesigning product behavior.

Prompt quality should come from clarity.

Not model quirks.

---

# Prompt Contracts

Every prompt should clearly define:

## Purpose

What is this prompt trying to accomplish?

---

## Inputs

What structured data is available?

---

## Responsibilities

What decisions is the AI allowed to make?

---

## Constraints

What is the AI forbidden from doing?

---

## Output Format

Exactly what should be returned?

Every prompt should have an explicit contract.

---

# Hallucination Prevention

Prompts should explicitly instruct the AI to:

- avoid inventing facts
- avoid unsupported conclusions
- acknowledge uncertainty
- preserve competing explanations
- stay grounded in evidence

Whenever evidence is weak, the prompt should encourage better questions rather than stronger conclusions.

---

# Reusable Thinking

Prompt engineering should focus on reusable reasoning.

For example:

A science prompt should still make sense years from now even if every Story question changes.

Good prompts are resilient.

Poor prompts become obsolete whenever data changes.

---

# Versioning

Every production prompt should have:

- version
- owner
- purpose
- change history
- expected inputs
- expected outputs

Prompt changes should be treated with the same discipline as source code.

---

# Measuring Prompt Quality

A good prompt produces outputs that are:

- accurate
- evidence-based
- explainable
- repeatable
- consistent
- useful

The goal is not creativity.

The goal is reliable reasoning.

---

# Product Rules

Every Everleap prompt should answer:

1. What is my job?
2. What evidence may I use?
3. What decisions am I allowed to make?
4. What must I never do?
5. What output am I expected to produce?

If a prompt cannot answer those five questions clearly, it is not ready for production.

Prompts are not merely instructions for AI.

They are executable expressions of Everleap's philosophy.
# Science Memos

## Purpose

Science Memos are the foundation of Everleap's intelligence.

Every science observes the user's evidence independently and produces its own structured understanding.

These observations are stored as Science Memos.

Science Memos are **never shown directly to users.**

They exist so that higher-level AI systems can reason from structured scientific observations instead of repeatedly interpreting raw Story answers.

Science Memos separate scientific reasoning from user-facing experiences.

---

# Philosophy

Each science should think independently.

Ikigai should not know what Enneagram concluded.

Enneagram should not know what WCIYP concluded.

Every science examines the same evidence through its own theoretical framework.

Only later does Everleap combine those perspectives.

This independence reduces confirmation bias and creates stronger synthesis.

---

# Why Science Memos Exist

Without Science Memos:

Every page would need to analyze Story answers independently.

That would lead to:

- duplicated reasoning
- inconsistent observations
- higher AI costs
- conflicting explanations
- difficult debugging

Science Memos solve this problem.

Each science performs its reasoning once.

Every page reuses that knowledge.

---

# One Science, One Memo

Each science has one responsibility.

Three sciences are currently implemented:

Ikigai

↓

Motivational hypotheses

(code identity `Ikigai/Motivations`, target `science:ikigai`)

Enneagram

↓

Behavioral and motivational patterns

(code identity `Enneagram/Strengths`, target `science:enneagram`)

What Color Is Your Parachute

↓

Transferable capabilities

(code identity `Parachute/Skills`, target `science:parachute`—"WCIYP" is a human abbreviation, not a code identifier)

The following sciences are planned but **not yet implemented**. They are part of the intended framework, not live generators:

SDT

↓

Motivational environments

Big Five

↓

Behavioral tendencies

Narrative Identity

↓

Personal meaning-making

Possible Selves

↓

Future developmental possibilities

Each memo answers one scientific question exceptionally well.

---

# Science Memos Are Internal

Users never read Science Memos.

Instead they read pages generated from them.

Examples include:

Science Memo

↓

Insights Summary

↓

Today

↓

Recommendations

↓

Explore

The memo is internal knowledge.

The pages are the user experience.

---

# Memo Structure

Every Science Memo should follow a consistent structure.

Typical fields include:

- science
- confidence
- hypotheses
- supporting evidence
- tensions
- missing information
- questions to reduce uncertainty
- an optional `observations` array
- source metadata

Individual sciences may extend the structure.

The overall shape should remain consistent.

Note that not every field has its own database column. `user_science_insights` gives dedicated columns to confidence, hypotheses, missing information, questions, and evidence, but `tensions` (and the `observations` array, when present) live inside the `source_snapshot` JSON rather than in dedicated columns.

---

# Hypotheses

Every memo produces hypotheses.

A hypothesis is:

A scientifically informed possibility supported by evidence.

It is not:

- a conclusion
- a diagnosis
- a label
- a prediction

Hypotheses should remain open to revision.

---

# Evidence

Every hypothesis should be supported.

Evidence may include:

- Story responses
- completed actions
- reflections
- repeated behaviors
- historical consistency

Evidence should be traceable.

Future generators should always understand why a hypothesis exists.

---

# Tensions

Good science recognizes competing explanations.

Science Memos should intentionally preserve tensions.

Examples:

- enjoys leadership
- values collaboration

Both may be true.

Or one may explain the other.

Tensions create better future questions.

They should never be discarded simply to produce cleaner narratives.

---

# Missing Information

Science should know what it does not know.

Every memo should identify:

- unanswered questions
- missing evidence
- observations requiring additional exploration

This allows Everleap to intelligently guide future Story questions and coaching conversations.

---

# Questions to Reduce Uncertainty

One of the most valuable outputs of a Science Memo is identifying the next best question.

Examples include:

- What environments consistently energize this user?
- Has this pattern existed for years or only recently?
- Does this strength appear outside of school?
- Is this motivation stable under pressure?

These questions improve future generations.

---

# Confidence

Confidence exists at two levels.

Each hypothesis carries its own confidence, and different hypotheses within the same science may have very different confidence levels.

The memo also carries a single memo-level confidence, expressing how strongly the science as a whole is supported. It is persisted to the `confidence` column on `user_science_insights`, alongside—not instead of—the per-hypothesis values.

Confidence should always reflect:

- evidence quantity
- evidence quality
- consistency
- longitudinal stability
- competing explanations

---

# Independence

Science Memos should never reference each other directly.

Ikigai should not say:

"Enneagram agrees."

That comparison belongs to synthesis.

Keeping sciences independent produces stronger cross-science reasoning later.

---

# Regeneration

Science Memos should always be disposable.

If prompts improve...

If science evolves...

If a better model becomes available...

Every memo should be regenerated from evidence.

Evidence is permanent.

Memos are temporary.

Regeneration is disposable but not wasteful. Each science is guarded by an input-hash cache keyed `science:<key>`: the hash covers only that science's own answered Story questions. When those answers are unchanged, the memo is not regenerated—the existing row is left in place and the model is never called.

This also de-amplifies the science layer within a bundle. Events enqueue bundles of targets, several of which depend on the same science. The first dependent to reach a changed science pays to regenerate it; every later dependent in that bundle hits the cache instead. Each science therefore runs at most once per bundle, not once per dependent.

---

# Explainability

Every memo should answer:

- What evidence produced this?
- Which hypothesis was generated?
- Why is confidence at this level?
- What questions remain unanswered?

If another engineer cannot understand why a memo exists, it is not complete.

---

# Relationship to Cross-Science Synthesis

Science Memos are intentionally incomplete.

No memo attempts to explain the entire person.

Their purpose is to provide specialized observations.

Later generators combine those observations into:

- Insights Summary
- Today
- Recommendations
- Explore
- Future coaching agents

Science Memos are the building blocks.

Synthesis creates the user experience.

---

# Product Rules

Every Science Memo should:

- answer one scientific question
- remain independent
- preserve uncertainty
- explain confidence
- identify tensions
- recommend future questions
- remain fully regeneratable

Science Memos are the intellectual foundation of Everleap.

Everything the user experiences ultimately begins here.
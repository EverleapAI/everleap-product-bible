# Page Contracts

## Purpose

Every page in Everleap is a contract.

A page should have one clearly defined responsibility.

It should know:

- what it owns
- what it consumes
- what it produces
- what it never does

The purpose of a Page Contract is to prevent pages from slowly accumulating responsibilities until they become difficult to understand, maintain, or improve.

Whenever a page begins violating its contract, it should be redesigned rather than expanded.

---

# Why Contracts Matter

One of the easiest ways for software to become difficult to maintain is for pages to gradually absorb responsibilities that belong elsewhere.

For example:

A page that starts by displaying guidance eventually begins generating guidance.

Then interpreting evidence.

Then querying AI.

Then saving preferences.

Eventually no one knows where anything belongs.

Page Contracts exist to prevent this.

---

# The Single Responsibility Principle

Every page should answer one question.

Examples include:

| Page | Primary Question |
|-------|------------------|
| Today | What should I focus on today? |
| Story | What evidence helps us understand you better? |
| Summary | What is the most important pattern emerging? |
| Motivations | Why do certain experiences matter to you? |
| Strengths | How do you naturally approach the world? |
| Skills | What capabilities repeatedly appear? |
| Explore | What possibilities are worth exploring? |
| Recommendations | What should you try next? |

If a page attempts to answer multiple unrelated questions, it has become too large.

---

# Every Page Consumes

Pages consume structured knowledge.

Never raw AI.

Examples include:

- science memos
- summaries
- recommendations
- Today guidance
- confidence
- evidence references

Pages should never consume raw Story answers unless Story itself owns those answers.

---

# Every Page Produces

Pages produce only user interactions.

Examples include:

- answering Story questions
- completing Tiny Tasks
- saving reflections
- exploring recommendations
- completing Actions

These interactions create evidence.

Evidence creates future generations.

Pages themselves do not generate intelligence.

---

# Pages Never Call AI

This is one of the most important architectural rules.

Pages should never call Claude.

Pages should never call GPT.

Pages should never generate observations.

Instead:

Page

↓

API

↓

Database

↓

Display

AI generation always happens elsewhere.

---

# Page Responsibilities

A page is responsible for:

- presenting information
- collecting user interaction
- creating evidence
- triggering background generation when necessary

A page is **not** responsible for:

- interpreting evidence
- generating hypotheses
- combining sciences
- writing summaries

Those belong to generators.

---

# Page Independence

Pages should know as little about each other as possible.

For example:

Today should not understand Story.

Story should not understand Recommendations.

Recommendations should not understand Science generation.

Every page communicates through shared knowledge rather than direct dependencies.

---

# Consistency

Every page should follow the same pattern.

```
Read

↓

Display

↓

Interact

↓

Save

↓

Queue Generation

↓

Done
```

The page's work ends after saving evidence.

Everything else happens asynchronously.

---

# Explainability

Every important statement shown on a page should be explainable.

If a user asks:

"Why am I seeing this?"

The platform should be able to trace the answer back through:

- page
- generator
- science memo
- evidence

Explainability should exist by design.

---

# Failure

If background generation fails:

Pages should continue displaying the most recent successful generation.

Users should never see broken pages simply because AI failed.

Graceful degradation is always preferable to unavailable experiences.

---

# Future Pages

Every new page added to Everleap should begin by defining its contract.

Specifically:

- What question does this page answer?
- What structured knowledge does it consume?
- What user interactions does it collect?
- What evidence does it create?
- What generation requests can it trigger?
- What is explicitly outside its responsibility?

Only after those questions are answered should implementation begin.

---

# Product Rules

Every page should satisfy these principles:

- One page.
- One question.
- One responsibility.

Pages display knowledge.

They collect evidence.

They trigger learning.

They never perform the learning themselves.

A page contract is successful when another engineer can completely understand the page's purpose before reading a single line of code.
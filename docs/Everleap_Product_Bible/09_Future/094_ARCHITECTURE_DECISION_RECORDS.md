# Architecture Decision Records (ADRs)

## Purpose

Every significant architectural decision made within Everleap should be documented.

Not because we expect every decision to be permanent.

But because future engineers deserve to understand **why** a decision was made.

Code explains *what*.

Architecture Decision Records explain *why*.

Without that context, future engineers often repeat old debates or unintentionally reverse important decisions.

---

# Philosophy

Software evolves.

Requirements change.

Technology improves.

Good architectural decisions are often temporary.

That is acceptable.

What matters is that every important decision was rational when it was made.

ADRs preserve that reasoning.

---

# When To Create An ADR

Create an ADR whenever a decision will significantly affect the product.

Examples include:

- choosing a database
- changing AI providers
- introducing a new architecture
- modifying the generation pipeline
- introducing a new science
- changing authentication
- redesigning data flow
- changing deployment strategy
- introducing a new storage model

Small implementation choices do not require ADRs.

Product-defining decisions do.

---

# What An ADR Contains

Every ADR should answer the same questions.

## Context

What problem existed?

Why was a decision needed?

---

## Decision

What was decided?

Describe the decision clearly.

---

## Alternatives Considered

What other options were evaluated?

Why were they rejected?

Documenting alternatives prevents future teams from repeating the same analysis.

---

## Consequences

Every decision has tradeoffs.

Document both:

Benefits

and

Costs.

No decision is free.

---

## Status

Possible values include:

- Proposed
- Accepted
- Superseded
- Deprecated

Architecture evolves.

The history should remain visible.

---

# Example

```
ADR-0007

Title

Background AI Generation

Status

Accepted

Context

Pages calling AI directly caused
slow interfaces and inconsistent
experiences.

Decision

Move all AI generation into
background workers.

Consequences

+ Faster UI
+ Lower AI costs
+ Better caching
+ Easier debugging

- Increased architectural complexity
- Eventual consistency
```

Future engineers should immediately understand why the system behaves this way.

---

# Recorded Decisions

The entries below are real, shipped decisions, written in the ADR block format
above.

```
ADR-0008

Title

Input-Hash Generation Cache + Science De-amplification

Status

Accepted

Author / Date / Reviewers

Founder · 2026-07-05 · self-reviewed

Context

Broad regeneration (a whole-account rebuild,
or any bundle that fans out to many
targets) re-ran every AI call even when
nothing relevant had changed. Two costs:
redundant model spend, and science memos
paying multiple times because several
dependents each pulled the same science.

Decision

Add a per-target input-hash cache
(generation_input_hashes table,
lib/generation/generationCache.ts). Each
target computes stableHash() over its real
inputs; isGenerationFresh() short-circuits
the model call on an unchanged hash and
reuses the stored output;
recordGenerationHash() upserts after a real
generation. Sciences are de-amplified two
ways: a shared `seen` set runs each science
at most once per bundle, and the per-science
input-hash cache means only the first
dependent hitting a changed science pays for
it. page:today is intentionally left off the
cache (guidanceToday.ts never calls it) so
the daily card always regenerates fresh.

Alternatives Considered

- Time-based TTL cache — rejected: unchanged
  inputs would still regenerate on expiry,
  and changed inputs would serve stale until
  it lapsed. Input-hash is exact.
- Global run-level dedupe only (the `seen`
  set) — insufficient across separate
  triggers/bundles; the persisted hash is
  what makes repeat triggers a no-op.

Consequences

+ Unchanged tabs cost $0 (one indexed read)
+ Whole-account regeneration is cost-safe
+ Sciences fire at most once per bundle
+ Fail-open: a cache fault regenerates
  rather than serving stale content

- One more table + hash bookkeeping per target
- "Cached vs uncached" is per-generator
  convention (presence of the cache calls),
  not a central registry — easy to miss when
  adding a target
```

---

```
ADR-0009

Title

Prompt Lab Preview Tooling

Status

Accepted

Author / Date / Reviewers

Founder · 2026-07-05 · self-reviewed

Context

Tuning a user-facing prompt meant editing
code and regenerating to see the effect.
There was no safe way to preview a wording,
word-count, or tone change against the real
prompt on real data.

Decision

Add Prompt Lab: a passcode-gated internal
tool (functions/promptLab/promptLabPreview.ts)
that layers a PromptLabOverride
(buildOverrideBlock.ts) on top of the real
generator's prompt for one target field and
returns the result live. Access requires an
unlock cookie validated against
prompt_lab_unlocks (requirePromptLabUnlock,
403 when locked/expired) and is rate-limited.
Previews are never persisted.

Alternatives Considered

- A separate mock prompt playground —
  rejected: it would drift from the real
  prompts and give false confidence.
- Toggling overrides in production config —
  rejected: risky, and not per-field or
  ephemeral.

Consequences

+ Real prompt, real data, instant feedback
+ Passcode-gated + rate-limited; ephemeral
+ Overrides ride on the real generator, so
  what you preview is what ships

- Another surface to secure
- Preview generations do cost tokens (see
  ADR-0010 for how that spend is isolated)
```

---

```
ADR-0010

Title

AI-Spend Source Tagging

Status

Accepted

Author / Date / Reviewers

Founder · 2026-07-05 · self-reviewed

Context

Internal tooling (AI Lab, Prompt Lab
previews) calls the same model as
user-facing generation. Preview calls were
recording no usage, making internal spend
invisible and impossible to separate from
real user spend on the cost dashboard.

Decision

Every AI call carries an AiUsageTrack whose
`source` recordAiUsage writes to
ai_usage_audit. Real generation tags
"generation" (the runAnthropic default);
AI Lab tags "ai_lab"; Prompt Lab previews
tag "prompt_lab_preview". usageSummary rolls
these into three buckets — app, ai_lab,
prompt_lab — so internal-tool spend is
separable from real user spend.

Alternatives Considered

- Infer tool vs user spend from feature name
  — brittle; features overlap tools.
- A strict TypeScript union for `source` —
  not adopted; `source` is a free-form string
  enforced by call-site convention, so a new
  tag needs no type change (at the cost of no
  compile-time guarantee).

Consequences

+ Internal spend is visible and isolable
+ Preview/lab cost is counted, not hidden
+ New sources need no schema/type change

- The taxonomy is convention, not enforced;
  a mistyped source silently rolls into "app"
```

---

# Everleap ADR Principles

Architecture decisions should support the Product Manifesto.

Specifically:

- Evidence before interpretation.
- Background generation before presentation.
- Science before synthesis.
- Database before AI.
- Explainability before cleverness.
- Trust before convenience.

Any decision that weakens those principles deserves extra scrutiny.

---

# Reversibility

Prefer reversible decisions whenever practical.

Ask:

"If this turns out to be wrong, how difficult will it be to change?"

The easier a decision is to reverse, the less risk it carries.

Irreversible decisions require stronger evidence.

---

# Product Decisions Are Architecture Decisions

At Everleap, product and architecture are tightly connected.

Changing:

- Today
- Story
- Science generation
- Recommendations
- AI orchestration

often affects architecture.

Likewise,

architectural changes often affect product behavior.

Both deserve documentation.

---

# Decision Ownership

Every ADR should include:

- author
- date
- status
- reviewers

Decisions should belong to the product, not to individuals.

Ownership provides accountability.

History provides understanding.

---

# Revisiting Decisions

Old decisions should not become permanent simply because they are old.

Instead ask:

- Is the original problem still relevant?
- Has technology changed?
- Has the product changed?
- Would we make the same decision today?

Good engineering continuously reevaluates assumptions.

---

# Naming Convention

Use sequential numbering.

Examples:

ADR-0001 Generation Pipeline

ADR-0002 Science Memo Architecture

ADR-0003 Background Workers

ADR-0004 Page Contracts

Never rename old ADRs.

History matters.

---

# Product Rules

Every important architectural decision should answer:

1. What problem were we solving?
2. Why was this solution chosen?
3. What alternatives were considered?
4. What tradeoffs were accepted?
5. How will future engineers know when to revisit this decision?

Architecture is not only the system we build.

It is also the reasoning we leave behind.

The best engineering teams don't just write good code.

They preserve good decisions.
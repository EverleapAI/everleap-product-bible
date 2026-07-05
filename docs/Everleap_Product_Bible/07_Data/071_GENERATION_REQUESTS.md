# Generation Requests

## Purpose

Generation Requests are the orchestration engine of Everleap.

They answer one simple question:

> **"What knowledge needs to be rebuilt because the user's understanding has changed?"**

Rather than rebuilding every page after every interaction, Everleap records generation requests and allows background workers to intelligently rebuild only what is necessary.

This architecture makes the platform scalable, reliable, and efficient.

---

# Philosophy

Users create evidence.

Evidence creates work.

Generation Requests describe that work.

They do **not** contain AI output.

They do **not** contain user-facing content.

They simply describe what needs to happen next.

Think of them as the scheduling system for the product's intelligence.

---

# Why They Exist

Without Generation Requests, every user interaction would require immediate AI generation.

That would create:

- slow page loads
- unnecessary AI calls
- inconsistent user experiences
- high operating costs
- tightly coupled systems

Instead, Everleap separates interaction from intelligence.

The user continues using the product while background workers quietly improve their experience.

---

# The Lifecycle

Every Generation Request follows the same lifecycle.

```
Evidence Changes

↓

Generation Request Created

↓

Pending

↓

Worker Claims Request

↓

Running

↓

Complete

or

Failed
```

The status values are exactly `pending`, `running`, `complete`, and `failed`. (Note `complete`, not "completed"; there is no separate "background" or "scheduled" status.)

The lifecycle should be deterministic and fully observable.

---

# What Creates Requests

Generation Requests may be created whenever meaningful evidence changes.

Examples include:

- onboarding completed
- Story answer submitted
- Story completed
- Tiny Task completed
- Action completed
- reflection submitted
- recommendation explored
- counselor interaction
- future coaching conversations

Not every interaction requires regeneration.

Only interactions that materially change understanding should create requests.

---

# Targets

Each request identifies exactly what should be rebuilt.

Examples include:

- science:ikigai
- science:enneagram
- science:parachute
- page:today
- page:insights_summary
- page:insights_motivations
- page:insights_strengths
- page:insights_skills
- page:insights_time_twin
- page:insights_fun_facts
- page:explore
- recommendation:careers
- recommendation:actions
- memory:consolidate
- future coaching agents

Insights is driven per-tab. Each Insights tab is its own target (`page:insights_summary`, `page:insights_motivations`, `page:insights_strengths`, `page:insights_skills`, `page:insights_time_twin`, `page:insights_fun_facts`), and live events enqueue those.

The combined single-pass `page:insights` target still exists and the dispatcher still routes it, but it is deprecated/orphaned: no live event enqueues it, and it appears only in the unused `REFRESH_INSIGHTS` and `FULL_REBUILD` bundles.

Targets describe work.

They do not describe implementation.

---

# Bundles

Events do not enqueue raw targets one at a time. They enqueue named **bundles**—curated sets of targets that belong together for a given interaction.

Examples include:

- `REFRESH_TODAY` — Today plus memory consolidation.
- `REFRESH_INSIGHTS_SUMMARY` — every per-tab Insights target, actions, Explore, and memory consolidation.

A Story answer, for instance, enqueues `REFRESH_TODAY` and `REFRESH_INSIGHTS_SUMMARY` together, and each target in the bundle becomes its own request.

The bundle is the unit an event dispatches; the individual request is still the unit a worker claims. Two bundles (`REFRESH_INSIGHTS` and `FULL_REBUILD`) are defined but no longer driven by any live event; they are the only remaining references to the orphaned combined `page:insights` target.

---

# Dependency Resolution

Generation Requests should not need to understand dependencies.

Instead, dependencies are declared by generation targets.

For example:

```
Today

depends on

Ikigai
Enneagram
Parachute
```

When Today is requested, the dispatcher automatically ensures those sciences are rebuilt first.

The request remains simple.

The dispatcher remains intelligent.

---

# Execution Modes

Not every request has the same urgency.

The execution mode is one of exactly three values: `deferred`, `immediate`, or `blocking`. The default is `deferred`.

### Deferred

Normal asynchronous generation. Most requests belong here, and it is the default when no mode is specified.

---

### Immediate

User should receive updated guidance as quickly as practical.

Examples:

- onboarding completed
- Story completed

---

### Blocking

The request is expected to run in-line with the interaction rather than being picked up later by a worker.

---

Execution mode should affect scheduling.

Never product behavior.

---

# Idempotency

Every request should be safe to execute multiple times.

If identical evidence produces identical work, repeated execution should not create inconsistent results.

Generators should be deterministic whenever practical.

This is enforced concretely by an input-hash cache. A table, `generation_input_hashes`, stores one hash per `(user_id, cache_key)`: the hash of the inputs that produced that target's last output. Before a target calls the model, it re-hashes its current inputs; if the hash is unchanged, it skips generation and leaves the existing output in place. Re-running a request on unchanged inputs is therefore a literal no-op rather than a repeated AI call—this is the platform's primary idempotency and cost mechanism. The cache fails open: any lookup error is treated as "not fresh," so it can only ever cause an unnecessary regeneration, never serve stale content.

---

# Failure Handling

Failures are expected.

AI services fail.

Networks fail.

Models occasionally return unusable output.

Generation Requests should preserve:

- failure reason
- retry count
- timestamps
- execution history

Failures should never interrupt the user's experience.

---

# Observability

Every request should answer:

- When was it created?
- Why was it created?
- What evidence triggered it?
- Which worker processed it?
- How long did it take?
- Did it succeed?
- What was regenerated?

Generation Requests form one of the most important debugging tools in the platform.

---

# Scalability

The request system should support:

- many workers
- many sciences
- many agents
- many AI providers

Workers should compete to claim pending requests.

No worker should require knowledge of the others.

Horizontal scaling should happen naturally.

---

# Future Evolution

As Everleap grows, new generators should require only:

1. Register the target.
2. Declare dependencies.
3. Implement the generator.

The request system itself should require little or no modification.

A good orchestration system grows by configuration rather than redesign.

---

# Product Rules

Generation Requests should always be:

- lightweight
- deterministic
- observable
- retryable
- idempotent
- dependency-aware
- independent of AI models

Generation Requests are not intelligence.

They are the traffic controller that ensures Everleap's intelligence happens in the right order, at the right time, and for the right reasons.
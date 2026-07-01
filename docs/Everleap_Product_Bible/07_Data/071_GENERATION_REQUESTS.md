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

Completed

or

Failed
```

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
- page:insights
- recommendation:careers
- recommendation:actions
- future coaching agents

Targets describe work.

They do not describe implementation.

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

Typical execution modes include:

### Immediate

User should receive updated guidance as quickly as practical.

Examples:

- onboarding completed
- Story completed

---

### Background

Normal asynchronous generation.

Most requests belong here.

---

### Scheduled

Future rebuilding.

Examples:

- nightly refresh
- weekly synthesis
- periodic recommendations

Execution mode should affect scheduling.

Never product behavior.

---

# Idempotency

Every request should be safe to execute multiple times.

If identical evidence produces identical work, repeated execution should not create inconsistent results.

Generators should be deterministic whenever practical.

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
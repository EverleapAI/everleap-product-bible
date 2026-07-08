# Actions

> **Implementation note:** Actions is a primary bottom-nav section at
> `/main/actions` (`apps/web/src/app/(app)/main/actions/page.tsx`), with a
> per-action "mission" detail at `/main/actions/[id]`. It reads the real
> `user_actions` store via `guidance/actions` (GET/POST/PATCH); suggestions come
> from `guidance/action-suggestions` (target `recommendation:actions`). It is the
> concrete home of the "next steps" half of `039_RECOMMENDATIONS.md`.

## Purpose

Actions is where understanding becomes doing. The rest of the product helps a
user see themselves and see possibilities; Actions is the surface that turns any
of that into one concrete thing they actually go and try — and then captures what
they learned.

If Today asks "what's one small step *today*?" and Explore asks "what's worth
looking into?", Actions is the shared to-do surface those steps and paths land
in, plus a place the product can suggest a few of its own.

---

## The Question This Page Answers

> **"What have I decided to try, where does each stand, and what did I learn?"**

---

## Philosophy

A recommendation the user never acts on produces no new evidence. Growth comes
from the loop: try something → notice what happened → that observation feeds the
next understanding. Actions exists to close that loop, not to be a productivity
tracker. Completing an action is not the goal; *learning something* is.

---

## What Actions Contains

- **Suggested for you** — a small set of agent-suggested next steps grounded in
  the user's own signal (`recommendation:actions`). Each can be added to the
  user's list or dismissed ("not for me"); dismissals are remembered.
- **To try** — actions the user has committed to (saved from Explore, promoted
  from a Today dispatch, or added from a suggestion), including ones in progress.
- **Done** — completed actions.
- **Status controls** — mark complete, mark working-on-it, or dismiss, applied
  optimistically. Each action carries a source-attribution chip (where it came
  from) and an Open link where relevant.
- **Mission detail (`/main/actions/[id]`)** — an action opened as a runnable
  "mission": what it is, concrete steps to actually do it, and a reflection prompt
  afterward.
- **Empty state** — routes the user to Explore to find something worth trying.

---

## Relationship to Other Pages

- **Explore** — "Try it for real" opportunities and career paths save into Actions.
- **Today** — a Today dispatch can become an action; completing an action feeds
  Today's next dispatch.
- **Insights / Sciences** — a completed action and its reflection are new
  **evidence**; they flow back into the science layer and future guidance.

---

## AI Responsibilities

AI *suggests* and helps frame a mission; it never assigns homework or pressures.
Suggestions must be concrete, teen-safe, and tied to real evidence — and the user
can always dismiss them. The reflection step is an invitation, not a requirement.

---

## Success

Actions succeeds when a user tries something they wouldn't have otherwise, and
comes back with "here's what I noticed" — whether or not the thing was "for them."

---

## Anti-Patterns

Actions should never:

- feel like a chore list or nag about incomplete items
- treat completion as the only success (a tried-and-rejected action is a win)
- suggest generic self-improvement tasks unsupported by the user's evidence
- overwhelm with too many suggestions at once
- lose the "why" — every action should trace back to something the product noticed

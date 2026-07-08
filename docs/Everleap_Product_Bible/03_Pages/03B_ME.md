# Me (Profile)

> **Implementation note:** "Me" is a primary bottom-nav section at
> `/main/profile` (`apps/web/src/app/(app)/main/profile/page.tsx`), labeled **Me**
> in the nav. It is a hub with sub-routes: `edit`, `portrait`, `data`, `journey`,
> `reflections`.

## Purpose

Me is the user's own space — the one section that faces *inward* rather than
forward. Everywhere else the product is doing something *for* the user (guiding,
explaining, suggesting); Me is where the user sees who Everleap understands them
to be, revisits their own journey, and stays in control of their data and account.

---

## The Question This Page Answers

> **"Who am I to Everleap so far — and what's mine to control?"**

---

## Philosophy

Trust requires both **reflection** and **control**. A product that forms a rich
picture of a young person must let that person see the picture, feel ownership of
it, and be able to change or take back their data at any time. Me is where the
product's understanding is handed back to its owner.

---

## What Me Contains

A basics header (name, account) plus logout, and the self-facing features:

- **Self-portrait** (`/portrait`) — a warm, synthesized reflection of who the
  user is, drawn from their evidence.
- **Reflections** (`/reflections`) — the user's own reflections over time.
- **Journey** (`/journey`) — the story of their progress: how far they've come
  and the momentum they've built.
- **Edit** (`/edit`) — update the basics the product holds about them.
- **Data control** (`/data`) — download their data or delete it; the account
  controls that make the rest safe to offer.

---

## Relationship to Other Pages

- **Story / Insights** — Me reflects the same evidence and understanding, framed
  as "you," not as analysis.
- **Actions / Today** — the journey and momentum shown here are the accumulation
  of what the user has done across the product.

---

## AI Responsibilities

Where AI renders a self-portrait or reflection, it must stay humble and tentative
— describing patterns, never issuing verdicts or fixed identity. This is the
surface where over-claiming would feel most invasive, so the teen-safety and
"hold it loosely" bars are highest here.

---

## Success

Me succeeds when a user feels *seen* without feeling *labeled*, and feels fully in
control of their information — enough to trust the rest of the product with it.

---

## Anti-Patterns

Me should never:

- assign a fixed identity or a verdict ("you are an X")
- make data export or deletion hard to find or discouraging to use
- surface raw internal scores or science memos as if they were facts about the person
- feel clinical — it should read as a mirror, not a report card

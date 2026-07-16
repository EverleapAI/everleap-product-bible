# Everleap — Repository Guide

This is the Everleap monorepo. It contains **both** the product source code **and** the
**Everleap Product Bible** — the canonical, plain-language explanation of what Everleap is,
who it's for, and how every part of it works.

If you are a new teammate pointing Claude Code at this repo for the first time: welcome.
This file loads automatically every time Claude starts here, so Claude already knows the
map below. Your job is mostly to ask good questions.

---

## Start here: the Bible is ground truth

Before designing or building **anything**, read the Bible in `docs/Everleap_Product_Bible/`.
Start with `READ_ME_FIRST.md`, then work through the numbered sections:

| Section | What's in it |
|---|---|
| `00_Foundation` | Vision, mission, first principles |
| `01_Product` | What Everleap actually is |
| `02_Users` | Who it's for and what they need |
| `03_Pages` | The screens and user flows |
| `04_Sciences` | The science pipeline |
| `05_AI` | The AI / agent layer |
| `06_Architecture` | How the system is built |
| `07_Data` | The data model |
| `08_Writing` | Voice, tone, and copy rules |
| `09_Future` | Roadmap and where it's going |
| `10_Implementation` | **Implementation ground truth — when docs conflict, this one wins** |
| `99_Reference` | Glossary and reference material |

Rule of thumb: **when your assumptions and the Bible disagree, the Bible wins. When two
Bible sections disagree, `10_Implementation` wins.**

---

## Source layout

- `apps/web` — the Next.js frontend (the product UI). Screens live under `apps/web/src`.
- `apps/everleap-api` — the backend API.
- `packages/ui` — shared UI components / the design system.
- `prisma` — the database schema.

---

## Designing new screens

The point of reading the Bible first is so new work *fits* Everleap instead of fighting it.

- **Match, don't invent.** Colors, spacing, and typography come from the design-system
  tokens — not hand-picked raw values. Look at existing components in `packages/ui` and
  `apps/web/src` and follow their patterns before creating new ones.
- **Voice matters.** Read `08_Writing` before writing any user-facing copy.
- **Ground it in the flows.** `03_Pages` describes how screens connect; new screens should
  slot into that, not float free.

---

## Working style

- **Read and understand before proposing.** This is a real product mid-build, not a sketch.
- **Propose before changing.** Especially for a first pass — explain the idea, show where it
  fits in the Bible and the code, then build.
- If you're a read-only collaborator, see `docs/onboarding/CLAUDE-readonly-setup.md`.

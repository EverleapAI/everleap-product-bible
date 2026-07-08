# Read Me First 👋

Welcome to Everleap. This repo is the **Product Bible** — the source of truth for
*why* Everleap exists, *how* it should behave, and *how* it's actually built. You
don't need to read all of it before you write code, but spend your first hour
here — it will save you many later.

## What Everleap is, in two sentences

Everleap helps young people (roughly 13–22) understand themselves and explore
what's possible — through onboarding, a reflective "Story", science-based
insights, a daily "Today" nudge, an "Explore" section, and "Actions" they
actually go do. The whole product runs on one idea: **evidence → science →
knowledge → experience**, where AI works in the *background* and pages just read
what it produced.

## The one mental model to hold

> **Pages consume knowledge. They never create it.**

A page never calls a language model inline. User activity creates evidence; a
background **generation queue** turns evidence into stored knowledge (science
memos, Today guidance, Explore matches…); pages render that stored knowledge
instantly. If you remember nothing else, remember this — it explains the entire
architecture. (Full version: `06_Architecture/060_SYSTEM_ARCHITECTURE.md`.)

## The three repos

| Repo | What |
|---|---|
| **this one** (`everleap-product-bible`) | the docs you're reading |
| `EverleapAI/web` | the Next.js frontend (`apps/web`) |
| `EverleapAI/everleap-api` | the Azure Functions backend (`apps/everleap-api`) |

Ask the team for access to the two code repos, and for the backend secrets
(`apps/everleap-api/local.settings.json`) — those are shared out-of-band and are
never committed.

## Your first hour

1. **Skim `README.md`** — how this Bible is organized and how to read it.
2. **Get it running:** `10_Implementation/GETTING_STARTED.md` — clone, install,
   run the backend (port **7071**) and the web app (port **3000**) locally, and
   set up your editor + Claude Code. This is the fastest path to a working app.
3. **Get the shape of the system:**
   - `06_Architecture/060_SYSTEM_ARCHITECTURE.md` — the four-layer model above.
   - `10_Implementation/108_INDEX.md` — the map of the as-built developer
     reference (real DB schema, every API endpoint, the generation pipeline, the
     prompt catalog, deployment).
   - `10_Implementation/109_EVERLEAP_PLAYBOOK.md` — how to actually work in the
     codebase day to day.
   - `06_Architecture/063_EXPLORE_ARCHITECTURE.md` — the largest, most
     representative subsystem, documented end to end.

## How to read the rest

The numbered sections `00_Foundation` → `09_Future` are the *philosophy and
product* (read top-down when you have time). `10_Implementation` is the *as-built
technical reference* — jump into it, don't read it cover to cover.

## The honesty rule

`10_Implementation` was written by reading the real code. If you ever find it
disagreeing with the code, **the docs are wrong, not the code** — fix the doc (or
flag it). Keeping this section true to the code is everyone's job, including
yours.

Glad you're here. Now go get the app running. 🚀

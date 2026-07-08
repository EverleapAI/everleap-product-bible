# Everleap Product Bible

> *The definitive source of truth for the Everleap product.*

---

# Purpose

The Everleap Product Bible exists to capture everything required to understand, design, build, and evolve Everleap.

It is intended to become the permanent institutional memory of the product.

Every significant product decision should eventually be reflected somewhere within this repository.

The Product Bible explains **why** Everleap exists, **what** it is trying to accomplish, **how** it should behave, and **how** future decisions should be made.

It is not intended to replace technical documentation or source code.

Instead, it provides the philosophy, design principles, scientific foundations, product intent, and architectural thinking that guide the implementation.

---

# Who Should Read This

This documentation is written for:

- Product designers
- Engineers
- AI coding assistants
- Future employees
- Product managers
- UX designers
- Researchers
- Investors who want to understand the long-term vision

Anyone making meaningful changes to Everleap should understand this documentation before making product decisions.

---

# Relationship to the Code

The source code explains **how Everleap works today.**

The Product Bible explains **why Everleap works the way it does.**

When implementation and philosophy disagree, the disagreement should be understood before code changes are made.

The Product Bible should evolve alongside the product.

---

# What This Repository Contains

## 00 Foundation

The philosophical foundation of Everleap.

These documents answer:

- Why does Everleap exist?
- What does it believe?
- What principles guide every decision?

---

## 01 Product

The overall product experience.

These documents describe how the major parts of Everleap work together to create a coherent developmental journey.

---

## 02 Users

Who Everleap serves.

These documents describe the different user groups, their goals, needs, and how the product should adapt to them.

---

## 03 Pages

Every major screen in Everleap.

Each page should explain:

- Purpose
- User mindset
- Inputs
- Outputs
- User experience
- Relationship to other pages
- Success criteria
- Things the page should never do

---

## 04 Sciences

Every scientific framework used by Everleap.

Each science should answer one unique question.

Each document explains:

- Scientific background
- Why this science is included
- What it measures
- What it does not measure
- How it contributes to Everleap
- How it interacts with the other sciences

---

## 05 AI

How artificial intelligence is used throughout Everleap.

Topics include:

- AI philosophy
- Generation pipeline
- Confidence
- Prompt design
- Agent responsibilities

---

## 06 Architecture

The conceptual architecture of the platform.

These documents explain how the product is organized rather than how individual functions are implemented.

---

## 07 Data

The information model behind Everleap.

Topics include:

- Data philosophy
- Generation requests
- Science memos
- Persistent guidance

---

## 08 Writing

Defines the Everleap voice.

These documents explain how Everleap communicates with users.

Language should always remain:

- curious
- humble
- evidence-based
- encouraging
- development focused

---

## 09 Future

Long-term thinking.

These documents capture future ideas, roadmap items, and concepts that have not yet entered implementation.

---

## 10 Implementation

**The as-built developer reference — start here if you are writing code.**

Unlike the rest of the Bible (which describes *why* Everleap behaves as it does), this section describes *what is actually built*, verified by reading the code in `apps/everleap-api` and `apps/web`. It covers a run-it-locally getting-started, the real database schema, every API endpoint, the generation registry and event flow, the production prompt catalog, deployment + environment, testing, a changelog, and a day-to-day working playbook.

New engineers: read `108_INDEX.md`, then `GETTING_STARTED.md`, then `109_EVERLEAP_PLAYBOOK.md`.

Treat any divergence between this section and the live code as a bug in the docs, and fix it.

---

## 99 Reference

Shared reference material — the glossary of terms used across the Bible (`990_GLOSSARY.md`).

*(Architecture Decision Records live in `09_Future/094_ARCHITECTURE_DECISION_RECORDS.md`.)*

---

# How to Use This Product Bible

This documentation should be read from the top down.

The recommended order is:

1. Foundation
2. Product
3. Users
4. Pages
5. Sciences
6. AI
7. Architecture
8. Data
9. Writing
10. Future

Understanding the philosophy before the implementation helps preserve consistency as Everleap grows.

**Developers:** once you understand the philosophy, use **10 Implementation** as your working reference — it is meant to be jumped into, not read top-down — and **99 Reference** for the glossary. If you only have an hour, read `10_Implementation/GETTING_STARTED.md` and `108_INDEX.md`.

---

# Living Documentation

This Product Bible is intended to evolve with the product.

It is expected that:

- new features will introduce new documentation
- existing documents will mature over time
- obsolete ideas will be revised rather than hidden
- implementation changes will be reflected here

This is a living document, not a historical archive.

---

# The Goal

A person who has never seen Everleap before should be able to read this Product Bible and understand:

- why the product exists
- who it serves
- how it thinks
- how it should evolve
- how future decisions should be made

before reading a single line of code.

If this documentation succeeds, the philosophy of Everleap will remain consistent even as the implementation continues to evolve.
# Memory Model

## Purpose

Everleap should feel like a relationship that deepens over time.

Not a form that resets on every visit.

Memory is what makes that possible.

It lets guidance reference what came before—the same way a person who knows you well would, not the way a system reads back its own records.

---

# Two Layers, Not One

Memory has two distinct layers, and they behave differently on purpose.

## Recent Activity

A short, concrete, time-bounded list of what someone has actually said or done recently—an answer, a rating, a completed reflection.

This layer exists to be referenced specifically and conversationally.

"I noticed you said..." is warm.

It should never read as a list, a count, or a timestamp.

## The Longer-Term Note

A single, evolving piece of durable understanding—revised over time, not appended to.

It exists to inform reasoning and tone, not to be quoted.

It is never shown to the user directly.

---

# Memory Is Written Separately From How It Is Used

Writing memory and using memory are two different moments, and they should stay that way.

Memory is consolidated in the background, off the same evidence that already triggers other generation.

Generation never waits for a fresh consolidation.

It simply reads whatever the longer-term note currently says—even if that note is a few minutes old.

This mirrors the rest of the generation pipeline: reading is immediate, writing happens behind the scenes. See Generation Pipeline.

---

# Not Every Signal Is Equally Trustworthy

Memory draws on more than one kind of evidence, and it should not treat all of it the same way.

## Explicit Signal

What someone directly told Everleap—a Story answer, a Tiny Task response, a rating.

This is the strongest evidence memory has. It may shape both the recent-activity layer and the longer-term note.

## Inferred Signal

What someone's behavior suggests without being asked—which pages keep getting revisited, which are never opened.

This is weaker. It should only ever inform the longer-term note, as a pattern of attention or absence, never as a specific callback. One visit means nothing. A page nobody opens after weeks of use might.

This weakness is now built into the plumbing. Consolidation (`memory:consolidate`) is guarded by the same input-hash cache as the rest of the pipeline, and page views are deliberately excluded from that hash: only explicit signal—Story answers, Tiny Task answers, feedback—can trigger a fresh consolidation. Passive page activity is still read into the note when consolidation does run, but it never causes a run on its own.

Future external signal—information from outside Everleap's own product, such as a connected account—would be weaker still, and would require its own explicit permission before it could inform anything at all. Everleap should never quietly absorb signal a user did not knowingly provide.

---

# Memory Changes Tone, Never Claim Type

The longer-term note may let guidance sound more specific and more confident as a pattern holds up across more evidence—the same way overall confidence already does. See Confidence Model.

This is never license to change what kind of claim is being made.

No identity. No prediction. No matter how consistent the pattern looks, no matter how long memory has been tracking it.

"This keeps showing up for you" is available at any depth of memory.

"You are becoming a doctor" is not available at any depth of memory.

---

# When Self-Report And Behavior Disagree

Sometimes what someone says about themselves and what they actually do point in different directions.

Memory will notice this eventually. When it does:

The user's own words always outrank what their behavior suggests.

The disagreement should be raised as a genuine, open question—never as a correction.

"You say X, but you don't act like it" is never acceptable, at any confidence, in any product surface.

See Tone and Voice.

---

# Memory Should Never Be Visible As A Mechanism

A user should never be able to tell that a rating, a memory note, or a past interaction shaped what they are reading now.

If guidance is reframed because of feedback, it should read as Everleap's next honest attempt—not a retry, and not an acknowledgment that anything changed.

Mystery about the underlying mechanics is fine.

Mystery about the underlying evidence is not—see Explainability, in Generation Pipeline.

---

# Memory Does Not Reach The Science Layer

The Science layer stays independent, deriving its hypotheses only from raw evidence—never from memory, and never from what synthesis has already concluded.

This is deliberate. Memory sits downstream of the sciences: it is shaped in part by how people react to what Today and Insights already said. If memory fed back into the sciences, that reaction would quietly become part of the evidence itself, and the sciences would no longer be an independent check on synthesis—they would start confirming their own past conclusions.

If a science should know more, it should see more raw evidence directly—not a memory note built from interpretation.

---

# Success

The memory model succeeds when returning users feel recognized without ever feeling watched.

When a longer relationship produces better questions, not just more confident answers.

When someone can look at any sentence memory produced and trace it back to something they actually said or did.

---

# Product Rules

Every generator that reads memory should be able to answer:

1. Is this drawing on something the person actually told Everleap, or something inferred from their behavior?
2. Would this sentence be true without the memory layer, just less specific?
3. Could the user trace this back to something real if they asked why?
4. Does this change the tone, or does it accidentally change the kind of claim being made?

If a generator cannot answer those four questions, it is not ready to read memory yet.

---
name: concept
description: Bootstraps a concept note. Skeleton + interview Qs; user fills substance. Refuses to write content the user hasn't engaged with.
model: inherit
---

The user wants to create a concept note for:

${1}

## Hard rule

**You do not write the substance of the concept for the user.** Writing a
complete concept note from your training data is exactly the "reading
about ≠ learning" anti-pattern flagged in the master plan. Your job is to
build a *good prompt* for the user to fill in, not to fill it in for them.

The only sections you may pre-fill:

- The frontmatter / tags (per template).
- The list of **interview questions** this concept tends to attract (this
  is what the user is preparing for — the questions are the prompts).
- **Pointers to related concepts** that already exist in the vault (search
  `03_Concepts/` for adjacency).
- A *one-line stub* in "Definición" — and only as a placeholder for the
  user to rewrite.

Everything else stays as template placeholders.

## Flow

1. Figure out which domain folder this belongs in: Algorithms, Frontend,
   Backend, JavaScript, TypeScript, Patterns, Performance, SystemDesign,
   Books. If ambiguous, propose two and let the user pick.
2. Search `03_Concepts/<Domain>/` to confirm no existing note for this
   topic. If one exists, surface it and ask whether the user wants to
   extend it instead of creating a new one.
3. Generate 5-8 interview questions that this concept tends to attract,
   tilted toward Staff-level depth (not "what is X" but "when would you
   not use X", "what does X cost at 10x scale", "what's the trade-off
   between X and Y").
4. Find 2-4 related existing notes in the vault to link.
5. Create the note at `03_Concepts/<Domain>/<Topic>.md` using the template
   at `99_Templates/Concept.md`. Use Templater syntax where the template
   does. Leave Definición, Por qué importa, Cómo funciona, Ejemplo, and
   Trade-offs as empty headings with a `<!-- TODO -->` marker.
6. Update `03_Concepts/<Domain>/00_MOC_<Domain>.md` to add a link to the
   new note under the appropriate subsection.

## After saving

Tell the user, in 2-3 sentences:

- The 1 interview question this note should be able to answer in 2
  minutes when finished.
- One specific *exercise* they can do to actually learn the concept
  rather than just summarize it (build a small thing, walk through a
  failure case, explain it to a rubber duck in their own words).

## Anti-patterns to refuse

If the user asks: "just write the concept for me" or "give me the full
explanation of X" — refuse, and reread the second rule of the master plan
back to them: *"Confundir 'leer sobre algo' con 'aprenderlo'."* Offer to
help them *learn* the concept instead (Socratic Q&A, exercise design,
critique of their draft).

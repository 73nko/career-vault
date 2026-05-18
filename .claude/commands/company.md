---
name: company
description: Bootstraps a Company_Research note. Pulls public stack/blog/process intel; flags gaps for the user to fill via referrals.
model: inherit
---

Bootstrap a company research note for:

${1}

## Flow

1. Confirm the company is one of the target tiers in
   `06_Interviews/Companies/00_Target_Companies_Tracker.md`. If it's not
   listed, ask whether to add it and to which tier.
2. Check whether a note already exists at
   `06_Interviews/Companies/<Company>.md`. If yes, ask whether to extend
   it; do not overwrite without confirmation.
3. Gather public information (use WebSearch / WebFetch). Target sources:
   - The company's engineering blog or tech blog (find the canonical URL).
   - Public talks (YouTube, conf talks) by their engineers.
   - Their public OSS repos (one or two flagship ones).
   - Glassdoor and LeetCode Discuss for **publicly reported interview
     process** — but do NOT rely on a single anecdote.
   - Recent press / funding stage (size + trajectory matters for Staff).
4. Synthesize into the Company_Research template at
   `99_Templates/Company_Research.md`. Save to
   `06_Interviews/Companies/<Company>.md`.

## Honest gaps

The template has fields you cannot fill from public information:

- Personas a contactar
- Lo que me hace candidato fuerte / débil (this is the user's own
  reflection, not yours)
- Plan para esta empresa
- Log de interacciones

Leave these as empty headings with `<!-- TODO: ... -->` notes. Don't
fabricate.

## What goes in the synthesis

For each filled section, prefer **concrete, dated, linked** signals over
generalizations:

- **Stack:** name the technologies with a link to where you found it
  (a job posting, a blog post, a public repo). "Modern stack" is useless.
- **Cultura técnica:** link 2-3 of their best engineering blog posts and
  say one sentence per post about what it reveals about their bar.
- **Proceso de entrevista:** distinguish "publicly confirmed" from
  "reported in one Glassdoor review (treat with skepticism)".
- **Engineering blog posts relevantes:** pick 3-5 posts that the user
  should *actually read* before applying. Link directly to them.

## After saving

Tell the user, in 2-3 sentences:

- One specific thing about this company that should change how the user
  prepares (e.g., "they ask system design at the data-layer level — your
  ClickHouse prep is directly relevant").
- One *honest* gap in the user's current preparation for this specific
  company.
- Whether their current quarter's plan aligns with applying here, or
  whether applying should be deferred. (Cross-reference
  `01_Plan/00_Master_Plan.md` — applying is generally a Q4 activity.)

## Update the tracker

After saving, update `06_Interviews/Companies/00_Target_Companies_Tracker.md`
to flip "Estado research" from "Pendiente" to "Completo" (or "Parcial" if
significant gaps remain).

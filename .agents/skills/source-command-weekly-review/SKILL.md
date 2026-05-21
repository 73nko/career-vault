---
name: "source-command-weekly-review"
description: "Guided Sunday weekly review. Walks the user through hours, plan progress, notes created, wins, blockers, next-week focus."
---

# source-command-weekly-review

Use this skill when the user asks to run the migrated source command `weekly-review`.

## Command Template

Run a guided weekly review. This is the user's Sunday ritual — non-negotiable
per `README.md`. It should take ~15 minutes.

## Pre-flight (do this before the first question)

1. Determine the current ISO week (`gggg-[W]ww` format) in Europe/Madrid.
2. Check whether a weekly review note already exists at
   `02_Daily/<YYYY-Www>.md`. If yes, ask whether to overwrite or extend.
3. Find the current quarter plan (`01_Plan/Q<n>_Plan.md`) and read the
   relevant week's block to understand what was planned.
4. Scan `02_Daily/` for daily notes created in the past 7 days — pull the
   "Horas reales", "Qué aprendí", and "Bloqueos" fields from each.
5. Scan `03_Concepts/` for files with `file.cday` in the last 7 days (use
   `find ... -newer ...` via Bash).
6. Scan `06_Interviews/Behavioral/` for STAR files modified in the last 7
   days.
7. Scan `00_Inbox/` for anything that needs filing.

Present the user with a short pre-flight summary (5-8 lines) before
asking the first question. This is to ground them — they may have
forgotten what they did.

## The review (interactive)

Walk through these sections in order, one question at a time. Use the
template at `99_Templates/Weekly_Review.md` as the structure.

1. **Horas.** Planeadas: 7. Reales: <sum from daily notes>. Diferencia.
   If diff is negative by more than 2h, ask one question about why — but
   only one. The user has explicitly said missed hours don't roll over.
2. **Avance del plan.** Which block of the current Q were they on? Show
   the block's checklist from the Q plan. Ask them to mark % complete and
   whether they're "en ritmo / atrasado / adelantado" — honest answer
   only.
3. **Notas creadas.** Show the list you scanned. Ask which of these the
   user would call "real progress" vs "shallow capture".
4. **Algoritmos resueltos.** From `03_Concepts/Algorithms/` new this week.
5. **Wins.** Two or three concrete things. Press if they reach for
   generalities ("learned a lot").
6. **Bloqueos no resueltos.** Ask: are these blockers external (need
   someone), internal (need to decide), or avoidance (don't want to do
   the thing)? Tag each.
7. **Inbox.** Walk through items in `00_Inbox/`. For each: file it, drop
   it, or convert to an actionable note. Do this together; don't let
   them defer this *again*.
8. **Próxima semana.** Foco principal (one sentence). 3 concrete tasks.
   Cross-check against the Q plan — does next week's focus actually
   advance the Q1 hito?
9. **Energía / disciplina.** 1-5 scale + one sentence. If they rate
   below 3 for two consecutive weeks, flag it — that's a leading
   indicator that the plan is in trouble.

## Save

Write the populated review to `02_Daily/<YYYY-Www>.md` based on
`99_Templates/Weekly_Review.md`. Preserve Templater date placeholders for
the navigation links at the bottom unless the user is explicitly running
this for a past week.

## Honest verdict

End with one short paragraph:

- Is the user on track for the current Q hito? Yes / borderline / no.
- If "no" or "borderline": specifically which milestone is slipping, by
  what margin, and what's the one thing to change next week. The master
  plan rule is: *"Si en Q1 no llego al hito, paro y replanifico. No me
  autoengaño."* — uphold that.
- If "yes": one thing to keep doing that's working.

Do not soften this.

## What to skip

- Don't generate a "win" if there wasn't one. An honest "this week was
  recovery from a bad sleep streak" is more useful than fake wins.
- Don't reorganize the vault as part of the review. That's the trap.
- Don't propose tooling improvements as a review action. That's also
  the trap.

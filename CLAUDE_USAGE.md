# Claude Usage Guide — Career Vault

#meta

How to use the Claude Code automation set up for this vault. Reference document — open this when you've forgotten how something works.

Last updated: 2026-05-18. Update when you change `.claude/` config or add new commands.

---

## Purpose

This vault has Claude Code configuration that turns it into a structured study/interview-prep environment. The configuration enforces discipline (refuses to write substance for you, demands quantified STAR results, scores honestly) and removes friction from the rituals (weekly reviews, mock debriefs, note scaffolding).

The configuration is **opinionated**. It's calibrated to fight specific anti-patterns you self-flagged in the master plan: vault-polishing, "reading ≠ learning", inflating the project, applying too early.

If it ever stops fitting, edit `.claude/` files directly.

---

## What's automatic

The moment you open Claude inside this vault (`cd ~/Projects/career-vault && claude`):

### 1. Status line shows phase + hours

```
~/Projects/career-vault (main) Opus 4.7 Q1 W2 0h/7h ctx:12%
```

- `Q1 W2` — current quarter + week number of the 52-week plan
- `0h/7h` — hours summed from `- Horas reales:` lines in this ISO week's daily notes
- Hours color: **yellow** = behind, **green** = on track (≥ half target), **magenta** = over target
- Source: `.claude/statusline.sh`

### 2. SessionStart hook prints context

```
Career vault — Mon May 18
Plan: Q1 · Week 2/52 · 0h/7h this week
Daily note: MISSING — create 2026-05-18.md before the session
```

Conditional extras:
- Sunday with no weekly review file yet → `Sunday — weekly review pending. Run /weekly-review.`
- Last Sunday of month → `Last Sunday of May — monthly review window.`
- Fri/Sat/Sun and < 3.5h logged → `Hours behind target — Xh logged with N days into the week.`

Claude reads all this as context — no need to re-explain where you are.

Source: `.claude/hooks/session-start.sh`

### 3. Vault `CLAUDE.md` is loaded

`CLAUDE.md` at the vault root overrides the global engineering rules. Tells Claude:
- This is an Obsidian vault, not code.
- Anti-patterns to call out (vault-polishing, reading-not-learning, etc.).
- File/tag conventions, template paths, Templater syntax.
- Disables the TDD / surgical-changes / brainstorm-ceremony rules for note edits.

### 4. Project memory is loaded

Stored at `~/.claude/projects/-Users-73nko-Projects-career-vault/memory/`:
- `user_profile.md` — Staff target, Datadog/Meta history, boxing routine, auto-engagement risks
- `project_vault.md` — vault layout, templates, review rituals, tagging
- `MEMORY.md` — index

To view or update: `/memory` slash command (Claude Code built-in), or edit files directly.

To add a new memory: just ask Claude "remember that…" — it'll write a new file in that directory and add a line to `MEMORY.md`.

---

## Command + agent reference

### Project slash commands (only inside the vault)

| Command | Argument | What it does |
|---|---|---|
| `/algo` | `<problem>` | Socratic NeetCode coach. Refuses to reveal the solution. Saves a note in `03_Concepts/Algorithms/`. |
| `/star` | `<story-key>` | STAR drafting coach. Enforces I-vs-we, demands a metric. Saves to `06_Interviews/Behavioral/`. |
| `/star-critique` | `<file>` | Rubric review (7 axes, /21). Does not edit the file. |
| `/system-design` | `<topic>` | 45-min phased system design mock. Saves to `06_Interviews/SystemDesign/`. |
| `/mock` | `behavioral\|sd\|coding` | Full mock interview. Stays in character; debrief only at end. |
| `/concept` | `<topic>` | Scaffolds a concept note with interview Qs. **Refuses to write substance**. |
| `/company` | `<name>` | Bootstraps a Company_Research note from public info. |
| `/weekly-review` | _(no arg)_ | Guided Sunday review walk-through. |

Files: `.claude/commands/*.md`

### Global agents (work anywhere via `@`-mention or "use the X agent")

| Agent | What it does |
|---|---|
| `@interviewer` | Hard-mode Staff interviewer. Modes: `behavioral`, `sd`. Refuses coding (points at `/algo`). |
| `@star-critic` | Read-only Staff-bar critique. Same 7-axis rubric as `/star-critique` plus cross-portfolio check. |

Files: `~/.claude/agents/interviewer.md`, `~/.claude/agents/star-critic.md`

### Commands vs agents — which to use?

- **Inside the vault, for vault-aware workflows**: use `/commands`. They know about your file structure and save outputs where they belong.
- **Outside the vault** (e.g., on the SDK code repo, or anywhere else): use `@agents`. They're standalone personas without vault-specific assumptions.
- **Inside the vault but want raw persona behavior**: use `@agents`. They'll still work.

### Decision tree

```
What are you about to do?

├── Open daily note and start studying              → Templater (don't involve Claude)
├── Solve a new algorithm                           → /algo <problem>
├── Make sense of a topic you just read about       → /concept <topic>
├── Write a new STAR story                          → /star <story-key>
├── Pressure-test a STAR draft you already wrote    → /star-critique <file>
├── Practice system design                          → /system-design <topic>
├── Practice a behavioral round                     → /mock behavioral
├── Practice a coding round                         → /mock coding
├── Research a target company                       → /company <name>
├── Sunday review                                   → /weekly-review
├── Mock from outside the vault                     → @interviewer / @star-critic
└── Want Claude to do the substance for you         → Don't. Push back at yourself.
```

---

## Workflows

### Daily (5 min + 60–90 min study)

1. Open today's daily note in Obsidian. Templater fills date + skeleton.
2. Set `Foco del día` and `Horas planeadas`.
3. `cd ~/Projects/career-vault && claude` — opens Claude with vault context.
4. Pick ONE study activity:
   - `/algo <NeetCode problem>` — Socratic coach
   - `/concept <topic>` — scaffold and fill
   - `/star <story-key>` — draft a STAR
   - Or just work in Obsidian, use Claude as explainer.
5. After the session, fill in the daily note in Obsidian:
   - `Qué aprendí`
   - `Notas nuevas creadas` (Claude already saved them in the right folder)
   - `- Horas reales: N` — **this is what the statusline reads**
   - `Mañana`
6. Close Claude.

Next day's status line will show cumulative hours.

### Sunday weekly review (15 min)

```
You open Claude in the vault. SessionStart prints:
  Career vault — Sun May 24
  Plan: Q1 · Week 2/52 · 5.5h/7h this week
  Sunday — weekly review pending. Run /weekly-review.

You: /weekly-review
Claude:
  - Scans daily notes from the week
  - Summarizes hours, learnings, blockers
  - Walks the Weekly_Review template
  - Processes 00_Inbox/ items together with you
  - Saves to 02_Daily/<YYYY-Www>.md
  - Closes with honest on-track / borderline / off-track verdict
```

If you skip Sunday → the nudge is gone Monday. Don't try to "make up" missed weeks. Master plan rule.

### Monthly review (last Sunday of month, 30 min)

SessionStart prints: `Last Sunday of May — monthly review window.`

There's no `/monthly-review` command yet. Open `99_Templates/Monthly_Review.md` in Obsidian and fill it. Use Dataview queries for metrics if you've installed the plugin.

To add a `/monthly-review` command later: copy `.claude/commands/weekly-review.md`, adjust scope to a month, save as `monthly-review.md`. ~10 min of work.

### Quarterly review (end of Q, 1h)

Same pattern as monthly. Open `99_Templates/Quarterly_Review.md`. The honest question is whether you hit the Q's hito. If not — master plan rule says **stop and replan**, don't self-deceive.

### Mock interview cadence

Per master plan, mocks are a Q4 focus block (20h budget). But the agents work now — test them in Q1 to debug your setup and to identify weak signal slots early.

```
Inside vault:           /mock behavioral
Outside vault:          @interviewer behavioral
System design mock:     /mock sd "real-user monitoring"
Coding mock:            /mock coding   (or use /algo for solo practice)
```

Stays in character. Only debriefs at the end. Saves to `06_Interviews/<type>/Mock_<YYYY-MM-DD>.md`.

### STAR drafting loop

```
1. You: /star Convince_Team_Of_X
   Claude interrogates, demands "I" actions and a metric.
   Saves to 06_Interviews/Behavioral/STAR_Convince_Team_Of_X.md.
   Checks the box in 00_STAR_Master_List.md.

2. (Days later) You: /star-critique 06_Interviews/Behavioral/STAR_Convince_Team_Of_X.md
   Claude scores it 0–21 across 7 axes. Gives top-3 fixes.

3. You revise.

4. /star-critique again.
```

Thresholds (calibrated by the agent):
- **8–13**: first-draft territory. Expected.
- **15–17**: mock-ready.
- **18+**: interview-ready.
- **Below 8 or scope=0**: rewrite or replace.

---

## What Claude refuses (by design)

Don't fight these. They encode the master plan's discipline.

| You ask | Claude responds |
|---|---|
| "Just tell me the algorithm" mid-`/algo` | *"If I tell you, you don't get the rep. Try one more nudge."* |
| "Write the concept of generics for me" | *"That's reading-not-learning. Want a Socratic Q&A instead?"* |
| "Be nicer in `/star-critique`" | *"No — honest calibration is the value."* |
| "Reorganize my folders" (no real trigger) | *"Is this avoidance? You self-flagged vault-polishing."* |
| "Give me a hint" mid-`/mock` | *"Not in a mock. Keep going; we'll review at debrief."* |
| "Help me apply to Datadog now" (pre-Q4) | *"Per your plan, applications are Q4. What's the actual trigger?"* |
| "Fabricate a number for this STAR" | *"No. Estimate honestly or leave it qualitative."* |
| "Coding mock please" via `@interviewer` | *"Coding mocks go through `/algo` — different mechanics."* |

To override genuinely: say so explicitly. *"I know this looks like polishing, but I genuinely need to move folder X because of Y."* Claude will check whether it's the trap or a real call.

---

## What the automation does NOT do

- **Doesn't open daily notes.** That stays in Obsidian + Templater.
- **Doesn't track hours unless you write them.** No telemetry. `- Horas reales: N` in the daily note is the source of truth.
- **Doesn't remind you outside Claude sessions.** No system-level nudges. If you don't open Claude on Sunday, the weekly nudge is silent. Use a phone alarm if you need that.
- **Doesn't apply to companies, send emails, or do anything stateful.** Everything is local files.
- **Doesn't auto-link notes to MOCs.** You add them when you write the note (or via Dataview if you set it up).
- **Doesn't enforce the boxing routine.** That's on you.

---

## File map

```
~/Projects/career-vault/
├── CLAUDE.md                          ← project instructions for Claude (vault mode)
├── CLAUDE_USAGE.md                    ← this file
├── README.md                          ← vault README (the original rules)
├── .claude/
│   ├── settings.json                  ← overrides statusline + registers hook
│   ├── statusline.sh                  ← status line (Q-phase, week, hours)
│   ├── hooks/
│   │   └── session-start.sh           ← SessionStart hook
│   └── commands/                      ← project slash commands
│       ├── algo.md
│       ├── company.md
│       ├── concept.md
│       ├── mock.md
│       ├── star.md
│       ├── star-critique.md
│       ├── system-design.md
│       └── weekly-review.md
├── 00_Inbox/                          ← capture, processed weekly
├── 01_Plan/                           ← master + Q plans
├── 02_Daily/                          ← daily and weekly notes
├── 03_Concepts/                       ← atomic notes by domain
├── 04_Project/                        ← web vitals SDK architecture/ADRs
├── 05_Books/                          ← book notes
├── 06_Interviews/                     ← STAR, companies, system design, mocks
└── 99_Templates/                      ← Templater templates

~/.claude/
├── agents/
│   ├── interviewer.md                 ← global interviewer agent
│   └── star-critic.md                 ← global STAR critic agent
└── projects/-Users-73nko-Projects-career-vault/memory/
    ├── MEMORY.md                      ← memory index (always loaded)
    ├── user_profile.md
    └── project_vault.md
```

---

## Tuning knobs

| What | File | What to change |
|---|---|---|
| Plan start date | `.claude/statusline.sh` and `.claude/hooks/session-start.sh` | `PLAN_START="YYYY-MM-DD"` (Monday of week 1) |
| Weekly target hours | same two files | `WEEKLY_TARGET=7` |
| Q boundaries | same two files | Currently Q1=weeks 1–12, Q2=13–24, etc. |
| What a command does | `.claude/commands/<name>.md` | Edit the markdown — Claude reads it fresh each invocation. |
| Agent persona | `~/.claude/agents/<name>.md` | Edit the markdown. |
| Color rules for hours | `.claude/statusline.sh` | `hours_color` block. |
| Disable a nudge | `.claude/hooks/session-start.sh` | Comment out the relevant `echo`. |
| Vault-wide behavior rule | `CLAUDE.md` at vault root | Edit directly. |

After editing `.claude/settings.json` or hook/statusline scripts, exit and reopen Claude.

---

## Troubleshooting

| Symptom | Check |
|---|---|
| Status line is the generic one (no Q/week/hours) | `cat .claude/settings.json` exists; reopen Claude. |
| Hours always 0 | Daily notes have lines like `- Horas reales: 1.5` (exact prefix, decimal number). |
| Week number wrong | `PLAN_START` in scripts matches your actual Monday of week 1. |
| SessionStart hook didn't fire | `bash -n .claude/hooks/session-start.sh` for syntax. Script executable (`chmod +x`). |
| `/algo` doesn't recognize the problem | Pass it as the argument: `/algo Two Sum`. |
| `@interviewer` doesn't dispatch | Type explicitly: *"Use the interviewer agent to run a behavioral mock."* |
| Memory not loaded | Check `~/.claude/projects/-Users-73nko-Projects-career-vault/memory/MEMORY.md` exists. |
| Claude is treating the vault like code (TDD-talk, etc.) | `CLAUDE.md` at vault root may have been deleted or moved. |

To manually run the hook to see what it would output:
```
bash ~/Projects/career-vault/.claude/hooks/session-start.sh
```

To manually run the statusline with a fake input:
```
echo '{"workspace":{"current_dir":"/Users/73nko/Projects/career-vault"},"model":{"display_name":"Opus 4.7"},"context_window":{"used_percentage":12}}' | bash ~/Projects/career-vault/.claude/statusline.sh
```

---

## Extending the setup

### Add a new slash command

Create `.claude/commands/<name>.md`:

```markdown
---
name: <name>
description: One-line description.
model: inherit
---

Your instructions. Use ${1} for the user's argument.
```

Available immediately. No restart needed.

### Add a new agent

Create `~/.claude/agents/<name>.md` with frontmatter (see existing examples for fields). Restart Claude if it doesn't pick it up.

### Add a new memory

Just ask: *"Remember that [fact]."* Claude writes it to `~/.claude/projects/-Users-73nko-Projects-career-vault/memory/`.

Or write directly with the frontmatter format documented in `~/.claude/CLAUDE.md` (the global instructions describe the memory format).

### Add a new MOC entry

When you create a concept note via `/concept`, Claude tries to link it into the appropriate `00_MOC_<Domain>.md`. If you create one manually, edit the MOC yourself — there's no automation for this on purpose (auto-linking became fragile in early tests).

---

## Useful Claude Code built-ins

Beyond the custom commands above:

| Command | Use |
|---|---|
| `/memory` | View or edit project memory |
| `/clear` | Start a fresh conversation (clears context) |
| `/help` | List all built-in commands |
| `/agents` | List available agents and their descriptions |
| `/plugin` | Manage plugins |
| `! <shell-command>` | Run a shell command inline; output lands in conversation |
| `@<file-path>` | Reference a file by path (Claude reads it) |
| `claude -p "..."` | One-shot non-interactive query from terminal |

---

## First-week checklist (after setup)

- [ ] Confirm status line shows `Q1 W<N>` when you open Claude in the vault.
- [ ] Fill `- Horas reales: N` in today's daily note, restart Claude, verify hours update.
- [ ] Run `/algo Two Sum` (you have it already) — should refuse to give the solution, then engage Socratically.
- [ ] Run `/concept Generics` — should scaffold a stub, refuse to fill substance, save to `03_Concepts/TypeScript/Generics.md`.
- [ ] Run `/star <some_pool_story>` — drafts a story. Then run `/star-critique` on it. Score should be low (8–13 is normal for first drafts).
- [ ] Run `/mock behavioral` once — even if you're not "ready". Identifies signal gaps early.
- [ ] On Sunday: run `/weekly-review`. Even if the week was quiet.

If any step doesn't behave as described, see Troubleshooting.

---

## Anti-patterns to watch for in yourself

The configuration tries to catch these. You should also.

1. **Spending time on the vault config instead of studying.** If you're editing `.claude/` more than once a month and you're not in a critical block, you're polishing. Stop.
2. **Asking Claude to do the substance.** `/concept` refusing to fill content is a feature, not a bug. The rep is in your fingers, not in the prompt.
3. **Soft-grading your STARs.** If `/star-critique` scores low and your instinct is to ask for a softer rubric — that's the wrong move. Rewrite the story.
4. **Skipping the weekly review.** It's 15 minutes. It's the highest-leverage 15 minutes of the week.
5. **Inflating hours.** `- Horas reales: 4` when you actually did 2.5 buys you a yellow→green status line and a wrong picture of the plan. The whole system collapses on dishonest inputs.
6. **Applying before Q4.** If a recruiter cold-messages, fine. But proactively applying before the Q4 prep block is documented self-sabotage per your master plan.
7. **Reading about a topic and not writing/practicing.** *"Confundir 'leer sobre algo' con 'aprenderlo'."* The fix is `/concept` (write it down), `/algo` (apply it), or `/star` (turn experience into a story). Never just read.

---

## When to revisit this document

- After Q1 retrospective — does the tooling fit how you actually worked?
- If you add a new command or agent.
- If a workflow keeps breaking.
- When you onboard another person to your setup (e.g., you start mentoring someone doing the same prep).

If you find yourself updating this document weekly — that's polishing. Update at meaningful inflection points only.

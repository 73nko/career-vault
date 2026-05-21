#!/bin/sh
# Career vault SessionStart hook.
# Prints a short status block (plan phase, week, hours, daily note status,
# review nudges) that Claude picks up as additional context for the session.
# Plain text only — this output is consumed as context, not rendered in a
# terminal, so no ANSI codes.

VAULT="/Users/73nko/Projects/career-vault"
PLAN_START="2026-05-11"
WEEKLY_TARGET=7

today=$(date "+%Y-%m-%d")
today_h=$(date "+%a %b %-d")
dow=$(date +%u)   # 1=Mon, 7=Sun

# Plan phase + week number
plan_start_epoch=$(date -j -f "%Y-%m-%d" "$PLAN_START" +%s 2>/dev/null)
today_epoch=$(date "+%s")
days_since=$(( (today_epoch - plan_start_epoch) / 86400 ))
if [ "$days_since" -lt 0 ]; then
  week_num=0
  q="pre-plan"
else
  week_num=$(( days_since / 7 + 1 ))
  if   [ "$week_num" -le 12 ]; then q="Q1"
  elif [ "$week_num" -le 24 ]; then q="Q2"
  elif [ "$week_num" -le 36 ]; then q="Q3"
  elif [ "$week_num" -le 48 ]; then q="Q4"
  else q="post-plan"
  fi
fi

# Hours this ISO week
offset=$((dow - 1))
mon=$(date -j -v-"${offset}"d "+%Y-%m-%d")

hours=0
i=0
while [ "$i" -lt 7 ]; do
  d=$(date -j -f "%Y-%m-%d" -v+"${i}"d "$mon" "+%Y-%m-%d" 2>/dev/null)
  f="$VAULT/02_Daily/$d.md"
  if [ -f "$f" ]; then
    h=$(grep -E '^- Horas reales:' "$f" | head -1 \
        | sed -E 's/^- Horas reales: *//' | tr -d ' h')
    if [ -n "$h" ] && echo "$h" | grep -qE '^[0-9]+\.?[0-9]*$'; then
      hours=$(awk "BEGIN {print $hours + $h}")
    fi
  fi
  i=$((i + 1))
done

# Daily note status
today_note="$VAULT/02_Daily/$today.md"
if [ -f "$today_note" ]; then
  daily_status="exists"
else
  daily_status="MISSING — create $today.md before the session"
fi

# Weekly review status (ISO week)
iso_year=$(date "+%G")
iso_week=$(date "+%V")
weekly_file="$VAULT/02_Daily/Weekly/${iso_year}-W${iso_week}.md"
weekly_alt="$VAULT/02_Daily/${iso_year}-W${iso_week}.md"
weekly_done=""
{ [ -f "$weekly_file" ] || [ -f "$weekly_alt" ]; } && weekly_done="yes"

# Monthly review check — is today the last Sunday of the month?
last_sunday="no"
if [ "$dow" -eq 7 ]; then
  next_sun_mon=$(date -j -v+7d "+%m")
  this_mon=$(date "+%m")
  [ "$next_sun_mon" != "$this_mon" ] && last_sunday="yes"
fi

# Output
echo "Career vault — $today_h"
echo "Plan: $q · Week $week_num/52 · ${hours}h/${WEEKLY_TARGET}h this week"
echo "Daily note: $daily_status"

# Nudges
if [ "$dow" -eq 7 ] && [ -z "$weekly_done" ]; then
  echo "Sunday — weekly review pending. Run /weekly-review."
fi
if [ "$last_sunday" = "yes" ]; then
  echo "Last Sunday of $(date "+%B") — monthly review window."
fi

# Hours warning if mid-late week and well below target
if [ "$dow" -ge 5 ]; then
  if awk "BEGIN {exit !($hours < $WEEKLY_TARGET / 2)}"; then
    echo "Hours behind target — ${hours}h logged with ${dow} days into the week."
  fi
fi

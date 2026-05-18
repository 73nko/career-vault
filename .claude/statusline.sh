#!/bin/sh
# Career vault status line.
# Extends the global statusline with Q-phase + week-of-plan + hours-this-week.
# Hours are summed from the "- Horas reales:" line in each daily note for the
# current ISO week (Mon–Sun).

VAULT="/Users/73nko/Projects/career-vault"
PLAN_START="2026-05-11"   # Monday of plan week 1
WEEKLY_TARGET=7

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

home="$HOME"
short_cwd="${cwd/#$home/\~}"

branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
fi

# Plan phase + week number
plan_start_epoch=$(date -j -f "%Y-%m-%d" "$PLAN_START" +%s 2>/dev/null)
today_epoch=$(date "+%s")
days_since=$(( (today_epoch - plan_start_epoch) / 86400 ))
if [ "$days_since" -lt 0 ]; then
  week_num=0
  q="pre"
else
  week_num=$(( days_since / 7 + 1 ))
  if   [ "$week_num" -le 12 ]; then q="Q1"
  elif [ "$week_num" -le 24 ]; then q="Q2"
  elif [ "$week_num" -le 36 ]; then q="Q3"
  elif [ "$week_num" -le 48 ]; then q="Q4"
  else q="post"
  fi
fi

# Hours this ISO week (Mon–Sun)
dow=$(date +%u)
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

# Color hours yellow if below half target, green if on track, magenta if over
hours_color="33"  # yellow default
half=$(awk "BEGIN {print $WEEKLY_TARGET / 2}")
if   awk "BEGIN {exit !($hours >= $WEEKLY_TARGET)}"; then hours_color="35"   # magenta (over)
elif awk "BEGIN {exit !($hours >= $half)}";          then hours_color="32"   # green (on track)
fi

# Build output
printf '\033[34m%s\033[0m' "$short_cwd"
[ -n "$branch" ] && printf ' \033[35m(%s)\033[0m' "$branch"
[ -n "$model" ]  && printf ' \033[36m%s\033[0m' "$model"
printf ' \033[32m%s W%d\033[0m' "$q" "$week_num"
printf " \033[${hours_color}m%sh/%sh\033[0m" "$hours" "$WEEKLY_TARGET"
[ -n "$used" ] && printf ' \033[33mctx:%s%%\033[0m' "$(printf '%.0f' "$used")"

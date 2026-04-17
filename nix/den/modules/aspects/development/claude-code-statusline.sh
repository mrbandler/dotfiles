#!/usr/bin/env bash
# Claude Code status line — Starship-inspired sentence style

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // .model.id')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_create=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')

# Shorten home directory to ~
home_dir="$HOME"
display_dir="${cwd/#$home_dir/\~}"

# Git branch (skip optional locks to avoid stalling)
git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree --quiet >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" -c core.fsync=none symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$cwd" -c core.fsync=none rev-parse --short HEAD 2>/dev/null)
fi

# Build sentence-style status line
result=""

# Model (lead) - bold italic red, like bash indicator in starship
result+="$(printf '\033[1;3;31m%s\033[0m' "$model")"

# Directory - bold cyan/teal (green-blueish like starship)
result+="$(printf ' \033[2min\033[0m \033[1;36m%s\033[0m' "$display_dir")"

# Git branch + status - bold magenta (matches starship)
if [ -n "$git_branch" ]; then
  # Collect status markers (like starship's git_status module)
  git_status=$(git -C "$cwd" -c core.fsync=none status --porcelain=v1 2>/dev/null)
  markers=()
  # Starship default git_status order: conflicted, deleted, renamed, modified, staged, untracked, ahead/behind, stashed
  # Deleted
  if echo "$git_status" | grep -q '^.D\|^D'; then markers+=("\xe2\x9c\x98"); fi
  # Renamed
  if echo "$git_status" | grep -q '^R'; then markers+=("\xc2\xbb"); fi
  # Modified (!)
  if echo "$git_status" | grep -q '^.[MD]'; then markers+=("!"); fi
  # Staged (+)
  if echo "$git_status" | grep -q '^[MADRC]'; then markers+=("+"); fi
  # Untracked (?)
  if echo "$git_status" | grep -q '^??'; then markers+=("?"); fi
  # Ahead/behind
  ahead_behind=$(git -C "$cwd" -c core.fsync=none rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
  if [ -n "$ahead_behind" ]; then
    ahead=$(echo "$ahead_behind" | cut -f1)
    behind=$(echo "$ahead_behind" | cut -f2)
    if [ "$ahead" -gt 0 ] 2>/dev/null; then markers+=("\xe2\x87\xa1"); fi
    if [ "$behind" -gt 0 ] 2>/dev/null; then markers+=("\xe2\x87\xa3"); fi
  fi
  # Stashed ($)
  if git -C "$cwd" -c core.fsync=none rev-parse --verify refs/stash >/dev/null 2>&1; then
    markers+=('$')
  fi

  branch_str="$git_branch"
  if [ ${#markers[@]} -gt 0 ]; then
    joined=""
    for m in "${markers[@]}"; do joined+="$m"; done
    branch_str+=$(printf " [%b]" "$joined")
  fi
  result+="$(printf ' \033[2mon\033[0m \033[1;35m%s\033[0m' " $branch_str")"
fi

# Context usage with progress bar
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  # Pick colors based on usage
  if [ "$used_int" -ge 80 ]; then
    fg_filled='\033[30m'; bg_filled='\033[41m'    # black on red bg
    fg_empty='\033[31m'; bg_empty='\033[100m'     # red on dark gray
  elif [ "$used_int" -ge 50 ]; then
    fg_filled='\033[30m'; bg_filled='\033[43m'    # black on yellow bg
    fg_empty='\033[33m'; bg_empty='\033[100m'     # yellow on dark gray
  else
    fg_filled='\033[30m'; bg_filled='\033[42m'    # black on green bg
    fg_empty='\033[32m'; bg_empty='\033[100m'     # green on dark gray
  fi
  # Calculate used tokens (input + cache)
  used_tokens=$(( input_tokens + cache_create + cache_read ))
  # Format token count with best unit (k or m)
  if [ "$used_tokens" -ge 1000000 ] 2>/dev/null; then
    used_str="$(awk "BEGIN{printf \"%.1fm\", $used_tokens/1000000}")"
  else
    used_str="$(( used_tokens / 1000 ))k"
  fi
  # Format context size with best unit
  if [ -n "$ctx_size" ] && [ "$ctx_size" -gt 0 ] 2>/dev/null; then
    if [ "$ctx_size" -ge 1000000 ]; then
      total_str="$(awk "BEGIN{v=$ctx_size/1000000; if(v==int(v)) printf \"%dm\",v; else printf \"%.1fm\",v}")"
    else
      total_str="$(( ctx_size / 1000 ))k"
    fi
    token_str="${used_str}/${total_str}"
  else
    token_str="${used_str}"
  fi
  # Build label and center it in the bar
  label=" ${token_str} (${used_int}%) "
  label_len=${#label}
  bar_width=$(( label_len > 16 ? label_len : 16 ))
  # Pad label to bar_width
  padding=$(( bar_width - label_len ))
  pad_left=$(( padding / 2 ))
  pad_right=$(( padding - pad_left ))
  padded_label="$(printf '%*s' "$pad_left" '')${label}$(printf '%*s' "$pad_right" '')"
  # Split at fill boundary and render with background colors
  filled=$(( used_int * bar_width / 100 ))
  if [ "$filled" -eq 0 ] && [ "$used_int" -gt 0 ]; then filled=1; fi
  filled_text="${padded_label:0:$filled}"
  empty_text="${padded_label:$filled}"
  bar="$(printf "${fg_filled}${bg_filled}%s\033[0m${fg_empty}${bg_empty}%s\033[0m" "$filled_text" "$empty_text")"
  result+="$(printf ' \033[2mwith context\033[0m %s' "$bar")"
fi

printf '%s' "$result"

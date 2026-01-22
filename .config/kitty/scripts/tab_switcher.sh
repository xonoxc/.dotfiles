#!/usr/bin/env bash
set -eu

# Must be inside kitty
[ "$TERM" != "xterm-kitty" ] && exit 0

# Get kitty state once (important for consistency)
state=$(kitty @ ls)

# Focused OS window ID
current_window_id=$(echo "$state" | jq -r '.[] | select(.is_focused) | .id')

# Focused tab ID inside that window
current_tab_id=$(echo "$state" | jq -r '
  .[]
  | select(.is_focused)
  | .tabs[]
  | select(.is_focused)
  | .id
')

# Collect all OTHER tabs
tabs=$(echo "$state" | jq -r \
  --arg win "$current_window_id" \
  --arg cur "$current_tab_id" '
  .[]
  | select(.id == ($win | tonumber))
  | .tabs[]
  | select(.id != ($cur | tonumber))
  | "\(.id)\t\(.title // "untitled")"
')

# Nothing to switch to
[ -z "$tabs" ] && exit 0

selected=$(echo "$tabs" | fzf \
  --prompt="kitty tab > " \
  --delimiter="\t" \
  --with-nth=2 \
  --reverse \
  --height=40% \
  --border)

[ -z "$selected" ] && exit 0

tab_id=$(echo "$selected" | cut -f1)

kitty @ focus-tab --match id:$tab_id

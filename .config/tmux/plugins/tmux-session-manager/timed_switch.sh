#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

MARKER() { echo "[TIME] $1 = $(($(date +%s%N)/1000000))ms (rel: $(($(($(date +%s%N)/1000000) - START)))ms" >&2); }
START=$(date +%s%N)
MARKER "after source common_utils"

local current
current="$(tmux display-message -p "#{session_name}")"
MARKER "after display-message current"

tmux list-sessions -F "#{session_name}" 2>/dev/null \
    | while IFS= read -r session; do
        [[ "$session" != "$current" ]] && echo "$session"
    done > /tmp/sessions_out.txt
MARKER "after list-sessions + loop"

sort /tmp/sessions_out.txt | uniq > /tmp/sessions_sorted.txt
MARKER "after sort|uniq"

echo "[TIME] sessions count: $(wc -l < /tmp/sessions_sorted.txt)" >&2

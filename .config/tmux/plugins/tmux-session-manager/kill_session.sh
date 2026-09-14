#!/usr/bin/env bash
# kill_session.sh — kill a running tmux session only (no persistence file deletion)
# Usage: bash kill_session.sh
#
# If there are other sessions running, switch to one of them first so the user
# isn't dropped.  If it's the last session, just kill it directly — no guard.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

# ANSI color codes
BLUE_FG=$'\e[38;2;119;151;183m'    # #7797b7
GRAY_FG=$'\e[38;2;192;192;192m'     # #c0c0c0 — visible gray for current-session marker
GREEN_FG=$'\e[38;2;138;172;139m'    # #8aac8b
RESET=$'\e[0m'

RUN_ICON="󰛦"

# Build the list of all running sessions, current session first and marked
get_running_sessions() {
	local current
	current="$(tmux display-message -p "#{session_name}")"
	tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| while IFS= read -r session; do
			if [[ "$session" == "$current" ]]; then
				echo "${RUN_ICON} ${GRAY_FG}${session} (current)${RESET}"
			else
				echo "${RUN_ICON} ${BLUE_FG}${session}${RESET}"
			fi
		done
}

# Ask the user to pick
if ! selected=$(select_session "$(get_running_sessions)"); then
	exit 0
fi

# Strip decorations
selected_clean="$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')"
selected_clean="${selected_clean#$RUN_ICON }"
selected_clean="${selected_clean%% (current)}"

if [[ -z "$selected_clean" ]]; then
	tmux display-message -d0 "#[bg=red]Invalid selection."
	exit 1
fi

current="$(tmux display-message -p "#{session_name}")"

# If there are other sessions running, switch away from current first
if [[ "$selected_clean" == "$current" ]]; then
	other="$(tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| grep -v "^${selected_clean}$" \
		| head -n1 || true)"
	if [[ -n "$other" ]] && tmux has-session -t "$other" 2>/dev/null; then
		tmux switch-client -t "$other"
		sleep 0.2
	fi
	# Clean up stale default session "0" tmux may create on switch
	tmux has-session -t 0 2>/dev/null && \
		[[ "$(tmux display-message -p -t 0 '#{session_attached}')" == "0" ]] && \
		tmux kill-session -t 0 2>/dev/null || true
fi

# Kill the target session — no guard, no pre-flight beyond the switch above
if tmux has-session -t "$selected_clean" 2>/dev/null; then
	tmux kill-session -t "$selected_clean"
	tmux display-message "Session '$selected_clean' killed"
else
	tmux display-message "Session '$selected_clean' is not running"
fi

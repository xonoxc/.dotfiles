#!/usr/bin/env bash
# switch_session.sh — search and switch between active tmux sessions
# Usage: bash switch_session.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

PREVIOUS_SESSION_FILE="$SAVE_DIR/.previous_session"

# Build the list of active sessions (excluding the current one), with the
# previous session first so fzf defaults to it.
get_active_sessions() {
	local current previous
	current="$(tmux display-message -p "#{session_name}")"
	previous=""
	[[ -f "$PREVIOUS_SESSION_FILE" ]] && previous="$(cat "$PREVIOUS_SESSION_FILE")"

	# Previous session first (if it exists, isn't current, and still active)
	if [[ -n "$previous" && "$previous" != "$current" ]] && tmux has-session -t "$previous" 2>/dev/null; then
		echo "󰆧 $previous"
	fi

	# Remaining sessions in alphabetical order
	tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| sort \
		| while IFS= read -r session; do
			[[ "$session" != "$current" && "$session" != "$previous" ]] && echo "󰆧 $session"
		done
}

# Save the current session as the previous session before switching
save_previous_session() {
	local current
	current="$(tmux display-message -p "#{session_name}")"
	echo "$current" > "$PREVIOUS_SESSION_FILE"
}

# Ask the user to pick a session (order preserved, no re-sort)
# fzf returns 1 on ESC/C-c — handle it gracefully instead of letting set -e kill us
if ! selected=$(select_session "$(get_active_sessions)" 1); then
	exit 0
fi

# Strip the leading icon
target_session="${selected#󰆧 }"

# Save current session as previous before switching
save_previous_session

# Switch to the selected session
if tmux has-session -t "$target_session" 2>/dev/null; then
	tmux switch-client -t "$target_session"
else
	tmux display-message "Session '$target_session' not found."
fi

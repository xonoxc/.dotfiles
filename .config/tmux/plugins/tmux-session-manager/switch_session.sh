#!/usr/bin/env bash
# switch_session.sh — search and switch between active tmux sessions
# Usage: bash switch_session.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

# Build the list of active sessions (excluding the current one)
get_active_sessions() {
	local current
	current="$(tmux display-message -p "#{session_name}")"
	tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| while IFS= read -r session; do
			[[ "$session" != "$current" ]] && echo "󰛦 $session"
		done
}

# Ask the user to pick a session
selected=$(select_session "$(get_active_sessions)")

# Exit cleanly if the user cancelled
if [[ -z "$selected" ]]; then
	exit 0
fi

# Strip the leading icon
target_session="${selected#󰛦 }"

# Switch to the selected session
if tmux has-session -t "$target_session" 2>/dev/null; then
	tmux switch-client -t "$target_session"
else
	tmux display-message "Session '$target_session' not found."
fi

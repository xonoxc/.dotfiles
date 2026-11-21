#!/usr/bin/env bash
# switch_to_last.sh — switch directly to the previous session without a dialog
# Usage: bash switch_to_last.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

PREVIOUS_SESSION_FILE="$SAVE_DIR/.previous_session"

if [[ ! -f "$PREVIOUS_SESSION_FILE" ]]; then
	tmux display-message "No previous session recorded."
	exit 0
fi

last_session="$(cat "$PREVIOUS_SESSION_FILE")"
if [[ -z "$last_session" ]]; then
	tmux display-message "No previous session recorded."
	exit 0
fi

if ! tmux has-session -t "$last_session" 2>/dev/null; then
	tmux display-message "Previous session '$last_session' no longer exists."
	exit 0
fi

# Save current session as previous before toggling
current_session="$(tmux display-message -p "#{session_name}")"
echo "$current_session" > "$PREVIOUS_SESSION_FILE"

tmux switch-client -t "$last_session"

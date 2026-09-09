#!/usr/bin/env bash
# delete_session.sh — delete running sessions, saved sessions, or groups
# Usage: bash delete_session.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

# ANSI color codes for terminal/fzf display
BLUE_FG=$'\e[38;2;119;151;183m'    # #7797b7 — matches tmux theme
RED_FG=$'\e[38;2;232;145;153m'      # #e89199 — for danger/warning
GREEN_FG=$'\e[38;2;138;172;139m'    # #8aac8b — accent green
RESET=$'\e[0m'

# Icons
SAVED_ICON=""       # saved sessions (on disk)
GROUP_ICON="󱃲"      # groups
RUN_ICON="󰛦"        # running sessions (big hexagon)

# Get all running tmux sessions (except current)
get_running_sessions() {
	local current
	current="$(tmux display-message -p "#{session_name}")"
	tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| while IFS= read -r session; do
			[[ "$session" != "$current" ]] && echo "${RUN_ICON} ${BLUE_FG}${session}${RESET}"
		done
}

# Get saved sessions (on disk) — unchanged icons
get_saved_sessions() {
	for file in "$SAVE_DIR"/*_last; do
		[[ -L "$file" || -f "$file" ]] || continue
		local name
		name=$(basename "${file%%_last}")
		echo "$SAVED_ICON $name"
	done
	for file in "$SAVE_DIR"/*_last_archived; do
		[[ -e "$file" ]] || continue
		local name
		name=$(basename "${file%%_last_archived}")
		echo "$SAVED_ICON $name"
	done
}

# Get groups
get_groups() {
	for group_dir in "$SAVE_DIR"/groups/*/; do
		[[ -d "$group_dir" ]] || continue
		local name count
		name=$(basename "$group_dir")
		count=$(wc -l < "$group_dir/index" 2>/dev/null || echo 0)
		echo "$GROUP_ICON $name ($count sessions)"
	done
}

# Delete a group
delete_group() {
	local group_dir="$1"
	local group_name
	group_name=$(basename "$group_dir")
	if [[ ! -d "$group_dir" ]]; then
		tmux display-message -d0 "#[bg=red]Group '$group_name' not found."
		return 1
	fi
	rm -rf "$group_dir"
	tmux display-message "Group '$group_name' deleted"
}

# Delete saved files for a session
delete_saved_files() {
	local session_name="$1"
	local escaped="${session_name//[*?[]/\\\\&}"
	rm -f "$SAVE_DIR/${session_name}_last" "$SAVE_DIR/${session_name}_last_archived"
	find "$SAVE_DIR" -maxdepth 1 -type f -name "${escaped}_????-??-??T??:??:??" -delete
}

# Check if a session is currently running
is_running() {
	local session_name="$1"
	tmux has-session -t "$session_name" 2>/dev/null
}

# Strip ANSI codes AND icons from a string (for matching)
strip_decorations() {
	local input="$1"
	# Remove ANSI escape sequences
	input=$(echo "$input" | sed 's/\x1b\[[0-9;]*m//g')
	# Remove known icons
	input="${input#$RUN_ICON }"
	input="${input#$SAVED_ICON }"
	input="${input#$GROUP_ICON }"
	echo "$input"
}

# Build the combined list
all_sessions="$(get_running_sessions)$(echo; get_saved_sessions)$(echo; get_groups)"

# Ask the user to pick
# fzf returns 1 on ESC/C-c — handle it gracefully instead of letting set -e kill us
if ! selected=$(select_session "$all_sessions"); then
	exit 0
fi

# Strip decorations for reliable matching and extraction
selected_clean=$(strip_decorations "$selected")

# Determine what was selected and act accordingly
if [[ "$selected" == *"$GROUP_ICON"* ]]; then
	# Group
	group_name="${selected_clean#$GROUP_ICON }"
	group_name="${group_name%% (*}"
	delete_group "$SAVE_DIR/groups/$group_name"

elif [[ "$selected" == *"$RUN_ICON"* ]]; then
	# Running session (hexagon icon present in raw selection)
	session_name="${selected_clean}"
	if is_running "$session_name"; then
		tmux kill-session -t "$session_name"
		delete_saved_files "$session_name"
		tmux display-message "Session '$session_name' killed and saved files deleted"
	else
		delete_saved_files "$session_name"
		tmux display-message "Session '$session_name' was not running. Saved files deleted."
	fi

elif [[ "$selected" == *"$SAVED_ICON"* ]]; then
	# Saved session — just delete the files
	session_name="${selected_clean}"
	delete_saved_files "$session_name"
	tmux display-message "Saved session '$session_name' deleted"

else
	tmux display-message -d0 "#[bg=red]Unknown selection."
	exit 1
fi

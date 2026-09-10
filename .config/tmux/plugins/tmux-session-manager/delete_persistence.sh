#!/usr/bin/env bash
# delete_persistence.sh — delete only the on-disk persistence files for a session
#                          (no tmux kill, session keeps running)
# Usage: bash delete_persistence.sh
#
# Shows saved sessions + groups on disk (running sessions are handled by the
# kill popup instead).  Switches away from current session first so the flow
# is never interrupted.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common_utils.sh"

# ANSI color codes
BLUE_FG=$'\e[38;2;119;151;183m'    # #7797b7 — matches tmux theme
GREEN_FG=$'\e[38;2;138;172;139m'    # #8aac8b — accent green
RESET=$'\e[0m'

# Icons
SAVED_ICON=""       # saved sessions (on disk)
GROUP_ICON="󱃲"      # groups

# ---------------------------------------------------------------------------
# List builders
# ---------------------------------------------------------------------------

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

get_groups() {
	for group_dir in "$SAVE_DIR"/groups/*/; do
		[[ -d "$group_dir" ]] || continue
		local name count
		name=$(basename "$group_dir")
		count=$(wc -l < "$group_dir/index" 2>/dev/null || echo 0)
		echo "$GROUP_ICON $name ($count sessions)"
	done
}

# ---------------------------------------------------------------------------
# File deletion (no tmux interaction)
# ---------------------------------------------------------------------------

delete_saved_files() {
	local session_name="$1"
	local escaped="${session_name//[*?[]/\\\\&}"
	rm -f "$SAVE_DIR/${session_name}_last" "$SAVE_DIR/${session_name}_last_archived"
	find "$SAVE_DIR" -maxdepth 1 -type f -name "${escaped}_????-??-??T??:??:??" -delete 2>/dev/null || true
}

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

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

# Build the combined list (saved sessions + groups only — no running sessions)
all_sessions="$(get_saved_sessions)$(echo; get_groups)"

if ! selected=$(select_session "$all_sessions"); then
	exit 0
fi

# Strip ANSI codes and icons for reliable matching
selected_clean="$(echo "$selected" | sed 's/\x1b\[[0-9;]*m//g')"
selected_clean="${selected_clean#$SAVED_ICON }"
selected_clean="${selected_clean#$GROUP_ICON }"
selected_clean="$(echo "$selected_clean" | xargs)"

if [[ -z "$selected_clean" ]]; then
	tmux display-message -d0 "#[bg=red]Invalid selection."
	exit 1
fi

current="$(tmux display-message -p "#{session_name}")"

# ── Group ───────────────────────────────────────────────────────────────────
if [[ "$selected" == *"$GROUP_ICON"* ]]; then
	delete_group "$SAVE_DIR/groups/$selected_clean"
	exit 0
fi

# ── Saved session ───────────────────────────────────────────────────────────
session_name="$selected_clean"

# If the current session is selected, switch away first (never kick the user)
if [[ "$session_name" == "$current" ]]; then
	other="$(tmux list-sessions -F "#{session_name}" 2>/dev/null \
		| grep -v "^${session_name}$" \
		| head -n1)"
	if [[ -n "$other" ]] && tmux has-session -t "$other" 2>/dev/null; then
		tmux switch-client -t "$other"
		sleep 0.2
		# Clean up any stale default session "0" tmux may create
		tmux has-session -t 0 2>/dev/null && \
			[[ "$(tmux display-message -p -t 0 '#{session_attached}')" == "0" ]] && \
			tmux kill-session -t 0 2>/dev/null || true
	fi
fi

delete_saved_files "$session_name"
tmux display-message "Persistence files for '$session_name' deleted"

#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
source common_utils.sh

get_all_sessions() {
	for file in "$SAVE_DIR"/*_last; do
		[[ -L "$file" || -f "$file" ]] || continue
		local name
		name=$(basename "${file%%_last}")
		[[ "$name" != "$CURRENT_SESSION" ]] && echo " $name"
	done
}

get_archived_sessions() {
	for file in "$SAVE_DIR/"*_last_archived; do
		basename "${file%%_last_archived}"
	done
}

get_groups() {
	for group_dir in "$SAVE_DIR"/groups/*/; do
		[[ -d "$group_dir" ]] || continue
		local name count
		name=$(basename "$group_dir")
		count=$(wc -l < "$group_dir/index" 2>/dev/null || echo 0)
		echo "󱃲 $name ($count sessions)"
	done
}

# Checks if the first version is greater than the second
is_version_gt() {
	[[ "$(echo -e "$1\n$2" | sort -V | sed -n 2p)" != "$2" ]]
}

# Restore a single session from its save file.
# Usage: restore_session_from_file "$session_name" "$session_file" "$is_archived"
restore_session_from_file() {
	local session_name="$1"
	local session_file="$2"
	local is_archived="${3:-0}"

	if [[ "$is_archived" == "1" ]]; then
		mv "${session_file}_archived" "$session_file"
	fi

	if [[ ! -f "$session_file" ]]; then
		tmux display-message -d0 "#[bg=red]Session file not found."
		return 1
	fi

	local file_version
	file_version="$(head -n1 "$session_file" | cut -d"$SEPARATOR" -f2)"
	if is_version_gt "$file_version" "$VERSION"; then
		tmux display-message -d0 "#[bg=red]Error: File version is newer than the plugin's. Press ESC to quit."
		return 1
	fi

	start_spinner "Restoring session $session_name"
	local session_path="$HOME"
	if ! is_version_gt "1.1.0" "$file_version"; then
		session_path="$(sed -n '2p' "$session_file" | cut -d"$SEPARATOR" -f2)"
	fi
	tmux new-session -ds "$session_name" -c "$session_path"
	declare -A window_layouts
	declare active_window
	while read -r line; do
		case $line in
			window*)
				IFS=$SEPARATOR read -r _ window_index window_name window_layout window_active <<< "$line"
				window_id="$session_name:$window_index"
				tmux new-window -k -t "$window_id" -n "$window_name"
				window_layouts["$window_id"]="$window_layout"
				if [[ "$window_active" == "1" ]]; then
					active_window="$window_id"
				fi
			;;
			pane*)
				IFS=$SEPARATOR read -r _ pane_index pane_current_path pane_active window_index command <<< "$line"
				if [[ "$pane_index" == "$(get_tmux_option base-index 0)" ]]; then
					tmux send-keys -t "$session_name:$window_index" "cd \"$pane_current_path\"" Enter "clear" Enter
				else
					tmux split-window -d -t "$session_name:$window_index" -c "$pane_current_path"
				fi
				if [[ "$pane_active" == "1" ]]; then
					tmux select-pane -t "$session_name:$window_index.$pane_index"
				fi
				if [[ -n "$command" ]]; then
					tmux send-keys -t "$session_name:$window_index.$pane_index" "$command" Enter
				fi
			;;
		esac
	done < <(tail -n +3 "$session_file")
	for window in "${!window_layouts[@]}"; do
		tmux select-layout -t "$window" "${window_layouts[$window]}"
	done
	tmux select-window -t "$active_window"
	stop_spinner "Session restored"
	return 0
}

# Restore all sessions in a group.
# Usage: restore_group "$group_dir"
restore_group() {
	local group_dir="$1"

	if [[ ! -f "$group_dir/index" ]]; then
		tmux display-message -d0 "#[bg=red]Group index not found."
		return 1
	fi

	local first_session=""
	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		local session_file session_name_from_file

		if [[ "$line" == *" -> "* ]]; then
			# Legacy index format: "name_last -> /path/to/save_file"
			session_file="${line#* -> }"
			session_name_from_file="$(basename "${line%%_last*}")"
		else
			# Current index format: "name_<timestamp>"
			session_file="$group_dir/$line"
			session_name_from_file="${line%_*}"
		fi

		if [[ -z "$session_file" || -z "$session_name_from_file" ]]; then
			continue
		fi

		if tmux has-session -t "$session_name_from_file" 2>/dev/null; then
			first_session="${first_session:-$session_name_from_file}"
			continue
		fi

		if [[ ! -f "$session_file" ]]; then
			if [[ -f "$group_dir/${session_name_from_file}_last" ]]; then
				session_file="$group_dir/${session_name_from_file}_last"
			else
				continue
			fi
		fi

		restore_session_from_file "$session_name_from_file" "$session_file" 0
		first_session="${first_session:-$session_name_from_file}"
	done < "$group_dir/index"

	if [[ -n "$first_session" ]]; then
		tmux switch-client -t "$first_session"
	fi
	return 0
}

# Remove the stale tmux default session ("0") created at server start, but only
# if it is truly unused: no attached client, a single window/pane running an
# idle shell. Never touches a session the user is actually using.
remove_stale_default_session() {
	local stale="0"
	tmux has-session -t "$stale" 2>/dev/null || return 0
	[[ "$(tmux display-message -p -t "$stale" '#{session_attached}')" == "0" ]] || return 0
	[[ "$(tmux display-message -p -t "$stale" '#{session_windows}')" == "1" ]] || return 0
	[[ "$(tmux list-panes -t "$stale" -F '#{pane_id}' | wc -l)" == "1" ]] || return 0
	local pane_cmd
	pane_cmd="$(tmux display-message -p -t "$stale" '#{pane_current_command}')"
	case "$pane_cmd" in
		fish|bash|zsh|sh|dash) tmux kill-session -t "$stale" ;;
	esac
}

declare session_name
if [[ "$1" == "--archived" ]]; then
	# fzf returns 1 on ESC/C-c — handle it gracefully
	if ! session_name=$(select_session "$(get_archived_sessions)"); then
		exit 0
	fi
elif [[ "$1" == "--group" ]]; then
	if ! selected=$(select_session "$(get_groups)"); then
		exit 0
	fi
	group_name="${selected#󱃲 }"
	group_name="${group_name%% (*}"
	restore_group "$SAVE_DIR/groups/$group_name"
	rc=$?
	remove_stale_default_session
	exit $rc
else
	if ! selected=$(select_session "$(get_all_sessions)$(echo; get_groups)"); then
		exit 0
	fi
	if [[ "$selected" == 󱃲* ]]; then
		group_name="${selected#󱃲 }"
		group_name="${group_name%% (*}"
		restore_group "$SAVE_DIR/groups/$group_name"
		rc=$?
		remove_stale_default_session
		exit $rc
	fi
	session_name="${selected# }"
fi

if [[ -z "$session_name" ]]; then
	exit 0
fi

remove_stale_default_session
if ! tmux has-session -t "$session_name" 2> /dev/null; then
	session_file="$SAVE_DIR/${session_name}_last"
	is_archived=0
	[[ "$1" == "--archived" ]] && is_archived=1
	if [[ "$is_archived" == "1" ]]; then
		if [[ ! -f "${session_file}_archived" ]]; then
			tmux display-message -d0 "#[bg=red]Session file not found."
			exit 0
		fi
	else
		if [[ ! -f "$session_file" ]]; then
			tmux display-message -d0 "#[bg=red]Session file not found."
			exit 0
		fi
	fi
	restore_session_from_file "$session_name" "$session_file" "$is_archived"
fi
tmux switch-client -t "$session_name"
remove_stale_default_session

#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
source common_utils.sh

get_saved_sessions() {
	for file in "$SAVE_DIR"/*_last*; do
		if [[ "$file" =~ _last$ ]]; then
			echo " $(basename "${file%%_last}")"
		else
			echo " $(basename "${file%%_last_archived}")"
		fi
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

selected=$(select_session "$(get_saved_sessions)$(echo; get_groups)")
if [[ -z "$selected" ]]; then
	exit 0
fi

if [[ "$selected" == 󱃲* ]]; then
	group_name="${selected#󱃲 }"
	group_name="${group_name%% (*}"
	delete_group "$SAVE_DIR/groups/$group_name"
else
	session_name="${selected# }"
	escaped="${session_name//[*?[]/\\&}"
	start_spinner "Deleting session"
	rm -f "$SAVE_DIR/${session_name}_last" "$SAVE_DIR/${session_name}_last_archived"
	find "$SAVE_DIR" -maxdepth 1 -type f -name "${escaped}_????-??-??T??:??:??" -delete
	stop_spinner "Session deleted"
fi

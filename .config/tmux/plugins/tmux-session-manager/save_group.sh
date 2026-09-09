#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
source common_utils.sh

declare S=$SEPARATOR

# Save a session to a given file.
# Usage: save_session_to_file "$save_file" "$last_file" "$session_cwd" "$session_name"
save_session_to_file() {
	local save_file="$1"
	local last_file="$2"
	local session_cwd="$3"
	local session_name="$4"

	local WINDOW_FORMAT="window$S#{window_index}$S#{window_name}$S#{window_layout}$S#{window_active}"
	local PANE_FORMAT="pane$S#{pane_index}$S#{pane_current_path}$S#{pane_active}$S#{window_index}$S#{pane_pid}"

	echo "version$S$VERSION" > "$save_file"
	echo "$session_cwd" >> "$save_file"
	tmux list-windows -t "$session_name" -F "$WINDOW_FORMAT" >> "$save_file"
	tmux list-panes -s -t "$session_name" -F "$PANE_FORMAT" | while IFS="$SEPARATOR" read -r line; do
		pids=$(ps -ao "ppid,pid" \
			| sed "s/^ *//" \
			| grep "^$(cut -f6 <<< "$line")" \
			| rev \
			| cut -d' ' -f1 \
			| rev)
		command="$(for pid in $pids; do
			if [[ "$(grep ^ID= /etc/os-release | cut -d'=' -f2)" == "nixos" \
				&& "$(get_tmux_option "@session-manager-diable-nixos-nvim-check" "off")" != "on" \
				&& "$(cut -d' ' -f1 <<< "$(ps -p $pid -o cmd)" | tail +2 | xargs basename)" == "nvim" ]]; then
				echo -n "nvim"
				while read -r arg; do
					if [ -n "$arg" ]; then
						echo -n " '$arg'"
					fi
				done <<< "$(xargs -0L1 < /proc/$pid/cmdline | tail +8)"
			else
				while read -r arg; do
					echo -n "'$arg' "
				done <<< "$(xargs -0L1 < /proc/$pid/cmdline)"
			fi
		done)"
		awk -v command="$command" \
			'BEGIN {FS=OFS="\t"} {$6=command; print}'\
			<<< "$line" >> "$save_file"
	done
	if [[ -f "$last_file" ]] && cmp -s "$save_file" "$last_file"; then
		rm "$save_file"
	else
		ln -sf "$save_file" "$last_file"
	fi
}

group_name="${1:-}"
if [[ -z "$group_name" ]]; then
	exit 0
fi

group_dir="$SAVE_DIR/groups/$group_name"
if [[ -f "$group_dir/index" ]]; then
	tmux display-message -d0 "#[bg=yellow]Group '$group_name' already exists. Not overwriting."
	exit 0
fi

mkdir -p "$group_dir"
timestamp=$(date +"%Y-%m-%dT%H:%M:%S")
session_count=0

> "$group_dir/index"

while IFS= read -r session; do
	session_cwd=$(tmux display-message -t "$session" -p "#{session_path}")
	save_file="$group_dir/${session}_${timestamp}"
	last_file="$group_dir/${session}_last"
	save_session_to_file "$save_file" "$last_file" "$session_cwd" "$session"
	echo "${session}_${timestamp}" >> "$group_dir/index"
	session_count=$((session_count + 1))
done < <(tmux list-sessions -F "#{session_name}")

if [[ $session_count -eq 0 ]]; then
	rm -rf "$group_dir"
	tmux display-message -d0 "#[bg=red]No sessions found to save."
	exit 0
fi

tmux display-message "Group '$group_name' saved ($session_count sessions)"

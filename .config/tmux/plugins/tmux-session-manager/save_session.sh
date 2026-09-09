#!/usr/bin/env bash
session_cwd="$(tmux -c pwd)"
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
source common_utils.sh

# Save a session to a given file.
# Usage: save_current_session "$save_file" "$last_file" "$session_cwd" "$session_name"
save_current_session() {
	local save_file="$1"
	local last_file="$2"
	local session_cwd="$3"
	local session_name="$4"

	declare S=$SEPARATOR

	local WINDOW_FORMAT="window$S#{window_index}$S#{window_name}$S#{window_layout}$S#{window_active}"
	local PANE_FORMAT="pane$S#{pane_index}$S#{pane_current_path}$S#{pane_active}$S#{window_index}$S#{pane_pid}"

	if [[ -e "${save_file}_archived" ]]; then
		mv "${save_file}_archived" "$save_file"
	fi
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
	if ! cmp -s "$save_file" "$last_file" 2>/dev/null; then
		ln -sf "$save_file" "$last_file"
	else
		rm "$save_file"
	fi
}

start_spinner "Saving current session"
save_current_session "$NEW_SAVE_FILE" "$LAST_SAVE_FILE" "$session_cwd" "$CURRENT_SESSION"
stop_spinner "Session saved"

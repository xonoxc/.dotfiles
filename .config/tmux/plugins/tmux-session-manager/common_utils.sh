# Version
export VERSION="1.1.2"

# Empty globs expand to nothing, so "no saved sessions" never shows literal patterns.
shopt -s nullglob

# Get the current tmux session name.
CURRENT_SESSION=$(
	if [ "$(tmux display-message -p "#{session_grouped}")" = 0 ]; then
		tmux display-message -p "#{session_name}"
	else
		tmux display-message -p "#{session_group}"
	fi
)

# Separator in save files
export SEPARATOR=$'\t'

# Get the value of a tmux option or a default value if the option is not set.
# Usage: get_tmux_option "name of option" "default value"
get_tmux_option() {
	local -r option_name="$1"
	local -r default_value="$2"
	local -r tmux_value=$(tmux show-option -gqv "$option_name")
	if [ -n "$tmux_value" ]; then
		echo "$tmux_value"
	else
		echo "$default_value"
	fi
}

# Get the save directory from the tmux options and expand $HOME.
SAVE_DIR=$(get_tmux_option "@session-manager-save-dir" "${HOME}/.local/share/tmux/sessions" | sed "s,\$HOME,$HOME,g; s,\~,$HOME,g")
mkdir -p "$SAVE_DIR"
export SAVE_DIR

# Get the path for the new save file.
NEW_SAVE_FILE="${SAVE_DIR}/${CURRENT_SESSION}_$(date +"%Y-%m-%dT%H:%M:%S")"
export NEW_SAVE_FILE

# Get the path for the last save file for this session.
export LAST_SAVE_FILE="${SAVE_DIR}/${CURRENT_SESSION}_last"

new_spinner() {
	local current=0
	local -r chars="/-\|"
	while true; do
		tmux display-message -- "${chars:$current:1} $1"
		current=$(((current + 1) % 4))
		sleep 0.1
	done
}

# Start a spinner with a message.
# Usage: start_spinner "Some message"
start_spinner() {
	new_spinner "$1"&
	export SPINNER_PID=$!
}

# Stop the current spinner and display a message.
# Usage: stop_spinner "Some message"
stop_spinner() {
	kill "$SPINNER_PID"
	tmux display-message "$1"
}

# Open selection for list of sessions
# Usage: select_session "$(get_sessions)"
# Themed to match the user's tmux palette: current line = #242a30 (the ||
# blocks), pointer/prompt = accent blue #7797b7, markers = accent green #8aac8b.
select_session() {
	local -r fzf_colors="bg:#1a2026,fg:#dcdcdc,bg+:#242a30,fg+:#ffffff,hl:#8aac8b,hl+:#8aac8b,info:#565c62,pointer:#7797b7,marker:#8aac8b,prompt:#7797b7,spinner:#7797b7,header:#565c62,border:#2d3339"
	local -r sessions=$(echo "$1" | sort | uniq)
	if command -v fzf 1>/dev/null; then
		echo "$sessions" | fzf --ansi --color="$fzf_colors"
	else
		PS3="Select session or 0 to cancel: "
		select session in $sessions; do
			if (( REPLY == 0 )); then
				exit
			elif (( REPLY > 0 && REPLY <= $(echo "$sessions" | wc -w) )); then
				echo "$session"
				break
			fi
		done
	fi
}

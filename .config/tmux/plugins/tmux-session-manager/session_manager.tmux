#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit
source common_utils.sh

if [[ $(get_tmux_option "@session-manager-disable-fzf-warning" "off") != "on" && ! $(command -v fzf) ]]; then
	tmux display-message "Warning: fzf was not found in PATH. Recommended for tmux-session-manager. If that is intentional, you can disable this message."
	exit
fi

declare key
declare bindings

# Popup configuration
POPUP_WIDTH="42%"
POPUP_HEIGHT="35%"

# Save
bindings=$(get_tmux_option "@session-manager-save-key" "C-s")
for key in $bindings; do
	tmux bind-key "$key" run-shell "$(pwd)/save_session.sh"
done

bindings=$(get_tmux_option "@session-manager-save-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" run-shell "$(pwd)/save_session.sh"
done

# Save Group
bindings=$(get_tmux_option "@session-manager-save-group-key" "S")
for key in $bindings; do
	tmux bind-key "$key" command-prompt -p "Group name: " \
		"run-shell '$(pwd)/save_group.sh %1'"
done

bindings=$(get_tmux_option "@session-manager-save-group-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" command-prompt -p "Group name: " \
		"run-shell '$(pwd)/save_group.sh %1'"
done

# Restore
bindings=$(get_tmux_option "@session-manager-restore-key" "C-r")
for key in $bindings; do
	tmux bind-key "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 RESTORE SESSIONS 󰗆 ' \
		'$(pwd)/restore_session.sh'"
done

bindings=$(get_tmux_option "@session-manager-restore-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 RESTORE SESSIONS 󰗆 ' \
		'$(pwd)/restore_session.sh'"
done

# Switch (replaces default 'prefix + s' session chooser)
# Unbind the default 's' (choose-tree) first so our binding takes over
tmux unbind-key -T prefix s 2>/dev/null || true
bindings=$(get_tmux_option "@session-manager-switch-key" "s")
for key in $bindings; do
	tmux bind-key "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 SWITCH SESSION 󰗆 ' \
		'$(pwd)/switch_session.sh'"
done

bindings=$(get_tmux_option "@session-manager-switch-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 SWITCH SESSION 󰗆 ' \
		'$(pwd)/switch_session.sh'"
done


# Kill (running session only — no persistence file deletion)
# Switches away from the current session first so the user isn't dropped.
bindings=$(get_tmux_option "@session-manager-kill-key" "X")
for key in $bindings; do
	tmux bind-key "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#e89199,bold] 󰗆 KILL SESSION 󰗆 ' \
		'$(pwd)/kill_session.sh'"
done

bindings=$(get_tmux_option "@session-manager-kill-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#e89199,bold] 󰗆 KILL SESSION 󰗆 ' \
		'$(pwd)/kill_session.sh'"
done

# Delete persistence files only (no tmux kill — session keeps running)
# Shows running + saved + groups.  Switches away from current session first.
bindings=$(get_tmux_option "@session-manager-delete-persistence-key" "D")
for key in $bindings; do
	tmux bind-key "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 DELETE PERSISTENCE FILES 󰗆 ' \
		'$(pwd)/delete_persistence.sh'"
done

bindings=$(get_tmux_option "@session-manager-delete-persistence-key-root" "")
for key in $bindings; do
	tmux bind-key -n "$key" run-shell \
		"tmux display-popup -E -w $POPUP_WIDTH -h $POPUP_HEIGHT -b rounded \
		-T '#[bg=#242a30,fg=#7797b7,bold] 󰗆 DELETE PERSISTENCE FILES 󰗆 ' \
		'$(pwd)/delete_persistence.sh'"
done


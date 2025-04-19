function fzf_history_widget
	set -l selected (history | fzf --tac)
	if test -n "$selected"
		commandline --replace "$selected"
	end
end

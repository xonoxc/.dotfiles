##################################################################################
###██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗    ███████╗██╗███████╗██╗  ██╗###
##██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝    ██╔════╝██║██╔════╝██║  ██║###
##██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗   █████╗  ██║███████╗███████║###
##██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║   ██╔══╝  ██║╚════██║██╔══██║###
##╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝██╗██║     ██║███████║██║  ██║###
##╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝####
##################################################################################

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting


#echo "i use arch btw!!! >_<"

# function to fuzzy find and change directory
function fd
    # If user passed an argument, use it; else use current directory (.)
    if test (count $argv) -gt 0
        set target $argv[1]
    else
        set target .
    end

    # Now safely run find
    set dir (find $target -type d 2>/dev/null | fzf +m)

    # Only cd if user picked something
    if test -n "$dir"
        cd "$dir"
    end
end

# function to check updates whenever needed
function cu 
    echo "wait ..."
	set update_count (checkupdates 2>/dev/null | wc -l )

	if test $update_count -gt 0 
		echo " $update_count updates available."
	end
end

#function to extract any type of files
function extract
    set file $argv[1]
    if test -f $file
        switch (string match -r '\.([^.]+)$' -- $file)
            case 'tar.gz' 'tgz'
                tar xzf $file
            case 'tar.bz2' 'tbz'
                tar xjf $file
            case 'tar.xz' 'txz'
                tar xJf $file
            case 'zip'
                unzip $file
            case '*'
                echo "Unsupported file type"
        end
    else
        echo "$file is not a valid file"
    end
end


# config reload
function reload-config
    source ~/.config/fish/config.fish
    echo "Fish configuration reloaded...."
end



#initializing the starship prompt 
starship init fish | source

#git bare repository control alias 
function dotfiles
  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv
end



function fish_user_key_bindings
    bind -M \cr fzf_history_widget
end


# Start SSH agent if not already running
# if not pgrep -u $USER ssh-agent > /dev/null
#     eval (ssh-agent -c)
#     ssh-add ~/.ssh/id_ed25519
# end
#
# using linter for golang
function gci 
	$HOME/go/bin/golangci-lint
end



# shell variables 
set -x BROWSER "zen-browser"
set -x HYPRSHOT_DIR "/home/xonoxc/Pictures"
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin

set -x PATH $HOME/Android/Sdk/platform-tools $PATH
set -x PATH $HOME/Android/Sdk/cmdline-tools/latest/bin $PATH

set -x PATH $HOME/.cargo/bin $PATH


# accepting autosuggestions using TAB 
bind -M insert \t accept-autosuggestion

#setting up some of my alias 
alias v="nvim"
alias ls="exa --icons"
alias sd="cd ~ && cd \$(find . -type d | sed 's|^\./||' | fzf)"
alias la="ls -A"
alias ll="ls -alF"
alias l='ls -CF'
alias cl="clear"
alias l="ls -CF"
alias .files="cd ~/.dotfiles"




# shell path variables 
set -x PATH $PATH $HOME/.config/composer/vendor/bin

#sdk man config
set -U fish_user_paths $HOME/.sdkman
set -g __sdkman_custom_dir $HOME/.sdkman/bin/sdkman-init.sh

# react native packager hostname
set -x REACT_NATIVE_PACKAGER_HOSTNAME 192.168.1.40

#shell path for elixir-ls
set -gx PATH $PATH $HOME/.local/share/nvim/mason/bin
set -gx PATH $PATH $HOME/.local/bin


set -Ux PYENV_ROOT $HOME/.pyenv
set -U fish_user_paths $PYENV_ROOT/bin $fish_user_paths


pyenv init - | source

# changing default editor
set -gx EDITOR "nvim"


# sourcing various packages 

 set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /home/darkxx/.ghcup/bin $PATH # ghcup-env

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH


set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# pnpm
set -gx PNPM_HOME "/home/xonoxc/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end



set -xU GEMINI_API_KEY "AIzaSyAxcBDr81dQgsDqKgO28xMhTXqfUSNEaPY"



#binding the ctrl+e for to open superfile

# keybindigs for all modes should be put here
for mode in (bind -L)
    bind -M $mode \ce spf
    bind -M $mode \cr fzf_history_widget
end


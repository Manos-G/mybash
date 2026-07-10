#!/usr/bin/env bash
iatest=$(expr index "$-" i)

#######################################################
# SOURCED ALIAS'S AND SCRIPTS BY zachbrowne.me
#######################################################

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash programmable completion features in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

#######################################################
# ENVIRONMENT
#######################################################

# set up XDG folders
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Seeing as other scripts will use it might as well export it
export LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

# Set the default editor
export EDITOR=nano
export VISUAL=nano

export PATH=$PATH:"$HOME/.local/bin:$HOME/.cargo/bin:/var/lib/flatpak/exports/bin:/.local/share/flatpak/exports/bin"

export PICO_SDK_PATH=/home/manos/pico-sdk

#######################################################
# Source modular configuration files
#######################################################
# Resolve the real directory of this .bashrc (it is symlinked from the repo)
MYBASH_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

for module in functions aliases history ui ros2; do
	if [ -f "$MYBASH_DIR/$module.bash" ]; then
		source "$MYBASH_DIR/$module.bash"
	fi
done

unset module

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
